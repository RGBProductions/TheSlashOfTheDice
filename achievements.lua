Achievements = {
    Achievements = {},
    Order = {}
}

function Achievements.Register(id, name, description, maxProgress, hidden)
    table.insert(Achievements.Order, id)
    Achievements.Achievements[id] = {name = name, description = description, maxProgress = maxProgress, progress = 0, hidden = hidden}
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
        local progress = tonumber(spl[2])
        Achievements.Achievements[id].progress = math.min(Achievements.Achievements[id].maxProgress, progress)
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

Achievements.Register("complete_tutorial", "Certified Slasher", "Complete the tutorial.", 1)
Achievements.Register("complete_tutorial_5", "I am worthy!", "Complete the tutorial 5 times.", 5)
Achievements.Register("complete_tutorial_10", "Okay, that's enough", "Complete the tutorial 10 times.", 10)
Achievements.Register("default_6_waves", "A Die's Worth", "Defeat 6 waves in Default.", 6)
Achievements.Register("default_10_waves", "Count on Two Hands", "Defeat 10 waves in Default.", 10)
Achievements.Register("default_30_waves", "Unstoppable", "Defeat 30 waves in Default.", 30)
Achievements.Register("rocket_enemy", "KABOOM!", "Experience the wrath of the rocket enemy.", 1)
Achievements.Register("rocket_defeat_enemy", "Right Back At You", "Blow up a rocket enemy with its own rocket.", 1)
Achievements.Register("rocket_defeat_multiple", "Group Hug", "Blow up three or more rocket enemies with one rocket.", 3)
Achievements.Register("max_attack", "Iron Fist", "Reach the maximum of 150 Attack.", 150)
Achievements.Register("max_defense", "Immovable", "Reach the maximum of 150 Defense.", 150)
Achievements.Register("max_luck", "Four-Leaf", "Reach the maximum of 90 Luck.", 90)
Achievements.Register("max_stats", "A True Force", "Reach the maximum in all three stats.", 390)
Achievements.Register("low_defense", "Deteriorated", "Fall below 1 Defense.", 1)
Achievements.Register("die_early", "How Did That Happen", "Die with a score of 0.", 1)
Achievements.Register("die_tutorial", "Pathetic", "Die in the tutorial.", 1)

Achievements.Register("no_movement", "Menacing Aura", "Defeat a wave without using WASD.", 1, true)
Achievements.Register("nothing_1_hr", "Couch Potato", "Spend 1 hour on the menu... for some reason.", 3600, true)
Achievements.Register("nothing_2_hr", "BRB Mom's Calling", "Spend 2 hours on the menu... probably AFK.", 7200, true)
Achievements.Register("nothing_10_hr", "Lo-Fi Hip-Hop Beats to Do Nothing to", "Spend 10 hours on the menu... do you really have nothing better to do?", 36000, true)
Achievements.Register("sus", "Something Suspicious", "get out of my head get out of my head get out of my head get out of my head get out of my head", 1, true)
Achievements.Register("extreme_luck", "Rigged", "Roll a 6 five times in a row.", 5, true)
Achievements.Register("singularity", "Singularity", "Wait long enough for 50 enemies to spawn.", 50, true)
Achievements.Register("default_50_waves", "Superhuman", "With all your strength, defeat 50 waves in Default.", 50, true)
Achievements.Register("hackerman", "Hackerman", "Prove you're a skilled programmer by unlocking this achievement.", 1, true)
