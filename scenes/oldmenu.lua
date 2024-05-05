local scene = {}

love.keyboard.setKeyRepeat(true)

function SetMenu(m)
    CurrentMenu = m
    MenuSelection = 1
end

function scene.load()
    StopMusic()
    SusCombo = 0
    Sus = "sus"
    EnterTheSus = love.audio.newSource("assets/music/SUS.ogg", "stream")
    ExitTheSus = love.audio.newSource("assets/music/UNSUS.ogg", "stream")
    SusKill = love.audio.newSource("assets/music/AKill.ogg", "stream")
    MenuTime = 0

    Conversion = {
        ["w"] = "up",
        ["s"] = "down",
        ["a"] = "left",
        ["d"] = "right",
        ["space"] = "return"
    }
    
    Logo = love.graphics.newImage("assets/images/ui/logo-updated.png")
    LogoPos = love.graphics.getHeight()

    CurrentMenu = "MainMenu"
    MenuSelection = 1

    WeighingModes = {
        "Legacy",
        "Even",
        "Situational",
        "Unfair (NOT RECOMMENDED)",
        "[Secret] Blessed"
    }

    PlayModes = {
        {"Tutorial", "tutorial"},
        {"Default", "default"},
        {"Enemy Rush", "enemy_rush"}
    }
    if Achievements.IsUnlocked("default_30_waves") then
        table.insert(PlayModes, {"Calm Mode", "calm"})
    end
    if DebugMode then
        table.insert(PlayModes, {"[DBG] MP - Co-op", "coop"})
        table.insert(PlayModes, {"[DBG] MP - FFA", "ffa"})
        table.insert(PlayModes, {"[DBG] MP - TDM", "tdm"})
    end
    Events.fire("gamemodeInit")

    MenuScenes = {
        {
            objects = {
                {type = "player"}
            },
        }
    }

    -- TODO: evict this from the code
    Menus = {
        MainMenu = {
            buttons = {
                {
                    label = "Play",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("Play")
                        end
                    }
                },
                {
                    label = "Settings",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("Settings")
                        end
                    }
                },
                {
                    label = "Achievements",
                    callbacks = {
                        ["return"] = function()
                            SceneManager.LoadScene("scenes/achievements")
                        end
                    }
                },
                {
                    label = "Credits",
                    callbacks = {
                        ["return"] = function()
                            SceneManager.LoadScene("scenes/credits")
                        end
                    }
                },
                {label = ""},
                {
                    label = "Quit",
                    callbacks = {
                        ["return"] = function()
                            love.event.push("quit")
                        end
                    }
                }
            }
        },
        Play = {
            label = "Play",
            buttons = {
                {
                    label = "Singleplayer",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("Singleplayer")
                        end
                    }
                },
                {
                    label = "Multiplayer",
                    callbacks = {
                        ["return"] = function()
                            SceneManager.LoadScene("scenes/mpmenu")
                        end
                    }
                },
                {label = ""},
                {
                    label = "Back",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("MainMenu")
                        end
                    }
                }
            }
        },
        Singleplayer = {
            label = "Select Game Mode",
            buttons = {
                {label = ""},
                {
                    label = "Back",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("Play")
                        end
                    }
                }
            }
        },
        Settings = {
            label = "Settings",
            buttons = {
                {
                    label = "Video",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("S_Video")
                        end
                    }
                },
                {
                    label = "Audio",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("S_Audio")
                        end
                    }
                },
                {
                    label = "Gameplay",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("S_Gameplay")
                        end
                    }
                },
                {
                    label = "Customization",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("S_Customization")
                        end
                    }
                },
                {label = ""},
                {
                    label = "Back",
                    callbacks = {
                        ["return"] = function()
                            love.filesystem.write("settings.json", json.encode(Settings))
                            SetMenu("MainMenu")
                        end
                    }
                }
            }
        },
        S_Gameplay = {
            label = "Gameplay Settings",
            buttons = {
                {
                    label = {
                        {type = "text", value = "Dice Weighing Mode: "},
                        {type = "fromcode", value = function()
                            return WeighingModes[Settings["Gameplay"]["Dice Weighing Mode"]+1]
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            local shift = 1
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 10
                            end
                            local unlockBlessed = Achievements.IsUnlocked("extreme_luck")
                            Settings["Gameplay"]["Dice Weighing Mode"] = math.max(0, math.min(#WeighingModes-1-(unlockBlessed and 0 or 1), Settings["Gameplay"]["Dice Weighing Mode"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function(fast)
                            local shift = 1
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 10
                            end
                            local unlockBlessed = Achievements.IsUnlocked("extreme_luck")
                            Settings["Gameplay"]["Dice Weighing Mode"] = math.max(0, math.min(#WeighingModes-1-(unlockBlessed and 0 or 1), Settings["Gameplay"]["Dice Weighing Mode"] + shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {label = ""},
                {
                    label = {
                        {type = "text", value = "Auto Aim: "},
                        {type = "fromcode", value = function()
                            return Settings["Gameplay"]["Auto Aim"] and "On" or "Off"
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            if Settings["Gameplay"]["Auto Aim"] then
                                Settings["Gameplay"]["Auto Aim"] = false
                                love.filesystem.write("settings.json", json.encode(Settings))
                            end
                        end,
                        ["right"] = function(fast)
                            if not Settings["Gameplay"]["Auto Aim"] then
                                Settings["Gameplay"]["Auto Aim"] = true
                                love.filesystem.write("settings.json", json.encode(Settings))
                            end
                        end,
                        ["return"] = function()
                            Settings["Gameplay"]["Auto Aim"] = not Settings["Gameplay"]["Auto Aim"]
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {
                    label = {
                        {type = "text", value = "Auto Aim Limit: "},
                        {type = "fromcode", value = function()
                            return Settings["Gameplay"]["Auto Aim Limit"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            local shift = 5
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 15
                            end
                            Settings["Gameplay"]["Auto Aim Limit"] = math.max(0, math.min(180, Settings["Gameplay"]["Auto Aim Limit"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function(fast)
                            local shift = 5
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 15
                            end
                            Settings["Gameplay"]["Auto Aim Limit"] = math.max(0, math.min(180, Settings["Gameplay"]["Auto Aim Limit"] + shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {label = ""},
                {
                    label = "Back",
                    callbacks = {
                        ["return"] = function()
                            love.filesystem.write("settings.json", json.encode(Settings))
                            SetMenu("Settings")
                        end
                    }
                },
                {
                    label = "Return to Menu",
                    callbacks = {
                        ["return"] = function()
                            love.filesystem.write("settings.json", json.encode(Settings))
                            SetMenu("MainMenu")
                        end
                    }
                }
            }
        },
        S_Audio = {
            label = "Audio Settings",
            buttons = {
                {
                    label = {
                        {type = "text", value = "Sound Volume: "},
                        {type = "fromcode", value = function()
                            return Settings["Audio"]["Sound Volume"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            local shift = 1
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 10
                            end
                            Settings["Audio"]["Sound Volume"] = math.max(0, math.min(100, Settings["Audio"]["Sound Volume"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function(fast)
                            local shift = 1
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 10
                            end
                            Settings["Audio"]["Sound Volume"] = math.max(0, math.min(100, Settings["Audio"]["Sound Volume"] + shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {
                    label = {
                        {type = "text", value = "Music Volume: "},
                        {type = "fromcode", value = function()
                            return Settings["Audio"]["Music Volume"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            local shift = 1
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 10
                            end
                            Settings["Audio"]["Music Volume"] = math.max(0, math.min(100, Settings["Audio"]["Music Volume"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function(fast)
                            local shift = 1
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 10
                            end
                            Settings["Audio"]["Music Volume"] = math.max(0, math.min(100, Settings["Audio"]["Music Volume"] + shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {label = ""},
                {
                    label = "Back",
                    callbacks = {
                        ["return"] = function()
                            love.filesystem.write("settings.json", json.encode(Settings))
                            SetMenu("Settings")
                        end
                    }
                },
                {
                    label = "Return to Menu",
                    callbacks = {
                        ["return"] = function()
                            love.filesystem.write("settings.json", json.encode(Settings))
                            SetMenu("MainMenu")
                        end
                    }
                }
            }
        },
        S_Video = {
            label = "Video Settings",
            buttons = {
                {
                    label = {
                        {type = "text", value = "UI Scale: "},
                        {type = "fromcode", value = function()
                            return Settings["Video"]["UI Scale"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            local shift = 0.01
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 0.1
                            end
                            Settings["Video"]["UI Scale"] = math.max(0.25, math.min(3, Settings["Video"]["UI Scale"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function(fast)
                            local shift = 0.01
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 0.1
                            end
                            Settings["Video"]["UI Scale"] = math.max(0.25, math.min(3, Settings["Video"]["UI Scale"] + shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {
                    label = {
                        {type = "text", value = "Color by Operator: "},
                        {type = "fromcode", value = function()
                            return (Settings["Video"]["Color by Operator"] and "On") or "Off"
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            if Settings["Video"]["Color by Operator"] then
                                Settings["Video"]["Color by Operator"] = false
                                love.filesystem.write("settings.json", json.encode(Settings))
                            end
                        end,
                        ["right"] = function(fast)
                            if not Settings["Video"]["Color by Operator"] then
                                Settings["Video"]["Color by Operator"] = true
                                love.filesystem.write("settings.json", json.encode(Settings))
                            end
                        end,
                        ["return"] = function()
                            Settings["Video"]["Color by Operator"] = not Settings["Video"]["Color by Operator"]
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {label = ""},
                {
                    label = "Back",
                    callbacks = {
                        ["return"] = function()
                            love.filesystem.write("settings.json", json.encode(Settings))
                            SetMenu("Settings")
                        end
                    }
                },
                {
                    label = "Return to Menu",
                    callbacks = {
                        ["return"] = function()
                            love.filesystem.write("settings.json", json.encode(Settings))
                            SetMenu("MainMenu")
                        end
                    }
                }
            }
        },
        S_Customization = {
            label = "Customization Settings",
            buttons = {
                {
                    label = {
                        {type = "color", color = function()
                            return {
                                Settings["Customization"]["PlayerR"],
                                Settings["Customization"]["PlayerG"],
                                Settings["Customization"]["PlayerB"]
                            }
                        end},
                        {type = "text", value = "Player Color Preview"}
                    },
                    canClick = false
                },
                {
                    label = {
                        {type = "text", value = "Player Color (Red): "},
                        {type = "fromcode", value = function()
                            return Settings["Customization"]["PlayerR"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            local shift = 0.03125
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 0.125
                            end
                            Settings["Customization"]["PlayerR"] = math.max(0, math.min(1, Settings["Customization"]["PlayerR"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function(fast)
                            local shift = 0.03125
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 0.125
                            end
                            Settings["Customization"]["PlayerR"] = math.max(0, math.min(1, Settings["Customization"]["PlayerR"] + shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {
                    label = {
                        {type = "text", value = "Player Color (Green): "},
                        {type = "fromcode", value = function()
                            return Settings["Customization"]["PlayerG"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            local shift = 0.03125
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 0.125
                            end
                            Settings["Customization"]["PlayerG"] = math.max(0, math.min(1, Settings["Customization"]["PlayerG"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function(fast)
                            local shift = 0.03125
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 0.125
                            end
                            Settings["Customization"]["PlayerG"] = math.max(0, math.min(1, Settings["Customization"]["PlayerG"] + shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {
                    label = {
                        {type = "text", value = "Player Color (Blue): "},
                        {type = "fromcode", value = function()
                            return Settings["Customization"]["PlayerB"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function(fast)
                            local shift = 0.03125
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 0.125
                            end
                            Settings["Customization"]["PlayerB"] = math.max(0, math.min(1, Settings["Customization"]["PlayerB"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function(fast)
                            local shift = 0.03125
                            if love.keyboard.isDown("lshift") or fast then
                                shift = 0.125
                            end
                            Settings["Customization"]["PlayerB"] = math.max(0, math.min(1, Settings["Customization"]["PlayerB"] + shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {label = ""},
                {
                    label = "Back",
                    callbacks = {
                        ["return"] = function()
                            love.filesystem.write("settings.json", json.encode(Settings))
                            SetMenu("Settings")
                        end
                    }
                },
                {
                    label = "Return to Menu",
                    callbacks = {
                        ["return"] = function()
                            love.filesystem.write("settings.json", json.encode(Settings))
                            SetMenu("MainMenu")
                        end
                    }
                }
            }
        }
    }

    for _,mode in ipairs(PlayModes) do
        table.insert(Menus.Singleplayer.buttons, #Menus.Singleplayer.buttons-1, {
            label = mode[1],
            callbacks = {
                ["return"] = function()
                    SceneManager.LoadScene("scenes/game", {mode=mode[2]})
                end
            }
        })
    end
    
    local major,minor,rev,name = love.getVersion()
    MenuVersions = {
        {name = "The Slash of the Dice", version = tostring(version)}
    }

    Events.fire("menuloaded")
    DiscordPresence.details = "In the Menu"
    DiscordPresence.state = nil
    DiscordPresence.startTimestamp = DiscordPresence.currentScene == "menu" and DiscordPresence.startTimestamp or os.time()
    DiscordPresence.currentScene = "menu"

    if DebugMode then
    end

    table.insert(MenuVersions, {name = "LÖVE", version = major .. "." .. minor .. " (" .. name .. ")"})
end

function scene.update(dt)
    MenuTime = MenuTime + dt
    Achievements.SetMax("nothing_1_hr", MenuTime)
    Achievements.SetMax("nothing_2_hr", MenuTime)
    Achievements.SetMax("nothing_10_hr", MenuTime)
    local blend = math.pow(1/(16^3), dt)
    LogoPos = blend*(LogoPos-16)+16
    -- LogoPos = LogoPos - ((LogoPos-16)/8)
end

function scene.draw()
    love.graphics.setColor(1,1,1)
    if not IsMobile then
        love.graphics.setShader(BGShader)
        BGShader:send("time", GlobalTime*48)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    else
        love.graphics.draw(MenuBGMobile, -((GlobalTime*48)%192), -((GlobalTime*48)%192))
    end
    love.graphics.draw(Logo, love.graphics.getWidth()/2, LogoPos, 0, Settings["Video"]["UI Scale"], Settings["Video"]["UI Scale"], Logo:getWidth()/2, 0)
    love.graphics.setFont(xlfont)
    if Menus[CurrentMenu].label then
        love.graphics.printf(Menus[CurrentMenu].label, 0, LogoPos + Logo:getHeight()*Settings["Video"]["UI Scale"], love.graphics.getWidth(), "center")
        if Menus[CurrentMenu].icon then
            love.graphics.draw(Menus[CurrentMenu].icon, (love.graphics.getWidth()-xlfont:getWidth(Menus[CurrentMenu].label))/2-xlfont:getHeight()*1.5, LogoPos + Logo:getHeight()*Settings["Video"]["UI Scale"], 0, xlfont:getHeight()/Menus[CurrentMenu].icon:getWidth(), xlfont:getHeight()/Menus[CurrentMenu].icon:getHeight())
        end
    end
    love.graphics.setFont(lrfont)
    local iconSize = lrfont:getHeight()
    local c = "arrow"
    for i,v in ipairs(Menus[CurrentMenu].buttons) do
        local label,col = ParseLabel(v.label)
        love.graphics.setColor(col or {1,1,1})
        local r,g,b,a = love.graphics.getColor()
        love.graphics.setColor(r,g,b,a*0.5)
        if i == MenuSelection or (v.canClick == false) then
            love.graphics.setColor(r,g,b,a)
        end
        if i == MenuSelection and v.canClick ~= false and (#label > 0) then
            c = "hand"
        end
        local y = LogoPos + (love.graphics.getHeight()-lrfont:getHeight()*(#Menus[CurrentMenu].buttons-4))/2 + lrfont:getHeight()*(i-1)
        love.graphics.printf(label, 0, y, love.graphics.getWidth(), "center")
        if v.icon then
            love.graphics.draw(v.icon, (love.graphics.getWidth()-lrfont:getWidth(label))/2-iconSize, y, 0, iconSize/v.icon:getWidth(), iconSize/v.icon:getHeight())
        end
        if IsMobile then
            if v.callbacks and not v.callbacks["return"] then
                if v.callbacks.right then
                    love.graphics.draw(ForwardIcon, (love.graphics.getWidth()+lrfont:getWidth(label))/2+iconSize, y, 0, iconSize/ForwardIcon:getWidth(), iconSize/ForwardIcon:getHeight())
                    love.graphics.draw(FastForwardIcon, (love.graphics.getWidth()+lrfont:getWidth(label))/2+iconSize*3, y, 0, iconSize/FastForwardIcon:getWidth(), iconSize/FastForwardIcon:getHeight())
                end
                if v.callbacks.left then
                    love.graphics.draw(BackIcon, (love.graphics.getWidth()-lrfont:getWidth(label))/2-iconSize*2, y, 0, iconSize/BackIcon:getWidth(), iconSize/BackIcon:getHeight())
                    love.graphics.draw(FastBackIcon, (love.graphics.getWidth()-lrfont:getWidth(label))/2-iconSize*4, y, 0, iconSize/FastBackIcon:getWidth(), iconSize/FastBackIcon:getHeight())
                end
            end
        end
    end
    love.mouse.setCursor(love.mouse.getSystemCursor(c))

    love.graphics.setColor(1,1,1)
    if Achievements.IsUnlocked("default_50_waves") then
        love.graphics.draw(Trophy, 32, love.graphics.getHeight()-32-128-32, 0, 128/Trophy:getWidth(), 128/Trophy:getHeight())
    end
    
    love.graphics.setFont(smfont)
    for i,v in ipairs(MenuVersions) do
        love.graphics.print(v.name .. " v" .. v.version .. (v.extra and (" - " .. table.concat(v.extra, ", "))or ""), 0, love.graphics.getHeight() - smfont:getHeight()*(#MenuVersions-i+1))
    end
    -- love.graphics.print("The Slash of the Dice v" .. tostring(version), 0, love.graphics.getHeight() - smfont:getHeight()*2)
    -- local major,minor,rev,name = love.getVersion()
    -- love.graphics.print("LÖVE v" .. major .. "." .. minor .. " (" .. name .. ")", 0, love.graphics.getHeight() - smfont:getHeight())

    if UpdateCheckFailed ~= 0 then
        love.graphics.setColor(1,0,0)
        love.graphics.print("UPDATE CHECKING FAILED WITH CODE " .. UpdateCheckFailed[1], 0, 0)
        local pos = 1
        for k,v in pairs(UpdateCheckFailed[2]) do
            love.graphics.print(tostring(k) .. ":" .. tostring(v), 0, pos*smfont:getHeight())
            pos = pos + 1
        end
    end

    if beta then
        love.graphics.setFont(lgfont)
        love.graphics.setColor(0,1,0)
        love.graphics.printf("BETA VERSION", 0, love.graphics.getHeight() - lgfont:getHeight(), love.graphics.getWidth(), "center")
    end
    if update[1] then
        love.graphics.setFont(lgfont)
        love.graphics.printf("An update is available!", 0, love.graphics.getHeight()-lgfont:getHeight()*2, love.graphics.getWidth(), "center")
        love.graphics.printf("New version: " .. update[2], 0, love.graphics.getHeight()-lgfont:getHeight(), love.graphics.getWidth(), "center")
    end
end

function ParseLabel(v)
    if type(v) == "string" then return v end
    local res = ""
    local color = {1,1,1}
    for _,i in pairs(v) do
        if i.type == "color" then
            color = i.color
            if type(color) == "function" then
                color = color()
            end
        end
        if i.type == "text" then
            res = res .. i.value
        end
        if i.type == "fromcode" then
            res = res .. tostring(i.value())
        end
    end
    return res,color
end

function scene.keypressed(k)
    if k == Sus:sub(SusCombo+1,SusCombo+1) then
        SusCombo = SusCombo + 1
        if SusCombo == #Sus then
            SusCombo = 0
            SusMode = not SusMode
            if SusMode then
                EnterTheSus:setVolume(Settings["Audio"]["Sound Volume"]/100)
                EnterTheSus:stop()
                EnterTheSus:play()
                Achievements.Advance("sus")
            else
                ExitTheSus:setVolume(Settings["Audio"]["Sound Volume"]/100)
                ExitTheSus:stop()
                ExitTheSus:play()
            end
        end
    end
    if Conversion[k] then
        k = Conversion[k]
    end
    MenuSelection = MenuSelection - 1
    if k == "down" then
        MenuSelection = (MenuSelection+1)%(#Menus[CurrentMenu].buttons)
        if not Menus[CurrentMenu].buttons[MenuSelection+1].callbacks then
            MenuSelection = (MenuSelection+1)%(#Menus[CurrentMenu].buttons)
        end
    end
    if k == "up" then
        MenuSelection = (MenuSelection-1)%(#Menus[CurrentMenu].buttons)
        if not Menus[CurrentMenu].buttons[MenuSelection+1].callbacks then
            MenuSelection = (MenuSelection-1)%(#Menus[CurrentMenu].buttons)
        end
    end
    MenuSelection = MenuSelection + 1

    if MenuSelection > 0 and MenuSelection <= #Menus[CurrentMenu].buttons then
        if Menus[CurrentMenu].buttons[MenuSelection].callbacks then
            if k ~= "down" and k ~= "up" then
                local callback = Menus[CurrentMenu].buttons[MenuSelection].callbacks[k]
                if callback then
                    callback()
                end
            end
        end
    end
end

function scene.mousemoved(x, y, dx, dy)
    local itmY = LogoPos+(love.graphics.getHeight()-lrfont:getHeight()*(#Menus[CurrentMenu].buttons-4))/2
    MenuSelection = math.floor((y-itmY)/lrfont:getHeight())+1
end

function scene.mousepressed(x, y)
    if MenuSelection > 0 and MenuSelection <= #Menus[CurrentMenu].buttons then
        if Menus[CurrentMenu].buttons[MenuSelection].callbacks then
            local calls = Menus[CurrentMenu].buttons[MenuSelection].callbacks
            local label = ParseLabel(Menus[CurrentMenu].buttons[MenuSelection].label or "")
            if IsMobile then
                local iconSize = lrfont:getHeight()
                local fwdX = (love.graphics.getWidth()+lrfont:getWidth(label))/2+iconSize
                local bckX = (love.graphics.getWidth()-lrfont:getWidth(label))/2-iconSize*2
                local f_fwdX = (love.graphics.getWidth()+lrfont:getWidth(label))/2+iconSize*3
                local f_bckX = (love.graphics.getWidth()-lrfont:getWidth(label))/2-iconSize*4
                if x >= fwdX and x < fwdX+iconSize and calls.right then
                    calls.right()
                end
                if x >= bckX and x < bckX+iconSize and calls.left then
                    calls.left()
                end
                if x >= f_fwdX and x < f_fwdX+iconSize and calls.right then
                    calls.right(true)
                end
                if x >= f_bckX and x < f_bckX+iconSize and calls.left then
                    calls.left(true)
                end
            end
            local callback = calls["return"]
            if callback then
                callback()
            end
            local itmY = LogoPos+(love.graphics.getHeight()-lrfont:getHeight()*(#Menus[CurrentMenu].buttons-4))/2
            MenuSelection = math.floor((y-itmY)/lrfont:getHeight())+1
        end
    end
end

function scene.wheelmoved(x, y)
    if MenuSelection > 0 and MenuSelection <= #Menus[CurrentMenu].buttons then
        if Menus[CurrentMenu].buttons[MenuSelection].callbacks then
            local k = (math.sign(y) == -1 and "left") or "right"
            local callback = Menus[CurrentMenu].buttons[MenuSelection].callbacks[k]
            if callback then
                callback()
            end
        end
    end
end

return scene