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
                    width = 128,
                    height = 128,
                    image = love.graphics.newImage("assets/images/ui/button_icons/materialsymbols_play_arrow.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 56,
                    width = 256,
                    height = 96,
                    text = function() return Localize("button.play") end,
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
                    image = love.graphics.newImage("assets/images/ui/button_icons/materialsymbols_trophy_sharp.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.achievements") end,
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
                    image = love.graphics.newImage("assets/images/ui/button_icons/materialsymbols_text_ad_outline.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.credits") end,
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
                    image = love.graphics.newImage("assets/images/ui/button_icons/materialsymbols_settings.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.settings") end,
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
                    image = love.graphics.newImage("assets/images/ui/button_icons/materialsymbols_dresser_outline.png")
                }),
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 32,
                    width = 256,
                    height = 48,
                    text = function() return Localize("button.customization") end,
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
            background = function() return Settings.video.menu_theme.button_back.background end,
            border = function() return Settings.video.menu_theme.button_back.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 256,
                    height = 64,
                    text = function() return Localize("button.quit") end,
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
                    background = function() return Settings.video.menu_theme.button_secondary.background end,
                    border = function() return Settings.video.menu_theme.button_secondary.border end,
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
                    background = function() return Settings.video.menu_theme.button_secondary.background end,
                    border = function() return Settings.video.menu_theme.button_secondary.border end,
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
                    background = function() return Settings.video.menu_theme.button_secondary.background end,
                    border = function() return Settings.video.menu_theme.button_secondary.border end,
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
            background = function() return Settings.video.menu_theme.button_back.background end,
            border = function() return Settings.video.menu_theme.button_back.border end,
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
                    background = function() return Settings.video.menu_theme.button_secondary.background end,
                    border = function() return Settings.video.menu_theme.button_secondary.border end,
                    cursor = "hand",
                    children = {
                        UI.Text:new({
                            clickThrough = true,
                            x = 0,
                            y = 0,
                            width = 256,
                            height = 64,
                            text = function(self) return Localize("button.settings.video") end,
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
                    background = function() return Settings.video.menu_theme.button_secondary.background end,
                    border = function() return Settings.video.menu_theme.button_secondary.border end,
                    cursor = "hand",
                    children = {
                        UI.Text:new({
                            clickThrough = true,
                            x = 0,
                            y = 0,
                            width = 256,
                            height = 64,
                            text = function(self) return Localize("button.settings.audio") end,
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
                    background = function() return Settings.video.menu_theme.button_secondary.background end,
                    border = function() return Settings.video.menu_theme.button_secondary.border end,
                    cursor = "hand",
                    children = {
                        UI.Text:new({
                            clickThrough = true,
                            x = 0,
                            y = 0,
                            width = 256,
                            height = 64,
                            text = function(self) return Localize("button.settings.gameplay") end,
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
        UI.Text:new({
            x = 0,
            y = -180,
            width = 512,
            height = xlfont:getHeight(),
            font = xlfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            text = function() return Localize("title.menu.customization") end
        }),
        UI.Element:new({
            id = "options",
            x = 0,
            y = -80,
            children = {
                UI.Button:new({
                    id = "color",
                    x = 0,
                    y = 160,
                    width = 256,
                    height = 64,
                    background = function() return Settings.video.menu_theme.button_secondary.background end,
                    border = function() return Settings.video.menu_theme.button_secondary.border end,
                    cursor = "hand",
                    children = {
                        UI.Text:new({
                            clickThrough = true,
                            x = 0,
                            y = 0,
                            width = 256,
                            height = 64,
                            text = function(self) return Localize("button.customize.color") end,
                            font = lgfont_2x,
                            fontScale = 0.5,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    },
                    onclick = function(self)
                        local popup = UI.Panel:new({
                            width = 480,
                            height = 320,
                            background = function() return Settings.video.menu_theme.popup_error.background end,
                            border = function() return Settings.video.menu_theme.popup_error.border end,
                            children = {
                                UI.Text:new({
                                    width = 448,
                                    height = 208,
                                    y = -40,
                                    alignHoriz = "center",
                                    alignVert = "center",
                                    text = function() return Localize("error.unimplemented") end
                                }),
                                UI.Button:new({
                                    id = "assist",
                                    width = 256,
                                    height = 64,
                                    y = 112,
                                    background = function() return Settings.video.menu_theme.button_secondary.background end,
                                    border = function() return Settings.video.menu_theme.button_secondary.border end,
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
            x = 0,
            y = 160,
            width = 64,
            height = 64,
            background = function() return Settings.video.menu_theme.button_back.background end,
            border = function() return Settings.video.menu_theme.button_back.border end,
            cursor = "hand",
            children = {
                UI.Image:new({
                    clickThrough = true,
                    image = love.graphics.newImage("assets/images/ui/button_icons/materialsymbols_exit_to_app.png"),
                    x = 0,
                    y = 0,
                    width = 48,
                    height = 48
                })
            },
            onclick = function() SetMenu("main") end
        })
    }
})

AddMenu("main", mainMenu)
AddMenu("play", playMenu)
AddMenu("settings", settingsMenu)
AddMenu("customize", customizeMenu)