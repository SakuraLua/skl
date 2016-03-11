require("alien")

local saori = {}
local saoriStor = {}

local function loadSaori(filename)
    filename = SHIORI_PATH_ANSI .. filename
    local pathName = filename:gmatch("(.*[/\\]).*$", "")()
    local libSr = alien.load(filename)
    libSr.load:types("char", "string", "long") -- (bool) load(module_path, length)
    libSr.unload:types("char") -- (bool) unload()
    libSr.request:types("string", "string", "ref int") -- (bool) request(req, length)
    if libSr.load(pathName, pathName:len()) then
        log("saori " .. filename .. " loaded.")
        return libSr
    else
        error("saori `load` failed: " .. filename)
    end
end


local function parse(req)
    local saoriLines = req:split("\r\n")
    if not saoriLines[1]:gmatch("SAORI/1%.%d 200")() then
        error("Saori error " .. saoriLines)
    end
    local saoriResult = {}
    for i = 2, #saoriLines do
        local k, v = saoriLines[i]:gmatch("([^:]*): (.*)$")()
        if k and v then
            saoriResult[k:lower()] = v
        end
    end
    return saoriResult
end

local function request(saori, ...)
    local reqStr = "EXECUTE SAORI/1.1\r\nCharset: UTF-8\r\n"
    local args = {...}
    for i = 1, #args do
        reqStr = reqStr .. "Argument" .. (i - 1) .. ": " .. args[i] .. "\r\n"
    end
    reqStr = reqStr .. "\r\n\r\n"
    return parse(saori.request(reqStr, reqStr:len()))
end

function saori.init()
    -- 初始化；加载需要自动加载的 saori
    for k, v in pairs(CONFIG.saori) do
        local sr = {
            path = v.path,
            alien = nil
        }
        if v.preload then
            sr.alien = loadSaori(v.path)
        end
        saoriStor[k] = sr
    end
end

function saori.term()
    -- 卸载已经加载的 saori
    for k, v in pairs(saoriStor) do
        if v.alien then
            v.alien.unload()
            log("saori " .. k .. " unloaded.")
        end
        v.alien = nil
    end
end

function saori.call(saoriName, ...)
    local sr = saoriStor[saoriName]
    if not sr then
        error("No saori named " .. saoriName .. ", add in your config.lua first!")
    end
    if not sr.alien then
        -- load saori
        sr.alien = loadSaori(sr.path)
    end
    return request(sr.alien, ...)
end

return saori