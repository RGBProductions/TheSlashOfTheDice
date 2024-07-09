local customizeMenu = UI.Element:new({
    id = "customizeMenu",
    children = {
        UI.Panel:new({
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
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
            background = function() return GetTheme().button_primary.background end,
            border = function() return GetTheme().button_primary.border end,
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
                    image = ButtonIcons.materialsymbols_play_arrow,
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
                            image = ButtonIcons.materialsymbols_colors,
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
                            width = 480,
                            height = 488,
                            background = function() return GetTheme().popup_info.background end,
                            border = function() return GetTheme().popup_info.border end,
                            children = {
                                UI.Text:new({
                                    clickThrough = true,
                                    x = 0,
                                    y = -196,
                                    width = 480,
                                    height = 64,
                                    text = function() return Localize("title.customization.color") end,
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
                                UI.ColorPicker:new({
                                    id = "colorpicker",
                                    x = 0,
                                    y = -20,
                                    width = 256,
                                    height = 256,
                                    hue = h,
                                    saturation = s,
                                    value = v,
                                    oncolorchanged = function(me,hsv,rgb)
                                        me.parent:getChildById("hexcode").input.content = HexCodeOf(rgb[1],rgb[2],rgb[3])
                                    end
                                }),
                                UI.TextInput:new({
                                    id = "hexcode",
                                    x = 0,
                                    y = 132,
                                    width = 256,
                                    height = 32,
                                    background = function() return GetTheme().button_secondary.background end,
                                    border = function() return GetTheme().button_secondary.border end,
                                    initWith = function(me)
                                        return HexCodeOf(unpack(Settings.customization.color))
                                    end,
                                    onvaluechanged = function(me,value)
                                        local S,R = pcall(Color,value)
                                        if S then
                                            me.parent:getChildById("colorpicker"):setRGB(unpack(R))
                                        end
                                    end,
                                    children = {
                                        UI.Text:new({
                                            clickThrough = true,
                                            width = 256,
                                            height = 32,
                                            alignHoriz = "center",
                                            alignVert = "center",
                                            font = lgfont_2x,
                                            fontScale = 0.5,
                                            text = function (me)
                                                if me.parent.selected then
                                                    return me.parent.input.content
                                                end
                                                return HexCodeOf(unpack(me.parent.parent:getChildById("colorpicker"):getRGB()))
                                            end
                                        })
                                    }
                                }),
                                UI.Button:new({
                                    id = "apply",
                                    width = 256,
                                    height = 64,
                                    y = 156+40,
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
                            image = ButtonIcons.materialsymbols_footprint,
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
                            y = 0,
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
                                    background = function(me) return GetTheme()[Settings.customization.trail == me.id and "button_primary" or "button_secondary"].background end,
                                    border = function(me) return GetTheme()[Settings.customization.trail == me.id and "button_primary" or "button_secondary"].border end,
                                    onclick = function(me) Settings.customization.trail = me.id end,
                                    cursor = "hand",
                                    children = {}
                                })
                                button:addChild(UI.Text:new({
                                    clickThrough = true,
                                    y = 60,
                                    width = 96,
                                    height = 24,
                                    text = function(me) return Localize(me.parent.id == nil and "customization.none" or ("customization.trails."..me.parent.id..".name")) end,
                                    color = function() return GetTheme().button_secondary.text end,
                                    font = mdfont_2x,
                                    fontScale = function(me)
                                        local text = me.text(me)
                                        local width = me.font:getWidth(text)/2
                                        return math.min(1,me.width/width)*0.5
                                    end,
                                    alignHoriz = "center",
                                    alignVert = "center"
                                }))
                                if data and data.icon then
                                    button:addChild(UI.Image:new({
                                        clickThrough = true,
                                        image = data.icon,
                                        width = 64,
                                        height = 64
                                    }))
                                else
                                    button:addChild(UI.Text:new({
                                        clickThrough = true,
                                        width = 96,
                                        height = 96,
                                        text = function(me) return Localize(me.parent.id == nil and "customization.none" or ("customization.trails."..me.parent.id..".name")) end,
                                        color = function() return GetTheme().button_secondary.text end,
                                        font = mdfont_2x,
                                        fontScale = 0.5,
                                        alignHoriz = "center",
                                        alignVert = "center"
                                    }))
                                end
                                options:addChild(button)
                                x = x + 96 + 16
                                if x >= 432 then
                                    x = 0
                                    y = y + 120 + 16
                                end
                            end
                            addOption(nil, {icon = NoCosmeticIcon})
                            for name,data in pairs(Cosmetics.Trails) do
                                addOption(name,data)
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
                                    text = function() return Localize("title.customization.trail") end,
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
                            image = ButtonIcons.materialsymbols_skull_outline,
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
                            y = 0,
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
                                    background = function(me) return GetTheme()[Settings.customization.death_effect == me.id and "button_primary" or "button_secondary"].background end,
                                    border = function(me) return GetTheme()[Settings.customization.death_effect == me.id and "button_primary" or "button_secondary"].border end,
                                    onclick = function(me) Settings.customization.death_effect = me.id end,
                                    cursor = "hand",
                                    children = {}
                                })
                                button:addChild(UI.Text:new({
                                    clickThrough = true,
                                    y = 60,
                                    width = 96,
                                    height = 24,
                                    text = function(me) return Localize(me.parent.id == nil and "customization.none" or ("customization.effects."..me.parent.id..".name")) end,
                                    color = function() return GetTheme().button_secondary.text end,
                                    font = mdfont_2x,
                                    fontScale = function(me)
                                        local text = me.text(me)
                                        local width = me.font:getWidth(text)/2
                                        return math.min(1,me.width/width)*0.5
                                    end,
                                    alignHoriz = "center",
                                    alignVert = "center"
                                }))
                                if data and data.icon then
                                    button:addChild(UI.Image:new({
                                        clickThrough = true,
                                        image = data.icon,
                                        width = 64,
                                        height = 64
                                    }))
                                else
                                    button:addChild(UI.Text:new({
                                        clickThrough = true,
                                        width = 96,
                                        height = 96,
                                        text = function(me) return Localize(me.parent.id == nil and "customization.none" or ("customization.effects."..me.parent.id..".name")) end,
                                        color = function() return GetTheme().button_secondary.text end,
                                        font = mdfont_2x,
                                        fontScale = 0.5,
                                        alignHoriz = "center",
                                        alignVert = "center"
                                    }))
                                end
                                options:addChild(button)
                                x = x + 96 + 16
                                if x >= 432 then
                                    x = 0
                                    y = y + 120 + 16
                                end
                            end
                            addOption(nil, {icon = NoCosmeticIcon})
                            for name,data in pairs(Cosmetics.Effects) do
                                addOption(name, data)
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
                                    text = function() return Localize("title.customization.death_effect") end,
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
                            image = ButtonIcons.mingcute_hat_fill,
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
                            y = 0,
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
                                button:addChild(UI.Text:new({
                                    clickThrough = true,
                                    y = 60,
                                    width = 96,
                                    height = 24,
                                    text = function(me) return Localize(me.parent.id == nil and "customization.none" or ("customization.hats."..me.parent.id..".name")) end,
                                    color = function() return GetTheme().button_secondary.text end,
                                    font = mdfont_2x,
                                    fontScale = function(me)
                                        local text = me.text(me)
                                        local width = me.font:getWidth(text)/2
                                        return math.min(1,me.width/width)*0.5
                                    end,
                                    alignHoriz = "center",
                                    alignVert = "center"
                                }))
                                if data then
                                    button:addChild(UI.Image:new({
                                        clickThrough = true,
                                        image = data.image,
                                        width = data.image:getWidth()*(data.scale or 1),
                                        height = data.image:getHeight()*(data.scale or 1)
                                    }))
                                end
                                options:addChild(button)
                                x = x + 96 + 16
                                if x >= 432 then
                                    x = 0
                                    y = y + 120 + 16
                                end
                            end
                            addOption(nil, {image = NoCosmeticIcon, scale = 0.5})
                            for name,data in pairs(Cosmetics.Hats) do
                                addOption(name,data)
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
                                    text = function() return Localize("title.customization.hat") end,
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
                    image = ButtonIcons.materialsymbols_exit_to_app,
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
                    image = ButtonIcons.materialsymbols_help,
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
                            image = ButtonIcons.materialsymbols_colors,
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
                            image = ButtonIcons.materialsymbols_footprint,
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
                            image = ButtonIcons.materialsymbols_skull_outline,
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
                            image = ButtonIcons.mingcute_hat_fill,
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

AddMenu("customize", customizeMenu)