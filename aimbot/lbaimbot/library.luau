--[[
credits to iusearchbtwn - specially for konata.fun
dsc.gg/konata
]]

local lbaimbot = {}
local LbStorage = {}

getgenv().Lb = getgenv().Lb or {}

local Settings = {
    AimPart = "Head",
    Bind = Enum.UserInputType.MouseButton2,
    TeamCheck = true,
    WallCheck = true,
    Smoothing = 0.15,
    FovVisible = true,
    FovRadius = 120,
    ChamsTeamCheck = true
}

setmetatable(getgenv().Lb, {
    __index = function(_, key) return LbStorage[key] end,
    __newindex = function(_, key, value) LbStorage[key] = value end
})

Lb.Aimbot = false
Lb.Chams = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Holding = false
local ChamsFolder = CoreGui:FindFirstChild("Chams_Storage") or Instance.new("Folder", CoreGui)
ChamsFolder.Name = "Chams_Storage"

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)

local function IsVisible(targetPart, character)
    if not Settings.WallCheck then return true end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local raycastResult = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, raycastParams)
    return not raycastResult
end

local function GetClosestPlayer()
    local MaximumDistance = Settings.FovRadius
    local Target = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local aimPart = character:FindFirstChild(Settings.AimPart)
            if humanoid and humanoid.Health > 0 and aimPart and IsVisible(aimPart, character) then
                local screenPosition, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if distance < MaximumDistance then
                        MaximumDistance = distance
                        Target = aimPart
                    end
                end
            end
        end
    end
    return Target
end

function lbaimbot.Init(customSettings)
    if customSettings then
        for k, v in pairs(customSettings) do Settings[k] = v end
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Settings.Bind or input.KeyCode == Settings.Bind then Holding = true end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Settings.Bind or input.KeyCode == Settings.Bind then Holding = false end
    end)

    local function ApplyChams(player)
        if player == LocalPlayer then return end
        local function CharacterAdded(character)
            character:WaitForChild("HumanoidRootPart", 5)
            local existing = ChamsFolder:FindFirstChild(player.Name)
            if existing then existing:Destroy() end
            local highlight = Instance.new("Highlight")
            highlight.Name = player.Name
            highlight.Adornee = character
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillOpacity = 0.5
            highlight.OutlineOpacity = 0.2
            highlight.Enabled = Lb.Chams
            highlight.Parent = ChamsFolder
        end
        if player.Character then task.spawn(CharacterAdded, player.Character) end
        player.CharacterAdded:Connect(CharacterAdded)
    end

    for _, p in ipairs(Players:GetPlayers()) do ApplyChams(p) end
    Players.PlayerAdded:Connect(ApplyChams)

    RunService.RenderStepped:Connect(function()
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Settings.FovRadius
        FOVCircle.Visible = Settings.FovVisible and Lb.Aimbot
        
        for _, highlight in ipairs(ChamsFolder:GetChildren()) do
            local p = Players:FindFirstChild(highlight.Name)
            if p then
                highlight.Enabled = Lb.Chams
                highlight.FillColor = (Settings.ChamsTeamCheck and p.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end

        if not Lb.Aimbot then return end
        
        if Holding then
            local target = GetClosestPlayer()
            if target then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                local tweenInfo = TweenInfo.new(Settings.Smoothing, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                TweenService:Create(Camera, tweenInfo, {CFrame = targetCFrame}):Play()
            end
        end
    end)
    
    return getgenv().Lb
end

return lbaimbot
