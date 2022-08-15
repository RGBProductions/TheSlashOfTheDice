love.filesystem.write("https.so", love.filesystem.read("https.so"))
love.filesystem.write("https.dll", love.filesystem.read("https.dll"))
local https = require "https"
require "scenemanager"
require "pools"

json = require "json"
love.graphics.setDefaultFilter("nearest", "nearest")

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
--how do you feel rn--
-- local vals = string.split_plain("1.0-JAM", ".")
-- local t = string.split_plain(vals[#vals], "-")
-- for i,v in ipairs(vals) do
--     vals[i] = string.split_plain(v, "-")[1]
-- end
-- print("Major: " .. vals[1])
-- print("Minor: " .. vals[2])
-- print("Revision: " .. (vals[3] or 0))
-- print("Type: " .. (t[2] or "RELEASE"))
-- print("Full version: " .. vals[1] .. "." .. vals[2] .. "." .. (vals[3] or 0) .. "-" .. (t[2] or "RELEASE"))
-- print("Actual version: " .. table.join(vals, "."))

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

-- MichaelEpicA's Method
function CheckForUpdates()
    -- local code,data,headers,unknown = https.request("https://github.com/TheFuryBumblebee/TheSlashOfTheDice/releases/latest")
    local code,data,headers = https.request("https://github.com/TheFuryBumblebee/TheSlashOfTheDice/releases/latest", {method = "get"})
    local location = headers.location
    if not headers.location then
        location = headers.Location -- Windows
    end
    local real_url = location:sub(2,-1)
    local spl = real_url:split("/")
    local tag = spl[#spl]
    local cmp = CompareVersions(version, tag:sub(2,-1))
    if cmp == 1 then
        beta = true
    elseif cmp == -1 then
        update = {true, tag}
    end
end

CheckForUpdates()

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
    Music:setLooping(true)
    Music:setVolume(Settings["Audio"]["Music Volume"]/100)
    Music:play()
end

function StopMusic()
    if Music then
        Music:stop()
    end
end

function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function RecursiveOverwrite(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            t1[k] = {}
            t1[k] = RecursiveOverwrite(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

function table.merge(t, m)
    local res = deepcopy(t)
    return RecursiveOverwrite(res, m)
end

function love.load()
    Settings = {
        ["Video"] = {
            ["UI Scale"] = 1.5,
            ["Color by Operator"] = true
        },

        ["Audio"] = {
            ["Sound Volume"] = 75,
            ["Music Volume"] = 75
        },

        ["Gameplay"] = {
            ["Dice Weighing Mode"] = 2
        }
    }
    if love.filesystem.getInfo("settings.json") then
        local itms = json.decode(love.filesystem.read("settings.json"))
        Settings = table.merge(Settings, itms)
    end
    SceneManager.LoadScene("scenes/menu", {})
end

function love.update(dt)
    SceneManager.Update(dt)
end

function love.mousemoved(x, y, dx, dy)
    SceneManager.MouseMoved(x, y, dx, dy)
end

function love.wheelmoved(x, y)
    SceneManager.WheelMoved(x, y)
end

function love.focus(f)
    SceneManager.Focus(f)
end

function love.keypressed(k)
    SceneManager.KeyPressed(k)
end

function love.textinput(t)
    SceneManager.TextInput(t)
end

function love.mousepressed(x,y,b)
    SceneManager.MousePressed(x,y,b)
end

function love.draw()
    SceneManager.Draw()
end