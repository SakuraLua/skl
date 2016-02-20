local dict = {}
dict.log = log
dict.setValue = function(field, referenceNum, valueName)
    valueName = valueName or "SAVEDATA"
    return function(req)
        _G[valueName] = _G[valueName] or {}
        if type(_G[valueName]) ~= "table" then
            log("set " .. valueName .. " to " .. req["Reference" .. referenceNum])
            _G[valueName] = req["Reference" .. referenceNum]
        else
            log("set " .. valueName .. "." .. field .. " to" .. req["Reference" .. referenceNum])
            _G[valueName][field] = req["Reference" .. referenceNum]
        end
    end
end
return dict