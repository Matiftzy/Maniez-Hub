local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local TargetPosition = Vector3.new(-50.033226013183594, 133.59967041015625, -2882.60107421875)

-- Pastikan hanya user tertentu yang bisa menjalankan script
local player = Players.LocalPlayer
if player.Name ~= _G.Main then
    return -- Jika bukan user yang diizinkan, keluar
end

for _, child in pairs(workspace:GetDescendants()) do
    if child:IsA("Texture") or child:IsA("Decal") or child:IsA("Shirt") or child:IsA("Pants") then
        child:Destroy()
    end
end

workspace:FindFirstChild("Cutscenes"):Destroy()
workspace:FindFirstChild("Map"):Destroy()
workspace:FindFirstChild("Preload"):Destroy()
workspace:FindFirstChild("Sound"):Destroy()
workspace:FindFirstChild("Thrown"):Destroy()
workspace:FindFirstChild("Built"):Destroy()

-- Membuat part sesuai permintaan
local part = Instance.new("Part")
part.Size = Vector3.new(500, 1.2, 500)
part.Position = Vector3.new(-50, 130, -2880)
part.Anchored = true
part.Parent = game.Workspace

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:FindFirstChild("HumanoidRootPart")
local emoteButton = nil
local skillsTable = nil

local isActive = false
local currentAlt = nil
local m1Click = true
local canSkill = true

if game.PlaceId == 10449761463 then
    emoteButton = game:GetService("Players").LocalPlayer.PlayerGui.Emotes.ImageLabel.Spin
    skillsTable = {"One", "Two", "Three"} 
    cyborgButton = game:GetService("Players").LocalPlayer.PlayerGui.TopbarPlus.TopbarContainer.UnnamedIcon.DropdownContainer.DropdownFrame.Cyborg.IconButton

    if cyborgButton and cyborgButton:IsA("TextButton") then
        local callback = getconnections(cyborgButton.MouseButton1Click)
        for _, connection in ipairs(callback) do
            connection:Fire() -- Memicu semua callback event
        end
    end
end

-- Fungsi untuk mendapatkan HRP dari karakter pemain
local function getHRP(character)
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Fungsi untuk mendapatkan alt yang sedang hidup
local function getAliveAlt()
    for _, altName in ipairs(_G.Alts) do
        local altPlayer = Players:FindFirstChild(altName)
        if altPlayer and altPlayer.Character and getHRP(altPlayer.Character) and altPlayer.Character:FindFirstChild("Humanoid") and altPlayer.Character.Humanoid.Health > 0 then
            return altPlayer
        end
    end
    return nil
end

-- Fungsi untuk mengecek apakah ada pemain lain dengan HP < 20% dalam radius 10 studs
local function isNearbyPlayerLowHP()
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherHRP = getHRP(otherPlayer.Character)
            local otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")

            if otherHRP and otherHumanoid then
                local distance = (otherHRP.Position - hrp.Position).Magnitude
                if distance <= 10 and otherHumanoid.Health <= otherHumanoid.MaxHealth * 0.15 then
                    return true
                end
            end
        end
    end
    return false
end

local function checkPlayerHighlights()
    if not hrp then return end -- Pastikan HRP tersedia

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherHRP = getHRP(otherPlayer.Character)

            if otherHRP then
                local distance = (otherHRP.Position - hrp.Position).Magnitude

                -- Cek hanya jika dalam radius 6 studs
                if distance <= 6 then
                    for _, obj in ipairs(otherPlayer.Character:GetChildren()) do
                        if obj:IsA("Highlight") and obj.OutlineTransparency < 1 then
                            canSkill = false
                            print("canskill = false")
                            return
                        else
                            canSkill = true -- Asumsi awal bisa skill, baru dicek lebih lanjut
                            print("canskill = true")
                        end
                    end
                end
            end
        end
    end
end

-- GUI Frame
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player.PlayerGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local blackScreen = Instance.new("Frame")
blackScreen.Parent = ScreenGui
blackScreen.Size = UDim2.new(1, 0, 1, 0)
blackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -60, 0.5, -25) -- Pusatkan tombol di tengah layar
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20
ToggleButton.Text = "OFF"
ToggleButton.Font = Enum.Font.FredokaOne
ToggleButton.AutoButtonColor = true
ToggleButton.BorderSizePixel = 0
ToggleButton.Active = true

-- Tambahkan label teks di bawah tombol
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = ScreenGui
InfoLabel.Size = UDim2.new(0, 300, 0, 200)
InfoLabel.Position = UDim2.new(0.5, -150, 0.5, 40) -- Tepat di bawah tombol
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.TextSize = 16
InfoLabel.TextWrapped = true
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextScaled = true
InfoLabel.Text = "[MAIN] [Auto Farm Kills TSBG]\n\nPlease TURN ON to kills ALT's in Farming Base\n\nScript made by Maniez Hub, discord.gg/U3CVFrMPeT"

local killsInfoLabel = Instance.new("TextLabel")
killsInfoLabel.Parent = ScreenGui
killsInfoLabel.Size = UDim2.new(0, 300, 0, 100)
killsInfoLabel.Position = UDim2.new(0.5, -150, 0.2, 40) -- Tepat di bawah tombol
killsInfoLabel.BackgroundTransparency = 1
killsInfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
killsInfoLabel.TextSize = 16
killsInfoLabel.TextWrapped = true
killsInfoLabel.Font = Enum.Font.GothamBold
killsInfoLabel.TextScaled = true
killsInfoLabel.Text = "Total Kills: 0\n\nKills: 0"

-- UI Styling
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = ToggleButton
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = "Border"

-- Fungsi untuk mengikuti alt yang sedang aktif dan menyerang jika HP > 20%
local function followAlt()
    while isActive do
        checkPlayerHighlights()
        
        if not currentAlt or not currentAlt.Character or not getHRP(currentAlt.Character) or currentAlt.Character:FindFirstChild("Humanoid").Health <= 0 then
            -- Jika alt mati atau tidak valid, cari alt baru
            currentAlt = getAliveAlt()
        end

        if currentAlt and currentAlt.Character then
            local altHRP = getHRP(currentAlt.Character)
            local altHumanoid = currentAlt.Character:FindFirstChild("Humanoid")

            if hrp and altHRP and altHumanoid then
                -- Posisikan di belakang alt dengan jarak 3 studs
                hrp.CFrame = CFrame.new(-50.0336, 133.6, -2882.6) * CFrame.new(0, 0, 3)
                
                killsInfoLabel.Text = "Total Kills: " .. player.leaderstats["Total Kills"].Value .. "\n\nKills: " .. player.leaderstats["Kills"].Value

                -- Cek apakah ada pemain lain di sekitar dengan HP < 20%
                if isNearbyPlayerLowHP() then
                    m1Click = false
                else
                    m1Click = true
                end

                -- Hanya klik jika HP target > 20% dan m1Click true
                if altHumanoid.Health > altHumanoid.MaxHealth * 0.15 and m1Click then
                    -- Simulasi klik kiri mouse
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end

                if canSkill then
                    for _, key in ipairs(skillsTable) do
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                    end
                end
                
                if emoteButton then
                    if emoteButton.Visible == true then
                        local events = {
                            "MouseButton1Click",
                            "MouseButton1Down",
                            "MouseButton1Up",
                            "MouseButton2Click",
                            "MouseButton2Down",
                            "MouseButton2Up",
                            "Activated",
                            "SelectionGained",
                            "SelectionLost",
                            "TouchTap"
                        }
                    
                        for _, eventName in ipairs(events) do
                            local event = emoteButton[eventName]
                            if event then
                                for _, connection in ipairs(getconnections(event)) do
                                    connection.Function()
                                end
                            end
                        end
                    else
                        warn("Tombol tidak ditemukan!")
                    end
                end
            end
        end

        task.wait(0.05) -- Periksa setiap 0.05 detik
    end
end

-- Toggle Button
ToggleButton.MouseButton1Click:Connect(function()
    isActive = not isActive
    ToggleButton.Text = isActive and "ON" or "OFF"
    ToggleButton.BackgroundColor3 = isActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(35, 35, 35)

    if isActive then
        task.spawn(followAlt)
    end
end)

-- Menangani karakter yang di-reset
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    task.wait(0.5)
    hrp = getHRP(newCharacter)
end)

-- Fungsi untuk membuat tombol bisa di-drag
local dragging, dragInput, dragStart, startPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if isActive then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPosition)
    end
end)
