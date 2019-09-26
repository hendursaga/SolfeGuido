
local Config = {}


function Config.parse()
    local conf = {}
    if love.filesystem.getInfo(assets.config.configSave) then
        conf = love.filesystem.load(assets.config.configSave)()
        for k,v in pairs(conf) do
            Config[k] = v
        end
    else
        conf = assets.config.userPreferences
        for k,v in pairs(conf) do
            Config[k] = v[1]
        end
    end

end

function Config.save()
    local elems = {"return {"}
    for k,v in pairs(Config) do
        if type(v) ~= "function" then
            v = type(v) == 'string' and "'" .. v .. "'" or tostring(v)
            elems[#elems+1] = k .. ' = ' .. v .. ','
        end
    end
    elems[#elems+1] = '}'

    local total = table.concat(elems, '\n')
    love.filesystem.write(assets.config.configSave , total)
end




return Config