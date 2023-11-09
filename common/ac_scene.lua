__source 'lua/api_scene.cpp'
__allow 'scene'

require './ac_ray'
require './ac_display'
require './ac_render_enums'
require './ac_render_shader'

local _sp_scenep = {template = 'project.fx', defaultBlendMode = render.BlendMode.BlendAccurate, delayed = true}

-- Mesh vertex related stuff:

ffi.cdef [[ typedef struct { vec3 pos; vec3 normal; vec2 uv; vec3 __extras; } lua_mesh_vertex; ]]

---Mesh vertex.
---@class ac.MeshVertex
---@field pos vec3
---@field normal vec3
---@field uv vec2
---@constructor fun(pos: vec3, normal: vec3, uv: vec2): ac.MeshVertex
ac.MeshVertex = ffi.metatype('lua_mesh_vertex', {
  __len = function(s) return #s.pos end,
  __index = {
    ---Creates new mesh vertex.
    ---@param pos vec3
    ---@param normal vec3
    ---@param uv vec2
    ---@return ac.MeshVertex
    new = function(pos, normal, uv)
      return ac.MeshVertex(pos, normal or vec3(0, 1, 0), uv or vec2())
    end,
  }
})

local __vecMeshVertices = __util.arrayType(ffi.typeof('lua_mesh_vertex'))
local __vecMeshIndices = __util.arrayType(ffi.typeof('uint16_t'))

---Buffer with mesh vertices. Contains `ac.MeshVertex` items.
---@class ac.VertexBuffer : ac.GenericList
---@constructor fun(size: nil|integer|ac.MeshVertex[] "Initial size or initializing values."): ac.VertexBuffer

function ac.VertexBuffer(size)
  local ret = __vecMeshVertices(0, size)
  if type(size) == 'number' then
    ffi.C.lj_init_vertices__scene(ret.raw, size)
  end
  return ret
end

---Buffer with mesh indieces. Contains `integer` items (limited by 16 bits for AC to handle).
---@class ac.IndicesBuffer : ac.GenericList
---@constructor fun(size: nil|integer|integer[] "Initial size or initializing values."): ac.IndicesBuffer

function ac.IndicesBuffer(size)
  return __vecMeshIndices(0, size)
end

-- Scene references:

local function cr(v)
  if v == nil then return nil end
  return ffi.gc(v, ffi.C.lj_noderef_gc__scene)
end

local function nf(v)
  if type(v) == 'table' then
    return '{' .. table.join(v, ', ') .. '}'
  end
  return v ~= nil and tostring(v) or ""
end

local function _emptyNodeRef()
  return cr(ffi.C.lj_noderef_new__scene(nil, 1))
end

local function _passRefArgs(other)
  if type(other) == 'table' then
    ffi.C.lj_noderef_begin_arg_pass__scene()
    for i = 2, #other do
      ffi.C.lj_noderef_arg_pass__scene(other[i])
    end
    other = other[1]
  end
  return other
end

local _texBgSkip = rgbm(0,0,0,-1)
local _texBgOriginal = rgbm(-1,0,0,0)
local _vecUp = vec3(0, 1, 0)

local function __sip(s, i)
  i = i + 1
  if i <= s.__size then return i, s:at(i) end
end

---Reference to one or several objects in scene. Works similar to those jQuery things which would refer to one or
---several of webpage elements. Use methods like `ac.findNodes()` to get one. Once you have a reference to some nodes,
---you can load additional KN5s, create new nodes and such in it.
---Note: it might be beneficial in general to prefer methods like `ac.findNodes()` and `ac.findMeshes()` over `ac.findAny()`.
---Should be fewer surprises this way.
---@class ac.SceneReference
ffi.cdef [[ typedef struct { int __size; } noderef; ]]
ffi.metatype('noderef', {
  __len = function(s) return s.__size end,
  __tostring = function(s)
    return string.format('ac.SceneReference<%d>', s.__size)
  end,
  __ipairs = function(s)
    return __sip, s, 0
  end,
  __index = {

    ---Dispose any resources associated with this `ac.SceneReference` and empty it out. Use it if you need to remove a previously
    ---created node or a loaded KN5.
    dispose = function (s) return ffi.C.lj_noderef_dispose__scene(s) end,

    ---Set debug outline for meshes in the reference. Outline remains active until explicitly disabled or until reference is released.
    ---Note: each outlined group adds a render target switch and additional draw calls, so avoid adding it to more than, let’s say,
    ---ten groups at once (each group can have multiple meshes in it). 
    ---@param color rgbm? @Outline color. Use `nil` or transparent color to disable outline.
    ---@return ac.SceneReference @Returns self for easy chaining.
    setOutline = function (s, color)
      ffi.C.lj_noderef_setoutline__scene(s, __util.ensure_rgbm_nil(color) or rgbm.colors.transparent)
      return s
    end,

    ---Set material property. Be careful to match the type (you need the same amount of numeric values). If you’re using boolean,-
    ---resulting value will be either 1 or 0.
    ---@param property string | "'ksEmissive'"
    ---@param value number|vec2|vec3|rgb|vec4|rgbm|boolean
    ---@return ac.SceneReference @Returns self for easy chaining.
    setMaterialProperty = function (s, property, value)
      property = __util.str(property)
      if type(value) == 'number' then ffi.C.lj_noderef_setmaterialproperty1__scene(s, property, value)
      elseif vec2.isvec2(value) then ffi.C.lj_noderef_setmaterialproperty2__scene(s, property, value)
      elseif vec3.isvec3(value) then ffi.C.lj_noderef_setmaterialproperty3__scene(s, property, value)
      elseif rgb.isrgb(value) then ffi.C.lj_noderef_setmaterialproperty3c__scene(s, property, value)
      elseif vec4.isvec4(value) then ffi.C.lj_noderef_setmaterialproperty4__scene(s, property, value) 
      elseif rgbm.isrgbm(value) then ffi.C.lj_noderef_setmaterialproperty4c__scene(s, property, value) 
      elseif type(value) == 'boolean' then ffi.C.lj_noderef_setmaterialproperty1__scene(s, property, value and 1 or 0)
      else error('Not supported type: '..value, 2) end
      return s
    end,

    ---Set material texture. Three possible uses:
    ---
    ---1. Pass color to create a new solid color texture:
    ---  ```
    ---  meshes:setMaterialTexture('txDiffuse', rgbm(1, 0, 0, 1)) -- for red color
    ---  ```
    ---2. Pass filename to load a new texture. Be careful, it would load texture syncronously unless it
    ---  was loaded before:
    ---  ```
    ---  meshes:setMaterialTexture('txDiffuse', 'filename.dds')
    ---  ```
    ---3. Pass a table with parameters to draw a texture in a style of scriptable displays. Be careful as to
    ---  not call it too often, make sure to limit refresh rate unless you really need a quick update. If you’re
    ---  working on a track script, might also be useful to check if camera is close enough with something like
    ---  ac.getSim().cameraPosition:closerToThan(display coordinates, some distance)
    ---  ```
    ---  meshes:setMaterialTexture('txDiffuse', {
    ---    textureSize = vec2(1024, 1024), -- although optional, I recommend to set it: skin could replace texture by one with different resolution
    ---    background = rgbm(1, 0, 0, 1),  -- set to `nil` (or remove) to reuse original texture as background, set to `false` to skip background preparation completely
    ---    region = {                      -- if not set, whole texture will be repainted
    ---        from = vec2(200, 300),
    ---        size = vec2(400, 400)
    ---    },
    ---    callback = function (dt)
    ---      display.rect{ pos = …, size = …, … }
    ---    end
    ---  })
    ---  ```
    ---@param texture string | "'txDiffuse'" | "'txNormal'" | "'txEmissive'" | "'txMaps'" @Name of a texture slot.
    ---@tableparam value { callback: fun(dt: number), textureSize: vec2 = (512, 512), region: { from: vec2 = (0, 0), size: vec2 = (512, 512) }, background: rgbm|boolean|nil = nil }
    ---@overload fun(texture: string, value: string)
    ---@overload fun(texture: string, value: rgbm)
    ---@return ac.SceneReference @Returns self for easy chaining.
    setMaterialTexture = function (s, texture, value)
      if type(value) == 'string' or tostring(value):sub(1, 1) == '$' then
        ffi.C.lj_noderef_setmaterialtexture_file__scene(s, texture, tostring(value))
      elseif type(value) == 'table' then
        if not value.callback then error('Callback is missing', 2) end
        local dt = ffi.C.lj_noderef_setmaterialtexture_begin__scene(s, texture,
          __util.ensure_vec2(value.textureSize),
          value.background ~= nil and (value.background == false and _texBgSkip or __util.ensure_rgbm(value.background)) or _texBgOriginal,
          __util.ensure_vec2(value.region and value.region.from), __util.ensure_vec2(value.region and value.region.size))
        if dt >= 0 then
          __util.pushEnsureToCall(ffi.C.lj_noderef_setmaterialtexture_end__scene)
          value.callback(dt)
          __util.popEnsureToCall()
        end
      else
        ffi.C.lj_noderef_setmaterialtexture_color__scene(s, texture, __util.ensure_rgbm(value))
      end
      return s
    end,

    ---Ensures all materials are unique, allowing to alter their textures and material properties without affecting the rest of the scene. Only
    ---ensures uniqueness relative to the rest of the scene. For example, if it refers to two meshes using the same material, they’ll continue
    ---to share material, but it would be their own material, separate from the scene.
    ---@return ac.SceneReference @Returns self for easy chaining.
    ensureUniqueMaterials = function (s) ffi.C.lj_noderef_ensureuniquematerials__scene(s) return s end,

    ---Stores current transformation to be restored when `ac.SceneReference` is disposed (for example, when script reloads). Might be a good
    ---idea to use it first on any nodes you’re going to move, so all of them would get back when script is reloaded (assuming their original 
    ---transformation is important, like it is with needles, for example).
    ---@return ac.SceneReference @Returns self for easy chaining.
    storeCurrentTransformation = function (s) ffi.C.lj_noderef_storecurrenttransform__scene(s) return s end,

    ---CSP keeps track of previous world position of each node to do its motion blur. This call would clear that value, so teleported, for
    ---example, objects wouldn’t have motion blur artifacts for a frame.
    ---@return ac.SceneReference @Returns self for easy chaining.
    clearMotion = function (s) ffi.C.lj_noderef_clearmotion__scene(s) return s end,

    ---Number of elements in this reference. Alternatively, you can use `#` operator.
    ---@return integer
    size = function (s) return s.__size end,

    ---If reference is empty or not.
    ---@return boolean
    empty = function (s) return s.__size == 0 end,

    ---Find any children that match filter and return a new reference to them.
    ---@param filter string @Node/mesh filter.
    ---@return ac.SceneReference @Reference to found scene elements.
    findAny = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 0)) end,

    ---Find any child nodes that match filter and return a new reference to them.
    ---@param filter string @Node filter.
    ---@return ac.SceneReference @Reference to found nodes.
    findNodes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 0x10000)) end,

    ---Find any child meshes that match filter and return a new reference to them.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found meshes.
    findMeshes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 0x20000)) end,

    ---Find any child skinned meshes that match filter and return a new reference to them.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found skinned meshes.
    findSkinnedMeshes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 0x40000)) end,

    ---Find any child objects of a certain class that match filter and return a new reference to them.
    ---@param objectClass ac.ObjectClass @Objects class.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found skinned meshes.
    findByClass = function (s, objectClass, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), tonumber(objectClass) or 0)) end,

    ---Filters current reference and returns new one with objects that match filter only.
    ---@param filter string @Node/mesh filter.
    ---@return ac.SceneReference @Reference to found scene elements.
    filterAny = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_filter__scene(s, nf(filter), 0)) end,

    ---Filters current reference and returns new one with nodes that match filter only.
    ---@param filter string @Node filter.
    ---@return ac.SceneReference @Reference to found nodes.
    filterNodes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_filter__scene(s, nf(filter), 0x10000)) end,

    ---Filters current reference and returns new one with meshes that match filter only.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found meshes.
    filterMeshes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_filter__scene(s, nf(filter), 0x20000)) end,

    ---Filters current reference and returns new one with skinned meshes that match filter only.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found skinned meshes.
    filterSkinnedMeshes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_filter__scene(s, nf(filter), 0x40000)) end,

    ---Filters current reference and returns new one with objects of a certain class that match filter only.
    ---@param objectClass ac.ObjectClass @Objects class.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found skinned meshes.
    filterByClass = function (s, objectClass, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_filter__scene(s, nf(filter), tonumber(objectClass) or 0)) end,

    ---Create a new node with a given name and attach it as a child.
    ---@param name string
    ---@param keepAlive boolean @Set to `true` to create a long-lasting node which wouldn’t be removed when script is reloaded.
    ---@return ac.SceneReference @Newly created node or `nil` if failed
    createNode = function (s, name, keepAlive) return cr(ffi.C.lj_noderef_createnode__scene(s, name, keepAlive ~= true)) end,

    ---Create a new mesh with a given name and attach it as a child. Steals passed vertices and indices to avoid reallocating
    ---memory, so make sure to use `vertices:clone()` when passing if you want to keep the original data. 
    ---@param name string
    ---@param materialName string?
    ---@param vertices ac.VertexBuffer
    ---@param indices ac.IndicesBuffer
    ---@param keepAlive boolean @Set to `true` to create a long-lasting node which wouldn’t be removed when script is reloaded.
    ---@param moveData boolean? @Set to `true` to move vertices and indices data thus saving on reallocating memory. You can use `vertices:clone()` for one of them to retain original array. Default value: `false`.
    ---@return ac.SceneReference @Newly created mesh or `nil` if failed
    createMesh = function (s, name, materialName, vertices, indices, keepAlive, moveData)
      local v0, v1, v2 = __util.stealVector(vertices, moveData)
      local i0, i1, i2 = __util.stealVector(indices, moveData)
      return cr(ffi.C.lj_noderef_createmesh__scene(s, name, materialName and tostring(materialName) or nil, keepAlive ~= true,
        v0, v1, v2, i0, i1, i2))
    end,

    ---Replace mesh vertices dynamically. New number of vertices should match existing one, indices work the same. Can be used for dynamic
    ---mesh alteration (for example, deformation). Calling it each frame with highly detailed mesh might still affect performance negatively though.
    ---@param vertices ac.VertexBuffer
    ---@return ac.SceneReference @Returns self for easy chaining.
    alterVertices = function (s, vertices)
      ffi.C.lj_noderef_dynamicvertices__scene(s, vertices.raw, vertices._size)
      return s
    end,

    ---Get vertices of a first mesh in selection. Makes a copy into an `ac.VertexBuffer`, so it might be expensive to call each frame, but it can be called
    ---once for those vertices to later be used with `:alterVertices()` method.
    ---@return ac.VertexBuffer? @Returns `nil` if there are no suitable meshes in selection.
    getVertices = function (s)
      local num = refnumber(0)
      local ptr = ffi.C.lj_noderef_getvertices__scene(s, num)
      return ptr ~= nil and __vecMeshVertices(num.value, ptr) or nil
    end,

    ---Create a new bounding sphere node with a given name and attach it as a child. Using those might help with performance: children
    ---would skip bounding frustum test, and whole node would not get traversed during rendering if it’s not in frustum.
    ---
    ---Note: for it to work properly, it’s better to attach it to AC cars node, as that one does expect those bounding sphere nodes
    ---to be inside of it. You can find it with `ac.findNodes('carsRoot:yes')`.
    ---@param name string
    ---@return ac.SceneReference @Can return `nil` if failed.
    createBoundingSphereNode = function (s, name, radius) return cr(ffi.C.lj_noderef_createbsnode__scene(s, name, radius)) end,

    ---Load KN5 model and attach it as a child. To use remote models, first load them with `web.loadRemoteModel()`.
    ---
    ---Node: The way it actually works, KN5 would be loaded in a pool and then copied here (with sharing
    ---of resources such as vertex buffers). This generally helps with performance.
    ---@param filename string @KN5 filename relative to script folder or AC root folder.
    ---@return ac.SceneReference @Can return `nil` if failed.
    loadKN5 = function (s, filename) return cr(ffi.C.lj_noderef_loadkn5__scene(s, filename)) end,

    ---Load KN5 LOD model and attach it as a child. Parameter `mainFilename` should refer to the main KN5 with all the textures.
    ---
    ---Node: The way it actually works, KN5 would be loaded in a pool and then copied here (with sharing
    ---of resources such as vertex buffers). This generally helps with performance. Main KN5 would be
    ---loaded as well, but not shown, and instead kept in a pool.
    ---@param filename string @KN5 filename relative to script folder or AC root folder.
    ---@param mainFilename string @Main KN5 filename relative to script folder or AC root folder.
    ---@return ac.SceneReference @Can return `nil` if failed.
    loadKN5LOD = function (s, filename, mainFilename) return cr(ffi.C.lj_noderef_loadkn5lod__scene(s, filename, mainFilename)) end,

    ---Load KN5 model and attach it as a child asyncronously. To use remote models, first load them with `web.loadRemoteModel()`.
    ---
    ---Node: The way it actually works, KN5 would be loaded in a pool and then copied here (with sharing
    ---of resources such as vertex buffers). This generally helps with performance.
    ---@param filename string @KN5 filename relative to script folder or AC root folder.
    ---@param callback fun(err: string, loaded: ac.SceneReference?) @Callback called once model is loaded.
    loadKN5Async = function (s, filename, callback) 
      ffi.C.lj_noderef_loadkn5_async__scene(s, filename, __util.expectReply(function (err, returnIndex)
        if err then callback(err, nil)
        else callback(nil, cr(ffi.C.lj_noderef_access_reply__scene(returnIndex))) end
      end))
    end,

    ---Load KN5 model and attach it as a child asyncronously. Parameter `mainFilename` should refer to the main KN5 with all the textures.
    ---
    ---Node: The way it actually works, KN5 would be loaded in a pool and then copied here (with sharing
    ---of resources such as vertex buffers). This generally helps with performance. Main KN5 would be
    ---loaded as well, but not shown, and instead kept in a pool.
    ---@param filename string @KN5 filename relative to script folder or AC root folder.
    ---@param mainFilename string @Main KN5 filename relative to script folder or AC root folder.
    ---@param callback fun(err: string, loaded: ac.SceneReference?) @Callback called once model is loaded.
    loadKN5LODAsync = function (s, filename, mainFilename, callback) 
      ffi.C.lj_noderef_loadkn5lod_async__scene(s, filename, mainFilename, __util.expectReply(function (err, returnIndex)
        if err then callback(err, nil)
        else callback(nil, cr(ffi.C.lj_noderef_access_reply__scene(returnIndex))) end
      end))
    end,

    ---Loads animation from a file (on first call only), sets animation position. To use remote animations, first load them with `web.loadRemoteAnimation()`.
    ---@param filename string @Animation filename (”…ksanim”). If set to `nil`, no animation will be applied.
    ---@param position number? @Animation position from 0 to 1. Default value: 0.
    ---@param force boolean? @If not set to `true`, animation will be applied only if position is different from position used previously. Default value: `false`.
    ---@return ac.SceneReference @Returns self for easy chaining.
    setAnimation = function (s, filename, position, force) 
      ffi.C.lj_noderef_setksanim__scene(s, filename and tostring(filename) or nil, tonumber(position) or 0, force == true)
      return s
    end,

    ---@param visible boolean
    ---@return ac.SceneReference @Returns self for easy chaining.
    setVisible = function (s, visible) ffi.C.lj_noderef_setvisible__scene(s, visible == true) return s end,

    ---@param shadows boolean
    ---@return ac.SceneReference @Returns self for easy chaining.
    setShadows = function (s, shadows) ffi.C.lj_noderef_setshadows__scene(s, shadows == true) return s end,

    ---@param exclude boolean
    ---@return ac.SceneReference @Returns self for easy chaining.
    excludeFromCubemap = function (s, exclude) ffi.C.lj_noderef_setexcludecubemap__scene(s, exclude == true) return s end,

    ---@param exclude boolean
    ---@return ac.SceneReference @Returns self for easy chaining.
    excludeFromSecondary = function (s, exclude) ffi.C.lj_noderef_setexcludesecondary__scene(s, exclude == true) return s end,

    ---@param transparent boolean
    ---@return ac.SceneReference @Returns self for easy chaining.
    setTransparent = function (s, transparent) ffi.C.lj_noderef_settransparent__scene(s, transparent == true) return s end,

    ---@param mode render.BlendMode
    ---@return ac.SceneReference @Returns self for easy chaining.
    setBlendMode = function (s, mode) ffi.C.lj_noderef_setblendmode__scene(s, tonumber(mode)) return s end,

    ---@param mode render.CullMode
    ---@return ac.SceneReference @Returns self for easy chaining.
    setCullMode = function (s, mode) ffi.C.lj_noderef_setcullmode__scene(s, tonumber(mode)) return s end,

    ---@param mode render.DepthMode
    ---@return ac.SceneReference @Returns self for easy chaining.
    setDepthMode = function (s, mode) ffi.C.lj_noderef_setdepthmode__scene(s, tonumber(mode)) return s end,

    ---Sets attribute associated with current meshes or nodes. Attributes are stored as strings, but you can access them as numbers with `:getAttibute()` by
    ---passing number as `defaultValue`. To find meshes with a certain attribute, use “hasAttribute:name” search query.
    ---@param key string
    ---@param value number|string|nil @Pass `nil` to remove an attribute.
    ---@return ac.SceneReference @Returns self for easy chaining.
    setAttribute = function (s, key, value) ffi.C.lj_noderef_setattribute__scene(s, tostring(key), value ~= nil and tostring(value) or nil) return s end,

    ---Gets an attribute value.
    ---@param key string
    ---@param defaultValue number|string|nil @If `nil` is passed, returns string (or `nil` if attribute is not set).
    ---@return string|number|nil @Type is determined based on type of `defaultValue`.
    getAttribute = function (s, key, defaultValue) 
      if type(defaultValue) == 'number' then return ffi.C.lj_noderef_getattributenum__scene(s, tostring(key), defaultValue) end
      return __util.strrefp(ffi.C.lj_noderef_getattributestr__scene(s, tostring(key))) or defaultValue
    end,

    ---Reference:
    ---- Reduced TAA: 1;
    ---- Extra TAA: 0.5.
    ---@param value number
    ---@return ac.SceneReference @Returns self for easy chaining.
    setMotionStencil = function (s, value) ffi.C.lj_noderef_setmotionstencil__scene(s, tonumber(value) or 0) return s end,

    ---Sets position of a node (or nodes).
    ---
    ---Note: only nodes can move. If you need to move meshes, find their parent node and move it. If its parent node has more than a single mesh as a child,
    ---create a new node as a child of that parent and move mesh there.
    ---@param pos vec3
    ---@return ac.SceneReference @Returns self for easy chaining.
    setPosition = function (s, pos) ffi.C.lj_noderef_setposition__scene(s, __util.ensure_vec3(pos)) return s end,

    ---Sets orientation of a node (or nodes). If vector `up` is not provided, facing up vector will be used.
    ---
    ---Note: only nodes can rotate. If you need to rotate meshes, find their parent node and rotate it. If its parent node has more than a single mesh as a child,
    ---create a new node as a child of that parent and move mesh there.
    ---@param look vec3
    ---@param up vec3|nil
    ---@return ac.SceneReference @Returns self for easy chaining.
    setOrientation = function (s, look, up) ffi.C.lj_noderef_setorientation__scene(s, __util.ensure_vec3(look), up and __util.ensure_vec3(up) or _vecUp) return s end,

    ---Replaces orientation of a node (or nodes) with rotational matrix. If you want to just rotate node from its current orientation, use `:rotate()`.
    ---
    ---Note: only nodes can rotate. If you need to rotate meshes, find their parent node and rotate it. If its parent node has more than a single mesh as a child,
    ---create a new node as a child of that parent and move mesh there.
    ---@param axis vec3
    ---@param angleRad number
    ---@return ac.SceneReference @Returns self for easy chaining.
    setRotation = function (s, axis, angleRad) ffi.C.lj_noderef_setrotation__scene(s, __util.ensure_vec3(axis), angleRad) return s end,

    ---Rotates node (or nodes) relative to its current orientation. If you want to completely replace its orientation by rotating matrix, use `:setRotation()`.
    ---
    ---Note: only nodes can rotate. If you need to rotate meshes, find their parent node and rotate it. If its parent node has more than a single mesh as a child,
    ---create a new node as a child of that parent and move mesh there.
    ---@param axis vec3
    ---@param angleRad number
    ---@return ac.SceneReference @Returns self for easy chaining.
    rotate = function (s, axis, angleRad) ffi.C.lj_noderef_rotate__scene(s, __util.ensure_vec3(axis), angleRad) return s end,

    ---Returns position of a first node relative to its parent.
    ---@return vec3
    getPosition = function (s) return ffi.C.lj_noderef_getposition__scene(s) end,

    ---Returns direction a first node is looking towards relative to its parent.
    ---@return vec3
    getLook = function (s) return ffi.C.lj_noderef_getlook__scene(s) end,

    ---Returns direction upwards of a first node relative to its parent.
    ---@return vec3
    getUp = function (s) return ffi.C.lj_noderef_getup__scene(s) end,

    ---Returns number of children of all nodes in current scene reference.
    ---@return integer
    getChildrenCount = function (s) return ffi.C.lj_noderef_getchildrencount__scene(s) end,

    ---Returns reference to transformation matrix of the first node relative to its parent. If you need to move
    ---something often, accessing its matrix directly might be the best way. Be careful though, if there
    ---are no nodes in the list, it would return `nil`.
    ---@return mat4x4 @Reference to transformation matrix of the first node, or nil. Use `mat4x4:set()` to update its value, or access its rows directly.
    getTransformationRaw = function (s)
      local m = ffi.C.lj_noderef_getrawmat4x4ptr__scene(s)
      return m and m[0] or nil
    end,

    ---Returns world transformation matrix of the first node. Do not use it to move node in world space (if you need
    ---to move in world space, either use `ref:getTransformationRaw():set(worldSpaceTransform:mul(ref:getParent():getWorldTransformationRaw():inverse()))` or
    ---simply move your node to a node without transformation, like root of dynamic objects). Be careful though, if there
    ---are no nodes in the list, it would return `nil`.
    ---@return mat4x4 @Reference to transformation matrix of the first node, or nil. Use `mat4x4:set()` to update its value, or access its rows directly.
    getWorldTransformationRaw = function (s)
      local m = ffi.C.lj_noderef_getrawmat4x4world__scene(s)
      return m and m[0] or nil
    end,
    
    --[[? if (ctx.flags.withPhysics) out(]]

    ---Sets object transformation to match transformation of a `physics.RigidBody` instance. If this object is within another object with non-identity transformation,
    ---it will be taken into account.
    ---
    ---There is also a method `physics.RigidBody:setTransformationFrom()` doing the opposite (and requiring an inverse of this matrix).
    ---@param rigidBody physics.RigidBody @Physics entity to sync transformation with.
    ---@param localTransform mat4x4? @Optional transformation of scene reference nodes relative to the physics entity.
    ---@return physics.RigidBody @Returns self for easy chaining.
    setTransformationFrom = function (s, rigidBody, localTransform)
      ffi.C.lj_noderef_settransformationfrom__scene(s, rigidBody, mat4x4.ismat4x4(localTransform) and localTransform or nil)
      return s
    end,

    --[[) ?]]
    
    ---Returns AABB (minimum and maximum coordinates in vector) of static meshes in current selection. Only regular static meshes
    ---are taken into account (meshes created when KN5 is exported in track mode).
    ---@return vec3 @Minimum coordinate.
    ---@return vec3 @Maximum coordinate.
    ---@return integer @Number of static meshes in selection.
    getStaticAABB = function (s)
      local min, max = vec3(), vec3()
      return min, max, ffi.C.lj_noderef_aabb__scene(s, min, max)
    end,
    
    ---Returns AABB (minimum and maximum coordinates in vector) of meshes in current selection in local mesh coordinates. Recalculates
    ---AABB live, might take some time with high-poly meshes.
    ---@return vec3 @Minimum coordinate.
    ---@return vec3 @Maximum coordinate.
    ---@return integer @Number of static meshes in selection.
    getLocalAABB = function (s)
      local min, max = vec3(), vec3()
      return min, max, ffi.C.lj_noderef_aabblocal__scene(s, min, max)
    end,

    ---Returns a new scene reference with a child in certain index (assuming current scene reference points to node). If current reference
    ---contains several nodes, children from all of them at given index will be collected.
    ---@param index integer? @1-based index of a child. Default value: 1.
    ---@return ac.SceneReference
    getChild = function (s, index) return cr(ffi.C.lj_noderef_child__scene(s, (tonumber(index) or 1) - 1)) end,

    ---Returns a new scene reference with first-class children (not children of children) of all nodes in current reference.
    ---@return ac.SceneReference
    getChildren = function (s) return cr(ffi.C.lj_noderef_child__scene(s, -1)) end,

    ---Returns a new scene reference with a parent of an object in current scene reference. If current reference
    ---contains several objects, parents of all of them will be collected.
    ---@return ac.SceneReference
    getParent = function (s) return cr(ffi.C.lj_noderef_parent__scene(s)) end,

    ---Adds nodes and meshes from another scene reference to current scene reference.
    ---@param sceneRef ac.SceneReference @Scene reference to append.
    ---@return ac.SceneReference @Returns self for easy chaining.
    append = function (s, sceneRef) ffi.C.lj_noderef_append__scene(s, sceneRef) return s end,

    ---Removes nodes and meshes from another scene reference from current scene reference.
    ---@param sceneRef ac.SceneReference @Scene reference to remove.
    ---@return ac.SceneReference @Returns self for easy chaining.
    subtract = function (s, sceneRef) ffi.C.lj_noderef_subtract__scene(s, sceneRef) return s end,

    ---Returns `true` if there is a node from `childSceneRef` somewhere in this node.
    ---@param childSceneRef ac.SceneReference @Scene reference to remove.
    ---@return boolean
    contains = function (s, childSceneRef) return ffi.C.lj_noderef_contains__scene(s, childSceneRef) end,

    ---Clears current scene reference.
    ---@return ac.SceneReference @Returns self for easy chaining.
    clear = function (s) ffi.C.lj_noderef_clear__scene(s) return s end,

    ---Casts a ray prepared by something like `render.createRay(pos, dir, length)` or `render.createMouseRay()`.
    ---
    ---If you need to access a mesh that was hit, set second argument to true:
    ---```
    ---local hitDistance, hitMesh = mesh:raycast(render.createRay(pos, dir), true)
    ---if hitDistance ~= -1 then
    ---  print(hitMesh:name())
    ---end
    ---```
    ---Alternatively, reuse your own scene reference for better performance if you need to cast
    ---a lot of rays:
    ---```
    ---local hitMesh = ac.emptySceneReference()
    ---local hitDistance = mesh:raycast(render.createRay(pos, dir), hitMesh)
    ---if hitDistance ~= -1 then
    ---  print(hitMesh:name())
    ---end
    ---```
    ---@param ray ray
    ---@param outSceneRef ac.SceneReference|boolean|nil
    ---@param outPosRef vec3|nil @Local position (not the world one).
    ---@param outNormalRef vec3|nil @Local normal.
    ---@param outUVRef vec2|nil @Texture coordinate.
    ---@return number @Distance to hit, or -1 if there was no hit.
    ---@return ac.SceneReference|nil @Reference to a mesh that was hit (same as `outSceneRef`, doubled here for convenience).
    raycast = function (s, ray, outSceneRef, outPosRef, outNormalRef, outUVRef)
      if outSceneRef == true then outSceneRef = _emptyNodeRef() 
      elseif outSceneRef == false then outSceneRef = nil end
      local distance = ffi.C.lj_noderef_raycast__scene(s, outSceneRef, ray, outPosRef, outNormalRef, outUVRef)
      return distance, outSceneRef
    end,

    ---Get name of an element.
    ---@param index integer|nil @1-based index of an element to get a name of. Default value: 1.
    ---@return string @Node or mesh name.
    name = function (s, index)
      return __util.strrefr(ffi.C.lj_noderef_name__scene(s, (tonumber(index) or 1) - 1))
    end,

    ---Get class of an element.
    ---@param index integer|nil @1-based index of an element to get a class of. Default value: 1.
    ---@return ac.ObjectClass @Number for class of an object.
    class = function (s, index)
      return ffi.C.lj_noderef_class__scene(s, (tonumber(index) or 1) - 1)
    end,
    
    ---Get material name of an element.
    ---@param index integer|nil @1-based index of an element to get a material name of. Default value: 1.
    ---@return string @Material name.
    materialName = function (s, index)
      return __util.strrefr(ffi.C.lj_noderef_materialname__scene(s, (tonumber(index) or 1) - 1))
    end,
    
    ---Get shader name of an element.
    ---@param index integer|nil @1-based index of an element to get a shader name of. Default value: 1.
    ---@return string @Shader name.
    shaderName = function (s, index)
      return __util.strrefr(ffi.C.lj_noderef_shadername__scene(s, (tonumber(index) or 1) - 1))
    end,
    
    ---Get number of texture slots of an element.
    ---@param index integer|nil @1-based index of an element to get number of texture slots of. Default value: 1.
    ---@return integer @Number of texture slots.
    getTextureSlotsCount = function (s, index)
      return ffi.C.lj_noderef_textureslotcount__scene(s, (tonumber(index) or 1) - 1)
    end,
    
    ---Get number of material properties of an element.
    ---@param index integer|nil @1-based index of an element to get number of material properties of. Default value: 1.
    ---@return integer @Number of material properties.
    getMaterialPropertiesCount = function (s, index)
      return ffi.C.lj_noderef_materialpropertycount__scene(s, (tonumber(index) or 1) - 1)
    end,
    
    ---Get name of a certain texture slot of an element.
    ---@param index integer|nil @1-based index of an element to get a name of a certain texture slot of. Default value: 1.
    ---@param slotIndex integer|nil @1-based index of a texture slot. Default value: 1.
    ---@return string|nil @Texture slot name (like “txDiffuse” or “txNormal”) or `nil` if there is no such element or property.
    getTextureSlotName = function (s, index, slotIndex)
      return __util.strrefp(ffi.C.lj_noderef_textureslotname__scene(s, (tonumber(index) or 1) - 1, slotIndex and slotIndex - 1 or 0))
    end,
    
    ---Get name of a certain material property of an element.
    ---@param index integer|nil @1-based index of an element to get a name of a certain material property of. Default value: 1.
    ---@param slotIndex integer|nil @1-based index of a material property. Default value: 1.
    ---@return string|nil @Material property name (like “ksDiffuse” or “ksAmbient”) or `nil` if there is no such element or property.
    getMaterialPropertyName = function (s, index, slotIndex)
      return __util.strrefp(ffi.C.lj_noderef_materialpropertyname__scene(s, (tonumber(index) or 1) - 1, slotIndex and slotIndex - 1 or 0))
    end,

    ---Get index of a certain texture slot of an element from the name of that slot.
    ---@param index integer|nil @1-based index of an element to get an index of a texture slot of. Default value: 1.
    ---@param slotName string|"'txDiffuse'"|"'txNormal'"|"'txEmissive'"|"'txMaps'" @Name of a texture slot.
    ---@return integer|nil @1-based texture slot index, or `nil` if there is no such property.
    ---@overload fun(s: ac.SceneReference, slotName: string): integer|nil
    getTextureSlotIndex = function (s, index, slotName)
      if type(index) == 'string' then index, slotName = 1, index end
      local r = ffi.C.lj_noderef_textureslotindex__scene(s, (tonumber(index) or 1) - 1, tostring(slotName))
      return r == -1 and nil or r + 1
    end,    
    
    ---Get index of a certain material property of an element from the name of that property.
    ---@param index integer|nil @1-based index of an element to get an index of a material property of. Default value: 1.
    ---@param propertyName string|"'ksDiffuse'"|"'ksAmbient'"|"'ksEmissive'" @Name of material property.
    ---@return integer|nil @1-based material property index, or `nil` if there is no such property.
    ---@overload fun(s: ac.SceneReference, propertyName: string): integer|nil
    getMaterialPropertyIndex = function (s, index, propertyName)
      if type(index) == 'string' then index, propertyName = 1, index end
      local r = ffi.C.lj_noderef_materialpropertyindex__scene(s, (tonumber(index) or 1) - 1, tostring(propertyName))
      return r == -1 and nil or r + 1
    end,

    ---Get texture filename of a certain texture slot of an element.
    ---@param index integer|nil @1-based index of an element to get a texture filename of. Default value: 1.
    ---@param slot string|integer|nil|"'txDiffuse'"|"'txNormal'"|"'txEmissive'"|"'txMaps'" @Texture slot name or a 1-based index of a texture slot. Default value: 1.
    ---@return string|nil @Texture filename or `nil` if there is no such slot or element.
    ---@overload fun(s: ac.SceneReference, slot: string): string
    getTextureSlotFilename = function (s, index, slot)
      if type(index) == 'string' then index, slot = 1, index end
      index = (tonumber(index) or 1) - 1
      slot = type(slot) == 'string' and ffi.C.lj_noderef_textureslotindex__scene(s, index, slot) or (tonumber(slot) or 1) - 1
      return __util.strrefp(ffi.C.lj_noderef_textureslotfilename__scene(s, index, slot))
    end,

    ---Dump shader replacements configs for materials in current selection. Resulting string might be pretty huge. Not all properties are dumped, but more properties might be added later. Some textures are stored as temporary IDs only valid within a session.
    ---@return string
    dumpShaderReplacements = function (s)
      return __util.strrefr(ffi.C.lj_noderef_dumpmaterials__scene(s))
    end,
    
    ---Get value of a certain material property of an element.
    ---@param index integer|nil @1-based index of an element to get a material property of. Default value: 1.
    ---@param property string|integer|nil|"'ksDiffuse'"|"'ksAmbient'"|"'ksEmissive'" @Material property name or a 1-based index of a material property. Default value: 1.
    ---@return number|vec2|vec3|vec4|nil @Material property value (type depends on material property type), or `nil` if there is no such element or material property.
    ---@overload fun(s: ac.SceneReference, property: string): number|vec2|vec3|vec4|nil
    getMaterialPropertyValue = function (s, index, property)
      if type(index) == 'string' then index, property = 1, index end
      index = (tonumber(index) or 1) - 1
      property = type(property) == 'string' and ffi.C.lj_noderef_materialpropertyindex__scene(s, index, property) or (tonumber(property) or 1) - 1
      local size = ffi.C.lj_noderef_materialpropertysize__scene(s, index, property)
      if size == 1 then return ffi.C.lj_noderef_materialpropertyvalue1__scene(s, index, property) end
      if size == 2 then return ffi.C.lj_noderef_materialpropertyvalue2__scene(s, index, property) end
      if size == 3 then return ffi.C.lj_noderef_materialpropertyvalue3__scene(s, index, property) end
      if size == 4 then return ffi.C.lj_noderef_materialpropertyvalue4__scene(s, index, property) end
      return 0
    end,
    
    ---Get number of materials in given scene reference (not recursive, only checks meshes and skinned meshes). If same material is used
    ---for two different meshes, it would only count once. Materials sharing same name can be different (for example, applying “[SHADER_REPLACEMENT_...]”
    ---via config to some meshes, not materials, forks their materials to not affect other meshes using the same material).
    ---@return integer @Number of materials.
    getMaterialsCount = function (s)
      return ffi.C.lj_noderef_materialscount__scene(s)
    end,
    
    ---Creates a copy of a scene reference (not copies of nodes or meshes).
    ---@return ac.SceneReference
    clone = function (s)
      if s == nil then return _emptyNodeRef() end
      return cr(ffi.C.lj_noderef_clone__scene(s))
    end,
    
    ---Get bounding sphere of an element. Works only with meshes or skinned meshes, nodes will return nil.
    ---@param index integer|nil @1-based index of an element to get a bounding sphere of. Default value: 1.
    ---@param outVec vec3|nil @Optional vector to use for bounding sphere position, to avoid creating new vector.
    ---@return vec3|nil @Center of bounding sphere in parent node coordinates, or nil if there is no bounding sphere (if it’s not a mesh or a skinned mesh).
    ---@return number|nil @Radius of bounding sphere, or nil if there is no bounding sphere (if it’s not a mesh or a skinned mesh).
    boundingSphere = function (s, index, outVec)
      outVec = outVec or vec3()
      local radius = ffi.C.lj_noderef_meshbs__scene(s, (tonumber(index) or 1) - 1, outVec)
      if radius == -1 then return nil, nil end
      return outVec, radius
    end,

    ---Applies skin to nodes or meshes (if ran with nodes, will apply skin to all of their children meshes).
    ---Skin is a table storing texture names and filenames to skin textures. Example:
    ---```
    ---local skinDir = ac.getFolder(ac.FolderID.ContentCars) .. '/' .. ac.getCarID(0) .. '/skins/my_skin'
    ---ac.findNodes('carRoot:0'):applySkin({
    ---  ['metal_details.dds'] = skinDir .. '/metal_details.dds'
    ---})
    ---```
    ---@param skin table<string, string>
    ---@return ac.SceneReference @Returns self for easy chaining.
    applySkin = function (s, skin) ffi.C.lj_noderef_applyskin__scene(s, __util.json(table.map(skin, function (value, key)
      return tostring(value), key
    end))) return s end,

    ---Resets textures to ones from associated KN5 file where possible.
    ---@return ac.SceneReference @Returns self for easy chaining.
    resetSkin = function (s) ffi.C.lj_noderef_resetskin__scene(s) return s end,

    ---Change parent of nodes in current reference.
    ---@param parentSceneRef ac.SceneReference|nil @Set to nil to disconnect node from a scene.
    ---@return ac.SceneReference @Returns self for easy chaining.
    setParent = function (s, parentSceneRef) ffi.C.lj_noderef_moveto__scene(s, parentSceneRef) return s end,

    ---Finds materials in another scene reference that have the same names as materials in a given scene reference,
    ---and copies them over, so after that both references would share materials. Example use case: if you have LOD A and
    ---LOD B and LOD A got unique materials (because there are multiple objects sharing same KN5 model), with this function
    ---it’s possible to sync together materials from LOD A and LOD B by running `lodB:setMaterialsFrom(lodA)`. And because
    ---materials would not be actually copied, but instead shared, any consequent change of material properly in LOD A would
    ---be mirrored in LOD B.
    ---@return ac.SceneReference @Returns self for easy chaining.
    setMaterialsFrom = function (s, materialSceneRef) ffi.C.lj_noderef_setmaterialfrom__scene(s, materialSceneRef) return s end,

    ---Creates a new scene reference with just a single item from the original scene reference.
    ---Indices are 1-based. By default it would create a new scene reference, if you need to access
    ---a lot of objects fast, provide your own:
    ---```
    ---  local meshes = ac.findMeshes('shader:ksTree')
    ---  local ref = ac.emptySceneReference()
    ---  for i = 1, #meshes do
    ---    meshes:at(i, ref)
    ---    print(ref:name())  -- note: for this particular case, it would be more optimal to use meshes:name(i) instead
    ---  end
    ---```
    ---@param index integer @1-based index.
    ---@param outSceneRef ac.SceneReference|nil
    ---@return ac.SceneReference @Reference to a child, might be empty if there is no such child.
    at = function (s, index, outSceneRef)
      if outSceneRef == nil or outSceneRef == true then outSceneRef = _emptyNodeRef() end
      ffi.C.lj_noderef_at__scene(s, outSceneRef, index - 1)
      return outSceneRef
    end,

    ---Returns number of nodes and meshes matching between this and another scene reference. Could be used to quickly find out if a certain element is in a set.
    ---@param other nil|ac.SceneReference|ac.SceneReference[] @Can be a single scene reference or a table with several of them. 
    ---@return integer
    countMatches = function (s, other)
      if s == nil then return 0 end
      other = _passRefArgs(other)
      return ffi.C.lj_noderef_getintersectioncount__scene(s, other)
    end,

    ---Creates a new scene reference containing unique elements from both sets.
    ---@param other nil|ac.SceneReference|ac.SceneReference[] @Can be a single scene reference or a table with several of them.
    ---@return ac.SceneReference
    makeUnionWith = function (s, other)
      if s == nil then return _emptyNodeRef() end
      other = _passRefArgs(other)
      return cr(ffi.C.lj_noderef_makeunion__scene(s, other))
    end,

    ---Creates a new scene reference containing only the elements found in both of original sets.
    ---@param other nil|ac.SceneReference|ac.SceneReference[] @Can be a single scene reference or a table with several of them. 
    ---@return ac.SceneReference
    makeIntersectionWith = function (s, other)
      if s == nil then return _emptyNodeRef() end
      other = _passRefArgs(other)
      return cr(ffi.C.lj_noderef_makeintersection__scene(s, other))
    end,

    ---Creates a new scene reference containing only the elements found in first set, but not in second set.
    ---@param other nil|ac.SceneReference|ac.SceneReference[] @Can be a single scene reference or a table with several of them. 
    ---@return ac.SceneReference
    makeSubtractionWith = function (s, other)
      if s == nil then return _emptyNodeRef() end
      other = _passRefArgs(other)
      return cr(ffi.C.lj_noderef_makesubtraction__scene(s, other))
    end,

    ---Create new fake shadow node. Uses the same shading as track fake shadows.
    ---@tableparam params { points: vec3[], opacity: number = 1, squaredness: vec2 } @Params for newly created node.
    ---@return ac.SceneReference @Reference to a newly created object.
    createFakeShadow = function(s, params)
      if params.points and #params.points ~= 4 then error('Four points are required', 2) end
      local r = cr(ffi.C.lj_noderef_createfakeshadownode__scene(s, params.name or 'FAKESHADOW'))
      if r == nil then return nil end
      if params.points ~= nil then r:setFakeShadowPoints(params.points, params.corners) end
      if params.opacity ~= nil then r:setFakeShadowOpacity(params.opacity) end
      if params.squaredness ~= nil then r:setFakeShadowSquaredness(params.squaredness) end
      return r
    end,

    ---Sets fake shadow points if current reference was created with `sceneReference:createFakeShadow()`.
    ---@param points vec3[] @Four corners.
    ---@param corners number[] @Four numbers for corner intensity.
    ---@return ac.SceneReference @Returns self for easy chaining.
    setFakeShadowPoints = function(s, points, corners)
      if #points ~= 4 then error('Four points are required', 2) end
      ffi.C.lj_noderef_setfakeshadowpoints__scene(s,
        __util.ensure_vec3(points[1]), __util.ensure_vec3(points[2]), __util.ensure_vec3(points[3]), __util.ensure_vec3(points[4]),
        __util.num_or(corners and corners[1], 1), __util.num_or(corners and corners[2], 1), __util.num_or(corners and corners[3], 1), __util.num_or(corners and corners[4], 1))
      return s
    end,

    ---Sets fake shadow squaredness if current reference was created with `sceneReference:createFakeShadow()`.
    ---@param squaredness vec2 @X is squaredness along one axis, Y is along another.
    ---@return ac.SceneReference @Returns self for easy chaining.
    setFakeShadowSquaredness = function(s, squaredness) 
      ffi.C.lj_noderef_setfakeshadowsquaredness__scene(s, __util.ensure_vec2(squaredness or vec2(1, 1)))
      return s
    end,

    ---Sets fake shadow opacity if current reference was created with `sceneReference:createFakeShadow()`.
    ---@param opacity number @Value from 0 to 1.
    ---@return ac.SceneReference @Returns self for easy chaining.
    setFakeShadowOpacity = function(s, opacity)
      ffi.C.lj_noderef_setfakeshadowopacity__scene(s, __util.num_or(opacity, 1))
      return s
    end,

    ---Applies shader replacements stored in INI config format. Can optionally load included files, so templates
    ---work as well. If there is no symbol “[” in `data`, applies passed values to all meshes and materials in selection.
    ---@param data string @Config in INIPP format.
    ---@param includeType ac.IncludeType? @Include type. If not set, includes will not be resolved, so templates won’t work. Default value: `ac.IncludeType.None`.
    ---@return ac.SceneReference @Returns self for easy chaining.
    applyShaderReplacements = function(s, data, includeType)
      ffi.C.lj_noderef_applyshaderreplacement__scene(s, tostring(data), tonumber(includeType) or 0)
      return s
    end,

    ---Projects texture onto a mesh or few meshes, draws result. Use in when updating a dynamic texture, display or an extra canvas.
    ---Position, and directions are set in world space.
    ---
    ---Note: this is not a regular IMGUI drawing call, so most functions, such as shading offsets, transformations or clipping, would 
    ---not work here.
    ---
    ---Tip 1: if you want to draw a new skin for a car and apply AO to it, one way might be to draw it in a canvas and then draw
    ---original AO texture on top with special shading parameters:
    ---```
    ----- drawing rest of skin here
    ---ui.setShadingOffset(0, 0, 0, -1)
    ---ui.drawImage('car::EXT_body.dds', 0, ui.windowSize(), rgbm.colors.black)  -- with these shading offset properties, texture
    ---    -- will be drawn in black with inverse of brightness used for opacity
    ---ui.resetShadingOffset()
    ---```
    ---
    ---Tip 2: if you want to project things on meshes with certain material, make sure to filter out meshes so that it would only
    ---affect meshes from LOD A (instead of `ac.findMeshes('material:car_paint')` use `ac.findMeshes('{ material:car_paint & lod:A}')`),
    ---otherwise there’d be quite a few artifacts. I spent some time like this trying to figure out why results were off.
    --[[@tableparam params {
      filename: string "Path to a texture, or a texture element (`ui.MediaElement`, `ui.ExtraCanvas`, `ac.GeometryShot`).",
      pos: vec3 "Position from which texture will be projected, in world space.",
      look: vec3 "Direction with which texture will be projected, in world space.",
      up: vec3 = vec3(0, 1, 0) "Optional vector directed up, to specify texture rotation.",
      color: rgbm = rgbm.colors.white "Optional color. Default value: `rgbm.colors.white`.",
      colorOffset: rgbm = nil "Optional color offset. Default value: `rgbm.colors.transparent`.",
      size: vec2 "Size, horizontal and vertical. Default value: `vec2(1, 1)`.",
      depth: number = 1e9 "Depth: how far from camera projection goes, with a smooth falloff. Default value: 1e9.",
      skew: vec2 = nil "Optional skew. Default value: `vec2(0, 0)`.",
      tiling: vec2 = nil "Optional tiling for horizontal and vertical axis. With 1 tiles normally, with -1 tiles with flipping, other values are currently reserved. Default value: `vec2(0, 0)` (no tiling).",
      doubleSided: boolean = false "Set to `true` to draw things on surfaces facing away as well. Default value: `false`.",
      uvOffset: vec2 = nil "Optional UV offset. By default CSP estimates an UV offset such that most triagles would be shown. If mapping is way off though, it might need tweaking (or even repeated calls with different offsets).",
      blendMode: render.BlendMode = nil "Optional override for blend mode. Default value: `render.BlendMode.BlendAccurate`.",
      mask1: string = nil "Optional masking texture.",
      mask1UV1: vec2 = nil "Optional masking texture UV coordinates.",
      mask1UV2: vec2 = nil "Optional masking texture UV coordinates.",
      mask1Flags: render.TextureMaskFlags = nil "Optional masking texture flags.",
      mask2: string = nil "Optional secondary masking texture.",
      mask2UV1: vec2 = nil "Optional secondary masking texture UV coordinates.",
      mask2UV2: vec2 = nil "Optional secondary masking texture UV coordinates.",
      mask2Flags: render.TextureMaskFlags = nil "Optional secondary masking texture flags."
    }]]
    ---@return ac.SceneReference @Returns self for easy chaining.
    projectTexture = function(s, params)
      if type(params) == 'table' then
        ffi.C.lj_noderef_projecttexture__scene(s,
          __util.str(params.filename), __util.ensure_vec3(params.pos), __util.ensure_vec3(params.look), __util.ensure_vec3_nil(params.up), 
          __util.ensure_rgbm_nil(params.color), __util.ensure_rgbm_nil(params.colorOffset), __util.ensure_vec2_nil(params.size), tonumber(params.depth) or 1e9, 
          __util.ensure_vec2_nil(params.skew), __util.ensure_vec2_nil(params.tiling), params.doubleSided == true, __util.ensure_vec2_nil(params.uvOffset), tonumber(params.blendMode) or 13,
          params.mask1 and tostring(params.mask1) or nil, __util.ensure_vec2_nil(params.mask1UV1), __util.ensure_vec2_nil(params.mask1UV2), tonumber(params.mask1Flags) or 6,
          params.mask2 and tostring(params.mask2) or nil, __util.ensure_vec2_nil(params.mask2UV1), __util.ensure_vec2_nil(params.mask2UV2), tonumber(params.mask2Flags) or 6)
      end
      return s
    end,

        
    ---Projects shader onto a mesh or few meshes, draws result. Use in when updating a dynamic texture, display or an extra canvas.
    ---Position, and directions are set in world space. Shader is compiled at first run, which might take a few milliseconds.
    ---If you’re drawing things continuously, use `async` parameter and shader will be compiled in a separate thread,
    ---while drawing will be skipped until shader is ready.
    ---
    ---You can bind up to 32 textures and pass any number/boolean/vector/color/matrix values to the shader, which makes
    ---it a very effective tool for any custom drawing you might need to make.      
    ---
    ---Example:
    ---```
    ---local ray = render.createMouseRay()
    ---meshes:projectShader({
    ---  async = true,
    ---  pos = ray.pos,
    ---  look = ray.dir,
    ---  blendMode = render.BlendMode.Opaque,
    ---  textures = {
    ---    txInput1 = 'texture.png',  -- any key would work, but it’s easier to have a common prefix like “tx”
    ---    txInput2 = mediaPlayer,
    ---    txMissing = false
    ---  },
    ---  values = {
    ---    gValueColor = rgbm(1, 2, 0, 0.5),  -- any key would work, but it’s easier to have a common prefix like “g”
    ---    gValueNumber = math.random(),
    ---    gValueVec = vec2(1, 2),
    ---    gFlag = math.random() > 0.5
    ---  },
    ---  shader = [[
    ---    float4 main(PS_IN pin) { 
    ---      if (dot(abs(pin.Tex * 2 - 1), 1) > 0.5) return 0;
    ---      float4 in1 = txInput1.Sample(samAnisotropic, pin.Tex);
    ---      float4 in2 = txInput2.Sample(samAnisotropic, pin.Tex + gValueVec);
    ---      return gFlag ? pin.NormalView * in1 + in2 * gValueColor : in2;
    ---    }
    ---  ]]
    ---})
    ---```
    ---
    ---Tip: to simplify and speed things up, it might make sense to move table outside of a function to reuse it from frame
    ---to frame, simply accessing and updating textures, values and other parameters before call. However, make sure not to
    ---add new textures and values, otherwise it would require to recompile shader and might lead to VRAM leaks (if you would
    ---end up having thousands of no more used shaders). If you don’t have a working texture at the time of first creating
    ---that table, use `false` for missing texture value.
    ---
    ---Note: if shader would fail to compile, a C++ exception will be triggered, terminating script completely (to prevent AC 
    ---from crashing, C++ exceptions halt Lua script that triggered them until script gets a full reload).
    ---@return boolean @Returns `false` if shader is not yet ready and no drawing occured (happens only if `async` is set to `true`).
    --[[@tableparam params {
      pos: vec3 "Position from which texture will be projected, in world space.",
      look: vec3 "Direction with which texture will be projected, in world space.",
      up: vec3 = vec3(0, 1, 0) "Optional vector directed up, to specify texture rotation.",
      size: vec2 "Size, horizontal and vertical. Default value: `vec2(1, 1)`.",
      withDepth: boolean = true "If depth is used, nearest to projection position triagles will have higher priority (in case of overlapping UV), slightly slower, but produces better results (especially with `expanded` set to `true`).",
      expanded: boolean = true "Draws each mesh four additional times with small offsets to fill partically covered pixels. More expensive (but less expensive comparing to fixing issue with those half covered pixels with additional draw calls via Lua).",
      uvOffset: vec2 = nil "Optional UV offset. By default CSP estimates an UV offset such that most triagles would be shown. If mapping is way off though, it might need tweaking (or even repeated calls with different offsets).",
      blendMode: render.BlendMode = render.BlendMode.BlendAccurate "Blend mode. Default value: `render.BlendMode.BlendAccurate`.",
      async: boolean = nil "If set to `true`, drawing won’t occur until shader would be compiled in a different thread.",
      cacheKey: number = nil "Optional cache key for compiled shader (caching will depend on shader source code, but not on included files, so make sure to change the key if included files have changed)",
      defines: table = nil "Defines to pass to the shader, either boolean, numerical or string values (don’t forget to wrap complex expressions in brackets). False values won’t appear in code and true will be replaced with 1 so you could use `#ifdef` and `#ifndef` with them.",
      textures: table = {} "Table with textures to pass to a shader. For textures, anything passable in `ui.image()` can be used (filename, remote URL, media element, extra canvas, etc.). If you don’t have a texture and need to reset bound one, use `false` for a texture value (instead of `nil`)",
      values: table = {} "Table with values to pass to a shader. Values can be numbers, booleans, vectors, colors or 4×4 matrix. Values will be aligned automatically.",
      directValuesExchange: boolean = nil "If you’re reusing table between calls instead of recreating it each time and pass `true` as this parameter, `values` table will be swapped with an FFI structure allowing to skip data copying step and achieve the best performance. Note: with this mode, you’ll have to transpose matrices manually.",
      shader: string = 'float4 main(PS_IN pin) { return float4(pin.Tex.x, pin.Tex.y, 0, 1); }' "Shader code (format is HLSL, regular DirectX shader); actual code will be added into a template in “assettocorsa/extension/internal/shader-tpl/project.fx” (look into it to see what fields are available)."
    }]]
    projectShader = function(s, params)
      local dc = __util.setShaderParams2(params, _sp_scenep)
      if not dc then return false end
      ffi.C.lj_noderefcshader_enqueue__scene(dc, s, __util.ensure_vec3(params.pos), __util.ensure_vec3(params.look), __util.ensure_vec3_nil(params.up), 
        __util.ensure_vec2_nil(params.size), params.withDepth ~= false, params.expanded ~= false, __util.ensure_vec2_nil(params.uvOffset))
      return true
    end
  }
})

---@return ac.SceneReference
function ac.emptySceneReference() return _emptyNodeRef() end

---Creates a new scene reference containing objects (nodes, meshes, etc.) collected with a filter from root node associated with current script. For most scripts it would be an AC root node. For track scripts,
---track root node. For car scripts, car’s root.
---
---Node: for most cases, using `ac.findNodes()`, `ac.findMeshes()` and similar would work better.
---@param s string @Node/mesh filter.
---@return ac.SceneReference
function ac.findAny(s) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 0)) end

---Creates a new scene reference containing nodes collected with a filter from root node associated with current script. For most scripts it would be an AC root node. For track scripts,
---track root node. For car scripts, car’s root.
---
---Just a reminder, nodes refer to parent objects. Themselves, don’t get rendered, only their children elements (which might be nodes or meshes), but they can move.
---
---Filter is regular stuff, the same as used in INI configs. To use complex filter with commas and operators, wrap it in curly brackets as usual. There are also some special keywords available:
---- `'luaRoot:yes'`: root node associated with current script.
---- `'sceneRoot:yes'`: the most root node.
---- `'carsRoot:yes'`: node that hosts all the cars. If you want to load custom dynamic objects, especially complex, it’s recommended to load them in bounding sphere and attach here (this node is optimized to render bounding sphere-wrapped objects quickly).
---- `'trackRoot:yes'`: track root node.
---- `'staticRoot:yes'`: node with static geometry (affected by motion blur from original AC).
---- `'dynamicRoot:yes'`: node with dynamic geometry (node affected by motion blur from original AC).
---
---Note: if you’re adding new objects to a car, seach for `'BODYTR'` node. Car root remains stationary and hosts “BODYTR” for main car model and things like wheels and suspension nodes.
---@param s string @Node filter.
---@return ac.SceneReference
function ac.findNodes(s) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 0x10000)) end

---Creates a new scene reference containing meshes collected with a filter from root node associated with current script. For most scripts it would be an AC root node. For track scripts,
---track root node. For car scripts, car’s root.
---
---Just as a reminder, meshes can’t move. If you want to move a mesh, find its parent node and move it. If parent node has more than a single mesh, you can create a new parent node and move
---mesh found with `ac.findMeshes()` there.
---
---Filter is regular stuff, the same as used in INI configs. To use complex filter with commas and operators, wrap it in curly brackets as usual.
---@param s string @Mesh filter.
---@return ac.SceneReference
function ac.findMeshes(s) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 0x20000)) end

---Creates a new scene reference containing skinned meshes collected with a filter from root node associated with current script. For most scripts it would be an AC root node. For track scripts,
---track root node. For car scripts, car’s root.
---
---Filter is regular stuff, the same as used in INI configs. To use complex filter with commas and operators, wrap it in curly brackets as usual.
---@param s string @Mesh filter.
---@return ac.SceneReference
function ac.findSkinnedMeshes(s) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 0x40000)) end

---Creates a new scene reference containing objects of a certain class collected with a filter from root node associated with current script. For most scripts it would be an AC root node. For track scripts,
---track root node. For car scripts, car’s root.
---
---Filter is regular stuff, the same as used in INI configs. To use complex filter with commas and operators, wrap it in curly brackets as usual.
---@param objectClass ac.ObjectClass @Objects class.
---@param s string @Mesh filter.
---@return ac.SceneReference
function ac.findByClass(objectClass, s) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), tonumber(objectClass) or 0)) end



ffi.cdef [[ 
typedef struct {
  int _id;
  int _id_depth;
} carshot;
]]

---@param sceneReference ac.SceneReference|{reference: ac.SceneReference?, opaque: fun()?, transparent: fun()?} @Reference to nodes or meshes to draw, or a table with reference and callbacks for custom drawing.
---@param resolution vec2 @Resolution in pixels. Usually textures with sizes of power of two work the best.
---@param mips integer? @Number of MIPs for a texture. MIPs are downsized versions of main texture used to avoid aliasing. Default value: 1 (no MIPs).
---@param withDepth boolean? @If set to `true`, depth buffer will be available to show as well.
---@param antialiasingMode render.AntialiasingMode? @Antialiasing mode. Default value: `render.AntialiasingMode.None` (disabled).
---@param textureFormat render.TextureFormat? @Texture format. Default value: `render.TextureFormat.R8G8B8A8.UNorm`. Note: antialiasing expects the default format.
---@param flags render.TextureFlags? @Extra flags. Default value: `0`.
---@return ac.GeometryShot
---@overload fun(sceneReference: ac.SceneReference, resolution: vec2|integer, mips: integer, withDepth: boolean, textureFormat: render.TextureFormat)
function ac.GeometryShot(sceneReference, resolution, mips, withDepth, antialiasingMode, textureFormat, flags)
  local callbackOpaque, callbackTransparent = 0, 0
  if type(sceneReference) == 'table' then
    callbackOpaque = type(sceneReference.opaque) == 'function' and __util.setCallback(sceneReference.opaque) or 0
    callbackTransparent = type(sceneReference.transparent) == 'function' and __util.setCallback(sceneReference.transparent) or 0
    sceneReference = sceneReference.reference or ac.emptySceneReference()
  end
  if not ffi.istype('noderef*', sceneReference) then error('Scene reference is required', 2) end
  if type(resolution) == 'number' then resolution = vec2(resolution, resolution) end
  if not vec2.isvec2(resolution) then error('Resolution is required', 2) end
  resolution.x = math.clamp(resolution.x, 1, 8192)
  resolution.y = math.clamp(resolution.y, 1, 8192)

  if antialiasingMode and antialiasingMode > 0 and antialiasingMode < 100 then
    antialiasingMode, textureFormat = textureFormat, antialiasingMode
  end

  local c = __util.native('carshot_new',
    sceneReference, resolution.x, resolution.y, tonumber(mips) or 1, withDepth == true,
    tonumber(antialiasingMode) or 0, tonumber(textureFormat) or 28, tonumber(flags) or 0, 
    callbackOpaque, callbackTransparent)
  return ffi.gc(c, ffi.C.lj_carshot_gc__scene)
end

---This thing allows to draw 3D objects in UI functions (or use them as textures in `ac.SceneReference:setMaterialTexture()`, 
---for example). Prepare a scene reference (might be a bunch of nodes or meshes), create a new `ac.GeometryShot` with that reference,
---call `ac.GeometryShot:update()` with camera parameters and then use resulting shot instead of a texture name.
---
---Each `ac.GeometryShot` holds a GPU texture in R8G8B8A8 format with optional MIPs and additional depth texture in D32 format, so
---don’t create too many of those and use `ac.GeometryShot:dispose()` for shots you no longer need (or just lose them to get garbage
---collected, but it might take more time.
---
---
---@class ac.GeometryShot
---@explicit-constructor ac.GeometryShot
ffi.metatype('carshot', { 
  __tostring = function (s) return string.format('$ac.GeometryShot://?id=%d', s._id) end,
  __index = {
    ---Disposes geometry shot and releases resources.
    dispose = function (s)
      return ffi.C.lj_carshot_dispose__scene(s)
    end,

    ---Sets geometry shot name for debugging. Shots with set name appear in Lua Debug App, allowing to monitor their state.
    ---@param name string? @Name to display texture as. If set to `nil` or `false`, name will be reset and texture will be hidden.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setName = function (s, name)
      ffi.C.lj_carshot_setname__scene(s, name and tostring(name) or nil)
      return s
    end,

    ---Updates texture making a shot of referenced geometry with given camera parameters. Camera coordinates are set in world space.
    ---
    ---To make orthogonal shot, pass 0 as `fov`.
    ---@param pos vec3 @Camera position.
    ---@param look vec3 @Camera direction.
    ---@param up vec3? @Camera vector facing upwards relative to camera. Default value: `vec3(0, 1, 0)`.
    ---@param fov number? @FOV in degrees. Default value: 90.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    update = function (s, pos, look, up, fov)
      ffi.C.lj_carshot_update_prep__scene(s, __util.ensure_vec3(pos), __util.ensure_vec3(look), __util.ensure_vec3_nil(up), tonumber(fov) or 90)
      __util.native('carshot_update')
      return s
    end,

    ---Updates texture making a shot from a position of a track camera. Pass the index of a car to focus on.
    ---@param carIndex integer? @0-based car index. Default value: `0`.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    updateWithTrackCamera = function (s, carIndex)
      ffi.C.lj_carshot_update_prep_tc__scene(s, tonumber(carIndex) or 0)
      __util.native('carshot_update')
      return s
    end,

    ---Returns a texture reference to a depth buffer (only if created with `withDepth` set to `true`), which you can use to draw
    ---depth buffer with something like `ui.image(shot:depth(), vec2(320, 160))`.
    ---
    ---Note: buffer is treated like a single-channel texture so it would show in red, but with `ui.setShadingOffset()` you can draw
    ---it differently.
    ---@return string
    depth = function (s)
      return string.format('$ac.GeometryShot://?id=%d', s._id_depth)
    end,

    ---Clears texture.
    ---@param col rgbm
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    clear = function(s, col)
      ffi.C.lj_carshot_clear__scene(s, __util.ensure_rgbm(col))
      return s
    end,

    ---Generates MIPs. Once called, switches texture to manual MIPs generating mode. Note: this operation is not that expensive, but it’s not free.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    mipsUpdate = function(s)
      ffi.C.lj_carshot_mips__scene(s)
      return s
    end,

    ---Enables or disables transparent pass (secondary drawing pass with transparent surfaces). Disabled by default.
    ---@param value boolean? @Set to `true` to enable transparent pass. Default value: `true`.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setTransparentPass = function(s, value)
      ffi.C.lj_carshot_settransparentpass__scene(s, value ~= false)
      return s
    end,

    ---Enables original lighting (stops from switching to neutral lighting active by default). With original lighting,
    ---methods like `shot:setAmbientColor()` and `shot:setReflectionColor()` would no longer have an effect.
    ---@param value boolean? @Set to `true` to enable original lighting. Default value: `true`.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setOriginalLighting = function(s, value)
      ffi.C.lj_carshot_setoriginallighting__scene(s, value ~= false)
      return s
    end,

    ---Enables sky in the shot. By default, sky is not drawn.
    ---@param value boolean? @Set to `true` to enable sky. Default value: `true`.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setSky = function(s, value)
      ffi.C.lj_carshot_setincludesky__scene(s, value ~= false)
      return s
    end,

    ---Enables particles in the shot. By default, particles are not drawn.
    ---
    ---Note: this is not working well currently with post-processing active, drawing HDR colors into LDR texture. 
    ---Better support for such things is coming a bit later.
    ---@param value boolean? @Set to `true` to enable particles. Default value: `true`.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setParticles = function(s, value)
      ffi.C.lj_carshot_setincludeparticles__scene(s, value ~= false)
      return s
    end,

    ---Changes used shaders set. Switch to a set like `render.ShadersType.SampleColor` to access color of surface without any extra effects.
    ---@param type render.ShadersType? @Type of shaders set to use. Default value: `render.ShadersType.Simplified`.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setShadersType = function(s, type)
      ffi.C.lj_carshot_setshaderset__scene(s, tonumber(type) or 13)
      return s
    end,

    ---Replaces shadow set with an alternative one. Pretty expensive, use carefully.
    ---@param type 'area' @Type of shadow set to use.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setAlternativeShadowsSet = function(s, type)
      ffi.C.lj_carshot_setshadowsset__scene(s, tostring(type))
      return s
    end,

    ---Changes maximum layer of which meshes to render. 0 is for lowest world detail, 5 for highest.
    ---@param value integer @Layer value (aka world detail level).
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setMaxLayer = function(s, value)
      ffi.C.lj_carshot_setmaxlayer__scene(s, tonumber(value) or 0)
      return s
    end,

    ---Sets clipping planes. If clipping planes are too far apart, Z-fighting might occur. Note: to avoid Z-fighting, increasing
    ---nearby clipping plane distance helps much more.
    ---@param near number? @Nearby clipping plane in meters. Default value: 0.05.
    ---@param far number? @Far clipping plane in meters. Default value: 1000.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setClippingPlanes = function(s, near, far)
      ffi.C.lj_carshot_setclippingplanes__scene(s, tonumber(near) or 0.05, tonumber(far) or 1000)
      return s
    end,

    ---Sets orthogonal parameters.
    ---@param size vec2
    ---@param depth number
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setOrthogonalParams = function(s, size, depth)
      ffi.C.lj_carshot_setorthogonal__scene(s, __util.ensure_vec2(size), tonumber(depth) or 100)
      return s
    end,

    ---Sets clear color to clear texture with before each update. Transparent by default.
    ---@param value rgbm @Clear color from 0 to 1. Initial value: `rgbm.colors.transparent`.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setClearColor = function(s, value)
      ffi.C.lj_carshot_setclearcolor__scene(s, __util.ensure_rgbm(value))
      return s
    end,

    ---Sets ambient color used for general lighting.
    ---@param value rgbm @Ambient color. Initial value: `rgbm(3, 3, 3, 1)`.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setAmbientColor = function(s, value)
      ffi.C.lj_carshot_setambientcolor__scene(s, __util.ensure_rgbm(value))
      return s
    end,

    ---Sets color for reflection gradient.
    ---@param zenith rgbm @Zenith reflection color. Initial value: `rgbm(1, 1, 1, 1)`.
    ---@param horizon rgbm @Horizon reflection color. Initial value: `rgbm(0, 0, 0, 1)`.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setReflectionColor = function(s, zenith, horizon)
      ffi.C.lj_carshot_setreflectioncolor__scene(s, __util.ensure_rgbm(zenith), __util.ensure_rgbm(horizon))
      return s
    end,

    ---Configures geometry shot for the best possible quality for a scene shot, such as including all the geometry (maximum
    ---world detail), enabling particles, transparent pass, main shaders, etc. If you need something like making a nice shot
    ---of a scene from a certain point of view, this might be a good shortcut: if more visually improving features will be 
    ---added in the future, they’ll be included here as well.
    ---
    ---Please avoid using it for something like rear view camera or a track display though, they could definitely benefit from
    ---using simpler shaders or lower level of detail.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setBestSceneShotQuality = function(s)
      s:setShadersType(render.ShadersType.Main)
      s:setParticles(true)
      s:setTransparentPass(true)
      s:setSky(true)
      s:setMaxLayer(5)
      s:setOriginalLighting(true)
      return s
    end,

    ---Overrides exposure used if antialiasing mode is set to YEBIS value. By default scene exposure is used.
    ---@param value number? @Exposure used by YEBIS post-processing. Pass `nil` to reset to default behavior.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    setExposure = function(s, value)
      ffi.C.lj_carshot_setexposure__scene(s, tonumber(value) or math.huge)
      return s
    end,

    ---Returns texture resolution (or zeroes if element has been disposed).
    ---@return vec2
    size = function(s)
      return ffi.C.lj_carshot_size__scene(s)
    end,

    ---Returns number of MIP maps (1 for no MIP maps and it being a regular texture).
    ---@return integer
    mips = function(s)
      return ffi.C.lj_carshot_mipscount__scene(s)
    end,

    ---Returns shared handle to the texture. Shared handle can be used in other scripts with `ui.SharedTexture()`, or, if `crossProcess` flag
    ---is set to `true`, also accessed by other processes.
    ---@param crossProcess boolean? @Set to `true` to be able to pass a handle to other processes. Requires `render.TextureFlags.Shared` flag to be set during creation. Default value: `false`.
    ---@return integer
    sharedHandle = function(s, crossProcess)
      return ffi.C.lj_carshot_sharedhandle__scene(s, crossProcess == true)
    end,

    ---Manually applies antialiasing to the texture (works only if it was created with a specific antialiasing mode).
    ---By default antialiasing is applied automatically, but calling this function switches AA to a manual mode.
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    applyAntialiasing = function(s)
      ffi.C.lj_carshot_applyaa__scene(s)
      return s
    end,

    ---Saves shot as an image.
    ---@param filename string @Destination filename.
    ---@param format ac.ImageFormat? @Texture format (by default guessed based on texture name).
    ---@return ac.GeometryShot @Returns itself for chaining several methods together.
    save = function(s, filename, format)
      if not filename or type(filename) ~= 'string' or #filename == '' then return end
      if format == nil then
        local ext = string.sub(filename, #filename - 3, #filename):lower()
        if ext == '.png' then format = ac.ImageFormat.PNG 
        elseif ext == '.dds' then format = ac.ImageFormat.DDS
        elseif ext == '.zip' then format = ac.ImageFormat.ZippedDDS
        elseif ext == '.bmp' then format = ac.ImageFormat.BMP
        else format = ac.ImageFormat.JPG end
      end
      ffi.C.lj_carshot_save__scene(s, filename, format)
      return s
    end,

    ---Returns image encoded in DDS format. Might be useful if you would need to store an image
    ---in some custom form (if so, consider compressing it with `ac.compress()`).
    ---
    ---Note: you can later use `ui.decodeImage()` to get a string which you can then pass as a texture name
    ---to any of texture receiving functions. This way, you can load image into a new canvas later: just
    ---create a new canvas (possibly using `ui.imageSize()` first to get image size) and update it drawing
    ---imported image to the full size of the canvas.
    ---@return string|nil @Binary data, or `nil` if binary data export has failed.
    encode = function(s)
      return __util.strrefp(ffi.C.lj_carshot_tobytes__scene(s))
    end,

    ---Downloads data from GPU to CPU asyncronously (usually takes about 0.15 ms to get the data). Resulting data can be
    ---used to access colors of individual pixels or upload it back to CPU restoring original state.
    ---@param callback fun(err: string, data: ui.ExtraCanvasData)
    accessData = function (s, callback)
      if not callback then return end
      if type(callback) ~= 'function' then error('Function is required for callback', 2) end
      ffi.C.lj_carshot_tocpu__scene(s, __util.expectReply(function (err, key)
        if err then callback(err)
        else
          local r = ffi.C.lj_uirtcpu_get__ui(key)
          if r == nil then callback('Unexpectedly missing data') 
          else callback(nil, ffi.gc(r, ffi.C.lj_uirtcpu_gc__ui)) end
        end
      end))
    end
  }
})
