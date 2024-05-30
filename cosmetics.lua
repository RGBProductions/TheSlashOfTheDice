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