local scene = {}

smfont = love.graphics.getFont()
lgfont = love.graphics.newFont(24)
lrfont = love.graphics.newFont(32)
xlfont = love.graphics.newFont(48)

love.keyboard.setKeyRepeat(true)

function SetMenu(m)
    Menu = m
    MenuSelection = 1
end

function scene.load()
    StopMusic()

    Conversion = {
        ["w"] = "up",
        ["s"] = "down",
        ["a"] = "left",
        ["d"] = "right",
        ["space"] = "return"
    }
    
    Logo = love.graphics.newImage("assets/images/ui/logo-updated.png")
    LogoPos = love.graphics.getHeight()

    Menu = "MainMenu"
    MenuSelection = 1

    WeighingModes = {
        "Legacy",
        "Even",
        "Situational",
        "Unfair (NOT RECOMMENDED)"
    }

    Menus = {
        ["MainMenu"] = {
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
                    label = "Credits",
                    callbacks = {
                        ["return"] = function()
                            SceneManager.LoadScene("scenes/credits")
                        end
                    }
                },
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
        ["Play"] = {
            label = "Select Game Mode",
            buttons = {
                {
                    label = "Tutorial",
                    callbacks = {
                        ["return"] = function()
                            SceneManager.LoadScene("scenes/tutorial")
                        end
                    }
                },
                {
                    label = "Default",
                    callbacks = {
                        ["return"] = function()
                            SceneManager.LoadScene("scenes/game")
                        end
                    }
                },
                {
                    label = "Enemy Rush",
                    callbacks = {
                        ["return"] = function()
                            SceneManager.LoadScene("scenes/enemyrush")
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
        ["Settings"] = {
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
                {label = ""},
                {
                    label = "All Settings",
                    callbacks = {
                        ["return"] = function()
                            SetMenu("S_All")
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
        ["S_Gameplay"] = {
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
                        ["left"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Gameplay"]["Dice Weighing Mode"] = math.max(0, math.min(#WeighingModes-1, Settings["Gameplay"]["Dice Weighing Mode"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Gameplay"]["Dice Weighing Mode"] = math.max(0, math.min(#WeighingModes-1, Settings["Gameplay"]["Dice Weighing Mode"] + shift))
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
        ["S_Audio"] = {
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
                        ["left"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Audio"]["Sound Volume"] = math.max(0, math.min(100, Settings["Audio"]["Sound Volume"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
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
                        ["left"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Audio"]["Music Volume"] = math.max(0, math.min(100, Settings["Audio"]["Music Volume"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
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
        ["S_Video"] = {
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
                        ["left"] = function()
                            local shift = 0.01
                            if love.keyboard.isDown("lshift") then
                                shift = 0.1
                            end
                            Settings["Video"]["UI Scale"] = math.max(0.25, math.min(3, Settings["Video"]["UI Scale"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function()
                            local shift = 0.01
                            if love.keyboard.isDown("lshift") then
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
                        ["left"] = function()
                            if Settings["Video"]["Color by Operator"] then
                                Settings["Video"]["Color by Operator"] = false
                                love.filesystem.write("settings.json", json.encode(Settings))
                            end
                        end,
                        ["right"] = function()
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
        ["S_All"] = {
            label = "All Settings",
            buttons = {
                {
                    label = {
                        {type = "text", value = "UI Scale: "},
                        {type = "fromcode", value = function()
                            return Settings["Video"]["UI Scale"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function()
                            local shift = 0.01
                            if love.keyboard.isDown("lshift") then
                                shift = 0.1
                            end
                            Settings["Video"]["UI Scale"] = math.max(0.25, math.min(3, Settings["Video"]["UI Scale"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function()
                            local shift = 0.01
                            if love.keyboard.isDown("lshift") then
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
                        ["left"] = function()
                            if Settings["Video"]["Color by Operator"] then
                                Settings["Video"]["Color by Operator"] = false
                                love.filesystem.write("settings.json", json.encode(Settings))
                            end
                        end,
                        ["right"] = function()
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
                    label = {
                        {type = "text", value = "Sound Volume: "},
                        {type = "fromcode", value = function()
                            return Settings["Audio"]["Sound Volume"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Audio"]["Sound Volume"] = math.max(0, math.min(100, Settings["Audio"]["Sound Volume"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
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
                        ["left"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Audio"]["Music Volume"] = math.max(0, math.min(100, Settings["Audio"]["Music Volume"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Audio"]["Music Volume"] = math.max(0, math.min(100, Settings["Audio"]["Music Volume"] + shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end
                    }
                },
                {label = ""},
                {
                    label = {
                        {type = "text", value = "Dice Weighing Mode: "},
                        {type = "fromcode", value = function()
                            return WeighingModes[Settings["Gameplay"]["Dice Weighing Mode"]+1]
                        end}
                    },
                    callbacks = {
                        ["left"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Gameplay"]["Dice Weighing Mode"] = math.max(0, math.min(#WeighingModes-1, Settings["Gameplay"]["Dice Weighing Mode"] - shift))
                            love.filesystem.write("settings.json", json.encode(Settings))
                        end,
                        ["right"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Gameplay"]["Dice Weighing Mode"] = math.max(0, math.min(#WeighingModes-1, Settings["Gameplay"]["Dice Weighing Mode"] + shift))
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
end

function scene.update(dt)
    LogoPos = LogoPos - ((LogoPos-16)/8)
end

function scene.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(Logo, love.graphics.getWidth()/2, LogoPos, 0, Settings["Video"]["UI Scale"], Settings["Video"]["UI Scale"], Logo:getWidth()/2, 0)
    love.graphics.setFont(xlfont)
    if Menus[Menu].label then
        love.graphics.printf(Menus[Menu].label, 0, LogoPos + Logo:getHeight()*Settings["Video"]["UI Scale"] + xlfont:getHeight(), love.graphics.getWidth(), "center")
    end
    love.graphics.setFont(lrfont)
    local offset = 0
    if (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos + lrfont:getHeight()*(#Menus[Menu].buttons) > love.graphics.getHeight()-lrfont:getHeight() then
        offset = love.graphics.getHeight() - ((love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos + lrfont:getHeight()*(#Menus[Menu].buttons)) - lrfont:getHeight()
    end
    for i,v in ipairs(Menus[Menu].buttons) do
        love.graphics.setColor(1,1,1,0.5)
        if i == MenuSelection then
            love.graphics.setColor(1,1,1)
        end
        love.graphics.printf(ParseLabel(v.label), 0, offset + (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos + lrfont:getHeight()*(i-1), love.graphics.getWidth(), "center")
    end

    love.graphics.setFont(smfont)
    love.graphics.setColor(1,1,1)
    love.graphics.print("The Slash of the Dice v" .. tostring(version), 0, love.graphics.getHeight() - smfont:getHeight()*2)
    local major,minor,rev,name = love.getVersion()
    love.graphics.print("LÖVE v" .. major .. "." .. minor .. " (" .. name .. ")", 0, love.graphics.getHeight() - smfont:getHeight())

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
    for _,i in pairs(v) do
        if i.type == "text" then
            res = res .. i.value
        end
        if i.type == "fromcode" then
            res = res .. tostring(i.value())
        end
    end
    return res
end

function scene.keypressed(k)
    if Conversion[k] then
        k = Conversion[k]
    end
    MenuSelection = MenuSelection - 1
    if k == "down" then
        MenuSelection = (MenuSelection+1)%(#Menus[Menu].buttons)
        if not Menus[Menu].buttons[MenuSelection+1].callbacks then
            MenuSelection = (MenuSelection+1)%(#Menus[Menu].buttons)
        end
    end
    if k == "up" then
        MenuSelection = (MenuSelection-1)%(#Menus[Menu].buttons)
        if not Menus[Menu].buttons[MenuSelection+1].callbacks then
            MenuSelection = (MenuSelection-1)%(#Menus[Menu].buttons)
        end
    end
    MenuSelection = MenuSelection + 1

    if MenuSelection > 0 and MenuSelection <= #Menus[Menu].buttons then
        if Menus[Menu].buttons[MenuSelection].callbacks then
            if k ~= "down" and k ~= "up" then
                local callback = Menus[Menu].buttons[MenuSelection].callbacks[k]
                if callback then
                    callback()
                end
            end
        end
    end
end

function scene.mousemoved(x, y, dx, dy)
    local offset = 0
    if (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos + lrfont:getHeight()*(#Menus[Menu].buttons) > love.graphics.getHeight()-lrfont:getHeight() then
        offset = love.graphics.getHeight() - ((love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos + lrfont:getHeight()*(#Menus[Menu].buttons)) - lrfont:getHeight()
    end
    MenuSelection = math.floor((y-(offset + (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos))/lrfont:getHeight())+1
end

function scene.mousepressed(x, y)
    if MenuSelection > 0 and MenuSelection <= #Menus[Menu].buttons then
        if Menus[Menu].buttons[MenuSelection].callbacks then
            local callback = Menus[Menu].buttons[MenuSelection].callbacks["return"]
            if callback then
                callback()
            end
            MenuSelection = math.floor((y-((love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos))/lrfont:getHeight())+1
        end
    end
end

function scene.wheelmoved(x, y)
    if MenuSelection > 0 and MenuSelection <= #Menus[Menu].buttons then
        if Menus[Menu].buttons[MenuSelection].callbacks then
            local k = (math.sign(y) == -1 and "left") or "right"
            local callback = Menus[Menu].buttons[MenuSelection].callbacks[k]
            if callback then
                callback()
            end
        end
    end
end

return scene