function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local random = math.random
function uuid(template)
    template = template or 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function refUnpack(ref, startFrom)
    startFrom = startFrom or 0
    local i = startFrom
    local ret = {}
    while ref["Reference" .. i] ~= nil do
        table.insert(ret, ref["Reference" .. i])
        i = i + 1
    end
    return unpack(ret)
end

-- return string
-- useful when creating menus
function RS(str)
    return function()
        return str
    end
end

function interp(s, tab)
  return (s:gsub('(#%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

-- 按路径获取一个 table
-- table.readDeep(table, "a.b.c.d")
function table.readDeep(table, path, defaultValue)
    assert(type(table) == "table", "read deep should provide a table as arg 1")
    assert(type(path) == "string", "read deep should provide a string as arg 2")
    local pathList = path:split(".")
    local i, currentTable, currentKey
    currentTable = table
    for i=1, #pathList do
        currentKey = pathList[i]
        -- 如果是最后一级
        if i == #pathList then
            if currentTable[currentKey] == nil then
                return defaultValue
            else
                return currentTable[currentKey]
            end
        end
        -- 如果不是
        if currentTable[currentKey] == nil then
            return defaultValue
        else
            if(type(currentTable[currentKey]) == "table") then
                -- 继续遍历
                currentTable = currentTable[currentKey]
            else
                -- 返回默认值
                return defaultValue
            end
        end
    end
    return defaultValue
end

-- 相当于 a or b or c, 不过只判断 nil
--[[
    一个典型的例子是：读取配置。
    local cfg = require("lib.config")
    local defaultCfg = require("plugins.abcd.defaultconfig")
    local foobar = getDefaultValue(
        table.readDeep(cfg, "abcd.hello.world"), 
        table.readDeep(defaultCfg, "hello.world"), 
        "defaultValue"
    )
]]--
function getDefaultValue(...)
    local i, v
    for i, v in ipairs(arg) do
        if v ~= nil then
            return v
        end
    end
end