local menu = {}
local ai = require("ai")
local aiTalk = require("functions.aitalk")
local buildmenu = require("skl.buildmenu")
local Choice = require("functions.choice")

-------------------- 主菜单 --------------------

menu.main = {
    config = {
        id = "skl_main",
        rows = 9,
        title = (DICT.menus and DICT.menus.maintitle)
                    or "\\0\\b[2]需要帮忙吗\\_q\\n\\n[half]",
        items = {
            {"（刚才说了什么？）", "mainLastTalk"},
            {nil},
            --
            {"聊天", "OnAITalk"},
            {"占卜", "OnFortune"},
            --
            {"偏好设置", "OnOpenMenu", "basic"},
            {"个人设置", "OnOpenMenu", "personal"},
            --
            {"便利功能", "OnOpenMenu", "tools"},
            {"实用工具", "OnOpenMenu", "utils"},
            --
            {nil}, {nil},
            --
            {"人格信息", RS("\\![open,readme]")},
            {nil},
        }
    }
}

function Choice.mainLastTalk()
    if aiTalk.lastTalk then
        return DICT.menus.mainlasttalk or "\\![embed,FuncAiTalkLastTalk]"
    else
        return DICT.aitalklastnothing or "什么也没有说。"
    end
end

-------------------- 实用工具 --------------------
menu.utils = {
    config = {
        id = "skl_utils",
        title = [[\0\b[2]「实用工具」\_q\n[half]\n]],
        rows = 9,
        cols = 1,
        width = {0},
        foot = "\\n\\n[half]\\![*] \\q[返回主菜单,OnOpenMenu,main]",
        items = {}
    }
}
-------------------- 偏好设定 --------------------
menu.basic = {
    config = {
        id = "skl_basic",
        title = "\\0\\b[2]「偏好設定」\\_q\\n\\n[half]",
        rows = 9,
        cols = 3,
        width = {0, 55, 100},
        link = "#{qbegin}#{link}#{qend}",
        foot = "\\n\\n[half]\\![*] \\q[返回主菜單,OnOpenMenu,main]"
    }
}

local function changeBasic(key, value)
    SAVEDATA[key] = value
    require("skl").saveData()
    return menu.basic.menu()
end

function menu.basic.items()
    function getItem(title, condition)
        if condition then
            return "●" .. title
        else
            return "○" .. title
        end
    end
    items = {}
    table.insert(items, {"简繁转换"})
    table.insert(items, {
        getItem("简体", SAVEDATA.simplifiy == "chs"),
        changeBasic,
        "simplifiy,chs"
    })
    table.insert(items, {
        getItem("繁體", (SAVEDATA.simplifiy == "cht")),
        changeBasic,
        "simplifiy,cht"
    })
    table.insert(items, {"说话频率"})
    table.insert(items, {
        getItem("啰嗦", SAVEDATA.aiTalkInterval == "60"),
        changeBasic,
        "aiTalkInterval,60"
    })
    table.insert(items, {
        getItem("一般", SAVEDATA.aiTalkInterval == "120"),
        changeBasic,
        "aiTalkInterval,120"
    })
    table.insert(items, {nil})
    table.insert(items, {
        getItem("安静", SAVEDATA.aiTalkInterval == "300"),
        changeBasic,
        "aiTalkInterval,300"
    })
    table.insert(items, {
        getItem("沉默", SAVEDATA.aiTalkInterval == "0"),
        changeBasic,
        "aiTalkInterval,0"
    })
    return items
end

function menu.basic.menu()
    menu.basic.config.items = menu.basic.items()
    return buildmenu.menu(menu.basic.config)
end

-------------------- 个人设定 --------------------
menu.personal = {
    config = {
        id = "skl_personal",
        title = "\\0\\b[2]「个人设置」\\_q\\n鼠标单击可修改。\\n\\n[half]",
        rows = 9,
        cols = 1,
        items = {
            {"称呼：%(username)", RS("\\![open,inputbox,OnInputChangeUsername]")}
        }, 
        foot = "\\n\\n[half]\\![*] \\q[返回主菜单,OnOpenMenu,main]"
    }
}

function menu.init()
    ai.respond("OnOpenMenu", function(req)
        local menuName = req.Reference0
        local m = menu[menuName]
        if type(m) == "nil" then
            -- try to load menu script
            local func = ai.loadScript("menu/" .. menuName)
            if func then
                menu[menuName] = {
                    menu = func
                }
                return func
            end
        elseif type(m) ~= "table" then
            return m
        elseif m.menuStr then
            return m.menuStr
        elseif m.menu then
            return m.menu
        elseif m.config then
            -- m.menuStr, m.menuObj = buildmenu.menu(m.config)
            -- return m.menuStr
            return buildmenu.menu(m.config)
        else
            return m
        end
    end)
end

return menu