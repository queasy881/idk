--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              ADMIN MENU v3.0 — SAB EDITION                   ║
    ║          Tailored for Steal a Brainrot                       ║
    ║                                                              ║
    ║  Toggle Key: RightShift                                      ║
    ╚══════════════════════════════════════════════════════════════╝

    FEATURES:
    • Brainrot ESP — See all brainrots through walls with rarity color + name + $/s
    • Base ESP — Highlights all player bases, shows lock status
    • Player ESP — See all players through walls with name + distance
    • Conveyor Alert — Notifies when Legendary+ brainrot spawns on belt
    • Teleport — Instant TP to conveyor, your base, or any player's base
    • Speed / Fly / Noclip — Movement hacks for fast stealing
    • Auto-Collect — Auto-picks up cash drops
    • Fullbright, Anti-AFK, Freecam, and more
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
local Camera             = Workspace.CurrentCamera

--------------------------------------------------------------------------------
-- LOCAL PLAYER
--------------------------------------------------------------------------------
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- RARITY COLORS (matches SAB tiers)
--------------------------------------------------------------------------------
local RARITY_COLORS = {
    Common      = Color3.fromRGB(180, 180, 180),   -- Gray
    Rare        = Color3.fromRGB(76, 175, 80),      -- Green
    Epic        = Color3.fromRGB(156, 39, 176),     -- Purple
    Legendary   = Color3.fromRGB(255, 193, 7),      -- Gold
    Mythic      = Color3.fromRGB(233, 30, 99),      -- Pink/Red
    ["Brainrot God"] = Color3.fromRGB(255, 64, 64), -- Bright Red
    Secret      = Color3.fromRGB(0, 188, 212),      -- Cyan
    OG          = Color3.fromRGB(255, 145, 0),      -- Orange
    Unknown     = Color3.fromRGB(255, 255, 255),    -- White fallback
}

local RARITY_ORDER = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Brainrot God", "Secret", "OG"}

-- Minimum rarity to trigger conveyor alert
local ALERT_RARITIES = {Legendary = true, Mythic = true, ["Brainrot God"] = true, Secret = true, OG = true}

--------------------------------------------------------------------------------
-- THEME
--------------------------------------------------------------------------------
local C = {
    TOGGLE_KEY   = Enum.KeyCode.RightShift,
    MENU_W       = 430, MENU_H = 570, ANIM = 0.28, TAB_H = 32,
    BG1          = Color3.fromRGB(12, 12, 18),
    BG2          = Color3.fromRGB(18, 18, 26),
    BG3          = Color3.fromRGB(26, 26, 36),
    BG4          = Color3.fromRGB(34, 34, 46),
    ACCENT       = Color3.fromRGB(255, 193, 7),     -- Gold accent (brainrot theme)
    ACCENT2      = Color3.fromRGB(255, 145, 0),     -- Orange
    GREEN        = Color3.fromRGB(67, 181, 129),
    RED          = Color3.fromRGB(237, 66, 69),
    ORANGE       = Color3.fromRGB(250, 166, 26),
    CYAN         = Color3.fromRGB(0, 188, 212),
    TEXT1        = Color3.fromRGB(235, 235, 245),
    TEXT2        = Color3.fromRGB(150, 150, 170),
    TEXT3        = Color3.fromRGB(100, 100, 120),
    DIVIDER      = Color3.fromRGB(40, 40, 54),
    BORDER       = Color3.fromRGB(50, 50, 66),
    TOGGLE_ON    = Color3.fromRGB(255, 193, 7),     -- Gold when on
    TOGGLE_OFF   = Color3.fromRGB(58, 58, 74),
    SLIDER_TRACK = Color3.fromRGB(44, 44, 60),
}

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------
local S = {
    menuOpen = true, minimized = false, dragging = false,
    dragStart = nil, startPos = nil,
    -- Features
    brainrotEsp = false, baseEsp = false, playerEsp = false,
    conveyorAlert = false, autoCollect = false,
    fly = false, noclip = false, infJump = false, speedBoost = false,
    freecam = false, fullbright = false, antiAfk = false,
    -- Values
    walkSpeed = 16, jumpPower = 50, flySpeed = 80, boostSpeed = 80,
    alertMinRarity = "Legendary",
    -- Runtime
    conn = {}, brainrotHighlights = {}, baseHighlights = {}, playerHighlights = {},
    brainrotTags = {}, baseTags = {}, playerTags = {},
    origLighting = {}, flyBV = nil, flyBG = nil,
    freecamActive = false, origCamType = nil,
    notifications = {},
    -- Keybinds
    keybinds = {
        brainrotEsp = Enum.KeyCode.E,
        fly = Enum.KeyCode.F,
        noclip = Enum.KeyCode.V,
        freecam = Enum.KeyCode.G,
    },
    keybindListening = nil,
    -- Tab system
    activeTab = "Brainrots",
    tabFrames = {},
    allRows = {},
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

--- Try to detect brainrot rarity from the model or its children
local function detectRarity(model)
    -- Check common SAB naming patterns: rarity in name, attributes, or child values
    local name = model.Name:lower()

    -- Check for a StringValue or attribute named "Rarity"
    local rarityVal = model:FindFirstChild("Rarity")
    if rarityVal and rarityVal:IsA("StringValue") then
        return rarityVal.Value
    end

    -- Check attributes
    local attrRarity = nil
    pcall(function() attrRarity = model:GetAttribute("Rarity") end)
    if attrRarity and type(attrRarity) == "string" then return attrRarity end

    -- Check BillboardGui text for rarity keywords
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local txt = desc.Text:lower()
            for _, r in ipairs(RARITY_ORDER) do
                if txt:find(r:lower()) then return r end
            end
        end
    end

    -- Fallback: check model name for rarity keywords
    for _, r in ipairs(RARITY_ORDER) do
        if name:find(r:lower()) then return r end
    end

    return "Unknown"
end

--- Try to detect income/s from a brainrot model
local function detectIncome(model)
    local incomeVal = model:FindFirstChild("Income") or model:FindFirstChild("MoneyPerSecond") or model:FindFirstChild("CashPerSecond")
    if incomeVal and incomeVal:IsA("NumberValue") then return incomeVal.Value end

    local attrIncome = nil
    pcall(function() attrIncome = model:GetAttribute("Income") or model:GetAttribute("MoneyPerSecond") end)
    if attrIncome and type(attrIncome) == "number" then return attrIncome end

    return nil
end

--- Format large numbers
local function formatMoney(n)
    if not n then return "?" end
    if n >= 1e9 then return string.format("%.1fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.1fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

--- Get rarity color
local function getRarityColor(rarity)
    return RARITY_COLORS[rarity] or RARITY_COLORS.Unknown
end

--- Find brainrot models in workspace
--- SAB typically stores brainrots as models in workspace or in base folders
local function findBrainrots()
    local results = {}
    local function scan(parent)
        for _, child in ipairs(parent:GetChildren()) do
            -- Brainrots are typically Models with a PrimaryPart or HumanoidRootPart
            if child:IsA("Model") and child.PrimaryPart then
                -- Check if it looks like a brainrot (has income/rarity attributes, or is in a brainrot folder)
                local isPlayer = Players:GetPlayerFromCharacter(child)
                if not isPlayer then
                    local hasRarityIndicator = child:FindFirstChild("Rarity")
                        or child:FindFirstChild("Income")
                        or child:FindFirstChild("MoneyPerSecond")
                        or child:FindFirstChild("CashPerSecond")
                        or (pcall(function() return child:GetAttribute("Rarity") end) and child:GetAttribute("Rarity"))
                        or (pcall(function() return child:GetAttribute("Income") end) and child:GetAttribute("Income"))

                    if hasRarityIndicator then
                        table.insert(results, child)
                    end
                end
            end
        end
    end

    -- Scan workspace and common brainrot containers
    scan(Workspace)
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            local nameLower = folder.Name:lower()
            if nameLower:find("brainrot") or nameLower:find("base") or nameLower:find("conveyor")
                or nameLower:find("unit") or nameLower:find("collect") then
                scan(folder)
            end
        end
    end

    return results
end

--- Find player bases in workspace
local function findBases()
    local results = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = obj.Name:lower()
        if (obj:IsA("Model") or obj:IsA("Folder")) and (nameLower:find("base") or nameLower:find("plot") or nameLower:find("tycoon")) then
            -- Check if it has an owner attribute or a connection to a player
            table.insert(results, obj)
        end
    end
    return results
end

--- Find the conveyor belt
local function findConveyor()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = obj.Name:lower()
        if nameLower:find("conveyor") or nameLower:find("belt") or nameLower:find("spawn") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                return obj
            end
        end
    end
    return nil
end

--- Find cash/money collectibles (for auto-collect)
local function findCashDrops()
    local drops = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = obj.Name:lower()
        if (nameLower:find("cash") or nameLower:find("money") or nameLower:find("coin") or nameLower:find("drop"))
            and (obj:IsA("BasePart") or obj:IsA("Model")) then
            -- Check if it has a ClickDetector or TouchInterest
            local clickDet = obj:FindFirstChildOfClass("ClickDetector")
            local touchInt = obj:FindFirstChildOfClass("TouchTransmitter")
            if clickDet or touchInt then
                table.insert(drops, obj)
            end
        end
    end
    return drops
end

--------------------------------------------------------------------------------
-- SCREENGUI
--------------------------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "SABAdminMenu"; Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; Gui.Parent = PlayerGui

--------------------------------------------------------------------------------
-- NOTIFICATION SYSTEM (top right, for conveyor alerts)
--------------------------------------------------------------------------------
local NotifHolder = Instance.new("Frame", Gui)
NotifHolder.Name = "Notifications"; NotifHolder.Size = UDim2.new(0, 280, 1, 0)
NotifHolder.Position = UDim2.new(1, -290, 0, 10); NotifHolder.BackgroundTransparency = 1
NotifHolder.BorderSizePixel = 0
local notifLayout = Instance.new("UIListLayout", NotifHolder)
notifLayout.Padding = UDim.new(0, 6); notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function pushNotification(title, subtitle, color, duration)
    duration = duration or 5
    color = color or C.ACCENT

    local notif = Instance.new("Frame", NotifHolder)
    notif.Size = UDim2.new(1, 0, 0, 56); notif.BackgroundColor3 = C.BG1
    notif.BackgroundTransparency = 0.05; notif.BorderSizePixel = 0; notif.ClipsDescendants = true
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    local ns = Instance.new("UIStroke", notif); ns.Color = color; ns.Thickness = 1.5; ns.Transparency = 0.3

    -- Color bar on left
    local bar = Instance.new("Frame", notif); bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color; bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    local tl = Instance.new("TextLabel", notif)
    tl.Size = UDim2.new(1, -16, 0, 24); tl.Position = UDim2.new(0, 12, 0, 4)
    tl.BackgroundTransparency = 1; tl.Text = title; tl.TextColor3 = color
    tl.TextSize = 13; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left

    local sl = Instance.new("TextLabel", notif)
    sl.Size = UDim2.new(1, -16, 0, 20); sl.Position = UDim2.new(0, 12, 0, 28)
    sl.BackgroundTransparency = 1; sl.Text = subtitle; sl.TextColor3 = C.TEXT2
    sl.TextSize = 11; sl.Font = Enum.Font.GothamMedium; sl.TextXAlignment = Enum.TextXAlignment.Left

    -- Animate in
    notif.Position = UDim2.new(1, 0, 0, 0)
    tw(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Auto dismiss
    task.delay(duration, function()
        local t = tw(notif, {Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        t.Completed:Connect(function() notif:Destroy() end)
    end)
end

--------------------------------------------------------------------------------
-- MAIN FRAME
--------------------------------------------------------------------------------
local Main = Instance.new("Frame", Gui)
Main.Name = "Main"; Main.Size = UDim2.new(0, C.MENU_W, 0, C.MENU_H)
Main.Position = UDim2.new(0.5, -C.MENU_W/2, 0.5, -C.MENU_H/2)
Main.BackgroundColor3 = C.BG1; Main.BackgroundTransparency = 0.02
Main.BorderSizePixel = 0; Main.ClipsDescendants = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke", Main); ms.Color = C.BORDER; ms.Thickness = 1.5; ms.Transparency = 0.3

local mg = Instance.new("UIGradient", Main)
mg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 200, 160))})
mg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.97), NumberSequenceKeypoint.new(1, 1)})
mg.Rotation = 135

--------------------------------------------------------------------------------
-- TITLE BAR
--------------------------------------------------------------------------------
local TB = Instance.new("Frame", Main)
TB.Size = UDim2.new(1, 0, 0, 40); TB.BackgroundColor3 = C.BG2; TB.BorderSizePixel = 0
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 10)
local tbc = Instance.new("Frame", TB); tbc.Size = UDim2.new(1,0,0,12); tbc.Position = UDim2.new(0,0,1,-12)
tbc.BackgroundColor3 = C.BG2; tbc.BorderSizePixel = 0

-- Gold accent line
local al = Instance.new("Frame", TB); al.Size = UDim2.new(1,0,0,2); al.Position = UDim2.new(0,0,1,0)
al.BackgroundColor3 = C.ACCENT; al.BorderSizePixel = 0
local alg = Instance.new("UIGradient", al)
alg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.ACCENT), ColorSequenceKeypoint.new(0.5, C.ACCENT2), ColorSequenceKeypoint.new(1, C.ACCENT)})

-- Title
local tl = Instance.new("TextLabel", TB); tl.Size = UDim2.new(1,-100,1,0); tl.Position = UDim2.new(0,14,0,0)
tl.BackgroundTransparency = 1; tl.Text = "🧠 SAB Admin"; tl.TextColor3 = C.ACCENT
tl.TextSize = 15; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left

local vl = Instance.new("TextLabel", TB); vl.Size = UDim2.new(0,36,0,16); vl.Position = UDim2.new(0,122,0.5,-8)
vl.BackgroundColor3 = C.BG3; vl.Text = "v3.0"; vl.TextColor3 = C.TEXT2; vl.TextSize = 10
vl.Font = Enum.Font.GothamMedium; vl.BorderSizePixel = 0; Instance.new("UICorner", vl).CornerRadius = UDim.new(0,4)

-- Title buttons
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
local SF = Instance.new("Frame", Main); SF.Size = UDim2.new(1,-16,0,28)
SF.Position = UDim2.new(0,8,0,44); SF.BackgroundColor3 = C.BG3; SF.BorderSizePixel = 0
Instance.new("UICorner", SF).CornerRadius = UDim.new(0,6)

local si = Instance.new("TextLabel", SF); si.Size = UDim2.new(0,28,1,0)
si.BackgroundTransparency = 1; si.Text = "🔍"; si.TextSize = 13

local SB = Instance.new("TextBox", SF); SB.Size = UDim2.new(1,-36,1,0); SB.Position = UDim2.new(0,30,0,0)
SB.BackgroundTransparency = 1; SB.PlaceholderText = "Search features..."
SB.PlaceholderColor3 = C.TEXT3; SB.Text = ""; SB.TextColor3 = C.TEXT1
SB.TextSize = 12; SB.Font = Enum.Font.GothamMedium; SB.TextXAlignment = Enum.TextXAlignment.Left; SB.ClearTextOnFocus = false

--------------------------------------------------------------------------------
-- TAB BAR
--------------------------------------------------------------------------------
local TabBar = Instance.new("Frame", Main); TabBar.Size = UDim2.new(1,-16,0,C.TAB_H)
TabBar.Position = UDim2.new(0,8,0,76); TabBar.BackgroundTransparency = 1; TabBar.BorderSizePixel = 0
local tly = Instance.new("UIListLayout", TabBar); tly.FillDirection = Enum.FillDirection.Horizontal
tly.SortOrder = Enum.SortOrder.LayoutOrder; tly.Padding = UDim.new(0,3)

local TABS = {"Brainrots", "Players", "Movement", "World", "Config"}
local tabButtons = {}

local function switchTab(name)
    S.activeTab = name
    for tN, f in pairs(S.tabFrames) do f.Visible = (tN == name) end
    for tN, btn in pairs(tabButtons) do
        if tN == name then
            tw(btn, {BackgroundColor3 = C.ACCENT, BackgroundTransparency = 0}, 0.15)
            tw(btn, {TextColor3 = C.BG1}, 0.15)
        else
            tw(btn, {BackgroundColor3 = C.BG3, BackgroundTransparency = 0.3}, 0.15)
            tw(btn, {TextColor3 = C.TEXT2}, 0.15)
        end
    end
end

for i, name in ipairs(TABS) do
    local btn = Instance.new("TextButton", TabBar); btn.Name = name; btn.Size = UDim2.new(0, 76, 1, 0); btn.LayoutOrder = i
    btn.BackgroundColor3 = (i==1) and C.ACCENT or C.BG3; btn.BackgroundTransparency = (i==1) and 0 or 0.3
    btn.Text = name; btn.TextColor3 = (i==1) and C.BG1 or C.TEXT2
    btn.TextSize = 11; btn.Font = Enum.Font.GothamBold; btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    tabButtons[name] = btn; btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

--------------------------------------------------------------------------------
-- TAB CONTENT
--------------------------------------------------------------------------------
local cY = 76 + C.TAB_H + 4; local cH = C.MENU_H - cY - 4

local function mkTab(name)
    local sf = Instance.new("ScrollingFrame", Main); sf.Name = "Tab_"..name
    sf.Size = UDim2.new(1,-16,0,cH); sf.Position = UDim2.new(0,8,0,cY)
    sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = C.ACCENT; sf.ScrollBarImageTransparency = 0.4
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y; sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.Visible = (name == "Brainrots"); sf.ClipsDescendants = true
    Instance.new("UIListLayout", sf).Padding = UDim.new(0,3)
    local pd = Instance.new("UIPadding", sf); pd.PaddingTop = UDim.new(0,2); pd.PaddingBottom = UDim.new(0,8)
    sf:FindFirstChildOfClass("UIListLayout").SortOrder = Enum.SortOrder.LayoutOrder
    S.tabFrames[name] = sf; return sf
end
for _, n in ipairs(TABS) do mkTab(n) end

--------------------------------------------------------------------------------
-- UI BUILDERS
--------------------------------------------------------------------------------
local ordC = {}
local function nOrd(t) ordC[t] = (ordC[t] or 0) + 1; return ordC[t] end

local function mkSection(tab, text)
    local p = S.tabFrames[tab]; if not p then return end
    local f = Instance.new("Frame", p); f.Size = UDim2.new(1,0,0,26); f.BackgroundTransparency = 1; f.LayoutOrder = nOrd(tab)
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
    row.BackgroundColor3 = C.BG2; row.BackgroundTransparency = 0.4; row.BorderSizePixel = 0; row.LayoutOrder = nOrd(tab)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
    local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(1,-66,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C.TEXT1; lbl.TextSize = 12; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local track = Instance.new("Frame", row); track.Size = UDim2.new(0,38,0,20); track.Position = UDim2.new(1,-50,0.5,-10)
    track.BackgroundColor3 = on and C.TOGGLE_ON or C.TOGGLE_OFF; track.BorderSizePixel = 0; Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame", track); knob.Size = UDim2.new(0,14,0,14)
    knob.Position = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0; Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    local function setV(v) tw(track, {BackgroundColor3 = v and C.TOGGLE_ON or C.TOGGLE_OFF}, 0.18); tw(knob, {Position = v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}, 0.18, Enum.EasingStyle.Back) end
    btn.MouseButton1Click:Connect(function() on = not on; setV(on); if cb then cb(on) end end)
    btn.MouseEnter:Connect(function() tw(row, {BackgroundTransparency = 0.15}, 0.1) end)
    btn.MouseLeave:Connect(function() tw(row, {BackgroundTransparency = 0.4}, 0.1) end)
    table.insert(S.allRows, {frame = row, label = label:lower(), tab = tab})
    return setV, function() return on end, function(v) on = v; setV(v); if cb then cb(v) end end
end

local function mkSlider(tab, label, min, max, default, cb)
    local p = S.tabFrames[tab]; if not p then return end; local val = default or min
    local row = Instance.new("Frame", p); row.Name = "Slider_"..label; row.Size = UDim2.new(1,0,0,46)
    row.BackgroundColor3 = C.BG2; row.BackgroundTransparency = 0.4; row.BorderSizePixel = 0; row.LayoutOrder = nOrd(tab)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
    local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.6,0,0,18); lbl.Position = UDim2.new(0,10,0,3)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C.TEXT1; lbl.TextSize = 12; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local vl2 = Instance.new("TextLabel", row); vl2.Size = UDim2.new(0.35,0,0,18); vl2.Position = UDim2.new(0.6,0,0,3)
    vl2.BackgroundTransparency = 1; vl2.Text = tostring(math.floor(val)); vl2.TextColor3 = C.ACCENT; vl2.TextSize = 12; vl2.Font = Enum.Font.GothamBold; vl2.TextXAlignment = Enum.TextXAlignment.Right
    local trk = Instance.new("Frame", row); trk.Size = UDim2.new(1,-20,0,5); trk.Position = UDim2.new(0,10,0,30)
    trk.BackgroundColor3 = C.SLIDER_TRACK; trk.BorderSizePixel = 0; Instance.new("UICorner", trk).CornerRadius = UDim.new(1,0)
    local pct = (val-min)/(max-min)
    local fill = Instance.new("Frame", trk); fill.Size = UDim2.new(pct,0,1,0); fill.BackgroundColor3 = C.ACCENT; fill.BorderSizePixel = 0; Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local sk = Instance.new("Frame", trk); sk.Size = UDim2.new(0,12,0,12); sk.Position = UDim2.new(pct,-6,0.5,-6)
    sk.BackgroundColor3 = Color3.new(1,1,1); sk.BorderSizePixel = 0; sk.ZIndex = 2; Instance.new("UICorner", sk).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke", sk).Color = C.ACCENT; sk:FindFirstChildOfClass("UIStroke").Thickness = 2
    local dragging = false
    local function upd(p2) p2 = math.clamp(p2,0,1); val = math.floor(min+(max-min)*p2); vl2.Text = tostring(val); fill.Size = UDim2.new(p2,0,1,0); sk.Position = UDim2.new(p2,-6,0.5,-6); if cb then cb(val) end end
    local sb = Instance.new("TextButton", trk); sb.Size = UDim2.new(1,0,0,20); sb.Position = UDim2.new(0,0,0,-8); sb.BackgroundTransparency = 1; sb.Text = ""
    sb.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function() if dragging then upd((UserInputService:GetMouseLocation().X - trk.AbsolutePosition.X) / trk.AbsoluteSize.X) end end)
    table.insert(S.allRows, {frame = row, label = label:lower(), tab = tab})
    return function(n) upd(math.clamp((n-min)/(max-min),0,1)) end
end

local function mkActionBtn(tab, text, col, cb)
    local p = S.tabFrames[tab]; if not p then return end
    local btn = Instance.new("TextButton", p); btn.Size = UDim2.new(1,0,0,34); btn.LayoutOrder = nOrd(tab)
    btn.BackgroundColor3 = col; btn.BackgroundTransparency = 0.15; btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 12; btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false; Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(cb)
    btn.MouseEnter:Connect(function() tw(btn, {BackgroundTransparency = 0}, 0.1) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundTransparency = 0.15}, 0.1) end)
    table.insert(S.allRows, {frame = btn, label = text:lower(), tab = tab})
end

local function mkKeybind(tab, label, stateKey)
    local p = S.tabFrames[tab]; if not p then return end
    local row = Instance.new("Frame", p); row.Name = "KB_"..label; row.Size = UDim2.new(1,0,0,34)
    row.BackgroundColor3 = C.BG2; row.BackgroundTransparency = 0.4; row.BorderSizePixel = 0; row.LayoutOrder = nOrd(tab)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
    local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C.TEXT1; lbl.TextSize = 12; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local kbtn = Instance.new("TextButton", row); kbtn.Size = UDim2.new(0,80,0,22); kbtn.Position = UDim2.new(1,-90,0.5,-11)
    kbtn.BackgroundColor3 = C.BG4; kbtn.BorderSizePixel = 0; kbtn.AutoButtonColor = false
    kbtn.Text = S.keybinds[stateKey] and S.keybinds[stateKey].Name or "None"; kbtn.TextColor3 = C.ORANGE; kbtn.TextSize = 11; kbtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", kbtn).CornerRadius = UDim.new(0,4)
    kbtn.MouseButton1Click:Connect(function()
        kbtn.Text = "..."; kbtn.TextColor3 = C.RED; S.keybindListening = stateKey
        local c; c = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                S.keybinds[stateKey] = input.KeyCode; kbtn.Text = input.KeyCode.Name; kbtn.TextColor3 = C.ORANGE; S.keybindListening = nil; c:Disconnect()
            end
        end)
    end)
    table.insert(S.allRows, {frame = row, label = label:lower(), tab = tab})
end

--------------------------------------------------------------------------------
-- BUILD TABS
--------------------------------------------------------------------------------

-- ██ BRAINROTS TAB ██
mkSection("Brainrots", "ESP & Detection")
local _, _, forceBrainrotEsp = mkToggle("Brainrots", "🧠 Brainrot ESP (Rarity + Name)", false, function(v) S.brainrotEsp = v end)
local _, _, forceBaseEsp = mkToggle("Brainrots", "🏠 Base ESP (All Bases)", false, function(v) S.baseEsp = v end)
local _, _, forceConvAlert = mkToggle("Brainrots", "🔔 Conveyor Alert (Legendary+)", false, function(v) S.conveyorAlert = v end)

mkSection("Brainrots", "Automation")
local _, _, forceAutoCollect = mkToggle("Brainrots", "💰 Auto-Collect Cash", false, function(v) S.autoCollect = v end)

mkSection("Brainrots", "Teleport")
mkActionBtn("Brainrots", "📍  Teleport to Conveyor Belt", C.ACCENT, function()
    local conv = findConveyor()
    if conv then
        local root = getRoot()
        if root then
            local target = conv:IsA("Model") and (conv.PrimaryPart and conv.PrimaryPart.Position or conv:GetBoundingBox().Position) or conv.Position
            root.CFrame = CFrame.new(target + Vector3.new(0, 5, 0))
            pushNotification("Teleported", "Moved to conveyor belt", C.GREEN, 3)
        end
    else
        pushNotification("Not Found", "Could not find conveyor belt", C.RED, 3)
    end
end)

mkActionBtn("Brainrots", "🏠  Teleport to My Base", C.GREEN, function()
    local root = getRoot()
    if not root then return end
    -- Try to find player's own base
    local myBase = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = obj.Name:lower()
        if (nameLower:find("base") or nameLower:find("plot")) and (obj:IsA("Model") or obj:IsA("Folder")) then
            local owner = nil
            pcall(function() owner = obj:GetAttribute("Owner") end)
            local ownerVal = obj:FindFirstChild("Owner")
            if owner == LocalPlayer.Name or owner == LocalPlayer.UserId
                or (ownerVal and ownerVal:IsA("StringValue") and ownerVal.Value == LocalPlayer.Name)
                or (ownerVal and ownerVal:IsA("ObjectValue") and ownerVal.Value == LocalPlayer) then
                myBase = obj; break
            end
        end
    end
    if myBase then
        local pos = myBase:IsA("Model") and myBase:GetBoundingBox().Position or (myBase:FindFirstChildOfClass("BasePart") and myBase:FindFirstChildOfClass("BasePart").Position or root.Position)
        root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        pushNotification("Teleported", "Moved to your base", C.GREEN, 3)
    else
        pushNotification("Not Found", "Could not identify your base", C.RED, 3)
    end
end)

-- ██ PLAYERS TAB ██
mkSection("Players", "ESP & Tracking")
local _, _, forcePlayerEsp = mkToggle("Players", "👁️ Player ESP (Name + Distance)", false, function(v) S.playerEsp = v end)

mkSection("Players", "Player List")

local playerListRows = {}
local function rebuildPlayerList()
    for _, r in ipairs(playerListRows) do if r and r.Parent then r:Destroy() end end
    playerListRows = {}; ordC["Players"] = 3
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local p = S.tabFrames["Players"]
            local row = Instance.new("Frame", p); row.Size = UDim2.new(1,0,0,34)
            row.BackgroundColor3 = C.BG2; row.BackgroundTransparency = 0.4; row.BorderSizePixel = 0; row.LayoutOrder = nOrd("Players")
            Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)

            local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.4,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency = 1; lbl.Text = plr.DisplayName; lbl.TextColor3 = C.TEXT1; lbl.TextSize = 12; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left

            local function mkSm(text, xP, col, cb2)
                local b = Instance.new("TextButton", row); b.Size = UDim2.new(0,52,0,20); b.Position = UDim2.new(1,xP,0.5,-10)
                b.BackgroundColor3 = col; b.BackgroundTransparency = 0.2; b.Text = text; b.TextColor3 = Color3.new(1,1,1)
                b.TextSize = 10; b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0; b.AutoButtonColor = false
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,4); b.MouseButton1Click:Connect(cb2); return b
            end

            mkSm("TP", -170, C.ACCENT, function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local root = getRoot()
                    if root then root.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3) end
                    pushNotification("Teleported", "Moved to " .. plr.DisplayName, C.GREEN, 3)
                end
            end)

            mkSm("TP Base", -114, C.ACCENT2, function()
                -- Try to find target player's base
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local nm = obj.Name:lower()
                    if (nm:find("base") or nm:find("plot")) and (obj:IsA("Model") or obj:IsA("Folder")) then
                        local owner = nil
                        pcall(function() owner = obj:GetAttribute("Owner") end)
                        local ownerVal = obj:FindFirstChild("Owner")
                        if owner == plr.Name or owner == plr.UserId
                            or (ownerVal and ownerVal:IsA("StringValue") and ownerVal.Value == plr.Name)
                            or (ownerVal and ownerVal:IsA("ObjectValue") and ownerVal.Value == plr) then
                            local root = getRoot()
                            if root then
                                local pos = obj:IsA("Model") and obj:GetBoundingBox().Position or (obj:FindFirstChildOfClass("BasePart") and obj:FindFirstChildOfClass("BasePart").Position)
                                if pos then root.CFrame = CFrame.new(pos + Vector3.new(0,5,0)) end
                            end
                            pushNotification("Teleported", "At " .. plr.DisplayName .. "'s base", C.GREEN, 3)
                            return
                        end
                    end
                end
                pushNotification("Not Found", "Could not find " .. plr.DisplayName .. "'s base", C.RED, 3)
            end)

            mkSm("Spec", -58, C.CYAN, function()
                if plr.Character then Camera.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid") end
            end)

            mkSm("Unspec", -2, C.BG4, function()
                local h = getHum(); if h then Camera.CameraSubject = h end
            end)

            table.insert(playerListRows, row)
        end
    end
end
rebuildPlayerList()
Players.PlayerAdded:Connect(function() task.wait(0.5); rebuildPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); rebuildPlayerList() end)

-- ██ MOVEMENT TAB ██
mkSection("Movement", "Flight")
local _, _, forceFly = mkToggle("Movement", "✈️ Fly", false, function(v) S.fly = v end)
local setFlySpd = mkSlider("Movement", "Fly Speed", 10, 300, 80, function(v) S.flySpeed = v end)
mkSection("Movement", "Speed & Physics")
local setWs = mkSlider("Movement", "WalkSpeed", 16, 200, 16, function(v) S.walkSpeed = v; local h = getHum(); if h then h.WalkSpeed = v end end)
local setJp = mkSlider("Movement", "JumpPower", 50, 300, 50, function(v) S.jumpPower = v; local h = getHum(); if h then h.UseJumpPower = true; h.JumpPower = v end end)
local _, _, forceBoost = mkToggle("Movement", "⚡ Speed Boost (CFrame)", false, function(v) S.speedBoost = v end)
local setBoostSpd = mkSlider("Movement", "Boost Speed", 20, 200, 80, function(v) S.boostSpeed = v end)
mkSection("Movement", "Collision & Camera")
local _, _, forceNoclip = mkToggle("Movement", "👻 Noclip", false, function(v) S.noclip = v end)
local _, _, forceInfJump = mkToggle("Movement", "🦘 Infinite Jump", false, function(v) S.infJump = v end)
local _, _, forceFreecam = mkToggle("Movement", "🎥 Freecam", false, function(v) S.freecam = v end)

-- ██ WORLD TAB ██
mkSection("World", "Visuals")
local _, _, forceFullbright = mkToggle("World", "☀️ Fullbright", false, function(v) S.fullbright = v end)
mkSection("World", "Server")
local _, _, forceAntiAfk = mkToggle("World", "🔄 Anti-AFK", false, function(v) S.antiAfk = v end)

mkSection("World", "Rarity Color Legend")
-- Rarity color reference
for _, rarity in ipairs(RARITY_ORDER) do
    local p = S.tabFrames["World"]
    local row = Instance.new("Frame", p); row.Size = UDim2.new(1,0,0,22)
    row.BackgroundTransparency = 1; row.LayoutOrder = nOrd("World")

    local dot = Instance.new("Frame", row); dot.Size = UDim2.new(0,12,0,12); dot.Position = UDim2.new(0,10,0.5,-6)
    dot.BackgroundColor3 = RARITY_COLORS[rarity]; dot.BorderSizePixel = 0; Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local l = Instance.new("TextLabel", row); l.Size = UDim2.new(1,-34,1,0); l.Position = UDim2.new(0,28,0,0)
    l.BackgroundTransparency = 1; l.Text = rarity; l.TextColor3 = RARITY_COLORS[rarity]; l.TextSize = 11; l.Font = Enum.Font.GothamBold; l.TextXAlignment = Enum.TextXAlignment.Left
end

-- ██ CONFIG TAB ██
mkSection("Config", "Keybinds")
mkKeybind("Config", "Brainrot ESP", "brainrotEsp")
mkKeybind("Config", "Toggle Fly", "fly")
mkKeybind("Config", "Toggle Noclip", "noclip")
mkKeybind("Config", "Toggle Freecam", "freecam")

mkSection("Config", "Data")
mkActionBtn("Config", "💾  Save Config", C.GREEN, function()
    local sv = PlayerGui:FindFirstChild("SABConfig")
    if not sv then sv = Instance.new("StringValue", PlayerGui); sv.Name = "SABConfig" end
    local cfg = {ws = S.walkSpeed, jp = S.jumpPower, fs = S.flySpeed, bs = S.boostSpeed, kb = {}}
    for k, v in pairs(S.keybinds) do cfg.kb[k] = v.Name end
    sv.Value = game:GetService("HttpService"):JSONEncode(cfg)
    pushNotification("Config Saved", "Settings stored for this session", C.GREEN, 3)
end)

mkActionBtn("Config", "📂  Load Config", C.ACCENT, function()
    local sv = PlayerGui:FindFirstChild("SABConfig")
    if sv and sv.Value ~= "" then
        local ok, cfg = pcall(function() return game:GetService("HttpService"):JSONDecode(sv.Value) end)
        if ok and cfg then
            if cfg.ws then setWs(cfg.ws) end; if cfg.jp then setJp(cfg.jp) end
            if cfg.fs then setFlySpd(cfg.fs) end; if cfg.bs then setBoostSpd(cfg.bs) end
            if cfg.kb then for k, v in pairs(cfg.kb) do pcall(function() S.keybinds[k] = Enum.KeyCode[v] end) end end
            pushNotification("Config Loaded", "Settings restored", C.GREEN, 3)
        end
    else pushNotification("No Config", "Nothing saved yet", C.RED, 3) end
end)

mkActionBtn("Config", "🗑️  Reset All", C.RED, function()
    local sv = PlayerGui:FindFirstChild("SABConfig"); if sv then sv:Destroy() end
    setWs(16); setJp(50); setFlySpd(80); setBoostSpd(80)
    S.keybinds = {brainrotEsp = Enum.KeyCode.E, fly = Enum.KeyCode.F, noclip = Enum.KeyCode.V, freecam = Enum.KeyCode.G}
    pushNotification("Reset", "All settings cleared", C.ORANGE, 3)
end)

local infoLbl = Instance.new("TextLabel", S.tabFrames["Config"])
infoLbl.Size = UDim2.new(1,0,0,28); infoLbl.BackgroundTransparency = 1; infoLbl.LayoutOrder = nOrd("Config")
infoLbl.Text = "SAB Admin v3.0 • Toggle: RightShift"; infoLbl.TextColor3 = C.TEXT3; infoLbl.TextSize = 10; infoLbl.Font = Enum.Font.GothamMedium

--------------------------------------------------------------------------------
-- SEARCH
--------------------------------------------------------------------------------
SB:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SB.Text:lower():gsub("%s+","")
    if q == "" then
        for _, d in ipairs(S.allRows) do d.frame.Visible = true end; switchTab(S.activeTab)
    else
        for _, f in pairs(S.tabFrames) do f.Visible = true end
        for _, d in ipairs(S.allRows) do d.frame.Visible = d.label:find(q, 1, true) ~= nil end
    end
end)

--------------------------------------------------------------------------------
-- DRAGGING
--------------------------------------------------------------------------------
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        S.dragging = true; S.dragStart = i.Position; S.startPos = Main.Position
    end
end)
TB.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then S.dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if S.dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - S.dragStart
        Main.Position = UDim2.new(S.startPos.X.Scale, S.startPos.X.Offset+d.X, S.startPos.Y.Scale, S.startPos.Y.Offset+d.Y)
    end
end)

--------------------------------------------------------------------------------
-- OPEN / CLOSE / MINIMIZE
--------------------------------------------------------------------------------
local fullSize = UDim2.new(0, C.MENU_W, 0, C.MENU_H)

local function showMenu()
    S.menuOpen = true; Main.Visible = true; Main.Size = UDim2.new(0,C.MENU_W,0,0); Main.BackgroundTransparency = 1
    tw(Main, {Size = fullSize, BackgroundTransparency = 0.02}, C.ANIM, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end
local function hideMenu()
    local t = tw(Main, {Size = UDim2.new(0,C.MENU_W,0,0), BackgroundTransparency = 1}, C.ANIM)
    t.Completed:Connect(function() S.menuOpen = false; Main.Visible = false end)
end

MinBtn.MouseButton1Click:Connect(function()
    if S.minimized then
        S.minimized = false
        tw(Main, {Size = fullSize}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.delay(0.08, function() SF.Visible = true; TabBar.Visible = true; for _,f in pairs(S.tabFrames) do f.Visible = false end; S.tabFrames[S.activeTab].Visible = true end)
    else
        S.minimized = true; SF.Visible = false; TabBar.Visible = false; for _,f in pairs(S.tabFrames) do f.Visible = false end
        tw(Main, {Size = UDim2.new(0,C.MENU_W,0,42)}, 0.22)
    end
end)
CloseBtn.MouseButton1Click:Connect(function() hideMenu() end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or S.keybindListening then return end
    if input.KeyCode == C.TOGGLE_KEY then if S.menuOpen then hideMenu() else showMenu() end end
    for key, kc in pairs(S.keybinds) do
        if input.KeyCode == kc then
            if key == "brainrotEsp" then forceBrainrotEsp(not S.brainrotEsp)
            elseif key == "fly" then forceFly(not S.fly)
            elseif key == "noclip" then forceNoclip(not S.noclip)
            elseif key == "freecam" then forceFreecam(not S.freecam)
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- FEATURE IMPLEMENTATIONS
--------------------------------------------------------------------------------

-- ══════ BRAINROT ESP ══════
local brainrotTagFolder = Instance.new("Folder", Gui); brainrotTagFolder.Name = "BrainrotTags"

local function clearBrainrotEsp()
    for _, h in pairs(S.brainrotHighlights) do if h and h.Parent then h:Destroy() end end; S.brainrotHighlights = {}
    for _, t in pairs(S.brainrotTags) do if t and t.Parent then t:Destroy() end end; S.brainrotTags = {}
end

local function updateBrainrotEsp()
    clearBrainrotEsp()
    if not S.brainrotEsp then return end

    local brainrots = findBrainrots()
    local myRoot = getRoot()

    for _, model in ipairs(brainrots) do
        local rarity = detectRarity(model)
        local income = detectIncome(model)
        local color = getRarityColor(rarity)

        -- Highlight
        local hl = Instance.new("Highlight")
        hl.Name = "BrainrotESP"; hl.FillColor = color; hl.FillTransparency = 0.5
        hl.OutlineColor = color; hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = model; hl.Parent = model
        table.insert(S.brainrotHighlights, hl)

        -- Billboard tag
        local primaryPart = model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
        if primaryPart then
            local bg = Instance.new("BillboardGui", brainrotTagFolder)
            bg.Adornee = primaryPart; bg.Size = UDim2.new(0, 180, 0, 46)
            bg.StudsOffset = Vector3.new(0, 3, 0); bg.AlwaysOnTop = true

            local dist = myRoot and math.floor((myRoot.Position - primaryPart.Position).Magnitude) or 0

            -- Name
            local nl = Instance.new("TextLabel", bg); nl.Size = UDim2.new(1,0,0.45,0)
            nl.BackgroundTransparency = 1; nl.Text = model.Name
            nl.TextColor3 = color; nl.TextSize = 13; nl.Font = Enum.Font.GothamBold; nl.TextStrokeTransparency = 0.3

            -- Rarity + Income + Distance
            local incStr = income and (formatMoney(income) .. "/s") or "?"
            local il = Instance.new("TextLabel", bg); il.Size = UDim2.new(1,0,0.35,0); il.Position = UDim2.new(0,0,0.45,0)
            il.BackgroundTransparency = 1; il.Text = "["..rarity.."] $"..incStr.." • "..dist.."m"
            il.TextColor3 = color; il.TextSize = 10; il.Font = Enum.Font.GothamMedium; il.TextStrokeTransparency = 0.4

            table.insert(S.brainrotTags, bg)
        end
    end
end

-- ══════ BASE ESP ══════
local baseTagFolder = Instance.new("Folder", Gui); baseTagFolder.Name = "BaseTags"

local function clearBaseEsp()
    for _, h in pairs(S.baseHighlights) do if h and h.Parent then h:Destroy() end end; S.baseHighlights = {}
    for _, t in pairs(S.baseTags) do if t and t.Parent then t:Destroy() end end; S.baseTags = {}
end

local function updateBaseEsp()
    clearBaseEsp()
    if not S.baseEsp then return end
    local bases = findBases()
    local myRoot = getRoot()

    for _, base in ipairs(bases) do
        local owner = "Unknown"
        pcall(function() owner = base:GetAttribute("Owner") or "Unknown" end)
        local ownerVal = base:FindFirstChild("Owner")
        if ownerVal and ownerVal:IsA("StringValue") then owner = ownerVal.Value end

        local isLocked = false
        pcall(function() isLocked = base:GetAttribute("Locked") or false end)
        local lockVal = base:FindFirstChild("Locked")
        if lockVal and lockVal:IsA("BoolValue") then isLocked = lockVal.Value end

        local color = (owner == LocalPlayer.Name) and C.GREEN or (isLocked and C.RED or C.ORANGE)

        -- Highlight
        if base:IsA("Model") then
            local hl = Instance.new("Highlight"); hl.Name = "BaseESP"
            hl.FillColor = color; hl.FillTransparency = 0.8
            hl.OutlineColor = color; hl.OutlineTransparency = 0.2
            hl.Adornee = base; hl.Parent = base
            table.insert(S.baseHighlights, hl)
        end

        -- Tag
        local part = (base:IsA("Model") and base.PrimaryPart) or base:FindFirstChildOfClass("BasePart")
        if part then
            local dist = myRoot and math.floor((myRoot.Position - part.Position).Magnitude) or 0
            local bg = Instance.new("BillboardGui", baseTagFolder)
            bg.Adornee = part; bg.Size = UDim2.new(0, 160, 0, 36); bg.StudsOffset = Vector3.new(0, 8, 0); bg.AlwaysOnTop = true
            local nl = Instance.new("TextLabel", bg); nl.Size = UDim2.new(1,0,0.5,0); nl.BackgroundTransparency = 1
            nl.Text = "🏠 " .. owner; nl.TextColor3 = color; nl.TextSize = 12; nl.Font = Enum.Font.GothamBold; nl.TextStrokeTransparency = 0.4
            local sl = Instance.new("TextLabel", bg); sl.Size = UDim2.new(1,0,0.5,0); sl.Position = UDim2.new(0,0,0.5,0); sl.BackgroundTransparency = 1
            sl.Text = (isLocked and "🔒 Locked" or "🔓 Open") .. " • " .. dist .. "m"
            sl.TextColor3 = isLocked and C.RED or C.GREEN; sl.TextSize = 10; sl.Font = Enum.Font.GothamMedium; sl.TextStrokeTransparency = 0.5
            table.insert(S.baseTags, bg)
        end
    end
end

-- ══════ PLAYER ESP ══════
local playerTagFolder = Instance.new("Folder", Gui); playerTagFolder.Name = "PlayerTags"

local function clearPlayerEsp()
    for _, h in pairs(S.playerHighlights) do if h and h.Parent then h:Destroy() end end; S.playerHighlights = {}
    for _, t in pairs(S.playerTags) do if t and t.Parent then t:Destroy() end end; S.playerTags = {}
end

local function updatePlayerEsp()
    clearPlayerEsp()
    if not S.playerEsp then return end
    local myRoot = getRoot()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and hum then
                -- Highlight
                if not plr.Character:FindFirstChild("PlayerESP_HL") then
                    local hl = Instance.new("Highlight"); hl.Name = "PlayerESP_HL"
                    hl.FillColor = C.CYAN; hl.FillTransparency = 0.7
                    hl.OutlineColor = Color3.new(1,1,1); hl.OutlineTransparency = 0.2
                    hl.Adornee = plr.Character; hl.Parent = plr.Character
                    table.insert(S.playerHighlights, hl)
                end

                -- Tag
                local dist = myRoot and math.floor((myRoot.Position - head.Position).Magnitude) or 0
                local hpPct = math.floor((hum.Health / hum.MaxHealth) * 100)
                local bg = Instance.new("BillboardGui", playerTagFolder)
                bg.Adornee = head; bg.Size = UDim2.new(0, 160, 0, 40); bg.StudsOffset = Vector3.new(0, 2.5, 0); bg.AlwaysOnTop = true

                local nl = Instance.new("TextLabel", bg); nl.Size = UDim2.new(1,0,0.5,0); nl.BackgroundTransparency = 1
                nl.Text = plr.DisplayName; nl.TextColor3 = C.TEXT1; nl.TextSize = 13; nl.Font = Enum.Font.GothamBold; nl.TextStrokeTransparency = 0.3

                local hpCol = hpPct > 50 and C.GREEN or (hpPct > 25 and C.ORANGE or C.RED)
                local il = Instance.new("TextLabel", bg); il.Size = UDim2.new(1,0,0.4,0); il.Position = UDim2.new(0,0,0.55,0); il.BackgroundTransparency = 1
                il.Text = "HP: "..hpPct.."% • "..dist.."m"; il.TextColor3 = hpCol; il.TextSize = 10; il.Font = Enum.Font.GothamMedium; il.TextStrokeTransparency = 0.5
                table.insert(S.playerTags, bg)
            end
        end
    end
end

-- ══════ CONVEYOR ALERT ══════
local lastAlertedBrainrots = {}

local function checkConveyorAlerts()
    if not S.conveyorAlert then return end
    local brainrots = findBrainrots()
    for _, model in ipairs(brainrots) do
        local rarity = detectRarity(model)
        if ALERT_RARITIES[rarity] and not lastAlertedBrainrots[model] then
            lastAlertedBrainrots[model] = true
            local income = detectIncome(model)
            local incStr = income and ("$"..formatMoney(income).."/s") or ""
            pushNotification(
                "🚨 " .. rarity .. " SPOTTED!",
                model.Name .. " " .. incStr,
                getRarityColor(rarity), 8
            )
        end
    end
    -- Cleanup old entries
    for model, _ in pairs(lastAlertedBrainrots) do
        if not model.Parent then lastAlertedBrainrots[model] = nil end
    end
end

-- ══════ AUTO-COLLECT ══════
local function runAutoCollect()
    if not S.autoCollect then return end
    local root = getRoot(); if not root then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nm = obj.Name:lower()
        if (nm:find("cash") or nm:find("money") or nm:find("coin") or nm:find("drop")) then
            if obj:IsA("BasePart") then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < 50 then
                    pcall(function() firetouchinterest(root, obj, 0) task.wait() firetouchinterest(root, obj, 1) end)
                    local cd = obj:FindFirstChildOfClass("ClickDetector")
                    if cd then pcall(function() fireclickdetector(cd) end) end
                end
            end
        end
    end
end

-- ══════ FLY ══════
local function enableFly()
    local root = getRoot(); local hum = getHum(); if not root or not hum then return end
    hum.PlatformStand = true
    local bv = Instance.new("BodyVelocity", root); bv.Name = "FlyBV"; bv.MaxForce = Vector3.one*math.huge; bv.Velocity = Vector3.zero; S.flyBV = bv
    local bg = Instance.new("BodyGyro", root); bg.Name = "FlyBG"; bg.MaxTorque = Vector3.one*math.huge; bg.D = 100; bg.P = 10000; S.flyBG = bg
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
    disconn("fly"); if S.flyBV and S.flyBV.Parent then S.flyBV:Destroy() end; if S.flyBG and S.flyBG.Parent then S.flyBG:Destroy() end
    S.flyBV = nil; S.flyBG = nil; local h = getHum(); if h then h.PlatformStand = false end
end

-- ══════ NOCLIP ══════
local function startNoclip() S.conn["noclip"] = RunService.Stepped:Connect(function()
    if not S.noclip then return end; local ch = LocalPlayer.Character; if not ch then return end
    for _, p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
end) end
local function stopNoclip() disconn("noclip") end

-- ══════ INFINITE JUMP ══════
local function startInfJump() S.conn["infJump"] = UserInputService.JumpRequest:Connect(function()
    if not S.infJump then return end; local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end) end
local function stopInfJump() disconn("infJump") end

-- ══════ SPEED BOOST ══════
local function startBoost() S.conn["boost"] = RunService.RenderStepped:Connect(function(dt)
    if not S.speedBoost then return end; local r = getRoot(); local h = getHum(); if not r or not h then return end
    if h.MoveDirection.Magnitude > 0 then r.CFrame = r.CFrame + h.MoveDirection.Unit * S.boostSpeed * dt end
end) end
local function stopBoost() disconn("boost") end

-- ══════ FREECAM ══════
local function enableFreecam()
    S.freecamActive = true; S.origCamType = Camera.CameraType; Camera.CameraType = Enum.CameraType.Scriptable
    S.conn["freecam"] = RunService.RenderStepped:Connect(function(dt)
        if not S.freecamActive then return end; local spd = S.flySpeed * dt
        local cf = Camera.CFrame; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
        if dir.Magnitude > 0 then dir = dir.Unit end; Camera.CFrame = cf + dir * spd
    end)
end
local function disableFreecam()
    S.freecamActive = false; disconn("freecam"); Camera.CameraType = S.origCamType or Enum.CameraType.Custom
    local h = getHum(); if h then Camera.CameraSubject = h end
end

-- ══════ FULLBRIGHT ══════
local function enableFullbright()
    S.origLighting = {Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient}
    Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 1e5; Lighting.FogStart = 1e5; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(200,200,200); Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
end
local function disableFullbright()
    if S.origLighting.Brightness then Lighting.Brightness = S.origLighting.Brightness; Lighting.ClockTime = S.origLighting.ClockTime; Lighting.FogEnd = S.origLighting.FogEnd; Lighting.FogStart = S.origLighting.FogStart; Lighting.GlobalShadows = S.origLighting.GlobalShadows; Lighting.Ambient = S.origLighting.Ambient; Lighting.OutdoorAmbient = S.origLighting.OutdoorAmbient end
end

-- ══════ ANTI-AFK ══════
local function startAntiAfk()
    local vu = game:GetService("VirtualUser")
    S.conn["antiAfk"] = LocalPlayer.Idled:Connect(function() if S.antiAfk then pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.zero) end) end end)
end
local function stopAntiAfk() disconn("antiAfk") end

--------------------------------------------------------------------------------
-- MAIN LOOP
--------------------------------------------------------------------------------
local tick2 = 0
S.conn["main"] = RunService.RenderStepped:Connect(function(dt)
    tick2 += 1

    -- Brainrot ESP (every 20 frames)
    if tick2 % 20 == 0 then
        if S.brainrotEsp then updateBrainrotEsp() elseif #S.brainrotHighlights > 0 then clearBrainrotEsp() end
        if S.baseEsp then updateBaseEsp() elseif #S.baseHighlights > 0 then clearBaseEsp() end
    end

    -- Player ESP (every 10 frames)
    if tick2 % 10 == 0 then
        if S.playerEsp then updatePlayerEsp() elseif #S.playerHighlights > 0 then clearPlayerEsp() end
    end

    -- Conveyor alerts (every 30 frames)
    if tick2 % 30 == 0 then checkConveyorAlerts() end

    -- Auto-collect (every 5 frames)
    if tick2 % 5 == 0 and S.autoCollect then runAutoCollect() end

    -- Toggle handling
    if S.fly and not S.flyBV then enableFly() elseif not S.fly and S.flyBV then disableFly() end
    if S.fullbright and not S.origLighting.Brightness then enableFullbright() elseif not S.fullbright and S.origLighting.Brightness then disableFullbright(); S.origLighting = {} end
    if S.noclip and not S.conn["noclip"] then startNoclip() elseif not S.noclip and S.conn["noclip"] then stopNoclip() end
    if S.infJump and not S.conn["infJump"] then startInfJump() elseif not S.infJump and S.conn["infJump"] then stopInfJump() end
    if S.speedBoost and not S.conn["boost"] then startBoost() elseif not S.speedBoost and S.conn["boost"] then stopBoost() end
    if S.freecam and not S.freecamActive then enableFreecam() elseif not S.freecam and S.freecamActive then disableFreecam() end
    if S.antiAfk and not S.conn["antiAfk"] then startAntiAfk() elseif not S.antiAfk and S.conn["antiAfk"] then stopAntiAfk() end
end)

--------------------------------------------------------------------------------
-- CHARACTER RESPAWN
--------------------------------------------------------------------------------
local function onCharAdded(char)
    local hum = char:WaitForChild("Humanoid", 10); if not hum then return end; char:WaitForChild("HumanoidRootPart", 10)
    task.defer(function() if hum then hum.WalkSpeed = S.walkSpeed; hum.UseJumpPower = true; hum.JumpPower = S.jumpPower end end)
    if S.fly then disableFly(); task.wait(0.2); enableFly() end
    if S.noclip then stopNoclip(); task.wait(0.1); startNoclip() end
    if S.speedBoost then stopBoost(); task.wait(0.1); startBoost() end
end
LocalPlayer.CharacterAdded:Connect(onCharAdded)
if LocalPlayer.Character then task.spawn(function() onCharAdded(LocalPlayer.Character) end) end

--------------------------------------------------------------------------------
-- INITIAL ANIMATION
--------------------------------------------------------------------------------
Main.Size = UDim2.new(0,C.MENU_W,0,0); Main.BackgroundTransparency = 1; Main.Visible = true
task.wait(0.3); showMenu()
pushNotification("🧠 SAB Admin v3.0", "Press RightShift to toggle menu", C.ACCENT, 5)
print("[SAB Admin v3.0] Loaded! Press RightShift to toggle.")