local choice = {}
local ai = require("ai")

function choice.init()
    ai.respond("OnChoiceSelect", function(req)
        -- check choice functions
        if choice[req.Reference0] then
            return choice[req.Reference0]
        end
        -- check choice scripts
        local func = ai.loadScript("choices/" .. req.Reference0)
        if func then
            return func
        end
        -- check choice dicts
        if DICT.choices[req.Reference0:lower()] then
            return DICT.choices[req.Reference0:lower()]
        end
        return ai.execute(refUnpack(req))
    end)
end

return choice