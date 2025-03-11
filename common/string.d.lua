---Function won’t work: while CSP tries its best to guarantee API compatibility, ABI compatibility is not a priority at all,
---and the underlying LuaJIT implementation frequently changes and might even be replaced with something else in the future.
---@return nil
function string.dump() return nil end

---Splits string into an array using separator.
---@param self string @String to split.
---@param separator string? @Separator. If empty, string will be split into individual characters. Default value: ` `.
---@param limit integer? @Limit for pieces of string. Once reached, remaining string is put as a list piece.
---@param trimResult boolean? @Set to `true` to trim found strings. Default value: `false`.
---@param skipEmpty boolean? @Set to `false` to keep empty strings. Default value: `true` (for compatibility reasons).
---@param splitByAnyChar boolean? @Set to `true` to split not by a string `separator`, but by any characters in `separator`.
---@return string[]
function string.split(self, separator, limit, trimResult, skipEmpty, splitByAnyChar) end

---Splits string into a bunch of numbers (not in an array). Any symbol that isn’t a valid part of number is considered to be a delimiter. Does not create an array
---to keep things faster. To make it into an array, simply wrap the call in `{}`.
---@param self string @String to split.
---@param limit integer? @Limit for amount of numbers. Once reached, remaining part is ignored.
---@return ... @Numbers
function string.numbers(self, limit) end

---Pack things. For format, see <https://www.lua.org/manual/5.3/manual.html#6.4.2>.
---Use `a` for half-precision floating point value (two bytes).
---@param self string @Format string.
---@return string
function string.pack(self, ...) end

---Measure size of packed things. For format, see <https://www.lua.org/manual/5.3/manual.html#6.4.2>.
---Use `a` for half-precision floating point value (two bytes).
---@param self string @Format string.
---@return integer
function string.packsize(self) end

---Unpack things. For format, see <https://www.lua.org/manual/5.3/manual.html#6.4.2>.
---Use `a` for half-precision floating point value (two bytes).
---@param self string @Format string.
---@return ...
function string.unpack(self) end

---Checks if string starts with an URL or not. Uses flexible parsing scheme so even URLs not starting with
---a scheme could be found.
---@param self string @Target string.
---@param offset integer? @Starting search index, 1-based.
---@return integer? @Returns length of URL, or `nil` if string is not an URL.
function string.urlCheck(self, offset) end

---Finds next URL in a string. Uses flexible parsing scheme so even URLs not starting with
---a scheme could be found.
---@param self string @Target string.
---@param offset integer? @Starting search index, 1-based.
---@return integer? @First returned value is 1-based index of URL start.
---@return integer? @Second returned value is 1-based index of URL end (both arguments can be passed to `string.sub()` to cut out the URL).
function string.urlNext(self, offset) end

---Works like string.find with plain mode, but ignores case.
---@param self string @String to find `needle` in.
---@param needle string @String to find.
---@param index integer? @Starting search index. Default value: `1`.
---@return integer? @1-based index of a first match, or `nil` if nothing has been found.
function string.findIgnoreCase(self, needle, index) end

---Searches and replaces all the substrings.
---@param self string @String to find `replacee` and replace with `replacer` in.
---@param replacee string @String to find.
---@param replacer string? @String to replace. Default value: ``.
---@param limit integer? @Maximum number of found strings to replace. Default value: `math.huge`.
---@param ignoreCase boolean? @Option for case-incensitive search. Default value: `false`.
---@return string, integer @Second value returned is for the number of replacements.
function string.replace(self, replacee, replacer, limit, ignoreCase) end

---Returns UTF8 string for a corresponding code point.
---@param codePoint integer
---@return string
function string.codePointToUTF8(codePoint) end

---Returns unicode codepoint and length in bytes from a point in a string. Throws an error with invalid UTF-8.
---@param self string @String to get a codepoint from
---@param start integer @Index (starts with 1, if below counts from the end).
---@return integer? @Symbol codepoint (or `nil` if there is no symbol with given index).
---@return integer @Symbol length (or `nil` if there is no symbol with given index).
function string.codePointAt(self, start) end

---Looks for a next emoji in the string. If next emoji is complex, all the symbols will be processed and returned as a single byte sequence. Uses 15th version
---with data from Emoji Keyboard/Display Test Data for UTS #51.
---Not working properly for CSP versions below v0.2.3-preview50.
---@param self string @String to search emojis in.
---@param start integer @Index (starts with 1, if below counts from the end).
---@return integer? @Returns 1-based starting index of an emojis, or `nil` if no emojis have been found.
---@return integer? @Returns 1-based ending index, or `nil` if no emojis have been found.
function string.nextEmoji(self, start) end

---Encodes URL argument.
---@param self string
---@param plusForSpaces boolean? @Use `'+'` for space symbol (works for URLs, but if a regular URL encoding is needed, might be getting in a way). Default value: `true`.
---@return string
function string.urlEncode(self, plusForSpaces) end

---Checks if the beginning of a string matches another string. If string to match is longer than the first one, always returns `false`.
---@param self string @String to check the beginning of.
---@param another string @String to match.
---@param offset integer? @Optional offset for the matching beginning. Default value: `0`.
---@return boolean
function string.startsWith(self, another, offset) end

---Checks if the end of a string matches another string. If string to match is longer than the first one, always returns `false`.
---@param self string @String to check the end of.
---@param another string @String to match.
---@param offset integer? @Optional offset for the matching end. Default value: `0`.
---@return boolean
function string.endsWith(self, another, offset) end

---Compares string alphanumerically.
---@param self string @First string.
---@param another string @Second string.
---@return integer @Returns positive number if first string is larger than second one, or 0 if strings are equal.
function string.alphanumCompare(self, another) end

---Compares string as versions (splits by dots and uses alphanumerical comparator for each piece).
---@param self string @First version.
---@param another string @Second version.
---@return integer @Returns positive number if first version is newer than second one, or 0 if versions are equal.
function string.versionCompare(self, another) end

---Trims string at beginning and end.
---@param self string @String to trim.
---@param characters string? @Characters to remove. Default value: `'\n\r\t '`.
---@param direction integer? @Direction to trim, 0 for trimming both ends, -1 for trimming beginning only, 1 for trimming the end. Default value: `0`.
---@return string
function string.trim(self, characters, direction) end

---Repeats string a given number of times (`repeat` is a reserved keyword, so here we are).
---@param self string @String to trim.
---@param count integer @Number of times to repeat the string.
---@return string
function string.multiply(self, count) end

---Pads string with symbols from `pad` until it reaches the desired length.
---@param self string @String to trim.
---@param targetLength integer @Desired string length. If shorter than current length, string will be trimmed from the end.
---@param pad string? @String to pad with. If empty, no padding will be performed. If has more than one symbol, will be repeated to fill the space. Default value: ` ` (space).
---@param direction integer? @Direction to pad to, 1 for padding at the end, -1 for padding at the start, 0 for padding from both ends centering string. Default value: `1`.
---@return string
function string.pad(self, targetLength, pad, direction) end

---Similar to `string.find()`: looks for the first match of `pattern` and returns indices, but uses regular expressions.
---
---Note: regular expressions currently are in ECMAScript format, so backtracking is not supported. Also, in most cases they are slower than regular Lua patterns.
---@param self string @String to search in.
---@param pattern string @Regular expression.
---@param init integer? @1-based offset to start searching from. Default value: `1`.
---@param ignoreCase boolean? @Set to `true` to make search case-insensitive. Default value: `false`.
---@return integer? @1-based index of where the match occured, or `nil` if no match has been found.
---@return integer? @1-based index of the ending of found pattern, or `nil` if no match has been found.
---@return ... @Captured elements, if there are any capture groups in the pattern.
---@nodiscard
function string.regfind(self, pattern, init, ignoreCase) end

---Similar to `string.match()`: looks for the first match of `pattern` and returns matches, but uses regular expressions.
---
---Note: regular expressions currently are in ECMAScript format, so backtracking is not supported. Also, in most cases they are slower than regular Lua patterns.
---@param self string @String to search in.
---@param pattern string @Regular expression.
---@param init integer? @1-based offset to start searching from. Default value: `1`.
---@param ignoreCase boolean? @Set to `true` to make search case-insensitive. Default value: `false`.
---@return string @Captured elements if there are any capture groups in the pattern, or the whole captured string otherwise.
---@nodiscard
function string.regmatch(self, pattern, init, ignoreCase) end

---Similar to `string.gmatch()`: iterates over matches of `pattern`, but uses regular expressions.
---
---Note: regular expressions currently are in ECMAScript format, so backtracking is not supported. Also, in most cases they are slower than regular Lua patterns.
---@param self string @String to search in.
---@param pattern string @Regular expression.
---@param ignoreCase boolean? @Set to `true` to make search case-insensitive. Default value: `false`.
---@return fun():string, ... @Iterator with captured elements if there are any capture groups in the pattern, or the whole captured string otherwise.
---@nodiscard
function string.reggmatch(self, pattern, ignoreCase) end

---Similar to `string.gsub()`: replaces all entries of `pattern` with `repl`, but uses regular expressions.
---
---Note: regular expressions currently are in ECMAScript format, so backtracking is not supported. Also, in most cases they are slower than regular Lua patterns.
---@param self string @String to search in.
---@param pattern string @Regular expression.
---@param repl    string|table|function @Replacement value. Used in the same way as with `string.gsub()`, could be a table or a function.
---@param limit integer? @Limit maximum number of replacements. Default value: `math.huge`.
---@param ignoreCase boolean? @Set to `true` to make search case-insensitive. Default value: `false`.
---@return string @String with found entries replaced.
---@nodiscard
function string.reggsub(self, pattern, repl, limit, ignoreCase) end

---Compares a string against CSP-style filter (using “?” for “any characters”).
---@param self string @String to check.
---@param filter string @Filter to check. Surround with `{…}` to use complex queries, for example, `'{ ABC? & ! ?DEF }'`.
---@param init integer? @1-based offset to start searching from. Default value: `1`.
---@return boolean
function string.cspmatch(self, filter, init) end
