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
                    text = function() return Slash.Localization.Localize("button.play") end,
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
                Slash.Scenes.Load("default:achievements")
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
                    text = function() return Slash.Localization.Localize("button.achievements") end,
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
                Slash.Scenes.Load("default:credits")
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
                    text = function() return Slash.Localization.Localize("button.credits") end,
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
                    text = function() return Slash.Localization.Localize("button.settings") end,
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
                    text = function() return Slash.Localization.Localize("button.customization") end,
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
            x = -68,
            y = 136,
            width = 120,
            height = 64,
            background = function() return GetTheme().button_back.background end,
            border = function() return GetTheme().button_back.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 120,
                    height = 64,
                    text = function() return Slash.Localization.Localize("button.quit") end,
                    color = function() return GetTheme().button_back.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() love.event.push("quit") end
        }),

        UI.Button:new({
            id = "mods",
            x = 68,
            y = 136,
            width = 120,
            height = 64,
            background = function() return GetTheme().button_other.background end,
            border = function() return GetTheme().button_other.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 120,
                    height = 64,
                    text = function() return Slash.Localization.Localize("button.mods") end,
                    color = function() return GetTheme().button_other.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function()
                local mods_e = Menus.mods:getChildById("mods.enabled")
                local nomods_e = Menus.mods:getChildById("nomods.enabled")
                local mods_d = Menus.mods:getChildById("mods.disabled")
                local nomods_d = Menus.mods:getChildById("nomods.disabled")
                local needsrestart = Menus.mods:getChildById("needsrestart")
                local pos = -72
                local refreshLists
                local function addMod(enabled,obj)
                    local list = enabled and mods_e or mods_d
                    local text = enabled and nomods_e or nomods_d
                    local themekey = enabled and "button_secondary" or "button_back"
                    local label = enabled and "disable" or "enable"
                    local btntheme = enabled and "button_back" or "button_primary"
                    table.insert(list.children, UI.Panel:new({
                        x = 0,
                        y = pos,
                        width = 512,
                        height = 80,
                        background = function() return GetTheme()[themekey].background end,
                        border = function() return GetTheme()[themekey].border end,
                        children = {
                            UI.Text:new({
                                x = 32,
                                y = 0,
                                width = 416,
                                height = 80,
                                font = lgfont_2x,
                                fontScale = 0.5,
                                text = obj.info.name
                            }),
                            UI.Text:new({
                                x = 32,
                                y = 12,
                                width = 416,
                                height = 44,
                                font = mdfont_2x,
                                fontScale = 0.5,
                                text = obj.info.author
                            }),
                            UI.Text:new({
                                x = 32,
                                y = -4,
                                width = 416,
                                height = 72,
                                font = mdfont_2x,
                                fontScale = 0.5,
                                alignVert = "bottom",
                                text = obj.info.description
                            }),
                            UI.Image:new({
                                x = -216,
                                y = 0,
                                width = 64,
                                height = 64,
                                image = obj.info.icon
                            }),
                            UI.Button:new({
                                x = 196,
                                y = -12,
                                width = 96,
                                height = 32,
                                background = function() return GetTheme()[btntheme].background end,
                                border = function() return GetTheme()[btntheme].border end,
                                cursor = "hand",
                                children = {
                                    UI.Text:new({
                                        clickThrough = true,
                                        x = 0,
                                        y = 0,
                                        width = 96,
                                        height = 32,
                                        text = function() return Slash.Localization.Localize("button.mods."..label) end,
                                        color = function() return GetTheme()[btntheme].text end,
                                        font = lgfont_2x,
                                        fontScale = 0.4,
                                        alignHoriz = "center",
                                        alignVert = "center"
                                    })
                                },
                                onclick = function()
                                    if enabled then
                                        Slash.Mod.Disable(obj.id)
                                    else
                                        Slash.Mod.Enable(obj.id)
                                    end
                                    refreshLists()
                                end
                            })
                        }
                    }))
                    pos = pos + 96
                    text.hidden = true
                end
                refreshLists = function()
                    mods_e.children = {}
                    mods_d.children = {}
                    pos = -72
                    for _,mod in ipairs(Slash.Mod.GetMods()) do
                        if not mod.info.hidden then
                            addMod(true, mod)
                        end
                    end
                    pos = -72
                    for _,mod in ipairs(Slash.Mod.RetrieveDisabledMods()) do
                        if not mod.info.hidden then
                            addMod(false, mod)
                        end
                    end
                    needsrestart.hidden = not Slash.Mod.RequiresRestart()
                end
                refreshLists()
                SetMenu("mods")
            end
        })
    }
})

AddMenu("main", mainMenu)