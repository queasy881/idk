--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                      ADMIN MENU v2.0                        ║
    ║           Legitimate Gamepass Feature / Admin Panel          ║
    ║                                                              ║
    ║  Place as a LocalScript in StarterPlayerScripts              ║
    ║  or load via loadstring.                                     ║
    ║                                                              ║
    ║  Toggle Key: RightShift                                      ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

--------------------------------------------------------------------------------
-- SERVICES
--------------------------------------------------------------------------------
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local Camera            = Workspace.CurrentCamera

--------------------------------------------------------------------------------
-- LOCAL PLAYER REFERENCES
--------------------------------------------------------------------------------
local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Mouse        = LocalPlayer:GetMouse()

--------------------------------------------------------------------------------
-- CONFIGURATION
--------------------------------------------------------------------------------
local CONFIG = {
    TOGGLE_KEY      = Enum.KeyCode.RightShift,
    MENU_SIZE       = UDim2.new(0, 340, 0, 520),
    MENU_POSITION   = UDim2.new(0.5, -170, 0.5, -260),
    ANIM_TIME       = 0.3,

    -- Colors
    BG_PRIMARY      = Color3.fromRGB(18, 18, 24),
    BG_SECONDARY    = Color3.fromRGB(24, 24, 32),
    BG_TERTIARY     = Color3.fromRGB(32, 32, 42),
    ACCENT          = Color3.fromRGB(88, 101, 242),    -- Discord-like blue/purple
    ACCENT_HOVER    = Color3.fromRGB(108, 121, 255),
    TEXT_PRIMARY    = Color3.fromRGB(235, 235, 245),
    TEXT_SECONDARY  = Color3.fromRGB(160, 160, 180),
    TOGGLE_ON       = Color3.fromRGB(67, 181, 129),    -- Green
    TOGGLE_OFF      = Color3.fromRGB(72, 72, 88),      -- Gray
    SLIDER_TRACK    = Color3.fromRGB(52, 52, 68),
    DIVIDER         = Color3.fromRGB(44, 44, 58),
    DANGER          = Color3.fromRGB(237, 66, 69),      -- Red close btn
    BORDER          = Color3.fromRGB(48, 48, 64),
}

--------------------------------------------------------------------------------
-- STATE MANAGEMENT
-- Holds toggle states, active connections, and stored values for cleanup.
--------------------------------------------------------------------------------
local State = {
    menuOpen        = true,
    minimized       = false,
    dragging        = false,
    dragStart       = nil,
    startPos        = nil,

    -- Feature toggles
    espEnabled      = false,
    chamsEnabled    = false,
    aimbotEnabled   = false,
    flyEnabled      = false,
    noclipEnabled   = false,
    infJumpEnabled  = false,
    fullbrightOn    = false,
    speedBoostOn    = false,

    -- Slider values
    walkSpeed       = 16,
    jumpPower       = 50,
    flySpeed        = 60,
    fovRadius       = 150,
    speedBoostVal   = 80,

    -- Active connections for cleanup
    connections     = {},
    highlights      = {},
    chamsEffects    = {},

    -- Stored lighting values
    origLighting    = {},

    -- Fly body movers
    flyBV           = nil,
    flyBG           = nil,

    -- FOV circle
    fovCircle       = nil,

    -- Noclip parts cache
    noclipParts     = {},
}

--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------

--- Create a simple tween and play it
local function tween(obj, props, duration, style, dir)
    duration = duration or CONFIG.ANIM_TIME
    style    = style or Enum.EasingStyle.Quint
    dir      = dir or Enum.EasingDirection.Out
    local t  = TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
    t:Play()
    return t
end

--- Safely get humanoid from local player's character
local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

--- Safely get HumanoidRootPart
local function getRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

--- Disconnect and remove a named connection
local function disconnectKey(key)
    if State.connections[key] then
        State.connections[key]:Disconnect()
        State.connections[key] = nil
    end
end

--- Get all other player characters
local function getOtherCharacters()
    local chars = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(chars, p.Character)
            end
        end
    end
    return chars
end

--- Nearest player character to screen center (within FOV)
local function getNearestTarget()
    local closest   = nil
    local closestDist = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, char in ipairs(getOtherCharacters()) do
        local head = char:FindFirstChild("Head")
        if head then
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if onScreen then
                local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if dist2D <= State.fovRadius and dist2D < closestDist then
                    closest     = char
                    closestDist = dist2D
                end
            end
        end
    end

    return closest
end

--------------------------------------------------------------------------------
-- UI CONSTRUCTION
-- All GUI elements are created entirely in code — no studio objects needed.
--------------------------------------------------------------------------------

-- ScreenGui container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name               = "AdminMenuGui"
ScreenGui.ResetOnSpawn        = false
ScreenGui.ZIndexBehavior      = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset      = false
ScreenGui.Parent              = PlayerGui

-- Main panel frame
local MainFrame = Instance.new("Frame")
MainFrame.Name            = "MainPanel"
MainFrame.Size            = CONFIG.MENU_SIZE
MainFrame.Position        = CONFIG.MENU_POSITION
MainFrame.AnchorPoint     = Vector2.new(0, 0)
MainFrame.BackgroundColor3 = CONFIG.BG_PRIMARY
MainFrame.BackgroundTransparency = 0.03
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent          = ScreenGui

-- Rounded corners for main panel
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent       = MainFrame

-- Outer stroke / border
local mainStroke = Instance.new("UIStroke")
mainStroke.Color        = CONFIG.BORDER
mainStroke.Thickness    = 1.5
mainStroke.Transparency = 0.3
mainStroke.Parent       = MainFrame

-- Subtle gradient overlay on the panel
local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 210)),
})
mainGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.97),
    NumberSequenceKeypoint.new(1, 1),
})
mainGradient.Rotation = 135
mainGradient.Parent   = MainFrame

--------------------------------------------------------------------------------
-- TITLE BAR
--------------------------------------------------------------------------------
local TitleBar = Instance.new("Frame")
TitleBar.Name              = "TitleBar"
TitleBar.Size              = UDim2.new(1, 0, 0, 42)
TitleBar.Position          = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3  = CONFIG.BG_SECONDARY
TitleBar.BackgroundTransparency = 0
TitleBar.BorderSizePixel   = 0
TitleBar.Parent            = MainFrame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 10)
titleBarCorner.Parent       = TitleBar

-- Cover the bottom corners of title bar so only top is rounded
local titleBarCover = Instance.new("Frame")
titleBarCover.Name              = "BottomCover"
titleBarCover.Size              = UDim2.new(1, 0, 0, 12)
titleBarCover.Position          = UDim2.new(0, 0, 1, -12)
titleBarCover.BackgroundColor3  = CONFIG.BG_SECONDARY
titleBarCover.BorderSizePixel   = 0
titleBarCover.Parent            = TitleBar

-- Accent line under title bar
local accentLine = Instance.new("Frame")
accentLine.Name              = "AccentLine"
accentLine.Size              = UDim2.new(1, 0, 0, 2)
accentLine.Position          = UDim2.new(0, 0, 1, 0)
accentLine.BackgroundColor3  = CONFIG.ACCENT
accentLine.BorderSizePixel   = 0
accentLine.Parent            = TitleBar

local accentGrad = Instance.new("UIGradient")
accentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.ACCENT),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(138, 101, 242)),
    ColorSequenceKeypoint.new(1, CONFIG.ACCENT),
})
accentGrad.Parent = accentLine

-- Title text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name              = "TitleText"
TitleLabel.Size              = UDim2.new(1, -90, 1, 0)
TitleLabel.Position          = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text              = "⚡ Admin Menu"
TitleLabel.TextColor3        = CONFIG.TEXT_PRIMARY
TitleLabel.TextSize          = 16
TitleLabel.Font              = Enum.Font.GothamBold
TitleLabel.TextXAlignment    = Enum.TextXAlignment.Left
TitleLabel.Parent            = TitleBar

-- Version tag
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name              = "VersionTag"
VersionLabel.Size              = UDim2.new(0, 40, 0, 18)
VersionLabel.Position          = UDim2.new(0, 130, 0.5, -9)
VersionLabel.BackgroundColor3  = CONFIG.BG_TERTIARY
VersionLabel.BackgroundTransparency = 0
VersionLabel.Text              = "v2.0"
VersionLabel.TextColor3        = CONFIG.TEXT_SECONDARY
VersionLabel.TextSize          = 11
VersionLabel.Font              = Enum.Font.GothamMedium
VersionLabel.TextXAlignment    = Enum.TextXAlignment.Center
VersionLabel.BorderSizePixel   = 0
VersionLabel.Parent            = TitleBar

local verCorner = Instance.new("UICorner")
verCorner.CornerRadius = UDim.new(0, 4)
verCorner.Parent       = VersionLabel

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Name              = "MinimizeBtn"
MinBtn.Size              = UDim2.new(0, 28, 0, 28)
MinBtn.Position          = UDim2.new(1, -66, 0.5, -14)
MinBtn.BackgroundColor3  = CONFIG.BG_TERTIARY
MinBtn.BackgroundTransparency = 0.2
MinBtn.Text              = "─"
MinBtn.TextColor3        = CONFIG.TEXT_SECONDARY
MinBtn.TextSize          = 16
MinBtn.Font              = Enum.Font.GothamBold
MinBtn.BorderSizePixel   = 0
MinBtn.AutoButtonColor   = false
MinBtn.Parent            = TitleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent       = MinBtn

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name              = "CloseBtn"
CloseBtn.Size              = UDim2.new(0, 28, 0, 28)
CloseBtn.Position          = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3  = CONFIG.DANGER
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text              = "✕"
CloseBtn.TextColor3        = CONFIG.TEXT_PRIMARY
CloseBtn.TextSize          = 14
CloseBtn.Font              = Enum.Font.GothamBold
CloseBtn.BorderSizePixel   = 0
CloseBtn.AutoButtonColor   = false
CloseBtn.Parent            = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent       = CloseBtn

--------------------------------------------------------------------------------
-- CONTENT AREA (scrollable)
--------------------------------------------------------------------------------
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name                   = "Content"
ContentFrame.Size                   = UDim2.new(1, -16, 1, -52)
ContentFrame.Position               = UDim2.new(0, 8, 0, 46)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel        = 0
ContentFrame.ScrollBarThickness     = 3
ContentFrame.ScrollBarImageColor3   = CONFIG.ACCENT
ContentFrame.ScrollBarImageTransparency = 0.4
ContentFrame.CanvasSize             = UDim2.new(0, 0, 0, 0)       -- auto-set later
ContentFrame.AutomaticCanvasSize    = Enum.AutomaticSize.Y
ContentFrame.ClipsDescendants       = true
ContentFrame.Parent                 = MainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.SortOrder     = Enum.SortOrder.LayoutOrder
contentLayout.Padding       = UDim.new(0, 4)
contentLayout.Parent        = ContentFrame

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop    = UDim.new(0, 2)
contentPadding.PaddingBottom = UDim.new(0, 8)
contentPadding.Parent        = ContentFrame

--------------------------------------------------------------------------------
-- UI COMPONENT BUILDERS
-- Reusable factory functions to build section headers, toggles, sliders, etc.
--------------------------------------------------------------------------------

local layoutOrder = 0
local function nextOrder()
    layoutOrder = layoutOrder + 1
    return layoutOrder
end

--- Creates a section header label
local function createSection(text)
    local frame = Instance.new("Frame")
    frame.Name              = "Section_" .. text
    frame.Size              = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder       = nextOrder()
    frame.Parent            = ContentFrame

    local label = Instance.new("TextLabel")
    label.Size              = UDim2.new(1, -8, 1, 0)
    label.Position          = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text              = string.upper(text)
    label.TextColor3        = CONFIG.ACCENT
    label.TextSize          = 11
    label.Font              = Enum.Font.GothamBold
    label.TextXAlignment    = Enum.TextXAlignment.Left
    label.TextYAlignment    = Enum.TextYAlignment.Bottom
    label.Parent            = frame

    -- Underline
    local line = Instance.new("Frame")
    line.Size              = UDim2.new(1, -8, 0, 1)
    line.Position          = UDim2.new(0, 4, 1, -1)
    line.BackgroundColor3  = CONFIG.DIVIDER
    line.BorderSizePixel   = 0
    line.Parent            = frame

    return frame
end

--- Creates a divider line
local function createDivider()
    local div = Instance.new("Frame")
    div.Name              = "Divider"
    div.Size              = UDim2.new(1, -16, 0, 1)
    div.BackgroundColor3  = CONFIG.DIVIDER
    div.BackgroundTransparency = 0.3
    div.BorderSizePixel   = 0
    div.LayoutOrder       = nextOrder()
    div.Parent            = ContentFrame

    return div
end

--- Creates a toggle row with a label and animated toggle switch.
--- Returns: toggleButton, a function setVisualState(bool) for external control
local function createToggle(labelText, defaultOn, callback)
    local enabled = defaultOn or false

    local row = Instance.new("Frame")
    row.Name              = "Toggle_" .. labelText
    row.Size              = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3  = CONFIG.BG_SECONDARY
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel   = 0
    row.LayoutOrder       = nextOrder()
    row.Parent            = ContentFrame

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent       = row

    local label = Instance.new("TextLabel")
    label.Size              = UDim2.new(1, -70, 1, 0)
    label.Position          = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text              = labelText
    label.TextColor3        = CONFIG.TEXT_PRIMARY
    label.TextSize          = 13
    label.Font              = Enum.Font.GothamMedium
    label.TextXAlignment    = Enum.TextXAlignment.Left
    label.Parent            = row

    -- Toggle track
    local track = Instance.new("Frame")
    track.Name              = "ToggleTrack"
    track.Size              = UDim2.new(0, 42, 0, 22)
    track.Position          = UDim2.new(1, -54, 0.5, -11)
    track.BackgroundColor3  = enabled and CONFIG.TOGGLE_ON or CONFIG.TOGGLE_OFF
    track.BorderSizePixel   = 0
    track.Parent            = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent       = track

    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Name              = "Knob"
    knob.Size              = UDim2.new(0, 16, 0, 16)
    knob.Position          = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel   = 0
    knob.Parent            = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent       = knob

    -- Invisible button overlay for click detection
    local btn = Instance.new("TextButton")
    btn.Name              = "ToggleBtn"
    btn.Size              = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text              = ""
    btn.Parent            = row

    -- Visual updater
    local function setVisual(on)
        local targetTrackColor = on and CONFIG.TOGGLE_ON or CONFIG.TOGGLE_OFF
        local targetKnobPos    = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        tween(track, {BackgroundColor3 = targetTrackColor}, 0.2)
        tween(knob,  {Position = targetKnobPos}, 0.2, Enum.EasingStyle.Back)
    end

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        setVisual(enabled)
        if callback then
            callback(enabled)
        end
    end)

    -- Hover effect
    btn.MouseEnter:Connect(function()
        tween(row, {BackgroundTransparency = 0.15}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(row, {BackgroundTransparency = 0.4}, 0.15)
    end)

    return btn, setVisual, function() return enabled end
end

--- Creates a slider with label, value display, and drag interaction.
--- Returns: a function setValue(n) for external control
local function createSlider(labelText, min, max, default, callback)
    local value = default or min

    local row = Instance.new("Frame")
    row.Name              = "Slider_" .. labelText
    row.Size              = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3  = CONFIG.BG_SECONDARY
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel   = 0
    row.LayoutOrder       = nextOrder()
    row.Parent            = ContentFrame

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent       = row

    -- Top row: label + value
    local label = Instance.new("TextLabel")
    label.Size              = UDim2.new(0.6, 0, 0, 20)
    label.Position          = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text              = labelText
    label.TextColor3        = CONFIG.TEXT_PRIMARY
    label.TextSize          = 13
    label.Font              = Enum.Font.GothamMedium
    label.TextXAlignment    = Enum.TextXAlignment.Left
    label.Parent            = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Name              = "ValueLabel"
    valLabel.Size              = UDim2.new(0.35, 0, 0, 20)
    valLabel.Position          = UDim2.new(0.62, 0, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Text              = tostring(math.floor(value))
    valLabel.TextColor3        = CONFIG.ACCENT
    valLabel.TextSize          = 13
    valLabel.Font              = Enum.Font.GothamBold
    valLabel.TextXAlignment    = Enum.TextXAlignment.Right
    valLabel.Parent            = row

    -- Slider track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name              = "SliderTrack"
    sliderTrack.Size              = UDim2.new(1, -24, 0, 6)
    sliderTrack.Position          = UDim2.new(0, 12, 0, 33)
    sliderTrack.BackgroundColor3  = CONFIG.SLIDER_TRACK
    sliderTrack.BorderSizePixel   = 0
    sliderTrack.Parent            = row

    local sTrackCorner = Instance.new("UICorner")
    sTrackCorner.CornerRadius = UDim.new(1, 0)
    sTrackCorner.Parent       = sliderTrack

    -- Slider fill
    local initialPct = (value - min) / (max - min)

    local sliderFill = Instance.new("Frame")
    sliderFill.Name              = "SliderFill"
    sliderFill.Size              = UDim2.new(initialPct, 0, 1, 0)
    sliderFill.BackgroundColor3  = CONFIG.ACCENT
    sliderFill.BorderSizePixel   = 0
    sliderFill.Parent            = sliderTrack

    local sFillCorner = Instance.new("UICorner")
    sFillCorner.CornerRadius = UDim.new(1, 0)
    sFillCorner.Parent       = sliderFill

    -- Slider knob (circle)
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name              = "SliderKnob"
    sliderKnob.Size              = UDim2.new(0, 14, 0, 14)
    sliderKnob.Position          = UDim2.new(initialPct, -7, 0.5, -7)
    sliderKnob.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel   = 0
    sliderKnob.ZIndex            = 2
    sliderKnob.Parent            = sliderTrack

    local sKnobCorner = Instance.new("UICorner")
    sKnobCorner.CornerRadius = UDim.new(1, 0)
    sKnobCorner.Parent       = sliderKnob

    local sKnobStroke = Instance.new("UIStroke")
    sKnobStroke.Color     = CONFIG.ACCENT
    sKnobStroke.Thickness = 2
    sKnobStroke.Parent    = sliderKnob

    -- Drag interaction
    local draggingSlider = false

    local function updateSlider(pct)
        pct   = math.clamp(pct, 0, 1)
        value = math.floor(min + (max - min) * pct)
        valLabel.Text          = tostring(value)
        sliderFill.Size        = UDim2.new(pct, 0, 1, 0)
        sliderKnob.Position    = UDim2.new(pct, -7, 0.5, -7)
        if callback then
            callback(value)
        end
    end

    -- Invisible button over slider for click detection
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size              = UDim2.new(1, 0, 0, 24)
    sliderBtn.Position          = UDim2.new(0, 0, 0, -9)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text              = ""
    sliderBtn.Parent            = sliderTrack

    sliderBtn.MouseButton1Down:Connect(function()
        draggingSlider = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if draggingSlider then
            local absPos  = sliderTrack.AbsolutePosition
            local absSize = sliderTrack.AbsoluteSize
            local mouseX  = UserInputService:GetMouseLocation().X
            local pct     = (mouseX - absPos.X) / absSize.X
            updateSlider(pct)
        end
    end)

    -- External setter
    local function setValue(n)
        local p = math.clamp((n - min) / (max - min), 0, 1)
        updateSlider(p)
    end

    -- Hover
    local rowBtn = Instance.new("TextButton")
    rowBtn.Size              = UDim2.new(1, 0, 0, 24)
    rowBtn.Position          = UDim2.new(0, 0, 0, 0)
    rowBtn.BackgroundTransparency = 1
    rowBtn.Text              = ""
    rowBtn.Parent            = row

    rowBtn.MouseEnter:Connect(function()
        tween(row, {BackgroundTransparency = 0.15}, 0.15)
    end)
    rowBtn.MouseLeave:Connect(function()
        tween(row, {BackgroundTransparency = 0.4}, 0.15)
    end)

    return setValue
end

--------------------------------------------------------------------------------
-- BUILD THE MENU LAYOUT
-- Sections: Visuals, Combat, Movement, World
--------------------------------------------------------------------------------

-- ===== VISUALS SECTION =====
createSection("Visuals")

local _, setEspVisual, getEsp             -- ESP
_, setEspVisual, getEsp = createToggle("ESP / Wallhack", false, function(on)
    State.espEnabled = on
end)

local _, setChamsVisual, getChams         -- Chams
_, setChamsVisual, getChams = createToggle("Chams", false, function(on)
    State.chamsEnabled = on
end)

local _, setFullbrightVisual, getFullbright  -- Fullbright
_, setFullbrightVisual, getFullbright = createToggle("Fullbright", false, function(on)
    State.fullbrightOn = on
end)

createDivider()

-- ===== COMBAT SECTION =====
createSection("Combat")

local _, setAimbotVisual, getAimbot       -- Aimbot
_, setAimbotVisual, getAimbot = createToggle("Aimbot (Hold RMB)", false, function(on)
    State.aimbotEnabled = on
end)

local setFovSlider = createSlider("FOV Radius", 50, 400, 150, function(v)
    State.fovRadius = v
end)

createDivider()

-- ===== MOVEMENT SECTION =====
createSection("Movement")

local _, setFlyVisual, getFly             -- Fly
_, setFlyVisual, getFly = createToggle("Fly", false, function(on)
    State.flyEnabled = on
end)

local setFlySpeedSlider = createSlider("Fly Speed", 10, 300, 60, function(v)
    State.flySpeed = v
end)

local setWalkSpeedSlider = createSlider("WalkSpeed", 16, 200, 16, function(v)
    State.walkSpeed = v
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = v
    end
end)

local setJumpPowerSlider = createSlider("JumpPower", 50, 300, 50, function(v)
    State.jumpPower = v
    local hum = getHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end)

local _, setNoclipVisual, getNoclip       -- Noclip
_, setNoclipVisual, getNoclip = createToggle("Noclip", false, function(on)
    State.noclipEnabled = on
end)

local _, setInfJumpVisual, getInfJump     -- Infinite Jump
_, setInfJumpVisual, getInfJump = createToggle("Infinite Jump", false, function(on)
    State.infJumpEnabled = on
end)

local _, setSpeedVisual, getSpeed         -- Speed Boost
_, setSpeedVisual, getSpeed = createToggle("Speed Boost (CFrame)", false, function(on)
    State.speedBoostOn = on
end)

local setSpeedSlider = createSlider("Boost Speed", 20, 200, 80, function(v)
    State.speedBoostVal = v
end)

createDivider()

-- ===== WORLD SECTION =====
createSection("Info")

-- Status / credits label
local infoFrame = Instance.new("Frame")
infoFrame.Size              = UDim2.new(1, 0, 0, 32)
infoFrame.BackgroundTransparency = 1
infoFrame.LayoutOrder       = nextOrder()
infoFrame.Parent            = ContentFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size              = UDim2.new(1, -16, 1, 0)
infoLabel.Position          = UDim2.new(0, 8, 0, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text              = "Admin Menu v2.0 • Toggle: RightShift"
infoLabel.TextColor3        = CONFIG.TEXT_SECONDARY
infoLabel.TextSize          = 11
infoLabel.Font              = Enum.Font.GothamMedium
infoLabel.TextXAlignment    = Enum.TextXAlignment.Center
infoLabel.Parent            = infoFrame

--------------------------------------------------------------------------------
-- FOV CIRCLE (drawn with UICorner on a frame — always centered on screen)
--------------------------------------------------------------------------------
local fovCircle = Instance.new("Frame")
fovCircle.Name                  = "FOVCircle"
fovCircle.AnchorPoint           = Vector2.new(0.5, 0.5)
fovCircle.Size                  = UDim2.new(0, State.fovRadius * 2, 0, State.fovRadius * 2)
fovCircle.Position              = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel       = 0
fovCircle.Visible               = false
fovCircle.Parent                = ScreenGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Color        = CONFIG.ACCENT
fovStroke.Thickness    = 1.5
fovStroke.Transparency = 0.4
fovStroke.Parent       = fovCircle

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(0.5, 0)
fovCorner.Parent       = fovCircle

State.fovCircle = fovCircle

--------------------------------------------------------------------------------
-- TITLE BAR DRAGGING
--------------------------------------------------------------------------------
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        State.dragging  = true
        State.dragStart = input.Position
        State.startPos  = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        State.dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if State.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - State.dragStart
        MainFrame.Position = UDim2.new(
            State.startPos.X.Scale, State.startPos.X.Offset + delta.X,
            State.startPos.Y.Scale, State.startPos.Y.Offset + delta.Y
        )
    end
end)

--------------------------------------------------------------------------------
-- OPEN / CLOSE / MINIMIZE ANIMATIONS
--------------------------------------------------------------------------------
local fullSize = CONFIG.MENU_SIZE

local function showMenu()
    State.menuOpen = true
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, fullSize.X.Offset, 0, 0)
    MainFrame.BackgroundTransparency = 1
    tween(MainFrame, {
        Size = fullSize,
        BackgroundTransparency = 0.03,
    }, CONFIG.ANIM_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function hideMenu()
    local t = tween(MainFrame, {
        Size = UDim2.new(0, fullSize.X.Offset, 0, 0),
        BackgroundTransparency = 1,
    }, CONFIG.ANIM_TIME, Enum.EasingStyle.Quint)
    t.Completed:Connect(function()
        State.menuOpen = false
        MainFrame.Visible = false
    end)
end

local function minimizeMenu()
    State.minimized = true
    ContentFrame.Visible = false
    tween(MainFrame, {
        Size = UDim2.new(0, fullSize.X.Offset, 0, 44),
    }, 0.25, Enum.EasingStyle.Quint)
end

local function restoreMenu()
    State.minimized = false
    tween(MainFrame, {
        Size = fullSize,
    }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.delay(0.1, function()
        ContentFrame.Visible = true
    end)
end

-- Button events
MinBtn.MouseButton1Click:Connect(function()
    if State.minimized then
        restoreMenu()
    else
        minimizeMenu()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    hideMenu()
end)

-- Hover effects for title buttons
for _, btn in ipairs({MinBtn, CloseBtn}) do
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundTransparency = 0}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundTransparency = 0.2}, 0.15)
    end)
end

-- Toggle key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.TOGGLE_KEY then
        if State.menuOpen then
            hideMenu()
        else
            showMenu()
        end
    end
end)

--------------------------------------------------------------------------------
-- FEATURE IMPLEMENTATIONS
--------------------------------------------------------------------------------

--=============================================================================
-- 1. ESP / WALLHACK
-- Creates Highlight instances on every other player's character.
--=============================================================================
local function clearESP()
    for _, h in pairs(State.highlights) do
        if h and h.Parent then
            h:Destroy()
        end
    end
    State.highlights = {}
end

local function applyESP()
    clearESP()
    if not State.espEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local existing = player.Character:FindFirstChild("ESP_Highlight")
            if not existing then
                local hl = Instance.new("Highlight")
                hl.Name           = "ESP_Highlight"
                hl.FillTransparency = 0.75
                hl.FillColor      = CONFIG.ACCENT
                hl.OutlineColor   = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0.2
                hl.Adornee        = player.Character
                hl.Parent         = player.Character
                table.insert(State.highlights, hl)
            end
        end
    end
end

--=============================================================================
-- 2. CHAMS
-- Colored fill visible through walls using Highlight with lower fill transparency.
--=============================================================================
local function clearChams()
    for _, c in pairs(State.chamsEffects) do
        if c and c.Parent then
            c:Destroy()
        end
    end
    State.chamsEffects = {}
end

local function applyChams()
    clearChams()
    if not State.chamsEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local existing = player.Character:FindFirstChild("Chams_Highlight")
            if not existing then
                local hl = Instance.new("Highlight")
                hl.Name           = "Chams_Highlight"
                hl.FillTransparency = 0.3
                hl.FillColor      = Color3.fromRGB(255, 50, 50)
                hl.OutlineColor   = Color3.fromRGB(255, 100, 100)
                hl.OutlineTransparency = 0
                hl.DepthMode      = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee        = player.Character
                hl.Parent         = player.Character
                table.insert(State.chamsEffects, hl)
            end
        end
    end
end

--=============================================================================
-- 3. AIMBOT
-- Locks camera to nearest player head while holding right mouse button.
--=============================================================================
local aimbotActive = false

local function runAimbot()
    if not State.aimbotEnabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local target = getNearestTarget()
    if target then
        local head = target:FindFirstChild("Head")
        if head then
            local rootPart = getRootPart()
            if rootPart then
                local lookAt = CFrame.lookAt(Camera.CFrame.Position, head.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.5)
            end
        end
    end
end

--=============================================================================
-- 4. FLY
-- Uses BodyVelocity and BodyGyro to let the player fly with WASD / Space / Shift.
--=============================================================================
local function enableFly()
    local root = getRootPart()
    local hum  = getHumanoid()
    if not root or not hum then return end

    -- Disable default gravity
    hum.PlatformStand = true

    local bv = Instance.new("BodyVelocity")
    bv.Name        = "FlyBV"
    bv.MaxForce    = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity    = Vector3.zero
    bv.Parent      = root
    State.flyBV    = bv

    local bg = Instance.new("BodyGyro")
    bg.Name        = "FlyBG"
    bg.MaxTorque   = Vector3.new(math.huge, math.huge, math.huge)
    bg.D           = 100
    bg.P           = 10000
    bg.Parent      = root
    State.flyBG    = bg

    State.connections["fly"] = RunService.RenderStepped:Connect(function()
        if not State.flyEnabled then return end
        local root2 = getRootPart()
        if not root2 or not State.flyBV or not State.flyBV.Parent then return end

        local camCF  = Camera.CFrame
        local dir    = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dir = dir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dir = dir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dir = dir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dir = dir + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        if dir.Magnitude > 0 then
            dir = dir.Unit
        end

        State.flyBV.Velocity = dir * State.flySpeed
        State.flyBG.CFrame   = camCF
    end)
end

local function disableFly()
    disconnectKey("fly")

    if State.flyBV and State.flyBV.Parent then
        State.flyBV:Destroy()
    end
    if State.flyBG and State.flyBG.Parent then
        State.flyBG:Destroy()
    end
    State.flyBV = nil
    State.flyBG = nil

    local hum = getHumanoid()
    if hum then
        hum.PlatformStand = false
    end
end

--=============================================================================
-- 5. WALKSPEED & 6. JUMPPOWER
-- Handled directly via slider callbacks above.
--=============================================================================

--=============================================================================
-- 7. NOCLIP
-- Temporarily sets character parts to CanCollide = false each frame.
--=============================================================================
local function startNoclip()
    State.connections["noclip"] = RunService.Stepped:Connect(function()
        if not State.noclipEnabled then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    disconnectKey("noclip")
    -- Restore collision
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Name == "HumanoidRootPart" then
                    part.CanCollide = true
                elseif part:IsA("MeshPart") or part:IsA("Part") then
                    part.CanCollide = true
                end
            end
        end
    end
end

--=============================================================================
-- 8. INFINITE JUMP
-- Allows jumping even while in the air by listening for space press.
--=============================================================================
local function startInfJump()
    State.connections["infJump"] = UserInputService.JumpRequest:Connect(function()
        if not State.infJumpEnabled then return end
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfJump()
    disconnectKey("infJump")
end

--=============================================================================
-- 9. FULLBRIGHT
-- Sets Lighting properties to max brightness, restores original on disable.
--=============================================================================
local function enableFullbright()
    -- Store original values
    State.origLighting = {
        Brightness    = Lighting.Brightness,
        ClockTime     = Lighting.ClockTime,
        FogEnd        = Lighting.FogEnd,
        FogStart      = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient       = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }
    Lighting.Brightness      = 2
    Lighting.ClockTime       = 14
    Lighting.FogEnd          = 100000
    Lighting.FogStart        = 100000
    Lighting.GlobalShadows   = false
    Lighting.Ambient         = Color3.fromRGB(200, 200, 200)
    Lighting.OutdoorAmbient  = Color3.fromRGB(200, 200, 200)
end

local function disableFullbright()
    if State.origLighting.Brightness then
        Lighting.Brightness      = State.origLighting.Brightness
        Lighting.ClockTime       = State.origLighting.ClockTime
        Lighting.FogEnd          = State.origLighting.FogEnd
        Lighting.FogStart        = State.origLighting.FogStart
        Lighting.GlobalShadows   = State.origLighting.GlobalShadows
        Lighting.Ambient         = State.origLighting.Ambient
        Lighting.OutdoorAmbient  = State.origLighting.OutdoorAmbient
    end
end

--=============================================================================
-- 10. SPEED BOOST (CFrame-based)
-- Moves the HumanoidRootPart using CFrame for extra speed.
--=============================================================================
local function startSpeedBoost()
    State.connections["speedBoost"] = RunService.RenderStepped:Connect(function(dt)
        if not State.speedBoostOn then return end
        local root = getRootPart()
        local hum  = getHumanoid()
        if not root or not hum then return end

        if hum.MoveDirection.Magnitude > 0 then
            local move = hum.MoveDirection.Unit * State.speedBoostVal * dt
            root.CFrame = root.CFrame + move
        end
    end)
end

local function stopSpeedBoost()
    disconnectKey("speedBoost")
end

--------------------------------------------------------------------------------
-- MAIN UPDATE LOOP
-- Runs every render frame to handle continuous features.
--------------------------------------------------------------------------------
State.connections["mainLoop"] = RunService.RenderStepped:Connect(function()
    -- ESP: refresh periodically (every frame is fine for Highlights)
    if State.espEnabled then
        -- Only reapply if a player's character changed (lightweight check)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not player.Character:FindFirstChild("ESP_Highlight") then
                    applyESP()
                    break
                end
            end
        end
    else
        if #State.highlights > 0 then
            clearESP()
        end
    end

    -- Chams: same approach
    if State.chamsEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not player.Character:FindFirstChild("Chams_Highlight") then
                    applyChams()
                    break
                end
            end
        end
    else
        if #State.chamsEffects > 0 then
            clearChams()
        end
    end

    -- Aimbot
    if State.aimbotEnabled then
        runAimbot()
        fovCircle.Visible = true
        fovCircle.Size    = UDim2.new(0, State.fovRadius * 2, 0, State.fovRadius * 2)
    else
        fovCircle.Visible = false
    end

    -- Fly toggle handling
    if State.flyEnabled and not State.flyBV then
        enableFly()
    elseif not State.flyEnabled and State.flyBV then
        disableFly()
    end

    -- Fullbright toggle handling
    if State.fullbrightOn and not State.origLighting.Brightness then
        enableFullbright()
    elseif not State.fullbrightOn and State.origLighting.Brightness then
        disableFullbright()
        State.origLighting = {}
    end

    -- Noclip toggle
    if State.noclipEnabled and not State.connections["noclip"] then
        startNoclip()
    elseif not State.noclipEnabled and State.connections["noclip"] then
        stopNoclip()
    end

    -- Infinite Jump toggle
    if State.infJumpEnabled and not State.connections["infJump"] then
        startInfJump()
    elseif not State.infJumpEnabled and State.connections["infJump"] then
        stopInfJump()
    end

    -- Speed Boost toggle
    if State.speedBoostOn and not State.connections["speedBoost"] then
        startSpeedBoost()
    elseif not State.speedBoostOn and State.connections["speedBoost"] then
        stopSpeedBoost()
    end
end)

--------------------------------------------------------------------------------
-- CHARACTER RESPAWN HANDLING
-- Re-applies WalkSpeed, JumpPower, and re-enables active features after death.
--------------------------------------------------------------------------------
local function onCharacterAdded(character)
    -- Wait for humanoid to load
    local hum = character:WaitForChild("Humanoid", 10)
    if not hum then return end

    character:WaitForChild("HumanoidRootPart", 10)

    -- Re-apply walkspeed and jumppower
    task.defer(function()
        if hum then
            hum.WalkSpeed = State.walkSpeed
            hum.UseJumpPower = true
            hum.JumpPower = State.jumpPower
        end
    end)

    -- If fly was on, re-enable it after respawn
    if State.flyEnabled then
        disableFly()
        task.wait(0.2)
        enableFly()
    end

    -- Fullbright persists (lighting-based, not character-based)

    -- Noclip: reconnect
    if State.noclipEnabled then
        stopNoclip()
        task.wait(0.1)
        startNoclip()
    end

    -- Speed boost: reconnect
    if State.speedBoostOn then
        stopSpeedBoost()
        task.wait(0.1)
        startSpeedBoost()
    end

    -- ESP and Chams will auto-refresh via the main loop
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Initial setup if character already exists
if LocalPlayer.Character then
    task.spawn(function()
        onCharacterAdded(LocalPlayer.Character)
    end)
end

-- Handle other players joining / leaving (for ESP / Chams refresh)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if State.espEnabled then applyESP() end
        if State.chamsEnabled then applyChams() end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    -- Cleanup any highlights on the leaving player
    task.defer(function()
        if State.espEnabled then applyESP() end
        if State.chamsEnabled then applyChams() end
    end)
end)

--------------------------------------------------------------------------------
-- INITIAL ANIMATION
-- Open the menu with a smooth entrance when the script first loads.
--------------------------------------------------------------------------------
MainFrame.Size = UDim2.new(0, fullSize.X.Offset, 0, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true

task.wait(0.3)
showMenu()

print("[Admin Menu] Loaded successfully! Press RightShift to toggle.")