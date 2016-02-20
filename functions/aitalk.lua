local aitalk = {}
local ai = require("ai")
local base = require("skl.base")

function aitalk.init()
    ai.respond("OnSecondChange", function ()
        local iSeconds = SAVEDATA.aiTalkInterval + 0
        if iSeconds == nil or iSeconds <= 0 then
            -- 沉默
            return nil
        end
        if math.fmod(os.time(), iSeconds) == 0 then
            -- 说话
            return ai.execute("OnAITalk")
        end
        return nil
    end)
    ai.respond("OnAITalk", function ()
        aitalk.lastTalk = base.reply(DICT.events.onaitalk).Value
        return aitalk.lastTalk
    end)
    ai.respond("FuncAiTalkLastTalk", function ()
        return aitalk.lastTalk
    end)
end

return aitalk