local base = {}
-- local saori = require("skl.saori")
local chc = require("skl.chc")
local lastClock = os.clock()

function base.log(message, isError)
    local seMessage = message
    if type(message) == "function" then
        local info = debug.getinfo(message)
        message = "{Function} defined in " .. info.source .. " at line " .. 
            info.linedefined
        seMessage = message
    end
    if type(message) ~= "string" then
        seMessage = base.serialize(message)
    end
    if isError then
        seMessage = seMessage .. "\n" .. debug.traceback()
    end
    date = os.date("[%c] ")
    if seMessage:sub(1, 2) == "+ " then
        date = date .. string.format("%.2f", os.clock() - lastClock) .. " "
        seMessage = seMessage:sub(3)
    end
    if seMessage:sub(1, 5) == "-.-- " then
        lastClock = os.clock()
    end
    
    logMessage = date .. string.gsub(seMessage, "\n", "\n" .. date) .. "\n"
    if CONFIG.logFile and (isError or not CONFIG.logOnlyError) then
        FH = io.open((SHIORI_PATH or '') .. CONFIG.logFile, "ab")
        if FH ~= nil then
            FH:write(logMessage)
            io.close(FH)
        end
    end
    if CONFIG.msgBoxWhenError and isError then
        cMsgbox(seMessage)
    end
end

base.log("-------------- Log start --------------")


local function value2str(v)
    local vt = type(v)

    if vt == "nil" then
        return "nil"
    end
    if vt == "number" then
        return string.format("%d", v)
    end;
    if vt == "string" then
        tmp = string.format("%s", v)
        tmp = string.gsub(tmp, "\\", "\\\\")
        tmp = string.gsub(tmp, "\a", "\\a")
        tmp = string.gsub(tmp, "\b", "\\b")
        tmp = string.gsub(tmp, "\f", "\\f")
        tmp = string.gsub(tmp, "\n", "\\n")
        tmp = string.gsub(tmp, "\r", "\\r")
        tmp = string.gsub(tmp, "\t", "\\t")
        tmp = string.gsub(tmp, "\v", "\\v")
        tmp = string.gsub(tmp, "\"", "\\\"")
        tmp = string.gsub(tmp, "\'", "\\\'")
        return "\"" .. tmp .. "\""
    end;
    if vt == "boolean" then
        if v == true then
            return "true"
        else
            return "false"
        end
    end
    if vt == "function" then
        return '"*function"'
    end
    if vt == "thread" then
        return '"*thread"'
    end
    if vt == "userdata" then
        return '"*userdata"'
    end
    return '"UnsupportFormat"'
end

local function field2str(v)
    local vt = type(v)

    if vt == "number" then
        return string.format("[%d]", v)
    end
    if vt == "string" then
        tmp = string.format("%s", v)
        tmp = string.gsub(tmp, "\\", "\\\\")
        tmp = string.gsub(tmp, "\a", "\\a")
        tmp = string.gsub(tmp, "\b", "\\b")
        tmp = string.gsub(tmp, "\f", "\\f")
        tmp = string.gsub(tmp, "\n", "\\n")
        tmp = string.gsub(tmp, "\r", "\\r")
        tmp = string.gsub(tmp, "\t", "\\t")
        tmp = string.gsub(tmp, "\v", "\\v")
        tmp = string.gsub(tmp, "\"", "\\\"")
        tmp = string.gsub(tmp, "\'", "\\\'")
        return "[\"" .. tmp .. "\"]" end
    return 'UnknownField'
end

function base.serialize(t, level)
    local f, v, buf
    level = level or 0
    if type(t) ~= "table" then
        return value2str(t)
    end
    buf = ""
    f, v = next(t, nil)
    while f do
        if buf ~= "" then
            buf = buf .. ",\n"
        end
        if type(v) == "table" then
            buf = buf .. string.rep("  ", level) .. field2str(f) .. " = " .. base.serialize(v, level + 1)
        else
            buf = buf .. string.rep("  ", level) .. field2str(f) .. " = " .. value2str(v, level + 1)
        end
        f, v = next(t, f)
    end
    buf = "{\n" .. buf .. "\n" .. string.rep("  ", level - 1) .. "}"
    return buf
end

local function replaceVars(str, tbl)
    retstr = str
    if tbl == nil or retstr == nil then
        return retstr
    end
    for key, value in pairs(tbl) do
        if type(value) ~= "string" then
            value = value2str(value) or ""
        end
        retstr = string.gsub(retstr, "%%%(" .. key .. "%)", value)
    end
    return retstr
end

-- auto detect function, table or string; auto replace with data
function base.reply(x, tbl)
    rettbl = {}
    if type(x) == "function" then
        f, rettbl = pcall(x, tbl)
        if f then
            return base.reply(rettbl, tbl)
        else
            log("Error when reply using function: " .. rettbl)
            log(x)
        end
        return nil
    end
    if type(x) == "string" then
        x = {Value = x}
    end
    if type(x) == "table" then
        if #x > 0 then
            local choose = x[math.random(#x)]
            return base.reply(choose, tbl)
        else
            rettbl = x
            rettbl.Value = replaceVars(rettbl.Value, tbl)
            rettbl.Value = replaceVars(rettbl.Value, SYSTEMFUNC)
            rettbl.Value = replaceVars(rettbl.Value, USERFUNC)
            rettbl.Value = replaceVars(rettbl.Value, LOCALDATA)
            rettbl.Value = replaceVars(rettbl.Value, SAVEDATA)
        end
    end
    -- if SAVEDATA.simplifiy == "chs" then
    --    rettbl.Value = saori.call("ChConverter", "simplified", rettbl.Value).result
    -- end
    rettbl.Value = chc.convert(SAVEDATA.simplifiy or "cht", rettbl.Value)
    return rettbl
end

function base.getValue(x, tbl)
    return base.reply(x, tbl).Value
end

function base.unserialize(string)
    local data = loadstring(string)
    status, ret = pcall(data)
    if status then
        return ret
    else
        return nil
    end
end

function base.urlList(tbl)
	local retstr = ""
	for k, line in ipairs(tbl) do
		for i = 1, 3 do
            line[i] = line[i] or ""
        end
        
		retstr = retstr .. line[1] .. string.char(1) .. 
            line[2] .. string.char(1) .. 
            line[3] .. string.char(2)
	end
	return {Value = retstr}
end

return base