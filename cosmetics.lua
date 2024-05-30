Cosmetics = {
    Hats = {},
    Trails = {},
    Effects = {}
}

function Cosmetics.ReadHat(dir)
end

function Cosmetics.ReadTrail(dir)
end

function Cosmetics.ReadEffect(dir)
end

function Cosmetics.Search(dir)
    for _,itm in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local p = dir.."/"..itm
        if love.filesystem.getInfo(p).type == "directory" then
            if love.filesystem.getInfo(p.."/hat.json") then
                Cosmetics.ReadHat(dir)
            elseif love.filesystem.getInfo(p.."/trail.json") then
                Cosmetics.ReadTrail(dir)
            elseif love.filesystem.getInfo(p.."/effect.json") then
                Cosmetics.ReadEffect(dir)
            else
                Cosmetics.Search(p)
            end
        end
    end
end