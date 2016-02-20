local shiori = {}
local base = require("skl.base")
local runtime = require("skl.runtime")
local ai = require("ai")

local function createResonse(tbl)
    local ret = ""
    local Charset = "UTF-8"
    if tbl ~= nil then
        for key, value in pairs(tbl) do
            ret = ret .. key .. ": " .. value .. "\r\n"
        end
    end
    if ret == "" then
        return "SHIORI/3.0 204 No Content\r\nCharset: " .. Charset .. "\r\nSender: " .. CONFIG.shiori.sender .. "\r\n\r\n"
    end
    return "SHIORI/3.0 200 OK\r\n" .. ret .. "Charset: " .. Charset .. "\r\nSender: " .. CONFIG.shiori.sender .. "\r\n\r\n"
end

-- SHIORI load
function shiori.load(shiori_path)
    log("-.-- shiori load start.")
    math.randomseed(SKL_BOOT_TIME)

    -- init for basic variables
    local savefilename = SHIORI_PATH .. CONFIG.saveDataFile
    local FH = io.open(savefilename, "r")
    SAVEDATA = nil
    if FH ~= nil then
        local string = FH:read("*all")
        SAVEDATA = base.unserialize(string)
        FH:close()
    end
    if SAVEDATA == nil then
        SAVEDATA = CONFIG.defaultSaveData
        SAVEDATA.sum_sec = 0
        SAVEDATA.aiTalkInterval = "60"
        SAVEDATA.simplifiy = "cht"
    end
    
    require("skl.chc").init()
    require("skl.saori").init()
    
    f = pcall(shiori_init)
    log("+ shiori load finished.")
    return true
end

-- SHIORI unload
function shiori.unload()
    log("-.-- shiori unload start.")
    -- final process
    f = pcall(shiori_uninit)
    
    require("skl.saori").term()
    require("skl.chc").term()
    require("skl").saveData()
    
    collectgarbage("collect")
    collectgarbage("collect")
    
    log("+ shiori unload finished.")
    return true
end

-- parse request
local function reqparse(str)
    local c = 0
    local rettbl = {}
    for line in string.gmatch(str, "[^\r\n]+\r\n") do
        if c == 0 then
            rettbl.command, rettbl.version = string.gmatch(line, "(.+) (SHIORI.+)") ()
        else
            k, v = string.gmatch(line, "(.+): (.+)\r\n") ()
            if k ~= nil then
                rettbl[k] = v
            end
        end
        c = c + 1
    end
    return rettbl
end

-- SHIORI request
function shiori.request(str)
    local a = reqparse(str)
    local rettbl = ai.handle(a)

    retstr = createResonse(rettbl)
    return retstr
end

return shiori