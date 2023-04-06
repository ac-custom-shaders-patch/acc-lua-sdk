require './common/internal_import'

-- automatically generated entries go here:
__definitions()

---Nothing from here will be called for background threads.
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Available only in background worker scripts. Stores input data passed to `ac.startBackgroundWorker()` 
---function. Passed tables are serialized and deserialized using a binary format.
---@type any
__input = nil

---Available only in background worker scripts. Sleep function pauses execution for a certain time. 
---Before unpaused, any callbacks (such as `setTimeout()`, `setInterval()` and
---other custom enqueued callbacks) will be called. This is the only way for those callbacks to fire in a background worker. Note:
---if parent thread is closed, `ac.sleep()` won’t return back and instead script will be unloaded, this way worker can be reloaded
---as well.
---@param time number @Time in seconds to pause worker by.
function os.sleep(time) end

--[[) ?]]

