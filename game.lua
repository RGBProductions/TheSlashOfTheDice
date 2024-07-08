Game = {
    Die = {},
    Entity = {},
    Particle = {}
}

function Game.Die:new(delay,number)
    local pool = GetPoolByID(Settings["gameplay"]["dice_mode"])
    local d = {}
    d.rollIter = -(delay or 0)
    d.time = 0
    d.number = pool.Die[love.math.random(1,#pool.Die)]
    d.finalNumber = number or pool.Die[love.math.random(1,#pool.Die)]
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
    local die = GetPoolByID(Settings["gameplay"]["dice_mode"]).Die
    if not self.doneRolling then
        self.time = self.time + dt
        if self.time >= 0.125 then
            self.number = die[love.math.random(1,#die)]
            self.rollIter = self.rollIter + 1
            self.time = 0
        end
        if self.rollIter > 8 then
            self.doneRolling = true
            self.number = self.finalNumber
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

function Game.Entity:destroy()
    local i = table.index(Entities, self)
    if i then
        table.remove(Entities, i)
    end
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
    elseif (EntityTypes[self.id] or {}).update ~= nil then
        (EntityTypes[self.id] or {}).update(self, dt)
    end
    self.invincibility = self.invincibility - dt
end

function Game.Entity:keypressed(k)
    if self.callbacks["keypressed"] ~= nil then
        self.callbacks["keypressed"](self, k)
    elseif (EntityTypes[self.id] or {}).keypressed ~= nil then
        (EntityTypes[self.id] or {}).keypressed(self, k)
    end
end

function Game.Entity:mousepressed(x, y, b)
    if not self.callbacks["mousepressed"] then return end
    self.callbacks["mousepressed"](self, x, y, b)
end


function Game.Particle:new(x, y, lifespan, vx, vy, damp, size, angle)
    local o = {}
    o.x = x
    o.y = y
    o.vx = vx or 0
    o.vy = vy or 0
    o.size = size or 1
    o.damp = damp or 5
    o.angle = angle or 0
    o.lifespan = lifespan or 0.5
    o.time = love.timer.getTime()

    setmetatable(o, self)
    self.__index = self
    return o
end

function Game.Particle:update(dt)
    local blendAmt = 1/((self.damp/(self.damp-1))^60)
    local blend = math.pow(blendAmt,dt)
    self.vx = self.vx*blend
    self.vy = self.vy*blend
    self.x = self.x + self.vx*dt*60
    self.y = self.y + self.vy*dt*60
end