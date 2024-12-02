Languages = {}

LanguageFallbacks = {}

for _,lang in ipairs(love.filesystem.getDirectoryItems("assets/lang")) do
    local s,r = pcall(json.decode, love.filesystem.read("assets/lang/"..lang))
    if s then
        local name = lang:sub(1,-6)
        Languages[name] = r
        if r.fallback then
            LanguageFallbacks[name:sub(1,2)] = name
        end
    end
end

function Localize(text)
    local lang = Settings.language or "en_US"
    return ((Languages[lang] or {}).text or {})[text] or text
end

function GetTextDelay()
    local lang = Settings.language or "en_US"
    return (Languages[lang] or {}).textDelay or (1/40)
end

function GetLanguageName(lang)
    lang = lang or (Settings.language or "en_US")
    return (Languages[lang] or {}).name or lang
end