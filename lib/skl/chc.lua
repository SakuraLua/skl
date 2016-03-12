local chc = {}
local saori = require("skl.saori")
local driver = "opencc"
require "alien"
local ccLib
local ccPointers = {}

function chc.init()
    -- check if ChConverter saori
    if CONFIG.saori.ChConverter then
        driver = "ChConverter"
    end
    if driver == "opencc" then
        -- load opencc
        local ccLibPath = SHIORI_PATH_ANSI .. "skl/opencc/"
        ccLib = alien.load(ccLibPath .. "opencc.dll")
        -- (ptr configPointer) opencc_open(configPath)
        ccLib.opencc_open:types("pointer", "string")
        -- (int status) opencc_close(ptr configPointer)
        ccLib.opencc_close:types("int", "pointer")
        -- (string result) opencc_convert_utf8(ptr configPointer, string in, int length)
        ccLib.opencc_convert_utf8:types("pointer", "pointer", "string", "int")
        -- (void) opencc_convert_utf8_free 	(char *str)
        ccLib.opencc_convert_utf8_free:types("void", "pointer")
        
        -- open config files
        ccPointers.chs = ccLib.opencc_open(ccLibPath .. "tw2sp.json")
        ccPointers.cht = ccLib.opencc_open(ccLibPath .. "s2twp.json")
    end
    log("chc driver: " .. driver)
end

function chc.convert(to, str)
    if to == CONFIG.language then
        return str
    end
    if not str then
        return str
    end
    if driver == "opencc" then
        if ccPointers[to] then
            local ret = ccLib.opencc_convert_utf8(ccPointers[to], str, str:len())
            local str = alien.tostring(ret)
            ccLib.opencc_convert_utf8_free(ret)
            return str
        end
    elseif driver == "ChConverter" then
        local chTo = "simplified"
        if to == "cht" then
            chTo = "traditional"
        end
        return saori.call("ChConverter", chTo, str).result
    end
    return str
end

function chc.term()
    if dirver == "opencc" then
        -- term opencc
        ccLib.opencc_close(ccPointers.chs)
        ccLib.opencc_close(ccPointers.cht)
    end
end

return chc