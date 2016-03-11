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

local function saveData()
    -- save "SAVEDATA" to disk
    if type(SAVEDATA) ~= "table" then
        return false
    end 
    local FH = io.open(SHIORI_PATH_ANSI .. CONFIG.saveDataFile, "w")
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
    saveData = saveData
}