local mainMenu = UI.Element:new({
    children = {
        UI.Button:new({
            x = 0,
            y = -40,
            width = 256,
            height = 256,
            background = function() return Settings.video.menu_theme.button_primary.background end,
            border = function() return Settings.video.menu_theme.button_primary.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -32,
                    width = 96,
                    height = 96,
                    image = love.graphics.newImage("assets/images/ui/button_icons/play.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 56,
                    width = 256,
                    height = 96,
                    text = function() return Localize("button.play") end,
                    font = xlfont,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() SetMenu("play") end
        }),

        UI.Button:new({
            x = -272,
            y = -108,
            width = 256,
            height = 120,
            background = function() return Settings.video.menu_theme.button_secondary.background end,
            border = function() return Settings.video.menu_theme.button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -16,
                    width = 64,
                    height = 64,
                    image = love.graphics.newImage("assets/images/ui/button_icons/achievements.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.achievements") end,
                    font = mdfont,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            }
        }),

        UI.Button:new({
            x = 272,
            y = -108,
            width = 256,
            height = 120,
            background = function() return Settings.video.menu_theme.button_secondary.background end,
            border = function() return Settings.video.menu_theme.button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -16,
                    width = 64,
                    height = 64,
                    image = love.graphics.newImage("assets/images/ui/button_icons/credits.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.credits") end,
                    font = mdfont,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            }
        }),

        UI.Button:new({
            x = -272,
            y = 28,
            width = 256,
            height = 120,
            background = function() return Settings.video.menu_theme.button_secondary.background end,
            border = function() return Settings.video.menu_theme.button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -16,
                    width = 64,
                    height = 64,
                    image = love.graphics.newImage("assets/images/ui/button_icons/settings.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.settings") end,
                    font = mdfont,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            }
        }),

        UI.Button:new({
            x = 272,
            y = 28,
            width = 256,
            height = 120,
            background = function() return Settings.video.menu_theme.button_secondary.background end,
            border = function() return Settings.video.menu_theme.button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -16,
                    width = 64,
                    height = 64,
                    image = love.graphics.newImage("assets/images/ui/button_icons/customization.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.customization") end,
                    font = mdfont,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            }
        }),

        UI.Button:new({
            id = "exit",
            x = 0,
            y = 136,
            width = 256,
            height = 64,
            background = function() return Settings.video.menu_theme.button_back.background end,
            border = function() return Settings.video.menu_theme.button_back.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 120,
                    height = 64,
                    text = function() return Localize("button.quit") end,
                    font = lgfont,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() love.event.push("quit") end
        })
    }
})

local playMenu = UI.Element:new({
    children = {
        UI.Button:new({
            id = "back",
            x = 0,
            y = 136,
            width = 256,
            height = 64,
            background = function() return Settings.video.menu_theme.button_back.background end,
            border = function() return Settings.video.menu_theme.button_back.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 120,
                    height = 64,
                    text = function() return Localize("button.back") end,
                    font = lgfont,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() SetMenu("main") end
        })
    }
})

AddMenu("main", mainMenu)
AddMenu("play", playMenu)