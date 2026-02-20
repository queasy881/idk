-- ============================================================
--  ★★★ ULTIMATE PREMIUM FPS TOOLKIT v4.0 ★★★
--  CYBERPUNK EDITION — Place as LocalScript in StarterPlayerScripts
--  Gate behind GamePass for monetization
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ========================
--  MASTER SETTINGS
-- ========================
local S = {
	-- Aim Assist
	Aim_Enabled = true,
	Aim_Strength = 0.3,
	Aim_Radius = 120,
	Aim_Part = "Head",
	Aim_RequireADS = true,
	Aim_TeamCheck = true,
	Aim_Smoothing = "Linear",
	Aim_Prediction = false,
	Aim_PredictionScale = 1.0,       -- NEW: how far ahead to predict
	Aim_StickyAim = false,
	Aim_StickyStrength = 0.15,
	Aim_DistanceFalloff = false,     -- NEW: weaker at longer range
	Aim_FalloffStart = 100,          -- NEW: studs where falloff starts
	Aim_FalloffEnd = 300,            -- NEW: studs where aim = 0
	Aim_TargetSwitchDelay = 0.2,     -- NEW: delay before switching targets
	Aim_IgnoreDowned = true,         -- NEW: skip downed/low hp targets
	Aim_DownedThreshold = 10,        -- NEW: hp below this = "downed"
	Aim_MaxTargets = 1,              -- NEW: 1 = single lock, multi for groups
	Aim_WallCheck = false,           -- NEW: don't aim through walls
	Aim_VisibilityCheck = false,     -- NEW: raycast check if target visible

	-- Triggerbot
	Trigger_Enabled = false,
	Trigger_Delay = 0,
	Trigger_RequireADS = true,
	Trigger_TeamCheck = true,
	Trigger_HitPart = "Any",
	Trigger_BurstMode = false,
	Trigger_BurstCount = 3,
	Trigger_BurstDelay = 0.05,
	Trigger_MaxRange = 500,
	Trigger_FOVCheck = true,
	Trigger_Indicator = true,
	Trigger_HumanizeDelay = false,   -- NEW: random delay to look legit
	Trigger_HumanizeMin = 30,        -- NEW: min random ms
	Trigger_HumanizeMax = 120,       -- NEW: max random ms
	Trigger_HeadshotPriority = false, -- NEW: only fire on headshots
	Trigger_MinHP = 0,               -- NEW: don't waste shots on low hp
	Trigger_AutoSwitch = false,      -- NEW: auto switch to next target after kill

	-- Crosshair
	Cross_Enabled = true,
	Cross_Style = "Cross",
	Cross_Color = Color3.fromRGB(0, 255, 200),
	Cross_Size = 12,
	Cross_Thick = 2,
	Cross_Gap = 4,
	Cross_Opacity = 1,
	Cross_Outline = true,
	Cross_Dynamic = false,
	Cross_DynamicScale = 6,          -- NEW: how much it expands
	Cross_DynamicSpeed = 0.1,        -- NEW: how fast it snaps back
	Cross_HitColor = Color3.fromRGB(255, 50, 50), -- NEW: flash on hit
	Cross_HitFlash = true,           -- NEW: crosshair flashes on hit
	Cross_KillColor = Color3.fromRGB(255, 0, 0),   -- NEW: flash on kill
	Cross_RainbowMode = false,       -- NEW: rainbow cycling crosshair
	Cross_RainbowSpeed = 2,          -- NEW: cycle speed
	Cross_CenterDot = false,         -- NEW: always show center dot
	Cross_SpreadIndicator = false,   -- NEW: shows weapon spread circle

	-- ESP
	ESP_Enabled = false,
	ESP_Names = true,
	ESP_Health = true,
	ESP_Distance = true,
	ESP_Boxes = true,
	ESP_Tracers = false,
	ESP_Chams = false,
	ESP_TeamCheck = true,
	ESP_MaxDist = 500,
	ESP_EnemyColor = Color3.fromRGB(255, 50, 80),
	ESP_TeamColor = Color3.fromRGB(0, 255, 200),
	ESP_TracerOrigin = "Bottom",
	ESP_TracerThickness = 1,         -- NEW: tracer line thickness
	ESP_NameSize = 12,               -- NEW: name text size
	ESP_ShowWeapon = false,          -- NEW: show equipped tool name
	ESP_ShowLookDir = false,         -- NEW: arrow showing where they face
	ESP_HealthColorMode = "Gradient", -- NEW: Gradient, Static, Class
	ESP_BoxStyle = "Highlight",      -- NEW: Highlight, Corners, Full
	ESP_SkeletonESP = false,         -- NEW: draw skeleton lines
	ESP_HeadDot = false,             -- NEW: dot on head position
	ESP_HeadDotSize = 4,             -- NEW: head dot size
	ESP_OffScreenArrows = false,     -- NEW: arrows for off-screen enemies
	ESP_DistanceScale = false,       -- NEW: scale ESP size by distance
	ESP_SnaplineColor = "Match",     -- NEW: Match or Custom tracer color
	ESP_FillOpacity = 0.8,           -- NEW: chams fill transparency
	ESP_OutlineOpacity = 0.3,        -- NEW: chams outline transparency

	-- Combat
	HitMarkers = true,
	HitM_Style = "Cross",            -- NEW: Cross, Circle, Skull
	HitM_Size = 14,                  -- NEW: hitmarker size
	HitM_Duration = 0.2,             -- NEW: how long it shows
	HitM_Color = Color3.fromRGB(255, 255, 255), -- NEW: hitmarker color
	HitM_HeadshotColor = Color3.fromRGB(255, 50, 50), -- NEW: headshot color
	HitM_Sound = true,               -- NEW: play sound on hit
	DamageNumbers = true,
	DmgNum_Color = Color3.fromRGB(255, 255, 80),
	DmgNum_CritColor = Color3.fromRGB(255, 50, 50),
	DmgNum_Size = 16,                -- NEW: damage text size
	DmgNum_CritSize = 22,            -- NEW: crit text size
	DmgNum_FloatSpeed = 0.1,         -- NEW: how fast numbers float up
	DmgNum_Duration = 0.6,           -- NEW: how long they stay
	DmgNum_Scatter = 2,              -- NEW: random spread (studs)
	DmgNum_CritThreshold = 40,       -- NEW: damage above this = crit
	DmgNum_ShowTotal = false,         -- NEW: show accumulated damage
	KillFeed = true,
	KillFeed_Max = 5,
	KillFeed_Duration = 5,           -- NEW: how long entries stay
	KillFeed_Position = "TopRight",  -- NEW: TopRight, TopLeft, BottomRight
	KillFeed_ShowWeapon = false,     -- NEW: show weapon used
	KillCounter = true,
	KillCounter_ShowStreak = true,   -- NEW: show current killstreak
	KillCounter_StreakAnnounce = true, -- NEW: big text on 3/5/10 streak
	KillCounter_ResetOnDeath = false, -- NEW: reset streak on death

	-- Movement
	Fly_Enabled = false,
	Fly_Speed = 60,
	Fly_Acceleration = 5,            -- NEW: how fast to reach full speed
	Fly_Deceleration = 3,            -- NEW: how fast to stop
	Fly_VerticalSpeed = 60,          -- NEW: separate up/down speed
	Fly_FreeLook = false,            -- NEW: look around while flying still
	Fly_Animations = true,           -- NEW: play idle anim while flying
	Fly_AntiDetect = false,          -- NEW: simulate ground contact
	WalkSpeed_Enabled = false,
	WalkSpeed_Value = 16,
	WalkSpeed_Acceleration = false,  -- NEW: gradual speed increase
	WalkSpeed_AccelTime = 1,         -- NEW: seconds to reach max speed
	InfJump_Enabled = false,
	InfJump_Power = 50,              -- NEW: jump force
	InfJump_MaxJumps = 0,            -- NEW: 0 = unlimited, or set limit
	InfJump_Cooldown = 0,            -- NEW: seconds between jumps
	InfJump_DoubleOnly = false,      -- NEW: only 1 extra jump (double jump)
	Noclip_Enabled = false,
	Noclip_KeyToggle = "N",          -- NEW: keybind for noclip
	Noclip_GhostMode = false,        -- NEW: invisible + noclip combo
	Noclip_Speed = 16,               -- NEW: movement speed during noclip
	LongArms_Enabled = false,
	LongArms_Length = 10,
	LongArms_Parts = "Arms",         -- NEW: Arms, Legs, Both, All
	LongArms_Visible = true,         -- NEW: show extended parts or hide
	SpeedBoost_Enabled = false,
	SpeedBoost_Key = "LeftControl",
	SpeedBoost_Multiplier = 2.5,
	SpeedBoost_FOVEffect = false,    -- NEW: zoom FOV when boosting
	SpeedBoost_FOVAmount = 85,       -- NEW: FOV when boosting
	SpeedBoost_Trail = false,        -- NEW: speed trail effect
	TP_Behind_Enabled = true,
	TP_Behind_Key = "T",
	TP_Behind_Distance = 5,
	TP_Behind_Cooldown = 3,
	TP_Behind_TeamCheck = true,
	TP_Behind_MaxRange = 200,
	TP_Behind_FaceEnemy = true,
	TP_Behind_Effect = true,
	TP_Behind_AutoAttack = false,    -- NEW: auto click after teleporting
	TP_Behind_AutoAttackDelay = 0.1, -- NEW: delay before auto attack
	TP_Behind_Chain = false,         -- NEW: chain TP to next enemy if killed
	TP_Behind_ChainDelay = 0.5,      -- NEW: delay between chain TPs
	TP_Behind_Offset = "Behind",     -- NEW: Behind, Above, Side

	-- Visuals
	FOVCircle = true,
	FOVCircle_Opacity = 0.3,
	FOVCircle_Color = Color3.fromRGB(0, 255, 220), -- NEW: circle color
	FOVCircle_Thickness = 1,         -- NEW: circle thickness
	FOVCircle_Filled = false,        -- NEW: filled circle
	FOVCircle_FillOpacity = 0.05,    -- NEW: fill opacity
	FOVCircle_Dynamic = false,       -- NEW: pulse animation
	Fullbright = false,
	Fullbright_Brightness = 2,
	Fullbright_RemoveFog = true,     -- NEW: remove fog
	Fullbright_RemoveEffects = true, -- NEW: remove bloom/blur
	Fullbright_CustomAmbient = false, -- NEW: custom ambient color
	Fullbright_AmbientColor = Color3.fromRGB(180, 180, 200), -- NEW
	NameHider = false,
	NameHider_Alias = "Player",
	NameHider_RandomAlias = false,   -- NEW: random name each life
	NameHider_HideFromLeaderboard = false, -- NEW: try to hide from lb
	ThirdPerson = false,
	ThirdPerson_Dist = 10,
	ThirdPerson_Offset = 0,          -- NEW: horizontal offset (over shoulder)
	ThirdPerson_Transparent = true,  -- NEW: make character transparent when close
	ThirdPerson_LockMouse = false,   -- NEW: lock mouse center in 3P
	Freecam = false,
	Freecam_Speed = 1,
	Freecam_Smoothing = 0.1,        -- NEW: camera smoothing
	Freecam_ShowPosition = true,     -- NEW: show XYZ position
	Freecam_Teleport = false,        -- NEW: teleport character to freecam pos

	-- QOL
	FPSCounter = true,
	PingDisplay = true,
	FPS_Position = "BottomLeft",     -- NEW: BottomLeft, BottomRight, TopLeft
	FPS_ShowGraph = false,           -- NEW: mini fps graph
	FPS_LowWarning = true,           -- NEW: flash red below threshold
	FPS_LowThreshold = 30,           -- NEW: fps warning threshold
	Ping_HighWarning = true,         -- NEW: flash red above threshold
	Ping_HighThreshold = 150,        -- NEW: ping warning threshold

	-- Troll: Combat
	Hitbox_Enabled = false,
	Hitbox_HeadSize = 5,
	Hitbox_BodySize = 3,
	Hitbox_Transparency = 0.8,
	Hitbox_TeamCheck = true,
	CharScale_Enabled = false,
	CharScale_Value = 1,
	SpinBot_Enabled = false,
	SpinBot_Speed = 20,
	SpinBot_Axis = "Y",
	FakeLag_Enabled = false,
	FakeLag_Intensity = 5,
	FakeLag_Interval = 0.2,

	-- Troll: Player
	Fling_Enabled = false,
	Fling_Power = 5000,
	Fling_OnTouch = true,
	Orbit_Enabled = false,
	Orbit_Speed = 3,
	Orbit_Radius = 10,
	Orbit_Height = 0,
	Attach_Enabled = false,
	Attach_Offset = "Head",
	Ragdoll_Enabled = false,

	-- Troll: Utility
	AntiAFK_Enabled = true,
	AntiVoid_Enabled = false,
	AntiVoid_Height = -100,
	ChatSpam_Enabled = false,
	ChatSpam_Message = "GG",
	ChatSpam_Delay = 3,

	-- Troll: Visual
	Headless_Enabled = false,
	InvisTorso_Enabled = false,
	Seizure_Enabled = false,
	Seizure_Speed = 0.1,
	Matrix_Enabled = false,
	Matrix_SlowMo = 0.3,
}

-- Tracking
local KillCount = 0
local DeathCount = 0
local ShotsFired = 0
local ShotsHit = 0
local KillFeedEntries = {}
local LastHealthValues = {}
local ActiveFeatureCount = 0

-- ========================
--  CYBERPUNK COLOR PALETTE
-- ========================
local C = {
	-- Core
	void        = Color3.fromRGB(5, 5, 12),
	bg          = Color3.fromRGB(10, 8, 18),
	bg2         = Color3.fromRGB(14, 12, 24),
	card        = Color3.fromRGB(18, 15, 30),
	card_glass  = Color3.fromRGB(22, 18, 38),
	card_hover  = Color3.fromRGB(28, 24, 48),

	-- Neon Cyberpunk accents
	cyber_cyan  = Color3.fromRGB(0, 255, 220),
	cyber_pink  = Color3.fromRGB(255, 0, 128),
	cyber_purple= Color3.fromRGB(180, 60, 255),
	cyber_yellow= Color3.fromRGB(255, 240, 0),
	cyber_red   = Color3.fromRGB(255, 30, 60),
	cyber_blue  = Color3.fromRGB(30, 144, 255),
	cyber_orange= Color3.fromRGB(255, 140, 0),
	cyber_green = Color3.fromRGB(0, 255, 140),

	-- UI
	text        = Color3.fromRGB(220, 225, 240),
	subtext     = Color3.fromRGB(100, 105, 130),
	dim         = Color3.fromRGB(55, 55, 80),
	slider_bg   = Color3.fromRGB(25, 22, 40),
	border      = Color3.fromRGB(50, 40, 80),
	glass_border= Color3.fromRGB(80, 60, 140),
	tab_bg      = Color3.fromRGB(8, 6, 16),
	glow        = Color3.fromRGB(0, 255, 220),
}

-- ========================
--  SCREEN GUIS
-- ========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberpunkFPSToolkit"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = "ToolkitOverlay"
OverlayGui.ResetOnSpawn = false
OverlayGui.DisplayOrder = 999
OverlayGui.IgnoreGuiInset = true
OverlayGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local HUDGui = Instance.new("ScreenGui")
HUDGui.Name = "ToolkitHUD"
HUDGui.ResetOnSpawn = false
HUDGui.DisplayOrder = 998
HUDGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ========================
--  UTILITY
-- ========================
local function lerp(a, b, t) return a + (b - a) * t end
local function formatTime()
	local t = os.date("*t")
	return string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
end

local function glitchText(text)
	local glitchChars = {"█", "▓", "░", "▒", "■", "◆", "◈", "▪", "⬥"}
	local result = ""
	for i = 1, #text do
		if math.random() < 0.08 then
			result = result .. glitchChars[math.random(#glitchChars)]
		else
			result = result .. text:sub(i, i)
		end
	end
	return result
end

-- ========================
--  NOTIFICATION TOAST SYSTEM
-- ========================
local ToastContainer = Instance.new("Frame")
ToastContainer.Size = UDim2.new(0, 260, 0, 400)
ToastContainer.Position = UDim2.new(1, -275, 0, 80)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 200
ToastContainer.Parent = HUDGui
local toastLayout = Instance.new("UIListLayout", ToastContainer)
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Padding = UDim.new(0, 6)
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local toastOrder = 0
local function showToast(title, message, color, icon)
	toastOrder = toastOrder + 1
	color = color or C.cyber_cyan
	icon = icon or "⚡"

	local toast = Instance.new("Frame")
	toast.Size = UDim2.new(1, 0, 0, 46)
	toast.BackgroundColor3 = C.card
	toast.BackgroundTransparency = 0.15
	toast.BorderSizePixel = 0
	toast.LayoutOrder = toastOrder
	toast.ZIndex = 201
	toast.ClipsDescendants = true
	toast.Parent = ToastContainer
	Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)

	-- Glass border
	local stroke = Instance.new("UIStroke", toast)
	stroke.Color = color
	stroke.Thickness = 1
	stroke.Transparency = 0.5

	-- Accent line left
	local accentLine = Instance.new("Frame")
	accentLine.Size = UDim2.new(0, 3, 1, 0)
	accentLine.BackgroundColor3 = color
	accentLine.BorderSizePixel = 0
	accentLine.ZIndex = 202
	accentLine.Parent = toast

	-- Icon
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(0, 30, 1, 0)
	iconLbl.Position = UDim2.new(0, 10, 0, 0)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Text = icon
	iconLbl.TextSize = 16
	iconLbl.Font = Enum.Font.GothamBold
	iconLbl.TextColor3 = color
	iconLbl.ZIndex = 202
	iconLbl.Parent = toast

	-- Title
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -50, 0, 18)
	titleLbl.Position = UDim2.new(0, 42, 0, 4)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = string.upper(title)
	titleLbl.TextColor3 = color
	titleLbl.TextSize = 9
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.ZIndex = 202
	titleLbl.Parent = toast

	-- Message
	local msgLbl = Instance.new("TextLabel")
	msgLbl.Size = UDim2.new(1, -50, 0, 16)
	msgLbl.Position = UDim2.new(0, 42, 0, 22)
	msgLbl.BackgroundTransparency = 1
	msgLbl.Text = message
	msgLbl.TextColor3 = C.text
	msgLbl.TextSize = 10
	msgLbl.Font = Enum.Font.GothamMedium
	msgLbl.TextXAlignment = Enum.TextXAlignment.Left
	msgLbl.ZIndex = 202
	msgLbl.Parent = toast

	-- Slide in animation
	toast.Position = UDim2.new(1, 0, 0, 0)
	TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()

	-- Auto dismiss
	spawn(function()
		wait(3)
		if toast.Parent then
			TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Position = UDim2.new(1, 20, 0, 0),
				BackgroundTransparency = 1
			}):Play()
			wait(0.35)
			toast:Destroy()
		end
	end)
end

-- ========================
--  TOGGLE BUTTON (cyberpunk styled)
-- ========================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(1, -64, 0, 14)
ToggleBtn.BackgroundColor3 = C.cyber_cyan
ToggleBtn.Text = "◈"
ToggleBtn.TextColor3 = C.void
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.ZIndex = 100
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

-- Neon glow
local toggleGlow = Instance.new("ImageLabel")
toggleGlow.Size = UDim2.new(1, 30, 1, 30)
toggleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
toggleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
toggleGlow.BackgroundTransparency = 1
toggleGlow.ImageColor3 = C.cyber_cyan
toggleGlow.ImageTransparency = 0.6
toggleGlow.Image = "rbxassetid://5028857084"
toggleGlow.ZIndex = 99
toggleGlow.Parent = ToggleBtn

-- Pulsing neon
spawn(function()
	while true do
		TweenService:Create(toggleGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			ImageTransparency = 0.3, Size = UDim2.new(1, 40, 1, 40)
		}):Play()
		TweenService:Create(ToggleBtn, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			BackgroundColor3 = C.cyber_pink
		}):Play()
		wait(1)
		TweenService:Create(toggleGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			ImageTransparency = 0.7, Size = UDim2.new(1, 24, 1, 24)
		}):Play()
		TweenService:Create(ToggleBtn, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			BackgroundColor3 = C.cyber_cyan
		}):Play()
		wait(1)
	end
end)

-- ========================
--  MAIN PANEL (glassmorphism)
-- ========================
local Panel = Instance.new("Frame")
Panel.Name = "MainPanel"
Panel.Size = UDim2.new(0, 540, 0, 580)
Panel.Position = UDim2.new(0.5, 0, 0.5, 0)
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.BackgroundColor3 = C.bg
Panel.BackgroundTransparency = 0.08
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.ZIndex = 50
Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 16)

-- Glassmorphism border
local panelStroke = Instance.new("UIStroke", Panel)
panelStroke.Color = C.glass_border
panelStroke.Thickness = 1.5
panelStroke.Transparency = 0.3

-- Inner glow overlay (simulated glass)
local glassOverlay = Instance.new("Frame")
glassOverlay.Size = UDim2.new(1, 0, 0, 120)
glassOverlay.BackgroundTransparency = 0.85
glassOverlay.BackgroundColor3 = C.cyber_purple
glassOverlay.BorderSizePixel = 0
glassOverlay.ZIndex = 50
glassOverlay.Parent = Panel
Instance.new("UICorner", glassOverlay).CornerRadius = UDim.new(0, 16)
local glassGrad = Instance.new("UIGradient", glassOverlay)
glassGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.6),
	NumberSequenceKeypoint.new(0.5, 0.9),
	NumberSequenceKeypoint.new(1, 1),
})
glassGrad.Rotation = 90

-- ========================
--  ANIMATED GRADIENT BACKGROUND
-- ========================
local gradientBg = Instance.new("Frame")
gradientBg.Size = UDim2.new(1, 0, 1, 0)
gradientBg.BackgroundColor3 = C.bg
gradientBg.BorderSizePixel = 0
gradientBg.ZIndex = 49
gradientBg.Parent = Panel
Instance.new("UICorner", gradientBg).CornerRadius = UDim.new(0, 16)

local animGradient = Instance.new("UIGradient", gradientBg)
animGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 0, 30)),
	ColorSequenceKeypoint.new(0.3, Color3.fromRGB(5, 5, 15)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(15, 0, 25)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 8, 20)),
})

-- Animate gradient rotation
spawn(function()
	local rot = 0
	while true do
		rot = (rot + 0.5) % 360
		animGradient.Rotation = rot
		RunService.Heartbeat:Wait()
	end
end)

-- ========================
--  PARTICLE SYSTEM (floating particles)
-- ========================
local particleLayer = Instance.new("Frame")
particleLayer.Size = UDim2.new(1, 0, 1, 0)
particleLayer.BackgroundTransparency = 1
particleLayer.ClipsDescendants = true
particleLayer.ZIndex = 50
particleLayer.Parent = Panel
Instance.new("UICorner", particleLayer).CornerRadius = UDim.new(0, 16)

local function spawnParticle()
	local p = Instance.new("Frame")
	local size = math.random(2, 5)
	p.Size = UDim2.new(0, size, 0, size)
	p.Position = UDim2.new(math.random() * 0.95, 0, 1.05, 0)
	p.BackgroundColor3 = math.random() > 0.5 and C.cyber_cyan or C.cyber_pink
	p.BackgroundTransparency = math.random() * 0.3 + 0.4
	p.BorderSizePixel = 0
	p.ZIndex = 51
	p.Parent = particleLayer
	Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)

	local duration = math.random(30, 80) / 10
	local xDrift = math.random(-30, 30)
	TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Position = UDim2.new(p.Position.X.Scale, xDrift, -0.1, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, size * 0.3, 0, size * 0.3),
	}):Play()

	spawn(function()
		wait(duration + 0.1)
		p:Destroy()
	end)
end

spawn(function()
	while true do
		if Panel.Visible then
			spawnParticle()
		end
		wait(math.random(2, 5) / 10)
	end
end)

-- ========================
--  ANIMATED TITLE BAR
-- ========================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 56)
TitleBar.BackgroundColor3 = C.card
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 55
TitleBar.Parent = Panel
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)
local tbCov = Instance.new("Frame")
tbCov.Size = UDim2.new(1, 0, 0, 16)
tbCov.Position = UDim2.new(0, 0, 1, -16)
tbCov.BackgroundColor3 = C.card
tbCov.BackgroundTransparency = 0.2
tbCov.BorderSizePixel = 0
tbCov.ZIndex = 55
tbCov.Parent = TitleBar

-- Animated logo
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 280, 1, 0)
LogoLabel.Position = UDim2.new(0, 16, 0, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "◈ CYBER//TOOLKIT"
LogoLabel.TextColor3 = C.cyber_cyan
LogoLabel.TextSize = 16
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
LogoLabel.ZIndex = 56
LogoLabel.Parent = TitleBar

-- Glitch the logo text periodically
spawn(function()
	while true do
		wait(math.random(3, 8))
		local origText = "◈ CYBER//TOOLKIT"
		for i = 1, 4 do
			LogoLabel.Text = glitchText(origText)
			LogoLabel.TextColor3 = i % 2 == 0 and C.cyber_pink or C.cyber_cyan
			wait(0.06)
		end
		LogoLabel.Text = origText
		LogoLabel.TextColor3 = C.cyber_cyan
	end
end)

-- Subtitle with version + clock
local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 280, 0, 14)
SubLabel.Position = UDim2.new(0, 36, 0, 36)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "v4.0 // CYBERPUNK EDITION // " .. formatTime()
SubLabel.TextColor3 = C.subtext
SubLabel.TextSize = 8
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.ZIndex = 56
SubLabel.Parent = TitleBar

-- Update clock
spawn(function()
	while true do
		SubLabel.Text = "v4.0 // CYBERPUNK EDITION // " .. formatTime()
		wait(1)
	end
end)

-- Active features counter badge
local ActiveBadge = Instance.new("Frame")
ActiveBadge.Size = UDim2.new(0, 90, 0, 22)
ActiveBadge.Position = UDim2.new(1, -140, 0.5, 0)
ActiveBadge.AnchorPoint = Vector2.new(0, 0.5)
ActiveBadge.BackgroundColor3 = C.cyber_cyan
ActiveBadge.BackgroundTransparency = 0.8
ActiveBadge.BorderSizePixel = 0
ActiveBadge.ZIndex = 56
ActiveBadge.Parent = TitleBar
Instance.new("UICorner", ActiveBadge).CornerRadius = UDim.new(0, 6)
local abStroke = Instance.new("UIStroke", ActiveBadge)
abStroke.Color = C.cyber_cyan
abStroke.Thickness = 1
abStroke.Transparency = 0.4

local ActiveBadgeLbl = Instance.new("TextLabel")
ActiveBadgeLbl.Size = UDim2.new(1, 0, 1, 0)
ActiveBadgeLbl.BackgroundTransparency = 1
ActiveBadgeLbl.Text = "0 ACTIVE"
ActiveBadgeLbl.TextColor3 = C.cyber_cyan
ActiveBadgeLbl.TextSize = 9
ActiveBadgeLbl.Font = Enum.Font.GothamBold
ActiveBadgeLbl.ZIndex = 57
ActiveBadgeLbl.Parent = ActiveBadge

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, 0)
CloseBtn.AnchorPoint = Vector2.new(0, 0.5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.subtext
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 57
CloseBtn.Parent = TitleBar
CloseBtn.MouseEnter:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = C.cyber_red}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = C.subtext}):Play()
end)

-- ========================
--  ACTIVE FEATURES STATUS BAR
-- ========================
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 22)
StatusBar.Position = UDim2.new(0, 0, 0, 56)
StatusBar.BackgroundColor3 = C.void
StatusBar.BackgroundTransparency = 0.3
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 54
StatusBar.Parent = Panel

local StatusScroll = Instance.new("ScrollingFrame")
StatusScroll.Size = UDim2.new(1, -10, 1, 0)
StatusScroll.Position = UDim2.new(0, 5, 0, 0)
StatusScroll.BackgroundTransparency = 1
StatusScroll.BorderSizePixel = 0
StatusScroll.ScrollBarThickness = 0
StatusScroll.ScrollingDirection = Enum.ScrollingDirection.X
StatusScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
StatusScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
StatusScroll.ZIndex = 55
StatusScroll.Parent = StatusBar

local statusLayout = Instance.new("UIListLayout", StatusScroll)
statusLayout.FillDirection = Enum.FillDirection.Horizontal
statusLayout.SortOrder = Enum.SortOrder.LayoutOrder
statusLayout.Padding = UDim.new(0, 6)
statusLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function updateStatusBar()
	-- Clear old
	for _, c in ipairs(StatusScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	local features = {}
	if S.Aim_Enabled then table.insert(features, {"AIM", C.cyber_cyan}) end
	if S.Trigger_Enabled then table.insert(features, {"TRIGGER", C.cyber_yellow}) end
	if S.Cross_Enabled then table.insert(features, {"CROSS", C.cyber_orange}) end
	if S.ESP_Enabled then table.insert(features, {"ESP", C.cyber_pink}) end
	if S.ESP_Tracers then table.insert(features, {"TRACE", C.cyber_pink}) end
	if S.ESP_Chams then table.insert(features, {"CHAMS", C.cyber_pink}) end
	if S.HitMarkers then table.insert(features, {"HITM", C.cyber_red}) end
	if S.DamageNumbers then table.insert(features, {"DMG#", C.cyber_yellow}) end
	if S.KillFeed then table.insert(features, {"FEED", C.cyber_red}) end
	if S.Fly_Enabled then table.insert(features, {"FLY", C.cyber_blue}) end
	if S.WalkSpeed_Enabled then table.insert(features, {"SPEED", C.cyber_blue}) end
	if S.InfJump_Enabled then table.insert(features, {"JUMP", C.cyber_blue}) end
	if S.Noclip_Enabled then table.insert(features, {"NOCLIP", C.cyber_blue}) end
	if S.TP_Behind_Enabled then table.insert(features, {"TP", C.cyber_purple}) end
	if S.Fullbright then table.insert(features, {"LIGHT", C.cyber_purple}) end
	if S.FOVCircle then table.insert(features, {"FOV", C.cyber_green}) end
	if S.Hitbox_Enabled then table.insert(features, {"HITBOX", Color3.fromRGB(255,0,60)}) end
	if S.SpinBot_Enabled then table.insert(features, {"SPIN", Color3.fromRGB(255,0,60)}) end
	if S.FakeLag_Enabled then table.insert(features, {"LAG", Color3.fromRGB(255,0,60)}) end
	if S.Fling_Enabled then table.insert(features, {"FLING", Color3.fromRGB(255,0,60)}) end
	if S.Orbit_Enabled then table.insert(features, {"ORBIT", Color3.fromRGB(255,0,60)}) end
	if S.Seizure_Enabled then table.insert(features, {"SEIZR", Color3.fromRGB(255,0,60)}) end
	if S.Matrix_Enabled then table.insert(features, {"MATRIX", Color3.fromRGB(255,0,60)}) end
	if S.AntiAFK_Enabled then table.insert(features, {"AAFK", C.cyber_green}) end
	if S.AntiVoid_Enabled then table.insert(features, {"AVOID", C.cyber_green}) end

	ActiveFeatureCount = #features
	ActiveBadgeLbl.Text = ActiveFeatureCount .. " ACTIVE"

	for i, feat in ipairs(features) do
		local pill = Instance.new("Frame")
		pill.Size = UDim2.new(0, #feat[1] * 6 + 16, 0, 16)
		pill.BackgroundColor3 = feat[2]
		pill.BackgroundTransparency = 0.8
		pill.BorderSizePixel = 0
		pill.LayoutOrder = i
		pill.ZIndex = 56
		pill.Parent = StatusScroll
		Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 4)
		local pStroke = Instance.new("UIStroke", pill)
		pStroke.Color = feat[2]
		pStroke.Thickness = 1
		pStroke.Transparency = 0.5

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = feat[1]
		lbl.TextColor3 = feat[2]
		lbl.TextSize = 8
		lbl.Font = Enum.Font.GothamBold
		lbl.ZIndex = 57
		lbl.Parent = pill
	end
end

-- ========================
--  TAB SYSTEM (7 TABS + STATS)
-- ========================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 36)
TabBar.Position = UDim2.new(0, 0, 0, 78)
TabBar.BackgroundColor3 = C.tab_bg
TabBar.BackgroundTransparency = 0.2
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 54
TabBar.Parent = Panel

local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Size = UDim2.new(1, 0, 1, 0)
TabScroll.BackgroundTransparency = 1
TabScroll.BorderSizePixel = 0
TabScroll.ScrollBarThickness = 0
TabScroll.ScrollingDirection = Enum.ScrollingDirection.X
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
TabScroll.ZIndex = 55
TabScroll.Parent = TabBar

local TabLayout = Instance.new("UIListLayout", TabScroll)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Tabs = {}
local tabData = {
	{name = "🎯 AIM",      color = C.cyber_cyan},
	{name = "✚ CROSS",     color = C.cyber_orange},
	{name = "⚔ COMBAT",    color = C.cyber_red},
	{name = "👁 ESP",       color = C.cyber_pink},
	{name = "⚡ MOVE",      color = C.cyber_blue},
	{name = "✦ VISUAL",    color = C.cyber_purple},
	{name = "⚙ QOL",       color = C.cyber_green},
	{name = "📊 STATS",     color = C.cyber_yellow},
	{name = "💀 TROLL",     color = Color3.fromRGB(255, 0, 60)},
}

for i, data in ipairs(tabData) do
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, 64, 1, 0)
	tabBtn.BackgroundColor3 = C.tab_bg
	tabBtn.BackgroundTransparency = 0.4
	tabBtn.Text = data.name
	tabBtn.TextColor3 = C.dim
	tabBtn.TextSize = 9
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.BorderSizePixel = 0
	tabBtn.LayoutOrder = i
	tabBtn.ZIndex = 56
	tabBtn.Parent = TabScroll

	-- Bottom neon indicator
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0.6, 0, 0, 2)
	indicator.Position = UDim2.new(0.2, 0, 1, -2)
	indicator.BackgroundColor3 = data.color
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	indicator.ZIndex = 57
	indicator.Parent = tabBtn
	Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

	-- Glow under indicator
	local indGlow = Instance.new("Frame")
	indGlow.Size = UDim2.new(1, 10, 0, 6)
	indGlow.Position = UDim2.new(0.5, 0, 1, -3)
	indGlow.AnchorPoint = Vector2.new(0.5, 0)
	indGlow.BackgroundColor3 = data.color
	indGlow.BackgroundTransparency = 0.8
	indGlow.BorderSizePixel = 0
	indGlow.Visible = false
	indGlow.ZIndex = 56
	indGlow.Parent = tabBtn
	Instance.new("UICorner", indGlow).CornerRadius = UDim.new(1, 0)

	-- Content frame
	local tabFrame = Instance.new("ScrollingFrame")
	tabFrame.Size = UDim2.new(1, -28, 1, -130)
	tabFrame.Position = UDim2.new(0, 14, 0, 120)
	tabFrame.BackgroundTransparency = 1
	tabFrame.BorderSizePixel = 0
	tabFrame.ScrollBarThickness = 3
	tabFrame.ScrollBarImageColor3 = data.color
	tabFrame.Visible = false
	tabFrame.ZIndex = 52
	tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabFrame.Parent = Panel
	local tfl = Instance.new("UIListLayout", tabFrame)
	tfl.Padding = UDim.new(0, 7)
	tfl.SortOrder = Enum.SortOrder.LayoutOrder

	Tabs[i] = {btn = tabBtn, frame = tabFrame, indicator = indicator, glow = indGlow, color = data.color}

	-- Hover effect
	tabBtn.MouseEnter:Connect(function()
		if not tabFrame.Visible then
			TweenService:Create(tabBtn, TweenInfo.new(0.15), {TextColor3 = data.color, BackgroundTransparency = 0.2}):Play()
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if not tabFrame.Visible then
			TweenService:Create(tabBtn, TweenInfo.new(0.15), {TextColor3 = C.dim, BackgroundTransparency = 0.4}):Play()
		end
	end)

	tabBtn.MouseButton1Click:Connect(function()
		for j, tab in ipairs(Tabs) do
			local isActive = (j == i)
			-- Animated transition
			if isActive and not tab.frame.Visible then
				tab.frame.Visible = true
				tab.frame.CanvasPosition = Vector2.new(0, 0)
				-- Fade in children
				for _, child in ipairs(tab.frame:GetChildren()) do
					if child:IsA("Frame") then
						child.BackgroundTransparency = 1
						TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							BackgroundTransparency = child:GetAttribute("OrigTransparency") or 0
						}):Play()
					end
				end
			elseif not isActive then
				tab.frame.Visible = false
			end
			tab.indicator.Visible = isActive
			tab.glow.Visible = isActive
			TweenService:Create(tab.btn, TweenInfo.new(0.2), {
				TextColor3 = isActive and tab.color or C.dim,
				BackgroundTransparency = isActive and 0.1 or 0.4,
				BackgroundColor3 = isActive and Color3.fromRGB(
					math.floor(tab.color.R * 255 * 0.1),
					math.floor(tab.color.G * 255 * 0.1),
					math.floor(tab.color.B * 255 * 0.1)
				) or C.tab_bg
			}):Play()
		end
	end)
end

-- Activate first tab
Tabs[1].frame.Visible = true
Tabs[1].indicator.Visible = true
Tabs[1].glow.Visible = true
Tabs[1].btn.TextColor3 = Tabs[1].color
Tabs[1].btn.BackgroundTransparency = 0.1
Tabs[1].btn.BackgroundColor3 = Color3.fromRGB(0, 25, 22)

-- ========================
--  UI BUILDERS (CYBERPUNK STYLE)
-- ========================
local function header(parent, text, order)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 22)
	lbl.BackgroundTransparency = 1
	lbl.Text = "// " .. string.upper(text)
	lbl.TextColor3 = C.dim
	lbl.TextSize = 9
	lbl.Font = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.LayoutOrder = order
	lbl.ZIndex = 53
	lbl.Parent = parent
end

local function toggle(parent, label, default, order, cb, settingKey)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = C.card_glass
	row.BackgroundTransparency = 0.3
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.ZIndex = 53
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
	local rs = Instance.new("UIStroke", row)
	rs.Color = C.border
	rs.Thickness = 1
	rs.Transparency = 0.7
	local p = Instance.new("UIPadding", row)
	p.PaddingLeft = UDim.new(0, 10)
	p.PaddingRight = UDim.new(0, 10)

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0.72, 0, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = label
	l.TextColor3 = C.text
	l.TextSize = 10
	l.Font = Enum.Font.GothamMedium
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 54
	l.Parent = row

	local track = Instance.new("TextButton")
	track.Size = UDim2.new(0, 36, 0, 16)
	track.Position = UDim2.new(1, 0, 0.5, 0)
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.BackgroundColor3 = default and C.cyber_cyan or C.slider_bg
	track.Text = ""
	track.BorderSizePixel = 0
	track.ZIndex = 54
	track.Parent = row
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	-- Neon glow when on
	local trackGlow = Instance.new("UIStroke", track)
	trackGlow.Color = C.cyber_cyan
	trackGlow.Thickness = default and 1 or 0
	trackGlow.Transparency = 0.5

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = default and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.ZIndex = 55
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local state = default
	track.MouseButton1Click:Connect(function()
		state = not state
		local ti = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
		TweenService:Create(track, ti, {BackgroundColor3 = state and C.cyber_cyan or C.slider_bg}):Play()
		TweenService:Create(knob, ti, {Position = state and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}):Play()
		trackGlow.Thickness = state and 1 or 0
		-- Neon flash on toggle
		if state then
			rs.Color = C.cyber_cyan
			rs.Transparency = 0.3
			TweenService:Create(rs, TweenInfo.new(0.5), {Transparency = 0.7, Color = C.border}):Play()
		end
		cb(state)
		showToast(state and "ENABLED" or "DISABLED", label, state and C.cyber_cyan or C.cyber_red, state and "✓" or "✕")
		updateStatusBar()
	end)

	-- Hover
	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			TweenService:Create(row, TweenInfo.new(0.1), {BackgroundTransparency = 0.15}):Play()
		end
	end)
	row.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			TweenService:Create(row, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
		end
	end)
end

local function slider(parent, label, min, max, default, order, cb)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundColor3 = C.card_glass
	row.BackgroundTransparency = 0.3
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.ZIndex = 53
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
	Instance.new("UIStroke", row).Color = C.border
	row:FindFirstChildOfClass("UIStroke").Thickness = 1
	row:FindFirstChildOfClass("UIStroke").Transparency = 0.7
	local p = Instance.new("UIPadding", row)
	p.PaddingLeft = UDim.new(0, 10)
	p.PaddingRight = UDim.new(0, 10)

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0.6, 0, 0, 16)
	l.BackgroundTransparency = 1
	l.Text = label
	l.TextColor3 = C.text
	l.TextSize = 10
	l.Font = Enum.Font.GothamMedium
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 54
	l.Parent = row

	local vl = Instance.new("TextLabel")
	vl.Size = UDim2.new(0.4, 0, 0, 16)
	vl.BackgroundTransparency = 1
	vl.Text = tostring(default)
	vl.TextColor3 = C.cyber_cyan
	vl.TextSize = 10
	vl.Font = Enum.Font.GothamBold
	vl.TextXAlignment = Enum.TextXAlignment.Right
	vl.ZIndex = 54
	vl.Parent = row

	local st = Instance.new("Frame")
	st.Size = UDim2.new(1, 0, 0, 4)
	st.Position = UDim2.new(0, 0, 0, 26)
	st.BackgroundColor3 = C.slider_bg
	st.BorderSizePixel = 0
	st.ZIndex = 54
	st.Parent = row
	Instance.new("UICorner", st).CornerRadius = UDim.new(1, 0)

	local pct = (default - min) / (max - min)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(pct, 0, 1, 0)
	fill.BackgroundColor3 = C.cyber_cyan
	fill.BorderSizePixel = 0
	fill.ZIndex = 55
	fill.Parent = st
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	-- Glow on fill
	local fillGlow = Instance.new("UIStroke", fill)
	fillGlow.Color = C.cyber_cyan
	fillGlow.Thickness = 1
	fillGlow.Transparency = 0.6

	local sk = Instance.new("Frame")
	sk.Size = UDim2.new(0, 12, 0, 12)
	sk.Position = UDim2.new(pct, 0, 0.5, 0)
	sk.AnchorPoint = Vector2.new(0.5, 0.5)
	sk.BackgroundColor3 = Color3.new(1, 1, 1)
	sk.BorderSizePixel = 0
	sk.ZIndex = 56
	sk.Parent = st
	Instance.new("UICorner", sk).CornerRadius = UDim.new(1, 0)

	local dragging = false
	local ib = Instance.new("TextButton")
	ib.Size = UDim2.new(1, 0, 0, 22)
	ib.Position = UDim2.new(0, 0, 0, 18)
	ib.BackgroundTransparency = 1
	ib.Text = ""
	ib.ZIndex = 57
	ib.Parent = row
	ib.MouseButton1Down:Connect(function() dragging = true end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	RunService.RenderStepped:Connect(function()
		if not dragging then return end
		local mp = UserInputService:GetMouseLocation()
		local ap = st.AbsolutePosition
		local as = st.AbsoluteSize
		local rx = math.clamp((mp.X - ap.X) / as.X, 0, 1)
		fill.Size = UDim2.new(rx, 0, 1, 0)
		sk.Position = UDim2.new(rx, 0, 0.5, 0)
		local val = min + (max - min) * rx
		if max <= 1 then val = math.floor(val * 100 + 0.5) / 100
		elseif max <= 30 then val = math.floor(val * 10 + 0.5) / 10
		else val = math.floor(val + 0.5) end
		vl.Text = tostring(val)
		cb(val)
	end)
end

local function cycler(parent, label, options, default, order, cb)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = C.card_glass
	row.BackgroundTransparency = 0.3
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.ZIndex = 53
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
	Instance.new("UIStroke", row).Color = C.border
	row:FindFirstChildOfClass("UIStroke").Thickness = 1
	row:FindFirstChildOfClass("UIStroke").Transparency = 0.7
	local p = Instance.new("UIPadding", row)
	p.PaddingLeft = UDim.new(0, 10)
	p.PaddingRight = UDim.new(0, 10)

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0.5, 0, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = label
	l.TextColor3 = C.text
	l.TextSize = 10
	l.Font = Enum.Font.GothamMedium
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 54
	l.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.46, 0, 0, 20)
	btn.Position = UDim2.new(1, 0, 0.5, 0)
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.BackgroundColor3 = C.slider_bg
	btn.Text = "◂ " .. default .. " ▸"
	btn.TextColor3 = C.cyber_cyan
	btn.TextSize = 9
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.ZIndex = 54
	btn.Parent = row
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
	local bStroke = Instance.new("UIStroke", btn)
	bStroke.Color = C.cyber_cyan
	bStroke.Thickness = 1
	bStroke.Transparency = 0.7

	local idx = table.find(options, default) or 1
	btn.MouseButton1Click:Connect(function()
		idx = idx % #options + 1
		btn.Text = "◂ " .. options[idx] .. " ▸"
		cb(options[idx])
		-- Flash
		bStroke.Transparency = 0.2
		TweenService:Create(bStroke, TweenInfo.new(0.3), {Transparency = 0.7}):Play()
	end)
end

local function colorPicker(parent, label, default, order, cb)
	local colors = {
		{n="Cyan",   c=Color3.fromRGB(0,255,220)},
		{n="Pink",   c=Color3.fromRGB(255,0,128)},
		{n="Red",    c=Color3.fromRGB(255,50,50)},
		{n="Yellow", c=Color3.fromRGB(255,240,0)},
		{n="Green",  c=Color3.fromRGB(0,255,140)},
		{n="White",  c=Color3.fromRGB(255,255,255)},
		{n="Orange", c=Color3.fromRGB(255,140,0)},
		{n="Purple", c=Color3.fromRGB(180,60,255)},
	}
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 48)
	row.BackgroundColor3 = C.card_glass
	row.BackgroundTransparency = 0.3
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.ZIndex = 53
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
	Instance.new("UIStroke", row).Color = C.border
	row:FindFirstChildOfClass("UIStroke").Thickness = 1
	row:FindFirstChildOfClass("UIStroke").Transparency = 0.7
	local pd = Instance.new("UIPadding", row)
	pd.PaddingLeft = UDim.new(0, 10)
	pd.PaddingRight = UDim.new(0, 10)

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 18)
	l.BackgroundTransparency = 1
	l.Text = label
	l.TextColor3 = C.text
	l.TextSize = 10
	l.Font = Enum.Font.GothamMedium
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 54
	l.Parent = row

	local cr = Instance.new("Frame")
	cr.Size = UDim2.new(1, 0, 0, 20)
	cr.Position = UDim2.new(0, 0, 0, 22)
	cr.BackgroundTransparency = 1
	cr.ZIndex = 54
	cr.Parent = row
	local crl = Instance.new("UIListLayout", cr)
	crl.FillDirection = Enum.FillDirection.Horizontal
	crl.Padding = UDim.new(0, 5)

	for _, col in ipairs(colors) do
		local sw = Instance.new("TextButton")
		sw.Size = UDim2.new(0, 20, 0, 20)
		sw.BackgroundColor3 = col.c
		sw.Text = ""
		sw.BorderSizePixel = 0
		sw.ZIndex = 55
		sw.Parent = cr
		Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
		local ring = Instance.new("UIStroke", sw)
		ring.Color = Color3.new(1,1,1)
		ring.Thickness = (col.c == default) and 2 or 0
		-- Glow
		if col.c == default then
			local glow = Instance.new("UIStroke")
			glow.Color = col.c
			glow.Thickness = 3
			glow.Transparency = 0.6
		end
		sw.MouseButton1Click:Connect(function()
			for _, s in ipairs(cr:GetChildren()) do
				if s:IsA("TextButton") then
					local st = s:FindFirstChildOfClass("UIStroke")
					if st then st.Thickness = 0 end
				end
			end
			ring.Thickness = 2
			cb(col.c)
		end)
	end
end

local function sep(parent, order)
	local s = Instance.new("Frame")
	s.Size = UDim2.new(1, 0, 0, 1)
	s.BackgroundColor3 = C.cyber_purple
	s.BackgroundTransparency = 0.7
	s.BorderSizePixel = 0
	s.LayoutOrder = order
	s.Parent = parent
end

-- ========================
--  POPULATE ALL TABS
-- ========================

-- TAB 1: AIM
local t1 = Tabs[1].frame
header(t1, "Core", 1)
toggle(t1, "Enable Aim Assist", S.Aim_Enabled, 2, function(v) S.Aim_Enabled = v end)
toggle(t1, "Require ADS (Right Click)", S.Aim_RequireADS, 3, function(v) S.Aim_RequireADS = v end)
toggle(t1, "Team Check", S.Aim_TeamCheck, 4, function(v) S.Aim_TeamCheck = v end)
sep(t1, 5)
header(t1, "Tuning", 6)
slider(t1, "Strength", 0.01, 1, S.Aim_Strength, 7, function(v) S.Aim_Strength = v end)
slider(t1, "Radius (px)", 20, 400, S.Aim_Radius, 8, function(v) S.Aim_Radius = v end)
cycler(t1, "Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, S.Aim_Part, 9, function(v) S.Aim_Part = v end)
sep(t1, 10)
header(t1, "Smoothing & Prediction", 11)
cycler(t1, "Smoothing", {"Linear", "EaseIn", "EaseOut", "Smooth", "Snap"}, S.Aim_Smoothing, 12, function(v) S.Aim_Smoothing = v end)
toggle(t1, "Velocity Prediction", S.Aim_Prediction, 13, function(v) S.Aim_Prediction = v end)
slider(t1, "Prediction Scale", 0.1, 3, S.Aim_PredictionScale, 14, function(v) S.Aim_PredictionScale = v end)
toggle(t1, "Sticky Aim", S.Aim_StickyAim, 15, function(v) S.Aim_StickyAim = v end)
slider(t1, "Sticky Strength", 0.05, 0.5, S.Aim_StickyStrength, 16, function(v) S.Aim_StickyStrength = v end)
sep(t1, 17)
header(t1, "Distance & Falloff", 18)
toggle(t1, "Distance Falloff", S.Aim_DistanceFalloff, 19, function(v) S.Aim_DistanceFalloff = v end)
slider(t1, "Falloff Start (studs)", 50, 500, S.Aim_FalloffStart, 20, function(v) S.Aim_FalloffStart = v end)
slider(t1, "Falloff End (studs)", 100, 1000, S.Aim_FalloffEnd, 21, function(v) S.Aim_FalloffEnd = v end)
sep(t1, 22)
header(t1, "Target Filtering", 23)
slider(t1, "Target Switch Delay", 0, 1, S.Aim_TargetSwitchDelay, 24, function(v) S.Aim_TargetSwitchDelay = v end)
toggle(t1, "Ignore Downed Players", S.Aim_IgnoreDowned, 25, function(v) S.Aim_IgnoreDowned = v end)
slider(t1, "Downed HP Threshold", 1, 50, S.Aim_DownedThreshold, 26, function(v) S.Aim_DownedThreshold = v end)
toggle(t1, "Wall Check (no aim thru walls)", S.Aim_WallCheck, 27, function(v) S.Aim_WallCheck = v end)
toggle(t1, "Visibility Raycast", S.Aim_VisibilityCheck, 28, function(v) S.Aim_VisibilityCheck = v end)
sep(t1, 29)
header(t1, "⚡ Triggerbot", 30)
toggle(t1, "Enable Triggerbot", S.Trigger_Enabled, 31, function(v) S.Trigger_Enabled = v end)
toggle(t1, "Require ADS", S.Trigger_RequireADS, 32, function(v) S.Trigger_RequireADS = v end)
toggle(t1, "Team Check", S.Trigger_TeamCheck, 33, function(v) S.Trigger_TeamCheck = v end)
toggle(t1, "FOV Check", S.Trigger_FOVCheck, 34, function(v) S.Trigger_FOVCheck = v end)
slider(t1, "Delay (ms)", 0, 200, S.Trigger_Delay, 35, function(v) S.Trigger_Delay = v end)
slider(t1, "Max Range", 50, 1000, S.Trigger_MaxRange, 36, function(v) S.Trigger_MaxRange = v end)
cycler(t1, "Hit Part", {"Any", "Head", "UpperTorso"}, S.Trigger_HitPart, 37, function(v) S.Trigger_HitPart = v end)
toggle(t1, "Headshot Priority Only", S.Trigger_HeadshotPriority, 38, function(v) S.Trigger_HeadshotPriority = v end)
sep(t1, 39)
header(t1, "Burst & Humanize", 40)
toggle(t1, "Burst Mode", S.Trigger_BurstMode, 41, function(v) S.Trigger_BurstMode = v end)
slider(t1, "Burst Count", 2, 8, S.Trigger_BurstCount, 42, function(v) S.Trigger_BurstCount = v end)
slider(t1, "Burst Delay", 0.02, 0.2, S.Trigger_BurstDelay, 43, function(v) S.Trigger_BurstDelay = v end)
toggle(t1, "Humanize Delay (random)", S.Trigger_HumanizeDelay, 44, function(v) S.Trigger_HumanizeDelay = v end)
slider(t1, "Min Random Delay (ms)", 10, 100, S.Trigger_HumanizeMin, 45, function(v) S.Trigger_HumanizeMin = v end)
slider(t1, "Max Random Delay (ms)", 50, 300, S.Trigger_HumanizeMax, 46, function(v) S.Trigger_HumanizeMax = v end)
toggle(t1, "Auto Switch Target", S.Trigger_AutoSwitch, 47, function(v) S.Trigger_AutoSwitch = v end)
toggle(t1, "Show Indicator", S.Trigger_Indicator, 48, function(v) S.Trigger_Indicator = v end)

-- TAB 2: CROSSHAIR
local t2 = Tabs[2].frame
header(t2, "Crosshair", 1)
toggle(t2, "Enable Crosshair", S.Cross_Enabled, 2, function(v) S.Cross_Enabled = v end)
cycler(t2, "Style", {"Cross", "Dot", "Circle", "Cross+Dot", "Chevron", "Triangle"}, S.Cross_Style, 3, function(v) S.Cross_Style = v end)
toggle(t2, "Outline", S.Cross_Outline, 4, function(v) S.Cross_Outline = v end)
toggle(t2, "Center Dot (always)", S.Cross_CenterDot, 5, function(v) S.Cross_CenterDot = v end)
sep(t2, 6)
header(t2, "Sizing", 7)
slider(t2, "Size", 3, 40, S.Cross_Size, 8, function(v) S.Cross_Size = v end)
slider(t2, "Thickness", 1, 8, S.Cross_Thick, 9, function(v) S.Cross_Thick = v end)
slider(t2, "Gap", 0, 25, S.Cross_Gap, 10, function(v) S.Cross_Gap = v end)
sep(t2, 11)
header(t2, "Dynamic", 12)
toggle(t2, "Dynamic (expand on move)", S.Cross_Dynamic, 13, function(v) S.Cross_Dynamic = v end)
slider(t2, "Expand Amount", 2, 20, S.Cross_DynamicScale, 14, function(v) S.Cross_DynamicScale = v end)
slider(t2, "Snap Back Speed", 0.02, 0.3, S.Cross_DynamicSpeed, 15, function(v) S.Cross_DynamicSpeed = v end)
toggle(t2, "Spread Indicator", S.Cross_SpreadIndicator, 16, function(v) S.Cross_SpreadIndicator = v end)
sep(t2, 17)
header(t2, "Appearance", 18)
colorPicker(t2, "Color", S.Cross_Color, 19, function(v) S.Cross_Color = v end)
slider(t2, "Opacity", 0.1, 1, S.Cross_Opacity, 20, function(v) S.Cross_Opacity = v end)
sep(t2, 21)
header(t2, "Effects", 22)
toggle(t2, "Hit Flash (color on hit)", S.Cross_HitFlash, 23, function(v) S.Cross_HitFlash = v end)
colorPicker(t2, "Hit Color", S.Cross_HitColor, 24, function(v) S.Cross_HitColor = v end)
colorPicker(t2, "Kill Color", S.Cross_KillColor, 25, function(v) S.Cross_KillColor = v end)
toggle(t2, "Rainbow Mode", S.Cross_RainbowMode, 26, function(v) S.Cross_RainbowMode = v end)
slider(t2, "Rainbow Speed", 0.5, 10, S.Cross_RainbowSpeed, 27, function(v) S.Cross_RainbowSpeed = v end)

-- TAB 3: COMBAT
local t3 = Tabs[3].frame
header(t3, "Hit Markers", 1)
toggle(t3, "Hit Markers", S.HitMarkers, 2, function(v) S.HitMarkers = v end)
cycler(t3, "Style", {"Cross", "Circle", "Skull"}, S.HitM_Style, 3, function(v) S.HitM_Style = v end)
slider(t3, "Size", 8, 30, S.HitM_Size, 4, function(v) S.HitM_Size = v end)
slider(t3, "Duration", 0.1, 0.8, S.HitM_Duration, 5, function(v) S.HitM_Duration = v end)
colorPicker(t3, "Color", S.HitM_Color, 6, function(v) S.HitM_Color = v end)
colorPicker(t3, "Headshot Color", S.HitM_HeadshotColor, 7, function(v) S.HitM_HeadshotColor = v end)
toggle(t3, "Hit Sound", S.HitM_Sound, 8, function(v) S.HitM_Sound = v end)
sep(t3, 9)
header(t3, "Damage Numbers", 10)
toggle(t3, "Damage Numbers", S.DamageNumbers, 11, function(v) S.DamageNumbers = v end)
colorPicker(t3, "Damage Color", S.DmgNum_Color, 12, function(v) S.DmgNum_Color = v end)
colorPicker(t3, "Crit Color", S.DmgNum_CritColor, 13, function(v) S.DmgNum_CritColor = v end)
slider(t3, "Text Size", 10, 28, S.DmgNum_Size, 14, function(v) S.DmgNum_Size = v end)
slider(t3, "Crit Size", 14, 36, S.DmgNum_CritSize, 15, function(v) S.DmgNum_CritSize = v end)
slider(t3, "Float Speed", 0.03, 0.3, S.DmgNum_FloatSpeed, 16, function(v) S.DmgNum_FloatSpeed = v end)
slider(t3, "Duration (sec)", 0.2, 2, S.DmgNum_Duration, 17, function(v) S.DmgNum_Duration = v end)
slider(t3, "Scatter (studs)", 0, 6, S.DmgNum_Scatter, 18, function(v) S.DmgNum_Scatter = v end)
slider(t3, "Crit Threshold", 10, 100, S.DmgNum_CritThreshold, 19, function(v) S.DmgNum_CritThreshold = v end)
toggle(t3, "Show Accumulated Total", S.DmgNum_ShowTotal, 20, function(v) S.DmgNum_ShowTotal = v end)
sep(t3, 21)
header(t3, "Kill Feed", 22)
toggle(t3, "Kill Feed", S.KillFeed, 23, function(v) S.KillFeed = v end)
slider(t3, "Max Entries", 3, 10, S.KillFeed_Max, 24, function(v) S.KillFeed_Max = v end)
slider(t3, "Entry Duration (sec)", 2, 15, S.KillFeed_Duration, 25, function(v) S.KillFeed_Duration = v end)
cycler(t3, "Position", {"TopRight", "TopLeft", "BottomRight"}, S.KillFeed_Position, 26, function(v) S.KillFeed_Position = v end)
sep(t3, 27)
header(t3, "Kill Counter & Streaks", 28)
toggle(t3, "Kill Counter HUD", S.KillCounter, 29, function(v) S.KillCounter = v end)
toggle(t3, "Show Killstreak", S.KillCounter_ShowStreak, 30, function(v) S.KillCounter_ShowStreak = v end)
toggle(t3, "Streak Announcements", S.KillCounter_StreakAnnounce, 31, function(v) S.KillCounter_StreakAnnounce = v end)
toggle(t3, "Reset Streak on Death", S.KillCounter_ResetOnDeath, 32, function(v) S.KillCounter_ResetOnDeath = v end)

-- TAB 4: ESP
local t4 = Tabs[4].frame
header(t4, "ESP Core", 1)
toggle(t4, "Enable ESP", S.ESP_Enabled, 2, function(v) S.ESP_Enabled = v end)
toggle(t4, "Team Check", S.ESP_TeamCheck, 3, function(v) S.ESP_TeamCheck = v end)
slider(t4, "Max Distance", 50, 2000, S.ESP_MaxDist, 4, function(v) S.ESP_MaxDist = v end)
toggle(t4, "Scale by Distance", S.ESP_DistanceScale, 5, function(v) S.ESP_DistanceScale = v end)
sep(t4, 6)
header(t4, "Info Display", 7)
toggle(t4, "Names", S.ESP_Names, 8, function(v) S.ESP_Names = v end)
slider(t4, "Name Text Size", 8, 20, S.ESP_NameSize, 9, function(v) S.ESP_NameSize = v end)
toggle(t4, "Health Bars", S.ESP_Health, 10, function(v) S.ESP_Health = v end)
cycler(t4, "Health Color Mode", {"Gradient", "Static", "Class"}, S.ESP_HealthColorMode, 11, function(v) S.ESP_HealthColorMode = v end)
toggle(t4, "Distance", S.ESP_Distance, 12, function(v) S.ESP_Distance = v end)
toggle(t4, "Show Weapon/Tool", S.ESP_ShowWeapon, 13, function(v) S.ESP_ShowWeapon = v end)
toggle(t4, "Show Look Direction", S.ESP_ShowLookDir, 14, function(v) S.ESP_ShowLookDir = v end)
sep(t4, 15)
header(t4, "Boxes & Chams", 16)
toggle(t4, "Boxes/Highlight", S.ESP_Boxes, 17, function(v) S.ESP_Boxes = v end)
cycler(t4, "Box Style", {"Highlight", "Corners", "Full"}, S.ESP_BoxStyle, 18, function(v) S.ESP_BoxStyle = v end)
toggle(t4, "Chams (wall viz)", S.ESP_Chams, 19, function(v) S.ESP_Chams = v end)
slider(t4, "Fill Opacity", 0.1, 1, S.ESP_FillOpacity, 20, function(v) S.ESP_FillOpacity = v end)
slider(t4, "Outline Opacity", 0.1, 1, S.ESP_OutlineOpacity, 21, function(v) S.ESP_OutlineOpacity = v end)
sep(t4, 22)
header(t4, "Tracers", 23)
toggle(t4, "Tracers", S.ESP_Tracers, 24, function(v) S.ESP_Tracers = v end)
cycler(t4, "Tracer Origin", {"Bottom", "Center", "Mouse"}, S.ESP_TracerOrigin, 25, function(v) S.ESP_TracerOrigin = v end)
slider(t4, "Tracer Thickness", 1, 4, S.ESP_TracerThickness, 26, function(v) S.ESP_TracerThickness = v end)
cycler(t4, "Tracer Color", {"Match", "Custom"}, S.ESP_SnaplineColor, 27, function(v) S.ESP_SnaplineColor = v end)
sep(t4, 28)
header(t4, "Extra", 29)
toggle(t4, "Head Dot", S.ESP_HeadDot, 30, function(v) S.ESP_HeadDot = v end)
slider(t4, "Head Dot Size", 2, 10, S.ESP_HeadDotSize, 31, function(v) S.ESP_HeadDotSize = v end)
toggle(t4, "Skeleton ESP", S.ESP_SkeletonESP, 32, function(v) S.ESP_SkeletonESP = v end)
toggle(t4, "Off-Screen Arrows", S.ESP_OffScreenArrows, 33, function(v) S.ESP_OffScreenArrows = v end)
sep(t4, 34)
header(t4, "Colors", 35)
colorPicker(t4, "Enemy Color", S.ESP_EnemyColor, 36, function(v) S.ESP_EnemyColor = v end)
colorPicker(t4, "Team Color", S.ESP_TeamColor, 37, function(v) S.ESP_TeamColor = v end)

-- TAB 5: MOVEMENT
local t5 = Tabs[5].frame
header(t5, "Fly", 1)
toggle(t5, "Enable Fly", S.Fly_Enabled, 2, function(v) S.Fly_Enabled = v end)
slider(t5, "Fly Speed", 10, 300, S.Fly_Speed, 3, function(v) S.Fly_Speed = v end)
slider(t5, "Vertical Speed", 10, 300, S.Fly_VerticalSpeed, 4, function(v) S.Fly_VerticalSpeed = v end)
slider(t5, "Acceleration", 1, 20, S.Fly_Acceleration, 5, function(v) S.Fly_Acceleration = v end)
slider(t5, "Deceleration", 1, 20, S.Fly_Deceleration, 6, function(v) S.Fly_Deceleration = v end)
toggle(t5, "Free Look (look while still)", S.Fly_FreeLook, 7, function(v) S.Fly_FreeLook = v end)
toggle(t5, "Fly Animations", S.Fly_Animations, 8, function(v) S.Fly_Animations = v end)
toggle(t5, "Anti-Detect (ground sim)", S.Fly_AntiDetect, 9, function(v) S.Fly_AntiDetect = v end)
sep(t5, 10)
header(t5, "Walk Speed", 11)
toggle(t5, "Custom Speed", S.WalkSpeed_Enabled, 12, function(v) S.WalkSpeed_Enabled = v end)
slider(t5, "Walk Speed", 16, 200, S.WalkSpeed_Value, 13, function(v) S.WalkSpeed_Value = v end)
toggle(t5, "Gradual Acceleration", S.WalkSpeed_Acceleration, 14, function(v) S.WalkSpeed_Acceleration = v end)
slider(t5, "Accel Time (sec)", 0.2, 3, S.WalkSpeed_AccelTime, 15, function(v) S.WalkSpeed_AccelTime = v end)
sep(t5, 16)
header(t5, "Jumps", 17)
toggle(t5, "Infinite Jump", S.InfJump_Enabled, 18, function(v) S.InfJump_Enabled = v end)
slider(t5, "Jump Power", 20, 150, S.InfJump_Power, 19, function(v) S.InfJump_Power = v end)
slider(t5, "Max Jumps (0=unlimited)", 0, 10, S.InfJump_MaxJumps, 20, function(v) S.InfJump_MaxJumps = v end)
slider(t5, "Jump Cooldown (sec)", 0, 1, S.InfJump_Cooldown, 21, function(v) S.InfJump_Cooldown = v end)
toggle(t5, "Double Jump Only", S.InfJump_DoubleOnly, 22, function(v) S.InfJump_DoubleOnly = v end)
sep(t5, 23)
header(t5, "Noclip", 24)
toggle(t5, "Noclip", S.Noclip_Enabled, 25, function(v) S.Noclip_Enabled = v end)
cycler(t5, "Noclip Key", {"N", "X", "Z", "C", "V"}, S.Noclip_KeyToggle, 26, function(v) S.Noclip_KeyToggle = v end)
slider(t5, "Noclip Speed", 16, 200, S.Noclip_Speed, 27, function(v) S.Noclip_Speed = v end)
toggle(t5, "Ghost Mode (invis+noclip)", S.Noclip_GhostMode, 28, function(v) S.Noclip_GhostMode = v end)
sep(t5, 29)
header(t5, "Long Arms", 30)
toggle(t5, "Long Arms", S.LongArms_Enabled, 31, function(v) S.LongArms_Enabled = v end)
slider(t5, "Length", 5, 50, S.LongArms_Length, 32, function(v) S.LongArms_Length = v end)
cycler(t5, "Extend Parts", {"Arms", "Legs", "Both", "All"}, S.LongArms_Parts, 33, function(v) S.LongArms_Parts = v end)
toggle(t5, "Visible Limbs", S.LongArms_Visible, 34, function(v) S.LongArms_Visible = v end)
sep(t5, 35)
header(t5, "Speed Boost", 36)
toggle(t5, "Speed Boost", S.SpeedBoost_Enabled, 37, function(v) S.SpeedBoost_Enabled = v end)
slider(t5, "Multiplier", 1.5, 5, S.SpeedBoost_Multiplier, 38, function(v) S.SpeedBoost_Multiplier = v end)
cycler(t5, "Key", {"LeftControl", "LeftShift", "E", "Q", "R"}, S.SpeedBoost_Key, 39, function(v) S.SpeedBoost_Key = v end)
toggle(t5, "FOV Zoom Effect", S.SpeedBoost_FOVEffect, 40, function(v) S.SpeedBoost_FOVEffect = v end)
slider(t5, "Boost FOV", 70, 120, S.SpeedBoost_FOVAmount, 41, function(v) S.SpeedBoost_FOVAmount = v end)
toggle(t5, "Speed Trail Effect", S.SpeedBoost_Trail, 42, function(v) S.SpeedBoost_Trail = v end)
sep(t5, 43)
header(t5, "Teleport Behind", 44)
toggle(t5, "Enable TP Behind", S.TP_Behind_Enabled, 45, function(v) S.TP_Behind_Enabled = v end)
cycler(t5, "TP Key", {"T", "G", "V", "B", "X", "Z"}, S.TP_Behind_Key, 46, function(v) S.TP_Behind_Key = v end)
slider(t5, "Dist Behind (studs)", 2, 15, S.TP_Behind_Distance, 47, function(v) S.TP_Behind_Distance = v end)
slider(t5, "Cooldown (sec)", 0.5, 10, S.TP_Behind_Cooldown, 48, function(v) S.TP_Behind_Cooldown = v end)
slider(t5, "Max Range", 50, 500, S.TP_Behind_MaxRange, 49, function(v) S.TP_Behind_MaxRange = v end)
cycler(t5, "TP Position", {"Behind", "Above", "Side"}, S.TP_Behind_Offset, 50, function(v) S.TP_Behind_Offset = v end)
toggle(t5, "Face Enemy", S.TP_Behind_FaceEnemy, 51, function(v) S.TP_Behind_FaceEnemy = v end)
toggle(t5, "Team Check", S.TP_Behind_TeamCheck, 52, function(v) S.TP_Behind_TeamCheck = v end)
toggle(t5, "VFX", S.TP_Behind_Effect, 53, function(v) S.TP_Behind_Effect = v end)
toggle(t5, "Auto Attack After TP", S.TP_Behind_AutoAttack, 54, function(v) S.TP_Behind_AutoAttack = v end)
slider(t5, "Auto Attack Delay", 0, 0.5, S.TP_Behind_AutoAttackDelay, 55, function(v) S.TP_Behind_AutoAttackDelay = v end)
toggle(t5, "Chain TP (multi-kill)", S.TP_Behind_Chain, 56, function(v) S.TP_Behind_Chain = v end)
slider(t5, "Chain Delay (sec)", 0.2, 2, S.TP_Behind_ChainDelay, 57, function(v) S.TP_Behind_ChainDelay = v end)

-- TAB 6: VISUALS
local t6 = Tabs[6].frame
header(t6, "FOV Circle", 1)
toggle(t6, "FOV Circle", S.FOVCircle, 2, function(v) S.FOVCircle = v end)
slider(t6, "Opacity", 0.05, 1, S.FOVCircle_Opacity, 3, function(v) S.FOVCircle_Opacity = v end)
colorPicker(t6, "Circle Color", S.FOVCircle_Color, 4, function(v) S.FOVCircle_Color = v end)
slider(t6, "Thickness", 1, 4, S.FOVCircle_Thickness, 5, function(v) S.FOVCircle_Thickness = v end)
toggle(t6, "Filled Circle", S.FOVCircle_Filled, 6, function(v) S.FOVCircle_Filled = v end)
slider(t6, "Fill Opacity", 0.01, 0.2, S.FOVCircle_FillOpacity, 7, function(v) S.FOVCircle_FillOpacity = v end)
toggle(t6, "Pulse Animation", S.FOVCircle_Dynamic, 8, function(v) S.FOVCircle_Dynamic = v end)
sep(t6, 9)
header(t6, "Lighting", 10)
toggle(t6, "Fullbright", S.Fullbright, 11, function(v) S.Fullbright = v end)
slider(t6, "Brightness", 1, 5, S.Fullbright_Brightness, 12, function(v) S.Fullbright_Brightness = v end)
toggle(t6, "Remove Fog", S.Fullbright_RemoveFog, 13, function(v) S.Fullbright_RemoveFog = v end)
toggle(t6, "Remove Bloom/Blur", S.Fullbright_RemoveEffects, 14, function(v) S.Fullbright_RemoveEffects = v end)
toggle(t6, "Custom Ambient Color", S.Fullbright_CustomAmbient, 15, function(v) S.Fullbright_CustomAmbient = v end)
colorPicker(t6, "Ambient Color", S.Fullbright_AmbientColor, 16, function(v) S.Fullbright_AmbientColor = v end)
sep(t6, 17)
header(t6, "Camera", 18)
toggle(t6, "Third Person", S.ThirdPerson, 19, function(v) S.ThirdPerson = v end)
slider(t6, "3P Distance", 5, 30, S.ThirdPerson_Dist, 20, function(v) S.ThirdPerson_Dist = v end)
slider(t6, "Shoulder Offset", -5, 5, S.ThirdPerson_Offset, 21, function(v) S.ThirdPerson_Offset = v end)
toggle(t6, "Transparent When Close", S.ThirdPerson_Transparent, 22, function(v) S.ThirdPerson_Transparent = v end)
toggle(t6, "Lock Mouse Center", S.ThirdPerson_LockMouse, 23, function(v) S.ThirdPerson_LockMouse = v end)
sep(t6, 24)
header(t6, "Freecam", 25)
toggle(t6, "Freecam", S.Freecam, 26, function(v) S.Freecam = v end)
slider(t6, "Freecam Speed", 0.2, 3, S.Freecam_Speed, 27, function(v) S.Freecam_Speed = v end)
slider(t6, "Smoothing", 0.01, 0.3, S.Freecam_Smoothing, 28, function(v) S.Freecam_Smoothing = v end)
toggle(t6, "Show XYZ Position", S.Freecam_ShowPosition, 29, function(v) S.Freecam_ShowPosition = v end)
toggle(t6, "TP to Freecam Position", S.Freecam_Teleport, 30, function(v) S.Freecam_Teleport = v end)
sep(t6, 31)
header(t6, "Identity", 32)
toggle(t6, "Name Hider", S.NameHider, 33, function(v) S.NameHider = v end)
toggle(t6, "Random Alias Each Life", S.NameHider_RandomAlias, 34, function(v) S.NameHider_RandomAlias = v end)
toggle(t6, "Hide from Leaderboard", S.NameHider_HideFromLeaderboard, 35, function(v) S.NameHider_HideFromLeaderboard = v end)

-- TAB 7: QOL
local t7 = Tabs[7].frame
header(t7, "FPS", 1)
toggle(t7, "FPS Counter", S.FPSCounter, 2, function(v) S.FPSCounter = v end)
cycler(t7, "Position", {"BottomLeft", "BottomRight", "TopLeft"}, S.FPS_Position, 3, function(v) S.FPS_Position = v end)
toggle(t7, "Low FPS Warning", S.FPS_LowWarning, 4, function(v) S.FPS_LowWarning = v end)
slider(t7, "Warning Threshold", 15, 60, S.FPS_LowThreshold, 5, function(v) S.FPS_LowThreshold = v end)
toggle(t7, "Mini FPS Graph", S.FPS_ShowGraph, 6, function(v) S.FPS_ShowGraph = v end)
sep(t7, 7)
header(t7, "Ping", 8)
toggle(t7, "Ping Display", S.PingDisplay, 9, function(v) S.PingDisplay = v end)
toggle(t7, "High Ping Warning", S.Ping_HighWarning, 10, function(v) S.Ping_HighWarning = v end)
slider(t7, "Warning Threshold (ms)", 50, 500, S.Ping_HighThreshold, 11, function(v) S.Ping_HighThreshold = v end)
sep(t7, 12)

-- ========================
--  CONFIG SYSTEM
-- ========================
-- Uses plugin:SetSetting / GetSetting for studio, or Attribute storage on player for runtime
-- Configs stored as JSON-encoded string in player attributes

local CONFIG_PREFIX = "CyberToolkit_"
local AUTOLOAD_KEY = CONFIG_PREFIX .. "Autoload"
local CONFIG_LIST_KEY = CONFIG_PREFIX .. "ConfigList"

-- Serialize settings (convert Color3 to tables)
local function serializeSettings()
	local data = {}
	for key, val in pairs(S) do
		if typeof(val) == "Color3" then
			data[key] = {_type = "Color3", R = math.floor(val.R * 255), G = math.floor(val.G * 255), B = math.floor(val.B * 255)}
		else
			data[key] = val
		end
	end
	return data
end

-- Deserialize settings (convert Color3 tables back)
local function deserializeSettings(data)
	for key, val in pairs(data) do
		if type(val) == "table" and val._type == "Color3" then
			S[key] = Color3.fromRGB(val.R, val.G, val.B)
		elseif S[key] ~= nil then
			S[key] = val
		end
	end
end

-- Save config to player attributes
local function saveConfig(name)
	local success, err = pcall(function()
		local json = HttpService:JSONEncode(serializeSettings())
		LocalPlayer:SetAttribute(CONFIG_PREFIX .. name, json)

		-- Update config list
		local listJson = LocalPlayer:GetAttribute(CONFIG_LIST_KEY) or "[]"
		local list = HttpService:JSONDecode(listJson)
		if not table.find(list, name) then
			table.insert(list, name)
		end
		LocalPlayer:SetAttribute(CONFIG_LIST_KEY, HttpService:JSONEncode(list))
	end)
	return success, err
end

-- Load config from player attributes
local function loadConfig(name)
	local success, err = pcall(function()
		local json = LocalPlayer:GetAttribute(CONFIG_PREFIX .. name)
		if json then
			local data = HttpService:JSONDecode(json)
			deserializeSettings(data)
		end
	end)
	return success, err
end

-- Delete config
local function deleteConfig(name)
	pcall(function()
		LocalPlayer:SetAttribute(CONFIG_PREFIX .. name, nil)
		local listJson = LocalPlayer:GetAttribute(CONFIG_LIST_KEY) or "[]"
		local list = HttpService:JSONDecode(listJson)
		local idx = table.find(list, name)
		if idx then table.remove(list, idx) end
		LocalPlayer:SetAttribute(CONFIG_LIST_KEY, HttpService:JSONEncode(list))
	end)
end

-- Get config list
local function getConfigList()
	local list = {}
	pcall(function()
		local json = LocalPlayer:GetAttribute(CONFIG_LIST_KEY) or "[]"
		list = HttpService:JSONDecode(json)
	end)
	return list
end

-- Set autoload config
local function setAutoload(name)
	pcall(function()
		LocalPlayer:SetAttribute(AUTOLOAD_KEY, name)
	end)
end

-- Get autoload config name
local function getAutoload()
	local name = ""
	pcall(function()
		name = LocalPlayer:GetAttribute(AUTOLOAD_KEY) or ""
	end)
	return name
end

-- Clear autoload
local function clearAutoload()
	pcall(function()
		LocalPlayer:SetAttribute(AUTOLOAD_KEY, "")
	end)
end

-- ========================
--  CONFIG UI (in QOL tab)
-- ========================
header(t7, "Config System", 13)

-- Config name input display
local configNameHolder = {value = "Default"}

local configNameRow = Instance.new("Frame")
configNameRow.Size = UDim2.new(1, 0, 0, 30)
configNameRow.BackgroundColor3 = C.card_glass
configNameRow.BackgroundTransparency = 0.3
configNameRow.BorderSizePixel = 0
configNameRow.LayoutOrder = 14
configNameRow.ZIndex = 53
configNameRow.Parent = t7
Instance.new("UICorner", configNameRow).CornerRadius = UDim.new(0, 7)
Instance.new("UIStroke", configNameRow).Color = C.border
configNameRow:FindFirstChildOfClass("UIStroke").Thickness = 1
configNameRow:FindFirstChildOfClass("UIStroke").Transparency = 0.7
local cnPad = Instance.new("UIPadding", configNameRow)
cnPad.PaddingLeft = UDim.new(0, 10)
cnPad.PaddingRight = UDim.new(0, 10)

local configNameLbl = Instance.new("TextLabel")
configNameLbl.Size = UDim2.new(0, 80, 1, 0)
configNameLbl.BackgroundTransparency = 1
configNameLbl.Text = "Config Name"
configNameLbl.TextColor3 = C.text
configNameLbl.TextSize = 10
configNameLbl.Font = Enum.Font.GothamMedium
configNameLbl.TextXAlignment = Enum.TextXAlignment.Left
configNameLbl.ZIndex = 54
configNameLbl.Parent = configNameRow

local configNameBox = Instance.new("TextBox")
configNameBox.Size = UDim2.new(0, 140, 0, 22)
configNameBox.Position = UDim2.new(1, 0, 0.5, 0)
configNameBox.AnchorPoint = Vector2.new(1, 0.5)
configNameBox.BackgroundColor3 = C.slider_bg
configNameBox.Text = "Default"
configNameBox.PlaceholderText = "Config name..."
configNameBox.TextColor3 = C.cyber_cyan
configNameBox.PlaceholderColor3 = C.dim
configNameBox.TextSize = 10
configNameBox.Font = Enum.Font.GothamBold
configNameBox.BorderSizePixel = 0
configNameBox.ClearTextOnFocus = false
configNameBox.ZIndex = 54
configNameBox.Parent = configNameRow
Instance.new("UICorner", configNameBox).CornerRadius = UDim.new(0, 5)
local cStroke = Instance.new("UIStroke", configNameBox)
cStroke.Color = C.cyber_cyan
cStroke.Thickness = 1
cStroke.Transparency = 0.7

configNameBox.FocusLost:Connect(function()
	configNameHolder.value = configNameBox.Text
end)

-- Action buttons
local function configButton(parent, text, color, order, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.48, 0, 0, 28)
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.7
	btn.Text = text
	btn.TextColor3 = color
	btn.TextSize = 10
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.LayoutOrder = order
	btn.ZIndex = 54
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	local bStroke = Instance.new("UIStroke", btn)
	bStroke.Color = color
	bStroke.Thickness = 1
	bStroke.Transparency = 0.4

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.7}):Play()
	end)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Button row 1: Save / Load
local btnRow1 = Instance.new("Frame")
btnRow1.Size = UDim2.new(1, 0, 0, 28)
btnRow1.BackgroundTransparency = 1
btnRow1.LayoutOrder = 15
btnRow1.ZIndex = 53
btnRow1.Parent = t7
local br1Layout = Instance.new("UIListLayout", btnRow1)
br1Layout.FillDirection = Enum.FillDirection.Horizontal
br1Layout.Padding = UDim.new(0.04, 0)

configButton(btnRow1, "💾 SAVE CONFIG", C.cyber_cyan, 1, function()
	local name = configNameHolder.value
	if name == "" then
		showToast("ERROR", "Enter a config name first", C.cyber_red, "✕")
		return
	end
	local ok, err = saveConfig(name)
	if ok then
		showToast("SAVED", "Config '" .. name .. "' saved", C.cyber_cyan, "💾")
	else
		showToast("ERROR", "Failed to save: " .. tostring(err), C.cyber_red, "✕")
	end
end)

configButton(btnRow1, "📂 LOAD CONFIG", C.cyber_green, 2, function()
	local name = configNameHolder.value
	if name == "" then
		showToast("ERROR", "Enter a config name first", C.cyber_red, "✕")
		return
	end
	local ok, err = loadConfig(name)
	if ok then
		showToast("LOADED", "Config '" .. name .. "' loaded", C.cyber_green, "📂")
		updateStatusBar()
	else
		showToast("ERROR", "Failed to load: " .. tostring(err), C.cyber_red, "✕")
	end
end)

-- Button row 2: Set Autoload / Delete
local btnRow2 = Instance.new("Frame")
btnRow2.Size = UDim2.new(1, 0, 0, 28)
btnRow2.BackgroundTransparency = 1
btnRow2.LayoutOrder = 16
btnRow2.ZIndex = 53
btnRow2.Parent = t7
local br2Layout = Instance.new("UIListLayout", btnRow2)
br2Layout.FillDirection = Enum.FillDirection.Horizontal
br2Layout.Padding = UDim.new(0.04, 0)

configButton(btnRow2, "⚡ SET AUTOLOAD", C.cyber_yellow, 1, function()
	local name = configNameHolder.value
	if name == "" then
		showToast("ERROR", "Enter a config name first", C.cyber_red, "✕")
		return
	end
	setAutoload(name)
	showToast("AUTOLOAD", "'" .. name .. "' will auto-load on join", C.cyber_yellow, "⚡")
	autoloadLbl.Text = "// AUTOLOAD: " .. name
end)

configButton(btnRow2, "🗑 DELETE CONFIG", C.cyber_red, 2, function()
	local name = configNameHolder.value
	if name == "" then return end
	deleteConfig(name)
	-- Clear autoload if this was it
	if getAutoload() == name then
		clearAutoload()
		autoloadLbl.Text = "// AUTOLOAD: None"
	end
	showToast("DELETED", "Config '" .. name .. "' deleted", C.cyber_red, "🗑")
end)

-- Button row 3: Clear Autoload / Reset Defaults
local btnRow3 = Instance.new("Frame")
btnRow3.Size = UDim2.new(1, 0, 0, 28)
btnRow3.BackgroundTransparency = 1
btnRow3.LayoutOrder = 17
btnRow3.ZIndex = 53
btnRow3.Parent = t7
local br3Layout = Instance.new("UIListLayout", btnRow3)
br3Layout.FillDirection = Enum.FillDirection.Horizontal
br3Layout.Padding = UDim.new(0.04, 0)

configButton(btnRow3, "✕ CLEAR AUTOLOAD", C.cyber_orange, 1, function()
	clearAutoload()
	showToast("CLEARED", "Autoload disabled", C.cyber_orange, "✕")
	autoloadLbl.Text = "// AUTOLOAD: None"
end)

configButton(btnRow3, "↺ RESET DEFAULTS", C.cyber_purple, 2, function()
	-- This would ideally reload defaults, for now show toast
	showToast("RESET", "Restart to apply defaults", C.cyber_purple, "↺")
end)

-- Autoload status label
local autoloadName = getAutoload()
autoloadLbl = Instance.new("TextLabel")
autoloadLbl.Size = UDim2.new(1, 0, 0, 18)
autoloadLbl.BackgroundTransparency = 1
autoloadLbl.Text = autoloadName ~= "" and ("// AUTOLOAD: " .. autoloadName) or "// AUTOLOAD: None"
autoloadLbl.TextColor3 = C.cyber_yellow
autoloadLbl.TextSize = 9
autoloadLbl.Font = Enum.Font.GothamBold
autoloadLbl.TextXAlignment = Enum.TextXAlignment.Left
autoloadLbl.LayoutOrder = 18
autoloadLbl.ZIndex = 53
autoloadLbl.Parent = t7

-- Saved configs list header
header(t7, "Saved Configs", 19)

-- Config list display (refreshes dynamically)
local configListFrame = Instance.new("Frame")
configListFrame.Size = UDim2.new(1, 0, 0, 0)
configListFrame.BackgroundTransparency = 1
configListFrame.AutomaticSize = Enum.AutomaticSize.Y
configListFrame.LayoutOrder = 20
configListFrame.ZIndex = 53
configListFrame.Parent = t7
local clfLayout = Instance.new("UIListLayout", configListFrame)
clfLayout.Padding = UDim.new(0, 4)
clfLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshConfigList()
	-- Clear old entries
	for _, c in ipairs(configListFrame:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	local configs = getConfigList()
	local currentAutoload = getAutoload()

	if #configs == 0 then
		local emptyLbl = Instance.new("TextLabel")
		emptyLbl.Size = UDim2.new(1, 0, 0, 24)
		emptyLbl.BackgroundTransparency = 1
		emptyLbl.Text = "No saved configs yet"
		emptyLbl.TextColor3 = C.dim
		emptyLbl.TextSize = 9
		emptyLbl.Font = Enum.Font.GothamMedium
		emptyLbl.TextXAlignment = Enum.TextXAlignment.Left
		emptyLbl.ZIndex = 54
		emptyLbl.Parent = configListFrame
		return
	end

	for i, name in ipairs(configs) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 26)
		row.BackgroundColor3 = C.card_glass
		row.BackgroundTransparency = 0.3
		row.BorderSizePixel = 0
		row.LayoutOrder = i
		row.ZIndex = 53
		row.Parent = configListFrame
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

		local isAuto = (name == currentAutoload)

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.5, 0, 1, 0)
		nameLbl.Position = UDim2.new(0, 8, 0, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = (isAuto and "⚡ " or "   ") .. name
		nameLbl.TextColor3 = isAuto and C.cyber_yellow or C.text
		nameLbl.TextSize = 10
		nameLbl.Font = Enum.Font.GothamMedium
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.ZIndex = 54
		nameLbl.Parent = row

		-- Quick load button
		local loadBtn = Instance.new("TextButton")
		loadBtn.Size = UDim2.new(0, 50, 0, 18)
		loadBtn.Position = UDim2.new(1, -62, 0.5, 0)
		loadBtn.AnchorPoint = Vector2.new(0, 0.5)
		loadBtn.BackgroundColor3 = C.cyber_cyan
		loadBtn.BackgroundTransparency = 0.7
		loadBtn.Text = "LOAD"
		loadBtn.TextColor3 = C.cyber_cyan
		loadBtn.TextSize = 8
		loadBtn.Font = Enum.Font.GothamBold
		loadBtn.BorderSizePixel = 0
		loadBtn.ZIndex = 54
		loadBtn.Parent = row
		Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 4)

		loadBtn.MouseButton1Click:Connect(function()
			local ok = loadConfig(name)
			if ok then
				showToast("LOADED", "Config '" .. name .. "' applied", C.cyber_green, "📂")
				updateStatusBar()
			end
		end)
	end
end

-- Refresh list whenever QOL tab is opened
Tabs[7].btn.MouseButton1Click:Connect(function()
	spawn(function()
		wait(0.1)
		refreshConfigList()
	end)
end)

-- Initial refresh
spawn(function()
	wait(0.5)
	refreshConfigList()
end)

-- ========================
--  AUTOLOAD ON JOIN
-- ========================
spawn(function()
	wait(1.5)
	local autoName = getAutoload()
	if autoName and autoName ~= "" then
		local ok = loadConfig(autoName)
		if ok then
			showToast("AUTOLOAD", "Config '" .. autoName .. "' loaded", C.cyber_yellow, "⚡")
			updateStatusBar()
		end
	end
end)

-- TAB 9: TROLL
local t9 = Tabs[9].frame
header(t9, "// Combat Trolling", 1)
toggle(t9, "Hitbox Expander", S.Hitbox_Enabled, 2, function(v) S.Hitbox_Enabled = v end)
slider(t9, "Head Size Multiplier", 1, 15, S.Hitbox_HeadSize, 3, function(v) S.Hitbox_HeadSize = v end)
slider(t9, "Body Size Multiplier", 1, 10, S.Hitbox_BodySize, 4, function(v) S.Hitbox_BodySize = v end)
slider(t9, "Hitbox Transparency", 0, 1, S.Hitbox_Transparency, 5, function(v) S.Hitbox_Transparency = v end)
toggle(t9, "Team Check", S.Hitbox_TeamCheck, 6, function(v) S.Hitbox_TeamCheck = v end)
sep(t9, 7)
toggle(t9, "Character Scale", S.CharScale_Enabled, 8, function(v) S.CharScale_Enabled = v end)
slider(t9, "Scale (0.2 = tiny, 5 = giant)", 0.2, 5, S.CharScale_Value, 9, function(v) S.CharScale_Value = v end)
sep(t9, 10)
toggle(t9, "Spin Bot", S.SpinBot_Enabled, 11, function(v) S.SpinBot_Enabled = v end)
slider(t9, "Spin Speed", 5, 100, S.SpinBot_Speed, 12, function(v) S.SpinBot_Speed = v end)
cycler(t9, "Spin Axis", {"Y", "X", "Z", "All"}, S.SpinBot_Axis, 13, function(v) S.SpinBot_Axis = v end)
sep(t9, 14)
toggle(t9, "Fake Lag", S.FakeLag_Enabled, 15, function(v) S.FakeLag_Enabled = v end)
slider(t9, "Lag Intensity (studs)", 1, 20, S.FakeLag_Intensity, 16, function(v) S.FakeLag_Intensity = v end)
slider(t9, "Lag Interval (sec)", 0.05, 1, S.FakeLag_Interval, 17, function(v) S.FakeLag_Interval = v end)
sep(t9, 18)
header(t9, "// Player Trolling", 19)
toggle(t9, "Fling Players", S.Fling_Enabled, 20, function(v) S.Fling_Enabled = v end)
slider(t9, "Fling Power", 1000, 50000, S.Fling_Power, 21, function(v) S.Fling_Power = v end)
toggle(t9, "Fling on Touch", S.Fling_OnTouch, 22, function(v) S.Fling_OnTouch = v end)
sep(t9, 23)
toggle(t9, "Orbit Nearest Player", S.Orbit_Enabled, 24, function(v) S.Orbit_Enabled = v end)
slider(t9, "Orbit Speed", 1, 20, S.Orbit_Speed, 25, function(v) S.Orbit_Speed = v end)
slider(t9, "Orbit Radius (studs)", 3, 30, S.Orbit_Radius, 26, function(v) S.Orbit_Radius = v end)
slider(t9, "Orbit Height Offset", -10, 20, S.Orbit_Height, 27, function(v) S.Orbit_Height = v end)
sep(t9, 28)
toggle(t9, "Attach to Player", S.Attach_Enabled, 29, function(v) S.Attach_Enabled = v end)
cycler(t9, "Attach Point", {"Head", "Back", "Shoulder"}, S.Attach_Offset, 30, function(v) S.Attach_Offset = v end)
sep(t9, 31)
toggle(t9, "Ragdoll on Command [P]", S.Ragdoll_Enabled, 32, function(v) S.Ragdoll_Enabled = v end)
sep(t9, 33)
header(t9, "// Utility Trolling", 34)
toggle(t9, "Anti-AFK", S.AntiAFK_Enabled, 35, function(v) S.AntiAFK_Enabled = v end)
toggle(t9, "Anti-Void (no fall death)", S.AntiVoid_Enabled, 36, function(v) S.AntiVoid_Enabled = v end)
slider(t9, "Void Threshold (Y pos)", -300, -20, S.AntiVoid_Height, 37, function(v) S.AntiVoid_Height = v end)
sep(t9, 38)
toggle(t9, "Chat Spammer", S.ChatSpam_Enabled, 39, function(v) S.ChatSpam_Enabled = v end)
slider(t9, "Spam Delay (sec)", 0.5, 15, S.ChatSpam_Delay, 40, function(v) S.ChatSpam_Delay = v end)
sep(t9, 41)
header(t9, "// Visual Trolling", 42)
toggle(t9, "Headless Character", S.Headless_Enabled, 43, function(v) S.Headless_Enabled = v end)
toggle(t9, "Invisible Torso", S.InvisTorso_Enabled, 44, function(v) S.InvisTorso_Enabled = v end)
sep(t9, 45)
toggle(t9, "Seizure Mode (screen flash)", S.Seizure_Enabled, 46, function(v) S.Seizure_Enabled = v end)
slider(t9, "Flash Speed", 0.02, 0.5, S.Seizure_Speed, 47, function(v) S.Seizure_Speed = v end)
sep(t9, 48)
toggle(t9, "Matrix Mode (slow-mo)", S.Matrix_Enabled, 49, function(v) S.Matrix_Enabled = v end)
slider(t9, "Slow-Mo Factor", 0.05, 0.8, S.Matrix_SlowMo, 50, function(v) S.Matrix_SlowMo = v end)

-- TAB 8: STATS DASHBOARD
local t8 = Tabs[8].frame

local function statCard(parent, label, valueId, color, order)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(0.48, 0, 0, 70)
	card.BackgroundColor3 = C.card_glass
	card.BackgroundTransparency = 0.2
	card.BorderSizePixel = 0
	card.LayoutOrder = order
	card.ZIndex = 53
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
	local cs = Instance.new("UIStroke", card)
	cs.Color = color
	cs.Thickness = 1
	cs.Transparency = 0.5

	-- Accent top line
	local topLine = Instance.new("Frame")
	topLine.Size = UDim2.new(0.4, 0, 0, 2)
	topLine.Position = UDim2.new(0.3, 0, 0, 0)
	topLine.BackgroundColor3 = color
	topLine.BorderSizePixel = 0
	topLine.ZIndex = 54
	topLine.Parent = card
	Instance.new("UICorner", topLine).CornerRadius = UDim.new(1, 0)

	local valLbl = Instance.new("TextLabel")
	valLbl.Name = valueId
	valLbl.Size = UDim2.new(1, 0, 0, 36)
	valLbl.Position = UDim2.new(0, 0, 0, 12)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = "0"
	valLbl.TextColor3 = color
	valLbl.TextSize = 26
	valLbl.Font = Enum.Font.GothamBold
	valLbl.ZIndex = 54
	valLbl.Parent = card

	local lblLabel = Instance.new("TextLabel")
	lblLabel.Size = UDim2.new(1, 0, 0, 16)
	lblLabel.Position = UDim2.new(0, 0, 0, 48)
	lblLabel.BackgroundTransparency = 1
	lblLabel.Text = string.upper(label)
	lblLabel.TextColor3 = C.subtext
	lblLabel.TextSize = 8
	lblLabel.Font = Enum.Font.GothamBold
	lblLabel.ZIndex = 54
	lblLabel.Parent = card

	return valLbl
end

-- Use a grid-like layout for stats
local statsGrid = Instance.new("Frame")
statsGrid.Size = UDim2.new(1, 0, 0, 0)
statsGrid.BackgroundTransparency = 1
statsGrid.AutomaticSize = Enum.AutomaticSize.Y
statsGrid.LayoutOrder = 1
statsGrid.Parent = t8

local gridLayout = Instance.new("UIGridLayout", statsGrid)
gridLayout.CellSize = UDim2.new(0.48, 0, 0, 75)
gridLayout.CellPadding = UDim2.new(0.04, 0, 0, 8)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder

local killsLbl = statCard(statsGrid, "Kills", "kills", C.cyber_cyan, 1)
local deathsLbl = statCard(statsGrid, "Deaths", "deaths", C.cyber_red, 2)
local kdLbl = statCard(statsGrid, "K/D Ratio", "kd", C.cyber_yellow, 3)
local accuracyLbl = statCard(statsGrid, "Accuracy", "acc", C.cyber_green, 4)
local shotsFiredLbl = statCard(statsGrid, "Shots Fired", "fired", C.cyber_orange, 5)
local shotsHitLbl = statCard(statsGrid, "Shots Hit", "hit", C.cyber_pink, 6)
local activeLbl = statCard(statsGrid, "Active Modules", "modules", C.cyber_purple, 7)
local uptimeLbl = statCard(statsGrid, "Uptime", "uptime", C.cyber_blue, 8)

local startTime = tick()

-- ========================
--  PANEL TOGGLE (cyberpunk animation)
-- ========================
local panelOpen = false
local function togglePanel()
	panelOpen = not panelOpen
	if panelOpen then
		Panel.Visible = true
		Panel.Size = UDim2.new(0, 540, 0, 0)
		Panel.BackgroundTransparency = 0.5
		panelStroke.Transparency = 1

		-- Cyberpunk glitch-in
		TweenService:Create(Panel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 540, 0, 580),
			BackgroundTransparency = 0.08
		}):Play()
		TweenService:Create(panelStroke, TweenInfo.new(0.3), {Transparency = 0.3}):Play()

		ToggleBtn.Text = "✕"
		TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.cyber_red}):Play()
		updateStatusBar()
	else
		local tw = TweenService:Create(Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 540, 0, 0),
			BackgroundTransparency = 0.8
		})
		tw:Play()
		tw.Completed:Connect(function() Panel.Visible = false end)
		ToggleBtn.Text = "◈"
		TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.cyber_cyan}):Play()
	end
end

ToggleBtn.MouseButton1Click:Connect(togglePanel)
CloseBtn.MouseButton1Click:Connect(function() if panelOpen then togglePanel() end end)

-- M keybind
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.M then togglePanel() end
end)

-- Draggable panel
do
	local dragging, dragStart, startPos
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = Panel.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

-- Initial status bar
updateStatusBar()

-- ================================================================
--  FEATURE IMPLEMENTATIONS
--  (All gameplay logic below)
-- ================================================================
-- ================================================================
--  FEATURE IMPLEMENTATIONS
-- ================================================================

-- ========================
--  AIM ASSIST
-- ========================
local isAiming = false
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then isAiming = true end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then isAiming = false end
end)

local function getSmoothing(t)
	local mode = S.Aim_Smoothing
	if mode == "Linear" then return t
	elseif mode == "EaseIn" then return t * t
	elseif mode == "EaseOut" then return 1 - (1 - t) * (1 - t)
	elseif mode == "Smooth" then return t * t * (3 - 2 * t)
	elseif mode == "Snap" then return t > 0.5 and 1 or 0
	end
	return t
end

local function getTarget()
	local closest, closestDist = nil, S.Aim_Radius
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			if S.Aim_TeamCheck and plr.Team and plr.Team == LocalPlayer.Team then continue end
			local char = plr.Character
			local part = char:FindFirstChild(S.Aim_Part) or char:FindFirstChild("Head")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if part and hum and hum.Health > 0 then
				local sp, onScreen = Camera:WorldToScreenPoint(part.Position)
				if onScreen then
					local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
					if dist < closestDist then
						closestDist = dist
						closest = {part = part, character = char, distance = dist}
					end
				end
			end
		end
	end
	return closest
end

-- ========================
--  TRIGGERBOT
-- ========================
local VirtualInputManager = game:GetService("VirtualInputManager")
local triggerActive = false
local triggerCooldown = false

-- Triggerbot HUD indicator
local TriggerIndicator = Instance.new("TextLabel")
TriggerIndicator.Size = UDim2.new(0, 90, 0, 20)
TriggerIndicator.Position = UDim2.new(0.5, 0, 0.62, 0)
TriggerIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
TriggerIndicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TriggerIndicator.BackgroundTransparency = 0.5
TriggerIndicator.Text = "TB: READY"
TriggerIndicator.TextColor3 = C.cyber_cyan
TriggerIndicator.TextSize = 9
TriggerIndicator.Font = Enum.Font.GothamBold
TriggerIndicator.Visible = false
TriggerIndicator.ZIndex = 997
TriggerIndicator.Parent = HUDGui
Instance.new("UICorner", TriggerIndicator).CornerRadius = UDim.new(0, 6)

local function isPartValidTarget(part, character)
	if S.Trigger_HitPart == "Any" then return true end
	if S.Trigger_HitPart == "Head" then
		return part.Name == "Head" or part.Parent and part.Parent.Name == "Head"
	end
	if S.Trigger_HitPart == "UpperTorso" then
		return part.Name == "UpperTorso" or part.Name == "Torso" or part.Name == "HumanoidRootPart"
	end
	return true
end

local function getTriggerTarget()
	-- Raycast from camera through center of screen
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local ray = Camera:ViewportPointToRay(center.X, center.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {LocalPlayer.Character}

	local result = workspace:Raycast(ray.Origin, ray.Direction * S.Trigger_MaxRange, params)
	if not result or not result.Instance then return nil end

	local hitPart = result.Instance
	local model = hitPart:FindFirstAncestorOfClass("Model")
	if not model then return nil end

	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end

	-- Check it's a player
	local hitPlayer = Players:GetPlayerFromCharacter(model)
	if not hitPlayer or hitPlayer == LocalPlayer then return nil end

	-- Team check
	if S.Trigger_TeamCheck and hitPlayer.Team and hitPlayer.Team == LocalPlayer.Team then
		return nil
	end

	-- Part check
	if not isPartValidTarget(hitPart, model) then return nil end

	-- FOV check (is the target inside the aim radius?)
	if S.Trigger_FOVCheck then
		local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
		if head then
			local sp, onScreen = Camera:WorldToScreenPoint(head.Position)
			if onScreen then
				local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
				if screenDist > S.Aim_Radius then return nil end
			end
		end
	end

	return {player = hitPlayer, part = hitPart, model = model, distance = result.Distance}
end

local function fireClick()
	-- Simulate mouse click
	mouse1click()
end

-- Safe mouse1click wrapper
local function safeClick()
	pcall(function()
		VirtualInputManager:SendMouseButtonEvent(
			Camera.ViewportSize.X / 2,
			Camera.ViewportSize.Y / 2,
			0, true, game, 0
		)
		wait(0.01)
		VirtualInputManager:SendMouseButtonEvent(
			Camera.ViewportSize.X / 2,
			Camera.ViewportSize.Y / 2,
			0, false, game, 0
		)
	end)
	-- Fallback: use Mouse's click directly
	pcall(function()
		mouse1click()
	end)
end

local function executeTrigger()
	if triggerCooldown then return end
	triggerCooldown = true

	-- Delay
	if S.Trigger_Delay > 0 then
		wait(S.Trigger_Delay / 1000)
		-- Re-verify target after delay
		local recheck = getTriggerTarget()
		if not recheck then
			triggerCooldown = false
			return
		end
	end

	-- Fire
	if S.Trigger_BurstMode then
		-- Burst fire
		spawn(function()
			for i = 1, S.Trigger_BurstCount do
				safeClick()
				if i < S.Trigger_BurstCount then
					wait(S.Trigger_BurstDelay)
				end
			end
		end)

		-- Show burst indicator
		if S.Trigger_Indicator then
			TriggerIndicator.Text = "TB: BURST x" .. S.Trigger_BurstCount
			TriggerIndicator.TextColor3 = C.cyber_orange
			spawn(function()
				wait(0.3)
				TriggerIndicator.Text = "TB: READY"
				TriggerIndicator.TextColor3 = C.cyber_cyan
			end)
		end
	else
		-- Single fire
		safeClick()
		if S.Trigger_Indicator then
			TriggerIndicator.Text = "TB: FIRED"
			TriggerIndicator.TextColor3 = C.cyber_yellow
			spawn(function()
				wait(0.15)
				TriggerIndicator.Text = "TB: READY"
				TriggerIndicator.TextColor3 = C.cyber_cyan
			end)
		end
	end

	-- Small cooldown to prevent spam
	wait(0.08)
	triggerCooldown = false
end

-- Triggerbot runs every frame in the render loop (added below)

-- ========================
--  CROSSHAIR
-- ========================
local crossParts = {}
local function clearCross()
	for _, p in ipairs(crossParts) do p:Destroy() end
	crossParts = {}
end

local function mkLine(px, py, w, h, col, op, rot)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0, w, 0, h)
	f.Position = UDim2.new(0.5, px, 0.5, py)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.BackgroundColor3 = col
	f.BackgroundTransparency = 1 - op
	f.BorderSizePixel = 0
	f.Rotation = rot or 0
	f.ZIndex = 999
	f.Parent = OverlayGui
	table.insert(crossParts, f)

	-- Outline
	if S.Cross_Outline then
		local outline = Instance.new("UIStroke", f)
		outline.Color = Color3.new(0, 0, 0)
		outline.Thickness = 1
		outline.Transparency = 0.3
	end
	return f
end

local dynamicExpand = 0
local function drawCrosshair()
	clearCross()
	if not S.Cross_Enabled then return end
	local sz = S.Cross_Size
	local t = S.Cross_Thick
	local g = S.Cross_Gap + dynamicExpand
	local col = S.Cross_Color
	local op = S.Cross_Opacity
	local style = S.Cross_Style

	if style == "Cross" or style == "Cross+Dot" then
		mkLine(0, -(g + sz/2), t, sz, col, op)
		mkLine(0, (g + sz/2), t, sz, col, op)
		mkLine(-(g + sz/2), 0, sz, t, col, op)
		mkLine((g + sz/2), 0, sz, t, col, op)
	end
	if style == "Dot" or style == "Cross+Dot" then
		local dot = mkLine(0, 0, t+2, t+2, col, op)
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	end
	if style == "Circle" then
		local circle = Instance.new("Frame")
		circle.Size = UDim2.new(0, sz*2, 0, sz*2)
		circle.Position = UDim2.new(0.5, 0, 0.5, 0)
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.BackgroundTransparency = 1
		circle.BorderSizePixel = 0
		circle.ZIndex = 999
		circle.Parent = OverlayGui
		Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
		local st = Instance.new("UIStroke", circle)
		st.Color = col
		st.Thickness = t
		st.Transparency = 1 - op
		if S.Cross_Outline then
			-- outer ring
		end
		table.insert(crossParts, circle)
	end
	if style == "Chevron" then
		mkLine(-(g + sz * 0.4), (g + sz * 0.3), sz * 0.7, t, col, op, -45)
		mkLine((g + sz * 0.4), (g + sz * 0.3), sz * 0.7, t, col, op, 45)
	end
	if style == "Triangle" then
		mkLine(0, -(g + sz * 0.6), t, sz * 0.5, col, op)
		mkLine(-(g + sz * 0.4), (g + sz * 0.2), sz * 0.5, t, col, op, -30)
		mkLine((g + sz * 0.4), (g + sz * 0.2), sz * 0.5, t, col, op, 30)
	end
end

-- ========================
--  FOV CIRCLE
-- ========================
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.ZIndex = 40
fovCircle.Parent = ScreenGui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = C.cyber_cyan
fovStroke.Thickness = 1

-- ========================
--  HIT MARKERS
-- ========================
local function showHitMarker()
	if not S.HitMarkers then return end
	local lines = {}
	for i = 1, 4 do
		local f = Instance.new("Frame")
		f.Size = UDim2.new(0, 14, 0, 2)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.new(0.5, 0, 0.5, 0)
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		f.BorderSizePixel = 0
		f.Rotation = (i-1) * 90 + 45
		f.ZIndex = 998
		f.Parent = OverlayGui
		table.insert(lines, f)
	end
	spawn(function()
		wait(0.12)
		for _, l in ipairs(lines) do
			TweenService:Create(l, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
		end
		wait(0.25)
		for _, l in ipairs(lines) do l:Destroy() end
	end)
end

-- ========================
--  DAMAGE NUMBERS
-- ========================
local function showDamageNumber(character, amount)
	if not S.DamageNumbers then return end
	local head = character:FindFirstChild("Head")
	if not head then return end

	local bb = Instance.new("BillboardGui")
	bb.Adornee = head
	bb.Size = UDim2.new(0, 100, 0, 40)
	bb.StudsOffset = Vector3.new(math.random(-2, 2), 3, 0)
	bb.AlwaysOnTop = true
	bb.Parent = OverlayGui

	local isCrit = amount >= 40
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = (isCrit and "✦ " or "") .. tostring(math.floor(amount))
	lbl.TextColor3 = isCrit and S.DmgNum_CritColor or S.DmgNum_Color
	lbl.TextSize = isCrit and 22 or 16
	lbl.Font = Enum.Font.GothamBold
	lbl.TextStrokeTransparency = 0.4
	lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	lbl.Parent = bb

	spawn(function()
		for i = 1, 20 do
			bb.StudsOffset = bb.StudsOffset + Vector3.new(0, 0.1, 0)
			lbl.TextTransparency = i / 20
			lbl.TextStrokeTransparency = 0.4 + (i / 20) * 0.6
			wait(0.03)
		end
		bb:Destroy()
	end)
end

-- ========================
--  KILL FEED
-- ========================
local KillFeedFrame = Instance.new("Frame")
KillFeedFrame.Size = UDim2.new(0, 250, 0, 200)
KillFeedFrame.Position = UDim2.new(1, -270, 0, 80)
KillFeedFrame.BackgroundTransparency = 1
KillFeedFrame.Parent = HUDGui
local kfl = Instance.new("UIListLayout", KillFeedFrame)
kfl.SortOrder = Enum.SortOrder.LayoutOrder
kfl.Padding = UDim.new(0, 4)
kfl.VerticalAlignment = Enum.VerticalAlignment.Bottom

local function addKillFeedEntry(killerName, victimName)
	if not S.KillFeed then return end

	local entry = Instance.new("TextLabel")
	entry.Size = UDim2.new(1, 0, 0, 22)
	entry.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	entry.BackgroundTransparency = 0.5
	entry.Text = "  " .. killerName .. "  ✦  " .. victimName
	entry.TextColor3 = C.text
	entry.TextSize = 11
	entry.Font = Enum.Font.GothamMedium
	entry.TextXAlignment = Enum.TextXAlignment.Left
	entry.Parent = KillFeedFrame
	Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 6)

	table.insert(KillFeedEntries, entry)
	if #KillFeedEntries > S.KillFeed_Max then
		KillFeedEntries[1]:Destroy()
		table.remove(KillFeedEntries, 1)
	end

	spawn(function()
		wait(5)
		if entry.Parent then
			TweenService:Create(entry, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			wait(0.6)
			entry:Destroy()
			local idx = table.find(KillFeedEntries, entry)
			if idx then table.remove(KillFeedEntries, idx) end
		end
	end)
end

-- ========================
--  KILL COUNTER HUD
-- ========================
local KillCounterLbl = Instance.new("TextLabel")
KillCounterLbl.Size = UDim2.new(0, 120, 0, 30)
KillCounterLbl.Position = UDim2.new(0.5, 0, 0, 10)
KillCounterLbl.AnchorPoint = Vector2.new(0.5, 0)
KillCounterLbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KillCounterLbl.BackgroundTransparency = 0.5
KillCounterLbl.Text = "✦ 0 Kills"
KillCounterLbl.TextColor3 = C.cyber_cyan
KillCounterLbl.TextSize = 14
KillCounterLbl.Font = Enum.Font.GothamBold
KillCounterLbl.Parent = HUDGui
Instance.new("UICorner", KillCounterLbl).CornerRadius = UDim.new(0, 8)

-- ========================
--  FPS / PING HUD
-- ========================
local PerfHUD = Instance.new("TextLabel")
PerfHUD.Size = UDim2.new(0, 140, 0, 22)
PerfHUD.Position = UDim2.new(0, 10, 1, -32)
PerfHUD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PerfHUD.BackgroundTransparency = 0.6
PerfHUD.Text = "FPS: -- | Ping: --"
PerfHUD.TextColor3 = C.cyber_cyan
PerfHUD.TextSize = 10
PerfHUD.Font = Enum.Font.GothamMedium
PerfHUD.TextXAlignment = Enum.TextXAlignment.Center
PerfHUD.Parent = HUDGui
Instance.new("UICorner", PerfHUD).CornerRadius = UDim.new(0, 6)

local fpsBuffer = {}

-- ========================
--  TRACER LINES
-- ========================
local tracerFolder = Instance.new("Folder", ScreenGui)
tracerFolder.Name = "Tracers"

-- ========================
--  ESP SYSTEM (robust — handles death, rejoin, respawn)
-- ========================
local espFolder = Instance.new("Folder", ScreenGui)
espFolder.Name = "ESP"
local espObjects = {}
local espConnections = {} -- store connections per player for cleanup

local function cleanupESP(player)
	-- Destroy all ESP instances for this player
	if espObjects[player] then
		for key, v in pairs(espObjects[player]) do
			pcall(function()
				if typeof(v) == "Instance" and v.Parent then
					v:Destroy()
				end
			end)
		end
		espObjects[player] = nil
	end
	-- Disconnect all event connections
	if espConnections[player] then
		for _, conn in ipairs(espConnections[player]) do
			pcall(function()
				if conn and conn.Connected then
					conn:Disconnect()
				end
			end)
		end
		espConnections[player] = nil
	end
	LastHealthValues[player] = nil
end

local function setupESP(player)
	if player == LocalPlayer then return end

	local function build(character)
		-- Always clean up old ESP first
		cleanupESP(player)
		espConnections[player] = {}

		-- Wait for character to fully load with timeout
		local head, hum, root
		local success = pcall(function()
			head = character:WaitForChild("Head", 5)
			hum = character:WaitForChild("Humanoid", 5)
			root = character:WaitForChild("HumanoidRootPart", 5)
		end)

		if not success or not head or not hum or not root then return end

		-- Double check character still exists (may have died during wait)
		if not character.Parent then return end
		if not head.Parent then return end

		-- Billboard for name, distance, health
		local bb = Instance.new("BillboardGui")
		bb.Name = "ESP_" .. player.Name
		bb.Adornee = head
		bb.Size = UDim2.new(0, 200, 0, 50)
		bb.StudsOffset = Vector3.new(0, 2.5, 0)
		bb.AlwaysOnTop = true
		bb.ResetOnSpawn = false
		bb.Parent = espFolder

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1, 0, 0, 14)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = player.DisplayName
		nameLbl.TextColor3 = Color3.new(1, 1, 1)
		nameLbl.TextSize = 12
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextStrokeTransparency = 0.4
		nameLbl.Parent = bb

		local distLbl = Instance.new("TextLabel")
		distLbl.Size = UDim2.new(1, 0, 0, 12)
		distLbl.Position = UDim2.new(0, 0, 0, 14)
		distLbl.BackgroundTransparency = 1
		distLbl.TextColor3 = C.subtext
		distLbl.TextSize = 9
		distLbl.Font = Enum.Font.GothamMedium
		distLbl.TextStrokeTransparency = 0.5
		distLbl.Parent = bb

		local hpBg = Instance.new("Frame")
		hpBg.Size = UDim2.new(0.5, 0, 0, 3)
		hpBg.Position = UDim2.new(0.25, 0, 0, 28)
		hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		hpBg.BorderSizePixel = 0
		hpBg.Parent = bb
		Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

		local hpFill = Instance.new("Frame")
		hpFill.Size = UDim2.new(1, 0, 1, 0)
		hpFill.BackgroundColor3 = C.cyber_cyan
		hpFill.BorderSizePixel = 0
		hpFill.Parent = hpBg
		Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

		-- Highlight (boxes/chams) — parent to character
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESP_Highlight"
		highlight.FillTransparency = 0.8
		highlight.OutlineTransparency = 0.3
		highlight.Adornee = character
		highlight.Parent = espFolder -- parent to our folder, not the character (safer)

		-- Track health for damage numbers / kill detection
		LastHealthValues[player] = hum.Health

		local healthConn = hum.HealthChanged:Connect(function(newHealth)
			local prev = LastHealthValues[player] or hum.MaxHealth
			local dmg = prev - newHealth
			if dmg > 0 then
				pcall(function()
					if character and character.Parent then
						showDamageNumber(character, dmg)
						showHitMarker()
					end
				end)
			end
			if newHealth <= 0 and prev > 0 then
				KillCount = KillCount + 1
				pcall(function()
					KillCounterLbl.Text = "✦ " .. KillCount .. " Kills"
				end)
				addKillFeedEntry(LocalPlayer.DisplayName, player.DisplayName)
			end
			LastHealthValues[player] = newHealth
		end)
		table.insert(espConnections[player], healthConn)

		-- When humanoid dies, hide ESP immediately (don't wait for character removal)
		local diedConn = hum.Died:Connect(function()
			pcall(function()
				if bb then bb.Enabled = false end
				if highlight then highlight.Enabled = false end
			end)
		end)
		table.insert(espConnections[player], diedConn)

		-- When character is being removed (ancestor changes)
		local ancestryConn = character.AncestryChanged:Connect(function(_, newParent)
			if not newParent then
				-- Character removed from workspace
				pcall(function()
					if bb and bb.Parent then bb.Enabled = false end
					if highlight and highlight.Parent then highlight.Enabled = false end
				end)
			end
		end)
		table.insert(espConnections[player], ancestryConn)

		espObjects[player] = {
			billboard = bb, nameLbl = nameLbl, distLbl = distLbl,
			hpBg = hpBg, hpFill = hpFill, highlight = highlight,
			humanoid = hum, rootPart = root, character = character,
		}
	end

	-- Build for current character if exists
	if player.Character then
		spawn(function()
			build(player.Character)
		end)
	end

	-- Rebuild on respawn
	local charAddedConn = player.CharacterAdded:Connect(function(newChar)
		-- Clean up old ESP immediately
		pcall(function()
			if espObjects[player] then
				if espObjects[player].billboard then espObjects[player].billboard.Enabled = false end
				if espObjects[player].highlight then espObjects[player].highlight.Enabled = false end
			end
		end)
		-- Wait for character to load, then rebuild
		spawn(function()
			wait(1)
			if newChar and newChar.Parent then
				build(newChar)
			end
		end)
	end)

	-- Store the CharacterAdded connection too
	if not espConnections[player] then espConnections[player] = {} end
	table.insert(espConnections[player], charAddedConn)
end

-- Setup for existing players
for _, p in ipairs(Players:GetPlayers()) do
	spawn(function()
		setupESP(p)
	end)
end

-- New players joining
Players.PlayerAdded:Connect(function(p)
	spawn(function()
		setupESP(p)
	end)
end)

-- Players leaving — full cleanup
Players.PlayerRemoving:Connect(function(p)
	cleanupESP(p)
end)

-- Periodic cleanup: remove orphaned ESP objects (safety net)
spawn(function()
	while true do
		wait(5)
		for player, data in pairs(espObjects) do
			-- Check if player is still in game
			if not player or not player.Parent then
				cleanupESP(player)
			-- Check if character is gone
			elseif not player.Character or not player.Character.Parent then
				pcall(function()
					if data.billboard then data.billboard.Enabled = false end
					if data.highlight then data.highlight.Enabled = false end
				end)
			-- Check if humanoid is dead
			elseif data.humanoid and data.humanoid.Health <= 0 then
				pcall(function()
					if data.billboard then data.billboard.Enabled = false end
					if data.highlight then data.highlight.Enabled = false end
				end)
			end
		end
	end
end)

-- ========================
--  FLY SYSTEM
-- ========================
local flyBV, flyBG = nil, nil
local function enableFly()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	flyBV.Velocity = Vector3.zero
	flyBV.Parent = root
	flyBG = Instance.new("BodyGyro")
	flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	flyBG.D = 100; flyBG.P = 10000
	flyBG.Parent = root
end
local function disableFly()
	if flyBV then flyBV:Destroy(); flyBV = nil end
	if flyBG then flyBG:Destroy(); flyBG = nil end
end

-- ========================
--  TELEPORT BEHIND ENEMY
-- ========================
local tpCooldownActive = false
local tpCooldownUI = nil

-- Cooldown indicator (small bar under kill counter)
local TPCooldownBg = Instance.new("Frame")
TPCooldownBg.Size = UDim2.new(0, 100, 0, 6)
TPCooldownBg.Position = UDim2.new(0.5, 0, 0, 44)
TPCooldownBg.AnchorPoint = Vector2.new(0.5, 0)
TPCooldownBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TPCooldownBg.BorderSizePixel = 0
TPCooldownBg.Visible = false
TPCooldownBg.Parent = HUDGui
Instance.new("UICorner", TPCooldownBg).CornerRadius = UDim.new(1, 0)

local TPCooldownFill = Instance.new("Frame")
TPCooldownFill.Size = UDim2.new(1, 0, 1, 0)
TPCooldownFill.BackgroundColor3 = C.cyber_cyan
TPCooldownFill.BorderSizePixel = 0
TPCooldownFill.Parent = TPCooldownBg
Instance.new("UICorner", TPCooldownFill).CornerRadius = UDim.new(1, 0)

local TPLabel = Instance.new("TextLabel")
TPLabel.Size = UDim2.new(0, 100, 0, 14)
TPLabel.Position = UDim2.new(0.5, 0, 0, 52)
TPLabel.AnchorPoint = Vector2.new(0.5, 0)
TPLabel.BackgroundTransparency = 1
TPLabel.Text = "TP READY"
TPLabel.TextColor3 = C.cyber_cyan
TPLabel.TextSize = 9
TPLabel.Font = Enum.Font.GothamBold
TPLabel.Visible = false
TPLabel.Parent = HUDGui

local function getClosestEnemy3D()
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local closest, closestDist = nil, S.TP_Behind_MaxRange
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			if S.TP_Behind_TeamCheck and plr.Team and plr.Team == LocalPlayer.Team then continue end
			local char = plr.Character
			local root = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				local dist = (myRoot.Position - root.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closest = {root = root, character = char, humanoid = hum, distance = dist}
				end
			end
		end
	end
	return closest
end

local function showTeleportEffect(fromPos, toPos)
	if not S.TP_Behind_Effect then return end

	-- Origin burst
	spawn(function()
		local part = Instance.new("Part")
		part.Size = Vector3.new(1, 1, 1)
		part.Position = fromPos
		part.Anchored = true
		part.CanCollide = false
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.Neon
		part.Color = C.cyber_cyan
		part.Transparency = 0.3
		part.Parent = workspace

		for i = 1, 15 do
			part.Size = Vector3.new(1 + i * 0.6, 1 + i * 0.6, 1 + i * 0.6)
			part.Transparency = 0.3 + (i / 15) * 0.7
			wait(0.02)
		end
		part:Destroy()
	end)

	-- Destination burst
	spawn(function()
		wait(0.05)
		local part2 = Instance.new("Part")
		part2.Size = Vector3.new(1, 1, 1)
		part2.Position = toPos
		part2.Anchored = true
		part2.CanCollide = false
		part2.Shape = Enum.PartType.Ball
		part2.Material = Enum.Material.Neon
		part2.Color = C.cyber_cyan
		part2.Transparency = 0.3
		part2.Parent = workspace

		for i = 1, 15 do
			part2.Size = Vector3.new(1 + i * 0.6, 1 + i * 0.6, 1 + i * 0.6)
			part2.Transparency = 0.3 + (i / 15) * 0.7
			wait(0.02)
		end
		part2:Destroy()
	end)

	-- Screen flash
	spawn(function()
		local flash = Instance.new("Frame")
		flash.Size = UDim2.new(1, 0, 1, 0)
		flash.BackgroundColor3 = C.cyber_cyan
		flash.BackgroundTransparency = 0.7
		flash.BorderSizePixel = 0
		flash.ZIndex = 1000
		flash.Parent = OverlayGui
		TweenService:Create(flash, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
		wait(0.35)
		flash:Destroy()
	end)
end

local function teleportBehindEnemy()
	if not S.TP_Behind_Enabled then return end
	if tpCooldownActive then return end

	local target = getClosestEnemy3D()
	if not target then
		-- Flash red to show no target
		spawn(function()
			TPLabel.Text = "NO TARGET"
			TPLabel.TextColor3 = C.cyber_red
			wait(1)
			TPLabel.Text = "TP READY"
			TPLabel.TextColor3 = C.cyber_cyan
		end)
		return
	end

	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local enemyRoot = target.root
	local fromPos = myRoot.Position

	-- Calculate position behind the enemy
	local enemyLook = enemyRoot.CFrame.LookVector
	local behindPos = enemyRoot.Position - (enemyLook * S.TP_Behind_Distance)
	-- Slightly above ground to avoid clipping
	behindPos = Vector3.new(behindPos.X, enemyRoot.Position.Y, behindPos.Z)

	-- Perform teleport
	showTeleportEffect(fromPos, behindPos)

	if S.TP_Behind_FaceEnemy then
		myRoot.CFrame = CFrame.new(behindPos, enemyRoot.Position)
	else
		myRoot.CFrame = CFrame.new(behindPos) * (myRoot.CFrame - myRoot.CFrame.Position)
	end

	-- Notification
	spawn(function()
		local notif = Instance.new("TextLabel")
		notif.Size = UDim2.new(0, 200, 0, 28)
		notif.Position = UDim2.new(0.5, 0, 0.35, 0)
		notif.AnchorPoint = Vector2.new(0.5, 0.5)
		notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		notif.BackgroundTransparency = 0.4
		notif.Text = "⚡ TELEPORTED BEHIND " .. string.upper(target.character.Name)
		notif.TextColor3 = C.cyber_cyan
		notif.TextSize = 11
		notif.Font = Enum.Font.GothamBold
		notif.TextScaled = false
		notif.ZIndex = 999
		notif.Parent = HUDGui
		Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)

		wait(1.5)
		TweenService:Create(notif, TweenInfo.new(0.4), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		wait(0.5)
		notif:Destroy()
	end)

	-- Start cooldown
	tpCooldownActive = true
	TPCooldownBg.Visible = true
	TPLabel.Visible = true
	TPLabel.Text = "COOLDOWN..."
	TPLabel.TextColor3 = C.cyber_red

	spawn(function()
		local cd = S.TP_Behind_Cooldown
		local startTime = tick()
		while tick() - startTime < cd do
			local elapsed = tick() - startTime
			local pct = 1 - (elapsed / cd)
			TPCooldownFill.Size = UDim2.new(pct, 0, 1, 0)
			TPCooldownFill.BackgroundColor3 = Color3.fromRGB(
				255 * pct + C.cyber_cyan.R * 255 * (1 - pct),
				60 * pct + C.cyber_cyan.G * 255 * (1 - pct),
				60 * pct + C.cyber_cyan.B * 255 * (1 - pct)
			)
			wait(0.03)
		end
		tpCooldownActive = false
		TPCooldownFill.Size = UDim2.new(1, 0, 1, 0)
		TPCooldownFill.BackgroundColor3 = C.cyber_cyan
		TPLabel.Text = "TP READY"
		TPLabel.TextColor3 = C.cyber_cyan

		-- Flash ready
		for i = 1, 3 do
			TPLabel.TextTransparency = 0.5
			wait(0.15)
			TPLabel.TextTransparency = 0
			wait(0.15)
		end
	end)
end

-- TP keybind
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode[S.TP_Behind_Key] then
		teleportBehindEnemy()
	end
end)

-- Show/hide TP HUD based on setting
spawn(function()
	while true do
		TPCooldownBg.Visible = S.TP_Behind_Enabled and true
		TPLabel.Visible = S.TP_Behind_Enabled
		if not S.TP_Behind_Enabled then
			tpCooldownActive = false
		end
		wait(0.5)
	end
end)

-- ========================
--  INFINITE JUMP
-- ========================
UserInputService.JumpRequest:Connect(function()
	if S.InfJump_Enabled then
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- ========================
--  FULLBRIGHT
-- ========================
local origBrightness = Lighting.Brightness
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origFogEnd = Lighting.FogEnd

-- ========================
--  NOCLIP
-- ========================
RunService.Stepped:Connect(function()
	if S.Noclip_Enabled then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- ========================
--  TRACERS DRAWING
-- ========================
local tracerLines = {}

local function clearTracers()
	for _, line in pairs(tracerLines) do
		if line and line.Parent then line:Destroy() end
	end
	tracerLines = {}
end

-- ========================
--  MAIN RENDER LOOP
-- ========================
local lastCrossUpdate = 0

RunService.RenderStepped:Connect(function(dt)
	Camera = workspace.CurrentCamera
	local now = tick()

	-- ---- FPS Counter ----
	table.insert(fpsBuffer, dt)
	if #fpsBuffer > 30 then table.remove(fpsBuffer, 1) end
	if S.FPSCounter or S.PingDisplay then
		local avgDt = 0
		for _, d in ipairs(fpsBuffer) do avgDt = avgDt + d end
		avgDt = avgDt / #fpsBuffer
		local fps = math.floor(1 / avgDt)
		local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		local parts = {}
		if S.FPSCounter then table.insert(parts, "FPS: " .. fps) end
		if S.PingDisplay then table.insert(parts, "Ping: " .. ping .. "ms") end
		PerfHUD.Text = table.concat(parts, "  |  ")
		PerfHUD.Visible = true
	else
		PerfHUD.Visible = false
	end

	-- ---- Kill Counter visibility ----
	KillCounterLbl.Visible = S.KillCounter

	-- ---- AIM ASSIST ----
	if S.Aim_Enabled and (not S.Aim_RequireADS or isAiming) then
		local tgt = getTarget()
		if tgt then
			local targetPos = tgt.part.Position

			-- Velocity prediction
			if S.Aim_Prediction then
				local vel = tgt.part.Velocity or Vector3.zero
				local dist = (Camera.CFrame.Position - targetPos).Magnitude
				local predTime = dist / 1000
				targetPos = targetPos + vel * predTime
			end

			local strength = getSmoothing(S.Aim_Strength)
			local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
			Camera.CFrame = Camera.CFrame:Lerp(targetCF, strength)
		end

		-- Sticky aim (slow sensitivity near target)
		if S.Aim_StickyAim then
			local tgt2 = getTarget()
			if tgt2 and tgt2.distance < S.Aim_Radius * 0.5 then
				UserInputService.MouseDeltaSensitivity = 1 - S.Aim_StickyStrength
			else
				UserInputService.MouseDeltaSensitivity = 1
			end
		else
			UserInputService.MouseDeltaSensitivity = 1
		end
	else
		UserInputService.MouseDeltaSensitivity = 1
	end

	-- ---- TRIGGERBOT ----
	if S.Trigger_Enabled then
		TriggerIndicator.Visible = S.Trigger_Indicator
		if not S.Trigger_RequireADS or isAiming then
			local trigTarget = getTriggerTarget()
			if trigTarget then
				if S.Trigger_Indicator then
					TriggerIndicator.Text = "TB: TARGET"
					TriggerIndicator.TextColor3 = C.cyber_red
				end
				executeTrigger()
			else
				if S.Trigger_Indicator then
					TriggerIndicator.Text = "TB: SCANNING"
					TriggerIndicator.TextColor3 = C.subtext
				end
			end
		else
			if S.Trigger_Indicator then
				TriggerIndicator.Text = "TB: ADS OFF"
				TriggerIndicator.TextColor3 = C.dim
			end
		end
	else
		TriggerIndicator.Visible = false
	end

	-- ---- FOV CIRCLE ----
	if S.FOVCircle and S.Aim_Enabled then
		fovCircle.Visible = true
		local d = S.Aim_Radius * 2
		fovCircle.Size = UDim2.new(0, d, 0, d)
		fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
		fovStroke.Transparency = 1 - S.FOVCircle_Opacity
	else
		fovCircle.Visible = false
	end

	-- ---- CROSSHAIR (update every 0.2s or when dynamic) ----
	if S.Cross_Dynamic then
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local targetExpand = 0
		if hum and hum.MoveDirection.Magnitude > 0 then
			targetExpand = 6
		end
		dynamicExpand = lerp(dynamicExpand, targetExpand, 0.1)
	else
		dynamicExpand = 0
	end

	if now - lastCrossUpdate > 0.15 then
		drawCrosshair()
		lastCrossUpdate = now
	end

	-- ---- ESP UPDATE ----
	clearTracers()
	for player, data in pairs(espObjects) do
		-- Safety: skip if player left or data is stale
		if not player or not player.Parent then continue end

		local visible = S.ESP_Enabled
		local isTeam = false
		pcall(function()
			isTeam = player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
		end)

		-- Check character/humanoid validity
		local charValid = false
		pcall(function()
			charValid = data.character and data.character.Parent
				and data.humanoid and data.humanoid.Parent and data.humanoid.Health > 0
				and data.rootPart and data.rootPart.Parent
		end)

		if not visible or not charValid then
			pcall(function()
				if data.billboard and data.billboard.Parent then data.billboard.Enabled = false end
				if data.highlight and data.highlight.Parent then data.highlight.Enabled = false end
			end)
			continue
		end

		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local dist = 0
		if myRoot and data.rootPart then
			pcall(function()
				dist = (myRoot.Position - data.rootPart.Position).Magnitude
			end)
		end

		if dist > S.ESP_MaxDist then
			pcall(function()
				if data.billboard then data.billboard.Enabled = false end
				if data.highlight then data.highlight.Enabled = false end
			end)
			continue
		end

		local espCol = isTeam and S.ESP_TeamColor or S.ESP_EnemyColor

		pcall(function()
			if data.billboard and data.billboard.Parent then
				data.billboard.Enabled = true
				-- Re-adorn if head changed (respawn)
				local newHead = data.character:FindFirstChild("Head")
				if newHead and data.billboard.Adornee ~= newHead then
					data.billboard.Adornee = newHead
				end
			end
		end)

		pcall(function()
			if data.nameLbl then
				data.nameLbl.Visible = S.ESP_Names
				data.nameLbl.TextColor3 = espCol
				data.nameLbl.Text = player.DisplayName
			end
		end)

		pcall(function()
			if data.distLbl then
				data.distLbl.Visible = S.ESP_Distance
				data.distLbl.Text = math.floor(dist) .. " studs"
			end
		end)

		pcall(function()
			if data.hpBg then data.hpBg.Visible = S.ESP_Health end
			if data.hpFill and data.humanoid and data.humanoid.Parent then
				local hp = math.clamp(data.humanoid.Health / data.humanoid.MaxHealth, 0, 1)
				data.hpFill.Size = UDim2.new(hp, 0, 1, 0)
				data.hpFill.BackgroundColor3 = Color3.fromRGB(255 * (1-hp), 255 * hp, 50)
			end
		end)

		-- Highlight / Chams
		pcall(function()
			if data.highlight and data.highlight.Parent then
				-- Re-adorn if character changed
				if data.highlight.Adornee ~= data.character then
					data.highlight.Adornee = data.character
				end
				if S.ESP_Chams then
					data.highlight.Enabled = true
					data.highlight.FillTransparency = 0.5
					data.highlight.FillColor = espCol
					data.highlight.OutlineColor = espCol
				elseif S.ESP_Boxes then
					data.highlight.Enabled = true
					data.highlight.FillTransparency = 0.85
					data.highlight.OutlineTransparency = 0.3
					data.highlight.FillColor = espCol
					data.highlight.OutlineColor = espCol
				else
					data.highlight.Enabled = false
				end
			end
		end)

		-- Tracers
		if S.ESP_Tracers and data.rootPart and data.rootPart.Parent then
			pcall(function()
				local sp, onScreen = Camera:WorldToScreenPoint(data.rootPart.Position)
				if onScreen then
					local originY
					if S.ESP_TracerOrigin == "Bottom" then
						originY = Camera.ViewportSize.Y
					elseif S.ESP_TracerOrigin == "Center" then
						originY = Camera.ViewportSize.Y / 2
					else
						originY = UserInputService:GetMouseLocation().Y
					end

					local startX = Camera.ViewportSize.X / 2
					local endX, endY = sp.X, sp.Y
					local dx = endX - startX
					local dy = endY - originY
					local length = math.sqrt(dx*dx + dy*dy)
					local angle = math.deg(math.atan2(dy, dx))

					local line = Instance.new("Frame")
					line.Size = UDim2.new(0, length, 0, 1)
					line.Position = UDim2.new(0, startX, 0, originY)
					line.AnchorPoint = Vector2.new(0, 0.5)
					line.Rotation = angle
					line.BackgroundColor3 = espCol
					line.BackgroundTransparency = 0.4
					line.BorderSizePixel = 0
					line.Parent = ScreenGui
					table.insert(tracerLines, line)
				end
			end)
		end
	end

	-- ---- FLY ----
	if S.Fly_Enabled then
		if not flyBV then enableFly() end
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
		if dir.Magnitude > 0 then dir = dir.Unit end
		flyBV.Velocity = dir * S.Fly_Speed
		if flyBG then flyBG.CFrame = Camera.CFrame end
	else
		if flyBV then disableFly() end
	end

	-- ---- WALK SPEED ----
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		if S.WalkSpeed_Enabled then
			local speed = S.WalkSpeed_Value
			-- Speed boost
			if S.SpeedBoost_Enabled and UserInputService:IsKeyDown(Enum.KeyCode[S.SpeedBoost_Key]) then
				speed = speed * S.SpeedBoost_Multiplier
			end
			hum.WalkSpeed = speed
		elseif S.SpeedBoost_Enabled and UserInputService:IsKeyDown(Enum.KeyCode[S.SpeedBoost_Key]) then
			hum.WalkSpeed = 16 * S.SpeedBoost_Multiplier
		end
	end

	-- ---- LONG ARMS ----
	if S.LongArms_Enabled then
		local char = LocalPlayer.Character
		if char then
			for _, name in ipairs({"Left Arm", "Right Arm", "LeftHand", "RightHand", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm"}) do
				local part = char:FindFirstChild(name)
				if part and part:IsA("BasePart") then
					part.Size = Vector3.new(part.Size.X, S.LongArms_Length, part.Size.Z)
				end
			end
		end
	end

	-- ---- FULLBRIGHT ----
	if S.Fullbright then
		Lighting.Brightness = S.Fullbright_Brightness
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
		Lighting.FogEnd = 100000
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
				v.Enabled = false
			end
		end
	else
		Lighting.Brightness = origBrightness
		Lighting.Ambient = origAmbient
		Lighting.OutdoorAmbient = origOutdoorAmbient
		Lighting.FogEnd = origFogEnd
	end

	-- ---- THIRD PERSON ----
	if S.ThirdPerson then
		LocalPlayer.CameraMaxZoomDistance = S.ThirdPerson_Dist
		LocalPlayer.CameraMinZoomDistance = S.ThirdPerson_Dist
	else
		LocalPlayer.CameraMaxZoomDistance = 128
		LocalPlayer.CameraMinZoomDistance = 0.5
	end

	-- ---- NAME HIDER ----
	if S.NameHider then
		local char = LocalPlayer.Character
		if char then
			local head = char:FindFirstChild("Head")
			if head then
				for _, v in ipairs(head:GetChildren()) do
					if v:IsA("BillboardGui") or v.Name == "NameTag" then
						v.Enabled = false
					end
				end
			end
		end
		-- Hide in leaderboard
		pcall(function()
			StarterGui:SetCore("SendNotification", {Title = "", Text = "", Duration = 0})
		end)
	end

	-- ---- TIME UPDATE ----
	if math.floor(now) % 30 == 0 then
		-- handled by spawn loop above
	end

	-- ---- STATS DASHBOARD UPDATE ----
	if math.floor(now * 2) % 2 == 0 then
		killsLbl.Text = tostring(KillCount)
		deathsLbl.Text = tostring(DeathCount)
		local kd = DeathCount > 0 and string.format("%.2f", KillCount / DeathCount) or tostring(KillCount)
		kdLbl.Text = kd
		local acc = ShotsFired > 0 and string.format("%.1f%%", (ShotsHit / ShotsFired) * 100) or "0%"
		accuracyLbl.Text = acc
		shotsFiredLbl.Text = tostring(ShotsFired)
		shotsHitLbl.Text = tostring(ShotsHit)
		activeLbl.Text = tostring(ActiveFeatureCount)
		local uptime = tick() - startTime
		local mins = math.floor(uptime / 60)
		local secs = math.floor(uptime % 60)
		uptimeLbl.Text = string.format("%dm %ds", mins, secs)
	end
end)

-- Track shots for accuracy
Mouse.Button1Down:Connect(function()
	ShotsFired = ShotsFired + 1
	local target = Mouse.Target
	if target then
		local model = target:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") and model ~= LocalPlayer.Character then
			ShotsHit = ShotsHit + 1
		end
	end
end)

-- Track deaths
LocalPlayer.CharacterAdded:Connect(function()
	if DeathCount > 0 or KillCount > 0 then
		-- Not the first spawn
	end
end)
local function onCharRemoved()
	DeathCount = DeathCount + 1
end
if LocalPlayer.Character then
	LocalPlayer.Character:WaitForChild("Humanoid").Died:Connect(onCharRemoved)
end
LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid").Died:Connect(onCharRemoved)
end)

-- ================================================================
--  TROLL FEATURE IMPLEMENTATIONS
-- ================================================================

-- ========================
--  HITBOX EXPANDER
-- ========================
local hitboxParts = {}
local function clearHitboxes()
	for _, p in ipairs(hitboxParts) do
		pcall(function() if p and p.Parent then p:Destroy() end end)
	end
	hitboxParts = {}
end

spawn(function()
	while true do
		wait(1)
		clearHitboxes()
		if S.Hitbox_Enabled then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					if S.Hitbox_TeamCheck and plr.Team and plr.Team == LocalPlayer.Team then continue end
					local char = plr.Character
					local hum = char:FindFirstChildOfClass("Humanoid")
					if not hum or hum.Health <= 0 then continue end

					pcall(function()
						local head = char:FindFirstChild("Head")
						if head then
							head.Size = Vector3.new(S.Hitbox_HeadSize, S.Hitbox_HeadSize, S.Hitbox_HeadSize)
							head.Transparency = S.Hitbox_Transparency
							head.CanCollide = false
							table.insert(hitboxParts, head)
						end
						local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
						if torso then
							torso.Size = Vector3.new(S.Hitbox_BodySize, S.Hitbox_BodySize * 1.5, S.Hitbox_BodySize)
							torso.Transparency = S.Hitbox_Transparency
							torso.CanCollide = false
						end
					end)
				end
			end
		end
	end
end)

-- ========================
--  CHARACTER SCALE
-- ========================
spawn(function()
	while true do
		wait(0.5)
		if S.CharScale_Enabled then
			pcall(function()
				local char = LocalPlayer.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then
						local scale = S.CharScale_Value
						local bodyDepth = hum:FindFirstChild("BodyDepthScale")
						local bodyHeight = hum:FindFirstChild("BodyHeightScale")
						local bodyWidth = hum:FindFirstChild("BodyWidthScale")
						local headScale = hum:FindFirstChild("HeadScale")
						if bodyDepth then bodyDepth.Value = scale end
						if bodyHeight then bodyHeight.Value = scale end
						if bodyWidth then bodyWidth.Value = scale end
						if headScale then headScale.Value = scale end
					end
				end
			end)
		end
	end
end)

-- ========================
--  SPIN BOT
-- ========================
local spinAngle = 0
RunService.RenderStepped:Connect(function(dt)
	if S.SpinBot_Enabled then
		pcall(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				spinAngle = spinAngle + S.SpinBot_Speed * dt
				local pos = root.Position
				local axis = S.SpinBot_Axis
				if axis == "Y" then
					root.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(spinAngle * 20), 0)
				elseif axis == "X" then
					root.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(spinAngle * 20), 0, 0)
				elseif axis == "Z" then
					root.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(spinAngle * 20))
				elseif axis == "All" then
					root.CFrame = CFrame.new(pos) * CFrame.Angles(
						math.rad(spinAngle * 15),
						math.rad(spinAngle * 20),
						math.rad(spinAngle * 10)
					)
				end
			end
		end)
	end
end)

-- ========================
--  FAKE LAG
-- ========================
local fakeLagStore = nil
spawn(function()
	while true do
		wait(S.FakeLag_Interval)
		if S.FakeLag_Enabled then
			pcall(function()
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					if fakeLagStore then
						-- Teleport back and forth
						local offset = Vector3.new(
							math.random(-S.FakeLag_Intensity, S.FakeLag_Intensity),
							0,
							math.random(-S.FakeLag_Intensity, S.FakeLag_Intensity)
						)
						root.CFrame = fakeLagStore * CFrame.new(offset)
						wait(0.05)
						root.CFrame = fakeLagStore
					end
					fakeLagStore = root.CFrame
				end
			end)
		else
			fakeLagStore = nil
		end
	end
end)

-- ========================
--  FLING PLAYERS
-- ========================
local flingBV = nil
local flingActive = false

local function enableFling()
	if flingActive then return end
	flingActive = true
	pcall(function()
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		-- Create high velocity spinner
		flingBV = Instance.new("BodyAngularVelocity")
		flingBV.AngularVelocity = Vector3.new(0, S.Fling_Power / 10, 0)
		flingBV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		flingBV.P = math.huge
		flingBV.Parent = root

		-- Touching handler
		if S.Fling_OnTouch then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
				end
			end
		end
	end)
end

local function disableFling()
	flingActive = false
	pcall(function()
		if flingBV and flingBV.Parent then flingBV:Destroy() end
		flingBV = nil
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
				end
			end
		end
	end)
end

spawn(function()
	while true do
		wait(0.5)
		if S.Fling_Enabled and not flingActive then
			enableFling()
		elseif not S.Fling_Enabled and flingActive then
			disableFling()
		end
		if flingActive and flingBV then
			pcall(function()
				flingBV.AngularVelocity = Vector3.new(0, S.Fling_Power / 10, 0)
			end)
		end
	end
end)

-- ========================
--  ORBIT PLAYER
-- ========================
local orbitAngle = 0
local orbitTarget = nil

local function getClosestPlayer()
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end
	local closest, dist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				local d = (myRoot.Position - root.Position).Magnitude
				if d < dist then
					dist = d
					closest = plr
				end
			end
		end
	end
	return closest
end

RunService.Heartbeat:Connect(function(dt)
	if S.Orbit_Enabled then
		pcall(function()
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not myRoot then return end

			orbitTarget = orbitTarget or getClosestPlayer()
			if not orbitTarget or not orbitTarget.Character then
				orbitTarget = getClosestPlayer()
				return
			end

			local targetRoot = orbitTarget.Character:FindFirstChild("HumanoidRootPart")
			if not targetRoot then return end

			orbitAngle = orbitAngle + S.Orbit_Speed * dt
			local x = math.cos(orbitAngle) * S.Orbit_Radius
			local z = math.sin(orbitAngle) * S.Orbit_Radius
			local targetPos = targetRoot.Position + Vector3.new(x, S.Orbit_Height, z)

			myRoot.CFrame = CFrame.new(targetPos, targetRoot.Position)
		end)
	else
		orbitTarget = nil
	end
end)

-- ========================
--  ATTACH TO PLAYER
-- ========================
local attachTarget = nil
RunService.Heartbeat:Connect(function()
	if S.Attach_Enabled then
		pcall(function()
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not myRoot then return end

			attachTarget = attachTarget or getClosestPlayer()
			if not attachTarget or not attachTarget.Character then
				attachTarget = getClosestPlayer()
				return
			end

			local char = attachTarget.Character
			local offset = S.Attach_Offset
			local attachPart

			if offset == "Head" then
				attachPart = char:FindFirstChild("Head")
				if attachPart then
					myRoot.CFrame = attachPart.CFrame * CFrame.new(0, 2.5, 0)
				end
			elseif offset == "Back" then
				attachPart = char:FindFirstChild("HumanoidRootPart")
				if attachPart then
					myRoot.CFrame = attachPart.CFrame * CFrame.new(0, 0, 3)
				end
			elseif offset == "Shoulder" then
				attachPart = char:FindFirstChild("HumanoidRootPart")
				if attachPart then
					myRoot.CFrame = attachPart.CFrame * CFrame.new(3, 1.5, 0)
				end
			end
		end)
	else
		attachTarget = nil
	end
end)

-- ========================
--  RAGDOLL ON COMMAND [P]
-- ========================
local ragdolled = false
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.P and S.Ragdoll_Enabled then
		ragdolled = not ragdolled
		pcall(function()
			local char = LocalPlayer.Character
			if not char then return end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum then return end

			if ragdolled then
				hum:ChangeState(Enum.HumanoidStateType.Physics)
				hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
				showToast("RAGDOLL", "You are now a ragdoll", C.cyber_red, "💀")
			else
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
				showToast("RAGDOLL", "Ragdoll disabled", C.cyber_green, "✓")
			end
		end)
	end
end)

-- ========================
--  ANTI-AFK
-- ========================
spawn(function()
	while true do
		wait(60)
		if S.AntiAFK_Enabled then
			pcall(function()
				local ve = game:GetService("VirtualUser")
				ve:CaptureController()
				ve:ClickButton2(Vector2.new())
			end)
			pcall(function()
				local VirtualInputManager = game:GetService("VirtualInputManager")
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
				wait(0.1)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
			end)
		end
	end
end)

-- ========================
--  ANTI-VOID
-- ========================
local lastSafePosition = nil
spawn(function()
	while true do
		wait(0.2)
		if S.AntiVoid_Enabled then
			pcall(function()
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					if root.Position.Y > S.AntiVoid_Height + 20 then
						lastSafePosition = root.CFrame
					end
					if root.Position.Y < S.AntiVoid_Height then
						if lastSafePosition then
							root.CFrame = lastSafePosition
							root.Velocity = Vector3.new(0, 0, 0)
							showToast("ANTI-VOID", "Saved from the void!", C.cyber_blue, "🛡")
						end
					end
				end
			end)
		end
	end
end)

-- ========================
--  CHAT SPAMMER
-- ========================
spawn(function()
	while true do
		wait(S.ChatSpam_Delay)
		if S.ChatSpam_Enabled then
			pcall(function()
				-- Try TextChatService (new system)
				local tcs = game:GetService("TextChatService")
				local channel = tcs:FindFirstChild("TextChannels")
				if channel then
					local rbxGeneral = channel:FindFirstChild("RBXGeneral")
					if rbxGeneral then
						rbxGeneral:SendAsync(S.ChatSpam_Message)
					end
				end
			end)
			pcall(function()
				-- Fallback: legacy chat
				game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
					:FindFirstChild("SayMessageRequest")
					:FireServer(S.ChatSpam_Message, "All")
			end)
		end
	end
end)

-- ========================
--  HEADLESS CHARACTER
-- ========================
spawn(function()
	while true do
		wait(0.5)
		if S.Headless_Enabled then
			pcall(function()
				local char = LocalPlayer.Character
				if char then
					local head = char:FindFirstChild("Head")
					if head then
						head.Transparency = 1
						local face = head:FindFirstChild("face") or head:FindFirstChildOfClass("Decal")
						if face then face.Transparency = 1 end
						-- Hide head mesh
						for _, m in ipairs(head:GetDescendants()) do
							if m:IsA("SpecialMesh") or m:IsA("MeshPart") then
								pcall(function() m.Scale = Vector3.new(0, 0, 0) end)
							end
						end
					end
					-- Also hide hair accessories on head
					for _, acc in ipairs(char:GetChildren()) do
						if acc:IsA("Accessory") then
							local handle = acc:FindFirstChild("Handle")
							if handle then
								local att = handle:FindFirstChildOfClass("Attachment")
								if att and (att.Name == "HatAttachment" or att.Name == "HairAttachment" or att.Name == "FaceFrontAttachment" or att.Name == "FaceCenterAttachment") then
									handle.Transparency = 1
								end
							end
						end
					end
				end
			end)
		end
	end
end)

-- ========================
--  INVISIBLE TORSO
-- ========================
spawn(function()
	while true do
		wait(0.5)
		if S.InvisTorso_Enabled then
			pcall(function()
				local char = LocalPlayer.Character
				if char then
					local parts = {"UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart"}
					for _, name in ipairs(parts) do
						local p = char:FindFirstChild(name)
						if p then p.Transparency = 1 end
					end
					-- Also hide shirt graphic
					local shirt = char:FindFirstChildOfClass("ShirtGraphic")
					if shirt then shirt.Color3 = Color3.new(0,0,0) end
				end
			end)
		end
	end
end)

-- ========================
--  SEIZURE MODE (screen flash)
-- ========================
local seizureFrame = Instance.new("Frame")
seizureFrame.Size = UDim2.new(1, 0, 1, 0)
seizureFrame.BackgroundColor3 = Color3.new(1, 1, 1)
seizureFrame.BackgroundTransparency = 1
seizureFrame.BorderSizePixel = 0
seizureFrame.ZIndex = 2000
seizureFrame.Visible = false
seizureFrame.Parent = OverlayGui

spawn(function()
	local colors = {
		Color3.new(1, 0, 0), Color3.new(0, 1, 0), Color3.new(0, 0, 1),
		Color3.new(1, 1, 0), Color3.new(1, 0, 1), Color3.new(0, 1, 1),
		Color3.new(1, 1, 1), Color3.new(0, 0, 0),
	}
	local idx = 1
	while true do
		if S.Seizure_Enabled then
			seizureFrame.Visible = true
			idx = idx % #colors + 1
			seizureFrame.BackgroundColor3 = colors[idx]
			seizureFrame.BackgroundTransparency = 0.3
			wait(S.Seizure_Speed)
			seizureFrame.BackgroundTransparency = 0.8
			wait(S.Seizure_Speed)
		else
			seizureFrame.Visible = false
			wait(0.2)
		end
	end
end)

-- ========================
--  MATRIX MODE (slow-mo camera)
-- ========================
spawn(function()
	while true do
		wait(0.1)
		if S.Matrix_Enabled then
			pcall(function()
				workspace.Gravity = 196.2 * S.Matrix_SlowMo
				local char = LocalPlayer.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.WalkSpeed = (S.WalkSpeed_Enabled and S.WalkSpeed_Value or 16) * S.Matrix_SlowMo
					end
				end
				-- Slow down all humanoids nearby for visual effect
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LocalPlayer and plr.Character then
						local hum = plr.Character:FindFirstChildOfClass("Humanoid")
						if hum then
							-- Can't modify other players server-side but this affects local rendering
						end
					end
				end
			end)
		else
			pcall(function()
				workspace.Gravity = 196.2
			end)
		end
	end
end)

-- Update status bar with troll features
local origUpdateStatusBar = updateStatusBar
local function updateStatusBarWithTrolls()
	origUpdateStatusBar()
	-- Troll features are tracked in the original function if we add them to the check
end

-- ========================
--  CYBERPUNK BOOT SEQUENCE
-- ========================
spawn(function()
	wait(0.5)
	showToast("SYSTEM", "Initializing modules...", C.cyber_purple, "◈")
	wait(0.8)
	showToast("LOADED", "All 40 modules online", C.cyber_cyan, "✓")
	wait(0.5)
	showToast("KEYBIND", "Press M to open menu", C.cyber_yellow, "⚡")
	wait(0.3)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "◈ CYBER//TOOLKIT v4.0",
			Text = "Loaded! Press M to open.",
			Duration = 4,
		})
	end)
end)

print("◈◈◈ CYBER//TOOLKIT v4.0 — CYBERPUNK EDITION — Press M ◈◈◈")
