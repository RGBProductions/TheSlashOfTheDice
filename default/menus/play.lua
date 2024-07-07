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
        UI.ScrollablePanel:new({
            id = "modes",
            x = 0,
            y = 0,
            width = 256,
            height = 224,
            background = {0,0,0,0},
            children = {
                UI.Button:new({
                    scrollThrough = true,
                    id = "tutorial",
                    x = 0,
                    y = -80,
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
                    scrollThrough = true,
                    id = "default",
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
                    scrollThrough = true,
                    id = "enemy_rush",
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
                    scrollThrough = true,
                    id = "calm",
                    x = 0,
                    y = 160,
                    width = 256,
                    height = 64,
                    background = function() return GetTheme()[Achievements.IsUnlocked("default_30_waves") and "button_secondary" or "button_back"].background end,
                    border = function() return GetTheme()[Achievements.IsUnlocked("default_30_waves") and "button_secondary" or "button_back"].border end,
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
                    onclick = function(self)
                        if Achievements.IsUnlocked("default_30_waves") then
                            SceneManager.LoadScene("scenes/game", {mode = self.id})
                        else
                            local popup = UI.Panel:new({
                                width = 480,
                                height = 320,
                                background = function() return GetTheme().popup_error.background end,
                                border = function() return GetTheme().popup_error.border end,
                                children = {
                                    UI.Text:new({
                                        clickThrough = true,
                                        x = 0,
                                        y = -40,
                                        width = 480,
                                        height = 208,
                                        text = function() return Localize("calm_not_unlocked") end,
                                        font = lgfont_2x,
                                        fontScale = 0.5,
                                        alignHoriz = "center",
                                        alignVert = "center"
                                    }),
                                    UI.Button:new({
                                        id = "close",
                                        width = 256,
                                        height = 64,
                                        y = 112,
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
                    end
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

AddMenu("play", playMenu)