Game = {
    Die = {},
    Entity = {},
    SlashOrb = {}
}

function Game.Die:new()
    local d = {}
    d.rollIter = 0
    d.time = 0
    d.number = 1
    d.doneRolling = false
    d.timeSinceCompletion = 0

    setmetatable(d, self)
    self.__index = self
    return d
end

function Game.Die:newRoll()
    self.rollIter = 0
    self.time = 0
    self.numberRead = false
end

function Game.Die:update(dt)
    local die = GetPoolByID(Settings["Gameplay"]["Dice Weighing Mode"]).Die
    if Settings["Gameplay"]["Dice Weighing Mode"] == 2 then
        local Stats = player:get("stats")
        die = {}
        -- Calculate Total Statistic Score
        local statscore = (Stats["Attack"]/150)*0.4 + (Stats["Defense"]/150)*0.4 + (Stats["Luck"]/90)*0.2
        local istatscore = 1-statscore
        for n = 1, istatscore*8 do
            table.insert(die, 6)
        end
        for n = 1, istatscore*6 do
            table.insert(die, 5)
        end
        for n = 1, istatscore*4 do
            table.insert(die, 4)
        end
        for n = 1, statscore*8 do
            table.insert(die, 1)
        end
        for n = 1, statscore*6 do
            table.insert(die, 2)
        end
        for n = 1, statscore*4 do
            table.insert(die, 3)
        end
    end
    if not self.doneRolling then
        self.time = self.time + dt
        if self.time >= 0.125 then
            self.number = die[love.math.random(1,#die)]
            self.rollIter = self.rollIter + 1
            self.time = 0
        end
        if self.rollIter > 8 then
            self.doneRolling = true
        end
    else
        self.timeSinceCompletion = self.timeSinceCompletion + dt
    end
end

function Game.Die:getNumber()
    return (self.doneRolling and self.number) or nil
end


function Game.Entity:new(id, x, y, vx, vy, maxhp, callbacks, data)
    local e = {}
    e.id = id
    e.x = x
    e.y = y
    e.vx = vx or 0
    e.vy = vy or 0
    e.hp = maxhp or 100
    e.maxhp = maxhp or 100
    e.invincibility = 0
    e.callbacks = callbacks or {}
    e.data = data or {}

    setmetatable(e, self)
    self.__index = self
    return e
end

function Game.Entity:get(value)
    return self.data[value]
end

function Game.Entity:set(value, new)
    self.data[value] = new
end

function Game.Entity:update(dt)
    if self.callbacks["update"] ~= nil then
        self.callbacks["update"](self, dt)
    end
    self.invincibility = self.invincibility - dt
end

function Game.Entity:keypressed(k)
    if not self.callbacks["keypressed"] then return end
    self.callbacks["keypressed"](self, k)
end

function Game.Entity:mousepressed(x, y, b)
    if not self.callbacks["mousepressed"] then return end
    self.callbacks["mousepressed"](self, x, y, b)
end


function Game.SlashOrb:new(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.time = love.timer.getTime()

    setmetatable(o, self)
    self.__index = self
    return o
end