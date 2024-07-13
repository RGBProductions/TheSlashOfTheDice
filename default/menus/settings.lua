local tempSettings = {}

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
                    onclick = function(self)
                        tempSettings = table.merge({},Settings)
                        SetMenu(self.id.."Settings")
                    end
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
                    onclick = function(self)
                        tempSettings = table.merge({},Settings)
                        SetMenu(self.id.."Settings")
                    end
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
                    onclick = function(self)
                        tempSettings = table.merge({},Settings)
                        SetMenu(self.id.."Settings")
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

local sVideoMenu = UI.Element:new({
    children = {
        UI.Text:new({
            x = 0,
            y = -180,
            width = 512,
            height = xlfont:getHeight(),
            font = xlfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            text = function() return Localize("title.menu.video_settings") end
        }),
        UI.ScrollablePanel:new({
            id = "options",
            x = 0,
            y = 0,
            width = 640,
            height = 240,
            background = {0,0,0,0},
            children = {
                UI.Toggle:new({
                    id = "color_by_operator",
                    cursor = "hand",
                    x = 112,
                    y = -104,
                    width = 32,
                    height = 32,
                    value = function() return Settings.video.color_by_operator end,
                    ontoggle = function(self,value) tempSettings.video.color_by_operator = value end,
                    children = {
                        UI.Text:new({
                            text = function() return Localize("settings.color_by_operator") end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,288/width)
                            end,
                            x = -288,
                            y = 0,
                            width = 288,
                            height = 32,
                            alignHoriz = "left",
                            alignVert = "center"
                        })
                    }
                }),
                UI.Slider:new({
                    id = "ui_scale",
                    x = 112,
                    y = -56,
                    width = 256,
                    height = 24,
                    min = 0.5, max = 2,
                    fill = 1,
                    initWith = function() return Settings.video.ui_scale end,
                    onvaluechanged = function(self,value)
                        tempSettings.video.ui_scale = value
                        self:getChildByType(UI.TextInput).input.content = tostring(math.floor(value*100)/100)
                    end,
                    children = {
                        UI.Text:new({
                            text = function() return Localize("settings.ui_scale") end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,288/width)
                            end,
                            x = -288,
                            y = 0,
                            width = 288,
                            height = 32,
                            alignHoriz = "left",
                            alignVert = "center"
                        }),
                        UI.TextInput:new({
                            background = function() return GetTheme().button_secondary.background end,
                            border = function() return GetTheme().button_secondary.border end,
                            x = 176,
                            width = 64,
                            height = 24,
                            initWith = function() return math.floor(Settings.video.ui_scale*100)/100 end,
                            children = {
                                UI.Text:new({
                                    text = function(me) return me.parent.input.content end,
                                    font = mdfont_2x,
                                    fontScale = 0.5,
                                    width = 64,
                                    height = 24,
                                    alignHoriz = "center",
                                    alignVert = "center",
                                    clickThrough = true
                                })
                            },
                            onvaluechanged = function(self,value)
                                local num = tonumber(value) or 0
                                tempSettings.video.ui_scale = num
                                self.parent.fill = math.max(self.parent.min,math.min(self.parent.max,num))
                            end,
                            onconfirm = function(self,value)
                                local num = tonumber(value) or 0
                                self.input.content = tostring(math.max(self.parent.min,math.min(self.parent.max,num)))
                            end
                        })
                    }
                }),
                UI.Slider:new({
                    id = "background_brightness",
                    x = 112,
                    y = -8,
                    width = 256,
                    height = 24,
                    min = 0, max = 100,
                    fill = 1,
                    initWith = function() return Settings.video.background_brightness*100 end,
                    onvaluechanged = function(self,value)
                        tempSettings.video.background_brightness = value/100
                        self:getChildByType(UI.TextInput).input.content = tostring(math.floor(value))
                    end,
                    children = {
                        UI.Text:new({
                            text = function() return Localize("settings.background_brightness") end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,288/width)
                            end,
                            x = -288,
                            y = 0,
                            width = 288,
                            height = 32,
                            alignHoriz = "left",
                            alignVert = "center"
                        }),
                        UI.TextInput:new({
                            background = function() return GetTheme().button_secondary.background end,
                            border = function() return GetTheme().button_secondary.border end,
                            x = 176,
                            width = 64,
                            height = 24,
                            initWith = function() return math.floor(Settings.video.background_brightness*100) end,
                            children = {
                                UI.Text:new({
                                    text = function(me) return me.parent.input.content end,
                                    font = mdfont_2x,
                                    fontScale = 0.5,
                                    width = 64,
                                    height = 24,
                                    alignHoriz = "center",
                                    alignVert = "center",
                                    clickThrough = true
                                })
                            },
                            onvaluechanged = function(self,value)
                                local num = tonumber(value) or 0
                                tempSettings.video.background_brightness = num/100
                                self.parent.fill = math.max(self.parent.min,math.min(self.parent.max,num))
                            end,
                            onconfirm = function(self,value)
                                local num = tonumber(value) or 0
                                self.input.content = tostring(math.max(self.parent.min,math.min(self.parent.max,num)))
                            end
                        })
                    }
                }),
                UI.Button:new({
                    id = "language",
                    cursor = "hand",
                    x = 112,
                    y = 40,
                    width = 256,
                    height = 32,
                    background = function() return GetTheme().button_secondary.background end,
                    border = function() return GetTheme().button_secondary.border end,
                    onclick = function()
                        local options = UI.ScrollablePanel:new({
                            width = 432,
                            height = 288,
                            x = 0,
                            y = 0,
                            id = "options",
                            children = {},
                            scrollX = 0,
                            scrollY = 0,
                            background = {0,0,0,0}
                        })
                        do
                            local y = 0
                            local function addOption(id)
                                local button = UI.Button:new({
                                    scrollThrough = true,
                                    id = id,
                                    x = 0,
                                    y = y-96,
                                    width = 256,
                                    height = 32,
                                    background = function(me) return GetTheme()[Settings.language == me.id and "button_primary" or "button_secondary"].background end,
                                    border = function(me) return GetTheme()[Settings.language == me.id and "button_primary" or "button_secondary"].border end,
                                    onclick = function(me)
                                        Settings.language = me.id
                                        tempSettings.language = me.id

                                        local logoName = (Languages[Settings.language] or {}).logo
                                        if logoName then
                                            logoName = "logo-" .. logoName
                                        else
                                            logoName = "logo-en"
                                        end
                                        Logo = GetLogo(logoName)
                                    end,
                                    cursor = "hand",
                                    children = {}
                                })
                                button:addChild(UI.Text:new({
                                    clickThrough = true,
                                    y = 0,
                                    width = 256,
                                    height = 24,
                                    text = function(me) return GetLanguageName(me.parent.id) end,
                                    color = function() return GetTheme().button_secondary.text end,
                                    font = lgfont_2x,
                                    fontScale = function(self)
                                        local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                        local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                        local width = font:getWidth(text)
                                        return math.min(0.5,(256-32)/width)
                                    end,
                                    alignHoriz = "center",
                                    alignVert = "center"
                                }))
                                options:addChild(button)
                                y = y + 48
                            end
                            for name,_ in pairs(Languages) do
                                addOption(name)
                            end
                        end
                        local popup = UI.Panel:new({
                            width = 464,
                            height = 480,
                            background = function() return GetTheme().popup_info.background end,
                            border = function() return GetTheme().popup_info.border end,
                            children = {
                                UI.Text:new({
                                    clickThrough = true,
                                    x = 0,
                                    y = -192,
                                    width = 464,
                                    height = 64,
                                    text = function() return Localize("title.language") end,
                                    font = xlfont_2x,
                                    fontScale = function(me)
                                        local text = (type(me.text) == "function" and me:text()) or (me.text or "")
                                        local font = (type(me.font) == "function" and me:font()) or (me.font or mdfont)
                                        local width = font:getWidth(text)
                                        return math.min(0.5,(464-32)/width)
                                    end,
                                    alignHoriz = "center",
                                    alignVert = "center"
                                }),
                                options,
                                UI.Button:new({
                                    id = "close",
                                    width = 256,
                                    height = 64,
                                    y = 192,
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
                    end,
                    children = {
                        UI.Text:new({
                            text = function() return Localize("settings.language") end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,288/width)
                            end,
                            x = -288,
                            y = 0,
                            width = 288,
                            height = 32,
                            alignHoriz = "left",
                            alignVert = "center"
                        }),
                        UI.Text:new({
                            text = function() return GetLanguageName() end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,(256-32)/width)
                            end,
                            x = 0,
                            y = 0,
                            width = 256,
                            height = 32,
                            clickThrough = true,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    }
                }),
            }
        }),
        UI.Button:new({
            id = "apply",
            x = -136,
            y = 160,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_primary.background end,
            border = function() return GetTheme().button_primary.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 120,
                    height = 64,
                    text = function() return Localize("button.apply") end,
                    color = function() return GetTheme().button_back.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function()
                table.merge(Settings, tempSettings)
                ResetFonts()
                WriteSettings() SetMenu("settings")
            end
        }),
        UI.Button:new({
            id = "cancel",
            x = 136,
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
                    text = function() return Localize("button.cancel") end,
                    color = function() return GetTheme().button_back.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function()
                SetMenu("settings")
            end
        })
    }
})

local sAudioMenu = UI.Element:new({
    children = {
        UI.Text:new({
            x = 0,
            y = -180,
            width = 512,
            height = xlfont:getHeight(),
            font = xlfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            text = function() return Localize("title.menu.audio_settings") end
        }),
        UI.ScrollablePanel:new({
            id = "options",
            x = 0,
            y = 0,
            width = 640,
            height = 240,
            background = {0,0,0,0},
            children = {
                UI.Slider:new({
                    id = "music_volume",
                    x = 112,
                    y = -104,
                    width = 256,
                    height = 24,
                    min = 0, max = 100, step = 1,
                    fill = 1,
                    initWith = function() return Settings.audio.music_volume end,
                    onvaluechanged = function(self,value)
                        tempSettings.audio.music_volume = value
                        self:getChildByType(UI.TextInput).input.content = tostring(math.floor(value))
                    end,
                    children = {
                        UI.Text:new({
                            text = function() return Localize("settings.music_volume") end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,288/width)
                            end,
                            x = -288,
                            y = 0,
                            width = 288,
                            height = 32,
                            alignHoriz = "left",
                            alignVert = "center"
                        }),
                        UI.TextInput:new({
                            background = function() return GetTheme().button_secondary.background end,
                            border = function() return GetTheme().button_secondary.border end,
                            x = 176,
                            width = 64,
                            height = 24,
                            initWith = function() return math.floor(Settings.audio.music_volume) end,
                            children = {
                                UI.Text:new({
                                    text = function(me) return me.parent.input.content end,
                                    font = mdfont_2x,
                                    fontScale = 0.5,
                                    width = 64,
                                    height = 24,
                                    alignHoriz = "center",
                                    alignVert = "center",
                                    clickThrough = true
                                })
                            },
                            onvaluechanged = function(self,value)
                                local num = tonumber(value) or 0
                                tempSettings.audio.music_volume = num
                                self.parent.fill = math.max(self.parent.min,math.min(self.parent.max,num))
                            end,
                            onconfirm = function(self,value)
                                local num = tonumber(value) or 0
                                self.input.content = tostring(math.max(self.parent.min,math.min(self.parent.max,num)))
                            end
                        })
                    }
                }),
                UI.Slider:new({
                    id = "sound_volume",
                    x = 112,
                    y = -56,
                    width = 256,
                    height = 24,
                    min = 0, max = 100, step = 1,
                    fill = 1,
                    initWith = function() return Settings.audio.sound_volume end,
                    onvaluechanged = function(self,value)
                        tempSettings.audio.sound_volume = value
                        self:getChildByType(UI.TextInput).input.content = tostring(math.floor(value))
                    end,
                    children = {
                        UI.Text:new({
                            text = function() return Localize("settings.sound_volume") end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,288/width)
                            end,
                            x = -288,
                            y = 0,
                            width = 288,
                            height = 32,
                            alignHoriz = "left",
                            alignVert = "center"
                        }),
                        UI.TextInput:new({
                            background = function() return GetTheme().button_secondary.background end,
                            border = function() return GetTheme().button_secondary.border end,
                            x = 176,
                            width = 64,
                            height = 24,
                            initWith = function() return math.floor(Settings.audio.sound_volume) end,
                            children = {
                                UI.Text:new({
                                    text = function(me) return me.parent.input.content end,
                                    font = mdfont_2x,
                                    fontScale = 0.5,
                                    width = 64,
                                    height = 24,
                                    alignHoriz = "center",
                                    alignVert = "center",
                                    clickThrough = true
                                })
                            },
                            onvaluechanged = function(self,value)
                                local num = tonumber(value) or 0
                                tempSettings.audio.sound_volume = num
                                self.parent.fill = math.max(self.parent.min,math.min(self.parent.max,num))
                            end,
                            onconfirm = function(self,value)
                                local num = tonumber(value) or 0
                                self.input.content = tostring(math.max(self.parent.min,math.min(self.parent.max,num)))
                            end
                        })
                    }
                }),
            }
        }),
        UI.Button:new({
            id = "apply",
            x = -136,
            y = 160,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_primary.background end,
            border = function() return GetTheme().button_primary.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 120,
                    height = 64,
                    text = function() return Localize("button.apply") end,
                    color = function() return GetTheme().button_back.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function()
                table.merge(Settings, tempSettings)
                WriteSettings() SetMenu("settings")
            end
        }),
        UI.Button:new({
            id = "cancel",
            x = 136,
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
                    text = function() return Localize("button.cancel") end,
                    color = function() return GetTheme().button_back.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function()
                SetMenu("settings")
            end
        })
    }
})

local sGameplayMenu = UI.Element:new({
    children = {
        UI.Text:new({
            x = 0,
            y = -180,
            width = 512,
            height = xlfont:getHeight(),
            font = xlfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            text = function() return Localize("title.menu.gameplay_settings") end
        }),
        UI.ScrollablePanel:new({
            id = "options",
            x = 0,
            y = 0,
            width = 640,
            height = 240,
            background = {0,0,0,0},
            children = {
                UI.Button:new({
                    id = "dice_mode",
                    cursor = "hand",
                    x = 112,
                    y = -104,
                    width = 256,
                    height = 32,
                    background = function() return GetTheme().button_secondary.background end,
                    border = function() return GetTheme().button_secondary.border end,
                    onclick = function()
                        local options = UI.ScrollablePanel:new({
                            width = 432,
                            height = 288,
                            x = 0,
                            y = 0,
                            id = "options",
                            children = {},
                            scrollX = 0,
                            scrollY = 0,
                            background = {0,0,0,0}
                        })
                        do
                            local y = 0
                            local function addOption(id)
                                local button = UI.Button:new({
                                    scrollThrough = true,
                                    id = id,
                                    x = 0,
                                    y = y-96,
                                    width = 256,
                                    height = 32,
                                    background = function(me) return GetTheme()[tempSettings.gameplay.dice_mode == me.id and "button_primary" or "button_secondary"].background end,
                                    border = function(me) return GetTheme()[tempSettings.gameplay.dice_mode == me.id and "button_primary" or "button_secondary"].border end,
                                    onclick = function(me)
                                        tempSettings.gameplay.dice_mode = me.id
                                    end,
                                    cursor = "hand",
                                    children = {}
                                })
                                button:addChild(UI.Text:new({
                                    clickThrough = true,
                                    y = 0,
                                    width = 256,
                                    height = 24,
                                    text = function(me) return Localize("dice_mode."..me.parent.id) end,
                                    color = function() return GetTheme().button_secondary.text end,
                                    font = lgfont_2x,
                                    fontScale = function(self)
                                        local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                        local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                        local width = font:getWidth(text)
                                        return math.min(0.5,(256-32)/width)
                                    end,
                                    alignHoriz = "center",
                                    alignVert = "center"
                                }))
                                options:addChild(button)
                                y = y + 48
                            end
                            addOption(0)
                            addOption(1)
                            addOption(2)
                            addOption(3)
                            if Achievements.IsUnlocked("extreme_luck") then addOption(4) end
                        end
                        local popup = UI.Panel:new({
                            width = 464,
                            height = 480,
                            background = function() return GetTheme().popup_info.background end,
                            border = function() return GetTheme().popup_info.border end,
                            children = {
                                UI.Text:new({
                                    clickThrough = true,
                                    x = 0,
                                    y = -192,
                                    width = 464,
                                    height = 64,
                                    text = function() return Localize("title.dice_mode") end,
                                    font = xlfont_2x,
                                    fontScale = function(me)
                                        local text = (type(me.text) == "function" and me:text()) or (me.text or "")
                                        local font = (type(me.font) == "function" and me:font()) or (me.font or mdfont)
                                        local width = font:getWidth(text)
                                        return math.min(0.5,(464-32)/width)
                                    end,
                                    alignHoriz = "center",
                                    alignVert = "center"
                                }),
                                options,
                                UI.Button:new({
                                    id = "close",
                                    width = 256,
                                    height = 64,
                                    y = 192,
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
                    end,
                    children = {
                        UI.Text:new({
                            text = function() return Localize("settings.dice_mode") end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,288/width)
                            end,
                            x = -288,
                            y = 0,
                            width = 288,
                            height = 32,
                            alignHoriz = "left",
                            alignVert = "center"
                        }),
                        UI.Text:new({
                            text = function() return Localize("dice_mode."..tempSettings.gameplay.dice_mode) end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,(256-32)/width)
                            end,
                            x = 0,
                            y = 0,
                            width = 256,
                            height = 32,
                            clickThrough = true,
                            alignHoriz = "center",
                            alignVert = "center"
                        })
                    }
                }),
                UI.Toggle:new({
                    id = "auto_aim_on",
                    cursor = "hand",
                    x = 112,
                    y = -56,
                    width = 32,
                    height = 32,
                    value = function() return Settings.gameplay.auto_aim_on end,
                    ontoggle = function(self,value) tempSettings.gameplay.auto_aim_on = value end,
                    children = {
                        UI.Text:new({
                            text = function() return Localize("settings.auto_aim_on") end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,288/width)
                            end,
                            x = -288,
                            y = 0,
                            width = 288,
                            height = 32,
                            alignHoriz = "left",
                            alignVert = "center"
                        })
                    }
                }),
                UI.Slider:new({
                    id = "auto_aim_limit",
                    x = 112,
                    y = -8,
                    width = 256,
                    height = 24,
                    min = 0, max = 180, step = 1,
                    fill = 1,
                    initWith = function() return Settings.gameplay.auto_aim_limit end,
                    onvaluechanged = function(self,value)
                        tempSettings.gameplay.auto_aim_limit = value
                        self:getChildByType(UI.TextInput).input.content = tostring(math.floor(value))
                    end,
                    children = {
                        UI.Text:new({
                            text = function() return Localize("settings.auto_aim_limit") end,
                            font = lgfont_2x,
                            fontScale = function(self)
                                local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                                local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                                local width = font:getWidth(text)
                                return math.min(0.5,288/width)
                            end,
                            x = -288,
                            y = 0,
                            width = 288,
                            height = 32,
                            alignHoriz = "left",
                            alignVert = "center"
                        }),
                        UI.TextInput:new({
                            background = function() return GetTheme().button_secondary.background end,
                            border = function() return GetTheme().button_secondary.border end,
                            x = 176,
                            width = 64,
                            height = 24,
                            initWith = function() return math.floor(Settings.gameplay.auto_aim_limit) end,
                            children = {
                                UI.Text:new({
                                    text = function(me) return me.parent.input.content end,
                                    font = mdfont_2x,
                                    fontScale = 0.5,
                                    width = 64,
                                    height = 24,
                                    alignHoriz = "center",
                                    alignVert = "center",
                                    clickThrough = true
                                })
                            },
                            onvaluechanged = function(self,value)
                                local num = tonumber(value) or 0
                                tempSettings.gameplay.auto_aim_limit = num
                                self.parent.fill = math.max(self.parent.min,math.min(self.parent.max,num))
                            end,
                            onconfirm = function(self,value)
                                local num = tonumber(value) or 0
                                self.input.content = tostring(math.max(self.parent.min,math.min(self.parent.max,num)))
                            end
                        })
                    }
                }),
            }
        }),
        UI.Button:new({
            id = "apply",
            x = -136,
            y = 160,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_primary.background end,
            border = function() return GetTheme().button_primary.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 120,
                    height = 64,
                    text = function() return Localize("button.apply") end,
                    color = function() return GetTheme().button_back.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function()
                table.merge(Settings, tempSettings)
                WriteSettings() SetMenu("settings")
            end
        }),
        UI.Button:new({
            id = "cancel",
            x = 136,
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
                    text = function() return Localize("button.cancel") end,
                    color = function() return GetTheme().button_back.text end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function()
                SetMenu("settings")
            end
        })
    }
})

AddMenu("settings", settingsMenu)

AddMenu("videoSettings", sVideoMenu)
AddMenu("audioSettings", sAudioMenu)
AddMenu("gameplaySettings", sGameplayMenu)