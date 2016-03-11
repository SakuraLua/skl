--[[
# 加载辞书文件
本库将遍历 `dict` 文件夹，加载辞书到 DICT 变量中。
]]--
require "lfs"
local dictFunc = require("ai.dict")
local base = require("skl.base")

local function parseDict(fileContent, fileName)
    -- normalize
    fileContent = fileContent:gsub("\r\n", "\n")
    fileContent = fileContent:gsub("\r", "\n")
    local dictbl = fileContent:split("\n")
    local rettbl = {}
    local combine = nil
    -- loop over tbl
    local i
    local status = ""
    local evalStr = ""
    for i = 1, #dictbl do
        local str = dictbl[i]
        local context = "\n .. in dict file: " .. fileName
        context = context .. "\n .. Line " .. i
        
        -- for debug use
        if false then
            log("> Line: " .. str)
            log("> Status: " .. status .. context)
            -- log(rettbl)
            log("-------------------------------")
        end
        
        if str == "" then
            -- ignore empty string
        elseif status == "" then
            -- nil status
            -- check first char
            local firstChar = str:sub(1, 1)
            if firstChar == '\\' then
                -- sakura script
                table.insert(rettbl, str)
            elseif firstChar == '#' then
                -- comment
            elseif str == "--" then
                -- combine
                combine = combine or {}
                table.insert(combine, rettbl)
                rettbl = {}
            elseif str == ";EVAL" then
                -- lua immediately excute script
                status = "EVAL"
                evalStr = ""
            elseif str == ";FUNC" then
                -- lua function
                status = "FUNC"
                evalStr = ""
            elseif firstChar == "!" then
                -- dict call
                local expr = str:sub(2)
                local exprTable = expr:split(',')
                local funcName = exprTable[1] or 'nil'
                if #exprTable > 0 and dictFunc[funcName] then
                    ss, res = pcall(dictFunc[funcName], select(2, unpack(exprTable)))
                    if ss and res then
                        table.insert(rettbl, res)
                    elseif ss then
                        log("No retrun value." .. context)
                    else
                        log("Error calling dict function: " .. res .. context, true)
                    end
                else
                    log("No dict function " .. funcName .. "." .. context, true)
                end
            elseif firstChar == ":" then
                -- dict function
                local expr = str:sub(2)
                if dictFunc[expr] then
                    table.insert(rettbl, dictFunc[expr])
                else
                    log("No dict function " .. expr .. context, true)
                end
            elseif str == '"' then
                -- multiline
                status = "MULT"
                evalStr = ""
            else
                -- all others treated like sakura script with \0
                table.insert(rettbl, "\\0" .. str .. "\\e")
            end
        elseif status == "EVAL" or status == "FUNC" then
            -- eval status
            if str == ";END" then
                ret, err = loadstring(evalStr)
                if type(ret) == "function" then
                    if status == "EVAL" then
                        local ss, line = pcall(ret)
                        if ss and line then
                            table.insert(rettbl, line)
                        elseif ss then
                            log("No return value." .. context)
                        else
                            log("Error when calling script: " .. err .. context, true)
                        end
                    elseif status == "FUNC" then
                        -- keep function
                        table.insert(rettbl, ret)
                    end
                else
                    log("Not function: " .. err .. context, true)
                end
                status = ""
                evalStr = ""
            else
                evalStr = evalStr .. "\n" .. str
            end
        elseif status == "MULT" then
            if str == '"' then
                table.insert(rettbl, evalStr)
                status = ""
                evalStr = ""
            else
                evalStr = evalStr .. str
            end
        end
    end
    
    if combine then
        table.insert(combine, rettbl)
        -- 有联合语法
        return function(tbl)
            local i
            local result = ""
            for i = 1, #combine do
                local subValue = base.reply(combine[i], tbl)
                if subValue and subValue.Value then
                    subValue = subValue.Value
                else
                    subValue = ""
                end
                
                -- deal with \e
                subValue = subValue:gsub("\\e$", "")
                result = result .. subValue
            end
            return result
        end
    end
    
    return rettbl
end

local function loadDict(loadDir, saveDict)
    local dictDir = CONFIG.dictDir
    if loadDir ~= nil then
        dictDir = loadDir
    end
    dictDir = SHIORI_PATH_ANSI .. dictDir
    local dictReg = "^(.*)%." .. CONFIG.dictExt .. "$"
    DICT = DICT or {}
    local function loopDir(dir, table)
        for entry in lfs.dir(dir) do
            local eKey = entry:lower()
            if entry ~= "." and entry ~= ".." then -- ignore . and ..
                local fullFilename = dir .. "/" .. entry
                local attr = lfs.attributes(fullFilename)
                local mode = nil
                -- 兼容 lfs 无法获取目录
                if attr ~= nil and attr.mode ~= nil then
                    mode = attr.mode
                else
                    local f = io.open(fullFilename)
                    if f then
                        mode = "file"
                        f:close()
                    else
                        mode = "directory"
                    end
                end
                if mode == "directory" then
                    table[eKey] = table[eKey] or {}
                    loopDir(fullFilename, table[eKey])
                elseif mode == "file" then
                    -- check if it is tdc file
                    local name = string.match(entry, dictReg)
                    if name ~= nil then
                        name = name:lower()
                        local f, err = io.open(fullFilename, 'r')
                        if f == nil then
                            log("Dict " .. fullFilename .. "open failed.\n" .. err, true)
                        else
                            fileContent = f:read("*all")
                            table[name] = parseDict(fileContent, fullFilename)
                        end
                    end
                end
            end
        end
    end
    if type(saveDict) == "table" then
        loopDir(dictDir, saveDict)
    else
        loopDir(dictDir, DICT)
    end
    log("dict loaded.")
end

return {
    loadDict = loadDict,
    parseDict = parseDict
}
