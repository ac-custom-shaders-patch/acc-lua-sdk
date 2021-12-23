__source 'lua/api_scene.cpp'
__allow 'scene'

require './ac_ray'
require './ac_display'

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

local _texBgSkip = rgbm(0,0,0,-1)
local _texBgOriginal = rgbm(-1,0,0,0)
local _vecUp = vec3(0, 1, 0)

---Reference to one or several objects in scene. Works similar to those jQuery things which would refer to one or
---several of webpage elements. Use methods like `ac.findNodes()` to get one. Once you have a reference to some nodes,
---you can load additional KN5s, create new nodes and such in it.
---Note: it might be beneficial in general to prefer methods like `ac.findNodes()` and `ac.findMeshes()` over `ac.findAny()`.
---Should be fewer surprises this way.
---@class ac.SceneReference
ffi.cdef [[ typedef struct { int __size; } noderef; ]]
ffi.metatype('noderef', {
  __len = function(s) return s:size() end,
  __index = {

    ---Dispose any resources associated with this ac.SceneReference and empty it out. Use it if you need to remove a previously
    ---created node or a loaded KN5.
    dispose = function (s) return ffi.C.lj_noderef_dispose__scene(s) end,

    ---Set material property. Be careful to match the type (you need the same amount of numeric values). If you’re using boolean,-
    ---resulting value will be either 1 or 0.
    ---@param property string | "'ksEmissive'"
    ---@param value number|vec2|vec3|rgb|vec4|rgbm|boolean
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
    setMaterialTexture = function (s, texture, value)
      if type(value) == 'string' then
        ffi.C.lj_noderef_setmaterialtexture_file__scene(s, texture, value)
      elseif type(value) == 'table' then
        if not value.callback then error('Callback is missing', 2) end
        local dt = ffi.C.lj_noderef_setmaterialtexture_begin__scene(s, texture,
          __util.ensure_vec2(value.textureSize),
          value.background ~= nil and (value.background == false and _texBgSkip or __util.ensure_rgbm(value.background)) or _texBgOriginal,
          __util.ensure_vec2(value.region and value.region.from), __util.ensure_vec2(value.region and value.region.size))
        if dt >= 0 then
          using(function () value.callback(dt) end, ffi.C.lj_noderef_setmaterialtexture_end__scene)
        end
      else
        ffi.C.lj_noderef_setmaterialtexture_color__scene(s, texture, __util.ensure_rgbm(value))
      end
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
    findNodes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 1)) end,

    ---Find any child meshes that match filter and return a new reference to them.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found meshes.
    findMeshes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 2)) end,

    ---Find any child skinned meshes that match filter and return a new reference to them.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found skinned meshes.
    findSkinnedMeshes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 4)) end,

    ---Filters current reference and returns new one with objects that match filter only.
    ---@param filter string @Node/mesh filter.
    ---@return ac.SceneReference @Reference to found scene elements.
    filterAny = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_filter__scene(s, nf(filter), 0)) end,

    ---Filters current reference and returns new one with nodes that match filter only.
    ---@param filter string @Node filter.
    ---@return ac.SceneReference @Reference to found nodes.
    filterNodes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_filter__scene(s, nf(filter), 1)) end,

    ---Filters current reference and returns new one with meshes that match filter only.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found meshes.
    filterMeshes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_filter__scene(s, nf(filter), 2)) end,

    ---Filters current reference and returns new one with skinned meshes that match filter only.
    ---@param filter string @Mesh filter.
    ---@return ac.SceneReference @Reference to found skinned meshes.
    filterSkinnedMeshes = function (s, filter) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_filter__scene(s, nf(filter), 4)) end,

    ---Create a new node with a given name and attach it as a child.
    ---@param name string
    ---@param keepAlive boolean @Set to `true` to create a long-lasting node which wouldn’t be removed when script is reloaded.
    ---@return ac.SceneReference @Newly created node or nil if failed
    createNode = function (s, name, keepAlive) return cr(ffi.C.lj_noderef_createnode__scene(s, name, keepAlive ~= true)) end,

    ---Create a new bounding sphere node with a given name and attach it as a child. Using those might help with performance: children
    ---would skip bounding frustum test, and whole node would not get traversed during rendering if it’s not in frustum.
    ---
    ---Note: for it to work properly, it’s better to attach it to AC cars node, as that one does expect those bounding sphere nodes
    ---to be inside of it. You can find it with `ac.findNodes('carsRoot:yes')`.
    ---@param name string
    ---@return ac.SceneReference @Can return nil if failed
    createBoundingSphereNode = function (s, name, radius) return cr(ffi.C.lj_noderef_createbsnode__scene(s, name, radius)) end,

    ---Load KN5 model and attach it as a child.
    ---
    ---Node: The way it actually works, KN5 would be loaded in a pool and then copied here (with sharing
    ---of resources such as vertex buffers). This generally helps with performance.
    ---@param filename string @KN5 filename relative to script folder or AC root folder.
    ---@return ac.SceneReference @Can return nil if failed
    loadKN5 = function (s, filename) return cr(ffi.C.lj_noderef_loadkn5__scene(s, filename)) end,

    ---Load KN5 LOD model and attach it as a child. Parameter `mainFilename` should refer to the parent KN5.
    ---
    ---Node: The way it actually works, KN5 would be loaded in a pool and then copied here (with sharing
    ---of resources such as vertex buffers). This generally helps with performance. Parent KN5 would be
    ---loaded as well, but not shown, and instead kept in a pool.
    ---@param filename string @KN5 filename relative to script folder or AC root folder.
    ---@return ac.SceneReference @Can return nil if failed
    loadKN5LOD = function (s, filename, mainFilename) return cr(ffi.C.lj_noderef_loadkn5lod__scene(s, filename, mainFilename)) end,

    ---@param visible boolean
    ---@return ac.SceneReference @Returns self for easy chaining.
    setVisible = function (s, visible) ffi.C.lj_noderef_setvisible__scene(s, visible == true) return s end,

    ---@param shadows boolean
    ---@return ac.SceneReference @Returns self for easy chaining.
    setShadows = function (s, shadows) ffi.C.lj_noderef_setshadows__scene(s, shadows == true) return s end,

    ---@param transparent boolean
    ---@return ac.SceneReference @Returns self for easy chaining.
    setTransparent = function (s, transparent) ffi.C.lj_noderef_settransparent__scene(s, transparent == true) return s end,

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
    ---are no nodes in the list, it would return nil.
    ---@return mat4x4 @Reference to transformation matrix of the first node, or nil. Use `mat4x4:set()` to update its value, or access its rows directly.
    getTransformationRaw = function (s)
      local m = ffi.C.lj_noderef_getrawmat4x4ptr__scene(s)
      return m and m[0] or nil
    end,

    ---Returns a new scene reference with a child in certain index (assuming current scene reference points to node). If current reference
    ---contains several nodes, children from all of them at given index will be collected.
    ---@param index integer @1-based index of a child. Default value: 1.
    ---@return ac.SceneReference
    getChild = function (s, index) return ffi.C.lj_noderef_child__scene(s, index and index - 1 or 0) end,

    ---Returns a new scene reference with a parent of an object in current scene reference. If current reference
    ---contains several objects, parents of all of them will be collected.
    ---@return ac.SceneReference
    getParent = function (s) return ffi.C.lj_noderef_parent__scene(s) end,

    ---Adds nodes and meshes from another scene reference to current scene reference.
    ---@param sceneRef ac.SceneReference @1-based index of a child. Default value: 1.
    ---@return ac.SceneReference @Returns self for easy chaining.
    append = function (s, sceneRef) ffi.C.lj_noderef_append__scene(s, sceneRef) return s end,

    ---Casts a ray prepared by something like `render.createRay(pos, dir, length)` or `render.createMouseRay()`.
    ---
    ---If you need to access a mesh that was hit, set second argument to true:
    ---```
    ---local hitDistance, hitMesh = mesh:raycast(ac.createRay(pos, dir), true)
    ---if hitDistance ~= -1 then
    ---  print(hitMesh:name())
    ---end
    ---```
    ---Alternatively, reuse your own scene reference for better performance if you need to cast
    ---a lot of rays:
    ---```
    ---local hitMesh = ac.emptySceneReference()
    ---local hitDistance = mesh:raycast(ac.createRay(pos, dir), hitMesh)
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
      if outSceneRef == true then outSceneRef = _emptyNodeRef() end
      local distance = ffi.C.lj_noderef_raycast__scene(s, outSceneRef, ray, outPosRef, outNormalRef, outUVRef)
      return distance, outSceneRef
    end,

    ---Get name of an element.
    ---@param index integer|nil @1-based index of an element to get a name of. Default value: 1.
    ---@return string @Node or mesh name.
    name = function (s, index)
      return __util.strref(ffi.C.lj_noderef_name__scene(s, index and index - 1 or 0))
    end,
    
    ---Get material name of an element.
    ---@param index integer|nil @1-based index of an element to get a material name of. Default value: 1.
    ---@return string @Material name.
    materialName = function (s, index)
      return __util.strref(ffi.C.lj_noderef_materialname__scene(s, index and index - 1 or 0))
    end,
    
    ---Get shader name of an element.
    ---@param index integer|nil @1-based index of an element to get a shader name of. Default value: 1.
    ---@return string @Shader name.
    shaderName = function (s, index)
      return __util.strref(ffi.C.lj_noderef_shadername__scene(s, index and index - 1 or 0))
    end,
    
    ---Get bounding sphere of an element. Works only with meshes or skinned meshes, nodes will return nil.
    ---@param index integer|nil @1-based index of an element to get a bounding sphere of. Default value: 1.
    ---@param outVec vec3|nil @Optional vector to use for bounding sphere position, to avoid creating new vector.
    ---@return vec3|nil @Center of bounding sphere in parent node coordinates, or nil if there is no bounding sphere (if it’s not a mesh or a skinned mesh).
    ---@return number|nil @Radius of bounding sphere, or nil if there is no bounding sphere (if it’s not a mesh or a skinned mesh).
    boundingSphere = function (s, index, outVec)
      outVec = outVec or vec3()
      local radius = ffi.C.lj_noderef_meshbs__scene(s, index and index - 1 or 0, outVec)
      if radius == -1 then return nil, nil end
      return outVec, radius
    end,

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
      return __util.lj_noderef_at__scene(s, outSceneRef, index - 1)
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
---- `'carsRoot:yes'`: node that hosts all the cars. If you want to load custom dynamic objects, especially complex, it’s recommended to load them in bounding sphere and attach here (this node is optimized to render bounding sphere-wrapped objects quickly).
---- `'trackRoot:yes'`: track root node.
---- `'staticRoot:yes'`: node with static geometry (affected by motion blur from original AC).
---- `'dynamicRoot:yes'`: node with dynamic geometry (node affected by motion blur from original AC).
---
---Note: if you’re adding new objects to a car, seach for `'BODYTR'` node. Car root remains stationary and hosts “BODYTR” for main car model and things like wheels and suspension nodes.
---@param s string @Node filter.
---@return ac.SceneReference
function ac.findNodes(s) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 1)) end

---Creates a new scene reference containing meshes collected with a filter from root node associated with current script. For most scripts it would be an AC root node. For track scripts,
---track root node. For car scripts, car’s root.
---
---Just as a reminder, meshes can’t move. If you want to move a mesh, find its parent node and move it. If parent node has more than a single mesh, you can create a new parent node and move
---mesh found with `ac.findMeshes()` there.
---
---Filter is regular stuff, the same as used in INI configs. To use complex filter with commas and operators, wrap it in curly brackets as usual.
---@param s string @Mesh filter.
---@return ac.SceneReference
function ac.findMeshes(s) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 2)) end

---Creates a new scene reference containing skinned meshes collected with a filter from root node associated with current script. For most scripts it would be an AC root node. For track scripts,
---track root node. For car scripts, car’s root.
---
---Filter is regular stuff, the same as used in INI configs. To use complex filter with commas and operators, wrap it in curly brackets as usual.
---@param s string @Mesh filter.
---@return ac.SceneReference
function ac.findSkinnedMeshes(s) return s == nil and _emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 4)) end
