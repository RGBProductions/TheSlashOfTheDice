function boom(base, rate, length, volume)
    volume = volume or 1
    local rand = love.math.random(0,1)
    local time = 0
    local dat = love.sound.newSoundData(44100/length,44100,16,1)
    for i=1,dat:getSampleCount()do
        local v = rand
        time = time+1
        if time >= base+(rate*i)then
            rand = love.math.random(0,1)
            time = 0
        end
        dat:setSample(i-1,v*math.max(0,1-(i/44100*length))*volume)
    end
    love.audio.newSource(dat):play()
end

function sweep(base, rate, length, volume)
    volume = volume or 1
    local rand = love.math.random(0,1)
    local time = 0
    local dat = love.sound.newSoundData(44100/length*2,44100,16,1)
    for i=1,dat:getSampleCount()do
        local v = rand
        time = time+1
        if time >= base+(rate*i)then
            rand = love.math.random(0,1)
            time = 0
        end
        dat:setSample(i-1,v*math.max(0,1-(math.abs(i-44100/length)/44100*length))*volume)
    end
    love.audio.newSource(dat):play()
end

function beep(base, rate, length, volume)
    volume = volume or 1
    local dat = love.sound.newSoundData(44100/length,44100,16,1)
    for i=1,dat:getSampleCount() do
        local hl = math.round((math.sin(i/44100*2*math.pi*(base+(i/44100*rate)))+1)/2)*2-1
        dat:setSample(i-1,hl*math.max(0,1-(i/44100*length))*volume)
    end
    love.audio.newSource(dat):play()
end