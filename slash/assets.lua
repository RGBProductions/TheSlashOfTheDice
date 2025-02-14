Slash.Assets = {}

local imagePointers = {}
local imageCache = {}

function Slash.Assets.PreloadImage(name,path)
    imagePointers[name] = path
end

function Slash.Assets.GetImage(name)
    if imageCache[name] then
        return imageCache[name]
    end
    if not imagePointers[name] then
        return nil
    end
    if love.filesystem.getInfo(imagePointers[name]) then
        imageCache[name] = love.graphics.newImage(imagePointers[name])
    end
    return imageCache[name]
end

function Slash.Assets.ClearImages()
    imageCache = {}
end

local audioPointers = {}
local audioCache = {}

function Slash.Assets.PreloadAudio(name,path)
    audioPointers[name] = path
end

function Slash.Assets.GetAudio(name)
    if audioCache[name] then
        return audioCache[name]
    end
    if not audioPointers[name] then
        return nil
    end
    if love.filesystem.getInfo(audioPointers[name]) then
        audioCache[name] = love.audio.newSource(audioPointers[name], "stream")
    end
    return audioCache[name]
end

function Slash.Assets.ClearAudio()
    audioCache = {}
end