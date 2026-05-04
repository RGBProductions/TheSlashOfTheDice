local modsMenu = UI.Element:new({
    children = {
        UI.Text:new({
            x = 0,
            y = -180,
            width = 512,
            height = 72,
            font = xlfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            alignVert = "center",
            text = function() return Slash.Localization.Localize("title.menu.mods") end
        }),
        UI.Element:new({
            id = "enabled",
            x = -320,
            y = 0,
            width = 512,
            height = 224,
            children = {
                UI.Text:new({
                    x = 0,
                    y = -148,
                    width = 512,
                    height = 72,
                    font = lrfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "left",
                    alignVert = "center",
                    text = function() return Slash.Localization.Localize("title.mods.enabled") end
                }),
                UI.ScrollablePanel:new({
                    id = "mods.enabled",
                    x = 0,
                    y = 0,
                    width = 512,
                    height = 224,
                    background = {0,0,0,0},
                    children = {}
                }),
                UI.Text:new({
                    id = "nomods.enabled",
                    x = 0,
                    y = -64,
                    width = 512,
                    height = 72,
                    font = lrfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center",
                    text = function() return Slash.Localization.Localize("nomods.enabled") end
                })
            }
        }),
        UI.Element:new({
            id = "disabled",
            x = 320,
            y = 0,
            width = 512,
            height = 224,
            children = {
                UI.Text:new({
                    x = 0,
                    y = -148,
                    width = 512,
                    height = 72,
                    font = lrfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "right",
                    alignVert = "center",
                    text = function() return Slash.Localization.Localize("title.mods.disabled") end
                }),
                UI.ScrollablePanel:new({
                    id = "mods.disabled",
                    x = 0,
                    y = 0,
                    width = 512,
                    height = 224,
                    background = {0,0,0,0},
                    children = {}
                }),
                UI.Text:new({
                    id = "nomods.disabled",
                    x = 0,
                    y = -64,
                    width = 512,
                    height = 72,
                    font = lrfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center",
                    text = function() return Slash.Localization.Localize("nomods.disabled") end
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
                    text = function() return Slash.Localization.Localize("button.back") end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function()
                if Slash.Mod.RequiresRestart() then
                    love.event.quit("restart")
                    return
                end
                SetMenu("main")
            end
        }),
        UI.Text:new({
            id = "needsrestart",
            x = 0,
            y = 224,
            width = 512,
            height = 72,
            font = lgfont_2x,
            fontScale = 0.5,
            alignHoriz = "center",
            alignVert = "top",
            text = function() return Slash.Localization.Localize("title.mods.requires_restart") end
        })
    }
})

AddMenu("mods", modsMenu)