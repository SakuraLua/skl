--[[
This file is a part of SakuraLua.
本文件是 SakuraLua 系统的一部分。
**DO NOT MODIFY THIS FILE UNLESS YOU ARE A DEVELOPER OF SKL.**
**如果你不是 SKL 开发者，请勿修改本文件。**
]]

if SKL_INITED then
    return false
end
-- init SKL globals
SKL_INITED = true
SKL_PRODUCT_NAME = "SakuraLua"
SKL_PRODUCT_VERSION = "0.1"
-- init paths
package.path = "./?.lua"
package.cpath = "./clibs/?.dll"
local luaPath = {"", "lib/", "lua/", "skl/", "skl/lib/", "skl/lua/"}
local cPath = {"clibs/", "skl/clibs/"}
for i = 1, #luaPath do
    package.path = package.path .. ";" .. SHIORI_PATH .. luaPath[i] .. "?.lua"
    package.path = package.path .. ";" .. SHIORI_PATH .. luaPath[i] .. "?.luac"
end
for i = 1, #cPath do
    package.cpath = package.cpath .. ";" .. SHIORI_PATH .. cPath[i] .. "?.dll"
end

require("global_functions")

-- load index file for monkey patching skl
local index = require("index")

-- init skl
local skl = require("skl")
skl.init()

-- init index
if type(index) == "table" and index.init then
    index.init()
end

-- load plugins
require("lib.skl.plugins").load_all()