--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                      ADMIN MENU v3.0                        ║
    ║           Full-Featured Admin Panel with Tabs                ║
    ║                                                              ║
    ║  Load via loadstring or place as LocalScript                 ║
    ║  Toggle Key: RightShift                                      ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

--------------------------------------------------------------------------------
-- SERVICES
--------------------------------------------------------------------------------
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local Lighting           = game:GetService("Lighting")
local Workspace          = game:GetService("Workspace")
local StarterGui         = game:GetService("StarterGui")
local Camera             = Workspace.CurrentCamera

--------------------------------------------------------------------------------
-- LOCAL PLAYER
--------------------------------------------------------------------------------
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- CONFIG / THEME
--------------------------------------------------------------------------------
local C = {
    TOGGLE_KEY     = Enum.KeyCode.RightShift,
    MENU_W         = 420,
    MENU_H         = 560,
    ANIM           = 0.28,
    TAB_H          = 32,
    -- Theme
    BG1            = Color3.fromRGB(14, 14, 20),
    BG2            = Color3.fromRGB(20, 20, 28),
    BG3            = Color3.fromRGB(28, 28, 38),
    BG4            = Color3.fromRGB(36, 36, 48),
    ACCENT         = Color3.fromRGB(88, 101, 242),
    ACCENT2        = Color3.fromRGB(138, 101, 242),
    GREEN          = Color3.fromRGB(67, 181, 129),
    RED            = Color3.fromRGB(237, 66, 69),
    ORANGE         = Color3.fromRGB(250, 166, 26),
    TEXT1          = Color3.fromRGB(235, 235, 245),
    TEXT2          = Color3.fromRGB(150, 150, 170),
    TEXT3          = Color3.fromRGB(100, 100, 120),
    DIVIDER        = Color3.fromRGB(42, 42, 56),
    BORDER         = Color3.fromRGB(48, 48, 64),
    TOGGLE_ON      = Color3.fromRGB(67, 181, 129),
    TOGGLE_OFF     = Color3.fromRGB(62, 62, 78),
    SLIDER_TRACK   = Color3.fromRGB(48, 48, 64),
}

--------------------------------------------------------------------------------
-- GLOBAL STATE
--------------------------------------------------------------------------------
local S = {
    menuOpen = true, minimized = false, dragging = false,
    dragStart = nil, startPos = nil,
    -- Feature states
    esp = false, chams = false, tracers = false, espTags = false,
    aimbot = false, killAura = false,
    fly = false, noclip = false, infJump = false, speedBoost = false, freecam = false,
    fullbright = false, antiAfk = false,
    -- Values
    walkSpeed = 16, jumpPower = 50, flySpeed = 60, fovRadius = 150,
    boostSpeed = 80, killAuraRange = 15, charScale = 1, charTransparency = 0,
    -- Runtime
    conn = {}, highlights = {}, chamsHL = {}, tracerLines = {}, espTagGuis = {},
    origLighting = {}, flyBV = nil, flyBG = nil,
    freecamCF = nil, freecamActive = false, origCamType = nil,
    -- Keybinds
    keybinds = {
        esp = Enum.KeyCode.E,
        fly = Enum.KeyCode.F,
        noclip = Enum.KeyCode.V,
        aimbot = Enum.KeyCode.Q,
        freecam = Enum.KeyCode.G,
    },
    keybindListening = nil,  -- which keybind is being rebound
    -- Tab
    activeTab = "Visuals",
    tabFrames = {},
    allRows = {},            -- for search
}

--------------------------------------------------------------------------------
-- UTILITY
--------------------------------------------------------------------------------
local function tw(obj, props, dur, style, dir)
    dur = dur or C.ANIM; style = style or Enum.EasingStyle.Quint; dir = dir or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(dur, style, dir), props); t:Play(); return t
end

local function getHum()
    local ch = LocalPlayer.Character; return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local ch = LocalPlayer.Character; return ch and ch:FindFirstChild("HumanoidRootPart")
end
local function disconn(k)
    if S.conn[k] then S.conn[k]:Disconnect(); S.conn[k] = nil end
end
local function otherChars()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then table.insert(t, {player = p, char = p.Character}) end
        end
    end
    return t
end
local function nearestInFov()
    local best, bestDist = nil, math.huge
    local ctr = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, d in ipairs(otherChars()) do
        local head = d.char:FindFirstChild("Head")
        if head then
            local sp, vis = Camera:WorldToScreenPoint(head.Position)
            if vis then
                local dist = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
                if dist <= S.fovRadius and dist < bestDist then best = d.char; bestDist = dist end
            end
        end
    end
    return best
end

--------------------------------------------------------------------------------
-- SCREENGUI
--------------------------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "AdminMenuV3"; Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; Gui.Parent = PlayerGui

--------------------------------------------------------------------------------
-- MAIN FRAME
--------------------------------------------------------------------------------
local Main = Instance.new("Frame")
Main.Name = "Main"; Main.Size = UDim2.new(0, C.MENU_W, 0, C.MENU_H)
Main.Position = UDim2.new(0.5, -C.MENU_W/2, 0.5, -C.MENU_H/2)
Main.BackgroundColor3 = C.BG1; Main.BackgroundTransparency = 0.02
Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke", Main); ms.Color = C.BORDER; ms.Thickness = 1.5; ms.Transparency = 0.3

-- Gradient
local mg = Instance.new("UIGradient", Main)
mg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,210))})
mg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.97), NumberSequenceKeypoint.new(1, 1)})
mg.Rotation = 135

--------------------------------------------------------------------------------
-- TITLE BAR
--------------------------------------------------------------------------------
local TB = Instance.new("Frame", Main)
TB.Name = "TitleBar"; TB.Size = UDim2.new(1, 0, 0, 40)
TB.BackgroundColor3 = C.BG2; TB.BorderSizePixel = 0
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 10)
-- bottom cover
local tbc = Instance.new("Frame", TB); tbc.Size = UDim2.new(1,0,0,12); tbc.Position = UDim2.new(0,0,1,-12)
tbc.BackgroundColor3 = C.BG2; tbc.BorderSizePixel = 0

-- accent line
local al = Instance.new("Frame", TB); al.Size = UDim2.new(1,0,0,2); al.Position = UDim2.new(0,0,1,0)
al.BackgroundColor3 = C.ACCENT; al.BorderSizePixel = 0
local alg = Instance.new("UIGradient", al)
alg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.ACCENT), ColorSequenceKeypoint.new(0.5, C.ACCENT2), ColorSequenceKeypoint.new(1, C.ACCENT)})

-- title
local tl = Instance.new("TextLabel", TB); tl.Size = UDim2.new(1,-100,1,0); tl.Position = UDim2.new(0,14,0,0)
tl.BackgroundTransparency = 1; tl.Text = "⚡ Admin Menu"; tl.TextColor3 = C.TEXT1
tl.TextSize = 15; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left

-- version
local vl = Instance.new("TextLabel", TB); vl.Size = UDim2.new(0,36,0,16); vl.Position = UDim2.new(0,128,0.5,-8)
vl.BackgroundColor3 = C.BG3; vl.Text = "v3.0"; vl.TextColor3 = C.TEXT2; vl.TextSize = 10
vl.Font = Enum.Font.GothamMedium; vl.BorderSizePixel = 0; Instance.new("UICorner", vl).CornerRadius = UDim.new(0,4)

-- Minimize btn
local function mkTitleBtn(text, pos, col)
    local b = Instance.new("TextButton", TB); b.Size = UDim2.new(0,26,0,26); b.Position = pos
    b.BackgroundColor3 = col or C.BG3; b.BackgroundTransparency = 0.2; b.Text = text
    b.TextColor3 = C.TEXT1; b.TextSize = 13; b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0
    b.AutoButtonColor = false; Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency = 0}, 0.12) end)
    b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = 0.2}, 0.12) end)
    return b
end

local MinBtn   = mkTitleBtn("─", UDim2.new(1,-62,0.5,-13))
local CloseBtn = mkTitleBtn("✕", UDim2.new(1,-32,0.5,-13), C.RED)

--------------------------------------------------------------------------------
-- SEARCH BAR
--------------------------------------------------------------------------------
local SearchFrame = Instance.new("Frame", Main)
SearchFrame.Name = "Search"; SearchFrame.Size = UDim2.new(1,-16,0,28)
SearchFrame.Position = UDim2.new(0,8,0,44); SearchFrame.BackgroundColor3 = C.BG3
SearchFrame.BorderSizePixel = 0; Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0,6)

local SearchIcon = Instance.new("TextLabel", SearchFrame)
SearchIcon.Size = UDim2.new(0,28,1,0); SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"; SearchIcon.TextSize = 13; SearchIcon.Font = Enum.Font.GothamMedium

local SearchBox = Instance.new("TextBox", SearchFrame)
SearchBox.Size = UDim2.new(1,-36,1,0); SearchBox.Position = UDim2.new(0,30,0,0)
SearchBox.BackgroundTransparency = 1; SearchBox.PlaceholderText = "Search features..."
SearchBox.PlaceholderColor3 = C.TEXT3; SearchBox.Text = ""; SearchBox.TextColor3 = C.TEXT1
SearchBox.TextSize = 12; SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextXAlignment = Enum.TextXAlignment.Left; SearchBox.ClearTextOnFocus = false

--------------------------------------------------------------------------------
-- TAB BAR
--------------------------------------------------------------------------------
local TabBar = Instance.new("Frame", Main)
TabBar.Name = "TabBar"; TabBar.Size = UDim2.new(1,-16,0, C.TAB_H)
TabBar.Position = UDim2.new(0,8,0,76); TabBar.BackgroundTransparency = 1; TabBar.BorderSizePixel = 0

local tabLayout = Instance.new("UIListLayout", TabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)

local TABS = {"Visuals", "Combat", "Movement", "Players", "World", "Config"}
local tabButtons = {}

local function switchTab(name)
    S.activeTab = name
    for tName, frame in pairs(S.tabFrames) do
        frame.Visible = (tName == name)
    end
    for tName, btn in pairs(tabButtons) do
        if tName == name then
            tw(btn, {BackgroundColor3 = C.ACCENT, BackgroundTransparency = 0}, 0.15)
            tw(btn, {TextColor3 = Color3.new(1,1,1)}, 0.15)
        else
            tw(btn, {BackgroundColor3 = C.BG3, BackgroundTransparency = 0.3}, 0.15)
            tw(btn, {TextColor3 = C.TEXT2}, 0.15)
        end
    end
end

for i, name in ipairs(TABS) do
    local btn = Instance.new("TextButton", TabBar)
    btn.Name = name; btn.Size = UDim2.new(0, 62, 1, 0); btn.LayoutOrder = i
    btn.BackgroundColor3 = (i == 1) and C.ACCENT or C.BG3
    btn.BackgroundTransparency = (i == 1) and 0 or 0.3
    btn.Text = name; btn.TextColor3 = (i == 1) and Color3.new(1,1,1) or C.TEXT2
    btn.TextSize = 11; btn.Font = Enum.Font.GothamBold; btn.BorderSizePixel = 0
    btn.AutoButtonColor = false; Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    tabButtons[name] = btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

--------------------------------------------------------------------------------
-- TAB CONTENT FRAMES
--------------------------------------------------------------------------------
local contentY = 76 + C.TAB_H + 4
local contentH = C.MENU_H - contentY - 4

local function mkTabContent(name, order)
    local sf = Instance.new("ScrollingFrame", Main)
    sf.Name = "Tab_"..name; sf.Size = UDim2.new(1,-16,0, contentH)
    sf.Position = UDim2.new(0,8,0, contentY); sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0; sf.ScrollBarThickness = 3; sf.ScrollBarImageColor3 = C.ACCENT
    sf.ScrollBarImageTransparency = 0.4; sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize = UDim2.new(0,0,0,0); sf.Visible = (name == "Visuals")
    sf.ClipsDescendants = true
    local ly = Instance.new("UIListLayout", sf); ly.Padding = UDim.new(0,3); ly.SortOrder = Enum.SortOrder.LayoutOrder
    local pd = Instance.new("UIPadding", sf); pd.PaddingTop = UDim.new(0,2); pd.PaddingBottom = UDim.new(0,8)
    S.tabFrames[name] = sf
    return sf
end

for _, name in ipairs(TABS) do mkTabContent(name) end

--------------------------------------------------------------------------------
-- UI BUILDERS
--------------------------------------------------------------------------------
local orderCounters = {}
local function nextOrd(tab)
    orderCounters[tab] = (orderCounters[tab] or 0) + 1; return orderCounters[tab]
end

local function mkSection(tab, text)
    local p = S.tabFrames[tab]; if not p then return end
    local f = Instance.new("Frame", p); f.Size = UDim2.new(1,0,0,26); f.BackgroundTransparency = 1; f.LayoutOrder = nextOrd(tab)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,-8,1,0); l.Position = UDim2.new(0,6,0,0)
    l.BackgroundTransparency = 1; l.Text = string.upper(text); l.TextColor3 = C.ACCENT
    l.TextSize = 10; l.Font = Enum.Font.GothamBold; l.TextXAlignment = Enum.TextXAlignment.Left; l.TextYAlignment = Enum.TextYAlignment.Bottom
    local line = Instance.new("Frame", f); line.Size = UDim2.new(1,-8,0,1); line.Position = UDim2.new(0,4,1,-1)
    line.BackgroundColor3 = C.DIVIDER; line.BorderSizePixel = 0
end

local function mkToggle(tab, label, default, cb)
    local p = S.tabFrames[tab]; if not p then return end
    local on = default or false

    local row = Instance.new("Frame", p); row.Name = "Toggle_"..label; row.Size = UDim2.new(1,0,0,34)
    row.BackgroundColor3 = C.BG2; row.BackgroundTransparency = 0.4; row.BorderSizePixel = 0; row.LayoutOrder = nextOrd(tab)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(1,-66,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C.TEXT1
    lbl.TextSize = 12; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row); track.Size = UDim2.new(0,38,0,20); track.Position = UDim2.new(1,-50,0.5,-10)
    track.BackgroundColor3 = on and C.TOGGLE_ON or C.TOGGLE_OFF; track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", track); knob.Size = UDim2.new(0,14,0,14)
    knob.Position = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""

    local function setVis(v)
        tw(track, {BackgroundColor3 = v and C.TOGGLE_ON or C.TOGGLE_OFF}, 0.18)
        tw(knob, {Position = v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}, 0.18, Enum.EasingStyle.Back)
    end

    btn.MouseButton1Click:Connect(function() on = not on; setVis(on); if cb then cb(on) end end)
    btn.MouseEnter:Connect(function() tw(row, {BackgroundTransparency = 0.15}, 0.1) end)
    btn.MouseLeave:Connect(function() tw(row, {BackgroundTransparency = 0.4}, 0.1) end)

    -- Register for search
    table.insert(S.allRows, {frame = row, label = label:lower(), tab = tab})
    return setVis, function() return on end, function(v) on = v; setVis(v); if cb then cb(v) end end
end

local function mkSlider(tab, label, min, max, default, cb)
    local p = S.tabFrames[tab]; if not p then return end
    local val = default or min

    local row = Instance.new("Frame", p); row.Name = "Slider_"..label; row.Size = UDim2.new(1,0,0,46)
    row.BackgroundColor3 = C.BG2; row.BackgroundTransparency = 0.4; row.BorderSizePixel = 0; row.LayoutOrder = nextOrd(tab)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.6,0,0,18); lbl.Position = UDim2.new(0,10,0,3)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C.TEXT1; lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local vl2 = Instance.new("TextLabel", row); vl2.Size = UDim2.new(0.35,0,0,18); vl2.Position = UDim2.new(0.6,0,0,3)
    vl2.BackgroundTransparency = 1; vl2.Text = tostring(math.floor(val)); vl2.TextColor3 = C.ACCENT
    vl2.TextSize = 12; vl2.Font = Enum.Font.GothamBold; vl2.TextXAlignment = Enum.TextXAlignment.Right

    local trk = Instance.new("Frame", row); trk.Size = UDim2.new(1,-20,0,5); trk.Position = UDim2.new(0,10,0,30)
    trk.BackgroundColor3 = C.SLIDER_TRACK; trk.BorderSizePixel = 0; Instance.new("UICorner", trk).CornerRadius = UDim.new(1,0)

    local pct = (val - min)/(max - min)
    local fill = Instance.new("Frame", trk); fill.Size = UDim2.new(pct,0,1,0); fill.BackgroundColor3 = C.ACCENT; fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local sk = Instance.new("Frame", trk); sk.Size = UDim2.new(0,12,0,12); sk.Position = UDim2.new(pct,-6,0.5,-6)
    sk.BackgroundColor3 = Color3.new(1,1,1); sk.BorderSizePixel = 0; sk.ZIndex = 2
    Instance.new("UICorner", sk).CornerRadius = UDim.new(1,0)
    local sks = Instance.new("UIStroke", sk); sks.Color = C.ACCENT; sks.Thickness = 2

    local dragging = false
    local function upd(p2)
        p2 = math.clamp(p2,0,1); val = math.floor(min+(max-min)*p2)
        vl2.Text = tostring(val); fill.Size = UDim2.new(p2,0,1,0); sk.Position = UDim2.new(p2,-6,0.5,-6)
        if cb then cb(val) end
    end

    local sb = Instance.new("TextButton", trk); sb.Size = UDim2.new(1,0,0,20); sb.Position = UDim2.new(0,0,0,-8)
    sb.BackgroundTransparency = 1; sb.Text = ""
    sb.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mx = UserInputService:GetMouseLocation().X
            upd((mx - trk.AbsolutePosition.X) / trk.AbsoluteSize.X)
        end
    end)

    table.insert(S.allRows, {frame = row, label = label:lower(), tab = tab})
    return function(n) upd(math.clamp((n-min)/(max-min),0,1)) end
end

--- Keybind button
local function mkKeybind(tab, label, stateKey)
    local p = S.tabFrames[tab]; if not p then return end

    local row = Instance.new("Frame", p); row.Name = "Keybind_"..label; row.Size = UDim2.new(1,0,0,34)
    row.BackgroundColor3 = C.BG2; row.BackgroundTransparency = 0.4; row.BorderSizePixel = 0; row.LayoutOrder = nextOrd(tab)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C.TEXT1; lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local kbtn = Instance.new("TextButton", row); kbtn.Size = UDim2.new(0, 80, 0, 22); kbtn.Position = UDim2.new(1, -90, 0.5, -11)
    kbtn.BackgroundColor3 = C.BG4; kbtn.BorderSizePixel = 0; kbtn.AutoButtonColor = false
    kbtn.Text = S.keybinds[stateKey] and S.keybinds[stateKey].Name or "None"
    kbtn.TextColor3 = C.ORANGE; kbtn.TextSize = 11; kbtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", kbtn).CornerRadius = UDim.new(0,4)

    kbtn.MouseButton1Click:Connect(function()
        kbtn.Text = "..."
        kbtn.TextColor3 = C.RED
        S.keybindListening = stateKey

        local c; c = UserInputService.InputBegan:Connect(function(input, gp)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                S.keybinds[stateKey] = input.KeyCode
                kbtn.Text = input.KeyCode.Name
                kbtn.TextColor3 = C.ORANGE
                S.keybindListening = nil
                c:Disconnect()
            end
        end)
    end)

    table.insert(S.allRows, {frame = row, label = label:lower(), tab = tab})
end

--- Player list button row
local function mkPlayerBtn(tab, playerName, callback)
    local p = S.tabFrames[tab]; if not p then return end

    local row = Instance.new("Frame", p); row.Name = "Player_"..playerName; row.Size = UDim2.new(1,0,0,34)
    row.BackgroundColor3 = C.BG2; row.BackgroundTransparency = 0.4; row.BorderSizePixel = 0; row.LayoutOrder = nextOrd(tab)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.45,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = playerName; lbl.TextColor3 = C.TEXT1; lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local function mkSmallBtn(text, xPos, col, cb2)
        local b = Instance.new("TextButton", row); b.Size = UDim2.new(0,55,0,20); b.Position = UDim2.new(1, xPos, 0.5, -10)
        b.BackgroundColor3 = col; b.BackgroundTransparency = 0.2; b.Text = text; b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 10; b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0; b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
        b.MouseButton1Click:Connect(function() cb2() end)
        return b
    end

    mkSmallBtn("Teleport", -130, C.ACCENT, function()
        local target = Players:FindFirstChild(playerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3) end
        end
    end)

    mkSmallBtn("Spectate", -70, C.ACCENT2, function()
        local target = Players:FindFirstChild(playerName)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
        end
    end)

    local unspecBtn = mkSmallBtn("Unspec", -10, C.BG4, function()
        local hum = getHum()
        if hum then Camera.CameraSubject = hum end
    end)

    return row
end

--------------------------------------------------------------------------------
-- BUILD TABS
--------------------------------------------------------------------------------

-- ██ VISUALS TAB ██
mkSection("Visuals", "Player ESP")
local setEspVis, getEsp, forceEsp = mkToggle("Visuals", "ESP / Wallhack", false, function(v) S.esp = v end)
local setChamsVis, getChams, forceChams = mkToggle("Visuals", "Chams (Colored Fill)", false, function(v) S.chams = v end)
local setTracersVis, getTracers, forceTracers = mkToggle("Visuals", "Tracers (Lines to Players)", false, function(v) S.tracers = v end)
local setTagsVis, getTags, forceTags = mkToggle("Visuals", "ESP Tags (Name/HP/Dist)", false, function(v) S.espTags = v end)
mkSection("Visuals", "Rendering")
local setFbVis, getFb, forceFb = mkToggle("Visuals", "Fullbright", false, function(v) S.fullbright = v end)

-- ██ COMBAT TAB ██
mkSection("Combat", "Aim Assist")
local setAbVis, getAb, forceAb = mkToggle("Combat", "Aimbot (Hold RMB)", false, function(v) S.aimbot = v end)
local setFovSlider = mkSlider("Combat", "FOV Radius", 50, 400, 150, function(v) S.fovRadius = v end)
mkSection("Combat", "Auto")
local setKaVis, getKa, forceKa = mkToggle("Combat", "Kill Aura", false, function(v) S.killAura = v end)
local setKaRange = mkSlider("Combat", "Aura Range", 5, 30, 15, function(v) S.killAuraRange = v end)

-- ██ MOVEMENT TAB ██
mkSection("Movement", "Flight")
local setFlyVis, getFly, forceFly = mkToggle("Movement", "Fly", false, function(v) S.fly = v end)
local setFlySpd = mkSlider("Movement", "Fly Speed", 10, 300, 60, function(v) S.flySpeed = v end)
mkSection("Movement", "Speed")
local setWsSlider = mkSlider("Movement", "WalkSpeed", 16, 200, 16, function(v)
    S.walkSpeed = v; local h = getHum(); if h then h.WalkSpeed = v end
end)
local setJpSlider = mkSlider("Movement", "JumpPower", 50, 300, 50, function(v)
    S.jumpPower = v; local h = getHum(); if h then h.UseJumpPower = true; h.JumpPower = v end
end)
local setBoostVis, getBoost, forceBoost = mkToggle("Movement", "Speed Boost (CFrame)", false, function(v) S.speedBoost = v end)
local setBoostSlider = mkSlider("Movement", "Boost Speed", 20, 200, 80, function(v) S.boostSpeed = v end)
mkSection("Movement", "Collision & Jump")
local setNcVis, getNc, forceNc = mkToggle("Movement", "Noclip", false, function(v) S.noclip = v end)
local setIjVis, getIj, forceIj = mkToggle("Movement", "Infinite Jump", false, function(v) S.infJump = v end)
mkSection("Movement", "Camera")
local setFcVis, getFc, forceFc = mkToggle("Movement", "Freecam", false, function(v) S.freecam = v end)

-- ██ PLAYERS TAB ██
mkSection("Players", "Player List")
-- (dynamic — rebuilt on refresh)
local playerListRows = {}

local function rebuildPlayerList()
    for _, r in ipairs(playerListRows) do if r and r.Parent then r:Destroy() end end
    playerListRows = {}
    orderCounters["Players"] = 1  -- reset after section header
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local row = mkPlayerBtn("Players", plr.Name)
            table.insert(playerListRows, row)
        end
    end
end

rebuildPlayerList()
Players.PlayerAdded:Connect(function() task.wait(0.5); rebuildPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); rebuildPlayerList() end)

-- ██ WORLD TAB ██
mkSection("World", "Character")
local setScaleSlider = mkSlider("World", "Character Scale", 1, 5, 1, function(v)
    S.charScale = v
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local bd = hum:FindFirstChild("BodyDepthScale")
    local bh = hum:FindFirstChild("BodyHeightScale")
    local bw = hum:FindFirstChild("BodyWidthScale")
    local hs = hum:FindFirstChild("HeadScale")
    if bd then bd.Value = v end; if bh then bh.Value = v end; if bw then bw.Value = v end; if hs then hs.Value = v end
end)

local setTransSlider = mkSlider("World", "Transparency", 0, 90, 0, function(v)
    S.charTransparency = v / 100
    local char = LocalPlayer.Character; if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = v / 100
        end
    end
end)

local setGlowVis, getGlow, forceGlow = mkToggle("World", "Character Glow", false, function(v)
    local char = LocalPlayer.Character; if not char then return end
    if v then
        local hl = char:FindFirstChild("SelfGlow")
        if not hl then
            hl = Instance.new("Highlight"); hl.Name = "SelfGlow"
            hl.FillColor = C.ACCENT; hl.FillTransparency = 0.6
            hl.OutlineColor = C.ACCENT2; hl.OutlineTransparency = 0
            hl.Parent = char
        end
    else
        local hl = char:FindFirstChild("SelfGlow"); if hl then hl:Destroy() end
    end
end)

mkSection("World", "Server")
local setAfkVis, getAfk, forceAfk = mkToggle("World", "Anti-AFK", false, function(v) S.antiAfk = v end)

-- ██ CONFIG TAB ██
mkSection("Config", "Keybinds")
mkKeybind("Config", "Toggle ESP", "esp")
mkKeybind("Config", "Toggle Fly", "fly")
mkKeybind("Config", "Toggle Noclip", "noclip")
mkKeybind("Config", "Toggle Aimbot", "aimbot")
mkKeybind("Config", "Toggle Freecam", "freecam")
mkSection("Config", "Settings")

-- Save / Load config buttons
local function mkActionBtn(tab, text, col, cb)
    local p = S.tabFrames[tab]; if not p then return end
    local btn = Instance.new("TextButton", p); btn.Size = UDim2.new(1,0,0,34); btn.LayoutOrder = nextOrd(tab)
    btn.BackgroundColor3 = col; btn.BackgroundTransparency = 0.15; btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 12; btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(cb)
    btn.MouseEnter:Connect(function() tw(btn, {BackgroundTransparency = 0}, 0.1) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundTransparency = 0.15}, 0.1) end)
    table.insert(S.allRows, {frame = btn, label = text:lower(), tab = tab})
end

mkActionBtn("Config", "💾  Save Config", C.GREEN, function()
    -- Save to a StringValue in PlayerGui so it persists during session
    local sv = PlayerGui:FindFirstChild("AdminMenuConfig")
    if not sv then sv = Instance.new("StringValue", PlayerGui); sv.Name = "AdminMenuConfig" end
    local cfg = {
        walkSpeed = S.walkSpeed, jumpPower = S.jumpPower, flySpeed = S.flySpeed,
        fovRadius = S.fovRadius, boostSpeed = S.boostSpeed, killAuraRange = S.killAuraRange,
        keybinds = {}
    }
    for k, v in pairs(S.keybinds) do cfg.keybinds[k] = v.Name end
    local HttpService = game:GetService("HttpService")
    sv.Value = HttpService:JSONEncode(cfg)
    print("[Admin Menu] Config saved!")
end)

mkActionBtn("Config", "📂  Load Config", C.ACCENT, function()
    local sv = PlayerGui:FindFirstChild("AdminMenuConfig")
    if sv and sv.Value ~= "" then
        local HttpService = game:GetService("HttpService")
        local ok, cfg = pcall(function() return HttpService:JSONDecode(sv.Value) end)
        if ok and cfg then
            if cfg.walkSpeed then setWsSlider(cfg.walkSpeed) end
            if cfg.jumpPower then setJpSlider(cfg.jumpPower) end
            if cfg.flySpeed then setFlySpd(cfg.flySpeed) end
            if cfg.fovRadius then setFovSlider(cfg.fovRadius) end
            if cfg.boostSpeed then setBoostSlider(cfg.boostSpeed) end
            if cfg.killAuraRange then setKaRange(cfg.killAuraRange) end
            if cfg.keybinds then
                for k, v in pairs(cfg.keybinds) do
                    local ok2, kc = pcall(function() return Enum.KeyCode[v] end)
                    if ok2 and kc then S.keybinds[k] = kc end
                end
            end
            print("[Admin Menu] Config loaded!")
        end
    else
        warn("[Admin Menu] No saved config found.")
    end
end)

mkActionBtn("Config", "🗑️  Reset Config", C.RED, function()
    local sv = PlayerGui:FindFirstChild("AdminMenuConfig"); if sv then sv:Destroy() end
    setWsSlider(16); setJpSlider(50); setFlySpd(60); setFovSlider(150); setBoostSlider(80); setKaRange(15)
    S.keybinds = {esp = Enum.KeyCode.E, fly = Enum.KeyCode.F, noclip = Enum.KeyCode.V, aimbot = Enum.KeyCode.Q, freecam = Enum.KeyCode.G}
    print("[Admin Menu] Config reset!")
end)

-- Info
local infoLbl = Instance.new("TextLabel", S.tabFrames["Config"])
infoLbl.Size = UDim2.new(1,0,0,28); infoLbl.BackgroundTransparency = 1; infoLbl.LayoutOrder = nextOrd("Config")
infoLbl.Text = "Admin Menu v3.0 • Toggle: RightShift"; infoLbl.TextColor3 = C.TEXT3
infoLbl.TextSize = 10; infoLbl.Font = Enum.Font.GothamMedium

--------------------------------------------------------------------------------
-- FOV CIRCLE
--------------------------------------------------------------------------------
local fovCircle = Instance.new("Frame", Gui)
fovCircle.Name = "FOV"; fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
fovCircle.Size = UDim2.new(0, S.fovRadius*2, 0, S.fovRadius*2)
fovCircle.Position = UDim2.new(0.5,0,0.5,0); fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0; fovCircle.Visible = false
local fvs = Instance.new("UIStroke", fovCircle); fvs.Color = C.ACCENT; fvs.Thickness = 1.5; fvs.Transparency = 0.4
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(0.5,0)

--------------------------------------------------------------------------------
-- SEARCH FUNCTIONALITY
--------------------------------------------------------------------------------
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower():gsub("%s+", "")
    if query == "" then
        -- Show current tab only
        for _, data in ipairs(S.allRows) do
            data.frame.Visible = true
        end
        switchTab(S.activeTab)
    else
        -- Show ALL matching rows across all tabs, hide non-matching
        for tName, frame in pairs(S.tabFrames) do frame.Visible = true end
        for _, data in ipairs(S.allRows) do
            data.frame.Visible = data.label:find(query, 1, true) ~= nil
        end
    end
end)

--------------------------------------------------------------------------------
-- TITLE BAR DRAGGING
--------------------------------------------------------------------------------
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        S.dragging = true; S.dragStart = i.Position; S.startPos = Main.Position
    end
end)
TB.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        S.dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if S.dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - S.dragStart
        Main.Position = UDim2.new(S.startPos.X.Scale, S.startPos.X.Offset + d.X, S.startPos.Y.Scale, S.startPos.Y.Offset + d.Y)
    end
end)

--------------------------------------------------------------------------------
-- OPEN / CLOSE / MINIMIZE
--------------------------------------------------------------------------------
local fullSize = UDim2.new(0, C.MENU_W, 0, C.MENU_H)

local function showMenu()
    S.menuOpen = true; Main.Visible = true
    Main.Size = UDim2.new(0, C.MENU_W, 0, 0); Main.BackgroundTransparency = 1
    tw(Main, {Size = fullSize, BackgroundTransparency = 0.02}, C.ANIM, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function hideMenu()
    local t = tw(Main, {Size = UDim2.new(0, C.MENU_W, 0, 0), BackgroundTransparency = 1}, C.ANIM)
    t.Completed:Connect(function() S.menuOpen = false; Main.Visible = false end)
end

MinBtn.MouseButton1Click:Connect(function()
    if S.minimized then
        S.minimized = false
        tw(Main, {Size = fullSize}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.delay(0.08, function()
            SearchFrame.Visible = true; TabBar.Visible = true
            for _, f in pairs(S.tabFrames) do f.Visible = false end
            S.tabFrames[S.activeTab].Visible = true
        end)
    else
        S.minimized = true; SearchFrame.Visible = false; TabBar.Visible = false
        for _, f in pairs(S.tabFrames) do f.Visible = false end
        tw(Main, {Size = UDim2.new(0, C.MENU_W, 0, 42)}, 0.22)
    end
end)
CloseBtn.MouseButton1Click:Connect(function() hideMenu() end)

-- Toggle key
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or S.keybindListening then return end
    if input.KeyCode == C.TOGGLE_KEY then
        if S.menuOpen then hideMenu() else showMenu() end
    end
    -- Feature keybinds
    for key, kc in pairs(S.keybinds) do
        if input.KeyCode == kc then
            if key == "esp" then forceEsp(not S.esp)
            elseif key == "fly" then forceFly(not S.fly)
            elseif key == "noclip" then forceNc(not S.noclip)
            elseif key == "aimbot" then forceAb(not S.aimbot)
            elseif key == "freecam" then forceFc(not S.freecam)
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- FEATURE IMPLEMENTATIONS
--------------------------------------------------------------------------------

-- ══════════ ESP ══════════
local function clearESP()
    for _, h in pairs(S.highlights) do if h and h.Parent then h:Destroy() end end; S.highlights = {}
end
local function applyESP()
    clearESP(); if not S.esp then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ESP_HL") then
            local hl = Instance.new("Highlight"); hl.Name = "ESP_HL"
            hl.FillTransparency = 0.75; hl.FillColor = C.ACCENT
            hl.OutlineColor = Color3.new(1,1,1); hl.OutlineTransparency = 0.2
            hl.Adornee = p.Character; hl.Parent = p.Character
            table.insert(S.highlights, hl)
        end
    end
end

-- ══════════ CHAMS ══════════
local function clearChams()
    for _, h in pairs(S.chamsHL) do if h and h.Parent then h:Destroy() end end; S.chamsHL = {}
end
local function applyChams()
    clearChams(); if not S.chams then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("Chams_HL") then
            local hl = Instance.new("Highlight"); hl.Name = "Chams_HL"
            hl.FillTransparency = 0.3; hl.FillColor = Color3.fromRGB(255,50,50)
            hl.OutlineColor = Color3.fromRGB(255,100,100); hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = p.Character; hl.Parent = p.Character
            table.insert(S.chamsHL, hl)
        end
    end
end

-- ══════════ TRACERS ══════════
local tracerFolder = Instance.new("Folder", Gui); tracerFolder.Name = "Tracers"
local function clearTracers()
    for _, l in pairs(S.tracerLines) do if l and l.Parent then l:Destroy() end end; S.tracerLines = {}
end
local function updateTracers()
    clearTracers(); if not S.tracers then return end
    local bottomCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    for _, d in ipairs(otherChars()) do
        local root = d.char:FindFirstChild("HumanoidRootPart")
        if root then
            local sp, vis = Camera:WorldToScreenPoint(root.Position)
            if vis then
                local line = Instance.new("Frame", tracerFolder)
                local startP = bottomCenter
                local endP = Vector2.new(sp.X, sp.Y)
                local mid = (startP + endP) / 2
                local dist = (endP - startP).Magnitude
                local angle = math.atan2(endP.Y - startP.Y, endP.X - startP.X)

                line.Size = UDim2.new(0, dist, 0, 1)
                line.Position = UDim2.new(0, mid.X - dist/2, 0, mid.Y)
                line.AnchorPoint = Vector2.new(0.5, 0.5)
                line.Rotation = math.deg(angle)
                line.BackgroundColor3 = C.ACCENT
                line.BackgroundTransparency = 0.3
                line.BorderSizePixel = 0
                table.insert(S.tracerLines, line)
            end
        end
    end
end

-- ══════════ ESP TAGS (Name / HP / Distance) ══════════
local tagFolder = Instance.new("Folder", Gui); tagFolder.Name = "ESPTags"
local function clearTags()
    for _, g in pairs(S.espTagGuis) do if g and g.Parent then g:Destroy() end end; S.espTagGuis = {}
end
local function updateTags()
    clearTags(); if not S.espTags then return end
    local myRoot = getRoot()
    for _, d in ipairs(otherChars()) do
        local head = d.char:FindFirstChild("Head")
        local hum = d.char:FindFirstChildOfClass("Humanoid")
        if head and hum then
            local bg = Instance.new("BillboardGui")
            bg.Name = "Tag_"..d.player.Name; bg.Adornee = head
            bg.Size = UDim2.new(0, 160, 0, 50); bg.StudsOffset = Vector3.new(0, 2.5, 0)
            bg.AlwaysOnTop = true; bg.Parent = tagFolder

            local dist = myRoot and math.floor((myRoot.Position - head.Position).Magnitude) or 0
            local hpPct = math.floor((hum.Health / hum.MaxHealth) * 100)

            local nameL = Instance.new("TextLabel", bg); nameL.Size = UDim2.new(1,0,0.4,0)
            nameL.BackgroundTransparency = 1; nameL.Text = d.player.Name
            nameL.TextColor3 = C.TEXT1; nameL.TextSize = 13; nameL.Font = Enum.Font.GothamBold
            nameL.TextStrokeTransparency = 0.5

            local infoL = Instance.new("TextLabel", bg); infoL.Size = UDim2.new(1,0,0.3,0); infoL.Position = UDim2.new(0,0,0.4,0)
            infoL.BackgroundTransparency = 1
            infoL.Text = "HP: "..hpPct.."% | "..dist.."m"
            local hpColor = hpPct > 50 and C.GREEN or (hpPct > 25 and C.ORANGE or C.RED)
            infoL.TextColor3 = hpColor; infoL.TextSize = 11; infoL.Font = Enum.Font.GothamMedium
            infoL.TextStrokeTransparency = 0.5

            -- HP bar background
            local barBg = Instance.new("Frame", bg); barBg.Size = UDim2.new(0.7,0,0,4)
            barBg.Position = UDim2.new(0.15,0,0.78,0); barBg.BackgroundColor3 = C.BG1; barBg.BorderSizePixel = 0
            Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

            local barFill = Instance.new("Frame", barBg); barFill.Size = UDim2.new(hpPct/100,0,1,0)
            barFill.BackgroundColor3 = hpColor; barFill.BorderSizePixel = 0
            Instance.new("UICorner", barFill).CornerRadius = UDim.new(1,0)

            table.insert(S.espTagGuis, bg)
        end
    end
end

-- ══════════ AIMBOT ══════════
local function runAimbot()
    if not S.aimbot then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local t = nearestInFov()
    if t then
        local head = t:FindFirstChild("Head")
        if head then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, head.Position), 0.5)
        end
    end
end

-- ══════════ KILL AURA ══════════
local function runKillAura()
    if not S.killAura then return end
    local root = getRoot(); if not root then return end
    -- Simulate clicking on nearby player (ClickDetector or tool activation)
    -- Since this is client-side, we use the Humanoid's equipped tool
    local char = LocalPlayer.Character; if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")

    for _, d in ipairs(otherChars()) do
        local eRoot = d.char:FindFirstChild("HumanoidRootPart")
        if eRoot and (root.Position - eRoot.Position).Magnitude <= S.killAuraRange then
            if tool then
                tool:Activate()
            end
            -- Also try virtual click
            local click = d.char:FindFirstChild("ClickDetector", true)
            if click then
                pcall(function() fireclickdetector(click) end)
            end
        end
    end
end

-- ══════════ FLY ══════════
local function enableFly()
    local root = getRoot(); local hum = getHum(); if not root or not hum then return end
    hum.PlatformStand = true
    local bv = Instance.new("BodyVelocity", root); bv.Name = "FlyBV"; bv.MaxForce = Vector3.one * math.huge; bv.Velocity = Vector3.zero; S.flyBV = bv
    local bg = Instance.new("BodyGyro", root); bg.Name = "FlyBG"; bg.MaxTorque = Vector3.one * math.huge; bg.D = 100; bg.P = 10000; S.flyBG = bg

    S.conn["fly"] = RunService.RenderStepped:Connect(function()
        if not S.fly then return end; local r = getRoot(); if not r or not S.flyBV or not S.flyBV.Parent then return end
        local cf = Camera.CFrame; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
        if dir.Magnitude > 0 then dir = dir.Unit end
        S.flyBV.Velocity = dir * S.flySpeed; S.flyBG.CFrame = cf
    end)
end
local function disableFly()
    disconn("fly")
    if S.flyBV and S.flyBV.Parent then S.flyBV:Destroy() end
    if S.flyBG and S.flyBG.Parent then S.flyBG:Destroy() end
    S.flyBV = nil; S.flyBG = nil
    local h = getHum(); if h then h.PlatformStand = false end
end

-- ══════════ NOCLIP ══════════
local function startNoclip()
    S.conn["noclip"] = RunService.Stepped:Connect(function()
        if not S.noclip then return end; local ch = LocalPlayer.Character; if not ch then return end
        for _, p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)
end
local function stopNoclip()
    disconn("noclip")
    local ch = LocalPlayer.Character; if not ch then return end
    for _, p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = (p.Name ~= "HumanoidRootPart") or true end
    end
end

-- ══════════ INFINITE JUMP ══════════
local function startInfJump()
    S.conn["infJump"] = UserInputService.JumpRequest:Connect(function()
        if not S.infJump then return end; local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end
local function stopInfJump() disconn("infJump") end

-- ══════════ SPEED BOOST ══════════
local function startBoost()
    S.conn["boost"] = RunService.RenderStepped:Connect(function(dt)
        if not S.speedBoost then return end; local r = getRoot(); local h = getHum(); if not r or not h then return end
        if h.MoveDirection.Magnitude > 0 then r.CFrame = r.CFrame + h.MoveDirection.Unit * S.boostSpeed * dt end
    end)
end
local function stopBoost() disconn("boost") end

-- ══════════ FREECAM ══════════
local function enableFreecam()
    S.freecamActive = true; S.origCamType = Camera.CameraType
    S.freecamCF = Camera.CFrame; Camera.CameraType = Enum.CameraType.Scriptable

    S.conn["freecam"] = RunService.RenderStepped:Connect(function(dt)
        if not S.freecamActive then return end
        local speed = S.flySpeed * dt
        local cf = Camera.CFrame; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
        if dir.Magnitude > 0 then dir = dir.Unit end
        Camera.CFrame = cf + dir * speed
    end)
end
local function disableFreecam()
    S.freecamActive = false; disconn("freecam")
    Camera.CameraType = S.origCamType or Enum.CameraType.Custom
    local hum = getHum(); if hum then Camera.CameraSubject = hum end
end

-- ══════════ FULLBRIGHT ══════════
local function enableFullbright()
    S.origLighting = {
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }
    Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 1e5; Lighting.FogStart = 1e5
    Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(200,200,200); Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
end
local function disableFullbright()
    if S.origLighting.Brightness then
        Lighting.Brightness = S.origLighting.Brightness; Lighting.ClockTime = S.origLighting.ClockTime
        Lighting.FogEnd = S.origLighting.FogEnd; Lighting.FogStart = S.origLighting.FogStart
        Lighting.GlobalShadows = S.origLighting.GlobalShadows; Lighting.Ambient = S.origLighting.Ambient
        Lighting.OutdoorAmbient = S.origLighting.OutdoorAmbient
    end
end

-- ══════════ ANTI-AFK ══════════
local function startAntiAfk()
    -- Disconnect the default idle event
    local vu = game:GetService("VirtualUser")
    S.conn["antiAfk"] = Players.LocalPlayer.Idled:Connect(function()
        if S.antiAfk then
            pcall(function() vu:CaptureController() vu:ClickButton2(Vector2.zero) end)
        end
    end)
end
local function stopAntiAfk() disconn("antiAfk") end

--------------------------------------------------------------------------------
-- MAIN LOOP
--------------------------------------------------------------------------------
local espTickCounter = 0

S.conn["main"] = RunService.RenderStepped:Connect(function(dt)
    espTickCounter += 1

    -- ESP refresh (every 15 frames for performance)
    if espTickCounter % 15 == 0 then
        if S.esp then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ESP_HL") then applyESP(); break end
            end
        elseif #S.highlights > 0 then clearESP() end

        if S.chams then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("Chams_HL") then applyChams(); break end
            end
        elseif #S.chamsHL > 0 then clearChams() end
    end

    -- Tracers (every 2 frames)
    if espTickCounter % 2 == 0 then
        if S.tracers then updateTracers() elseif #S.tracerLines > 0 then clearTracers() end
    end

    -- ESP Tags (every 5 frames)
    if espTickCounter % 5 == 0 then
        if S.espTags then updateTags() elseif #S.espTagGuis > 0 then clearTags() end
    end

    -- Aimbot
    if S.aimbot then
        runAimbot()
        fovCircle.Visible = true; fovCircle.Size = UDim2.new(0, S.fovRadius*2, 0, S.fovRadius*2)
    else fovCircle.Visible = false end

    -- Kill Aura (every 3 frames)
    if espTickCounter % 3 == 0 and S.killAura then runKillAura() end

    -- Fly
    if S.fly and not S.flyBV then enableFly() elseif not S.fly and S.flyBV then disableFly() end

    -- Fullbright
    if S.fullbright and not S.origLighting.Brightness then enableFullbright()
    elseif not S.fullbright and S.origLighting.Brightness then disableFullbright(); S.origLighting = {} end

    -- Noclip
    if S.noclip and not S.conn["noclip"] then startNoclip() elseif not S.noclip and S.conn["noclip"] then stopNoclip() end

    -- Inf Jump
    if S.infJump and not S.conn["infJump"] then startInfJump() elseif not S.infJump and S.conn["infJump"] then stopInfJump() end

    -- Boost
    if S.speedBoost and not S.conn["boost"] then startBoost() elseif not S.speedBoost and S.conn["boost"] then stopBoost() end

    -- Freecam
    if S.freecam and not S.freecamActive then enableFreecam() elseif not S.freecam and S.freecamActive then disableFreecam() end

    -- Anti-AFK
    if S.antiAfk and not S.conn["antiAfk"] then startAntiAfk() elseif not S.antiAfk and S.conn["antiAfk"] then stopAntiAfk() end
end)

--------------------------------------------------------------------------------
-- CHARACTER RESPAWN
--------------------------------------------------------------------------------
local function onCharAdded(char)
    local hum = char:WaitForChild("Humanoid", 10); if not hum then return end
    char:WaitForChild("HumanoidRootPart", 10)
    task.defer(function()
        if hum then hum.WalkSpeed = S.walkSpeed; hum.UseJumpPower = true; hum.JumpPower = S.jumpPower end
    end)
    if S.fly then disableFly(); task.wait(0.2); enableFly() end
    if S.noclip then stopNoclip(); task.wait(0.1); startNoclip() end
    if S.speedBoost then stopBoost(); task.wait(0.1); startBoost() end
    if S.freecam then disableFreecam(); task.wait(0.1); enableFreecam() end
end

LocalPlayer.CharacterAdded:Connect(onCharAdded)
if LocalPlayer.Character then task.spawn(function() onCharAdded(LocalPlayer.Character) end) end

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function()
    task.wait(0.5); if S.esp then applyESP() end; if S.chams then applyChams() end
end) end)

--------------------------------------------------------------------------------
-- INITIAL ANIMATION
--------------------------------------------------------------------------------
Main.Size = UDim2.new(0, C.MENU_W, 0, 0); Main.BackgroundTransparency = 1; Main.Visible = true
task.wait(0.3); showMenu()

print("[Admin Menu v3.0] Loaded! Press RightShift to toggle. 6 tabs, full features.")