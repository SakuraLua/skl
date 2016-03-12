local ai = {}
local base = require("skl.base")
local response = require("ai.response")
local subscribe = require("ai.subscribe")
local skl = require("skl")

local sendQueue = {}

local function getEnv()
    local res = {}
    for k, v in pairs(_G) do
        res[k] = v
    end
    return res
end

local function setFReq(f)
    return function(req)
        local env = getEnv()
        env.req = req
        env.R = req
        return setfenv(f, env)
    end
end

function ai.loadScript(fileName, req)
    local sklEvent = SHIORI_PATH_ANSI .. "skl/scripts/" .. fileName .. ".lua"
    local srEvent = SHIORI_PATH_ANSI .. "scripts/" .. fileName .. ".lua"
    
    local func, x, y = nil, io.open(srEvent), io.open(sklEvent)
    
    if x then
        x:close()
        func = loadfile(srEvent)
    elseif y then
        y:close()
        func = loadfile(sklEvent)
    end
    
    if func then
        return setFReq(func, req)
    else
        return nil
    end
end

function ai.handle(req)
    rettbl = {}
    if not req.ID then
        return rettbl
    end
    
    if req.ID == "OnSecondChange" then
        local dispatch = require("async.dispatch")
        local one = dispatch.process()
        if one ~= nil then
            return base.reply(one)
        end
    end

    -- use second change event to process queue
    if #sendQueue > 0 and req.ID == "OnSecondChange" then
        local r = table.remove(sendQueue, 1)
        return r
    end
    
    -- save user data every minute
    if req.ID == "OnMinuteChange" then
        skl.saveData()
    end
    
    if subscribe[req.ID] then
        subscribe[req.ID](req)
    end
    
    local lowerID = req.ID:lower()
    if response[req.ID] then
        rettbl = base.reply(response[req.ID], req)
    else
        -- check if has event script
        local func = ai.loadScript("events/" .. req.ID)
        
        if func then
            response[req.ID] = func
            rettbl = base.reply(response[req.ID], req)
        elseif DICT.events and DICT.events[lowerID] then
            -- read from dict
            rettbl = base.reply(DICT.events[lowerID], req)
        end
    end
    
    return rettbl
end

function ai.queue(resp)
    table.insert(sendQueue, resp)
end

function ai.subscribe(id, func)
    if not subscribe[id] then
        subscribe[id] = func
    else
        local origin = subscribe[id]
        subscribe[id] = function (req)
            origin(req)
            func(req)
        end
    end
end

function ai.respond(id, func)
    if not response[id] then
        response[id] = func
    else
        local origin = response[id]
        response[id] = function (req)
            local resp = origin(req)
            req.prevResponse = resp
            return func(req)
        end
    end
end

function ai.execute(id, ...)
    local req = {
        ID = id,
        command = "GET"
    }
    local tbl = {...}, i
    for i = 1, #tbl do
        req["Reference" .. (i - 1)] = tbl[i]
    end
    return ai.handle(req)
end

function ai.raise(id, ...)
    local resp = ai.execute(req)
    ai.queue(resp)
end

return ai