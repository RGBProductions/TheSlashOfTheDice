Languages = {}

for _,lang in ipairs(love.filesystem.getDirectoryItems("assets/lang")) do
    local s,r = pcall(json.decode, love.filesystem.read("assets/lang/"..lang))
    if s then
        local name = lang:sub(1,-6)
        Languages[name] = r
        print(name)
    end
end

function Localize(text)
    local lang = Settings["Language"] or "en_US"
    return ((Languages[lang] or {}).text or {})[text] or text
end

function GetTextDelay()
    local lang = Settings["Language"] or "en_US"
    return (Languages[lang] or {}).textDelay or (1/40)
end