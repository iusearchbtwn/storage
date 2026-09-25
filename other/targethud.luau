-- Settings for the Target HUD
getgenv().targethud = {
    enabled = false, -- Toggle HUD on/off
    maxDistance = 5, -- Maximum distance to detect targets
    defaultHealthColor = Color3.fromRGB(128, 0, 128), -- Default health bar color (purple)
    backgroundTransparency = 0.3, -- Transparency of the outer box
}

-- Target HUD Script (LocalScript)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

-- Create a ScreenGui to hold the HUD
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

-- Create the outer box (background)
local outerBox = Instance.new("Frame")
outerBox.Size = UDim2.new(0, 200, 0, 120) -- Increased height for equipped item
outerBox.Position = UDim2.new(0.5, -100, 0.8, -140) -- Centered horizontally
outerBox.BackgroundColor3 = Color3.fromRGB(22, 22, 31) -- Dark gray
outerBox.BackgroundTransparency = getgenv().targethud.backgroundTransparency -- Set transparency
outerBox.BorderColor3 = Color3.fromRGB(80, 80, 80) -- Border color
outerBox.BorderSizePixel = 1
outerBox.Parent = screenGui
outerBox.Visible = false -- Default hidden

-- Create the header area (blank top bar)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 20)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(50, 50, 65) -- Slightly lighter gray
header.BorderSizePixel = 0
header.Parent = outerBox

-- Create the player's display name label
local displayNameLabel = Instance.new("TextLabel")
displayNameLabel.Size = UDim2.new(1, -10, 0, 20)
displayNameLabel.Position = UDim2.new(0, 5, 0, 20) -- Below the header
displayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
displayNameLabel.BackgroundTransparency = 1
displayNameLabel.Font = Enum.Font.GothamBold
displayNameLabel.TextSize = 14
displayNameLabel.Text = ""
displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
displayNameLabel.Parent = outerBox

-- Create the equipped item label
local equippedItemLabel = Instance.new("TextLabel")
equippedItemLabel.Size = UDim2.new(1, -10, 0, 20)
equippedItemLabel.Position = UDim2.new(0, 5, 0, 40) -- Positioned below the display name
equippedItemLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- Slightly dimmed white
equippedItemLabel.BackgroundTransparency = 1
equippedItemLabel.Font = Enum.Font.Gotham
equippedItemLabel.TextSize = 12
equippedItemLabel.Text = "None"
equippedItemLabel.TextXAlignment = Enum.TextXAlignment.Left
equippedItemLabel.Parent = outerBox

-- Create the health bar background
local healthBarBackground = Instance.new("Frame")
healthBarBackground.Size = UDim2.new(0.9, 0, 0, 10) -- Slightly narrower for padding
healthBarBackground.Position = UDim2.new(0.05, 0, 0, 70) -- Below the equipped item
healthBarBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray background
healthBarBackground.BorderColor3 = Color3.fromRGB(80, 80, 80) -- Border color
healthBarBackground.BorderSizePixel = 1
healthBarBackground.Parent = outerBox

-- Create the health bar (foreground)
local healthBar = Instance.new("Frame")
healthBar.Size = UDim2.new(0.5, 0, 1, 0) -- Start at 50% health for testing
healthBar.Position = UDim2.new(0, 0, 0, 0)
healthBar.BackgroundColor3 = getgenv().targethud.defaultHealthColor -- Use configurable color
healthBar.BorderSizePixel = 0
healthBar.Parent = healthBarBackground

-- Create the health number label
local healthNumberLabel = Instance.new("TextLabel")
healthNumberLabel.Size = UDim2.new(1, 0, 1, 0) -- Fill the health bar background
healthNumberLabel.Position = UDim2.new(0, 0, 0, 0)
healthNumberLabel.BackgroundTransparency = 1
healthNumberLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
healthNumberLabel.Font = Enum.Font.Gotham
healthNumberLabel.TextSize = 12
healthNumberLabel.Text = "100%" -- Default value
healthNumberLabel.TextXAlignment = Enum.TextXAlignment.Center
healthNumberLabel.TextYAlignment = Enum.TextYAlignment.Center
healthNumberLabel.Parent = healthBarBackground

-- Create the player's avatar image
local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 40, 0, 40)
avatarImage.Position = UDim2.new(1, -45, 0, -20) -- Top-right corner of the HUD
avatarImage.BackgroundTransparency = 1
avatarImage.Image = "" -- Placeholder for now
avatarImage.Parent = outerBox

-- Update the HUD when hovering over a player
local function updateTargetHUD()
    if not getgenv().targethud.enabled then
        outerBox.Visible = false
        return
    end

    local targetPlayer = nil
    local targetCharacter = nil
    local targetHumanoid = nil

    -- Check if the mouse is hovering over a player
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local head = otherPlayer.Character.Head
            local distance = (mouse.Hit.p - head.Position).magnitude

            if distance < getgenv().targethud.maxDistance then -- Use configurable distance
                targetPlayer = otherPlayer
                targetCharacter = otherPlayer.Character
                targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
                break
            end
        end
    end

    if targetPlayer and targetHumanoid then
        -- Show the HUD and update display name
        outerBox.Visible = true
        displayNameLabel.Text = string.format("%s (%s)", targetPlayer.DisplayName, targetPlayer.Name)

        -- Update equipped item
        local equippedTool = targetPlayer.Character:FindFirstChildOfClass("Tool")
        if equippedTool then
            equippedItemLabel.Text = equippedTool.Name
        else
            equippedItemLabel.Text = "None"
        end

        -- Update health bar and health number
        local healthPercentage = math.clamp(targetHumanoid.Health / targetHumanoid.MaxHealth, 0, 1)
        healthBar.Size = UDim2.new(healthPercentage, 0, 1, 0)
        healthNumberLabel.Text = string.format("%d%%", math.floor(healthPercentage * 100))

        -- Update avatar image
        local avatarId = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. targetPlayer.UserId .. "&width=420&height=420&format=png"
        avatarImage.Image = avatarId
    else
        -- Hide the HUD if no player is being hovered over
        outerBox.Visible = false
    end
end

-- Connect the update function to a RenderStepped event for continuous updates
game:GetService("RunService").RenderStepped:Connect(updateTargetHUD)
