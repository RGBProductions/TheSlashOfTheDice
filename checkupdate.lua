function split(text, delimiter)
    local result = {}
    for match in (text..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function split_plain(text, delimiter)
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

function CompareVersions(a,b)
    local t1 = split_plain(a, ".")
    local t2 = split_plain(b, ".")
    for i,v in ipairs(t1) do
        t1[i] = split_plain(v, "-")[1]
    end
    for i,v in ipairs(t2) do
        t2[i] = split_plain(v, "-")[1]
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

function check()
    local https
    local s,r = pcall(require, "https")
    if not s then
        print("Failed to load HTTPS module, ignoring")
        return false
    else
        https = r
    end

    local curver = split(love.filesystem.read("version.txt"), "\n")
    local version = curver[1]
    local version_number = curver[2]
    local update = {false, version}
    local beta = false

    local versionUrl = "https://raw.githubusercontent.com/RGBProductions/TheSlashOfTheDice/main/version.txt"
    local code,data,headers = https.request(versionUrl, {method = "get"})
    if code ~= 200 then return false end
    local lines = split(data, "\n")
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

    return true,beta,update
end

local channel = love.thread.getChannel("update")
channel:push({check()})