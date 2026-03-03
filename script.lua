--[[
    Rivals All-in-One Script
    Features: GUI, Aimbot, Silent Aim, ESP, Fly, Speed, Noclip, Weapon Mods
    Silent Aim: Hooks __index (Mouse.Hit/Target) + __namecall (Raycast/FindPart)
    GUI: Draggable frame with tabs and toggle buttons
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- =============================================
-- SETTINGS
-- =============================================
local Settings = {
    Aimbot = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2,
        TeamCheck = true,
        FOV = 300,
        ShowFOV = true,
        Smoothness = 5,
        AimPart = "Head",
        WallCheck = true,
        Prediction = 0.12,
    },
    SilentAim = {
        Enabled = false,
        HitChance = 100,
        AimPart = "Head",
        FOV = 250,
        ShowFOV = true,
        Method = "Raycast", -- Raycast, Mouse, Both
    },
    ESP = {
        Enabled = true,
        TeamCheck = true,
        Boxes = true,
        BoxColor = Color3.fromRGB(255, 50, 50),
        TeamBoxColor = Color3.fromRGB(50, 255, 50),
        Names = true,
        NameColor = Color3.fromRGB(255, 255, 255),
        Health = true,
        Distance = true,
        Tracers = false,
        TracerOrigin = "Bottom",
        Chams = false,
        ChamsColor = Color3.fromRGB(255, 0, 255),
    },
    Fly = {
        Enabled = false,
        Speed = 80,
    },
    Movement = {
        Speed = false,
        SpeedValue = 32,
        InfiniteJump = false,
        Noclip = false,
    },
    Weapon = {
        NoRecoil = true,
        NoSpread = true,
        RapidFire = false,
        InfiniteAmmo = true,
    },
    Misc = {
        FullBright = false,
        NoFog = false,
    },
}

-- =============================================
-- VARIABLES
-- =============================================
local Aiming = false
local Flying = false
local FlyBody, FlyGyro = nil, nil
local NoclipActive = false
local SpeedActive = false
local InfJumpActive = false
local ESPObjects = {}
local SilentAimTarget = nil

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================
local function IsAlive(player)
    local char = player and player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return char:FindFirstChild("HumanoidRootPart") ~= nil
end

local function IsTeammate(player)
    if not Settings.Aimbot.TeamCheck and not Settings.ESP.TeamCheck then return false end
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    return false
end

local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = Workspace:Raycast(origin, direction, rayParams)
    if result then
        return result.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

local function GetClosestPlayer(fov, aimPart, teamCheck)
    local closest, shortestDist = nil, fov
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            if not (teamCheck and IsTeammate(player)) then
                local char = player.Character
                local part = char:FindFirstChild(aimPart) or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if dist < shortestDist and IsVisible(part) then
                            closest = player
                            shortestDist = dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- =============================================
-- GUI LIBRARY
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Try to parent to CoreGui, fallback to PlayerGui
local guiParent = (syn and syn.protect_gui and ScreenGui) or ScreenGui
pcall(function() guiParent.Parent = game:GetService("CoreGui") end)
if not guiParent.Parent then
    guiParent.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Colors
local Colors = {
    Background = Color3.fromRGB(20, 20, 30),
    TopBar = Color3.fromRGB(30, 30, 45),
    TabBar = Color3.fromRGB(25, 25, 38),
    TabActive = Color3.fromRGB(100, 60, 255),
    TabInactive = Color3.fromRGB(50, 50, 70),
    ToggleOn = Color3.fromRGB(100, 60, 255),
    ToggleOff = Color3.fromRGB(60, 60, 80),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(140, 140, 160),
    Section = Color3.fromRGB(28, 28, 42),
    Border = Color3.fromRGB(45, 45, 65),
    Accent = Color3.fromRGB(100, 60, 255),
    SliderBg = Color3.fromRGB(40, 40, 60),
    SliderFill = Color3.fromRGB(100, 60, 255),
}

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Border
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Colors.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

-- Fix bottom corners of topbar
local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Colors.TopBar
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Text = "  RIVALS"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Colors.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Text = "v2.0  "
VersionLabel.Size = UDim2.new(0, 60, 1, 0)
VersionLabel.Position = UDim2.new(1, -60, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.TextColor3 = Colors.TextDim
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 12
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
VersionLabel.Parent = TopBar

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -95, 0, 3)
MinBtn.BackgroundColor3 = Colors.TabInactive
MinBtn.TextColor3 = Colors.Text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    local targetSize = Minimized and UDim2.new(0, 520, 0, 36) or UDim2.new(0, 520, 0, 420)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
    MinBtn.Text = Minimized and "+" or "-"
end)

-- Dragging
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.Position = UDim2.new(0, 0, 0, 36)
TabBar.BackgroundColor3 = Colors.TabBar
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

-- Content area
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -16, 1, -76)
ContentFrame.Position = UDim2.new(0, 8, 0, 72)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

local Tabs = {}
local TabButtons = {}
local TabPages = {}
local ActiveTab = nil

local tabNames = {"Aimbot", "Silent Aim", "ESP", "Movement", "Weapon", "Misc"}

-- Create tab pages
for i, name in ipairs(tabNames) do
    -- Tab Button
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = name
    btn.Size = UDim2.new(1 / #tabNames, 0, 1, 0)
    btn.BackgroundColor3 = Colors.TabInactive
    btn.TextColor3 = Colors.TextDim
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.LayoutOrder = i
    btn.Parent = TabBar
    TabButtons[name] = btn

    -- Page ScrollFrame
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Colors.Accent
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = ContentFrame

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 4)
    pagePadding.PaddingBottom = UDim.new(0, 4)
    pagePadding.Parent = page

    TabPages[name] = page
end

local function SwitchTab(name)
    if ActiveTab == name then return end
    ActiveTab = name
    for n, btn in pairs(TabButtons) do
        if n == name then
            btn.BackgroundColor3 = Colors.TabActive
            btn.TextColor3 = Colors.Text
        else
            btn.BackgroundColor3 = Colors.TabInactive
            btn.TextColor3 = Colors.TextDim
        end
    end
    for n, page in pairs(TabPages) do
        page.Visible = (n == name)
    end
end

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

-- UI Element Builders
local function CreateToggle(parent, label, default, order, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = Colors.Section
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Text = "  " .. label
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Colors.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBg.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = container
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Colors.ToggleKnob
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    local btn = Instance.new("TextButton")
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Parent = container

    btn.MouseButton1Click:Connect(function()
        state = not state
        local knobPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local bgColor = state and Colors.ToggleOn or Colors.ToggleOff
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = knobPos}):Play()
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = bgColor}):Play()
        callback(state)
    end)

    return container
end

local function CreateSlider(parent, label, min, max, default, order, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = Colors.Section
    container.BorderSizePixel = 0
    container.LayoutOrder = order
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Text = "  " .. label
    lbl.Size = UDim2.new(0.5, 0, 0, 22)
    lbl.Position = UDim2.new(0, 0, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Colors.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local valLabel = Instance.new("TextLabel")
    valLabel.Text = tostring(default)
    valLabel.Size = UDim2.new(0.5, -10, 0, 22)
    valLabel.Position = UDim2.new(0.5, 0, 0, 2)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = Colors.Accent
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 13
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 8)
    sliderBg.Position = UDim2.new(0, 10, 0, 32)
    sliderBg.BackgroundColor3 = Colors.SliderBg
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.SliderFill
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Text = ""
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Parent = sliderBg

    local sliding = false
    sliderBtn.MouseButton1Down:Connect(function() sliding = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local absPos = sliderBg.AbsolutePosition.X
            local absSize = sliderBg.AbsoluteSize.X
            local rel = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
            local value = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(value)
            callback(value)
        end
    end)
end

local function CreateSectionLabel(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Text = "  " .. text
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Colors.Accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = parent
end

-- =============================================
-- BUILD GUI TABS
-- =============================================

-- === AIMBOT TAB ===
local aimPage = TabPages["Aimbot"]
CreateSectionLabel(aimPage, "AIMBOT SETTINGS", 1)
CreateToggle(aimPage, "Enable Aimbot", Settings.Aimbot.Enabled, 2, function(v) Settings.Aimbot.Enabled = v end)
CreateToggle(aimPage, "Team Check", Settings.Aimbot.TeamCheck, 3, function(v) Settings.Aimbot.TeamCheck = v end)
CreateToggle(aimPage, "Show FOV Circle", Settings.Aimbot.ShowFOV, 4, function(v) Settings.Aimbot.ShowFOV = v end)
CreateToggle(aimPage, "Wall Check", Settings.Aimbot.WallCheck, 5, function(v) Settings.Aimbot.WallCheck = v end)
CreateSlider(aimPage, "FOV Radius", 50, 600, Settings.Aimbot.FOV, 6, function(v) Settings.Aimbot.FOV = v end)
CreateSlider(aimPage, "Smoothness", 1, 20, Settings.Aimbot.Smoothness, 7, function(v) Settings.Aimbot.Smoothness = v end)
CreateSlider(aimPage, "Prediction", 0, 30, math.floor(Settings.Aimbot.Prediction * 100), 8, function(v) Settings.Aimbot.Prediction = v / 100 end)

-- === SILENT AIM TAB ===
local silentPage = TabPages["Silent Aim"]
CreateSectionLabel(silentPage, "SILENT AIM SETTINGS", 1)
CreateToggle(silentPage, "Enable Silent Aim", Settings.SilentAim.Enabled, 2, function(v) Settings.SilentAim.Enabled = v end)
CreateToggle(silentPage, "Show FOV Circle", Settings.SilentAim.ShowFOV, 3, function(v) Settings.SilentAim.ShowFOV = v end)
CreateSlider(silentPage, "FOV Radius", 50, 500, Settings.SilentAim.FOV, 4, function(v) Settings.SilentAim.FOV = v end)
CreateSlider(silentPage, "Hit Chance (%)", 1, 100, Settings.SilentAim.HitChance, 5, function(v) Settings.SilentAim.HitChance = v end)

CreateSectionLabel(silentPage, "HOW IT WORKS", 6)
local infoLabel = Instance.new("TextLabel")
infoLabel.Text = "  Silent Aim hooks raycasts & mouse properties.\n  Your crosshair doesn't move but bullets hit the\n  closest enemy. Works with all Rivals weapons.\n  Hooks: __index (Mouse.Hit/Target/UnitRay)\n  + __namecall (Raycast/FindPartOnRay)"
infoLabel.Size = UDim2.new(1, 0, 0, 72)
infoLabel.BackgroundColor3 = Colors.Section
infoLabel.TextColor3 = Colors.TextDim
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 11
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.LayoutOrder = 7
infoLabel.BorderSizePixel = 0
infoLabel.Parent = silentPage
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 6)

-- === ESP TAB ===
local espPage = TabPages["ESP"]
CreateSectionLabel(espPage, "ESP SETTINGS", 1)
CreateToggle(espPage, "Enable ESP", Settings.ESP.Enabled, 2, function(v) Settings.ESP.Enabled = v end)
CreateToggle(espPage, "Team Check", Settings.ESP.TeamCheck, 3, function(v) Settings.ESP.TeamCheck = v end)
CreateToggle(espPage, "Boxes", Settings.ESP.Boxes, 4, function(v) Settings.ESP.Boxes = v end)
CreateToggle(espPage, "Names", Settings.ESP.Names, 5, function(v) Settings.ESP.Names = v end)
CreateToggle(espPage, "Health Bars", Settings.ESP.Health, 6, function(v) Settings.ESP.Health = v end)
CreateToggle(espPage, "Distance", Settings.ESP.Distance, 7, function(v) Settings.ESP.Distance = v end)
CreateToggle(espPage, "Tracers", Settings.ESP.Tracers, 8, function(v) Settings.ESP.Tracers = v end)
CreateToggle(espPage, "Chams (Highlight)", Settings.ESP.Chams, 9, function(v)
    Settings.ESP.Chams = v
    for _, player in pairs(Players:GetPlayers()) do
        if v then ApplyChams(player) else RemoveChams(player) end
    end
end)

-- === MOVEMENT TAB ===
local movePage = TabPages["Movement"]
CreateSectionLabel(movePage, "FLY", 1)
CreateToggle(movePage, "Enable Fly [F]", Settings.Fly.Enabled, 2, function(v)
    Settings.Fly.Enabled = v
    if v then StartFly() else StopFly() end
end)
CreateSlider(movePage, "Fly Speed", 10, 300, Settings.Fly.Speed, 3, function(v) Settings.Fly.Speed = v end)

CreateSectionLabel(movePage, "MOVEMENT", 4)
CreateToggle(movePage, "Speed Hack [X]", Settings.Movement.Speed, 5, function(v)
    Settings.Movement.Speed = v
    SpeedActive = v
    if not v and IsAlive(LocalPlayer) then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)
CreateSlider(movePage, "Walk Speed", 16, 200, Settings.Movement.SpeedValue, 6, function(v) Settings.Movement.SpeedValue = v end)
CreateToggle(movePage, "Infinite Jump [J]", Settings.Movement.InfiniteJump, 7, function(v)
    Settings.Movement.InfiniteJump = v
    InfJumpActive = v
end)
CreateToggle(movePage, "Noclip [V]", Settings.Movement.Noclip, 8, function(v)
    Settings.Movement.Noclip = v
    NoclipActive = v
end)

-- === WEAPON TAB ===
local weaponPage = TabPages["Weapon"]
CreateSectionLabel(weaponPage, "WEAPON MODS", 1)
CreateToggle(weaponPage, "No Recoil", Settings.Weapon.NoRecoil, 2, function(v) Settings.Weapon.NoRecoil = v end)
CreateToggle(weaponPage, "No Spread", Settings.Weapon.NoSpread, 3, function(v) Settings.Weapon.NoSpread = v end)
CreateToggle(weaponPage, "Rapid Fire", Settings.Weapon.RapidFire, 4, function(v) Settings.Weapon.RapidFire = v end)
CreateToggle(weaponPage, "Infinite Ammo", Settings.Weapon.InfiniteAmmo, 5, function(v) Settings.Weapon.InfiniteAmmo = v end)

-- === MISC TAB ===
local miscPage = TabPages["Misc"]
CreateSectionLabel(miscPage, "VISUALS", 1)
CreateToggle(miscPage, "Fullbright", Settings.Misc.FullBright, 2, function(v)
    Settings.Misc.FullBright = v
    if v then ApplyFullbright() end
end)
CreateToggle(miscPage, "No Fog", Settings.Misc.NoFog, 3, function(v)
    Settings.Misc.NoFog = v
    if v then ApplyNoFog() end
end)

CreateSectionLabel(miscPage, "KEYBINDS", 4)
local keybindInfo = Instance.new("TextLabel")
keybindInfo.Text = "  RMB (Hold) = Aimbot\n  F = Toggle Fly\n  V = Toggle Noclip\n  X = Toggle Speed\n  J = Toggle Infinite Jump\n  Right Shift = Toggle GUI"
keybindInfo.Size = UDim2.new(1, 0, 0, 90)
keybindInfo.BackgroundColor3 = Colors.Section
keybindInfo.TextColor3 = Colors.TextDim
keybindInfo.Font = Enum.Font.Gotham
keybindInfo.TextSize = 12
keybindInfo.TextWrapped = true
keybindInfo.TextXAlignment = Enum.TextXAlignment.Left
keybindInfo.TextYAlignment = Enum.TextYAlignment.Top
keybindInfo.LayoutOrder = 5
keybindInfo.BorderSizePixel = 0
keybindInfo.Parent = miscPage
Instance.new("UICorner", keybindInfo).CornerRadius = UDim.new(0, 6)

-- Set default tab
SwitchTab("Aimbot")

-- Toggle GUI visibility with Right Shift
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- =============================================
-- FOV CIRCLES (Drawing API)
-- =============================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false

local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Thickness = 1
SilentFOVCircle.NumSides = 64
SilentFOVCircle.Filled = false
SilentFOVCircle.Transparency = 0.7
SilentFOVCircle.Color = Color3.fromRGB(0, 255, 255)
SilentFOVCircle.Visible = false

-- =============================================
-- AIMBOT LOGIC
-- =============================================
local function UpdateAimbot()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled

    if not Settings.Aimbot.Enabled or not Aiming or not IsAlive(LocalPlayer) then return end

    local target = GetClosestPlayer(Settings.Aimbot.FOV, Settings.Aimbot.AimPart, Settings.Aimbot.TeamCheck)
    if target then
        local char = target.Character
        local part = char:FindFirstChild(Settings.Aimbot.AimPart) or char:FindFirstChild("HumanoidRootPart")
        if part then
            local predictedPos = part.Position
            if Settings.Aimbot.Prediction > 0 then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    predictedPos = predictedPos + (root.AssemblyLinearVelocity * Settings.Aimbot.Prediction)
                end
            end
            local s = Settings.Aimbot.Smoothness
            local current = Camera.CFrame
            local target_cf = CFrame.lookAt(current.Position, predictedPos)
            Camera.CFrame = (s <= 1) and target_cf or current:Lerp(target_cf, 1 / s)
        end
    end
end

-- =============================================
-- SILENT AIM - Multi-method hook
-- Hooks __index for Mouse.Hit/Target/UnitRay
-- Hooks __namecall for Raycast and FindPartOnRay
-- This is how Rivals hit registration works:
--   Client fires ray from camera -> checks what it hits -> sends hit data to server
--   By spoofing the ray origin/direction AND mouse properties,
--   bullets silently redirect to the nearest enemy
-- =============================================
local function GetSilentAimTarget()
    if not Settings.SilentAim.Enabled then return nil end
    if math.random(1, 100) > Settings.SilentAim.HitChance then return nil end

    local target = GetClosestPlayer(Settings.SilentAim.FOV, Settings.SilentAim.AimPart, true)
    if target and target.Character then
        local part = target.Character:FindFirstChild(Settings.SilentAim.AimPart)
            or target.Character:FindFirstChild("HumanoidRootPart")
        return part
    end
    return nil
end

-- Update silent aim target every frame
RunService.RenderStepped:Connect(function()
    SilentAimTarget = GetSilentAimTarget()
end)

-- Hook __index: spoofs Mouse.Hit, Mouse.Target, Mouse.UnitRay
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not Settings.SilentAim.Enabled then return oldIndex(self, key) end

    if self == Mouse then
        if SilentAimTarget then
            if key == "Hit" then
                return CFrame.new(SilentAimTarget.Position)
            elseif key == "Target" then
                return SilentAimTarget
            elseif key == "UnitRay" then
                local origin = Camera.CFrame.Position
                local direction = (SilentAimTarget.Position - origin).Unit
                return Ray.new(origin, direction)
            end
        end
    end

    return oldIndex(self, key)
end))

-- Hook __namecall: intercepts Raycast and FindPartOnRay calls
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Settings.SilentAim.Enabled and SilentAimTarget then
        -- Hook Workspace:Raycast() - used by modern Roblox shooters including Rivals
        if self == Workspace and method == "Raycast" then
            local origin = args[1]
            if typeof(origin) == "Vector3" then
                local newDir = (SilentAimTarget.Position - origin).Unit * 1000
                args[2] = newDir
                return oldNamecall(self, unpack(args))
            end
        end

        -- Hook FindPartOnRay (legacy ray method, some guns still use it)
        if self == Workspace and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
            local ray = args[1]
            if typeof(ray) == "Ray" then
                local origin = ray.Origin
                local newDir = (SilentAimTarget.Position - origin).Unit * 1000
                args[1] = Ray.new(origin, newDir)
                return oldNamecall(self, unpack(args))
            end
        end

        -- Hook remote events for hit registration (FireServer / InvokeServer)
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = string.lower(self.Name)
            if string.find(remoteName, "shoot") or string.find(remoteName, "fire")
               or string.find(remoteName, "hit") or string.find(remoteName, "bullet")
               or string.find(remoteName, "weapon") or string.find(remoteName, "damage")
               or string.find(remoteName, "ray") or string.find(remoteName, "replicate")
               or string.find(remoteName, "input") or string.find(remoteName, "mouse") then
                for i, v in pairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = SilentAimTarget.Position
                    elseif typeof(v) == "CFrame" then
                        args[i] = CFrame.lookAt(Camera.CFrame.Position, SilentAimTarget.Position)
                    elseif typeof(v) == "Ray" then
                        local origin = v.Origin
                        args[i] = Ray.new(origin, (SilentAimTarget.Position - origin).Unit * 1000)
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end
    end

    return oldNamecall(self, unpack(args))
end))

-- =============================================
-- ESP
-- =============================================
local function CreateESP(player)
    if player == LocalPlayer then return end
    local esp = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthOutline = Drawing.new("Square"),
        HealthFill = Drawing.new("Square"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
    }

    esp.Box.Thickness = 1; esp.Box.Filled = false; esp.Box.Visible = false
    esp.BoxOutline.Thickness = 3; esp.BoxOutline.Filled = false; esp.BoxOutline.Color = Color3.new(0,0,0); esp.BoxOutline.Visible = false
    esp.Name.Size = 14; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Font = Drawing.Fonts.Plex; esp.Name.Visible = false
    esp.HealthOutline.Thickness = 1; esp.HealthOutline.Filled = true; esp.HealthOutline.Color = Color3.new(0,0,0); esp.HealthOutline.Visible = false
    esp.HealthFill.Thickness = 1; esp.HealthFill.Filled = true; esp.HealthFill.Visible = false
    esp.Distance.Size = 12; esp.Distance.Center = true; esp.Distance.Outline = true; esp.Distance.Font = Drawing.Fonts.Plex; esp.Distance.Color = Color3.fromRGB(200,200,200); esp.Distance.Visible = false
    esp.Tracer.Thickness = 1; esp.Tracer.Visible = false

    ESPObjects[player] = esp
end

local function UpdateESP(player)
    local esp = ESPObjects[player]
    if not esp then return end

    if not Settings.ESP.Enabled or not IsAlive(player) or (Settings.ESP.TeamCheck and IsTeammate(player)) then
        for _, obj in pairs(esp) do obj.Visible = false end
        return
    end

    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then
        for _, obj in pairs(esp) do obj.Visible = false end
        return
    end

    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then
        for _, obj in pairs(esp) do obj.Visible = false end
        return
    end

    local headPos = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, 3, 0)).Position)
    local legPos = Camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -3, 0)).Position)
    local boxHeight = math.abs(headPos.Y - legPos.Y)
    local boxWidth = boxHeight * 0.55
    local boxColor = IsTeammate(player) and Settings.ESP.TeamBoxColor or Settings.ESP.BoxColor

    if Settings.ESP.Boxes then
        esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
        esp.BoxOutline.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)
        esp.BoxOutline.Visible = true
        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
        esp.Box.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)
        esp.Box.Color = boxColor
        esp.Box.Visible = true
    else
        esp.Box.Visible = false; esp.BoxOutline.Visible = false
    end

    if Settings.ESP.Names then
        esp.Name.Text = player.DisplayName
        esp.Name.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight/2 - 18)
        esp.Name.Color = Settings.ESP.NameColor
        esp.Name.Visible = true
    else
        esp.Name.Visible = false
    end

    if Settings.ESP.Health then
        local hf = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local bh, bw = boxHeight, 3
        local bx = rootPos.X - boxWidth/2 - 6
        esp.HealthOutline.Size = Vector2.new(bw+2, bh+2)
        esp.HealthOutline.Position = Vector2.new(bx-1, rootPos.Y - boxHeight/2 - 1)
        esp.HealthOutline.Visible = true
        local fh = bh * hf
        esp.HealthFill.Size = Vector2.new(bw, fh)
        esp.HealthFill.Position = Vector2.new(bx, rootPos.Y - boxHeight/2 + (bh - fh))
        esp.HealthFill.Color = Color3.fromRGB(255*(1-hf), 255*hf, 0)
        esp.HealthFill.Visible = true
    else
        esp.HealthOutline.Visible = false; esp.HealthFill.Visible = false
    end

    if Settings.ESP.Distance then
        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        esp.Distance.Text = string.format("[%d studs]", dist)
        esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxHeight/2 + 2)
        esp.Distance.Visible = true
    else
        esp.Distance.Visible = false
    end

    if Settings.ESP.Tracers then
        local vps = Camera.ViewportSize
        local origin = Settings.ESP.TracerOrigin
        local from = origin == "Bottom" and Vector2.new(vps.X/2, vps.Y)
            or origin == "Top" and Vector2.new(vps.X/2, 0)
            or origin == "Center" and Vector2.new(vps.X/2, vps.Y/2)
            or Vector2.new(Mouse.X, Mouse.Y)
        esp.Tracer.From = from
        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + boxHeight/2)
        esp.Tracer.Color = boxColor
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end
end

local function RemoveESP(player)
    local esp = ESPObjects[player]
    if esp then
        for _, obj in pairs(esp) do obj:Remove() end
        ESPObjects[player] = nil
    end
end

-- =============================================
-- CHAMS
-- =============================================
function ApplyChams(player)
    if not Settings.ESP.Chams or player == LocalPlayer then return end
    if Settings.ESP.TeamCheck and IsTeammate(player) then return end
    local char = player.Character
    if not char then return end
    local existing = char:FindFirstChild("_Chams")
    if existing then existing:Destroy() end
    local h = Instance.new("Highlight")
    h.Name = "_Chams"
    h.FillColor = Settings.ESP.ChamsColor
    h.FillTransparency = 0.5
    h.OutlineColor = Color3.new(1,1,1)
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = char
    h.Parent = char
end

function RemoveChams(player)
    local char = player.Character
    if char then
        local c = char:FindFirstChild("_Chams")
        if c then c:Destroy() end
    end
end

-- =============================================
-- FLY
-- =============================================
function StartFly()
    if not IsAlive(LocalPlayer) then return end
    local char = LocalPlayer.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    Flying = true
    hum.PlatformStand = true
    FlyBody = Instance.new("BodyVelocity")
    FlyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyBody.Velocity = Vector3.zero
    FlyBody.Parent = root
    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyGyro.D = 200
    FlyGyro.P = 10000
    FlyGyro.Parent = root
end

function StopFly()
    Flying = false
    if FlyBody then FlyBody:Destroy(); FlyBody = nil end
    if FlyGyro then FlyGyro:Destroy(); FlyGyro = nil end
    if IsAlive(LocalPlayer) then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function UpdateFly()
    if not Flying or not IsAlive(LocalPlayer) then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not FlyBody or not FlyGyro then return end
    local speed = Settings.Fly.Speed
    local camCF = Camera.CFrame
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
    if dir.Magnitude > 0 then dir = dir.Unit end
    FlyBody.Velocity = dir * speed
    FlyGyro.CFrame = camCF
end

-- =============================================
-- NOCLIP / SPEED / INF JUMP
-- =============================================
local function UpdateNoclip()
    if not NoclipActive or not IsAlive(LocalPlayer) then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

local function UpdateSpeed()
    if not SpeedActive or not IsAlive(LocalPlayer) then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Settings.Movement.SpeedValue end
end

UserInputService.JumpRequest:Connect(function()
    if InfJumpActive and IsAlive(LocalPlayer) then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- =============================================
-- WEAPON MODS
-- =============================================
local function ApplyWeaponMods()
    if not IsAlive(LocalPlayer) then return end
    for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") then
            for _, desc in pairs(tool:GetDescendants()) do
                local name_lower = string.lower(desc.Name)
                if Settings.Weapon.NoRecoil and string.find(name_lower, "recoil") then
                    if desc:IsA("NumberValue") or desc:IsA("IntValue") then desc.Value = 0
                    elseif desc:IsA("Vector3Value") then desc.Value = Vector3.zero end
                end
                if Settings.Weapon.NoSpread and string.find(name_lower, "spread") then
                    if desc:IsA("NumberValue") or desc:IsA("IntValue") then desc.Value = 0 end
                end
                if Settings.Weapon.RapidFire and (string.find(name_lower, "firerate") or string.find(name_lower, "cooldown") or string.find(name_lower, "cycletime")) then
                    if desc:IsA("NumberValue") or desc:IsA("IntValue") then desc.Value = 0.01 end
                end
                if Settings.Weapon.InfiniteAmmo and string.find(name_lower, "ammo") then
                    if desc:IsA("NumberValue") or desc:IsA("IntValue") then desc.Value = 9999 end
                end
            end
        end
    end
end

-- =============================================
-- FULLBRIGHT / NO FOG
-- =============================================
function ApplyFullbright()
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    lighting.Ambient = Color3.fromRGB(178, 178, 178)
    for _, e in pairs(lighting:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") then e.Enabled = false end
    end
end

function ApplyNoFog()
    local lighting = game:GetService("Lighting")
    lighting.FogEnd = 100000; lighting.FogStart = 0
    for _, e in pairs(lighting:GetChildren()) do
        if e:IsA("Atmosphere") then e.Density = 0 end
    end
end

-- =============================================
-- INPUT HANDLING
-- =============================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Settings.Aimbot.Key then Aiming = true end
    if input.KeyCode == Enum.KeyCode.F then
        if Flying then StopFly() else StartFly() end
    end
    if input.KeyCode == Enum.KeyCode.V then NoclipActive = not NoclipActive end
    if input.KeyCode == Enum.KeyCode.X then
        SpeedActive = not SpeedActive
        if not SpeedActive and IsAlive(LocalPlayer) then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
    if input.KeyCode == Enum.KeyCode.J then InfJumpActive = not InfJumpActive end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.Aimbot.Key then Aiming = false end
end)

-- =============================================
-- MAIN RENDER LOOP
-- =============================================
RunService.RenderStepped:Connect(function()
    UpdateAimbot()

    SilentFOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    SilentFOVCircle.Radius = Settings.SilentAim.FOV
    SilentFOVCircle.Visible = Settings.SilentAim.ShowFOV and Settings.SilentAim.Enabled

    for _, player in pairs(Players:GetPlayers()) do
        UpdateESP(player)
    end

    UpdateFly()
    UpdateNoclip()
    UpdateSpeed()
    ApplyWeaponMods()
end)

-- =============================================
-- INIT
-- =============================================
if Settings.Misc.FullBright then ApplyFullbright() end
if Settings.Misc.NoFog then ApplyNoFog() end

for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
    if player ~= LocalPlayer then
        ApplyChams(player)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            ApplyChams(player)
            CreateESP(player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        ApplyChams(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    RemoveChams(player)
end)

LocalPlayer.CharacterAdded:Connect(function()
    Flying = false; NoclipActive = false; StopFly()
    task.wait(1)
    for _, p in pairs(Players:GetPlayers()) do ApplyChams(p) end
end)

-- Notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Rivals Script v2.0",
        Text = "Loaded! Press Right Shift to toggle GUI",
        Duration = 6,
    })
end)

print("[Rivals] Script loaded. Right Shift = Toggle GUI")
