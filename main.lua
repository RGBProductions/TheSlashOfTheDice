require "scenemanager"

json = require "json"
love.graphics.setDefaultFilter("nearest", "nearest")

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

function LoadMusic(fn)
    local s,r = pcall(love.audio.newSource, fn, "stream")
    if not s then
        return print("WARNING: Music " .. fn .. " not found; skipping")
    end
    Music = r
    Music:setLooping(true)
    Music:setVolume(Settings["Music Volume"]/100)
    Music:play()
end

function StopMusic()
    if Music then
        Music:stop()
    end
end

function love.load()
    Settings = {
        ["UI Scale"] = 1.5,
        ["Sound Volume"] = 75,
        ["Music Volume"] = 75
    }
    if love.filesystem.getInfo("settings.json") then
        Settings = json.decode(love.filesystem.read("settings.json"))
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