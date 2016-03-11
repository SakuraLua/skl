local dm = {}
local buildmenu = require("skl.buildmenu")
local menu = require("functions.menu")
local ai = require("ai")
local base = require("skl.base")
local Choice = require("functions.choice")

dm.menu = {}
dm.menu.config = {
    rows = 9,
    cols = 1,
    title = "\\0\\b[2]这是开发者调试菜单。\\_q\\n\\n[half]",
    items = {
        {"执行 Lua 脚本", RS("\\![open,inputbox,OnDebugLuaEval]请务必使用 return 返回，或使用 log 记录想要查询的信息。\\e")},
        {"内置机制执行樱语", RS("\\![open,inputbox,OnDebugSakuraEval]将会使用内置机制执行输入的樱花语法。\\e")},
        {"刷新 Shiori", RS("\\![reload,shiori]辞书刷新完成。\\e")},
        {"刷新人格", RS("\\![reload,ghost]\\e")},
        {"返回主菜单", "OnOpenMenu", "main"}
    }
}
menu.debug = dm.menu
function dm.init()
    if CONFIG.debugMenuShow then
        table.insert(menu.main.config.items, {"开发者菜单", "OnOpenMenu", "debug"})
    end
end
ai.respond("OnKeyPress", function (req)
    if req.prevResponse then return req.prevResponse end
    if CONFIG.debugMenuKey and req.Reference0 == CONFIG.debugMenuKey then
        return ai.execute("OnOpenMenu", "debug")
    end
    if CONFIG.restartKey and CONFIG.restartKey == req.Reference0 then
        return "\\![reload,ghost]"
    end
end)


ai.respond("OnDebugLuaEval", function (req)
    local ss, ret = pcall(loadstring(req.Reference0), req)
    log(ret)
    if ss then
        return "\\![open,inputbox,OnDebugLuaEval]" .. base.reply(ret, req).Value
    else
        return "\\![open,inputbox,OnDebugLuaEval]" .. ret
    end
end)

ai.respond("OnDebugSakuraEval", function(req)
    return "\\![open,inputbox,OnDebugSakuraEval]" .. req.Reference0
end)

return dm