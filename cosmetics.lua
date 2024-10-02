Cosmetics = {
    Hats = {},
    Trails = {},
    Effects = {}
}

-- Credit to MichaelEpicA for writing the core functionality for cosmetics

function Cosmetics.ReadHat(dir)
    local hatsettings = json.decode(love.filesystem.read(dir.."/hat.json"))
    local spl = dir:split("/")
    local id = spl[#spl]
    local hat = {
        image = love.graphics.newImage(dir.."/hat.png"),
        anchor = hatsettings.anchor,
        scale = hatsettings.scale
    }
    Cosmetics.Hats[id] = hat
end

function Cosmetics.ReadTrail(dir)
    local trailsettings = json.decode(love.filesystem.read(dir.."/trail.json"))
    local spl = dir:split("/")
    local id = spl[#spl]
    local events = {}
    for i,v in pairs(trailsettings.events) do
        local actions = {}
        for _,v2 in pairs(v.actions) do
            local action = {
                type = v2.type,
                spawnRadius = v2.spawnRadius,
                size = v2.size,
                life = v2.life,
                angle = v2.angle or {0,0},
                velocity = v2.velocity or {0,0},
                image = love.graphics.newImage(dir.."/"..v2.image..".png")
            }
            table.insert(actions,action)
        end
        local event = {name=i, actions=actions}
        events[i] = event
    end
    local icon
    if love.filesystem.getInfo(dir.."/icon.png") then
        icon = love.graphics.newImage(dir.."/icon.png")
    end
    local trail = {events=events,icon=icon}
    Cosmetics.Trails[id] = trail
end

function Cosmetics.ReadEffect(dir)
    local effectSettings = json.decode(love.filesystem.read(dir.."/effect.json"))
    local spl = dir:split("/")
    local id = spl[#spl]
    local events = {}
    for i,v in pairs(effectSettings.events) do
        local actions = {}
        for _,v2 in pairs(v.actions) do
            local action = {
                type = v2.type,
                spawnRadius = v2.spawnRadius,
                size = v2.size,
                life = v2.life,
                amount = v2.amount,
                velocity = v2.velocity or {0,0},
                image = (type(v2.image) == "string") and love.graphics.newImage(dir.."/"..v2.image..".png") or nil
            }
            table.insert(actions,action)
        end
        local event = {name=i, actions=actions}
        events[i] = event
    end
    local icon
    if love.filesystem.getInfo(dir.."/icon.png") then
        icon = love.graphics.newImage(dir.."/icon.png")
    end
    local trail = {events=events,icon=icon}
    Cosmetics.Effects[id] = trail
end

function Cosmetics.Search(dir)
    for _,itm in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local p = dir.."/"..itm
        if love.filesystem.getInfo(p).type == "directory" then
            if love.filesystem.getInfo(p.."/hat.json") then
                Cosmetics.ReadHat(p)
            elseif love.filesystem.getInfo(p.."/trail.json") then
                Cosmetics.ReadTrail(p)
            elseif love.filesystem.getInfo(p.."/effect.json") then
                Cosmetics.ReadEffect(p)
            else
                Cosmetics.Search(p)
            end
        end
    end
end