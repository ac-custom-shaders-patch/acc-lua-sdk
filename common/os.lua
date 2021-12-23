--[[? if (!ctx.test) out(]]
__source 'lua/api_os.cpp'
__namespace 'os'
--[[) ?]]

--[[? if (ctx.ldoc) out(]]
---Module with additional functions to help deal with operating system.
os = {}
--[[) ?]]

os.DialogFlags = __enum({}, {
  None = 0x0,
  OverwritePrompt	= 0x2, -- When saving a file, prompt before overwriting an existing file of the same name. This is a default value for the Save dialog.
  StrictFileTypes	= 0x4, -- In the Save dialog, only allow the user to choose a file that has one of the file name extensions specified through IFileDialog::SetFileTypes.
  NoChangeDir	= 0x8, -- Don't change the current working directory.
  PickFolders	= 0x20, -- Present an Open dialog that offers a choice of folders rather than files.
  ForceFileSystem	= 0x40, -- Ensures that returned items are file system items (SFGAO_FILESYSTEM). Note that this does not apply to items returned by IFileDialog::GetCurrentSelection.
  AllNonStorageItems	= 0x80, -- Enables the user to choose any item in the Shell namespace, not just those with SFGAO_STREAM or SFAGO_FILESYSTEM attributes. This flag cannot be combined with FOS_FORCEFILESYSTEM.
  NoValidate	= 0x100, -- Do not check for situations that would prevent an application from opening the selected file, such as sharing violations or access denied errors.
  AllowMultiselect	= 0x200, -- Enables the user to select multiple items in the open dialog. Note that when this flag is set, the IFileOpenDialog interface must be used to retrieve those items.
  PathMustExist	= 0x800, -- The item returned must be in an existing folder. This is a default value.
  FileMustExist	= 0x1000, -- The item returned must exist. This is a default value for the Open dialog.
  CreatePrompt	= 0x2000, -- Prompt for creation if the item returned in the save dialog does not exist. Note that this does not actually create the item.
  ShareAware	= 0x4000, -- In the case of a sharing violation when an application is opening a file, call the application back through OnShareViolation for guidance. This flag is overridden by FOS_NOVALIDATE.
  NoReadonlyReturn	= 0x8000, -- Do not return read-only items. This is a default value for the Save dialog.
  NoTestFileCreate	= 0x10000, -- Do not test whether creation of the item as specified in the Save dialog will be successful. If this flag is not set, the calling application must handle errors, such as denial of access, discovered when the item is created.
  HideMRUPlaces	= 0x20000, -- Hide the list of places from which the user has recently opened or saved items. This value is not supported as of Windows 7.
  HidePinnedPlaces	= 0x40000, -- Hide items shown by default in the view's navigation pane. This flag is often used in conjunction with the IFileDialog::AddPlace method, to hide standard locations and replace them with custom locations.\n\nWindows 7 and later. Hide all of the standard namespace locations (such as Favorites, Libraries, Computer, and Network) shown in the navigation pane.\n\nWindows Vista. Hide the contents of the Favorite Links tree in the navigation pane. Note that the category itself is still displayed, but shown as empty.
  NoDereferenceLinks	= 0x100000, -- Shortcuts should not be treated as their target items. This allows an application to open a .lnk file rather than what that file is a shortcut to.
  OkButtonNeedsInteraction	= 0x200000, -- The OK button will be disabled until the user navigates the view or edits the filename (if applicable). Note: Disabling of the OK button does not prevent the dialog from being submitted by the Enter key.
  DontAddToRecent	= 0x2000000, -- Do not add the item being opened or saved to the recent documents list (SHAddToRecentDocs).
  ForceShowHidden	= 0x10000000, -- Include hidden and system items.
  DefaultNoMiniMode	= 0x20000000, -- Indicates to the Save As dialog box that it should open in expanded mode. Expanded mode is the mode that is set and unset by clicking the button in the lower-left corner of the Save As dialog box that switches between Browse Folders and Hide Folders when clicked. This value is not supported as of Windows 7.
  ForcePreviewPaneOn	= 0x40000000, -- Indicates to the Open dialog box that the preview pane should always be displayed.
  SupportStreamableItems	= 0x80000000 -- Indicates that the caller is opening a file as a stream (BHID_Stream), so there is no need to download that file.
})

---Opens regular Windows file opening dialog, calls callback with either an error or a path to a file selected by user
---(or nil if selection was cancelled). All parameters in `params` table are optional (the whole table too).
--[[@tableparam params {
  title: string = 'Open' "Dialog title",
  defaultFolder: string = ac.getFolder(ac.FolderID.Root) "Default folder if there is not a recently used folder value available",
  folder: string = nil "Selected folder (unlike `defaultFolder`, overrides recently used folder)",
  fileName: string = nil "File name that appears in the File name edit box when that dialog box is opened",
  fileTypes: { name: string, mask: string }[] = {
    { name = 'Images', mask = '*.png;*.jpg;*.jpeg;*.psd' }
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
  title: string = 'Save' "Dialog title",
  defaultFolder: string = ac.getFolder(ac.FolderID.Root) "Default folder if there is not a recently used folder value available",
  defaultExtension: string = nil "Sets the default extension to be added to file names.",
  folder: string = nil "Selected folder (unlike `defaultFolder`, overrides recently used folder)",
  fileName: string = nil "File name that appears in the File name edit box when that dialog box is opened",
  saveAsItem: string = nil "Ann item to be used as the initial entry in a Save As dialog",
  fileTypes: { name: string, mask: string }[] = {
    { name = 'Images', mask = '*.png;*.jpg;*.jpeg;*.psd' }
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
  stdin: string = nil "Optional data to pass to a process in stdin pipe",
  separateStderr: boolean = nil "Store stderr data in a separate string"
}]]
---@param callback fun(err: string, data: os.ConsoleProcessResult)
function os.runConsoleProcess(params, callback)
  ffi.C.lj_run_console__os(__util.json(params), __util.expectReply(callback))
end
