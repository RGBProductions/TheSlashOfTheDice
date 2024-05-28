Achievements = {
    Achievements = {},
    Order = {}
}

function Achievements.Register(id, maxProgress, hidden)
    table.insert(Achievements.Order, id)
    Achievements.Achievements[id] = {maxProgress = maxProgress, progress = 0, hidden = hidden}
    if love.filesystem.getInfo("assets/images/achievements/" .. id .. ".png") then
        Achievements.Achievements[id].icon = love.graphics.newImage("assets/images/achievements/" .. id .. ".png")
    else
        Achievements.Achievements[id].icon = love.graphics.newImage("assets/images/achievements/missing.png")
    end
end

function Achievements.Load(path)
    local s = love.filesystem.read(path)
    local lines = s:split("\n")
    for _,line in ipairs(lines) do
        if #line == 0 then
            goto continue
        end
        local spl = line:split(" ")
        local id = spl[1]
        if Achievements.Achievements[id] then
            local progress = tonumber(spl[2])
            Achievements.Achievements[id].progress = math.min(Achievements.Achievements[id].maxProgress, progress)
        end
        ::continue::
    end
end

function Achievements.Save(path)
    local s = ""
    for id,ach in pairs(Achievements.Achievements) do
        s = s .. id .. " " .. ach.progress .. "\n"
    end
    love.filesystem.write(path, s)
end

function Achievements.Advance(id)
    local event = {
        id = id,
        amount = 1,
        total = ((Achievements.Achievements[id] or {}).progress or 0) + 1,
        cancelled = false,
    }
    Events.fire("achievementAdvance", event)
    if not event.cancelled then
        local a = Achievements.Achievements[id]
        if a then
            local prev = a.progress
            a.progress = math.min(a.maxProgress, a.progress + 1)
            if a.progress >= a.maxProgress and prev < a.maxProgress then
                Events.fire("achievementUnlocked", {id = id})
                Achievements.Save("achievements.txt")
                UnlockAchievement(id)
                return true
            end
        end
    end
    return false
end

function Achievements.SetMax(id, progress)
    local event = {
        id = id,
        amount = math.max((Achievements.Achievements[id] or {}).progress or 0, progress) - (Achievements.Achievements[id] or {}).progress,
        total = math.max((Achievements.Achievements[id] or {}).progress or 0, progress),
        cancelled = false,
    }
    Events.fire("achievementAdvance", event)
    if not event.cancelled then
        local a = Achievements.Achievements[id]
        if a then
            local prev = a.progress
            a.progress = math.min(a.maxProgress,math.max(progress,a.progress))
            if a.progress >= a.maxProgress and prev < a.maxProgress then
                Events.fire("achievementUnlocked", {id = id})
                Achievements.Save("achievements.txt")
                UnlockAchievement(id)
                return true
            end
        end
    end
    return false
end

function Achievements.IsUnlocked(id)
    local a = Achievements.Achievements[id]
    if a then
        return a.progress >= a.maxProgress
    end
    return false
end

Achievements.Register("complete_tutorial", 1)
Achievements.Register("complete_tutorial_5", 5)
Achievements.Register("complete_tutorial_10", 10)
Achievements.Register("default_6_waves", 6)
Achievements.Register("default_10_waves", 10)
Achievements.Register("default_30_waves", 30)
Achievements.Register("max_attack", 150)
Achievements.Register("max_defense", 150)
Achievements.Register("max_luck", 90)
Achievements.Register("max_stats", 390)
Achievements.Register("low_defense", 1)
Achievements.Register("die_early", 1)
Achievements.Register("die_tutorial", 1)

Achievements.Register("no_movement", 1, true)
Achievements.Register("sus", 1, true)
Achievements.Register("extreme_luck", 5, true)
Achievements.Register("singularity", 50, true)
Achievements.Register("default_50_waves", 50, true)
Achievements.Register("hackerman", 1, true)
