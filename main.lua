utf8 = require "utf8"
hsx = require "lib.hsx"
json = require "json"

function utf8.sub(txt, i, j)
    local o1 = (utf8.offset(txt,i) or (#txt))-1
    local o2 = (utf8.offset(txt,j+1) or (#txt+1))-1
    return txt:sub(o1,o2)
end

do
    local s,r = pcall(require, "websocket")
    if s then
        websocket = r
    end
end

love.filesystem.getInfo = love.filesystem.getInfo or function() return nil end

ShowMobileUI = IsMobile

ShowDebugInfo = false
DrawTime = 0
UpdateTime = 0

ViewScale = 1
ViewMargin = 0
FontScale = IsMobile and 1.5 or 1
-- ViewMargin = 0

SlashIcon = love.graphics.newImage("assets/images/ui/slash.png")
PauseIcon = love.graphics.newImage("assets/images/ui/pause.png")
BackIcon = love.graphics.newImage("assets/images/ui/back.png")
ForwardIcon = love.graphics.newImage("assets/images/ui/forward.png")
FastBackIcon = love.graphics.newImage("assets/images/ui/fastback.png")
FastForwardIcon = love.graphics.newImage("assets/images/ui/fastforward.png")

Trophy = love.graphics.newImage("assets/images/ui/cubetrophy.png")

function IsHosting()
    return InGame and ((not IsMultiplayer) or Net.Hosting)
end

local _gh = love.graphics.getHeight

---@diagnostic disable-next-line: duplicate-set-field
function love.graphics.getHeight()
    return _gh()-ViewMargin
end

do
    local s,r = pcall(require, "lib.discordRPC")
    if s then
        DiscordRPC = r
    else
        print("Couldn't load Discord RPC: " .. tostring(r))
        DiscordRPC = nil
    end
end

if DiscordRPC then
    DiscordRPC.joinGame = function(secret)
        print("Discord join game: " .. secret)
    end

    DiscordRPC.joinRequest = function(user)
        print("Discord join request: " .. user)
    end

    DiscordRPC.ready = function(userId, username, discriminator, avatar)
        print("Discord connected to user " .. username)
    end

    DiscordRPC.errored = function(errorCode, message)
        print("Discord error: " .. message .. " (Code " .. errorCode .. ")")
    end
    
    DiscordRPC.disconnected = function(errorCode, message)
        print("Discord disconnected: " .. message .. " (Code " .. errorCode .. ")")
    end
else
    print("Discord RPC was not initialized.")
end

-- smfont = love.graphics.getFont()
smfont = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 12)
mdfont = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 16*FontScale)
lgfont = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 24*FontScale)
lrfont = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 32*FontScale)
xlfont = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 48*FontScale)

smfont_2x = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 12*2)
mdfont_2x = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 16*2)
lgfont_2x = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 24*2)
lrfont_2x = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 32*2)
xlfont_2x = love.graphics.newFont("assets/fonts/NotoSansJP-Regular.ttf", 48*2)

SusMode = false

function timerString(time)
    local hr = tostring(math.floor(time/3600))
    local min = tostring(math.floor(time/60)%60)
    local sec = tostring(math.floor(time)%60)
    local t = sec
    if min ~= "0" then
        t = min .. ":" .. ("0"):rep(2-#t) .. t
    end
    if hr ~= "0" then
        t = hr .. ":" .. ("0"):rep(5-#t) .. t
    end
    return t
end

function string.split(text, delimiter)
    local result = {}
    for match in (text..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function string.split_plain(text, delimiter)
    local result = {}
    local current = ""
    for i = 1, #text do
        if text:sub(i,i) == delimiter then
            table.insert(result, current)
            current = ""
        else
            current = current .. text:sub(i,i)
        end
    end
    table.insert(result, current)
    return result
end

function table.join(t, s)
    s = s or ", "
    local res = ""
    for n,i in ipairs(t) do
        res = res .. i
        if n ~= #t then
            res = res .. s
        end
    end
    return res
end

AchievementUnlocks = {}

function UnlockAchievement(id, titleText)
    table.insert(AchievementUnlocks, {achievement = id, time = 0, titleText = titleText})
end

require "events"
require "pools"
require "game"
require "lang"
require "entitytypes"
require "sounds"
require "scenemanager"
require "network"
require "achievements"
require "ui"
require "menus"
require "cosmetics"

require "default.menus"

if not love.filesystem.getInfo("achievements.txt") then
    Achievements.Save("achievements.txt")
end
Achievements.Load("achievements.txt")
love.graphics.setDefaultFilter("nearest", "nearest")

function RecursiveDelete( item )
    if love.filesystem.getInfo( item , "directory" ) then
        for _, child in pairs( love.filesystem.getDirectoryItems( item )) do
            RecursiveDelete( item .. '/' .. child )
            love.filesystem.remove( item .. '/' .. child )
        end
    elseif love.filesystem.getInfo( item ) then
        love.filesystem.remove( item )
    end
    love.filesystem.remove( item )
end

local curver = love.filesystem.read("version.txt"):split("\n")
version = curver[1]
version_number = curver[2]
update = {false, version}
beta = false
checkingUpdate = true

local updateThread = love.thread.newThread("checkupdate.lua")
local updateChannel = love.thread.getChannel("update")

function table.index(t,v)
    for n,i in pairs(t) do
        if i == v then
            return n
        end
    end
    return nil
end

function math.round(x)
    return math.floor(x+0.5)
end

function math.sign(x)
    return (x > 0 and 1) or (x < 0 and -1) or 0
end

function LoadMusic(fn)
    local s,r = pcall(love.audio.newSource, fn, "stream")
    if not s then
        return print("WARNING: Music " .. fn .. " not found; skipping")
    end
    Music = r
    CurrentMusic = fn
    Music:setLooping(true)
    Music:setVolume(Settings.audio.music_volume/100)
    Music:play()
end

function StopMusic()
    if Music then
        Music:stop()
    end
end

function table.merge(t, m)
    t = t or {}
    for k,v in pairs(m) do
        if type(v) == "table" then
            if type(t[k]) == "table" then
                t[k] = table.merge(t[k],v)
            else
                t[k] = table.merge({},v)
            end
        else
            t[k] = v
        end
    end
    return t
end

function math.dot(a,b)
    local sum = 0
    for i = 1, math.max(#a,#b) do
        sum = sum + (a[i] or 0)*(b[i] or 0)
    end
    return sum
end

function math.norm(v)
    local m = 0
    for i = 1, #v do
        m = m + v[i]^2
    end
    m = math.sqrt(m)
    if m == 0 then return v end
    local r = {}
    for i = 1, #v do
        table.insert(r, v[i]/m)
    end
    return r
end

DiscordPresence = {
    details = "Launching",
    startTimestamp = os.time(),
    largeImageKey = "main_icon"
}

Settings = {
    language = "en_US",

    video = {
        ui_scale = 1.5,
        color_by_operator = true,
        background_brightness = 1,
        menu_theme = "aura"
    },

    audio = {
        sound_volume = 75,
        music_volume = 75
    },

    gameplay = {
        dice_mode = 2,
        auto_aim_on = IsMobile,
        auto_aim_limit = 45
    },

    customization = {
        color = {0,1,1},
        hat = nil,
        trail = "flame",
        death_effect = nil
    }
}

Cosmetics.Search("default/cosmetics")
if love.filesystem.getInfo("settings.json") then
    local itms = json.decode(love.filesystem.read("settings.json"))
    Settings = table.merge(Settings, itms)
end
function DeathHandler() 
print("died")
end
function StepHandler(event) 
    if Settings.customization.trail then
        local trail = Cosmetics.Trails[Settings.customization.trail]
        if trail.events.step then
        local actions = trail.events.step.actions
        for _,v in ipairs(actions) do
            if v.type == "particle" then
                local particle = Game.Particle:new(event.x, event.y, v.life, v.velocity[1], v.velocity[2], 0, math.random(v.size[1],v.size[2]))
                particle.image = v.image
                table.insert(Particles, particle)
            end
        end
    end
    end
end
Events.on("step",StepHandler)
Events.on("player_death", DeathHandler)
function WriteSettings()
    local s,r = pcall(json.encode,Settings)
    if not s then
        print("Failed to save settings: " .. r)
        return
    end
    local s2,r2 = pcall(love.filesystem.write, "settings.json", r)
    if not s2 then
        print("Failed to save settings: " .. r2)
        return
    end
end

Cosmetics.Search("default/cosmetics")

ThemePresets = {}
for _,itm in ipairs(love.filesystem.getDirectoryItems("default/themes")) do
    local name = itm:sub(1,-6)
    local ext = itm:sub(-5,-1)
    if ext == ".json" then
        local s,r = pcall(json.decode, love.filesystem.read("default/themes/" .. itm))
        if s then
            ThemePresets[name] = r
        end
    end
end

function GetTheme()
    if type(Settings.video.menu_theme) == "string" then
        return (ThemePresets[Settings.video.menu_theme] or {}).theme or ((ThemePresets.aura or {}).theme or {})
    end
    return (Settings.video.menu_theme or {})
end

function love.load()
    if DiscordRPC then DiscordRPC.initialize("1124036737413435502", true) end

    MenuBG = love.graphics.newImage("assets/images/ui/background.png")
    MenuBG:setWrap("repeat", "repeat", "repeat")
    BGShader = love.graphics.newShader("assets/shaders/menu.glsl")
    BGShader:send("tex", MenuBG)
    BGShader:send("texSize", {MenuBG:getDimensions()})
    BGShader:send("time", (GlobalTime-600)*48)
    MenuBGMobile = love.graphics.newImage("assets/images/ui/background-mobile.png")
    MenuBGMobile:setWrap("repeat", "repeat", "repeat")
    
    updateThread:start()

    Events.fire("modPreInit")
    Events.fire("modPostInit")
    
    SceneManager.LoadScene("scenes/menu", {})
end

local saveTime = 0

GlobalTime = 0
local presenceTimer = 0

function love.update(dt)
    local t = love.timer.getTime()

    if updateChannel:getCount() > 0 then
        checkingUpdate = false
        local updateMessage = updateChannel:pop()
        if updateMessage[1] then -- Update checking passed
            beta = updateMessage[2]
            update = updateMessage[3]
        end
    end

    if DiscordRPC then
        DiscordRPC.runCallbacks()
    end

    Net.Update()
    saveTime = saveTime + dt
    if saveTime >= 30 then
        Achievements.Save("achievements.txt")
        saveTime = 0
    end
    presenceTimer = presenceTimer + dt
    if presenceTimer >= 2 then
        if DiscordRPC then DiscordRPC.updatePresence(DiscordPresence) end
        presenceTimer = 0
    end
    if Music then
        if Paused then
            Music:setVolume((Settings.audio.music_volume/100)*0.5)
        else
            Music:setVolume(Settings.audio.music_volume/100)
        end
    end
    SceneManager.Update(dt)
    GlobalTime = GlobalTime + dt
    if #AchievementUnlocks >= 1 then
        AchievementUnlocks[1].time = AchievementUnlocks[1].time + dt
        if AchievementUnlocks[1].time >= 3 then
            table.remove(AchievementUnlocks, 1)
        end
    end

    UpdateTime = love.timer.getTime() - t
end

function love.mousemoved(x, y, dx, dy)
    SceneManager.MouseMoved(x, y, dx, dy)
end

function love.wheelmoved(x, y)
    SceneManager.WheelMoved(x, y)
end

function love.focus(f)
    SceneManager.Focus(f)
    if not f then
        Achievements.Save("achievements.txt")
    end
end

function love.keypressed(k)
    if k == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
    if k == "f3" then
        ShowDebugInfo = not ShowDebugInfo
    end
    ShowMobileUI = false
    SceneManager.KeyPressed(k)
end

function love.textinput(t)
    SceneManager.TextInput(t)
end

function love.mousepressed(x,y,b,t,p)
    ShowMobileUI = t
    SceneManager.MousePressed(x,y,b,t,p)
end

function love.mousereleased(x,y,b)
    SceneManager.MouseReleased(x,y,b)
end

function love.gamepadpressed(stick,b)
    SceneManager.GamepadPressed(stick,b)
end

function love.touchpressed(...)
    SceneManager.TouchPressed(...)
end

function love.touchmoved(...)
    SceneManager.TouchMoved(...)
end

function love.touchreleased(...)
    SceneManager.TouchReleased(...)
end

function love.draw()
    local t = love.timer.getTime()

    SceneManager.Draw()
    if #AchievementUnlocks >= 1 then
        local txt = Localize("achievement."..AchievementUnlocks[1].achievement..".name")
        local w = math.max(lrfont:getWidth(Localize(AchievementUnlocks[1].titleText or "achievement_unlocked")), lgfont:getWidth(txt))
        local h = lrfont:getHeight()+lgfont:getHeight()
        local icon = Achievements.Achievements[AchievementUnlocks[1].achievement].icon
        love.graphics.setColor(0.1,0.1,0.1,math.min(1,(3-AchievementUnlocks[1].time)*2))
        love.graphics.rectangle("fill", love.graphics.getWidth()-h-w-4, love.graphics.getHeight()-h-4, w+h+4, h+4)
        love.graphics.setColor(1,1,1,math.min(1,(3-AchievementUnlocks[1].time)*2))
        love.graphics.setFont(lrfont)
        love.graphics.draw(icon, love.graphics.getWidth()-w-h-8-2, love.graphics.getHeight()-h-2, 0, h/icon:getWidth(), h/icon:getHeight())
        love.graphics.print("Achievement Unlocked!", love.graphics.getWidth()-w-2, love.graphics.getHeight()-h-2)
        love.graphics.setFont(lgfont)
        love.graphics.print(txt, love.graphics.getWidth()-w-2, love.graphics.getHeight()-h-2+lrfont:getHeight())
        love.graphics.setColor(0,0,0,math.min(1,(3-AchievementUnlocks[1].time)*2))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", love.graphics.getWidth()-h-8-w-3, love.graphics.getHeight()-h-3, w+h+8, h)
    end

    love.graphics.setFont(smfont)
    love.graphics.setColor(1,1,1)
    local txt = love.timer.getFPS() .. " FPS"
    local w = smfont:getWidth(txt)
    love.graphics.print(txt, love.graphics.getWidth()-w, 0)
    
    DrawTime = love.timer.getTime()-t

    if ShowDebugInfo then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), smfont:getHeight()*16)
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(smfont)
        love.graphics.print("The Slash of the Dice v" .. version, 0, smfont:getHeight()*0)
        local major,minor,rev,name = love.getVersion()
        love.graphics.print("LÖVE v" .. major .. "." .. minor .. " (" .. name .. ")", 0, smfont:getHeight()*1)
        love.graphics.print("Render Time: " .. math.ceil(DrawTime*1000) .. " ms (" .. math.floor(1/DrawTime) .. " FPS)", 0, smfont:getHeight()*3)
        love.graphics.print("Update Time: " .. math.ceil(UpdateTime*1000) .. " ms (" .. math.floor(1/UpdateTime) .. " FPS)", 0, smfont:getHeight()*4)
        love.graphics.print("Total Frame Time: " .. math.ceil((UpdateTime+DrawTime)*1000) .. " ms (" .. math.floor(1/(UpdateTime+DrawTime)) .. " FPS)", 0, smfont:getHeight()*5)
        
        love.graphics.print("Is Game Host: " .. tostring(IsHosting()), 0, smfont:getHeight()*7)
        love.graphics.print("Entities: " .. #(Entities or {}), 0, smfont:getHeight()*8)
        love.graphics.print("Particles: " .. #(Particles or {}), 0, smfont:getHeight()*9)
    end
end

function love.quit()
    Achievements.Save("achievements.txt")
    if DiscordRPC then DiscordRPC.shutdown() end
end

function love.lowmemory()
    print("LOW MEMORY, ATTEMPTING TO CLEAR")
    collectgarbage()
end