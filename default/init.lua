DefaultMod = Slash.Mod.New(...)

Trophy = Slash.Assets.GetImage("default:ui.cubetrophy") or Slash.Assets.Missing
SlashIcon = Slash.Assets.GetImage("default:ui.slash") or Slash.Assets.Missing
PauseIcon = Slash.Assets.GetImage("default:ui.pause") or Slash.Assets.Missing
BackIcon = Slash.Assets.GetImage("default:ui.back") or Slash.Assets.Missing
ForwardIcon = Slash.Assets.GetImage("default:ui.forward") or Slash.Assets.Missing
FastBackIcon = Slash.Assets.GetImage("default:ui.fastback") or Slash.Assets.Missing
FastForwardIcon = Slash.Assets.GetImage("default:ui.fastforward") or Slash.Assets.Missing

Credits = json.decode(DefaultMod:readFile("assets/default/text/credits.json"))

GlobalTime = 0

MenuBG = love.graphics.newImage("default/assets/default/images/ui/background.png")
MenuBG:setWrap("repeat", "repeat", "repeat")
MenuBGMesh = love.graphics.newMesh({
    {0,0,0,0},
    {4000,0,4000/MenuBG:getWidth(),0},
    {0,4000,0,4000/MenuBG:getHeight()},
    
    {0,4000,0,4000/MenuBG:getHeight()},
    {4000,0,4000/MenuBG:getWidth(),0},
    {4000,4000,4000/MenuBG:getWidth(),4000/MenuBG:getHeight()}
}, "triangles")
MenuBGMesh:setTexture(MenuBG)

smfont = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 12)

function ResetFonts()
    mdfont = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 16*FontScale*Settings.video.ui_scale/1.5)
    lgfont = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 24*FontScale*Settings.video.ui_scale/1.5)
    lrfont = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 32*FontScale*Settings.video.ui_scale/1.5)
    xlfont = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 48*FontScale*Settings.video.ui_scale/1.5)
end

smfont_1x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 12)
mdfont_1x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 16)
lgfont_1x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 24)
lrfont_1x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 32)
xlfont_1x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 48)

smfont_2x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 12*2)
mdfont_2x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 16*2)
lgfont_2x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 24*2)
lrfont_2x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 32*2)
xlfont_2x = love.graphics.newFont("default/assets/default/fonts/NotoSansJP-Regular.ttf", 48*2)

function LoadMusic(fn)
    local source = Slash.Assets.GetAudio(fn)
    if not source then
        return Slash.Log.Warn("Could not play music with ID '" .. fn .. "'")
    end
    Music = source
    CurrentMusic = fn
    Music:setLooping(true)
    Music:setVolume(Settings.audio.music_volume/100)
    Music:play()
    -- local s,r = pcall(love.audio.newSource, fn, "stream")
    -- if not s then
    --     return print("WARNING: Music " .. fn .. " not found; skipping")
    -- end
    -- Music = r
    -- CurrentMusic = fn
    -- Music:setLooping(true)
    -- Music:setVolume(Settings.audio.music_volume/100)
    -- Music:play()
end

function StopMusic()
    if Music then
        Music:stop()
    end
end