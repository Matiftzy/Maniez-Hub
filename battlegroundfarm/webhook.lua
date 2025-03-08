if not _G.WebhookURL then
  return
end

local player = game.Players.LocalPlayer

local leaderstats = player:FindFirstChild("leaderstats")
while not leaderstats do
    wait(1)
    leaderstats = player:FindFirstChild("leaderstats")
end

local playerGui = player:FindFirstChild("PlayerGui")
while not playerGui do
    wait(1)
    playerGui = player:FindFirstChild("PlayerGui")
end

local function getRankTitle()
    local titleButton = playerGui:FindFirstChild("Cosmetics")
        and playerGui.Cosmetics:FindFirstChild("Frame")
        and playerGui.Cosmetics.Frame:FindFirstChild("TitlesSF")
        and playerGui.Cosmetics.Frame.TitlesSF:FindFirstChild("TextButton")

    return titleButton and titleButton.Text or "Unknown"
end

local function sendToDiscord()
    local httpService = game:GetService("HttpService")

    local currentTotalKillsValue = leaderstats:FindFirstChild("Total Kills") and leaderstats["Total Kills"].Value or 0
    local currentKillsValue = leaderstats:FindFirstChild("Kills") and leaderstats.Kills.Value or 0
    local currentRankTitle = getRankTitle()

    local avatarURL = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"

    local data = {
        ["username"] = "Discohook",
        ["avatar_url"] = avatarURL,
        ["embeds"] = {{
            ["title"] = "**" .. player.Name .. "**",
            ["color"] = 0x7289DA,
            ["thumbnail"] = { ["url"] = avatarURL },
            ["fields"] = {
                {
                    ["name"] = "**Total Kills:**",
                    ["value"] = tostring(currentTotalKillsValue),
                    ["inline"] = false
                },
                {
                    ["name"] = "**Kills:**",
                    ["value"] = tostring(currentKillsValue),
                    ["inline"] = false
                },
                {
                    ["name"] = "**Title:**",
                    ["value"] = tostring(currentRankTitle),
                    ["inline"] = false
                }
            }
        }}
    }

    local jsonData = httpService:JSONEncode(data)

    request({
        Url = _G.WebhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = jsonData
    })
end

local function trackStatChanges()
    local killsStat = leaderstats:FindFirstChild("Kills")
    local totalKillsStat = leaderstats:FindFirstChild("Total Kills")

    if killsStat then
        killsStat:GetPropertyChangedSignal("Value"):Connect(function()
            print("Kills updated")
            sendToDiscord()
        end)
    end

    if totalKillsStat then
        totalKillsStat:GetPropertyChangedSignal("Value"):Connect(function()
            print("Total Kills updated")
            sendToDiscord()
        end)
    end
end

trackStatChanges()
