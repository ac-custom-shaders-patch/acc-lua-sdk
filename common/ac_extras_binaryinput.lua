__source 'lua/api_extras_binaryinput.cpp'

ffi.cdef [[ 
typedef struct {
  void* __something;
} binaryinput;
]]

-- Flag `ignore` is for ignoring modifiers: if set, both, for example, X and Ctrl+X would trigger the event.
-- Flag `system` is for system hotkeys that require held Ctrl to be active, such as replay activation.
-- Flag `gamepad` is for gamepad buttons, use `ac.GamepadButton` instead of `ui.KeyIndex` for `key` argument.
-- @alias ac.ControlButtonModifiers {ctrl: boolean, shift: boolean, alt: boolean, ignore: boolean, gamepad: boolean, system: boolean}

function ac.ControlButton(id, key, modifiers, repeatPeriod)
  local k, m, r = 0, 0, 1e9
  if type(key) == 'table' then
    -- New format
    if type(key.keyboard) == 'table' then
      k = tonumber(key.keyboard.key) or 0
      m = key.keyboard.ctrl and 2 or 0
      if key.keyboard.shift then m = m + 8 end
      if key.keyboard.alt then m = m + 4 end
    elseif type(key.gamepad) == 'number' then
      k = tonumber(key.gamepad) or 0
      m = -2
    end
  else
    -- Old ugly & private format
    if type(modifiers) == 'table' then
      if modifiers.ctrl then m = m + 2 end
      if modifiers.shift then m = m + 8 end
      if modifiers.alt then m = m + 4 end
      if modifiers.ignore then m = -1 end
      if modifiers.gamepad then m = -2 end
      if modifiers.system then m = -3 end
    end
    k = tonumber(key) or 0
    r = tonumber(repeatPeriod) or 1e9
  end
  return ffi.C.lj_binaryinput_new(tostring(id), k, m, r)
end

---If any type restriction is set, binding will be shown as empty if there is no device fitting the restriction bound. If no type
---restriction is set, any input device can be bound overriding all previously configured boundaries, or multiple bindings can be added
---with a popup menu.
ui.ControlButtonControlFlags = __enum({}, {
  None = 0,
  Keyboard = 1,           -- Type restriction: keyboard only
  Gamepad = 2,            -- Type restriction: gamepad only
  Controllers = 4,        -- Type restriction: controllers only
  NoKeyboard = 6,         -- Type restriction: gamepad or controllers depending on input mode
  IgnoreConflicts = 16,   -- Do not check if anything else in “controls.ini” is already using the input
  SingleEntry = 32,       -- Don’t show multiple devices if bound, only a single one, remove other devices on bounding
  IgnoreRealConfig = 64,  -- Disable copying changes to original presets with car-specific controls or presets-per-mode active
})

---A good way to listen to user pressing buttons configured in AC control settings. Handles everything for you automatically, and if you’re working
---on a Lua app has a `:control()` method drawing a button showing current binding and allowing to change it in-game.
---
---Could be used for original AC button bindings, new bindings added by CSP, or even for creating custom bindings. For that, make sure to pass a
---reliably unique ID when creating a control button, maybe even prefixed by your app name.
---
---Note: inputs for car scripts (both display and physics ones) would work only if the car is currently controlled by the user.
---@class ac.ControlButton
---@explicit-constructor ac.ControlButton
ffi.metatype('binaryinput', {
  __index = {
    ---Button is configured.
    ---@return boolean
    configured = ffi.C.lj_binaryinput_set,

    ---Button was just pressed.
    ---@return boolean
    pressed = __util.__physicsThread__ and ffi.C.lj_binaryinput_pressedphysics or ffi.C.lj_binaryinput_pressed,

    ---Button is held down.
    ---@return boolean
    down = ffi.C.lj_binaryinput_down,

    ---Sets a callback to be called when the button is pressed.
    ---@param callback fun()
    ---@return ac.Disposable
    onPressed = function(s, callback)
      if type(callback) ~= 'function' then error('Callback should be a function', 2) end
      return __util.disposable(ffi.C.lj_binaryinput_onpressed(s, __util.setCallback(callback)))
    end,

    ---Sets a callback to be called when the button is released.
    ---@param callback fun()
    ---@return ac.Disposable
    onReleased = function(s, callback)
      if type(callback) ~= 'function' then error('Callback should be a function', 2) end
      return __util.disposable(ffi.C.lj_binaryinput_onreleased(s, __util.setCallback(callback)))
    end,

    ---@param value boolean? @Default value: `true`.
    ---@return ac.ControlButton
    setAlwaysActive = function(s, value)
      ffi.C.lj_binaryinput_setalwaysactive(s, value ~= false)
      return s
    end,

    ---Use within UI function to draw an editing button. Not available for scripts without UI access.
    ---@param size vec2? @If not set, or width is 0, uses next item width and regular button height.
    ---@param flags ui.ControlButtonControlFlags? @Default value: `ac.ControlButtonControlFlags.None`.
    ---@param emptyLabel string? @Default value: `'Click to assign'`.
    ---@return boolean
    control = function(s, size, flags, emptyLabel)
      if not ui or not ui.button then error('Not allowed for this type of script', 2) end
      return ffi.C.lj_binaryinput_control(s, __util.ensure_vec2(size), tonumber(flags) or 7, emptyLabel and tostring(emptyLabel) or 'Click to assign')
    end,
  }
})