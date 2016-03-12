local lanes = require("lanes")

local ai = require("ai")
local dispatch = {}

dispatch.queue = {}
function dispatch.enqueue(func, configs)
    assert(type(func) == "function", "You should only enqueue function.")
    configs = configs or {}
    local f = lanes.gen("*", {
        globals = {},
    }, func)
    local h = f()
    local item = {
        handle = h,
        configs = configs
    }
    table.insert(dispatch.queue, item)
    local info = debug.getinfo(2)
    log("Started thread #" .. #dispatch.queue .. " by " .. info.short_src .. ":" .. info.currentline)
end
function dispatch.process()
    local i
    for i = 1, #dispatch.queue do
        local item = dispatch.queue[i]
        local h = item.handle
        log("async dispath thread #" .. i .. ", status: " .. h.status)
        if h.status == "done" or h.status == "error" then
            -- 运行完成，检查结果
            local v, err = h:join()
            table.remove(dispatch.queue, i)
            -- 检查是否为回调类函数
            if type(item.configs.callback) == "function" then
                -- 回调的则执行回调
                item.configs.callback(v, err)
            else
                -- 不是回调的则读出内容反馈给伪 AI
                if err ~= nil then
                    log("A thread faced error: " .. err)
                else
                    return v
                end
            end
        elseif h.status == "waiting" then
            -- 等待 linda
            if type(item.configs.lindaCallback) == "function" then
                item.configs.lindaCallback(h, item.configs)
            else
                -- 没有 linda callback，杀掉线程并给出错误
                h:cancel()
                log("No linda callback for thread #" .. i .. ", killing.")
            end
        elseif h.status == "cancelled" or h.status == "killed" then
            log("thread #" .. i .. " ended.")
            table.remove(dispatch.queue, i)
        end
    end
    return nil
end

return dispatch