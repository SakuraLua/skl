require "lfs"

local plugins = {}
local dict = require("lib.skl.dict")

function plugins.load_all()
    lfs.chdir(SHIORI_PATH_ANSI)
    for entry in lfs.dir("plugins") do
        -- ignore . , .. , and files start with _
        if entry ~= "." and entry ~= ".." and (not(entry:match('^_'))) then
            local fullFilename = "plugins/" .. entry
            local attr = lfs.attributes(fullFilename)
            local plugin = false
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
                -- plugin dir
                plugin = "plugins." .. entry .. ".index"
                log("Loading plugin: " .. plugin .. " ...")
                -- try to load dict
                local dictDir = fullFilename .. "/dict"
                local dictAttr = lfs.attributes(dictDir)
                --if dictAttr and dictAttr.mode == "directory" then
                    -- check if dict is exists
                    local dictKey = entry:lower()
                    log("Try to load dict for " .. plugin .. " ...")
                    if not(DICT[dictKey]) then
                        -- build new dict table
                        DICT[dictKey] = {}
                        dict.loadDict(dictDir, DICT[dictKey])
                    end
                --end
                local status, err = pcall(require, plugin)
                if status then -- success
                    log(plugin .. " loaded.")
                else
                    log(plugin .. " load failed.")
                    log(err)
                end
            end
        end
    end
end

return plugins