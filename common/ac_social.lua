---Faster way to deal with driver tags. Any request of unsupported fields will return `false` for further extendability.
---Scripts with access to I/O can also alter fields.
---@class ac.DriverTags
---@field color rgbm @User name color. Could be derived from custom color set via `ac.DriverTags` (or `ac.setDriverChatNameColor()`), turns reddish if driver is muted, or uses custom driver tag from CM if any is set, or turns greenish if driver is marked as a friend (in CSP or CM). For the player entry it will always be yellow.
---@field friend boolean @Friend tag, uses CSP and CM databases.
---@field muted boolean @Muted tag, if set messages in chat will be hidden.
---@constructor fun(driverName: string): ac.DriverTags
function ac.DriverTags(driverName)
  __util.lazy('lib_social')
  return ac.DriverTags(driverName)
end

---Checks if a user is tagged as a friend. Uses CSP and CM databases. Deprecated, use `ac.DriverTags` instead.
---@deprecated
---@param driverName string @Driver name.
---@return boolean
function ac.isTaggedAsFriend(driverName)
  __util.lazy('lib_social')
  return ac.isTaggedAsFriend(driverName)
end

---Tags user as a friend (or removes the tag if `false` is passed). Deprecated, use `ac.DriverTags` instead.
---@deprecated
---@param driverName string @Driver name.
---@param isFriend boolean? @Default value: `true`.
function ac.tagAsFriend(driverName, isFriend)
  __util.lazy('lib_social')
  return ac.tagAsFriend(driverName, isFriend)
end
