RocketSprite = love.graphics.newImage("assets/images/entities/rocket.png")

local blendAmt = 1/((5/4)^60)
local tutorialBounds = 1024

local function slash(self,x,y)
    local ax = x-love.graphics.getWidth()/2
    local ay = y-love.graphics.getHeight()/2
    local px = player.x - Camera.x
    local py = player.y - Camera.y
    ax = ax - px
    ay = ay - py
    local m = math.sqrt(ax^2+ay^2)
    if m > 0 then
        ax = ax / m
        ay = ay / m
    end
    if Settings["gameplay"]["auto_aim_on"] then
        local consider = {}
        local t = math.cos(math.rad(Settings["gameplay"]["auto_aim_limit"]))
        for _,entity in ipairs(GetEntitiesWithID("enemy")) do
            local evec = math.norm({entity.x-self.x, entity.y-self.y})
            local svec = {ax,ay}
            if math.dot(evec,svec) >= t then
                table.insert(consider, entity)
            end
        end
        local dist = math.huge
        local ent = 0
        local spos = {x+Camera.x-love.graphics.getWidth()/2,y+Camera.y-love.graphics.getHeight()/2}
        for i,entity in ipairs(consider) do
            local d = math.sqrt((entity.x-spos[1])^2+(entity.y-spos[2])^2)
            if d <= dist then
                dist = d
                ent = i
            end
        end
        if ent ~= 0 then
            local evec = math.norm({consider[ent].x-self.x, consider[ent].y-self.y})
            ax = evec[1]
            ay = evec[2]
        end
    end
    self.vx = self.vx + ax*64
    self.vy = self.vy + ay*64
    self:set("slashTime", 0.25)
    sweep("slash", 1, 0, 32, 0.25*Settings["audio"]["sound_volume"]/100)
    TutorialValues["Slashes"] = TutorialValues["Slashes"] + 1

    if IsMultiplayer then
        Net.Send({type = "slash", vx = self.vx, vy = self.vy})
    end
end

EntityTypes = {
    player = {
        update = function(self, dt)
            self:set("slashTime", self:get("slashTime")-dt)
            self:set("bufferTime", (self:get("bufferTime") or 0)-dt)
            local speed = 2
            local usedWASD = false
            if love.keyboard.isDown("a") then
                self.vx = self.vx - speed * dt * 60
                Moved = true
                usedWASD = true
            end
            if love.keyboard.isDown("d") then
                self.vx = self.vx + speed * dt * 60
                Moved = true
                usedWASD = true
            end
            if love.keyboard.isDown("w") then
                self.vy = self.vy - speed * dt * 60
                Moved = true
                usedWASD = true
            end
            if love.keyboard.isDown("s") then
                self.vy = self.vy + speed * dt * 60
                Moved = true
                usedWASD = true
            end
    
            ---@type love.Joystick
            local joystick = nil
            for _,stick in ipairs(love.joystick.getJoysticks()) do
                if stick:isGamepad() then
                    joystick = stick
                end
            end
    
            if not usedWASD then
                local x = Thumbstick.x/(Thumbstick.outerRad*ViewScale*Settings["video"]["ui_scale"])*speed
                local y = Thumbstick.y/(Thumbstick.outerRad*ViewScale*Settings["video"]["ui_scale"])*speed
                if joystick then
                    x = joystick:getGamepadAxis("leftx")
                    y = joystick:getGamepadAxis("lefty")
                    local m = math.sqrt(x*x+y*y)
                    if m <= 0.2 then
                        x = 0
                        y = 0
                    end
                    x = x*speed
                    y = y*speed
                end
                self.vx = self.vx + x * dt * 60
                self.vy = self.vy + y * dt * 60
                if Thumbstick.x ~= 0 or Thumbstick.y ~= 0 then
                    Moved = true
                end
            end
    
            local blend = math.pow(blendAmt,dt)
            self.vx = blend*(self.vx)
            self.vy = blend*(self.vy)
    
            self.x = self.x + self.vx*dt*60
            if Gamemode == "tutorial" and (self.x < -tutorialBounds or self.x > tutorialBounds) then
                self.x = math.max(-tutorialBounds,math.min(tutorialBounds,self.x))
                self.vx = 0
            end
            for _,entity in ipairs(Entities) do
                if entity ~= self and entity:get("Collision") then
                    local collision = entity:get("Collision")
                    if BoxCollision(self.x-32, self.y-32, 64, 64, entity.x-collision[3]/2+collision[1], entity.y-collision[4]/2+collision[2], collision[3], collision[4]) then
                        if math.sign(self.vx) == 1 then -- Moving right
                            self.x = entity.x+collision[1] - collision[3]/2 + 32
                            self.vx = 0
                        end
                        if math.sign(self.vx) == -1 then -- Moving left
                            self.x = entity.x+collision[1] + collision[3]/2 + 32
                            self.vx = 0
                        end
                    end
                end
            end
            self.y = self.y + self.vy*dt*60
            if Gamemode == "tutorial" and (self.y < -tutorialBounds or self.y > tutorialBounds) then
                self.y = math.max(-tutorialBounds,math.min(tutorialBounds,self.y))
                self.vy = 0
            end
            for _,entity in ipairs(Entities) do
                if entity ~= self and entity:get("Collision") then
                    local collision = entity:get("Collision")
                    if BoxCollision(self.x-32, self.y-32, 64, 64, entity.x-collision[3]/2+collision[1], entity.y-collision[4]/2+collision[2], collision[3], collision[4]) then
                        if math.sign(self.vy) == 1 then -- Moving down
                            self.y = entity.y+collision[2] - collision[4]/2 + 32
                        end
                        if math.sign(self.vy) == -1 then -- Moving up
                            self.y = entity.y+collision[2] + collision[4]/2 + 32
                        end
                    end
                end
            end
    
            TutorialValues["MovementTotal"] = TutorialValues["MovementTotal"] + math.sqrt((self.vx*dt*60)^2 + (self.vy*dt*60)^2)
    
            Camera.tx = self.x
            Camera.ty = self.y
    
            if self:get("slashTime") > 0 then
                local ox = self:get("lastPos")[1]-self.x
                local oy = self:get("lastPos")[2]-self.y
                local len = math.sqrt(ox^2+oy^2)/4
                for i = 1, len do
                    table.insert(Particles, Game.Particle:new(self.x-ox*i/len, self.y-oy*i/len))
                end
                local ents = GetEntityCollisions(self)
                for _,ent in pairs(ents) do
                    if ent.invincibility <= 0 and ent.id ~= "rocket" and ((not (ent.id == "player" and (not MultiplayerSetup.friendlyFire))) or (MultiplayerSetup.friendlyFire)) then
                        local dmg = self:get("stats")["Attack"]/ent:get("stats")["Defense"]
                        dmg = dmg * self:get("damageFactor")
                        local crit = false
                        if math.floor(self:get("critFactor")*math.max(0,9-self:get("stats")["Luck"]/10)) == 0 then
                            dmg = dmg * 2
                            crit = true
                            beep("crit", 1567.981743926997, 0, 8, 0.25*Settings["audio"]["sound_volume"]/100)
                        end
                        dmg = math.round(dmg)
                        ent.hp = ent.hp - dmg
                        ent.invincibility = 0.5
                        ent.data.lastAttacker = self.uid
                        boom("hit", 2, 0.005, 16, 0.5*Settings["audio"]["sound_volume"]/100)
                        AddDamageIndicator(ent.x, ent.y, dmg, (crit and {1,1,0}) or {1,1,1})
                        if IsHosting() then
                            self:set("damageFactor", love.math.random(5, 10))
                            self:set("critFactor", love.math.random())
                        end
                    end
                end
            else
                if (self:get("bufferTime") or 0) > 0 then
                    slash(self, love.mouse.getX(), love.mouse.getY())
                    self:set("bufferTime", 0)
                end
            end
    
            self:set("lastPos", {self.x, self.y})
    
            if IsMultiplayer then
                Net.Send({type = "player_update", x = self.x, y = self.y, vx = self.vx, vy = self.vy, stats = self:get("stats")})
            end
        end,
        mousepressed = function(self, x, y, b)
            if b == 1 then
                if self:get("slashTime") <= 0 then
                    slash(self, x, y)
                else
                    self:set("bufferTime", 0.05)
                end
            end
        end,
        draw = function(self)
            local scale = 64
            local x = self.x-Camera.x+(love.graphics.getWidth()-scale)/2
            local y = self.y-Camera.y+(love.graphics.getHeight()-scale)/2+ViewMargin
            if x >= -scale and x < love.graphics.getWidth() and y >= -scale and y < love.graphics.getHeight() then
                local customization = self:get("customization") or {color = self:get("color") or {0,1,1}}
                love.graphics.setColor(customization.color or {0,1,1})
                if self:get("slashTime") and self:get("slashTime") >= 0 then
                    love.graphics.setColor(1,0,0)
                end
                love.graphics.rectangle("fill", x, y, scale, scale)
                if customization.hat then
                    local hat = Cosmetics.Hats[customization.hat]
                    if hat then
                        love.graphics.setColor(1,1,1)
                        love.graphics.draw(hat.image,x+scale/2+hat.anchor[1],y+scale/2+hat.anchor[2],0, hat.scale, hat.scale,hat.image:getWidth()/2,hat.image:getHeight()/2)
                        love.graphics.setColor(customization.color or {0,1,1})
                    end
                    else
                        print("no hat?" .. customization.hat)
                    end
                if not self.hidehp then
                    love.graphics.setColor(1,0,0)
                    love.graphics.rectangle("fill", x-(96-scale)/2, y-scale/2-16, 96, 12)
                    love.graphics.setColor(0,1,0)
                    local fill = self.hp / self.maxhp
                    love.graphics.rectangle("fill", x-(96-scale)/2, y-scale/2-16, 96*fill, 12)
                end
            end
        end,
    },
    enemy = {
        update = function(self, dt)
            self:set("slashTime", self:get("slashTime")-dt)
            self:set("cooldown", self:get("cooldown")-dt)
            local closest
            local dist = math.huge
            for _,p in ipairs(GetEntitiesWithID("player")) do
                local d = math.sqrt((p.x - self.x)^2+(p.y - self.y)^2)
                if d < dist and p.hp > 0 then
                    closest = p
                    dist = d
                end
            end
            local ox,oy = 0,0
            local m = 64*4
            closest = closest or player
            if closest.hp > 0 or (not IsMultiplayer) then
                ox = closest.x - self.x
                oy = closest.y - self.y
                m = math.sqrt(ox^2+oy^2)
                if m > 0 then
                    ox = ox / m
                    oy = oy / m
                end
            end

            if (IsMultiplayer and Net.Hosting) or (not IsMultiplayer) then
                self.vx = self.vx + ox*dt*60
                self.vy = self.vy + oy*dt*60
            end

            local blend = math.pow(blendAmt,dt)
            self.vx = blend*(self.vx)+0
            self.vy = blend*(self.vy)+0

            self.x = self.x + self.vx*dt*60
            self.y = self.y + self.vy*dt*60

            if (IsMultiplayer and Net.Hosting) or (not IsMultiplayer) then
                if m <= 3*64 and self:get("slashTime") <= 0 and self:get("cooldown") <= 0 then
                    self.vx = self.vx + ox*64
                    self.vy = self.vy + oy*64
                    self:set("slashTime", 0.25)
                    self:set("cooldown", 1.5)
                end
            end

            if self:get("slashTime") > 0 then
                local ents = GetEntityCollisions(self)
                for _,ent in pairs(ents) do
                    if ent.id == "player" and ent.invincibility <= 0 then
                        local dmg = self:get("stats")["Attack"]/ent:get("stats")["Defense"]
                        dmg = dmg * self:get("damageFactor")
                        dmg = math.round(dmg)
                        ent.hp = ent.hp - dmg
                        ent.invincibility = 0.5
                        ent.data.lastAttacker = self.uid
                        boom("hit", 2, 0.005, 16, 0.5*Settings["audio"]["sound_volume"]/100)
                        AddDamageIndicator(ent.x, ent.y, dmg, {1,0,0})
                        if IsHosting() then
                            self:set("damageFactor", love.math.random(5, 10))
                        end
                    end
                end
            end

            if Net.Hosting then
                Net.Broadcast({type = "modify_entity", uid = self.uid, x = self.x, y = self.y, vx = self.vx, vy = self.vy, hp = self.hp,data = self.data})
            end
        end
    },
    rocket_enemy = {
        update = function(self, dt)
            self:set("link", self:get("link") or love.math.random(0,99999))
            self:set("slashTime", self:get("slashTime")-dt)
            self:set("cooldown", self:get("cooldown")-dt)
            self:set("scooldown", (self:get("scooldown") or self:get("cooldown"))-dt)
            local ox = player.x - self.x
            local oy = player.y - self.y
            local m = math.sqrt(ox^2+oy^2)
            if m > 0 then
                ox = ox / m
                oy = oy / m
            end
            self.vx = self.vx + ox
            self.vy = self.vy + oy

            local blend = math.pow(blendAmt,dt)
            self.vx = blend*(self.vx)+0
            self.vy = blend*(self.vy)+0

            self.x = self.x + self.vx*dt*60
            self.y = self.y + self.vy*dt*60

            if m <= 1.5*64 and self:get("slashTime") <= 0 and self:get("scooldown") <= 0 then
                self.vx = self.vx + ox*16
                self.vy = self.vy + oy*16
                self:set("slashTime", 0.25)
                self:set("scooldown", 1.5)
            end

            if self:get("slashTime") > 0 then
                local ents = GetEntityCollisions(self)
                for _,ent in pairs(ents) do
                    if ent.id == "player" and ent.invincibility <= 0 then
                        local dmg = (self:get("stats")["Attack"]/2)/ent:get("stats")["Defense"]
                        dmg = dmg * love.math.random(5, 10)
                        dmg = math.round(dmg)
                        ent.hp = ent.hp - dmg
                        ent.invincibility = 0.5
                        boom("hit", 2, 0.005, 16, 0.5*Settings["audio"]["sound_volume"]/100)
                        AddDamageIndicator(ent.x, ent.y, dmg, {1,0,0})
                    end
                end
            end

            if m <= 16*64 and self:get("cooldown") <= 0 then
                local rocket = Game.Entity:new("rocket", self.x, self.y, ox*8, oy*8, 8000, {
                    update = EntityTypes.rocket.update,
                    draw = EntityTypes.rocket.draw
                }, {
                    lifetime = 0,
                    owner = self:get("link"),
                    stats = {
                        Attack = self:get("stats")["Attack"]
                    }
                })
                local a = math.atan2(ox,-oy)
                rocket.angle = a
                table.insert(Entities, rocket)
                self:set("cooldown", 5)
            end
        end
    },
    rocket = {
        draw = function(self)
            local scale = 16
            local x = self.x-Camera.x+(love.graphics.getWidth()-scale)/2
            local y = self.y-Camera.y+(love.graphics.getHeight()-scale)/2+ViewMargin
            if x >= -scale and x < love.graphics.getWidth() and y >= -scale and y < love.graphics.getHeight() then
                -- local ox = player.x - self.x
                -- local oy = player.y - self.y
                -- local a = math.atan2(ox,-oy)
                love.graphics.setColor(1,1,1)
                love.graphics.draw(RocketSprite, x, y, self.angle, 2, 2, 16, 16)
            end
        end,
        update = function(self, dt)
            table.insert(Particles, Game.Particle:new(self.x+(love.math.random()*2-1)*8, self.y+(love.math.random()*2-1)*8, 2))
            local ox = player.x - self.x
            local oy = player.y - self.y
            local m = math.sqrt(ox^2+oy^2)
            if m > 0 then
                ox = ox / m
                oy = oy / m
            end
            local a = math.atan2(ox,-oy)
            local diff = ((a-self.angle)+math.pi*3)%(2*math.pi)-math.pi
            if math.abs(diff) >= dt*4 then
                self.angle = self.angle + diff*dt*4
            end
            self.vx = self.vx + math.sin(self.angle)
            self.vy = self.vy - math.cos(self.angle)

            self.vx = self.vx - self.vx/16
            self.vy = self.vy - self.vy/16

            self.x = self.x + self.vx*dt*60
            self.y = self.y + self.vy*dt*60

            self:set("lifetime", self:get("lifetime") + dt)
            if m <= 2*64 or self:get("lifetime") >= 5 then
                local killed = 0
                for _,ent in pairs(Entities) do
                    if ent ~= self and ent.id ~= "rocket" then
                        if ent.id == "player" then
                            Achievements.Advance("rocket_enemy")
                        end
                        local mx,my = ent.x - self.x,ent.y - self.y
                        local dist = math.sqrt(mx*mx + my*my)
                        if ent.invincibility <= 0 and dist <= 4*64 then
                            local atk = math.max(0,math.min(1,1-dist/256))*60*self:get("stats")["Attack"]
                            local dmg = atk/ent:get("stats")["Defense"]
                            dmg = math.round(dmg)
                            ent.hp = ent.hp - dmg
                            if ent.hp <= 0 then
                                if ent:get("link") == self:get("owner") then
                                    Achievements.Advance("rocket_defeat_enemy")
                                end
                                if ent.id == "enemy" then
                                    killed = killed + 1
                                end
                            end
                            ent.invincibility = 0.5
                            AddDamageIndicator(ent.x, ent.y, dmg, {1,0,0})
                        end
                    end
                end
                Achievements.SetMax("rocket_defeat_multiple", killed)
                for _=1,32 do
                    table.insert(Particles, Game.Particle:new(self.x,self.y,1,(love.math.random()*2-1)*32,(love.math.random()*2-1)*32,16))
                end
                boom("explosion", 128, 0.000, 1, 0.5*Settings["audio"]["sound_volume"]/100)
                self:destroy()
            end
        end
    }
}