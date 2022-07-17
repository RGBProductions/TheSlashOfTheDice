require "scenemanager"

-- json = require "json"
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

function love.load()
    Settings = {
        ["UI Scale"] = 1.5
    }
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