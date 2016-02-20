local base = require("skl.base")
local shiori = require("skl.shiori")

log = base.log

function load(shiori_path)
    local status, ret = pcall(shiori.load, shiori_path)
    if status then
        return ret
    else
        log("Load error: " .. ret, true)
        return false
    end
end

function unload()
    local status, ret = pcall(shiori.unload)
    if status then
        return ret
    else
        log("Unload error: " .. ret, true)
        return false
    end
end

function request(str)
    local status, ret = pcall(shiori.request, str)
    if status then
        return ret
    else
        log("Request error: " .. ret, true)
        return ""
    end
end

-- define all global variables
SKL_BOOT_TIME = SKL_BOOT_TIME or os.time()
SAVEDATA = SAVEDATA or {}
LOCALDATA = LOCALDATA or {}
USERFUNC = USERFUNC or {}
SYSTEMFUNC = SYSTEMFUNC or {}