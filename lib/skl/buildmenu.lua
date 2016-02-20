local buildmenu = {}
local menuStorage = {}

local ai = require("ai")
local base = require("skl.base")

function buildmenu.menu(args, page)
    args = args or {}
    if type(args) == "string" then
        args = menuStorage[args]
    end
    page = page or 1
    args.title = args.title or ""
    args.foot = args.foot or ""
    args.timeout = args.timeout or 30000
    args.id = args.id or uuid()
    args.cols = args.cols or 2
    args.rows = args.rows or 4
    args.width = args.width or 70
    args.link = args.link or "\\![*] #{qbegin}#{link}#{qend}"
    args.nextPage = args.nextPage or "\\![*] #{qbegin}下一页#{qend}"
    args.prevPage = args.prevPage or "\\![*] #{qbegin}上一页#{qend}"
    args.disableCancel = args.disableCancel or false
    args.cancel = args.cancel or "\\![*] #{qbegin}关闭#{qend}"
    args.cancelReply = "\\0唔。\\e"
    args.items = args.items or {
        {"事件示例1", "OnMenuDemoItemClicked", "1"},
        {"事件示例2", "OnMenuDemoItemClicked,2"},
        {"回调示例", function(tbl) return "\\0回调。\\e" end},
        {"重载 Shiori", function() return "\\![reload,shiori]辞书重载完成。\\e" end},
        {"选项子示例1", "demo1"},
        {"选项子示例2", "demo2"}
    }
    
    -- calculate col width
    if type(args.width) == "number" then
        local w = args.width
        args.width = {}
        for i = 1, args.cols do
            args.width[i] = w * (i - 1)
        end
    end
    
    -- register menu
    menuStorage[args.id] = args
    
    local mStr = "\\![set,balloontimeout," .. args.timeout .. "]"
    mStr = mStr .. base.getValue(args.title)
    local itemPerPage = args.cols * args.rows
    local totalPage = math.ceil(#args.items / itemPerPage)
    local startIndex = (itemPerPage * (page - 1)) + 1
    
    if startIndex > #args.items or page > totalPage then
        return nil, args
    end
    
    for i = startIndex, math.min(#args.items, startIndex + itemPerPage - 1) do
        local item = args.items[i]
        local eventStr = nil
        local col = math.fmod(i - 1, args.cols) + 1
        
        -- check if need to start a new line
        if col == 1 then
            mStr = mStr .. "\\n"
        end
        
        if type(item[1]) ~= "nil" then
            local extArgs = ""
            local ss, ret = pcall(table.concat, {select(3, unpack(item))}, ",")
            if ss and ret then
                extArgs = ret
            end
            if type(item[2]) == "function" then
                eventStr = "OnSklBuildMenuItemClick," .. args.id .. "," .. i .. "," .. extArgs
            elseif type(item[2]) ~= "nil" then
                eventStr = item[2] .. "," .. extArgs
            end
            local itemStr = item[1]
            local posStr = "\\_l[" .. args.width[col] .. ",-]"
            if eventStr then
                local iTable = {
                    qbegin = "\\q[",
                    qend = "," .. eventStr .. "]",
                    link = itemStr,
                }
                mStr = mStr .. posStr .. interp(args.link, iTable)
            else
                mStr = mStr .. posStr .. itemStr
            end
        end
    end
    
    mStr = mStr .. base.getValue(args.foot)
    
    -- check if have next page
    if page < totalPage then
        local pageEvent = "OnSklBuildMenuPageClick," .. args.id .. "," .. (page + 1)
        local iTable = {
            qbegin = "\\q[",
            qend = "," .. pageEvent .. "]",
            currentPage = page,
            nextPage = page + 1
        }
        mStr = mStr .. "\\n" .. interp(args.nextPage, iTable)
    end
    
    -- check if have prev page
    if page > 1 then
        local pageEvent = "OnSklBuildMenuPageClick," .. args.id .. "," .. (page - 1)
        local iTable = {
            qbegin = "\\q[",
            qend = "," .. pageEvent .. "]",
            currentPage = page,
            nextPage = page - 1
        }
        mStr = mStr .. "\\n" .. interp(args.prevPage, iTable)
    end
    
    if not args.disableCancel then
        local iTable = {
            qbegin = "\\q[",
            qend = ",OnSklBuildMenuCancel," .. args.id .. "]"
        }
        mStr = mStr .. "\\n" .. interp(args.cancel, iTable)
    end
    
    return mStr, args
end

ai.respond("OnSklBuildMenuItemClick", function(req)
    local id = req.Reference0
    local index = req.Reference1 + 0
    if not (id and index and menuStorage[id] and menuStorage[id].items[index]) then
        return nil
    end
    local callback = menuStorage[id].items[index][2]
    return callback(refUnpack(req, 2))
end)

ai.respond("OnSklBuildMenuPageClick", function(req)
    local id = req.Reference0
    local page = req.Reference1 + 0
    local menu = menuStorage[id]
    local str, m = buildmenu.menu(menu, page)
    return str
end)

ai.respond("OnSklBuildMenuCancel", function(req)
    local id = req.Reference0
    return menuStorage[id].cancelReply
end)

return buildmenu