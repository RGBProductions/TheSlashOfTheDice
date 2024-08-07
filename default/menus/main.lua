local mainMenu = UI.Element:new({
    children = {
        UI.Button:new({
            defaultSelected = true,
            id = "play",
            x = 0,
            y = -40,
            width = 256,
            height = 256,
            background = function() return GetTheme().button_primary.background end,
            border = function() return GetTheme().button_primary.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -32,
                    width = 128,
                    height = 128,
                    tint = function() return GetTheme().button_primary.icon_color end,
                    image = ButtonIcons.materialsymbols_play_arrow
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 56,
                    width = 256,
                    height = 96,
                    text = function() return Localize("button.play") end,
                    color = function() return GetTheme().button_primary.text end,
                    font = xlfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() SetMenu("play") end
        }),

        UI.Button:new({
            id = "achievements",
            x = -272,
            y = -108,
            width = 256,
            height = 120,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            onclick = function()
                SceneManager.LoadScene("scenes/achievements")
            end,
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -16,
                    width = 64,
                    height = 64,
                    tint = function() return GetTheme().button_secondary.icon_color end,
                    image = ButtonIcons.materialsymbols_trophy_sharp
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.achievements") end,
                    color = function() return GetTheme().button_secondary.text end,
                    font = mdfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            }
        }),

        UI.Button:new({
            id = "credits",
            x = 272,
            y = -108,
            width = 256,
            height = 120,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            onclick = function()
                SceneManager.LoadScene("scenes/credits")
            end,
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -16,
                    width = 64,
                    height = 64,
                    tint = function() return GetTheme().button_secondary.icon_color end,
                    image = ButtonIcons.materialsymbols_text_ad_outline
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.credits") end,
                    color = function() return GetTheme().button_secondary.text end,
                    font = mdfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            }
        }),

        UI.Button:new({
            id = "settings",
            x = -272,
            y = 28,
            width = 256,
            height = 120,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -16,
                    width = 64,
                    height = 64,
                    tint = function() return GetTheme().button_secondary.icon_color end,
                    image = ButtonIcons.materialsymbols_settings
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.settings") end,
                    color = function() return GetTheme().button_secondary.text end,
                    font = mdfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() SetMenu("settings") end
        }),

        UI.Button:new({
            id = "customization",
            x = 272,
            y = 28,
            width = 256,
            height = 120,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    x = 0,
                    y = -16,
                    width = 64,
                    height = 64,
                    tint = function() return GetTheme().button_secondary.icon_color end,
                    image = ButtonIcons.materialsymbols_dresser_outline
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.customization") end,
                    color = function() return GetTheme().button_secondary.text end,
                    font = mdfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() SetMenu("customize") end
        }),

        UI.Button:new({
            id = "exit",
            x = 0,
            y = 136,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_back.background end,
            border = function() return GetTheme().button_back.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 256,
                    height = 64,
                    text = function() return Localize("button.quit") end,
                    color = function() return GetTheme().button_back.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() love.event.push("quit") end
        })
    }
})

AddMenu("main", mainMenu)