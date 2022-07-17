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
    
    Logo = love.graphics.newImage("assets/images/ui/logo-new.png")
    LogoPos = love.graphics.getHeight()

    Menu = "MainMenu"
    MenuSelection = 1

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
                    label = {
                        {type = "text", value = "UI Scale: "},
                        {type = "fromcode", value = function()
                            return Settings["UI Scale"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function()
                            local shift = 0.01
                            if love.keyboard.isDown("lshift") then
                                shift = 0.1
                            end
                            Settings["UI Scale"] = math.max(0.25, math.min(3, Settings["UI Scale"] - shift))
                        end,
                        ["right"] = function()
                            local shift = 0.01
                            if love.keyboard.isDown("lshift") then
                                shift = 0.1
                            end
                            Settings["UI Scale"] = math.max(0.25, math.min(3, Settings["UI Scale"] + shift))
                        end
                    }
                },
                {
                    label = {
                        {type = "text", value = "Sound Volume: "},
                        {type = "fromcode", value = function()
                            return Settings["Sound Volume"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Sound Volume"] = math.max(0, math.min(100, Settings["Sound Volume"] - shift))
                        end,
                        ["right"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Sound Volume"] = math.max(0, math.min(100, Settings["Sound Volume"] + shift))
                        end
                    }
                },
                {
                    label = {
                        {type = "text", value = "Music Volume: "},
                        {type = "fromcode", value = function()
                            return Settings["Music Volume"]
                        end}
                    },
                    callbacks = {
                        ["left"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Music Volume"] = math.max(0, math.min(100, Settings["Music Volume"] - shift))
                        end,
                        ["right"] = function()
                            local shift = 1
                            if love.keyboard.isDown("lshift") then
                                shift = 10
                            end
                            Settings["Music Volume"] = math.max(0, math.min(100, Settings["Music Volume"] + shift))
                        end
                    }
                },
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
        }
    }
end

function scene.update(dt)
    LogoPos = LogoPos - ((LogoPos-16)/8)
end

function scene.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(Logo, love.graphics.getWidth()/2, LogoPos, 0, Settings["UI Scale"], Settings["UI Scale"], Logo:getWidth()/2, 0)
    love.graphics.setFont(xlfont)
    if Menus[Menu].label then
        love.graphics.printf(Menus[Menu].label, 0, LogoPos + Logo:getHeight()*Settings["UI Scale"] + xlfont:getHeight(), love.graphics.getWidth(), "center")
    end
    love.graphics.setFont(lrfont)
    for i,v in ipairs(Menus[Menu].buttons) do
        love.graphics.setColor(1,1,1,0.5)
        if i == MenuSelection then
            love.graphics.setColor(1,1,1)
        end
        love.graphics.printf(ParseLabel(v.label), 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos + lrfont:getHeight()*(i-1), love.graphics.getWidth(), "center")
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
    MenuSelection = MenuSelection - 1
    if k == "down" then
        MenuSelection = (MenuSelection+1)%(#Menus[Menu].buttons)
    end
    if k == "up" then
        MenuSelection = (MenuSelection-1)%(#Menus[Menu].buttons)
    end
    MenuSelection = MenuSelection + 1

    if k ~= "down" and k ~= "up" then
        local callback = Menus[Menu].buttons[MenuSelection].callbacks[k]
        if callback then
            callback()
        end
    end
end

return scene