First see this, current LUA libraries are always included in latest CSP version:
https://github.com/CheesyManiac/cheesy-lua/wiki/Getting-Started-with-CSP-Lua-Scripting


this is kinda old now:


# CSP Lua SDK

Source code for CSP Lua libraries. Feel free to use any of its parts, like its [class implementation](/common/class.lua), in your projects, 
or just use it for a reference.

Designed to work with [OpenResty’s fork of LuaJIT](https://github.com/openresty/luajit2), with LuaJIT compiled with 5.2 compatibility option.

# How to start writing scripts

Whole API is fully documented, documentation definitions are shipped with CSP builds and can be found in “extension/internal/lua-sdk” folder,
with a readme file on how to plug them in. You’d need to use [Visual Studio Code](https://code.visualstudio.com/) and 
[Lua plugin by sumneko](https://github.com/sumneko/lua-language-server), and it would result in a neat seamless docs integration:

![Screenshot](https://files.acstuff.ru/shared/Hv6o/20211223-182954.png)

Definition files are generated in [EmmyLua format](https://emmylua.github.io/), and there are plugins for other IDEs too, but it might be
a bit more tricky to set.

More information is available in [wiki](https://github.com/ac-custom-shaders-patch/acc-lua-sdk/wiki).

# How libraries work

Any Lua script in Assetto Corsa first loads [ac_common](/ac_common.lua) library and then loads a library corresponding to its type. 
Different types of script can define different `script.…` functions which will then be called by CSP when certain event occurs.

For backwards compatibility some functions, like `function script.update()`, can be defined in global namespace like `function update()`,
but `script.…` ones will be looked for first. Once CSP finds a function, it would store a reference to it for faster lookup when calling
in the future, so changing functions on-fly wouldn’t work.

# Points of interest

A few places in this repo that might interest you:

- [Definitions](.definitions): while automatically generated documentation for that Lua plugin is detaile, there are also some simple summary files listing available functions and structures. They’re not as exhaustive and don’t have everything, but they still might help to skim over and possibly notice something useful.
- [Common API implementation](common): sometimes docs might not be enough and you might want to check how something is implemented, like, for example, [those `table` functions](common/table.lua).

# Prepared scripts to use as examples

- [Built-in apps](https://github.com/ac-custom-shaders-patch/app-csp-defaults);
- [Built-in internal scripts](https://github.com/ac-custom-shaders-patch/acc-lua-internal);
- [Built-in postprocessing filters](https://github.com/ac-custom-shaders-patch/acc-extension-config/tree/master/lua/pp-filters);
- [Default WeatherFX implementation](https://github.com/ac-custom-shaders-patch/acc-weatherfx-base);
- [Paintshop app](https://github.com/ac-custom-shaders-patch/app-paintshop);
- [Various Lua examples](https://github.com/ac-custom-shaders-patch/acc-lua-examples).

