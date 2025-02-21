local _print = print

local logPath = ""
do
    local currentDate = os.date("*t")
    local year = tostring(currentDate.year)
    year = ("0"):rep(4 - #year) .. year
    local month = tostring(currentDate.month)
    month = ("0"):rep(2 - #month) .. month
    local day = tostring(currentDate.day)
    day = ("0"):rep(2 - #day) .. day
    local hour = tostring(currentDate.hour)
    hour = ("0"):rep(2 - #hour) .. hour
    local minute = tostring(currentDate.min)
    minute = ("0"):rep(2 - #minute) .. minute
    local second = tostring(currentDate.sec)
    second = ("0"):rep(2 - #second) .. second
    logPath = year.."-"..month.."-"..day .. "_" .. hour.."-"..minute.."-"..second .. ".log"
end

Slash.Log = {}

Slash.LogLevel = {
    INFO = {text = "INFO", color = "97"},
    WARN = {text = "WARN", color = "93"},
    ERROR = {text = "ERROR", color = "91"},
    FATAL = {text = "FATAL", color = "31"}
}

local log = {}

local function time()
    local d = os.date("*t")
    local hr = tostring(d.hour)
    hr = ("0"):rep(2-#hr) .. hr
    local mn = tostring(d.min)
    mn = ("0"):rep(2-#mn) .. mn
    local sc = tostring(d.sec)
    sc = ("0"):rep(2-#sc) .. sc
    return hr .. ":" .. mn .. ":" .. sc
end

function Slash.Log.Log(level, ...)
    local num = select("#", ...)
    local t = {...}
    local txt = "[" .. time() .. " | " .. level.text:upper() .. "] "
    for i = 1, num do
        txt = txt .. tostring(t[i])
        if i ~= num then
            txt = txt .. "\t"
        end
    end
    _print("\x1b[" .. level.color .. "m" .. txt .. "\x1b[0m")
    table.insert(log, txt)
end

function Slash.Log.Info(...)
    Slash.Log.Log(Slash.LogLevel.INFO, ...)
end

function Slash.Log.Warn(...)
    Slash.Log.Log(Slash.LogLevel.WARN, ...)
end

function Slash.Log.Error(...)
    Slash.Log.Log(Slash.LogLevel.ERROR, ...)
end

function Slash.Log.Fatal(...)
    Slash.Log.Log(Slash.LogLevel.FATAL, ...)
end

function Slash.Log.Flush()
    local txt = table.concat(log, "\n")
    love.filesystem.createDirectory("logs")
    love.filesystem.write("logs/"..logPath, txt)
    love.filesystem.write("latest.log", txt)
end

print = Slash.Log.Info