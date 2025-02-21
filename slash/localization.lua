-- Localization module
Slash.Localization = {}

---@alias Language {text: {[string]: string}, name?: string, logo?: string}

local languages = {}
local currentLanguage = ""

---Localizes a key into the current language
---
---May return the key if the language does not contain an entry for that key
---@param key string
---@return string
function Slash.Localization.Localize(key)
    return (languages[currentLanguage] or {text = {}}).text[key] or key
end

---Sets the current language
---
---If the language does not exist, this function will do nothing
---@param language string
function Slash.Localization.SetLanguage(language)
    if Slash.Localization.HasLanguage(language) then
        currentLanguage = language
    end
end

---Checks if a language exists
---@param language string
---@return boolean
function Slash.Localization.HasLanguage(language)
    return languages[language] ~= nil
end

---Adds or expands a language
---@param language string
---@param data? Language
function Slash.Localization.AddLanguage(language, data)
    if type(data) ~= "table" then return end
    languages[language] = table.merge(languages[language] or {}, data or {})
end

function Slash.Localization.Clear()
    languages = {}
    currentLanguage = ""
end