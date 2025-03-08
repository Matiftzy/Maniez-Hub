local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if player.Name == _G.Main then
    return
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

local character = player.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")

local function getHRP(character)
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local part = Instance.new("Part")
part.Size = Vector3.new(500, 1.2, 500)
part.Position = Vector3.new(-50, 130, -2880)
part.Anchored = true
part.Parent = game.Workspace

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player.PlayerGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local blackScreen = Instance.new("Frame")
blackScreen.Parent = ScreenGui
blackScreen.Size = UDim2.new(1, 0, 1, 0)
blackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackScreen.Visible = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -60, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20
ToggleButton.Text = "OFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = true
ToggleButton.BorderSizePixel = 0
ToggleButton.Active = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = ToggleButton
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = "Border"

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = ScreenGui
InfoLabel.Size = UDim2.new(0, 300, 0, 200)
InfoLabel.Position = UDim2.new(0.5, -150, 0.5, 40)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.TextSize = 16
InfoLabel.TextWrapped = true
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextScaled = true
InfoLabel.Text = "[ALT] [Auto Farm Kills TSBG]\n\nPlease TURN ON to set ALT's in Farming Base\n\nScript made by Maniez Hub, discord.gg/U3CVFrMPeT"

local isActive = false

local function teleportAndModifyPlayers()
    if isActive and hrp then
        hrp.CFrame = CFrame.new(-50.0336, 133.6, -2882.6)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                for _, part in ipairs(plr.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.05) do
        if isActive and hrp then
            teleportAndModifyPlayers()
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    isActive = not isActive
    ToggleButton.Text = isActive and "ON" or "OFF"
    ToggleButton.BackgroundColor3 = isActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(35, 35, 35)

    if isActive and hrp then
        hrp.CFrame = CFrame.new(-50.0336, 133.6, -2882.6)
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    task.wait(0.5)
    hrp = getHRP(newCharacter)

    if isActive and hrp then
        hrp.CFrame = CFrame.new(-50.0336, 133.6, -2882.6)
    end
end)

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
