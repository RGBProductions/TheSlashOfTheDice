local scene = {}

require "game"
require "sounds"

local function rand(min, max)
    max = max + 1
    return math.floor(love.math.random()*(max-min)+min)
end

function scene.load()
    -- Load die images
    DieImages = {}
    for _,itm in pairs(love.filesystem.getDirectoryItems("assets/images/die")) do
        DieImages[tonumber(itm:sub(1,-5))] = love.graphics.newImage("assets/images/die/" .. itm)
    end

    Dice = {}
    DiceDisplayPosition = 0
    
    SlashOrbs = {}

    SpawnTimer = 5
    Difficulty = 1
    SpawnDelay = 5
    
    dbg = true

    dbgMargin = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    }

    Entities = {
        Game.Entity:new("player", 0, 0, 0, 0, 100, {["update"] = function(self, dt)
            self:set("slashTime", self:get("slashTime")-dt)
            if love.keyboard.isDown("a") then
                self.vx = self.vx - 2
            end
            if love.keyboard.isDown("d") then
                self.vx = self.vx + 2
            end
            if love.keyboard.isDown("w") then
                self.vy = self.vy - 2
            end
            if love.keyboard.isDown("s") then
                self.vy = self.vy + 2
            end

            self.vx = self.vx - self.vx/5
            self.vy = self.vy - self.vy/5

            self.x = self.x + self.vx*dt*60
            self.y = self.y + self.vy*dt*60

            Camera.tx = self.x
            Camera.ty = self.y

            if self:get("slashTime") > 0 then
                local ox = self:get("lastPos")[1]-self.x
                local oy = self:get("lastPos")[2]-self.y
                local len = math.sqrt(ox^2+oy^2)/4
                for i = 1, len do
                    table.insert(SlashOrbs, Game.SlashOrb:new(self.x-ox*i/len, self.y-oy*i/len))
                end
                local ents = GetEntityCollisions(self)
                for _,ent in pairs(ents) do
                    if ent.invincibility <= 0 then
                        local dmg = self:get("stats")["Attack"]/ent:get("stats")["Defense"]
                        dmg = dmg * love.math.random(5, 10)
                        local crit = false
                        if rand(0,math.max(0,9-self:get("stats")["Luck"]/10)) == 0 then
                            dmg = dmg * 2
                            crit = true
                            beep(1567.981743926997, 0, 8, 0.25*Settings["Sound Volume"]/100)
                        end
                        dmg = math.round(dmg)
                        ent.hp = ent.hp - dmg
                        ent.invincibility = 0.5
                        boom(2, 0.005, 16, 0.5*Settings["Sound Volume"]/100)
                        AddDamageIndicator(ent.x, ent.y, dmg, (crit and {1,1,0}) or {1,1,1})
                    end
                end
            end

            self:set("lastPos", {self.x, self.y})
        end, ["keypressed"] = function(self, k) end, ["mousepressed"] = function(self, x, y, b)
            if b == 1 then
                if self:get("slashTime") <= 0 then
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
                    self.vx = self.vx + ax*64
                    self.vy = self.vy + ay*64
                    self:set("slashTime", 0.25)
                    sweep(1, 0, 32, 0.25*Settings["Sound Volume"]/100)
                end
            end
        end}, {
            ["slashTime"] = 0,
            ["lastPos"] = {0,0},
            ["stats"] = {
                ["Defense"] = 1,
                ["Attack"] = 1,
                ["Luck"] = 0
            }
        })
    }

    Camera = {
        x = 0,
        y = 0,
        tx = 0,
        ty = 0
    }
    
    player = GetEntitiesWithID("player")[1]

    Background = {
        {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)},
        {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)},
        {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)}
    }
    while Background[1][1] == 0 and Background[2][1] == 0 and Background[3][1] == 0 do
        Background = {
            {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)},
            {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)},
            {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)}
        }
    end

    DamageIndicators = {}

    Score = 0
end

function AddDamageIndicator(x, y, amt, color)
    color = color or {1,1,1}
    table.insert(DamageIndicators, {x = x, y = y, amt = amt, color = color, time = love.timer.getTime()})
end

function BoxCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function GetEntitiesWithID(id)
    local res = {}
    for _,ent in pairs(Entities) do
        if ent.id == id then
            table.insert(res, ent)
        end
    end
    return res
end

function GetEntityCollisions(entity)
    local res = {}
    if not entity then return res end
    for _,ent in pairs(Entities) do
        if ent ~= entity then
            if BoxCollision(ent.x, ent.y, 64, 64, entity.x, entity.y, 64, 64) then
                table.insert(res, ent)
            end
        end
    end
    return res
end

function scene.update(dt)
    local i = 1
    while i <= #DamageIndicators do
        local indicator = DamageIndicators[i]
        if love.timer.getTime() - indicator.time >= 2 then
            table.remove(DamageIndicators, i)
        else
            i = i + 1
        end
    end

    local o = 1
    while o <= #SlashOrbs do
        local orb = SlashOrbs[o]
        if love.timer.getTime() - orb.time >= 0.5 then
            table.remove(SlashOrbs, o)
        else
            o = o + 1
        end
    end

    SpawnTimer = SpawnTimer + dt
    if player then
        if SpawnTimer >= SpawnDelay then
            SpawnTimer = 0
            SpawnDelay = math.max(2, SpawnDelay - 0.5)
            local x = love.math.random(-1024, 1024) + player.x
            local y = love.math.random(-1024, 1024) + player.y
            table.insert(Entities, Game.Entity:new("enemy", x, y, 0, 0, nil, {
                ["update"] = function(self, dt)
                    self:set("slashTime", self:get("slashTime")-dt)
                    self:set("cooldown", self:get("cooldown")-dt)
                    local ox = player.x - self.x
                    local oy = player.y - self.y
                    local m = math.sqrt(ox^2+oy^2)
                    if m > 0 then
                        ox = ox / m
                        oy = oy / m
                    end
                    self.vx = self.vx + ox
                    self.vy = self.vy + oy

                    self.vx = self.vx - self.vx/5
                    self.vy = self.vy - self.vy/5
        
                    self.x = self.x + self.vx*dt*60
                    self.y = self.y + self.vy*dt*60

                    if m <= 3*64 and self:get("slashTime") <= 0 and self:get("cooldown") <= 0 then
                        self.vx = self.vx + ox*64
                        self.vy = self.vy + oy*64
                        self:set("slashTime", 0.25)
                        self:set("cooldown", 1.5)
                    end

                    if self:get("slashTime") > 0 then
                        local ents = GetEntityCollisions(self)
                        for _,ent in pairs(ents) do
                            if ent.id == "player" and ent.invincibility <= 0 then
                                local dmg = self:get("stats")["Attack"]/ent:get("stats")["Defense"]
                                dmg = dmg * love.math.random(5, 10)
                                dmg = math.round(dmg)
                                ent.hp = ent.hp - dmg
                                ent.invincibility = 0.5
                                boom(2, 0.005, 16, 0.5*Settings["Sound Volume"]/100)
                                AddDamageIndicator(ent.x, ent.y, dmg, {1,0,0})
                            end
                        end
                    end
                end
            }, {
                ["stats"] = {
                    ["Defense"] = 1+(Difficulty-1)/5*rand(0.5,1),
                    ["Attack"] = 1+(Difficulty-1)/5*rand(0.5,1)
                },
                ["slashTime"] = 0,
                ["cooldown"] = 1
            }))
            Difficulty = Difficulty * 1.075
        end
        for _,die in pairs(Dice) do
            die.die:update(dt)
        end
        local Stats = player:get("stats")
        local i = 1
        while i <= #Dice do
            if Dice[i].die.doneRolling and not Dice[i].applied then
                if Dice[i].operation == "add" then
                    Stats[Dice[i].stat] = math.max(0, Stats[Dice[i].stat] + Dice[i].die:getNumber())
                elseif Dice[i].operation == "sub" then
                    Stats[Dice[i].stat] = math.max(0, Stats[Dice[i].stat] - Dice[i].die:getNumber())
                elseif Dice[i].operation == "div" then
                    Stats[Dice[i].stat] = math.max(0, Stats[Dice[i].stat] / Dice[i].die:getNumber())
                elseif Dice[i].operation == "mul" then
                    Stats[Dice[i].stat] = math.max(0, Stats[Dice[i].stat] * Dice[i].die:getNumber())
                end
                Dice[i].applied = true
                if Dice[i].operation == "add" or Dice[i].operation == "mul" then
                    beep(1046.5022612023945, 0, 8, 0.25*Settings["Sound Volume"]/100)
                else
                    boom(32, 0.01, 8, 0.25*Settings["Sound Volume"]/100)
                end
            end
            if Dice[i].die.timeSinceCompletion >= 2 then
                table.remove(Dice, i)
                DiceDisplayPosition = DiceDisplayPosition - 1
            else
                i = i + 1
            end
        end
        DiceDisplayPosition = DiceDisplayPosition + (#Dice-DiceDisplayPosition)/8
        if Stats["Attack"] < 1 then
            Stats["Attack"] = 1
        end
        if Stats["Defense"] < 0.1 then
            Stats["Defense"] = 0.1
        end

        if Stats["Attack"] > 150 then
            Stats["Attack"] = 150
        end
        if Stats["Defense"] > 150 then
            Stats["Defense"] = 150
        end
        if Stats["Luck"] > 90 then
            Stats["Luck"] = 90
        end

        for _,ent in pairs(Entities) do
            ent:update(dt)
            ent.hp = math.min(ent.maxhp, ent.hp + dt*2)
        end

        local stats = {}
        for t,v in pairs(Stats) do
            table.insert(stats, t)
        end
        local ops = {"add","add","add","add", "mul","mul","mul", "sub", "div"}

        local e = 1
        while e <= #Entities do
            if Entities[e].hp <= 0 then
                if Entities[e].id ~= "player" then
                    if #GetEntitiesWithID("player") > 0 then
                        table.insert(Dice, {die = Game.Die:new(), stat = stats[love.math.random(1, #stats)], operation = ops[love.math.random(1, #ops)]})
                        Score = Score + 1
                    end
                end
                table.remove(Entities, e)
                boom(2, 0.005, 4, 0.5*Settings["Sound Volume"]/100)
            else
                e = e + 1
            end
        end
    end

    Camera.x = Camera.x + (Camera.tx - Camera.x)/8
    Camera.y = Camera.y + (Camera.ty - Camera.y)/8
end

function scene.keypressed(k)
    if k == "k" then
        if #GetEntitiesWithID("player") > 0 then
            table.remove(Entities, 1)
            boom(2, 0.005, 4, 0.5*Settings["Sound Volume"]/100)
        end
    end
    if k == "escape" then
        SceneManager.LoadScene("scenes/menu")
    end
    if k == "space" and #GetEntitiesWithID("player") == 0 then
        SceneManager.LoadScene("scenes/enemyrush")
    end
end

function scene.mousepressed(x, y, b)
    for _,ent in pairs(Entities) do
        ent:mousepressed(x,y,b)
    end
end

function scene.draw()
    local objOnscreen = 0
    local entOnscreen = 0
    for x = -math.ceil(love.graphics.getWidth()/2/64+1), math.ceil(love.graphics.getWidth()/2/64+1) do
        for y = -math.ceil(love.graphics.getHeight()/2/64+1), math.ceil(love.graphics.getHeight()/2/64+1) do
            local rx = x + math.floor(Camera.x/64)
            local ry = y + math.floor(Camera.y/64)
            local ox = -32-Camera.x+(love.graphics.getWidth())/2+rx*64
            local oy = -32-Camera.y+(love.graphics.getHeight())/2+ry*64
            love.graphics.setColor((rx+ry+Background[1][3])%Background[1][2]*Background[1][1],(rx+ry+Background[1][3])%Background[2][2]*Background[2][1],(rx+ry+Background[1][3])%Background[3][2]*Background[3][1])
            if ox >= -64+dbgMargin.left and ox < love.graphics.getWidth()-dbgMargin.right and oy >= -64+dbgMargin.top and oy < love.graphics.getHeight()-dbgMargin.bottom then
                love.graphics.rectangle("line", ox, oy, 64, 64)
                objOnscreen = objOnscreen + 1
            end
        end
    end
    for _,orb in pairs(SlashOrbs) do
        love.graphics.setColor(1,1,1)
        love.graphics.circle("fill", orb.x-Camera.x+love.graphics.getWidth()/2, orb.y-Camera.y+love.graphics.getHeight()/2, (0.5-(love.timer.getTime()-orb.time))*16)
    end
    for _,entity in pairs(Entities) do
        local scale = 64
        if entity.id == "enemy" then
            scale = 48
        end
        local x = entity.x-Camera.x+(love.graphics.getWidth()-scale)/2
        local y = entity.y-Camera.y+(love.graphics.getHeight()-scale)/2
        if x >= -scale+dbgMargin.left and x < love.graphics.getWidth()-dbgMargin.right and y >= -scale+dbgMargin.top and y < love.graphics.getHeight()-dbgMargin.bottom then
            love.graphics.setColor(1,1,1)
            if entity.id == "player" then
                love.graphics.setColor(0,1,1)
            end
            if entity:get("slashTime") and entity:get("slashTime") >= 0 then
                love.graphics.setColor(1,0,0)
            end
            if entity.invincibility > 0 then
                local r,g,b,a = love.graphics.getColor()
                love.graphics.setColor(r,g,b,0.5)
            end
            love.graphics.rectangle("fill", x, y, scale, scale)

            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("fill", x-(96-scale)/2, y-scale/2-16, 96, 12)
            love.graphics.setColor(0,1,0)
            local fill = entity.hp / entity.maxhp
            love.graphics.rectangle("fill", x-(96-scale)/2, y-scale/2-16, 96*fill, 12)
            entOnscreen = entOnscreen + 1
        end
    end
    
    for _,indicator in pairs(DamageIndicators) do
        love.graphics.setColor(indicator.color)
        local x = indicator.x - Camera.x + love.graphics.getWidth()/2
        local y = indicator.y - Camera.y + love.graphics.getHeight()/2
        
        local ny = 1-(1-math.max(0, math.min(1, 2*(love.timer.getTime() - indicator.time))))^5
        local ds = (1-math.max(0, math.min(1, 2*((love.timer.getTime() - indicator.time)-1))))^5
        love.graphics.printf(indicator.amt, x, y-ny*48, 64, "center", 0, ds, ds, 32, 32)
    end

    for i,die in ipairs(Dice) do
        local s = math.max(1, DiceDisplayPosition*64*Settings["UI Scale"]/love.graphics.getWidth())
        local ds = (1-math.max(0, math.min(1, 2*(die.die.timeSinceCompletion-1))))^5
        local ny = 1-(1-math.max(0, math.min(1, 2*(die.die.timeSinceCompletion))))^5
        local x = love.graphics.getWidth()-((DiceDisplayPosition-(i)+1)*64*Settings["UI Scale"]/s) + 32*Settings["UI Scale"]/s
        local y = love.graphics.getHeight()-32*Settings["UI Scale"]/s
        local r,g,b = 1,1,1
        if die.operation == "div" or die.operation == "sub" then
            r,g,b = 1,0,0
        end

        if die.die:getNumber() then
            local op = "+"
            if die.operation == "mul" then
                op = "×"
            end
            if die.operation == "sub" then
                op = "-"
            end
            if die.operation == "div" then
                op = "÷"
            end

            local st = ""
            if die.stat then
                st = die.stat .. " "
            end
        
            love.graphics.setColor(r,g,b)
            love.graphics.setFont(smfont)
            love.graphics.printf(st .. op .. die.die.number, x, y+32*Settings["UI Scale"]/s-love.graphics.getFont():getHeight()*Settings["UI Scale"]/s/2-ny*48*Settings["UI Scale"]/s, 64, "center", 0, Settings["UI Scale"]/s*ds, Settings["UI Scale"]/s*ds, 32, 32)
        end
        love.graphics.setColor(r,g,b,1)
        if not die.die:getNumber() then
            love.graphics.setColor(r,g,b,0.5)
        end
        love.graphics.draw(DieImages[die.die.number], x, y, 0, Settings["UI Scale"]/s*ds, Settings["UI Scale"]/s*ds, 32, 32)
    end

    love.graphics.setColor(1,1,1)
    local str = ""
    if player then
        local Stats = player:get("stats")
        for name,value in pairs(Stats) do
            str = str .. name .. ": " .. math.round(value*100)/100 .. "\n"
        end
        love.graphics.setFont(lgfont)
        love.graphics.print(str, 0, 0)
    end
    
    love.graphics.print("Score: " .. Score, 0, love.graphics.getHeight()-lgfont:getHeight())

    love.graphics.setFont(lgfont)
    love.graphics.printf("Next Enemy: " .. math.ceil((SpawnDelay - SpawnTimer)), 0, 0, love.graphics.getWidth(), "center")
    local fill = 1-(SpawnTimer/SpawnDelay)
    love.graphics.setColor(0.25,0.25,0.25)
    love.graphics.rectangle("fill", (love.graphics.getWidth()-512)/2, love.graphics.getFont():getHeight(), 512, 16)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", (love.graphics.getWidth()-512)/2, love.graphics.getFont():getHeight(), 512*fill, 16)

    if #GetEntitiesWithID("player") == 0 then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(xlfont)
        love.graphics.printf("You died!", 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2-xlfont:getHeight()*2, love.graphics.getWidth(), "center")
        love.graphics.setFont(lgfont)
        love.graphics.printf("Score: " .. Score, 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2, love.graphics.getWidth(), "center")
        love.graphics.printf("Press space to play again", 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2+lgfont:getHeight()*2, love.graphics.getWidth(), "center")
        love.graphics.printf("Press escape to return to menu", 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2+lgfont:getHeight()*3, love.graphics.getWidth(), "center")
    end

    -- if dbg then
    --     love.graphics.setFont(lgfont)
    --     local str = ""
    --     str = str .. "Entities Visible: " .. entOnscreen .. "\n"
    --     str = str .. "Objects Visible: " .. objOnscreen .. "\n"
    --     str = str .. "Total Visible: " .. objOnscreen + entOnscreen .. "\n"
    --     str = str .. "FPS: " .. love.timer.getFPS() .. "\n"
    --     love.graphics.setColor(0,0,0)
    --     love.graphics.print(str, 2, 2)
    --     love.graphics.setColor(1,1,1)
    --     love.graphics.print(str, 0, 0)
    --     -- local lw = love.graphics.getLineWidth()
    --     -- love.graphics.setLineWidth(4)
    --     -- love.graphics.setColor(1,1,0)
    --     -- love.graphics.rectangle("line", dbgMargin.left, dbgMargin.top, love.graphics.getWidth()-dbgMargin.left-dbgMargin.right, love.graphics.getHeight()-dbgMargin.top-dbgMargin.bottom)
    --     -- love.graphics.setLineWidth(lw)
    -- end
    
    love.graphics.setColor(1,1,1)
end

return scene