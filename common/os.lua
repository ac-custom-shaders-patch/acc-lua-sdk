--[[? if (!ctx.test) out(]]
__source 'lua/api_os.cpp'
__namespace 'os'
--[[) ?]]

--[[? if (ctx.ldoc) out(]]
---Module with additional functions to help deal with operating system.
os = {}
--[[) ?]]

---Opens regular Windows file opening dialog, calls callback with either an error or a path to a file selected by user
---(or nil if selection was cancelled). All parameters in `params` table are optional (the whole table too).
--[[@tableparam params {
  title: string = nil "Dialog title",
  defaultFolder: nil|string = ac.getFolder(ac.FolderID.Root) "Default folder if there is not a recently used folder value available",
  folder: string = nil "Selected folder (unlike `defaultFolder`, overrides recently used folder)",
  fileName: string = nil "File name that appears in the File name edit box when that dialog box is opened",
  fileTypes: nil|{ name: string, mask: string }[] = {
    { name = 'Images', mask = '*.png;*.jpg;*.jpeg;*.bmp' }
  } "File types (names and masks)",
  addAllFilesFileType: boolean = true "If providing file types, set this to true to automatically add “All Files (*.*)” type at the bottom",
  fileTypeIndex: integer = nil "File type selected by default (1-based)",
  fileNameLabel: string = nil "Text of the label next to the file name edit box",
  okButtonLabel: string = nil "Text of the Open button",
  places: string[] = nil "Additional places to show in the list of locations on the left",
  flags: os.DialogFlags = bit.bor(os.DialogFlags.PathMustExist, os.DialogFlags.FileMustExist) "Dialog flags (use `bit.bor()` to combine flags together to avoid errors with adding same flag twice)"
}]]
---@param callback fun(err: string, filename: string)
function os.openFileDialog(params, callback)
  ffi.C.lj_dialog_openfile__os(__util.json(params), __util.expectReply(callback))
end

---Opens regular Windows file saving dialog, calls callback with either an error or a path to a file selected by user
---(or nil if selection was cancelled). All parameters in `params` table are optional (the whole table too).
--[[@tableparam params {
  title: string = nil "Dialog title",
  defaultFolder: nil|string = ac.getFolder(ac.FolderID.Root) "Default folder if there is not a recently used folder value available",
  defaultExtension: string = nil "Sets the default extension to be added to file names.",
  folder: string = nil "Selected folder (unlike `defaultFolder`, overrides recently used folder)",
  fileName: string = nil "File name that appears in the File name edit box when that dialog box is opened",
  saveAsItem: string = nil "Ann item to be used as the initial entry in a Save As dialog",
  fileTypes: nil|{ name: string, mask: string }[] = {
    { name = 'Images', mask = '*.png;*.jpg;*.jpeg;*.bmp' }
  } "File types (names and masks)",
  addAllFilesFileType: boolean = true "If providing file types, set this to true to automatically add “All Files (*.*)” type at the bottom",
  fileTypeIndex: integer = nil "File type selected by default (1-based)",
  fileNameLabel: string = nil "Text of the label next to the file name edit box",
  okButtonLabel: string = nil "Text of the Save button",
  places: string[] = nil "Additional places to show in the list of locations on the left",
  flags: os.DialogFlags = bit.bor(os.DialogFlags.PathMustExist, os.DialogFlags.OverwritePrompt, os.DialogFlags.NoReadonlyReturn) "Dialog flags (use `bit.bor()` to combine flags together to avoid errors with adding same flag twice)"
}]]
---@param callback fun(err: string, filename: string)
function os.saveFileDialog(params, callback)
  ffi.C.lj_dialog_savefile__os(__util.json(params), __util.expectReply(callback))
end

---Run a console process in background with given arguments, return exit code and output in callback. Launched process will be tied
---to AC process to shut down with AC (works only on Windows 8 and newer).
--[[@tableparam params {
  filename: string "Application filename",
  arguments: string[] = {} "Arguments (quotes will be added automatically unless `rawArguments` is set to true)",
  rawArguments: boolean = nil "Set to `true` to disable any arguments processing and pass them as they are, simply joining them with a space symbol.",
  workingDirectory: string = nil "Working directory.",
  timeout: integer = nil "Timeout in milliseconds. If above zero, process will be killed after given time has passed.",
  environment: table = nil "If set to a table, values from that table will be used as environment variables instead of inheriting ones from AC process",
  inheritEnvironment: boolean = nil "Set to `true` to inherit AC environment variables before adding custom ones",
  stdin: string = nil "Optional data to pass to a process in stdin pipe",
  separateStderr: boolean = nil "Store stderr data in a separate string",
  terminateWithScript: boolean = nil "Terminate process if this Lua script were to terminate (for example, during reload)",
  dataCallback: fun(err: boolean, data: string) = nil "If set to a function, data written in stdout and stderr will be passed to the function instead as it arrives"
}]]
---@param callback nil|fun(err: string, data: os.ConsoleProcessResult)
function os.runConsoleProcess(params, callback)
  local r
  if type(params.dataCallback) == 'function' then
    local callbackID = __util.setCallback(params.dataCallback)
    params.dataCallback = nil
    r = ffi.C.lj_run_console__os(__util.json(params), __util.expectReply(function (err, data)
      __script.forgetCallback(callbackID)
      if callback then callback(err, data) end
    end), callbackID)
  else
    r = ffi.C.lj_run_console__os(__util.json(params), __util.expectReply(callback), 0)
  end
  if r ~= 0 then
    return function (data)
      ffi.C.lj_run_console_post_stdin__os(r, __util.blob(data))
    end
  end
end
