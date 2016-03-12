local function init()
    local config = require("config")
    CONFIG = config -- register global config table
    if config.mobDebug then
        require("lib.mobdebug").start() -- start mobDebug session
    end
    require("lib.shiori_base")
    require("skl.dict").loadDict()
    require("functions.aitalk").init()
    require("functions.menu").init()
    require("functions.choice").init()
    require("functions.debugmenu").init()
    JSON = require("lib.JSON")
end

local function extend(source, attr, callback)
    local origin = source[attr]
    local function extendedFunc(...)
        local oRet = {origin(...)}
        return callback(oRet, ...)
    end
    source[attr] = extendedFunc
end

local function override(source, attr, callback)
    local origin = source[attr]
    local function overridedFunc(...)
        return callback(origin, ...)
    end
    source[attr] = overridedFunc
end

local function loadData()
    local savefilename = SHIORI_PATH_ANSI .. CONFIG.saveDataFile
    local FH = io.open(savefilename, "r")
    SAVEDATA = nil
    if FH ~= nil then
        local str = FH:read("*all")
        if string.len(str) < string.len("return ") then
            -- try to load from backup
            FH:close()
            FH = io.open(savefilename .. ".bak", "r")
            str = FH:read("*all")
        end
        SAVEDATA = require("skl.base").unserialize(str)
        FH:close()
    end
    if SAVEDATA == nil then
        SAVEDATA = CONFIG.defaultSaveData
        SAVEDATA.sum_sec = 0
        SAVEDATA.aiTalkInterval = "60"
        SAVEDATA.simplifiy = "cht"
    end
end

local function saveData()
    -- save "SAVEDATA" to disk
    if type(SAVEDATA) ~= "table" then
        return false
    end
    
    -- backup old file in case of write errors
    local FH = io.open(SHIORI_PATH_ANSI .. CONFIG.saveDataFile, "r")
    if FH ~= nil then
    local content = FH:read("*all")
        if string.len(content) > string.len("return ") then
            local WH = io.open(SHIORI_PATH_ANSI .. CONFIG.saveDataFile .. ".bak", "w")
            if WH ~= nil then
                WH:write(content)
                io.close(WH)
            end
        end
        io.close(FH)
    end
    
    FH = io.open(SHIORI_PATH_ANSI .. CONFIG.saveDataFile, "w")
    if FH ~= nil then
        SAVEDATA["sum_sec"] = require("skl.runtime").sum_sec()
        FH:write("return " .. require("skl.base").serialize(SAVEDATA, 1));
        io.close(FH)
    end
end

return {
    init = init,
    extend = extend,
    override = override,
    loadData = loadData,
    saveData = saveData
}