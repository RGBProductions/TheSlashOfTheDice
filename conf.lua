require "love.system"
IsMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
-- IsMobile = true

DebugMode = false

function love.conf(t)
    for _,a in ipairs(arg) do
        if a == "--debug" then
            DebugMode = true
        end
        if a == "--unlock-fps" then
            t.window.vsync = 0
        end
    end
    t.identity = "TheSlashOfTheDice"
    t.window.resizable = not IsMobile
    t.window.width = 1280
    t.window.height = 720

    -- t.window.width = 1920
    -- t.window.height = 1080
    t.window.title = "The Slash of the Dice"
    t.window.icon = "assets/images/ui/icon.png"

    if IsMobile then
        t.window.usedpiscale = false
        t.window.fullscreen = true
        t.externalstorage = true
    end
end