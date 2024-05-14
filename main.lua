utf8 = require "utf8"

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
json = require "json"

love.filesystem.getInfo = love.filesystem.getInfo or function() return nil end

-- hehe
AprilFoolsMode = false
do
    local date = os.date("*t")
    if date.month == 4 and date.day <= 3 then
        AprilFoolsMode = true
    end
end

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

local _gh = love.graphics.getHeight

---@diagnostic disable-next-line: duplicate-set-field
function love.graphics.getHeight()
    return _gh()-ViewMargin
end

local enableHttps = not IsMobile
-- if love.filesystem.getInfo("https.so") or love.filesystem.getInfo("https.dll") then
--     enableHttps = true
-- end
if enableHttps then
    -- if love.filesystem.getInfo("https.so") then love.filesystem.write("https.so", love.filesystem.read("https.so")) end
    -- if love.filesystem.getInfo("https.dll") then love.filesystem.write("https.dll", love.filesystem.read("https.dll")) end
    local s,r = pcall(require, "https")
    if not s then
        print("Failed to load HTTPS module, ignoring")
        enableHttps = false
    else
        https = r
    end
end

-- if love.filesystem.getInfo("discord-rpc.dll") then
--     love.filesystem.write("discord-rpc.dll", love.filesystem.read("discord-rpc.dll"))
--     love.filesystem.write("libdiscord-rpc.dll", love.filesystem.read("discord-rpc.dll"))
-- end
-- if love.filesystem.getInfo("discord-rpc.so") then
--     love.filesystem.write("discord-rpc.so", love.filesystem.read("discord-rpc.so"))
--     love.filesystem.write("libdiscord-rpc.so", love.filesystem.read("discord-rpc.so"))
-- end

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
    function DiscordRPC.joinGame(secret)
        print("Join Game: " .. secret)
    end

    function DiscordRPC.joinRequest(user)
        print("Join Request: " .. user)
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

function CompareVersions(a,b)
    local t1 = string.split_plain(a, ".")
    local t2 = string.split_plain(b, ".")
    for i,v in ipairs(t1) do
        t1[i] = string.split_plain(v, "-")[1]
    end
    for i,v in ipairs(t2) do
        t2[i] = string.split_plain(v, "-")[1]
    end

    for i = 1, math.max(#t1,#t2) do
        if tonumber(t1[i] or 0) > tonumber(t2[i] or 0) then
            return 1
        end
        if tonumber(t1[i] or 0) < tonumber(t2[i] or 0) then
            return -1
        end
    end
    return 0
end

UpdateCheckFailed = 0

-- File method
function CheckForUpdates()
    local versionUrl = "https://raw.githubusercontent.com/RGBProductions/TheSlashOfTheDice/main/version.txt"
    local code,data,headers = https.request(versionUrl, {method = "get"})
    if code ~= 200 then return end
    local lines = data:split("\n")
    local cmp = 0
    if #lines > 1 then
        cmp = (tonumber(lines[2]) > tonumber(version_number) and 1) or (tonumber(lines[2]) < tonumber(version_number) and -1) or 0
    else
        print("No version code exists. Comparing via name instead")
        cmp = CompareVersions(version, lines[1])
    end
    if cmp == 1 then
        beta = true
    elseif cmp == -1 then
        update = {true, lines[1]}
    end
end

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
    Music:setVolume(Settings["Audio"]["Music Volume"]/100)
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
            t[k] = table.merge(t[k],v)
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

function love.load()
    if DiscordRPC then DiscordRPC.initialize("1124036737413435502", true) end
    Settings = {
        ["Language"] = "en_US",
        
        ["Video"] = {
            ["UI Scale"] = 1.5,
            ["Color by Operator"] = true
        },

        ["Audio"] = {
            ["Sound Volume"] = 75,
            ["Music Volume"] = 75
        },

        ["Gameplay"] = {
            ["Dice Weighing Mode"] = 2,
            ["Auto Aim"] = IsMobile,
            ["Auto Aim Limit"] = 45
        },

        ["Customization"] = {
            ["PlayerR"] = 0,
            ["PlayerG"] = 1,
            ["PlayerB"] = 1
        }
    }
    if love.filesystem.getInfo("settings.json") then
        local itms = json.decode(love.filesystem.read("settings.json"))
        Settings = table.merge(Settings, itms)
    end

    MenuBG = love.graphics.newImage("assets/images/ui/background.png")
    MenuBG:setWrap("repeat", "repeat", "repeat")
    BGShader = love.graphics.newShader("assets/shaders/menu.glsl")
    BGShader:send("tex", MenuBG)
    BGShader:send("texSize", {MenuBG:getDimensions()})
    BGShader:send("time", (GlobalTime-600)*48)
    MenuBGMobile = love.graphics.newImage("assets/images/ui/background-mobile.png")
    MenuBGMobile:setWrap("repeat", "repeat", "repeat")
end

local frame = 0
local saveTime = 0

GlobalTime = 0
local presenceTimer = 0

function love.update(dt)
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
            Music:setVolume((Settings["Audio"]["Music Volume"]/100)*0.5)
        else
            Music:setVolume(Settings["Audio"]["Music Volume"]/100)
        end
    end
    frame = frame + 1
    if frame == 2 then
        if enableHttps then pcall(CheckForUpdates) end
    
        Events.fire("modPreInit")
        Events.fire("modPostInit")
        
        SceneManager.LoadScene("scenes/menu", {})
    end
    if frame > 3 then
        SceneManager.Update(dt)
    end
    GlobalTime = GlobalTime + dt
    if #AchievementUnlocks >= 1 then
        AchievementUnlocks[1].time = AchievementUnlocks[1].time + dt
        if AchievementUnlocks[1].time >= 3 then
            table.remove(AchievementUnlocks, 1)
        end
    end
end

function love.mousemoved(x, y, dx, dy)
    if frame > 3 then
        SceneManager.MouseMoved(x, y, dx, dy)
    end
end

function love.wheelmoved(x, y)
    if frame > 3 then
        SceneManager.WheelMoved(x, y)
    end
end

function love.focus(f)
    if frame > 3 then
        SceneManager.Focus(f)
    end
    if not f then
        Achievements.Save("achievements.txt")
    end
end

function love.keypressed(k)
    if k == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
    if frame > 3 then
        SceneManager.KeyPressed(k)
    end
end

function love.textinput(t)
    if frame > 3 then
        SceneManager.TextInput(t)
    end
end

function love.mousepressed(x,y,b)
    if frame > 3 then
        SceneManager.MousePressed(x,y,b)
    end
end

function love.gamepadpressed(stick,b)
    SceneManager.GamepadPressed(stick,b)
end

function love.touchpressed(...)
    if frame > 3 then
        SceneManager.TouchPressed(...)
    end
end

function love.touchmoved(...)
    if frame > 3 then
        SceneManager.TouchMoved(...)
    end
end

function love.touchreleased(...)
    if frame > 3 then
        SceneManager.TouchReleased(...)
    end
end

function love.draw()
    if frame > 3 then
        SceneManager.Draw()
    else
        love.graphics.setFont(xlfont)
        love.graphics.printf(Localize("update.retrieving"), 0, (love.graphics.getHeight()-xlfont:getHeight())/2, love.graphics.getWidth(), "center")
    end
    if #AchievementUnlocks >= 1 then
        local txt = Localize(AchievementUnlocks[1].achievement)
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
end

function love.quit()
    Achievements.Save("achievements.txt")
    if DiscordRPC then DiscordRPC.shutdown() end
end
