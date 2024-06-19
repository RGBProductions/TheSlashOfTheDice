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
   --todo: idk
end

function Cosmetics.ReadEffect(dir)
    --todo: yep
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