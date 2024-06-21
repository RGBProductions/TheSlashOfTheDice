Cosmetics = {
    Hats = {},
    Trails = {},
    Effects = {}
}

function Cosmetics.ReadHat(dir)
   local hatsettings = json.decode(love.filesystem.read(dir.."/hat.json"))
   local id = dir:split("/")[4]
   local hat = {
    image = love.graphics.newImage(dir.."/hat.png"),
    anchor = hatsettings.anchor,
    scale = hatsettings.scale
   }
   print("print"..id)
   Cosmetics.Hats[id] = hat
end

function Cosmetics.ReadTrail(dir)
    local trailsettings = json.decode(love.filesystem.read(dir.."/trail.json"))
    local id = dir:split("/")[4]
    local events = {}
    for i,v in pairs(trailsettings.events) do
        local actions = {}
        for _,v2 in pairs(v.actions) do
            local action = {
                type = v2.type,
                spawnRadius = v2.spawnRadius,
                size = v2.size,
                life = v2.life,
                velocity = v2.velocity or {0,0},
                image = love.graphics.newImage(dir.."/"..v2.image..".png")
            }
            table.insert(actions,action)
        end
        local event = {name=i, actions=actions}
        events[i] = event
    end
    local trail = {events=events}
    Cosmetics.Trails[id] = trail
end

function Cosmetics.ReadEffect(dir)
    --todo: yep
    local effectSettings = json.decode(love.filesystem.read(dir.."/effect.json"))
    local id = dir:split("/")[4]
    local events = {}
    for _,v in ipairs(effectSettings.events) do
        local actions = {}
        for _,v2 in ipairs(v.actions) do
            local action = {
                type = v2.type,
                spawnRadius = v2.spawnRadius,
                velocity = v2.velocity,
                size = v2.size,
                amount = v2.amount,
                life = v2.life,
                image = love.graphics.newImage(dir.."/"..v2.image..".png")
            }
            table.insert(actions,action)
        end
        local event = {name=v.name, actions=actions}
        events[v.name] = event
    end
    local trail = {events=events}
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