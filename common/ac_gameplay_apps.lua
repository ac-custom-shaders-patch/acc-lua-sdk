__source 'lua/api_gameplay_apps.cpp'
__allow 'gp'

ffi.cdef [[ 
typedef struct {
  void* __something;
} appwindowaccessor;
]]

local _awlv, _awrn

---Collect information about available windows.
---@return {name: string, title: string, position: vec2, size: vec2, visible: boolean, pinned: boolean, collapsed: boolean, layer: integer, layerDuplicate: boolean}[]
function ac.getAppWindows()
  if not _awrn then _awrn = refnumber() end
  ffi.C.lj_getAppWindows_inner__gp(_awrn)
  _awlv = __util.result() or _awlv
  return _awlv or {}
end

---Looks for a certain window of either an original AC app, a Python or a Lua app. Use `ac.getAppWindows()` to get a list of available apps.
---If found, this wrapper can be used to move or hide an app, or switch it to a different render layer.
---@param windowName string
---@return ac.AppWindowAccessor?
function ac.accessAppWindow(windowName)
  local a = ffi.C.lj_appwindowaccessor_new__gp(tostring(windowName))
  if a == nil then return nil end
  return ffi.gc(a, ffi.C.lj_appwindowaccessor_gc__gp)
end

---Wrapper for interacting with any AC app. Might not work as intended with some apps not expecting such intrusion though.
---@class ac.AppWindowAccessor
ffi.metatype('appwindowaccessor', {
  __index = {
    ---Window reference is valid (some references might become invalid if the window is deleted).
    ---@return boolean
    valid = ffi.C.lj_appwindowaccessor_valid__gp,

    ---Checks if window is visible.
    ---@return boolean
    visible = ffi.C.lj_appwindowaccessor_getvisible__gp,

    ---Changes visible state of the window.
    ---@param value boolean? @Default value: `true`.
    ---@return ac.AppWindowAccessor
    setVisible = function(s, value) ffi.C.lj_appwindowaccessor_setvisible__gp(s, value ~= false) return s end,

    ---Checks if window is pinned.
    ---@return boolean
    pinned = ffi.C.lj_appwindowaccessor_getpinned__gp,

    ---Changes pinned state of the window. Works with IMGUI apps with CSP v0.2.3-preview62 or newer.
    ---@param value boolean? @Default value: `true`.
    ---@return ac.AppWindowAccessor
    setPinned = function(s, value) ffi.C.lj_appwindowaccessor_setpinned__gp(s, value ~= false) return s end,

    ---Returns window position.
    ---@return vec2
    position = ffi.C.lj_appwindowaccessor_pos__gp,

    ---Returns window size (Python apps might draw things to extends exceeding this size).
    ---@return vec2
    size = ffi.C.lj_appwindowaccessor_size__gp,

    ---Moves window to a different position. Works with IMGUI apps with CSP v0.2.3-preview62 or newer.
    ---@param value vec2
    ---@return ac.AppWindowAccessor
    move = function(s, value) ffi.C.lj_appwindowaccessor_move__gp(s, __util.ensure_vec2(value)) return s end,

    ---Resizes a window. Works with IMGUI apps only.
    ---@param value vec2
    ---@return ac.AppWindowAccessor
    resize = function(s, value) ffi.C.lj_appwindowaccessor_resize__gp(s, __util.ensure_vec2(value)) return s end,

    ---Returns redirect layer, or 0 if redirect is disabled. Redirected apps can be accessed via `dynamic::hud::redirected::N` textures.
    ---@return integer @0 if redirect is disabled.
    redirectLayer = ffi.C.lj_appwindowaccessor_getredirect__gp,

    ---Moves window to a different render layer, or back to existance with `0` passed as `layer`. Windows in separate layers don’t get mouse
    ---commands (but this wrapper can be used to send fake commands instead).
    ---@param layer integer? @Default value: `0`.
    ---@param duplicate boolean? @Set to `true` to clone a window to a different layer instead of moving it there. Be careful: this might break some Python apps. Default value: `false`.
    ---@return ac.AppWindowAccessor
    setRedirectLayer = function(s, layer, duplicate) ffi.C.lj_appwindowaccessor_setredirect__gp(s, tonumber(layer) or 0, duplicate == true) return s end,

    ---Sends a fake mouse event to a window. Does not work with IMGUI apps or from online scripts.
    ---@param position vec2
    ---@return ac.AppWindowAccessor
    onMouseMove = function(s, position) ffi.C.lj_appwindowaccessor_onmm__gp(s, __util.ensure_vec2(position)) return s end,

    ---Sends a fake mouse event to a window. Does not work with IMGUI apps or from online scripts.
    ---@param position vec2
    ---@param button ui.MouseButton? @Default value: `ui.MouseButton.Left`.
    ---@return ac.AppWindowAccessor
    onMouseDown = function(s, position, button) ffi.C.lj_appwindowaccessor_onmd__gp(s, __util.ensure_vec2(position), tonumber(button) or 0) return s end,

    ---Sends a fake mouse event to a window. Does not work with IMGUI apps or from online scripts.
    ---@param position vec2
    ---@param button ui.MouseButton? @Default value: `ui.MouseButton.Left`.
    ---@return ac.AppWindowAccessor
    onMouseUp = function(s, position, button) ffi.C.lj_appwindowaccessor_onmu__gp(s, __util.ensure_vec2(position), tonumber(button) or 0) return s end,
  }
})