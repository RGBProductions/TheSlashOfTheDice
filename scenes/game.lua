-- this version, 1.2.1, is the last one i'm using this game scene in.
-- for 1.3 i'm going to completely rewrite it.
-- i just hate how long and bad it is.

local scene = {}

local blendAmt = 1/((5/4)^60)
local tutorialBounds = 1024

local frame = 0

local pauseMenu = UI.Element:new({
    children = {
        UI.Text:new({
            x = 0,
            y = -128,
            width = 512,
            height = xlfont_2x:getHeight()/2,
            font = xlfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            text = function() return Localize("paused.title") end
        }),
        UI.Button:new({
            id = "resume",
            defaultSelected = true,
            x = 0,
            y = -64-16+64,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 256,
                    height = 64,
                    text = function(self) return Localize("paused.resume") end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function(self)
                Paused = false
                ShowGameMenu = false
            end
        }),
        UI.Button:new({
            id = "restart",
            x = 0,
            y = 0+64,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 256,
                    height = 64,
                    text = function(self) return Localize("paused.restart") end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function(self)
                SceneManager.LoadScene("scenes/game", {mode=Gamemode})
                frame = 0
            end
        }),
        UI.Button:new({
            id = "exit",
            x = 0,
            y = 64+16+64,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 256,
                    height = 64,
                    text = function(self) return Localize("paused.exit") end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function(self)
                Net.Disconnect()
                SceneManager.LoadScene("scenes/menu")
            end
        })
    }
})

local gameOverMenu = UI.Element:new({
    children = {
        UI.Text:new({
            x = 0,
            y = -128,
            width = 512,
            height = xlfont_2x:getHeight()/2,
            font = xlfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            text = function() return Localize("gameover.title") end
        }),
        UI.Text:new({
            x = 0,
            y = -64,
            width = 512,
            height = lgfont_2x:getHeight()/2,
            font = lgfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            text = function() return Localize("score"):format(Score) end
        }),
        UI.Button:new({
            id = "restart",
            defaultSelected = true,
            x = 0,
            y = 0+32,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 256,
                    height = 64,
                    text = function(self) return Localize(GameSetups[Gamemode].canRespawn and "gameover.respawn" or (IsMultiplayer and "gameover.spectate" or "gameover.retry")) end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function(self)
                if GameSetups[Gamemode].canRespawn then
                    AddNewPlayer(Settings.customization, Gamemode == "calm" or Gamemode == "tutorial")
                    IsDead = false
                elseif IsMultiplayer then
                    Spectating = true
                else
                    SceneManager.LoadScene("scenes/game", {mode=Gamemode})
                    frame = 0
                end
            end
        }),
        UI.Button:new({
            id = "exit",
            x = 0,
            y = 64+16+32,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 256,
                    height = 64,
                    text = function(self) return Localize("gameover.exit") end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function(self)
                Net.Disconnect()
                SceneManager.LoadScene("scenes/menu")
            end
        })
    }
})

local function setSelection(menu)
    if (menu or {}).unpackChildren then
        for _,child in ipairs((menu or {}):unpackChildren()) do
            if child.element.defaultSelected then
                MenuSelection = child
                break
            end
        end
    end
end

function AddNewPlayer(customization,keepStats,netinfo,isOwn)
    player = Game.Entity:new("player", 0, 0, 0, 0, 100, {["slash"] = EntityTypes.player.slash, ["update"] = EntityTypes.player.update, ["keypressed"] = function(self, k) end, ["mousepressed"] = EntityTypes.player.mousepressed, ["gamepadaxis"] = EntityTypes.player.gamepadaxis, ["draw"] = EntityTypes.player.draw}, {
        slashTime = 0,
        lastPos = {0,0},
        stats = keepStats and (Stats or {
            Defense = 1,
            Attack = 1,
            Luck = 0
        }) or {
            Defense = 1,
            Attack = 1,
            Luck = 0
        },
        damageFactor = love.math.random(5, 10),
        critFactor = love.math.random(),
        isOwn = isOwn,
        customization = customization
    })
    if netinfo then
        player.data.netinfo = netinfo
    end
    player.uid = math.floor(love.timer.getTime()*10000)
    table.insert(Entities, player)
    if isOwn then
        IsDead = false
    end
    return player
end

function AddNetPlayer(info,stats)
    local netplayer = Game.Entity:new("player", 0, 0, 0, 0, 100, {["update"] = function(self, dt)
        self:set("slashTime", self:get("slashTime")-dt)

        local blend = math.pow(blendAmt,dt)
        self.vx = blend*(self.vx)
        self.vy = blend*(self.vy)

        self.x = self.x + self.vx*dt*60
        for _,entity in ipairs(Entities) do
            if entity ~= self and entity:get("Collision") then
                local collision = entity:get("Collision")
                if BoxCollision(self.x-32, self.y-32, 64, 64, entity.x-collision[3]/2+collision[1], entity.y-collision[4]/2+collision[2], collision[3], collision[4]) then
                    if math.sign(self.vx) == 1 then -- Moving right
                        self.x = entity.x+collision[1] - collision[3]/2 + 32
                    end
                    if math.sign(self.vx) == -1 then -- Moving left
                        self.x = entity.x+collision[1] + collision[3]/2 + 32
                    end
                end
            end
        end
        self.y = self.y + self.vy*dt*60
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

        if self:get("slashTime") > 0 then
            -- local ox = self:get("lastPos")[1]-self.x
            -- local oy = self:get("lastPos")[2]-self.y
            -- local len = math.sqrt(ox^2+oy^2)/4
            -- for i = 1, len do
            --     table.insert(Particles, Game.Particle:new(self.x-ox*i/len, self.y-oy*i/len))
            -- end
            local ents = GetEntityCollisions(self)
            for _,ent in pairs(ents) do
                if ent.invincibility <= 0 and ent.id ~= "rocket" and ((not (ent.id == "player" and (not MultiplayerSetup.friendlyFire))) or (MultiplayerSetup.friendlyFire)) then
                    local dmg = self:get("stats")["Attack"]/ent:get("stats")["Defense"]
                    dmg = dmg * love.math.random(5, 10)
                    local crit = false
                    if rand(0,math.max(0,9-self:get("stats")["Luck"]/10)) == 0 then
                        dmg = dmg * 2
                        crit = true
                        beep("crit", 1567.981743926997, 0, 8, 0.25*Settings.audio.sound_volume/100)
                    end
                    dmg = math.round(dmg)
                    ent.hp = ent.hp - dmg
                    ent.invincibility = 0.5
                    ent.data.lastAttacker = self.uid
                    boom("hit", 2, 0.005, 16, 0.5*Settings.audio.sound_volume/100)
                    AddDamageIndicator(ent.x, ent.y, dmg, (crit and {1,1,0}) or {1,1,1})
                end
            end
        end

        self:set("lastPos", {self.x, self.y})
    end, ["keypressed"] = function(self, k) end, ["mousepressed"] = function(self, x, y, b) end}, {
        ["slashTime"] = 0,
        ["lastPos"] = {0,0},
        ["stats"] = stats or {
            ["Defense"] = 1,
            ["Attack"] = 1,
            ["Luck"] = 0
        },
        ["color"] = (info or {}).color,
        ["netinfo"] = info
    })
    netplayer.uid = math.floor(love.timer.getTime()*10000)
    table.insert(Entities, netplayer)
    return netplayer
end

function ModifyNetPlayer(id, x, y, vx, vy, hp, data)
    data = data or {}
    for _,ent in ipairs(GetEntitiesWithID("player")) do
        if (ent.data.netinfo or {}).id == id then
            ent.x = x or ent.x
            ent.y = y or ent.y
            ent.vx = vx or ent.vx
            ent.vy = vy or ent.vy
            ent.hp = hp or ent.hp
            for k,v in pairs(data) do
                ent.data[k] = v
            end
        end
    end
end

function ModifyEntity(uid, x, y, vx, vy, hp, data)
    data = data or {}
    for _,ent in ipairs(Entities) do
        if ent.uid == uid then
            ent.x = x or ent.x
            ent.y = y or ent.y
            ent.vx = vx or ent.vx
            ent.vy = vy or ent.vy
            ent.hp = hp or ent.hp
            for k,v in pairs(data) do
                ent.data[k] = v
            end
        end
    end
end

function scene.load(args)
    if args.seed then
        love.math.setRandomSeed(args.seed)
    end
    frame = 0
    StopMusic()
    Thumbstick = {
        x = 0,
        y = 0,
        outerRad = 96,
        innerRad = 32,
        pressed = nil
    }
    Slashstick = {
        radius = 96
    }
    Pausebutton = {
        size = 64
    }

    Moved = false
    Paused = false
    ShowGameMenu = false
    Spectating = false
    IsDead = false
    InGame = true
    Gamemode = args.mode

    IsMultiplayer = args.multiplayer ~= nil
    MultiplayerSetup = args.multiplayer or {}

    LoadMusic(Gamemode == "tutorial" and "assets/music/Tutorial.ogg" or ("assets/music/Fight" .. (SusMode and "Sus" or "") .. ".ogg"))
    -- Load die images
    DieImages = {}
    for _,itm in pairs(love.filesystem.getDirectoryItems("assets/images/die")) do
        DieImages[tonumber(itm:sub(1,-5))] = love.graphics.newImage("assets/images/die/" .. itm)
    end

    Dice = {}
    DiceDisplayPosition = 0
    DiceDisplaySize = 0
    
    Particles = {}

    TimerDisplay = {
        match = "timer.remaining",
        enemy = "timer.enemy"
    }

    Events.fire("loadmodes")
    GameSetups = {
        tutorial = {multiplayer = false, name = "Tutorial", hasTimer = false, timerType = "enemy", timer = 5, spawnImmediate = false, canRespawn = true},
        default = {multiplayer = false, name = "Default", hasTimer = true, timerType = "enemy", timer = 15, spawnImmediate = true, canRespawn = false},
        calm = {multiplayer = false, name = "Calm", hasTimer = true, timerType = "enemy", timer = 15, spawnImmediate = true, canRespawn = false},
        enemy_rush = {multiplayer = false, name = "Enemy Rush", hasTimer = true, timerType = "enemy", timer = 5, spawnImmediate = true, canRespawn = false},
        
        playtest = {multiplayer = false, name = "Playtest", hasTimer = true, timerType = "enemy", timer = 10, spawnImmediate = true, canRespawn = false},
        
        coop = {multiplayer = true, name = "Co-op", hasTimer = true, timerType = "enemy", timer = 15, spawnImmediate = true, canRespawn = false},
        ffa = {multiplayer = true, name = "FFA", hasTimer = true, timerType = "match", timer = MultiplayerSetup.Timer or (3*60), spawnImmediate = false, canRespawn = true},
        tdm = {multiplayer = true, name = "TDM", hasTimer = true, timerType = "match", timer = MultiplayerSetup.Timer or (3*60), spawnImmediate = false, canRespawn = true}
    }

    showTimer = GameSetups[Gamemode].hasTimer
    runTimer = GameSetups[Gamemode].hasTimer
    timerType = GameSetups[Gamemode].timerType

    SpawnTimer = (GameSetups[Gamemode].spawnImmediate and GameSetups[Gamemode].timer) or 0
    VisualSpawnTimer = SpawnTimer
    Difficulty = 1
    SpawnDelay = GameSetups[Gamemode].timer
    Spawned = 0

    SixStreak = 0

    Entities = {}
    player = AddNewPlayer(Settings.customization, nil, IsMultiplayer and Net.ClientID)
    if IsMultiplayer and Net.Hosting then
        for _,p in ipairs(Net.Room.players) do
            local stats = {Defense = 1, Attack = 1, Luck = 0}
            local ent
            if p ~= Net.ClientID then
                ent = AddNetPlayer({id = p}, stats)
            else
                ent = player
            end
            Net.Broadcast({type = "spawn_player", uid = ent.uid, id = p, stats = stats})
        end
    end
    if IsMultiplayer then
    end
    if args.map then
        for _,ent in ipairs(args.map) do
            table.insert(Entities, ent)
        end
    end

    Camera = {
        x = 0,
        y = 0,
        tx = 0,
        ty = 0
    }

    TutorialValues = {
        ["MovementTotal"] = 0,
        ["Slashes"] = 0,
        ["Score"] = 0
    }

    Stage = 1
    Message = 1
    MessageProgress = 0
    TutorialText = ""
    CharTime = 0

    TutorialStages = {
        {
            criteria = {},
            messages = {
                {text = "tutorial.intro1", pause = true},
                {text = "tutorial.intro2", pause = true},
                {text = "tutorial.intro3", pause = true},
                {text = function() return (IsMobile and "tutorial.intro4.mobile" or ((Gamepads[1] ~= nil) and "tutorial.intro4.gamepad" or "tutorial.intro4.desktop")) end, format = {function()
                    local strings = GetControlStrings("pause")
                    return strings[(Gamepads[1] ~= nil) and "gamepad" or "desktop"]
                end}, pause = true},
                {text = "tutorial.intro5", pause = true}
            }
        }, {
            criteria = {
                ["MovementTotal"] = {
                    type = "greater",
                    value = 8*128
                }
            },
            messages = {
                {text = function()
                    if IsMobile then return "tutorial.movement.mobile" end
                    if Gamepads[1] == nil then return "tutorial.movement.desktop" end

                    local strings = {
                        up = GetControlStrings("move_up"),
                        down = GetControlStrings("move_down"),
                        left = GetControlStrings("move_left"),
                        right = GetControlStrings("move_right")
                    }
                    local axes = {
                        up = GetControlAxis("move_up") or "",
                        down = GetControlAxis("move_down") or "",
                        left = GetControlAxis("move_left") or "",
                        right = GetControlAxis("move_right") or ""
                    }
                    if Gamepads[1] ~= nil then
                        local up,down,left,right = axes.up,axes.down,axes.left,axes.right
                        if up:sub(1,-2) == down:sub(1,-2) then
                            up = up:sub(1,-2)
                            down = down:sub(1,-2)
                        end
                        if right:sub(1,-2) == left:sub(1,-2) then
                            right = right:sub(1,-2)
                            left = left:sub(1,-2)
                        end
                        if up:sub(1,-2) == down:sub(1,-2) and up:sub(1,-2) == left:sub(1,-2) and up:sub(1,-2) == right:sub(1,-2) then
                            up = up:sub(1,-2)
                            down = down:sub(1,-2)
                            right = right:sub(1,-2)
                            left = left:sub(1,-2)
                        end
                        if up == down and up == left and up == right then
                            return "tutorial.movement.gamepad_single"
                        end
                        if (up == down and left ~= right) or (up ~= down and left == right) then
                            return "tutorial.movement.gamepad_triple"
                        end
                        if (up == down and left == right) then
                            return "tutorial.movement.gamepad_double"
                        end
                        return "tutorial.movement.gamepad"
                    end
                    return "tutorial.movement.desktop"
                end, format = function()
                    local strings = {
                        up = GetControlStrings("move_up"),
                        down = GetControlStrings("move_down"),
                        left = GetControlStrings("move_left"),
                        right = GetControlStrings("move_right")
                    }
                    local axes = {
                        up = GetControlAxis("move_up") or "",
                        down = GetControlAxis("move_down") or "",
                        left = GetControlAxis("move_left") or "",
                        right = GetControlAxis("move_right") or ""
                    }
                    if Gamepads[1] ~= nil then
                        local up,down,left,right = axes.up,axes.down,axes.left,axes.right
                        if up:sub(1,-2) == down:sub(1,-2) then
                            up = up:sub(1,-2)
                            down = down:sub(1,-2)
                        end
                        if right:sub(1,-2) == left:sub(1,-2) then
                            right = right:sub(1,-2)
                            left = left:sub(1,-2)
                        end
                        if up:sub(1,-2) == down:sub(1,-2) and up:sub(1,-2) == left:sub(1,-2) and up:sub(1,-2) == right:sub(1,-2) then
                            up = up:sub(1,-2)
                            down = down:sub(1,-2)
                            right = right:sub(1,-2)
                            left = left:sub(1,-2)
                        end
                        local gstrings = {
                            up = GetAxisString(up),
                            down = GetAxisString(down),
                            left = GetAxisString(left),
                            right = GetAxisString(right)
                        }
                        if up == down and up == left and up == right then
                            return {gstrings.up}
                        end
                        if (up == down and left ~= right) then
                            return {gstrings.up,gstrings.left,gstrings.right}
                        end
                        if (up ~= down and left == right) then
                            return {gstrings.up,gstrings.down,gstrings.left}
                        end
                        if (up == down and left == right) then
                            return {gstrings.up,gstrings.left}
                        end
                        return {gstrings.up,gstrings.down,gstrings.left,gstrings.right}
                    end
                    return {strings.up.desktop, strings.left.desktop, strings.down.desktop, strings.right.desktop}
                end}
            }
        }, {
            criteria = {
                ["Slashes"] = {
                    type = "greater",
                    value = 0
                }
            },
            messages = {
                {text = "tutorial.slash1", pause = true},
                {text = "tutorial.slash2", pause = true},
                {text = function() return (IsMobile and "tutorial.slash3.mobile" or ((Gamepads[1] ~= nil) and "tutorial.slash3.gamepad" or "tutorial.slash3.desktop")) end, format = {function()
                    local strings = GetControlStrings("slash")
                    return strings[(Gamepads[1] ~= nil) and "gamepad" or "desktop"]
                end}}
            }
        }, {
            messages = {
                {text = "tutorial.dice1", pause = true},
                {text = "tutorial.dice2", onShow = function()
                    table.insert(Dice, {die = Game.Die:new(16), stat = "Attack", operation = "add", example = 1})
                end, pause = true},
                {text = "tutorial.dice3", pause = true},
                {text = "tutorial.dice4", pause = true},
                {text = "tutorial.dice5", pause = true}
            }
        }, {
            criteria = {
                ["Score"] = {
                    type = "greater",
                    value = 0
                }
            },
            messages = {
                {text = "tutorial.enemies1", onShow = function()
                    local x = player.x+64*5
                    if x > tutorialBounds then
                        x = player.x-64*5
                    end
                    table.insert(Entities, Game.Entity:new("enemy", x, player.y, 0, 0, nil, {
                        ["update"] = function(self, dt)
                            -- DORMANT ENTITY - NO MOVEMENT OR ATTACKING
                        end
                    }, {
                        ["stats"] = {
                            ["Defense"] = 0.25, -- Lowered for easier kill
                            ["Attack"] = 0 -- Doesn't matter, but just in case somehow the enemy attacks
                        }
                    }))
                end, pause = true},
                {text = "tutorial.enemies2", pause = true},
                {text = "tutorial.enemies3"}
            }
        }, {
            messages = {
                {text = "tutorial.enemies4", pause = true},
                {text = "tutorial.enemies5", pause = true},
            }
        }, {
            criteria = {
                ["Score"] = {
                    type = "greater",
                    value = 5
                }
            },
            messages = {
                {text = "tutorial.end1", pause = true},
                {text = "tutorial.end2", pause = true},
                {text = "tutorial.end3", pause = true, onShow = function()
                    showTimer = true
                end},
                {text = function() return (IsMobile and "tutorial.end4.mobile" or ((Gamepads[1] ~= nil) and "tutorial.end4.gamepad" or "tutorial.end4.desktop")) end, format = {function()
                    local strings = GetControlStrings("skip_wave")
                    return strings[(Gamepads[1] ~= nil) and "gamepad" or "desktop"]
                end}, pause = true},
                {text = "tutorial.end5", onShow = function()
                    runTimer = true
                end}
            }
        }, {
            criteria = {
                ["NOTPOSSIBLE"] = {
                    type = "equal",
                    value = 10
                }
            },
            messages = {
                {text = "tutorial.complete", onShow = function()
                    Achievements.Advance("complete_tutorial")
                    Achievements.Advance("complete_tutorial_5")
                    Achievements.Advance("complete_tutorial_10")
                end}
            }
        }
    }
    
    -- player = GetEntitiesWithID("player")[1]
    hadPlayer = true

    if Gamemode ~= "tutorial" then
        Background = {
            {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)},
            {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)},
            {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)}
        }
        while (Background[1][1] == 0 and Background[2][1] == 0 and Background[3][1] == 0) or (Background[1][4] == 0 or Background[2][4] == 0 or Background[3][4] == 0 or Background[1][5] == 0 or Background[2][5] == 0 or Background[3][5] == 0) do
            Background = {
                {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)},
                {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)},
                {love.math.random(0,1), love.math.random(2,5), love.math.random(2,3), love.math.random(-3,3), love.math.random(-3,3)}
            }
        end
    else
        Background = {
            {0, 2, 2, 1, 1},
            {0, 2, 2, 1, 1},
            {1, 3, 2, 1, 1}
        }
    end

    DamageIndicators = {}

    Score = 0
    
    Events.fire("gameloaded")
    DiscordPresence.details = (IsMultiplayer and "Multiplayer" or "Singleplayer") .. " - " .. GameSetups[Gamemode].name
    DiscordPresence.state = "Score: " .. Score
    DiscordPresence.currentScene = "game"
    DiscordPresence.startTimestamp = os.time()
end

function AddDamageIndicator(x, y, amt, color)
    color = color or {1,1,1}
    table.insert(DamageIndicators, {x = x, y = y, amt = amt, color = color, time = love.timer.getTime()})
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

function CheckStageCriteria()
    if not TutorialStages[Stage].criteria then return true end
    for k,v in pairs(TutorialStages[Stage].criteria) do
        if TutorialValues[k] == nil then return false end
        if v.type == "greater" then
            if v.value >= TutorialValues[k] then
                return false
            end
        end
        if v.type == "less" then
            if v.value <= TutorialValues[k] then
                return false
            end
        end
        if v.type == "equal" then
            if v.value ~= TutorialValues[k] then
                return false
            end
        end
    end
    return true
end

function AttemptTutorialAdvance(fromKey)
    local format = TutorialStages[Stage].messages[Message].format or {}
    if type(format) == "function" then format = format() end
    for i,v in ipairs(format) do
        if type(v) == "function" then format[i] = v() end
    end
    local stageText = TutorialStages[Stage].messages[Message].text
    if type(stageText) == "function" then stageText = stageText() end
    local txt = Localize(stageText):format(unpack(format))
    if MessageProgress < utf8.len(txt) and fromKey then
        MessageProgress = utf8.len(txt)
        return
    end
    if TutorialStages[Stage].messages[Message].pause and not fromKey then return end
    if not CheckStageCriteria() and Message == #TutorialStages[Stage].messages then return end
    CharTime = 0
    Message = Message + 1
    MessageProgress = 0
    if Message > #TutorialStages[Stage].messages then
        Stage = Stage + 1
        Message = 1
    end
    if TutorialStages[Stage].messages[Message].onShow then
        TutorialStages[Stage].messages[Message].onShow()
    end
end

function scene.update(dt)
    frame = frame + 1
    if not (Paused and not IsMultiplayer) then
        if Gamemode == "tutorial" then
            CharTime = CharTime + dt
            local format = TutorialStages[Stage].messages[Message].format or {}
            if type(format) == "function" then format = format() end
            for i,v in ipairs(format) do
                if type(v) == "function" then format[i] = v() end
            end
            local stageText = TutorialStages[Stage].messages[Message].text
            if type(stageText) == "function" then stageText = stageText() end
            local txt = Localize(stageText):format(unpack(format))
            local beeped = false
            while CharTime >= GetTextDelay() do
                if MessageProgress < utf8.len(txt) then
                    if not beeped then
                        beep("tutorial_text", 1046.5022612023945, 0, 32, 1/16*Settings.audio.sound_volume/100)
                        beeped = true
                    end
                    MessageProgress = math.min(utf8.len(txt), MessageProgress+1)
                end
                CharTime = CharTime - GetTextDelay()
            end
            MessageProgress = math.min(utf8.len(txt), MessageProgress)
            TutorialText = utf8.sub(txt, 1, MessageProgress)
            if MessageProgress >= utf8.len(txt) then
                AttemptTutorialAdvance()
            end
        end
        local i = 1
        while i <= #DamageIndicators do
            local indicator = DamageIndicators[i]
            if love.timer.getTime() - indicator.time >= 2 then
                table.remove(DamageIndicators, i)
                i = i - 1
            end
            i = i + 1
        end

        local o = 1
        while o <= #Particles do
            local orb = Particles[o]
            orb:update(dt)
            if love.timer.getTime() - orb.time >= orb.lifespan then
                table.remove(Particles, o)
                o = o - 1
            end
            o = o + 1
        end

        
        if Gamemode ~= "tutorial" or (runTimer and Spawned < 5) then
            SpawnTimer = SpawnTimer + dt
        end
        if player then
            if runTimer and SpawnTimer >= SpawnDelay then
                SpawnTimer = 0
                if timerType == "enemy" and ((IsMultiplayer and Net.Hosting) or (not IsMultiplayer)) then
                    if Gamemode == "tutorial" then Spawned = Spawned + 1 end
                    SpawnDelay = math.max((Gamemode == "enemy_rush" and 2) or (Gamemode == "calm" and 5) or (Gamemode == "playtest" and 10) or 1,SpawnDelay - ((Gamemode ~= "tutorial" and Gamemode ~= "playtest") and 0.5 or 0))
                    local x = love.math.random(-512, 512) + player.x
                    local y = love.math.random(-512, 512) + player.y
                    local event = {type = "enemy", stats = {
                        ["Defense"] = (Gamemode ~= "tutorial" and 1+(Difficulty-1)/5*rand(0.96875,1.5) or 1),
                        ["Attack"] = (Gamemode ~= "tutorial" and 1+(Difficulty-1)/5*rand(0.96875,1.5) or 1)
                    }, cancelled = false}
                    Events.fire("enemyspawn", event)
                    if not event.cancelled then
                        local ent = Game.Entity:new("enemy", x, y, 0, 0, nil, EntityTypes[event.type or "enemy"], {
                            ["stats"] = event.stats or {
                                ["Defense"] = (Gamemode ~= "tutorial" and 1+(Difficulty-1)/5*rand(0.96875,1.5) or 1),
                                ["Attack"] = (Gamemode ~= "tutorial" and 1+(Difficulty-1)/5*rand(0.96875,1.5) or 1)
                            },
                            ["slashTime"] = 0,
                            ["cooldown"] = 1,
                            ["damageFactor"] = love.math.random(5, 10)
                        })
                        ent.uid = math.floor(love.timer.getTime()*10000)
                        table.insert(Entities, ent)
                        if Net.Hosting then
                            Net.Broadcast({type = "spawn_entity", entity = {type = "enemy", x = ent.x, y = ent.y, vx = ent.vx, vy = ent.vy, maxhp = ent.maxhp, data = ent.data, uid = ent.uid}})
                        end
                    end
                    Achievements.SetMax("singularity", #GetEntitiesWithID("enemy"))
                    Difficulty = Difficulty * ((Gamemode == "default" and 1.15) or ((Gamemode == "tutorial" or Gamemode == "playtest") and 1) or 1.075)
                    if Gamemode == "calm" then
                        Difficulty = math.min(40,Difficulty)
                    end
                end
                Net.Broadcast({type = "sync_timer", timer = SpawnTimer, delay = SpawnDelay})
            end
            for _,die in pairs(Dice) do
                die.die:update(dt)
            end
            Stats = player:get("stats")
            local i = 1
            while i <= #Dice do
                if Dice[i].die.doneRolling and not Dice[i].applied then
                    if Dice[i].die:getNumber() == 6 then
                        SixStreak = SixStreak + 1
                        Achievements.SetMax("extreme_luck", SixStreak)
                    else
                        SixStreak = 0
                    end
                    if Dice[i].example ~= 1 then
                        if Dice[i].operation == "add" then
                            Stats[Dice[i].stat] = math.max(0, Stats[Dice[i].stat] + Dice[i].die:getNumber())
                            Achievements.SetMax("max_attack", Stats.Attack)
                            Achievements.SetMax("max_defense", Stats.Defense)
                            Achievements.SetMax("max_luck", Stats.Luck)
                        elseif Dice[i].operation == "sub" then
                            Stats[Dice[i].stat] = math.max(0, Stats[Dice[i].stat] - Dice[i].die:getNumber())
                            if Stats.Defense < 1 then
                                Achievements.Advance("low_defense")
                            end
                        elseif Dice[i].operation == "div" then
                            Stats[Dice[i].stat] = math.max(0, Stats[Dice[i].stat] / Dice[i].die:getNumber())
                            if Stats.Defense < 1 then
                                Achievements.Advance("low_defense")
                            end
                        elseif Dice[i].operation == "mul" then
                            Stats[Dice[i].stat] = math.max(0, Stats[Dice[i].stat] * Dice[i].die:getNumber())
                            Achievements.SetMax("max_attack", Stats.Attack)
                            Achievements.SetMax("max_defense", Stats.Defense)
                            Achievements.SetMax("max_luck", Stats.Luck)
                        end
                    end
                    Dice[i].applied = true
                    if Dice[i].operation == "add" or Dice[i].operation == "mul" then
                        beep("good_dice", 1046.5022612023945, 0, 8, 0.25*Settings.audio.sound_volume/100)
                    else
                        boom("bad_dice", 32, 0.01, 8, 0.25*Settings.audio.sound_volume/100)
                    end
                end
                if Dice[i].die.timeSinceCompletion >= 2 then
                    table.remove(Dice, i)
                    DiceDisplayPosition = DiceDisplayPosition - 1
                    i = i - 1
                end
                i = i + 1
            end
            local blend = math.pow( (1/((8/7)^60)), dt)
            do
                local b,a = #Dice,DiceDisplayPosition
                DiceDisplayPosition = blend*(a-b)+b
            end
            do
                local b,a = math.max(1, (#Dice)*64*Settings.video.ui_scale/love.graphics.getWidth()), DiceDisplaySize
                DiceDisplaySize = blend*(a-b)+b
            end
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
            Achievements.SetMax("max_stats", Stats.Luck+Stats.Attack+Stats.Defense)

            for _,ent in pairs(Entities) do
                ent:update(dt)
                if ent.id == "player" then
                    ent.hp = math.min(ent.maxhp, ent.hp + dt*2)
                end
            end
            if player.hp <= 0 and Gamemode == "calm" then
                player.hp = 1
            end

            local stats = {}
            for t,v in pairs(Stats) do
                table.insert(stats, t)
            end

            local pool = GetPoolByID(Settings.gameplay.dice_mode)
            local ops = pool.Operators

            local e = 1
            while e <= #Entities do
                if Entities[e].hp <= 0 then
                    if Entities[e].id ~= "player" then
                        if #GetEntitiesWithID("player") > 0 then
                            if Entities[e].data.lastAttacker == player.uid then
                                table.insert(Dice, {die = Game.Die:new(), stat = stats[love.math.random(1, #stats)], operation = ops[love.math.random(1, #ops)]})
                                if not Moved then
                                    Achievements.Advance("no_movement")
                                end
                                if #GetEntitiesWithID("enemy")-1 <= 0 then
                                    SpawnTimer = math.max(SpawnTimer, SpawnDelay-5)
                                end
                            end
                            Score = Score + 1
                            DiscordPresence.state = "Score: " .. Score
                            TutorialValues["Score"] = Score
                        end
                    elseif Entities[e] == player then
                        IsDead = true
                        setSelection(gameOverMenu)
                    end
                    table.remove(Entities, e)
                    boom("kill", 2, 0.005, 4, 0.5*Settings.audio.sound_volume/100)
                    e = e - 1
                end
                e = e + 1
            end
        end

        do
            local blend = math.pow(1/(16^4), dt)
            Camera.x = blend*(Camera.x-Camera.tx)+Camera.tx
            Camera.y = blend*(Camera.y-Camera.ty)+Camera.ty
        end

        do
            local tBlendAmt = 1/((5/4)^60)
            local blend = math.pow(tBlendAmt, dt)
            VisualSpawnTimer = blend*(VisualSpawnTimer-SpawnTimer)+SpawnTimer
        end

        if Spectating then
            local mx = (love.keyboard.isDown("d") and 1 or 0) - (love.keyboard.isDown("a") and 1 or 0)
            local my = (love.keyboard.isDown("s") and 1 or 0) - (love.keyboard.isDown("w") and 1 or 0)
            if ShowMobileUI then
                mx = Thumbstick.x/(Thumbstick.outerRad*ViewScale*Settings.video.ui_scale)
                my = Thumbstick.y/(Thumbstick.outerRad*ViewScale*Settings.video.ui_scale)
            end
            Camera.tx = Camera.tx + mx*dt*64*6
            Camera.ty = Camera.ty + my*dt*64*6
        end
    else
        for _,particle in ipairs(Particles) do
            particle.time = particle.time + dt
        end
        for _,indicator in ipairs(DamageIndicators) do
            indicator.time = indicator.time + dt
        end
    end

    if hadPlayer and #GetEntitiesWithID("player") <= 0 then
        -- Just died
        Events.fire("player_death", {x = player.x, y = player.y})
        if Gamemode == "default" then
            Achievements.SetMax("default_6_waves", Score)
            Achievements.SetMax("default_10_waves", Score)
            Achievements.SetMax("default_30_waves", Score)
            Achievements.SetMax("default_50_waves", Score)
            if Score == 0 then
                Achievements.Advance("die_early")
            end
        end
        if Gamemode == "tutorial" then
            Achievements.Advance("die_tutorial")
        end
    end
    hadPlayer = #GetEntitiesWithID("player") > 0
end

function scene.keypressed(k)
    -- if k == "k" then
    --     if #GetEntitiesWithID("player") > 0 then
    --         player.hp = -1
    --         -- boom("kill_player", 2, 0.005, 4, 0.5*Settings.Audio.Sound Volume/100)
    --     end
    -- end
    if k == "escape" then
        if Gamemode == "playtest" then
            SceneManager.LoadScene("scenes/menu", {menu = "customize"})
        end
        if #GetEntitiesWithID("player") > 0 or Spectating then
            Paused = not Paused
            ShowGameMenu = not ShowGameMenu
            if ShowGameMenu then
                setSelection(pauseMenu)
            end
        else
            Net.Disconnect()
            SceneManager.LoadScene("scenes/menu")
        end
    end
    if k == "space" and not Paused and Gamemode == "tutorial" then
        AttemptTutorialAdvance(true)
    end
    if k == "space" and #GetEntitiesWithID("player") == 0 and not Spectating then
        if GameSetups[Gamemode].canRespawn then
            AddNewPlayer(Settings.customization, Gamemode == "calm" or Gamemode == "tutorial")
            IsDead = false
        elseif IsMultiplayer then
            Spectating = true
        else
            SceneManager.LoadScene("scenes/game", {mode=Gamemode})
            frame = 0
        end
    end
    if not Paused then
        if table.index(MatchControl({type = "key", button = k}), "skip_wave") and (runTimer and Spawned < 5) then
            SpawnTimer = SpawnDelay
        end
        if table.index(MatchControl({type = "key", button = k}), "slash") and player then
            local mx = GetControlValue("move_right")-GetControlValue("move_left")
            local my = GetControlValue("move_down")-GetControlValue("move_up")
            local x,y = mx*96+love.graphics.getWidth()/2,my*96+love.graphics.getHeight()/2
            player.callbacks.slash(player,x,y)
        end
    end
    -- if k == "b" then
    --     local stats = player:get("stats")
    --     table.insert(Dice, {die = Game.Die:new(), stat = stats[love.math.random(1, #stats)], operation = "add"})
    --     table.insert(Dice, {die = Game.Die:new(), stat = stats[love.math.random(1, #stats)], operation = "mul"})
    --     table.insert(Dice, {die = Game.Die:new(), stat = stats[love.math.random(1, #stats)], operation = "sub"})
    --     table.insert(Dice, {die = Game.Die:new(), stat = stats[love.math.random(1, #stats)], operation = "div"})
    -- end
end

function scene.mousepressed(x, y, b, t, p)
    if not Paused then
        if IsDead and not Spectating then
            local screenWidth = 1280
            local screenHeight = 720
            local centerpoint = {
                love.graphics.getWidth()/2,
                love.graphics.getHeight()/2
            }
            local scale = math.min(love.graphics.getWidth()/screenWidth, love.graphics.getHeight()/screenHeight)
            local m_x = (x-centerpoint[1])/scale
            local m_y = (y-centerpoint[2])/scale
            gameOverMenu:click(m_x,m_y,b)
            -- local my = (love.graphics.getHeight()-lgfont:getHeight())/2+lgfont:getHeight()*2
            -- local itm = math.floor((y-my)/lrfont:getHeight())
            -- if itm == 0 then
            --     if GameSetups[Gamemode].canRespawn then
            --         AddNewPlayer(Settings.customization, Gamemode == "calm" or Gamemode == "tutorial")
            --         IsDead = false
            --     elseif IsMultiplayer then
            --         Spectating = true
            --     else
            --         SceneManager.LoadScene("scenes/game", {mode=Gamemode})
            --     end
            -- end
            -- if itm == 1 then
            --     Net.Disconnect()
            --     SceneManager.LoadScene("scenes/menu")
            -- end
        else
            if not t then
                if table.index(MatchControl({type = "mouse", button = b}), "skip_wave") and (runTimer and Spawned < 5) then
                    SpawnTimer = SpawnDelay
                end
                if table.index(MatchControl({type = "mouse", button = b}), "slash") and player then
                    player.callbacks.slash(player,x,y)
                end
                for _,ent in pairs(Entities) do
                    ent:mousepressed(x,y,b)
                end
            end
        end
    else
        local screenWidth = 1280
        local screenHeight = 720
        local centerpoint = {
            love.graphics.getWidth()/2,
            love.graphics.getHeight()/2
        }
        local scale = math.min(love.graphics.getWidth()/screenWidth, love.graphics.getHeight()/screenHeight)
        local m_x = (x-centerpoint[1])/scale
        local m_y = (y-centerpoint[2])/scale
        pauseMenu:click(m_x,m_y,b)
        -- local my = (love.graphics.getHeight()-lgfont:getHeight())/2
        -- local itm = math.floor((y-my)/lrfont:getHeight())
        -- if itm == 0 then
        --     Paused = not Paused
        --     ShowGameMenu = not ShowGameMenu
        -- end
        -- if itm == 1 then
        --     SceneManager.LoadScene("scenes/game", {mode = Gamemode})
        -- end
        -- if itm == 2 then
        --     Net.Disconnect()
        --     SceneManager.LoadScene("scenes/menu")
        -- end
    end
end

function scene.draw()
    local objOnscreen = 0
    local entOnscreen = 0
    local lw = love.graphics.getLineWidth()
    love.graphics.setLineWidth(2)
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.scale(ViewScale)
    love.graphics.translate(-love.graphics.getWidth()/2, -love.graphics.getHeight()/2)
    local hit = {}
    for x = -math.ceil((love.graphics.getWidth()/ViewScale)/2/64+1), math.ceil((love.graphics.getWidth()/ViewScale)/2/64+1) do
        for y = -math.ceil((love.graphics.getHeight()/ViewScale)/2/64+1), math.ceil((love.graphics.getHeight()/ViewScale)/2/64+1) do
            local rx = x + math.floor(Camera.x/64)
            local ry = y + math.floor(Camera.y/64)
            local ox = -32-Camera.x+(love.graphics.getWidth())/2+rx*64
            local oy = -32-Camera.y+(love.graphics.getHeight())/2+ry*64
            local show = true
            local color = {1,1,1}
            if Gamemode == "tutorial" and (rx*64 > tutorialBounds or ry*64 > tutorialBounds or rx*64 < -tutorialBounds or ry*64 < -tutorialBounds) then
                local c = math.round(love.math.noise(rx/2,-ry/2))*0.5+0.5
                color = {c,c,c}
                local d = math.max(math.abs(rx*64)-tutorialBounds,math.abs(ry*64)-tutorialBounds)/64-3
                local n = love.math.noise(rx/4,ry/4)*(1-d/16)
                if n < 0.5 then
                    show = false
                end
            end
            love.graphics.setColor(
                Settings.video.background_brightness*color[1]*math.min(1,math.round((rx/Background[1][4]+ry/Background[1][5]+Background[1][3])%Background[1][2]*Background[1][1])),
                Settings.video.background_brightness*color[2]*math.min(1,math.round((rx/Background[2][4]+ry/Background[2][5]+Background[2][3])%Background[2][2]*Background[2][1])),
                Settings.video.background_brightness*color[3]*math.min(1,math.round((rx/Background[3][4]+ry/Background[3][5]+Background[3][3])%Background[3][2]*Background[3][1]))
            )
            local r,g,b,a = love.graphics.getColor()
            if not (r == 0 and g == 0 and b == 0) then
                if show and ox >= -64-((love.graphics.getWidth()/2)/ViewScale-love.graphics.getWidth()/2) and ox < love.graphics.getWidth()/ViewScale and oy >= -64-((love.graphics.getHeight()/2)/ViewScale-love.graphics.getHeight()/2) and oy < love.graphics.getHeight()/ViewScale then
                    if hit[ox..":"..oy] then
                        love.graphics.rectangle("line", ox, oy, 32,32)
                    else
                        love.graphics.rectangle("line", ox, oy, 64, 64)
                    end
                    hit[ox..":"..oy] = true
                    objOnscreen = objOnscreen + 1
                end
            end
        end
    end
    if Gamemode == "tutorial" then
        love.graphics.setLineWidth(16)
        local ox = -32-Camera.x+(love.graphics.getWidth())/2-tutorialBounds
        local oy = -32-Camera.y+(love.graphics.getHeight())/2-tutorialBounds
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("line", ox, oy, tutorialBounds*2+64, tutorialBounds*2+64)
    end
    love.graphics.setLineWidth(4)
    love.graphics.setColor(1,1,1)
    for _,orb in pairs(Particles) do
        local x,y = orb.x-Camera.x+love.graphics.getWidth()/2, orb.y-Camera.y+love.graphics.getHeight()/2
        local scale = (orb.lifespan-(love.timer.getTime()-orb.time))*16/(orb.lifespan/0.5)
        if orb.image then
            love.graphics.draw(orb.image, x, y, orb.angle, scale*orb.size, scale*orb.size, orb.image:getWidth()/2, orb.image:getHeight()/2)
        else
            love.graphics.setColor(1,1,1)
            love.graphics.circle("fill", x, y, scale*orb.size)
        end
    end
    for _,entity in pairs(Entities) do
        if entity.callbacks.draw then
            entity.callbacks.draw(entity)
            entOnscreen = entOnscreen + 1
            goto continue
        end
        local scale = 64
        if entity.id == "enemy" then
            scale = 48
        end
        local x = entity.x-Camera.x+(love.graphics.getWidth()-scale)/2
        local y = entity.y-Camera.y+(love.graphics.getHeight()-scale)/2
        if x >= -scale-((love.graphics.getWidth()/2)/ViewScale-love.graphics.getWidth()/2) and x < love.graphics.getWidth()/ViewScale and y >= -scale-((love.graphics.getHeight()/2)/ViewScale-love.graphics.getHeight()/2) and y < love.graphics.getHeight()/ViewScale then
            love.graphics.setColor(1,1,1)
            if entity.id == "player" then
                local c = entity:get("color") or {0,1,1}
                love.graphics.setColor(c)
            end
            if entity:get("slashTime") and entity:get("slashTime") >= 0 then
                love.graphics.setColor(1,0,0)
            end
            if entity.invincibility > 0 then
                local r,g,b,a = love.graphics.getColor()
                love.graphics.setColor(r,g,b,0.5)
            end
            love.graphics.rectangle("fill", x, y, scale, scale)
            if entity:get("netinfo") then
                love.graphics.setColor(1,1,1)
                local name = (entity:get("netinfo") or {}).name or "???"
                love.graphics.setFont(lgfont)
                love.graphics.printf(name,x+scale/2-64,y-lgfont:getHeight()-8,128,"center")
            end

            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("fill", x-(96-scale)/2, y-scale/2-16, 96, 12)
            love.graphics.setColor(0,1,0)
            local fill = entity.hp / entity.maxhp
            love.graphics.rectangle("fill", x-(96-scale)/2, y-scale/2-16, 96*fill, 12)
            entOnscreen = entOnscreen + 1
        end
        ::continue::
    end
    love.graphics.setLineWidth(lw)
    
    love.graphics.setFont(lgfont_1x)
    for _,indicator in pairs(DamageIndicators) do
        love.graphics.setColor(indicator.color)
        local x = indicator.x - Camera.x + love.graphics.getWidth()/2
        local w = lgfont_1x:getWidth(tostring(indicator.amt))
        local y = indicator.y - Camera.y + love.graphics.getHeight()/2
        
        local ny = 1-(1-math.max(0, math.min(1, 2*(love.timer.getTime() - indicator.time))))^5
        local ds = (1-math.max(0, math.min(1, 2*((love.timer.getTime() - indicator.time)-1))))^5
        love.graphics.printf(indicator.amt, x, y-ny*48, w, "center", 0, ds, ds, w/2, 32)
    end
    love.graphics.pop()

    for i,die in ipairs(Dice) do
        local s = DiceDisplaySize
        local ds = (1-math.max(0, math.min(1, 2*(die.die.timeSinceCompletion-1))))^5
        local ny = 1-(1-math.max(0, math.min(1, 2*(die.die.timeSinceCompletion))))^5
        local x = love.graphics.getWidth()-((DiceDisplayPosition-(i)+1)*64*Settings.video.ui_scale/s) + 32*Settings.video.ui_scale/s
        local y = love.graphics.getHeight()-32*Settings.video.ui_scale/s
        local r,g,b = 1,1,1
        if Settings.video.color_by_operator then
            if die.operation == "mul" then
                r,g,b = 0,1,0
            end
            if die.operation == "sub" then
                r,g,b = 1,0.875,0.05
            end
            if die.operation == "div" then
                r,g,b = 1,0,0
            end
        else
            if die.operation == "div" or die.operation == "sub" then
                r,g,b = 1,0,0
            end
        end

        if die.die:getNumber() then
            love.graphics.setColor(r,g,b)
            love.graphics.setFont(smfont)
            love.graphics.printf(Localize("dice."..die.operation):format(Localize("stat." .. (die.stat or ""):lower()), die.die.number), x, y+32*Settings.video.ui_scale/s-love.graphics.getFont():getHeight()*Settings.video.ui_scale/s/2-ny*48*Settings.video.ui_scale/s, 64, "center", 0, Settings.video.ui_scale/s*ds, Settings.video.ui_scale/s*ds, 32, 32)
        end
        love.graphics.setColor(r,g,b,1)
        if not die.die:getNumber() then
            love.graphics.setColor(r,g,b,0.5)
        end
        love.graphics.draw(DieImages[die.die.number], x, y, 0, Settings.video.ui_scale/s*ds, Settings.video.ui_scale/s*ds, 32, 32)
    end

    love.graphics.setColor(1,1,1)
    if player then
        local Stats = player:get("stats")
        love.graphics.setFont(lgfont)
        local pos = 0
        local order = {
            "Attack",
            "Defense",
            "Luck"
        }
        for _,name in ipairs(order) do
            love.graphics.print(Localize("stat.display"):format(Localize("stat." .. name:lower()),math.round(Stats[name]*100)/100), 0, pos)
            pos = pos + lgfont:getHeight()
        end
    end
    
    love.graphics.print(Localize("score"):format(Score), 0, love.graphics.getHeight()-lgfont:getHeight())

    love.graphics.setFont(lgfont)
    local pos = 0
    if showTimer then
        love.graphics.printf(Localize(TimerDisplay[timerType] or ""):format(timerString(math.ceil((SpawnDelay - SpawnTimer)))), 0, 0, love.graphics.getWidth(), "center")
        local fill = 1-((Settings.video.smooth_timer and VisualSpawnTimer or SpawnTimer)/SpawnDelay)
        love.graphics.setColor(0.25,0.25,0.25)
        local barWidth = IsMobile and 1024 or 512
        local barHeight = (IsMobile and 32 or 16)*Settings.video.ui_scale/1.5
        love.graphics.rectangle("fill", (love.graphics.getWidth()-barWidth)/2, lgfont:getHeight(), barWidth, barHeight*ViewScale)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", (love.graphics.getWidth()-barWidth)/2, lgfont:getHeight(), barWidth*fill, barHeight*ViewScale)
        if ShowMobileUI then
            love.graphics.draw(FastForwardIcon, (love.graphics.getWidth()+barWidth)/2 + barHeight, lgfont:getHeight()-barHeight/2, 0, barHeight*2/FastForwardIcon:getWidth(), barHeight*2/FastForwardIcon:getHeight())
        end
        pos = pos + lgfont:getHeight()+barHeight
    end

    if Gamemode == "playtest" then
        love.graphics.setColor(0,0,0)
        local txt = Localize("playtesting" .. (IsMobile and "_mobile" or ""))
        pcall(love.graphics.printf, txt, 0, pos-2, love.graphics.getWidth(), "center")
        pcall(love.graphics.printf, txt, 0, pos-2, love.graphics.getWidth(), "center")
        pcall(love.graphics.printf, txt, 0, pos+2, love.graphics.getWidth(), "center")
        pcall(love.graphics.printf, txt, 0, pos+2, love.graphics.getWidth(), "center")
        local t = ((math.sin(love.timer.getTime()*math.pi)+1)/2)*0.5+0.5
        love.graphics.setColor(t,t,t)
        love.graphics.printf(txt, 0, pos, love.graphics.getWidth(), "center")
        love.graphics.setColor(1,1,1)
    end

    love.graphics.setFont(lgfont)
    if Gamemode == "tutorial" then
        love.graphics.setColor(0,0,0)
        pcall(love.graphics.printf, TutorialText, 148, pos-2, love.graphics.getWidth()-300, "center")
        pcall(love.graphics.printf, TutorialText, 152, pos-2, love.graphics.getWidth()-300, "center")
        pcall(love.graphics.printf, TutorialText, 152, pos+2, love.graphics.getWidth()-300, "center")
        pcall(love.graphics.printf, TutorialText, 148, pos+2, love.graphics.getWidth()-300, "center")
        love.graphics.setColor(1,1,1)
        pcall(love.graphics.printf, TutorialText, 150, pos, love.graphics.getWidth()-300, "center")

        local format = TutorialStages[Stage].messages[Message].format or {}
        if type(format) == "function" then format = format() end
        for i,v in ipairs(format) do
            if type(v) == "function" then format[i] = v() end
        end
        local stageText = TutorialStages[Stage].messages[Message].text
        if type(stageText) == "function" then stageText = stageText() end
        local txt = Localize(stageText):format(unpack(format))
        if MessageProgress >= utf8.len(txt) and TutorialStages[Stage].messages[Message].pause then
            local w,l = lgfont:getWrap(txt, love.graphics.getWidth()-300)
            local h = #l*lgfont:getHeight()
            local advance = Localize("tutorial.advance." .. (IsMobile and "mobile" or ((Gamepads[1] ~= nil) and "gamepad" or "desktop")))
            if not IsMobile then
                local strings = GetControlStrings("advance_text")
                advance = advance:format(strings[(Gamepads[1] ~= nil) and "gamepad" or "desktop"])
            end
            love.graphics.setFont(mdfont)

            love.graphics.setColor(0,0,0)
            love.graphics.printf(advance, 148, pos-2 + h, love.graphics.getWidth()-300, "center")
            love.graphics.printf(advance, 152, pos-2 + h, love.graphics.getWidth()-300, "center")
            love.graphics.printf(advance, 152, pos+2 + h, love.graphics.getWidth()-300, "center")
            love.graphics.printf(advance, 148, pos+2 + h, love.graphics.getWidth()-300, "center")
            local t = ((math.sin(love.timer.getTime()*math.pi)+1)/2)*0.5+0.5
            love.graphics.setColor(t,t,t)
            love.graphics.printf(advance, 150, pos + h, love.graphics.getWidth()-300, "center")
            
            love.graphics.setFont(lgfont)
        end
    end

    if ShowMobileUI then
        love.graphics.setColor(1,1,1)
        love.graphics.setLineWidth(8)
        love.graphics.circle("line", Thumbstick.outerRad*ViewScale*Settings.video.ui_scale+96, love.graphics.getHeight()-Thumbstick.outerRad*ViewScale*Settings.video.ui_scale-96, Thumbstick.outerRad*ViewScale*Settings.video.ui_scale)
        love.graphics.circle("fill", Thumbstick.outerRad*ViewScale*Settings.video.ui_scale+96+Thumbstick.x, love.graphics.getHeight()-Thumbstick.outerRad*ViewScale*Settings.video.ui_scale-96+Thumbstick.y, Thumbstick.innerRad*ViewScale*Settings.video.ui_scale)
        love.graphics.setLineWidth(8)
        if not Spectating then
            love.graphics.circle("line", love.graphics.getWidth()-Slashstick.radius*ViewScale*Settings.video.ui_scale-96, love.graphics.getHeight()-Slashstick.radius*ViewScale*Settings.video.ui_scale-96, Slashstick.radius*ViewScale*Settings.video.ui_scale)
            love.graphics.draw(SlashIcon, love.graphics.getWidth()-Slashstick.radius*ViewScale*Settings.video.ui_scale-96, love.graphics.getHeight()-Slashstick.radius*ViewScale*Settings.video.ui_scale-96, 0, (Slashstick.radius*Settings.video.ui_scale*2)/SlashIcon:getWidth(), (Slashstick.radius*Settings.video.ui_scale*2)/SlashIcon:getHeight(), SlashIcon:getWidth()/2, SlashIcon:getHeight()/2)
        end
        love.graphics.rectangle("line", love.graphics.getWidth()-Pausebutton.size*ViewScale*Settings.video.ui_scale-64, 64, Pausebutton.size*ViewScale*Settings.video.ui_scale, Pausebutton.size*ViewScale*Settings.video.ui_scale)
        love.graphics.draw(PauseIcon, love.graphics.getWidth()-Pausebutton.size*ViewScale*Settings.video.ui_scale-64, 64, 0, Pausebutton.size/PauseIcon:getWidth()*Settings.video.ui_scale, Pausebutton.size/PauseIcon:getHeight()*Settings.video.ui_scale)
    end

    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 0
    local rightMargin = 0
    local topMargin = 0
    local bottomMargin = 0
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min(love.graphics.getWidth()/screenWidth, love.graphics.getHeight()/screenHeight)
    love.graphics.push()
    love.graphics.translate(centerpoint[1], centerpoint[2])
    love.graphics.scale(scale,scale)

    if IsDead and not Spectating then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", -centerpoint[1]/scale, -centerpoint[2]/scale, love.graphics.getWidth()/scale, love.graphics.getHeight()/scale)
        love.graphics.setColor(1,1,1)
        gameOverMenu:draw()
        if Gamepads[1] then
            gameOverMenu:drawSelected()
        end
        local c = gameOverMenu:getCursor((love.mouse.getX()-centerpoint[1])/scale, (love.mouse.getY()-centerpoint[2])/scale) or "arrow"
        local s,r = pcall(love.mouse.getSystemCursor, c)
        if s then
            love.mouse.setCursor(r)
        end
        -- love.graphics.setFont(xlfont)
        -- love.graphics.printf(Localize("gameover.title"), 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2-xlfont:getHeight()*2, love.graphics.getWidth(), "center")
        -- love.graphics.setFont(lgfont)
        -- love.graphics.printf(Localize("score"):format(Score), 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2, love.graphics.getWidth(), "center")
        -- love.graphics.printf(Localize(GameSetups[Gamemode].canRespawn and "gameover.respawn" or (IsMultiplayer and "gameover.spectate" or "gameover.retry")), 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2+lgfont:getHeight()*2+lrfont:getHeight()*0, love.graphics.getWidth(), "center")
        -- love.graphics.printf(Localize("gameover.exit"), 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2+lgfont:getHeight()*2+lrfont:getHeight()*1, love.graphics.getWidth(), "center")
    end

    if ShowGameMenu then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", -centerpoint[1]/scale, -centerpoint[2]/scale, love.graphics.getWidth()/scale, love.graphics.getHeight()/scale)
        love.graphics.setColor(1,1,1)
        pauseMenu:draw()
        if Gamepads[1] then
            pauseMenu:drawSelected()
        end
        local c = pauseMenu:getCursor((love.mouse.getX()-centerpoint[1])/scale, (love.mouse.getY()-centerpoint[2])/scale) or "arrow"
        local s,r = pcall(love.mouse.getSystemCursor, c)
        if s then
            love.mouse.setCursor(r)
        end
        -- love.graphics.setFont(xlfont)
        -- love.graphics.printf(Localize("paused.title"), 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2-xlfont:getHeight()*2, love.graphics.getWidth(), "center")
        -- love.graphics.setFont(lgfont)
        -- love.graphics.printf(Localize("paused.resume"), 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2+lrfont:getHeight()*0, love.graphics.getWidth(), "center")
        -- love.graphics.printf(Localize("paused.restart"), 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2+lrfont:getHeight()*1, love.graphics.getWidth(), "center")
        -- love.graphics.printf(Localize("paused.exit"), 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2+lrfont:getHeight()*2, love.graphics.getWidth(), "center")
    end

    love.graphics.pop()
    
    love.graphics.setColor(1,1,1)
end

function scene.gamepadaxis(stick,axis,value)
    player:gamepadaxis(stick,axis,value)

    if ShowGameMenu or (IsDead and not Spectating) then
        local selection

        local menu = ShowGameMenu and pauseMenu or gameOverMenu

        if WasControlTriggered("menu_right") then
            selection = GetSelectionTarget({1,0}, menu, MenuSelection) or selection
        end
        if WasControlTriggered("menu_left") then
            selection = GetSelectionTarget({-1,0}, menu, MenuSelection) or selection
        end
        if WasControlTriggered("menu_down") then
            selection = GetSelectionTarget({0,1}, menu, MenuSelection) or selection
        end
        if WasControlTriggered("menu_up") then
            selection = GetSelectionTarget({0,-1}, menu, MenuSelection) or selection
        end
        
        if selection then
            MenuSelection = selection
        end
    end
    -- if axis == "triggerright" then
    --     if value >= 0.5 and lastTriggerValue < 0.5 then
    --         player:mousepressed(stick:getGamepadAxis("leftx")*96+love.graphics.getWidth()/2,stick:getGamepadAxis("lefty")*96+love.graphics.getHeight()/2,1)
    --     end
    --     lastTriggerValue = value
    -- end
end

function scene.gamepadpressed(stick,b)
    if frame < 2 then return end
    local controlMatches = MatchControl({type = "gpbutton", button = b})
    if table.index(controlMatches, "skip_wave") and (runTimer and Spawned < 5) then
        SpawnTimer = SpawnDelay
    end
    if table.index(controlMatches, "pause") then
        if Gamemode == "playtest" then
            SceneManager.LoadScene("scenes/menu", {menu = "customize"})
        end
        if not (IsDead and not Spectating) then
            Paused = not Paused
            ShowGameMenu = not ShowGameMenu
            if ShowGameMenu then
                setSelection(pauseMenu)
            end
        else
            -- if GameSetups[Gamemode].canRespawn then
            --     AddNewPlayer(Settings.customization, Gamemode == "calm" or Gamemode == "tutorial")
            --     IsDead = false
            -- elseif IsMultiplayer then
            --     Spectating = true
            -- else
            --     SceneManager.LoadScene("scenes/game", {mode=Gamemode})
            -- end
        end
    end
    -- if b == "back" then
    --     if Paused then
    --         Net.Disconnect()
    --         SceneManager.LoadScene("scenes/menu")
    --     end
    --     if #GetEntitiesWithID("player") == 0 then
    --         Net.Disconnect()
    --         SceneManager.LoadScene("scenes/menu")
    --     end
    -- end
    if table.index(controlMatches, "advance_text") and not Paused and Gamemode == "tutorial" then
        AttemptTutorialAdvance(true)
    end
    if not Paused then
        if table.index(MatchControl({type = "gpbutton", button = b}), "skip_wave") and (runTimer and Spawned < 5) then
            SpawnTimer = SpawnDelay
        end
        if table.index(MatchControl({type = "gpbutton", button = b}), "slash") and player then
            local mx = GetControlValue("move_right")-GetControlValue("move_left")
            local my = GetControlValue("move_down")-GetControlValue("move_up")
            local x,y = mx*96+love.graphics.getWidth()/2,my*96+love.graphics.getHeight()/2
            player.callbacks.slash(player,x,y)
        end
    end

    if ShowGameMenu or (IsDead and not Spectating) then
        local selection

        local menu = ShowGameMenu and pauseMenu or gameOverMenu

        local matches = MatchControl({type = "gpbutton", button = b})

        if table.index(matches, "menu_right") then
            selection = GetSelectionTarget({1,0}, menu, MenuSelection) or selection
        end
        if table.index(matches, "menu_left") then
            selection = GetSelectionTarget({-1,0}, menu, MenuSelection) or selection
        end
        if table.index(matches, "menu_down") then
            selection = GetSelectionTarget({0,1}, menu, MenuSelection) or selection
        end
        if table.index(matches, "menu_up") then
            selection = GetSelectionTarget({0,-1}, menu, MenuSelection) or selection
        end

        if selection then
            MenuSelection = selection
        end
    end

    if b == "a" then
        if ShowGameMenu or (IsDead and not Spectating) then
            if (MenuSelection or {}).element.clickInstance then
                (MenuSelection or {}).element:clickInstance()
            end
        end
    end
end

function scene.touchpressed(id,x,y)
    if frame < 2 then return end
    if Paused then return end
    local tx,ty = x-(Thumbstick.outerRad*ViewScale*ViewScale*Settings.video.ui_scale+64+Thumbstick.x),y-(love.graphics.getHeight()-Thumbstick.outerRad*ViewScale*ViewScale*Settings.video.ui_scale-64+Thumbstick.y)
    if math.sqrt(tx*tx+ty*ty) <= Thumbstick.outerRad*ViewScale*Settings.video.ui_scale then
        Thumbstick.pressed = id
        return
    end
    local sx,sy = x-(love.graphics.getWidth()-Slashstick.radius*ViewScale*ViewScale*Settings.video.ui_scale-64),y-(love.graphics.getHeight()-Slashstick.radius*ViewScale*ViewScale*Settings.video.ui_scale-64)
    if math.sqrt(sx*sx+sy*sy) <= Slashstick.radius*ViewScale*Settings.video.ui_scale and player then
        local mx = Thumbstick.x/(Thumbstick.outerRad*ViewScale*Settings.video.ui_scale)
        local my = Thumbstick.y/(Thumbstick.outerRad*ViewScale*Settings.video.ui_scale)
        local X,Y = mx*96+love.graphics.getWidth()/2,my*96+love.graphics.getHeight()/2
        player.callbacks.slash(player, X, Y)
        return
    end
    if x >= love.graphics.getWidth()-Pausebutton.size*ViewScale*Settings.video.ui_scale-64 and x < love.graphics.getWidth()-64 and y >= 64 and y < Pausebutton.size*ViewScale*Settings.video.ui_scale+64 then
        if Gamemode == "playtest" then
            SceneManager.LoadScene("scenes/menu", {menu = "customize"})
            return
        end
        Paused = not Paused
        ShowGameMenu = not ShowGameMenu
        if ShowGameMenu then
            setSelection(pauseMenu)
        end
        return
    end
    if not (IsDead and not Spectating) then
        if ShowMobileUI then
            local barWidth = 1024
            local barHeight = 32*Settings.video.ui_scale/1.5
            local skipX, skipY = (love.graphics.getWidth()+barWidth)/2 + barHeight, lgfont:getHeight()-barHeight/2
            if x >= skipX-16 and x < skipX + barHeight*2 + 16 and y >= skipY-16 and y < skipY + barHeight*2 + 16 then
                if (runTimer and Spawned < 5) then
                    SpawnTimer = SpawnDelay
                end
            end
        end
    end
    if not Paused and Gamemode == "tutorial" then
        AttemptTutorialAdvance(true)
    end
end

function scene.touchreleased(id,x,y)
    if Thumbstick.pressed == id then
        Thumbstick.pressed = nil
        Thumbstick.x = 0
        Thumbstick.y = 0
    end
end

function scene.touchmoved(id,x,y)
    local tx,ty = x-(Thumbstick.outerRad*ViewScale*ViewScale*Settings.video.ui_scale+64),y-(love.graphics.getHeight()-Thumbstick.outerRad*ViewScale*ViewScale*Settings.video.ui_scale-64)
    if Thumbstick.pressed == id then
        local m = math.sqrt(tx*tx+ty*ty)
        local n = math.min(Thumbstick.outerRad*ViewScale*Settings.video.ui_scale, m)
        Thumbstick.x = tx/m*n
        Thumbstick.y = ty/m*n
    end
end

return scene