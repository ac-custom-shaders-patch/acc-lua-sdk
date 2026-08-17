__source 'lua/api_gameplay_apps.cpp'

function ac.accessAppWindow(windowName) return __util.lazy('lib_accessappwindow')(windowName) end