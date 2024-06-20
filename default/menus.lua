local icons = {}
for _,itm in ipairs(love.filesystem.getDirectoryItems("assets/images/ui/button_icons")) do
    local name,ext = unpack(itm:split_plain("."))
    if ext == "png" then
        icons[name] = love.graphics.newImage("assets/images/ui/button_icons/"..itm)
    end
end

local noCosmetic = love.graphics.newImage("assets/images/ui/none.png")

local mainMenu = UI.Element:new({
    children = {
        UI.Button:new({
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
                    image = icons.materialsymbols_play_arrow
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
            x = -272,
            y = -108,
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
                    image = icons.materialsymbols_trophy_sharp
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
            x = 272,
            y = -108,
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
                    image = icons.materialsymbols_text_ad_outline
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
                    image = icons.materialsymbols_settings
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
                    image = icons.materialsymbols_dresser_outline
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

local playMenu = UI.Element:new({
    children = {
        UI.Text:new({
            x = 0,
            y = -180,
            width = 512,
            height = xlfont:getHeight(),
            font = xlfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            text = function() return Localize("title.menu.play") end
        }),
        UI.Element:new({
            id = "modes",
            x = 0,
            y = -80,
            children = {
                UI.Button:new({
                    id = "tutorial",
                    x = 0,
                    y = 0,
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
                            text = function(self) return Localize("gamemode."..self.parent.id) end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self) SceneManager.LoadScene("scenes/game", {mode = self.id}) end
                }),
                UI.Button:new({
                    id = "default",
                    x = 0,
                    y = 80,
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
                            text = function(self) return Localize("gamemode."..self.parent.id) end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self) SceneManager.LoadScene("scenes/game", {mode = self.id}) end
                }),
                UI.Button:new({
                    id = "enemy_rush",
                    x = 0,
                    y = 160,
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
                            text = function(self) return Localize("gamemode."..self.parent.id) end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self) SceneManager.LoadScene("scenes/game", {mode = self.id}) end
                })
            }
        }),
        UI.Button:new({
            id = "back",
            x = 0,
            y = 160,
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
                    text = function() return Localize("button.back") end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() SetMenu("main") end
        })
    }
})

local settingsMenu = UI.Element:new({
    children = {
        UI.Text:new({
            x = 0,
            y = -180,
            width = 512,
            height = xlfont:getHeight(),
            font = xlfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            text = function() return Localize("title.menu.settings") end
        }),
        UI.Element:new({
            id = "tabs",
            x = 0,
            y = -80,
            children = {
                UI.Button:new({
                    id = "video",
                    x = 0,
                    y = 0,
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
                            text = function(self) return Localize("button.settings.video") end,
                            color = function() return GetTheme().button_secondary.text end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self)  end
                }),
                UI.Button:new({
                    id = "audio",
                    x = 0,
                    y = 80,
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
                            text = function(self) return Localize("button.settings.audio") end,
                            color = function() return GetTheme().button_secondary.text end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self)  end
                }),
                UI.Button:new({
                    id = "gameplay",
                    x = 0,
                    y = 160,
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
                            text = function(self) return Localize("button.settings.gameplay") end,
                            color = function() return GetTheme().button_secondary.text end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self)  end
                })
            }
        }),
        UI.Button:new({
            id = "back",
            x = 0,
            y = 160,
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
                    width = 120,
                    height = 64,
                    text = function() return Localize("button.back") end,
                    color = function() return GetTheme().button_back.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function() SetMenu("main") end
        })
    }
})

local customizeMenu = UI.Element:new({
    id = "customizeMenu",
    children = {
        UI.Panel:new({
            background = function () return GetTheme().button_secondary.background end,
            width = 96,
            height = 96,
            x = -240,
            y = -40,
            children = {
                UI.PlayerDisplay:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 64,
                    height = 64,
                    data = function() return {customization = Settings.customization} end
                })
            }
        }),
        UI.Button:new({
            background = function () return GetTheme().button_primary.background end,
            cursor = "hand",
            width = 64,
            height = 64,
            x = -240,
            y = 56,
            onclick = function() SceneManager.LoadScene("scenes/game", {mode = "playtest"}) end,
            children = {
                UI.Image:new({
                    x = 0,
                    y = 0,
                    width = 48,
                    height = 48,
                    image = icons.materialsymbols_play_arrow,
                    tint = function() return GetTheme().button_primary.icon_color end,
                    clickThrough = true
                })
            }
        }),
        UI.Element:new({
            id = "options",
            x = 0,
            y = -40,
            children = {
                UI.Button:new({
                    id = "color",
                    x = 0,
                    y = -120,
                    width = 256,
                    height = 64,
                    background = function() return GetTheme().button_secondary.background end,
                    border = function() return GetTheme().button_secondary.border end,
                    cursor = "hand",
                    children = {
                        UI.Image:new({
                            clickThrough = true,
                            x = -96,
                            y = 0,
                            width = 48,
                            height = 48,
                            image = icons.materialsymbols_colors,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Panel:new({
                            clickThrough = true,
                            x = -64,
                            y = 0,
                            width = 2,
                            height = 64,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Text:new({
                            clickThrough = true,
                            x = 32,
                            y = 0,
                            width = 192,
                            height = 64,
                            text = function(self) return HexCodeOf(unpack(Settings.customization.color)) end,
                            color = function() return GetTheme().button_secondary.text end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self)
                        local h,s,v = hsx.rgb2hsv(Settings.customization.color[1],Settings.customization.color[2],Settings.customization.color[3])
                        local popup = UI.Panel:new({
                            width = 288,
                            height = 368,
                            background = function() return GetTheme().popup_info.background end,
                            border = function() return GetTheme().popup_info.border end,
                            children = {
                                UI.ColorPicker:new({
                                    id = "colorpicker",
                                    x = 0,
                                    y = -40,
                                    width = 256,
                                    height = 256,
                                    hue = h,
                                    saturation = s,
                                    value = v
                                }),
                                UI.Button:new({
                                    id = "apply",
                                    width = 256,
                                    height = 64,
                                    y = 136,
                                    background = function() return GetTheme().button_secondary.background end,
                                    border = function() return GetTheme().button_secondary.border end,
                                    onclick = function(me)
                                        Settings.customization.color = me.parent:getChildById("colorpicker"):getRGB()
                                        table.remove(Dialogs, table.index(Dialogs, me.parent))
                                    end,
                                    cursor = "hand",
                                    children = {
                                        UI.Text:new({
                                            clickThrough = true,
                                            x = 0,
                                            y = 0,
                                            width = 256,
                                            height = 64,
                                            text = function() return Localize("button.ok") end,
                                            color = function() return GetTheme().button_secondary.text end,
                                            font = lgfont_2x,
                                            fontScale = 0.5,
                                            alignHoriz = "center",
                                            alignVert = "center"
                                        })
                                    },
                                })
                            }
                        })
                        table.insert(Dialogs, popup)
                    end
                }),
                UI.Button:new({
                    id = "trail",
                    x = 0,
                    y = -40,
                    width = 256,
                    height = 64,
                    background = function() return GetTheme().button_secondary.background end,
                    border = function() return GetTheme().button_secondary.border end,
                    cursor = "hand",
                    children = {
                        UI.Image:new({
                            clickThrough = true,
                            x = -96,
                            y = 0,
                            width = 48,
                            height = 48,
                            image = icons.materialsymbols_footprint,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Panel:new({
                            clickThrough = true,
                            x = -64,
                            y = 0,
                            width = 2,
                            height = 64,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Text:new({
                            clickThrough = true,
                            x = 32,
                            y = 0,
                            width = 192,
                            height = 64,
                            text = function(self) return Localize(Settings.customization.trail == nil and "customization.none" or ("customization.trails."..Settings.customization.trail..".name")) end,
                            color = function() return GetTheme().button_secondary.text end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self)
                        local options = UI.ScrollablePanel:new({
                            width = 432,
                            height = 288,
                            x = 0,
                            y = -40,
                            id = "options",
                            children = {},
                            scrollX = 0,
                            scrollY = 0,
                            background = {0,0,0,0}
                        })
                        do
                            local x,y = 0,0
                            local function addOption(id)
                                local button = UI.Button:new({
                                    scrollThrough = true,
                                    id = id,
                                    x = x-168,
                                    y = y-96,
                                    width = 96,
                                    height = 96,
                                    background = function(me) return GetTheme()[Settings.customization.trail == me.id and "button_primary" or "button_secondary"].background end,
                                    border = function(me) return GetTheme()[Settings.customization.trail == me.id and "button_primary" or "button_secondary"].border end,
                                    onclick = function(me) Settings.customization.trail = me.id end,
                                    cursor = "hand",
                                    children = {
                                        UI.Text:new({
                                            width = 96,
                                            height = 96,
                                            text = function(me) return Localize(me.id == nil and "customization.none" or ("customization.trails."..me.id..".name")) end,
                                            color = function() return GetTheme().button_secondary.text end,
                                            font = mdfont_2x,
                                            fontScale = 0.5,
                                            alignHoriz = "center",
                                            alignVert = "center"
                                        })
                                    }
                                })
                                options:addChild(button)
                                x = x + 96 + 16
                                if x >= 432 then
                                    x = 0
                                    y = y + 96 + 16
                                end
                            end
                            addOption(nil)
                            for name,_ in pairs(Cosmetics.Trails) do
                                addOption(name)
                            end
                        end
                        local popup = UI.Panel:new({
                            width = 464,
                            height = 400,
                            background = function() return GetTheme().popup_info.background end,
                            border = function() return GetTheme().popup_info.border end,
                            children = {
                                options,
                                UI.Button:new({
                                    id = "close",
                                    width = 256,
                                    height = 64,
                                    y = 152,
                                    background = function() return GetTheme().button_secondary.background end,
                                    border = function() return GetTheme().button_secondary.border end,
                                    onclick = function(me)
                                        table.remove(Dialogs, table.index(Dialogs, me.parent))
                                    end,
                                    cursor = "hand",
                                    children = {
                                        UI.Text:new({
                                            clickThrough = true,
                                            x = 0,
                                            y = 0,
                                            width = 256,
                                            height = 64,
                                            text = function() return Localize("button.ok") end,
                                            color = function() return GetTheme().button_secondary.text end,
                                            font = lgfont_2x,
                                            fontScale = 0.5,
                                            alignHoriz = "center",
                                            alignVert = "center"
                                        })
                                    },
                                })
                            }
                        })
                        table.insert(Dialogs, popup)
                    end
                }),
                UI.Button:new({
                    id = "death_effect",
                    x = 0,
                    y = 40,
                    width = 256,
                    height = 64,
                    background = function() return GetTheme().button_secondary.background end,
                    border = function() return GetTheme().button_secondary.border end,
                    cursor = "hand",
                    children = {
                        UI.Image:new({
                            clickThrough = true,
                            x = -96,
                            y = 0,
                            width = 48,
                            height = 48,
                            image = icons.materialsymbols_skull_outline,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Panel:new({
                            clickThrough = true,
                            x = -64,
                            y = 0,
                            width = 2,
                            height = 64,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Text:new({
                            clickThrough = true,
                            x = 32,
                            y = 0,
                            width = 192,
                            height = 64,
                            text = function(self) return Localize(Settings.customization.death_effect == nil and "customization.none" or ("customization.effects."..Settings.customization.death_effect..".name")) end,
                            color = function() return GetTheme().button_secondary.text end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self)
                        local options = UI.ScrollablePanel:new({
                            width = 432,
                            height = 288,
                            x = 0,
                            y = -40,
                            id = "options",
                            children = {},
                            scrollX = 0,
                            scrollY = 0,
                            background = {0,0,0,0}
                        })
                        do
                            local x,y = 0,0
                            local function addOption(id)
                                local button = UI.Button:new({
                                    scrollThrough = true,
                                    id = id,
                                    x = x-168,
                                    y = y-96,
                                    width = 96,
                                    height = 96,
                                    background = function(me) return GetTheme()[Settings.customization.death_effect == me.id and "button_primary" or "button_secondary"].background end,
                                    border = function(me) return GetTheme()[Settings.customization.death_effect == me.id and "button_primary" or "button_secondary"].border end,
                                    onclick = function(me) Settings.customization.death_effect = me.id end,
                                    cursor = "hand",
                                    children = {
                                        UI.Text:new({
                                            width = 96,
                                            height = 96,
                                            text = function(me) return Localize(me.id == nil and "customization.none" or ("customization.effects."..me.id..".name")) end,
                                            color = function() return GetTheme().button_secondary.text end,
                                            font = mdfont_2x,
                                            fontScale = 0.5,
                                            alignHoriz = "center",
                                            alignVert = "center"
                                        })
                                    }
                                })
                                options:addChild(button)
                                x = x + 96 + 16
                                if x >= 432 then
                                    x = 0
                                    y = y + 96 + 16
                                end
                            end
                            addOption(nil)
                            for name,_ in pairs(Cosmetics.Effects) do
                                addOption(name)
                            end
                        end
                        local popup = UI.Panel:new({
                            width = 464,
                            height = 400,
                            background = function() return GetTheme().popup_info.background end,
                            border = function() return GetTheme().popup_info.border end,
                            children = {
                                options,
                                UI.Button:new({
                                    id = "close",
                                    width = 256,
                                    height = 64,
                                    y = 152,
                                    background = function() return GetTheme().button_secondary.background end,
                                    border = function() return GetTheme().button_secondary.border end,
                                    onclick = function(me)
                                        table.remove(Dialogs, table.index(Dialogs, me.parent))
                                    end,
                                    cursor = "hand",
                                    children = {
                                        UI.Text:new({
                                            clickThrough = true,
                                            x = 0,
                                            y = 0,
                                            width = 256,
                                            height = 64,
                                            text = function() return Localize("button.ok") end,
                                            color = function() return GetTheme().button_secondary.text end,
                                            font = lgfont_2x,
                                            fontScale = 0.5,
                                            alignHoriz = "center",
                                            alignVert = "center"
                                        })
                                    },
                                })
                            }
                        })
                        table.insert(Dialogs, popup)
                    end
                }),
                UI.Button:new({
                    id = "hat",
                    x = 0,
                    y = 120,
                    width = 256,
                    height = 64,
                    background = function() return GetTheme().button_secondary.background end,
                    border = function() return GetTheme().button_secondary.border end,
                    cursor = "hand",
                    children = {
                        UI.Image:new({
                            clickThrough = true,
                            x = -96,
                            y = 0,
                            width = 48,
                            height = 48,
                            image = icons.mingcute_hat_fill,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Panel:new({
                            clickThrough = true,
                            x = -64,
                            y = 0,
                            width = 2,
                            height = 64,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Text:new({
                            clickThrough = true,
                            x = 32,
                            y = 0,
                            width = 192,
                            height = 64,
                            text = function(self) return Localize(Settings.customization.hat == nil and "customization.none" or ("customization.hats."..Settings.customization.hat..".name")) end,
                            color = function() return GetTheme().button_secondary.text end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self)
                        local options = UI.ScrollablePanel:new({
                            width = 432,
                            height = 288,
                            x = 0,
                            y = -40,
                            id = "options",
                            children = {},
                            scrollX = 0,
                            scrollY = 0,
                            background = {0,0,0,0}
                        })
                        do
                            local x,y = 0,0
                            local function addOption(id,data)
                                local button = UI.Button:new({
                                    scrollThrough = true,
                                    id = id,
                                    x = x-168,
                                    y = y-96,
                                    width = 96,
                                    height = 96,
                                    background = function(me) return GetTheme()[Settings.customization.hat == me.id and "button_primary" or "button_secondary"].background end,
                                    border = function(me) return GetTheme()[Settings.customization.hat == me.id and "button_primary" or "button_secondary"].border end,
                                    onclick = function(me) Settings.customization.hat = me.id end,
                                    cursor = "hand",
                                    children = {}
                                })
                                if data then
                                    button:addChild(UI.Image:new({
                                        clickThrough = true,
                                        image = data.image,
                                        width = data.image:getWidth()*data.scale,
                                        height = data.image:getHeight()*data.scale
                                    }))
                                end
                                options:addChild(button)
                                x = x + 96 + 16
                                if x >= 432 then
                                    x = 0
                                    y = y + 96 + 16
                                end
                            end
                            addOption(nil, {image = noCosmetic, scale = 1})
                            for name,data in pairs(Cosmetics.Hats) do
                                addOption(name,data)
                            end
                        end
                        local popup = UI.Panel:new({
                            width = 464,
                            height = 400,
                            background = function() return GetTheme().popup_info.background end,
                            border = function() return GetTheme().popup_info.border end,
                            children = {
                                options,
                                UI.Button:new({
                                    id = "close",
                                    width = 256,
                                    height = 64,
                                    y = 152,
                                    background = function() return GetTheme().button_secondary.background end,
                                    border = function() return GetTheme().button_secondary.border end,
                                    onclick = function(me)
                                        table.remove(Dialogs, table.index(Dialogs, me.parent))
                                    end,
                                    cursor = "hand",
                                    children = {
                                        UI.Text:new({
                                            clickThrough = true,
                                            x = 0,
                                            y = 0,
                                            width = 256,
                                            height = 64,
                                            text = function() return Localize("button.ok") end,
                                            color = function() return GetTheme().button_secondary.text end,
                                            font = lgfont_2x,
                                            fontScale = 0.5,
                                            alignHoriz = "center",
                                            alignVert = "center"
                                        })
                                    },
                                })
                            }
                        })
                        table.insert(Dialogs, popup)
                    end
                })
            }
        }),
        UI.Button:new({
            id = "back",
            x = -40,
            y = 160,
            width = 64,
            height = 64,
            background = function() return GetTheme().button_back.background end,
            border = function() return GetTheme().button_back.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    tint = function() return GetTheme().button_back.icon_color end,
                    image = icons.materialsymbols_exit_to_app,
                    x = 0,
                    y = 0,
                    width = 48,
                    height = 48
                })
            },
            onclick = function()
                WriteSettings()
                SetMenu("main")
            end
        }),
        UI.Button:new({
            id = "help",
            x = 40,
            y = 160,
            width = 64,
            height = 64,
            background = function() return GetTheme().button_other.background end,
            border = function() return GetTheme().button_other.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    tint = function() return GetTheme().button_other.icon_color end,
                    image = icons.materialsymbols_help,
                    x = 0,
                    y = 0,
                    width = 48,
                    height = 48
                })
            },
            onclick = function()
                local popup = UI.Panel:new({
                    width = 720,
                    height = 360,
                    background = function() return GetTheme().popup_info.background end,
                    border = function() return GetTheme().popup_info.border end,
                    children = {
                        UI.Image:new({
                            clickThrough = true,
                            x = -320,
                            y = -140,
                            width = 48,
                            height = 48,
                            image = icons.materialsymbols_colors,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Text:new({
                            width = 624,
                            height = 0,
                            x = 32,
                            y = -140,
                            alignHoriz = "left",
                            alignVert = "center",
                            font = lgfont_2x,
                            fontScale = 0.5,
                            text = function() return Localize("customization.help.color") end
                        }),
                        UI.Image:new({
                            clickThrough = true,
                            x = -320,
                            y = -140+64,
                            width = 48,
                            height = 48,
                            image = icons.materialsymbols_footprint,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Text:new({
                            width = 624,
                            height = 0,
                            x = 32,
                            y = -140+64,
                            alignHoriz = "left",
                            alignVert = "center",
                            font = lgfont_2x,
                            fontScale = 0.5,
                            text = function() return Localize("customization.help.trail") end
                        }),
                        UI.Image:new({
                            clickThrough = true,
                            x = -320,
                            y = -140+128,
                            width = 48,
                            height = 48,
                            image = icons.materialsymbols_skull_outline,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Text:new({
                            width = 624,
                            height = 0,
                            x = 32,
                            y = -140+128,
                            alignHoriz = "left",
                            alignVert = "center",
                            font = lgfont_2x,
                            fontScale = 0.5,
                            text = function() return Localize("customization.help.death_effect") end
                        }),
                        UI.Image:new({
                            clickThrough = true,
                            x = -320,
                            y = -140+128+64,
                            width = 48,
                            height = 48,
                            image = icons.mingcute_hat_fill,
                            tint = function() return GetTheme().button_primary.icon_color end,
                        }),
                        UI.Text:new({
                            width = 624,
                            height = 0,
                            x = 32,
                            y = -140+128+64,
                            alignHoriz = "left",
                            alignVert = "center",
                            font = lgfont_2x,
                            fontScale = 0.5,
                            text = function() return Localize("customization.help.hat") end
                        }),
                        UI.Button:new({
                            id = "close",
                            width = 256,
                            height = 64,
                            y = 132,
                            background = function() return GetTheme().button_secondary.background end,
                            border = function() return GetTheme().button_secondary.border end,
                            onclick = function(me)
                                table.remove(Dialogs, table.index(Dialogs, me.parent))
                            end,
                            cursor = "hand",
                            children = {
                                UI.Text:new({
                                    clickThrough = true,
                                    x = 0,
                                    y = 0,
                                    width = 256,
                                    height = 64,
                                    text = function() return Localize("button.ok") end,
                                    color = function() return GetTheme().button_secondary.text end,
                                    font = lgfont_2x,
                                    fontScale = 0.5,
                                    alignHoriz = "center",
                                    alignVert = "center"
                                })
                            },
                        })
                    }
                })
                table.insert(Dialogs, popup)
            end
        })
    }
})

AddMenu("main", mainMenu)
AddMenu("play", playMenu)
AddMenu("settings", settingsMenu)
AddMenu("customize", customizeMenu)