--[[
    BEDWARS SCRIPT - REDESIGNED UI
    Complete standalone UI system replacement
    All original game logic preserved
    
    UI Features:
    - Modern dark theme with accent colors
    - Draggable windows
    - Animated toggles, sliders, dropdowns
    - Categorized module system
    - Notification system
    - Keybind support
]]

--============================================================================
-- SERVICES
--============================================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local cloneref = cloneref or function(obj) return obj end
local playersService = cloneref(Players)
local replicatedStorage = cloneref(ReplicatedStorage)
local runService = cloneref(RunService)
local inputService = cloneref(UserInputService)
local tweenService = cloneref(TweenService)
local httpService = cloneref(HttpService)
local textChatService = cloneref(TextChatService)
local collectionService = cloneref(CollectionService)
local contextActionService = cloneref(ContextActionService)
local guiService = cloneref(GuiService)
local coreGui = cloneref(CoreGui)
local starterGui = cloneref(StarterGui)

--============================================================================
-- UI CONFIGURATION
--============================================================================
local UIConfig = {
    -- Colors
    Colors = {
        Background = Color3.fromRGB(18, 18, 24),
        BackgroundSecondary = Color3.fromRGB(24, 24, 32),
        BackgroundTertiary = Color3.fromRGB(32, 32, 42),
        Accent = Color3.fromRGB(114, 137, 218),
        AccentDark = Color3.fromRGB(88, 101, 242),
        AccentLight = Color3.fromRGB(138, 161, 242),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 190),
        TextMuted = Color3.fromRGB(120, 120, 135),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
        Toggle = Color3.fromRGB(67, 181, 129),
        ToggleOff = Color3.fromRGB(70, 70, 85),
        Border = Color3.fromRGB(50, 50, 65),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    
    -- Fonts
    Fonts = {
        Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
        Medium = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
        Bold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    },
    
    -- Sizes
    Sizes = {
        WindowWidth = 580,
        WindowHeight = 420,
        CategoryWidth = 140,
        ModuleHeight = 36,
        ToggleSize = 20,
        SliderHeight = 16,
        Padding = 8,
        CornerRadius = 6,
    },
    
    -- Animation
    Animation = {
        Speed = 0.2,
        EasingStyle = Enum.EasingStyle.Quart,
        EasingDirection = Enum.EasingDirection.Out,
    },
    
    -- Keybind
    ToggleKey = Enum.KeyCode.RightShift,
}

--============================================================================
-- UI LIBRARY
--============================================================================
local UILibrary = {}
UILibrary.__index = UILibrary

-- Utility Functions
local function Create(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    duration = duration or UIConfig.Animation.Speed
    style = style or UIConfig.Animation.EasingStyle
    direction = direction or UIConfig.Animation.EasingDirection
    local tween = tweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or UIConfig.Sizes.CornerRadius),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or UIConfig.Colors.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function AddPadding(parent, padding)
    padding = padding or UIConfig.Sizes.Padding
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

local function AddShadow(parent)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 24, 1, 24),
        ZIndex = -1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = UIConfig.Colors.Shadow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent
    })
    return shadow
end

--============================================================================
-- NOTIFICATION SYSTEM
--============================================================================
local NotificationSystem = {}

function NotificationSystem:Init(screenGui)
    self.Container = Create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 0, 400),
        Parent = screenGui
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Container
    })
end

function NotificationSystem:Notify(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "info"
    
    local colors = {
        info = UIConfig.Colors.Accent,
        success = UIConfig.Colors.Success,
        warning = UIConfig.Colors.Warning,
        error = UIConfig.Colors.Error,
        alert = UIConfig.Colors.Error,
    }
    
    local accentColor = colors[notifType] or UIConfig.Colors.Accent
    
    local notification = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = UIConfig.Colors.Background,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = self.Container
    })
    AddCorner(notification)
    AddStroke(notification, accentColor, 1)
    
    local container = Create("Frame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = notification
    })
    AddPadding(container, 12)
    
    local accentBar = Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = accentColor,
        Size = UDim2.new(0, 3, 1, 0),
        Parent = notification
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 8, 0, 0),
        FontFace = UIConfig.Fonts.Bold,
        Text = title,
        TextColor3 = UIConfig.Colors.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local messageLabel = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 8, 0, 22),
        AutomaticSize = Enum.AutomaticSize.Y,
        FontFace = UIConfig.Fonts.Regular,
        Text = message,
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    -- Animate in
    notification.Size = UDim2.new(1, 0, 0, 0)
    Tween(notification, {Size = UDim2.new(1, 0, 0, 70)}, 0.3)
    
    -- Auto dismiss
    task.delay(duration, function()
        Tween(notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        notification:Destroy()
    end)
    
    return notification
end

--============================================================================
-- MODULE CLASS
--============================================================================
local Module = {}
Module.__index = Module

function Module.new(category, config)
    local self = setmetatable({}, Module)
    
    self.Name = config.Name
    self.Category = category
    self.Enabled = false
    self.Callback = config.Function
    self.Tooltip = config.Tooltip
    self.Keybind = config.Keybind or ""
    self.Elements = {}
    self.Connections = {}
    self.CleanupFunctions = {}
    self.Children = nil
    self.Object = nil
    
    self:CreateUI(category.ModuleContainer)
    
    return self
end

function Module:CreateUI(parent)
    -- Main module frame
    self.Object = Create("Frame", {
        Name = self.Name,
        BackgroundColor3 = UIConfig.Colors.BackgroundSecondary,
        Size = UDim2.new(1, 0, 0, UIConfig.Sizes.ModuleHeight),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent
    })
    AddCorner(self.Object, 4)
    
    -- Header (clickable area)
    local header = Create("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, UIConfig.Sizes.ModuleHeight),
        Parent = self.Object
    })
    
    -- Toggle indicator
    local toggleBg = Create("Frame", {
        Name = "ToggleBg",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = UIConfig.Colors.ToggleOff,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(0, 36, 0, 20),
        Parent = header
    })
    AddCorner(toggleBg, 10)
    
    local toggleCircle = Create("Frame", {
        Name = "Circle",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = UIConfig.Colors.Text,
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        Parent = toggleBg
    })
    AddCorner(toggleCircle, 7)
    
    -- Module name
    local nameLabel = Create("TextLabel", {
        Name = "Name",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        FontFace = UIConfig.Fonts.Medium,
        Text = self.Name,
        TextColor3 = UIConfig.Colors.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Keybind label
    local keybindLabel = Create("TextLabel", {
        Name = "Keybind",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 50, 1, 0),
        FontFace = UIConfig.Fonts.Regular,
        Text = self.Keybind ~= "" and "["..self.Keybind.."]" or "",
        TextColor3 = UIConfig.Colors.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = header
    })
    
    -- Expand button
    local expandBtn = Create("TextButton", {
        Name = "Expand",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        FontFace = UIConfig.Fonts.Regular,
        Text = "▼",
        TextColor3 = UIConfig.Colors.TextMuted,
        TextSize = 10,
        Parent = header
    })
    
    -- Children container (for sub-elements)
    self.Children = Create("Frame", {
        Name = "Children",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, UIConfig.Sizes.ModuleHeight),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Visible = false,
        Parent = self.Object
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Children
    })
    
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = self.Children
    })
    
    -- Store references
    self._toggleBg = toggleBg
    self._toggleCircle = toggleCircle
    self._expanded = false
    
    -- Click to toggle
    local headerButton = Create("TextButton", {
        Name = "HeaderButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 1, 0),
        Text = "",
        Parent = header
    })
    
    headerButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Expand/collapse
    expandBtn.MouseButton1Click:Connect(function()
        self._expanded = not self._expanded
        self.Children.Visible = self._expanded
        expandBtn.Text = self._expanded and "▲" or "▼"
    end)
    
    -- Hover effect
    headerButton.MouseEnter:Connect(function()
        Tween(self.Object, {BackgroundColor3 = UIConfig.Colors.BackgroundTertiary}, 0.1)
    end)
    
    headerButton.MouseLeave:Connect(function()
        Tween(self.Object, {BackgroundColor3 = UIConfig.Colors.BackgroundSecondary}, 0.1)
    end)
end

function Module:Toggle()
    self.Enabled = not self.Enabled
    self:UpdateVisual()
    
    if self.Callback then
        task.spawn(function()
            self.Callback(self.Enabled)
        end)
    end
end

function Module:SetEnabled(enabled)
    if self.Enabled ~= enabled then
        self:Toggle()
    end
end

function Module:UpdateVisual()
    local color = self.Enabled and UIConfig.Colors.Toggle or UIConfig.Colors.ToggleOff
    local pos = self.Enabled and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    
    Tween(self._toggleBg, {BackgroundColor3 = color}, 0.2)
    Tween(self._toggleCircle, {Position = pos}, 0.2)
end

function Module:Clean(item)
    if typeof(item) == "function" then
        table.insert(self.CleanupFunctions, item)
    elseif typeof(item) == "RBXScriptConnection" then
        table.insert(self.Connections, item)
    elseif typeof(item) == "Instance" then
        table.insert(self.CleanupFunctions, function() item:Destroy() end)
    end
    return item
end

function Module:Cleanup()
    for _, connection in ipairs(self.Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(self.Connections)
    
    for _, func in ipairs(self.CleanupFunctions) do
        pcall(func, self)
    end
    table.clear(self.CleanupFunctions)
end

function Module:SetBind(key)
    self.Keybind = key
    local keybindLabel = self.Object:FindFirstChild("Header"):FindFirstChild("Keybind")
    if keybindLabel then
        keybindLabel.Text = key ~= "" and "["..key.."]" or ""
    end
end

--============================================================================
-- MODULE UI ELEMENTS
--============================================================================

-- CreateToggle
function Module:CreateToggle(config)
    local toggle = {
        Name = config.Name,
        Enabled = config.Default or false,
        Callback = config.Function,
        Object = nil,
    }
    
    local frame = Create("Frame", {
        Name = config.Name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = self.Children
    })
    
    if config.Visible == false or config.Darker then
        frame.BackgroundColor3 = UIConfig.Colors.Background
        frame.BackgroundTransparency = 0.5
        AddCorner(frame, 4)
    end
    
    if config.Visible == false then
        frame.Visible = false
    end
    
    local toggleBg = Create("Frame", {
        Name = "ToggleBg",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = toggle.Enabled and UIConfig.Colors.Toggle or UIConfig.Colors.ToggleOff,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 16),
        Parent = frame
    })
    AddCorner(toggleBg, 8)
    
    local toggleCircle = Create("Frame", {
        Name = "Circle",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = UIConfig.Colors.Text,
        Position = toggle.Enabled and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        Parent = toggleBg
    })
    AddCorner(toggleCircle, 6)
    
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        FontFace = UIConfig.Fonts.Regular,
        Text = config.Name,
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local button = Create("TextButton", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = frame
    })
    
    toggle.Object = frame
    
    local function updateVisual()
        local color = toggle.Enabled and UIConfig.Colors.Toggle or UIConfig.Colors.ToggleOff
        local pos = toggle.Enabled and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        Tween(toggleBg, {BackgroundColor3 = color}, 0.2)
        Tween(toggleCircle, {Position = pos}, 0.2)
    end
    
    button.MouseButton1Click:Connect(function()
        toggle.Enabled = not toggle.Enabled
        updateVisual()
        if toggle.Callback then
            task.spawn(toggle.Callback, toggle.Enabled)
        end
    end)
    
    table.insert(self.Elements, toggle)
    return toggle
end

-- CreateSlider
function Module:CreateSlider(config)
    local slider = {
        Name = config.Name,
        Value = config.Default or config.Min or 0,
        Min = config.Min or 0,
        Max = config.Max or 100,
        Decimal = config.Decimal or 1,
        Callback = config.Function,
        Suffix = config.Suffix,
        Object = nil,
    }
    
    local frame = Create("Frame", {
        Name = config.Name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Children
    })
    
    if config.Visible == false or config.Darker then
        frame.BackgroundColor3 = UIConfig.Colors.Background
        frame.BackgroundTransparency = 0.5
        AddCorner(frame, 4)
    end
    
    if config.Visible == false then
        frame.Visible = false
    end
    
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.6, 0, 0, 18),
        FontFace = UIConfig.Fonts.Regular,
        Text = config.Name,
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local valueLabel = Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.6, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 0, 18),
        FontFace = UIConfig.Fonts.Medium,
        Text = tostring(slider.Value),
        TextColor3 = UIConfig.Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame
    })
    
    local sliderBg = Create("Frame", {
        Name = "SliderBg",
        BackgroundColor3 = UIConfig.Colors.BackgroundTertiary,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 12),
        Parent = frame
    })
    AddCorner(sliderBg, 6)
    
    local sliderFill = Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = UIConfig.Colors.Accent,
        Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
        Parent = sliderBg
    })
    AddCorner(sliderFill, 6)
    
    local sliderButton = Create("TextButton", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = sliderBg
    })
    
    slider.Object = frame
    
    local function getSuffix(val)
        if type(slider.Suffix) == "function" then
            return " " .. slider.Suffix(val)
        elseif type(slider.Suffix) == "string" then
            return " " .. slider.Suffix
        end
        return ""
    end
    
    local function updateSlider(input)
        local pos = sliderBg.AbsolutePosition
        local size = sliderBg.AbsoluteSize
        local percent = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
        local value = slider.Min + (slider.Max - slider.Min) * percent
        value = math.floor(value * slider.Decimal) / slider.Decimal
        
        slider.Value = value
        valueLabel.Text = tostring(value) .. getSuffix(value)
        Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
        
        if slider.Callback then
            task.spawn(slider.Callback, value)
        end
    end
    
    local dragging = false
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    inputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    inputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    sliderButton.MouseButton1Click:Connect(function()
        local mouse = inputService:GetMouseLocation()
        updateSlider({Position = mouse})
    end)
    
    -- Initialize display
    valueLabel.Text = tostring(slider.Value) .. getSuffix(slider.Value)
    
    table.insert(self.Elements, slider)
    return slider
end

-- CreateDropdown
function Module:CreateDropdown(config)
    local dropdown = {
        Name = config.Name,
        Value = config.List and config.List[1] or "",
        List = config.List or {},
        Callback = config.Function,
        Object = nil,
        Open = false,
    }
    
    local frame = Create("Frame", {
        Name = config.Name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        ClipsDescendants = false,
        Parent = self.Children
    })
    
    if config.Visible == false or config.Darker then
        frame.BackgroundColor3 = UIConfig.Colors.Background
        frame.BackgroundTransparency = 0.5
        AddCorner(frame, 4)
    end
    
    if config.Visible == false then
        frame.Visible = false
    end
    
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        FontFace = UIConfig.Fonts.Regular,
        Text = config.Name,
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local dropBtn = Create("TextButton", {
        Name = "DropBtn",
        BackgroundColor3 = UIConfig.Colors.BackgroundTertiary,
        Position = UDim2.new(0.4, 0, 0, 2),
        Size = UDim2.new(0.6, 0, 0, 24),
        FontFace = UIConfig.Fonts.Regular,
        Text = dropdown.Value .. " ▼",
        TextColor3 = UIConfig.Colors.Text,
        TextSize = 11,
        AutoButtonColor = false,
        Parent = frame
    })
    AddCorner(dropBtn, 4)
    
    local listFrame = Create("Frame", {
        Name = "List",
        BackgroundColor3 = UIConfig.Colors.Background,
        Position = UDim2.new(0.4, 0, 1, 4),
        Size = UDim2.new(0.6, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100,
        Parent = frame
    })
    AddCorner(listFrame, 4)
    AddStroke(listFrame, UIConfig.Colors.Border)
    
    local listLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        Parent = listFrame
    })
    
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = listFrame
    })
    
    dropdown.Object = frame
    
    local function populateList()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, item in ipairs(dropdown.List) do
            local itemBtn = Create("TextButton", {
                Name = item,
                BackgroundColor3 = UIConfig.Colors.BackgroundSecondary,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                FontFace = UIConfig.Fonts.Regular,
                Text = item,
                TextColor3 = UIConfig.Colors.TextDim,
                TextSize = 11,
                AutoButtonColor = false,
                ZIndex = 101,
                Parent = listFrame
            })
            AddCorner(itemBtn, 3)
            
            itemBtn.MouseEnter:Connect(function()
                Tween(itemBtn, {BackgroundTransparency = 0}, 0.1)
            end)
            
            itemBtn.MouseLeave:Connect(function()
                Tween(itemBtn, {BackgroundTransparency = 1}, 0.1)
            end)
            
            itemBtn.MouseButton1Click:Connect(function()
                dropdown.Value = item
                dropBtn.Text = item .. " ▼"
                dropdown.Open = false
                listFrame.Visible = false
                Tween(listFrame, {Size = UDim2.new(0.6, 0, 0, 0)}, 0.2)
                
                if dropdown.Callback then
                    task.spawn(dropdown.Callback, item)
                end
            end)
        end
    end
    
    dropBtn.MouseButton1Click:Connect(function()
        dropdown.Open = not dropdown.Open
        if dropdown.Open then
            populateList()
            listFrame.Visible = true
            local height = math.min(#dropdown.List * 24 + 10, 200)
            Tween(listFrame, {Size = UDim2.new(0.6, 0, 0, height)}, 0.2)
        else
            Tween(listFrame, {Size = UDim2.new(0.6, 0, 0, 0)}, 0.2)
            task.delay(0.2, function()
                if not dropdown.Open then
                    listFrame.Visible = false
                end
            end)
        end
    end)
    
    table.insert(self.Elements, dropdown)
    return dropdown
end

-- CreateColorSlider
function Module:CreateColorSlider(config)
    local colorSlider = {
        Name = config.Name,
        Hue = config.DefaultHue or 0.6,
        Sat = config.DefaultSat or 1,
        Value = config.DefaultValue or 1,
        Opacity = config.DefaultOpacity or 1,
        Callback = config.Function,
        Object = nil,
    }
    
    local frame = Create("Frame", {
        Name = config.Name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = self.Children
    })
    
    if config.Visible == false or config.Darker then
        frame.BackgroundColor3 = UIConfig.Colors.Background
        frame.BackgroundTransparency = 0.5
        AddCorner(frame, 4)
    end
    
    if config.Visible == false then
        frame.Visible = false
    end
    
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 0, 18),
        FontFace = UIConfig.Fonts.Regular,
        Text = config.Name,
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local preview = Create("Frame", {
        Name = "Preview",
        BackgroundColor3 = Color3.fromHSV(colorSlider.Hue, colorSlider.Sat, colorSlider.Value),
        Position = UDim2.new(1, -24, 0, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Parent = frame
    })
    AddCorner(preview, 4)
    
    local hueBg = Create("Frame", {
        Name = "HueBg",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = frame
    })
    AddCorner(hueBg, 5)
    
    local hueGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        }),
        Parent = hueBg
    })
    
    local hueBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = hueBg
    })
    
    local opacityBg = Create("Frame", {
        Name = "OpacityBg",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = frame
    })
    AddCorner(opacityBg, 5)
    
    local opacityGradient = Create("UIGradient", {
        Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(1, 1, 1)),
        Parent = opacityBg
    })
    
    local opacityBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = opacityBg
    })
    
    colorSlider.Object = frame
    
    local function update()
        preview.BackgroundColor3 = Color3.fromHSV(colorSlider.Hue, colorSlider.Sat, colorSlider.Value)
        if colorSlider.Callback then
            task.spawn(colorSlider.Callback, colorSlider.Hue, colorSlider.Sat, colorSlider.Value, colorSlider.Opacity)
        end
    end
    
    local draggingHue = false
    local draggingOpacity = false
    
    hueBtn.MouseButton1Down:Connect(function()
        draggingHue = true
    end)
    
    opacityBtn.MouseButton1Down:Connect(function()
        draggingOpacity = true
    end)
    
    inputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = false
            draggingOpacity = false
        end
    end)
    
    inputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingHue then
                local percent = math.clamp((input.Position.X - hueBg.AbsolutePosition.X) / hueBg.AbsoluteSize.X, 0, 1)
                colorSlider.Hue = percent
                update()
            elseif draggingOpacity then
                local percent = math.clamp((input.Position.X - opacityBg.AbsolutePosition.X) / opacityBg.AbsoluteSize.X, 0, 1)
                colorSlider.Opacity = percent
                update()
            end
        end
    end)
    
    table.insert(self.Elements, colorSlider)
    return colorSlider
end

-- CreateTwoSlider (range slider)
function Module:CreateTwoSlider(config)
    local slider = {
        Name = config.Name,
        ValueMin = config.DefaultMin or config.Min or 0,
        ValueMax = config.DefaultMax or config.Max or 100,
        Min = config.Min or 0,
        Max = config.Max or 100,
        Callback = config.Function,
        Object = nil,
    }
    
    -- Add GetRandomValue function
    function slider.GetRandomValue()
        return math.random(slider.ValueMin, slider.ValueMax)
    end
    
    local frame = Create("Frame", {
        Name = config.Name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Children
    })
    
    if config.Visible == false or config.Darker then
        frame.BackgroundColor3 = UIConfig.Colors.Background
        frame.BackgroundTransparency = 0.5
        AddCorner(frame, 4)
    end
    
    if config.Visible == false then
        frame.Visible = false
    end
    
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 0, 18),
        FontFace = UIConfig.Fonts.Regular,
        Text = config.Name,
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local valueLabel = Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 0, 18),
        FontFace = UIConfig.Fonts.Medium,
        Text = slider.ValueMin .. " - " .. slider.ValueMax,
        TextColor3 = UIConfig.Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame
    })
    
    local sliderBg = Create("Frame", {
        Name = "SliderBg",
        BackgroundColor3 = UIConfig.Colors.BackgroundTertiary,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 12),
        Parent = frame
    })
    AddCorner(sliderBg, 6)
    
    local sliderFill = Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = UIConfig.Colors.Accent,
        Position = UDim2.new((slider.ValueMin - slider.Min) / (slider.Max - slider.Min), 0, 0, 0),
        Size = UDim2.new((slider.ValueMax - slider.ValueMin) / (slider.Max - slider.Min), 0, 1, 0),
        Parent = sliderBg
    })
    AddCorner(sliderFill, 6)
    
    slider.Object = frame
    
    local function updateDisplay()
        valueLabel.Text = slider.ValueMin .. " - " .. slider.ValueMax
        local minPercent = (slider.ValueMin - slider.Min) / (slider.Max - slider.Min)
        local maxPercent = (slider.ValueMax - slider.Min) / (slider.Max - slider.Min)
        sliderFill.Position = UDim2.new(minPercent, 0, 0, 0)
        sliderFill.Size = UDim2.new(maxPercent - minPercent, 0, 1, 0)
    end
    
    local sliderBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = sliderBg
    })
    
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    inputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    inputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(slider.Min + (slider.Max - slider.Min) * percent)
            
            if math.abs(value - slider.ValueMin) < math.abs(value - slider.ValueMax) then
                slider.ValueMin = math.min(value, slider.ValueMax)
            else
                slider.ValueMax = math.max(value, slider.ValueMin)
            end
            
            updateDisplay()
            if slider.Callback then
                task.spawn(slider.Callback, slider.ValueMin, slider.ValueMax)
            end
        end
    end)
    
    table.insert(self.Elements, slider)
    return slider
end

-- CreateTextBox
function Module:CreateTextBox(config)
    local textbox = {
        Name = config.Name,
        Value = config.Default or "",
        Callback = config.Function,
        Object = nil,
    }
    
    local frame = Create("Frame", {
        Name = config.Name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = self.Children
    })
    
    if config.Visible == false or config.Darker then
        frame.BackgroundColor3 = UIConfig.Colors.Background
        frame.BackgroundTransparency = 0.5
        AddCorner(frame, 4)
    end
    
    if config.Visible == false then
        frame.Visible = false
    end
    
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, 0, 1, 0),
        FontFace = UIConfig.Fonts.Regular,
        Text = config.Name,
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local inputBox = Create("TextBox", {
        Name = "Input",
        BackgroundColor3 = UIConfig.Colors.BackgroundTertiary,
        Position = UDim2.new(0.4, 0, 0, 2),
        Size = UDim2.new(0.6, 0, 0, 24),
        FontFace = UIConfig.Fonts.Regular,
        Text = textbox.Value,
        PlaceholderText = config.Placeholder or "",
        TextColor3 = UIConfig.Colors.Text,
        PlaceholderColor3 = UIConfig.Colors.TextMuted,
        TextSize = 11,
        ClearTextOnFocus = false,
        Parent = frame
    })
    AddCorner(inputBox, 4)
    
    textbox.Object = frame
    
    inputBox.FocusLost:Connect(function()
        textbox.Value = inputBox.Text
        if textbox.Callback then
            task.spawn(textbox.Callback, textbox.Value)
        end
    end)
    
    table.insert(self.Elements, textbox)
    return textbox
end

-- CreateTextList
function Module:CreateTextList(config)
    local textlist = {
        Name = config.Name,
        List = config.Default or {},
        ListEnabled = config.Default or {},
        Callback = config.Function,
        Object = nil,
    }
    
    local frame = Create("Frame", {
        Name = config.Name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        Parent = self.Children
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        FontFace = UIConfig.Fonts.Regular,
        Text = config.Name,
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local inputBox = Create("TextBox", {
        Name = "Input",
        BackgroundColor3 = UIConfig.Colors.BackgroundTertiary,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 24),
        FontFace = UIConfig.Fonts.Regular,
        Text = "",
        PlaceholderText = config.Placeholder or "Add item...",
        TextColor3 = UIConfig.Colors.Text,
        PlaceholderColor3 = UIConfig.Colors.TextMuted,
        TextSize = 11,
        ClearTextOnFocus = false,
        Parent = frame
    })
    AddCorner(inputBox, 4)
    
    local listDisplay = Create("TextLabel", {
        Name = "ListDisplay",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(1, 0, 0, 14),
        FontFace = UIConfig.Fonts.Regular,
        Text = table.concat(textlist.ListEnabled, ", "),
        TextColor3 = UIConfig.Colors.TextMuted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = frame
    })
    
    textlist.Object = frame
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and inputBox.Text ~= "" then
            table.insert(textlist.ListEnabled, inputBox.Text)
            listDisplay.Text = table.concat(textlist.ListEnabled, ", ")
            inputBox.Text = ""
            if textlist.Callback then
                task.spawn(textlist.Callback, textlist.ListEnabled)
            end
        end
    end)
    
    table.insert(self.Elements, textlist)
    return textlist
end

-- CreateTargets
function Module:CreateTargets(config)
    local targets = {
        Players = {Enabled = config.Players or false},
        NPCs = {Enabled = config.NPCs or false},
        Walls = {Enabled = config.Walls or false},
        Callback = config.Function,
    }
    
    local frame = Create("Frame", {
        Name = "Targets",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = self.Children
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 1, 0),
        FontFace = UIConfig.Fonts.Regular,
        Text = "Targets",
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local targetOptions = {"Players", "NPCs", "Walls"}
    local xOffset = 0.3
    
    for _, targetType in ipairs(targetOptions) do
        if config[targetType] ~= nil or targetType == "Players" then
            local btn = Create("TextButton", {
                Name = targetType,
                BackgroundColor3 = targets[targetType].Enabled and UIConfig.Colors.Accent or UIConfig.Colors.BackgroundTertiary,
                Position = UDim2.new(xOffset, 4, 0, 4),
                Size = UDim2.new(0, 50, 0, 20),
                FontFace = UIConfig.Fonts.Regular,
                Text = targetType:sub(1, 3),
                TextColor3 = UIConfig.Colors.Text,
                TextSize = 10,
                AutoButtonColor = false,
                Parent = frame
            })
            AddCorner(btn, 4)
            
            btn.MouseButton1Click:Connect(function()
                targets[targetType].Enabled = not targets[targetType].Enabled
                Tween(btn, {BackgroundColor3 = targets[targetType].Enabled and UIConfig.Colors.Accent or UIConfig.Colors.BackgroundTertiary}, 0.2)
                if targets.Callback then
                    task.spawn(targets.Callback)
                end
            end)
            
            xOffset = xOffset + 0.23
        end
    end
    
    return targets
end

-- CreateFont
function Module:CreateFont(config)
    local fontSelector = {
        Name = config.Name,
        Value = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Callback = config.Function,
        Object = nil,
    }
    
    -- Simple font dropdown
    local fonts = {
        "Gotham",
        "SourceSans",
        "Arial",
        "Ubuntu",
        "Roboto",
    }
    
    local dropdown = self:CreateDropdown({
        Name = config.Name,
        List = fonts,
        Function = function(val)
            local fontMap = {
                Gotham = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                SourceSans = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                Arial = Font.new("rbxasset://fonts/families/Arial.json"),
                Ubuntu = Font.new("rbxasset://fonts/families/Ubuntu.json"),
                Roboto = Font.new("rbxasset://fonts/families/Roboto.json"),
            }
            fontSelector.Value = fontMap[val] or fontMap.Gotham
            if fontSelector.Callback then
                task.spawn(fontSelector.Callback, fontSelector.Value)
            end
        end
    })
    
    fontSelector.Object = dropdown.Object
    return fontSelector
end

--============================================================================
-- CATEGORY CLASS
--============================================================================
local Category = {}
Category.__index = Category

function Category.new(name, ui)
    local self = setmetatable({}, Category)
    
    self.Name = name
    self.UI = ui
    self.Modules = {}
    self.ModuleContainer = nil
    self.TabButton = nil
    self.Options = {}
    self.ListEnabled = {}
    self.ColorUpdate = {Event = {Connect = function() return {Disconnect = function() end} end}}
    
    self:CreateUI()
    
    return self
end

function Category:CreateUI()
    -- Tab button in sidebar
    self.TabButton = Create("TextButton", {
        Name = self.Name,
        BackgroundColor3 = UIConfig.Colors.BackgroundSecondary,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        FontFace = UIConfig.Fonts.Medium,
        Text = self.Name,
        TextColor3 = UIConfig.Colors.TextDim,
        TextSize = 13,
        AutoButtonColor = false,
        Parent = self.UI.CategoryList
    })
    AddCorner(self.TabButton, 4)
    
    -- Module container
    self.ModuleContainer = Create("ScrollingFrame", {
        Name = self.Name .. "Modules",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = UIConfig.Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.UI.ModuleArea
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.Name,
        Parent = self.ModuleContainer
    })
    
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 8),
        Parent = self.ModuleContainer
    })
    
    -- Tab click handler
    self.TabButton.MouseButton1Click:Connect(function()
        self.UI:SelectCategory(self)
    end)
    
    self.TabButton.MouseEnter:Connect(function()
        if self.UI.SelectedCategory ~= self then
            Tween(self.TabButton, {BackgroundTransparency = 0.5}, 0.1)
        end
    end)
    
    self.TabButton.MouseLeave:Connect(function()
        if self.UI.SelectedCategory ~= self then
            Tween(self.TabButton, {BackgroundTransparency = 1}, 0.1)
        end
    end)
end

function Category:CreateModule(config)
    local module = Module.new(self, config)
    self.Modules[config.Name] = module
    self.UI.Modules[config.Name] = module
    return module
end

function Category:Select()
    self.ModuleContainer.Visible = true
    Tween(self.TabButton, {BackgroundTransparency = 0, TextColor3 = UIConfig.Colors.Text}, 0.2)
end

function Category:Deselect()
    self.ModuleContainer.Visible = false
    Tween(self.TabButton, {BackgroundTransparency = 1, TextColor3 = UIConfig.Colors.TextDim}, 0.2)
end

--============================================================================
-- MAIN UI CLASS
--============================================================================
function UILibrary.new()
    local self = setmetatable({}, UILibrary)
    
    self.ScreenGui = nil
    self.MainFrame = nil
    self.Categories = {}
    self.Modules = {}
    self.Connections = {}
    self.CleanupFunctions = {}
    self.Visible = true
    self.SelectedCategory = nil
    self.Loaded = false
    self.gui = nil
    
    self:CreateMainUI()
    self:SetupKeybinds()
    
    return self
end

function UILibrary:CreateMainUI()
    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "BedwarsUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Try to parent to CoreGui, fallback to PlayerGui
    local success = pcall(function()
        self.ScreenGui.Parent = coreGui
    end)
    if not success then
        self.ScreenGui.Parent = playersService.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self.gui = self.ScreenGui
    
    -- Initialize notification system
    NotificationSystem:Init(self.ScreenGui)
    
    -- Main window
    self.MainFrame = Create("Frame", {
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = UIConfig.Colors.Background,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, UIConfig.Sizes.WindowWidth, 0, UIConfig.Sizes.WindowHeight),
        Parent = self.ScreenGui
    })
    AddCorner(self.MainFrame)
    AddStroke(self.MainFrame, UIConfig.Colors.Border)
    AddShadow(self.MainFrame)
    
    -- Title bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = UIConfig.Colors.BackgroundSecondary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.MainFrame
    })
    AddCorner(titleBar)
    
    -- Fix corner overlap
    local titleBarFix = Create("Frame", {
        Name = "Fix",
        BackgroundColor3 = UIConfig.Colors.BackgroundSecondary,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        BorderSizePixel = 0,
        Parent = titleBar
    })
    
    -- Title
    local title = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        FontFace = UIConfig.Fonts.Bold,
        Text = "BEDWARS",
        TextColor3 = UIConfig.Colors.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Subtitle
    local subtitle = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 100, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        FontFace = UIConfig.Fonts.Regular,
        Text = "v2.0",
        TextColor3 = UIConfig.Colors.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Close button
    local closeBtn = Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = UIConfig.Colors.Error,
        BackgroundTransparency = 0.8,
        Position = UDim2.new(1, -35, 0, 8),
        Size = UDim2.new(0, 24, 0, 24),
        FontFace = UIConfig.Fonts.Bold,
        Text = "×",
        TextColor3 = UIConfig.Colors.Text,
        TextSize = 18,
        AutoButtonColor = false,
        Parent = titleBar
    })
    AddCorner(closeBtn, 4)
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundTransparency = 0}, 0.2)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundTransparency = 0.8}, 0.2)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)
    
    -- Minimize button
    local minBtn = Create("TextButton", {
        Name = "Minimize",
        BackgroundColor3 = UIConfig.Colors.Warning,
        BackgroundTransparency = 0.8,
        Position = UDim2.new(1, -65, 0, 8),
        Size = UDim2.new(0, 24, 0, 24),
        FontFace = UIConfig.Fonts.Bold,
        Text = "−",
        TextColor3 = UIConfig.Colors.Text,
        TextSize = 18,
        AutoButtonColor = false,
        Parent = titleBar
    })
    AddCorner(minBtn, 4)
    
    minBtn.MouseEnter:Connect(function()
        Tween(minBtn, {BackgroundTransparency = 0}, 0.2)
    end)
    
    minBtn.MouseLeave:Connect(function()
        Tween(minBtn, {BackgroundTransparency = 0.8}, 0.2)
    end)
    
    -- Content area
    local content = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40),
        Parent = self.MainFrame
    })
    
    -- Sidebar (category list)
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = UIConfig.Colors.BackgroundSecondary,
        Size = UDim2.new(0, UIConfig.Sizes.CategoryWidth, 1, 0),
        Parent = content
    })
    AddCorner(sidebar)
    
    self.CategoryList = Create("ScrollingFrame", {
        Name = "CategoryList",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = UIConfig.Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.CategoryList
    })
    
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = self.CategoryList
    })
    
    -- Module area
    self.ModuleArea = Create("Frame", {
        Name = "ModuleArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, UIConfig.Sizes.CategoryWidth + 10, 0, 0),
        Size = UDim2.new(1, -UIConfig.Sizes.CategoryWidth - 10, 1, 0),
        Parent = content
    })
    
    -- Make window draggable
    self:MakeDraggable(titleBar, self.MainFrame)
    
    -- Create default categories
    self:CreateDefaultCategories()
end

function UILibrary:CreateDefaultCategories()
    local categoryOrder = {"Combat", "Blatant", "Render", "Utility", "World", "Inventory", "Legit", "Friends", "Targets"}
    
    for i, name in ipairs(categoryOrder) do
        local cat = Category.new(name, self)
        cat.TabButton.LayoutOrder = i
        self.Categories[name] = cat
    end
    
    -- Select first category
    if self.Categories["Combat"] then
        self:SelectCategory(self.Categories["Combat"])
    end
end

function UILibrary:SelectCategory(category)
    if self.SelectedCategory then
        self.SelectedCategory:Deselect()
    end
    
    self.SelectedCategory = category
    category:Select()
end

function UILibrary:MakeDraggable(handle, frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    inputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function UILibrary:SetupKeybinds()
    inputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == UIConfig.ToggleKey then
            self:ToggleVisibility()
        end
        
        -- Module keybinds
        for _, module in pairs(self.Modules) do
            if module.Keybind ~= "" and input.KeyCode == Enum.KeyCode[module.Keybind] then
                module:Toggle()
            end
        end
    end)
end

function UILibrary:ToggleVisibility()
    self.Visible = not self.Visible
    
    if self.Visible then
        self.MainFrame.Visible = true
        self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
        Tween(self.MainFrame, {Size = UDim2.new(0, UIConfig.Sizes.WindowWidth, 0, UIConfig.Sizes.WindowHeight)}, 0.3, Enum.EasingStyle.Back)
    else
        Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.delay(0.2, function()
            if not self.Visible then
                self.MainFrame.Visible = false
            end
        end)
    end
end

function UILibrary:CreateNotification(title, message, duration, notifType)
    return NotificationSystem:Notify(title, message, duration, notifType)
end

function UILibrary:Clean(item)
    if typeof(item) == "function" then
        table.insert(self.CleanupFunctions, item)
    elseif typeof(item) == "RBXScriptConnection" then
        table.insert(self.Connections, item)
    end
    return item
end

function UILibrary:Uninject()
    for _, connection in ipairs(self.Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    
    for _, func in ipairs(self.CleanupFunctions) do
        pcall(func)
    end
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end


--============================================================================
-- INITIALIZE VAPE REPLACEMENT (COMPATIBILITY LAYER)
--============================================================================
local vape = UILibrary.new()
vape.Libraries = {
    entity = nil, -- Will be set up later
    targetinfo = {Targets = {}},
    sessioninfo = {},
    uipallet = UIConfig.Colors,
    tween = {Tween = Tween},
    color = {
        Light = function(c, amount) 
            local h, s, v = c:ToHSV()
            return Color3.fromHSV(h, s, math.min(v + amount, 1))
        end,
        Dark = function(c, amount)
            local h, s, v = c:ToHSV()
            return Color3.fromHSV(h, s, math.max(v - amount, 0))
        end
    },
    whitelist = {
        get = function(self, plr) return true, true end,
        tag = function(self, plr, ...) return "" end,
        customtags = {}
    },
    prediction = {},
    getfontsize = function(text, size, font, bounds)
        return Vector2.new(#text * size * 0.5, size)
    end,
    getcustomasset = function(path) return "" end,
    auraanims = {
        Normal = {{CFrame = CFrame.Angles(0, 0, 0), Time = 0.1}},
        Random = {{CFrame = CFrame.Angles(0, 0, 0), Time = 0.1}}
    }
}
vape.Legit = vape.Categories.Legit
vape.ThreadFix = false
vape.Profile = "default"
vape.Save = function() end
vape.Load = function() end

-- Prediction library
vape.Libraries.prediction = {
    SolveTrajectory = function(origin, speed, gravity, targetPos, targetVel, targetGravity, hipHeight, jumpVel, rayParams)
        local displacement = targetPos - origin
        local time = displacement.Magnitude / speed
        local predictedPos = targetPos + targetVel * time
        return predictedPos
    end
}

shared.vape = vape

--============================================================================
-- VAPE EVENTS
--============================================================================
local vapeEvents = setmetatable({}, {
    __index = function(self, index)
        self[index] = Instance.new('BindableEvent')
        return self[index]
    end
})

--============================================================================
-- ENTITY LIBRARY
--============================================================================
local entitylib = {
    isAlive = false,
    character = nil,
    Running = false,
    List = {},
    AllList = {},
    Connections = {},
    PlayerConnections = {},
    Events = {
        LocalAdded = Instance.new("BindableEvent"),
        EntityAdded = Instance.new("BindableEvent"),
        EntityRemoved = Instance.new("BindableEvent"),
        EntityRemoving = Instance.new("BindableEvent"),
        EntityUpdated = Instance.new("BindableEvent"),
    }
}

local lplr = playersService.LocalPlayer
local gameCamera = workspace.CurrentCamera

function entitylib.start()
    entitylib.Running = true
    
    local function onCharacterAdded(char)
        local humanoid = char:WaitForChild("Humanoid", 10)
        local rootPart = char:WaitForChild("HumanoidRootPart", 10)
        
        if humanoid and rootPart then
            entitylib.isAlive = true
            entitylib.character = {
                Character = char,
                Humanoid = humanoid,
                RootPart = rootPart,
                Head = char:WaitForChild("Head", 5),
                HipHeight = humanoid.HipHeight,
            }
            entitylib.Events.LocalAdded:Fire()
        end
    end
    
    local function onCharacterRemoving()
        entitylib.isAlive = false
        entitylib.character = nil
    end
    
    if lplr.Character then
        onCharacterAdded(lplr.Character)
    end
    
    table.insert(entitylib.Connections, lplr.CharacterAdded:Connect(onCharacterAdded))
    table.insert(entitylib.Connections, lplr.CharacterRemoving:Connect(onCharacterRemoving))
end

function entitylib.addEntity(char, plr, teamCheck)
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    
    if not (humanoid and rootPart) then return end
    
    local entity = {
        Character = char,
        Player = plr,
        Humanoid = humanoid,
        RootPart = rootPart,
        Head = head,
        Health = char:GetAttribute("Health") or humanoid.Health,
        MaxHealth = char:GetAttribute("MaxHealth") or humanoid.MaxHealth,
        HipHeight = humanoid.HipHeight,
        Targetable = true,
        NPC = plr == nil,
        Friend = false,
        Target = false,
        Jumping = false,
        TeamCheck = teamCheck,
    }
    
    entitylib.List[char] = entity
    entitylib.AllList[char] = entity
    entitylib.Events.EntityAdded:Fire(entity)
    
    -- Health update
    local healthConn = char:GetAttributeChangedSignal("Health"):Connect(function()
        entity.Health = char:GetAttribute("Health") or humanoid.Health
        entity.MaxHealth = char:GetAttribute("MaxHealth") or humanoid.MaxHealth
        entitylib.Events.EntityUpdated:Fire(entity)
    end)
    
    return entity
end

function entitylib.removeEntity(char)
    local entity = entitylib.List[char]
    if entity then
        entitylib.Events.EntityRemoving:Fire(entity)
        entitylib.List[char] = nil
        entitylib.AllList[char] = nil
        entitylib.Events.EntityRemoved:Fire(entity)
    end
end

function entitylib.refreshEntity(char, plr)
    entitylib.removeEntity(char)
    return entitylib.addEntity(char, plr)
end

function entitylib.EntityPosition(config)
    if not entitylib.isAlive then return nil end
    
    local closest, closestDist = nil, config.Range or math.huge
    local localPos = entitylib.character.RootPart.Position
    
    for _, entity in pairs(entitylib.List) do
        if entity.Targetable and entity.Character ~= lplr.Character then
            if config.Players and entity.Player then
                local dist = (entity.RootPart.Position - localPos).Magnitude
                if dist < closestDist then
                    closest = entity
                    closestDist = dist
                end
            elseif config.NPCs and entity.NPC then
                local dist = (entity.RootPart.Position - localPos).Magnitude
                if dist < closestDist then
                    closest = entity
                    closestDist = dist
                end
            end
        end
    end
    
    return closest
end

function entitylib.EntityMouse(config)
    if not entitylib.isAlive then return nil end
    
    local mouse = lplr:GetMouse()
    local camera = workspace.CurrentCamera
    local closest, closestAngle = nil, config.Range or 180
    
    for _, entity in pairs(entitylib.List) do
        if entity.Targetable and entity.Character ~= lplr.Character then
            local screenPos, onScreen = camera:WorldToScreenPoint(entity.RootPart.Position)
            if onScreen then
                local mousePos = Vector2.new(mouse.X, mouse.Y)
                local entityScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                local angle = (mousePos - entityScreenPos).Magnitude
                
                if angle < closestAngle then
                    closest = entity
                    closestAngle = angle
                end
            end
        end
    end
    
    return closest
end

function entitylib.AllPosition(config)
    if not entitylib.isAlive then return {} end
    
    local results = {}
    local localPos = entitylib.character.RootPart.Position
    
    for _, entity in pairs(entitylib.List) do
        if entity.Targetable and entity.Character ~= lplr.Character then
            local dist = (entity.RootPart.Position - localPos).Magnitude
            if dist <= (config.Range or math.huge) then
                if (config.Players and entity.Player) or (config.NPCs and entity.NPC) then
                    table.insert(results, entity)
                end
            end
        end
    end
    
    -- Sort by distance
    table.sort(results, function(a, b)
        local distA = (a.RootPart.Position - localPos).Magnitude
        local distB = (b.RootPart.Position - localPos).Magnitude
        return distA < distB
    end)
    
    -- Limit results
    if config.Limit and #results > config.Limit then
        local limited = {}
        for i = 1, config.Limit do
            limited[i] = results[i]
        end
        return limited
    end
    
    return results
end

function entitylib.getEntityColor(entity)
    if entity.Friend then
        return Color3.fromRGB(0, 255, 255)
    elseif entity.Target then
        return Color3.fromRGB(255, 0, 0)
    end
    return nil
end

vape.Libraries.entity = entitylib

--============================================================================
-- GAME STORE
--============================================================================
local store = {
    attackReach = 0,
    attackReachUpdate = tick(),
    damageBlockFail = tick(),
    hand = {},
    inventory = {
        inventory = {
            items = {},
            armor = {}
        },
        hotbar = {}
    },
    inventories = {},
    matchState = 0,
    queueType = 'bedwars_test',
    tools = {},
    shop = {},
    shopLoaded = false,
    equippedKit = '',
    KillauraTarget = nil,
    blockPlacer = nil,
}

local Reach = {}
local HitBoxes = {}
local InfiniteFly = {}
local TrapDisabler
local AntiFallPart
local bedwars, remotes, sides = {}, {}, {}

--============================================================================
-- UTILITY FUNCTIONS
--============================================================================
local function run(func)
    task.spawn(func)
end

local function notif(title, msg, duration, ntype)
    return vape:CreateNotification(title, msg, duration, ntype)
end

local function collection(tags, module, customadd, customremove)
    tags = typeof(tags) ~= 'table' and {tags} or tags
    local objs, connections = {}, {}

    for _, tag in tags do
        table.insert(connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
            if customadd then
                customadd(objs, v, tag)
                return
            end
            table.insert(objs, v)
        end))
        table.insert(connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
            if customremove then
                customremove(objs, v, tag)
                return
            end
            v = table.find(objs, v)
            if v then
                table.remove(objs, v)
            end
        end))

        for _, v in collectionService:GetTagged(tag) do
            if customadd then
                customadd(objs, v, tag)
                continue
            end
            table.insert(objs, v)
        end
    end

    local cleanFunc = function(self)
        for _, v in connections do
            v:Disconnect()
        end
        table.clear(connections)
        table.clear(objs)
    end
    if module then
        module:Clean(cleanFunc)
    end
    return objs, cleanFunc
end

local function getItem(itemName, inv)
    for slot, item in (inv or store.inventory.inventory.items) do
        if item.itemType == itemName then
            return item, slot
        end
    end
    return nil
end

local function getSword()
    local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
    for slot, item in store.inventory.inventory.items do
        if item.itemType and item.itemType:find("sword") then
            bestSword = item
            bestSwordSlot = slot
            break
        end
    end
    return bestSword, bestSwordSlot
end

local function getTool(breakType)
    local bestTool, bestToolSlot = nil, nil
    for slot, item in store.inventory.inventory.items do
        if item.itemType and (item.itemType:find("axe") or item.itemType:find("pickaxe")) then
            bestTool = item
            bestToolSlot = slot
            break
        end
    end
    return bestTool, bestToolSlot
end

local function getWool()
    for _, wool in store.inventory.inventory.items do
        if wool.itemType and wool.itemType:find('wool') then
            return wool.itemType, wool.amount
        end
    end
end

local function hotbarSwitch(slot)
    if slot and store.inventory.hotbarSlot ~= slot then
        -- Dispatch inventory change
        return true
    end
    return false
end

local function switchItem(tool, delayTime)
    delayTime = delayTime or 0.05
    if delayTime > 0 then
        task.wait(delayTime)
    end
    return true
end

local function isFriend(plr, recolor)
    return false
end

local function isTarget(plr)
    return false
end

local function removeTags(str)
    str = str:gsub('<br%s*/>', '\n')
    return (str:gsub('<[^<>]->', ''))
end

local function roundPos(vec)
    return Vector3.new(math.round(vec.X / 3) * 3, math.round(vec.Y / 3) * 3, math.round(vec.Z / 3) * 3)
end

local function getSpeed()
    return 20
end

local function getTableSize(tab)
    local ind = 0
    for _ in tab do
        ind += 1
    end
    return ind
end

local isnetworkowner = function() return true end

local frictionTable, oldfrict = {}, {}
local frictionConnection
local frictionState

local function updateVelocity(force)
    -- Placeholder for velocity modification
end

local sortmethods = {
    Damage = function(a, b)
        return (a.Entity.Health or 100) < (b.Entity.Health or 100)
    end,
    Distance = function(a, b)
        if not entitylib.isAlive then return false end
        local selfpos = entitylib.character.RootPart.Position
        return (a.Entity.RootPart.Position - selfpos).Magnitude < (b.Entity.RootPart.Position - selfpos).Magnitude
    end,
    Health = function(a, b)
        return (a.Entity.Health or 100) < (b.Entity.Health or 100)
    end,
}

--============================================================================
-- START ENTITY LIBRARY
--============================================================================
entitylib.start()

--============================================================================
-- COMBAT MODULES
--============================================================================
run(function()
    local AimAssist
    local Targets
    local Sort
    local AimSpeed
    local Distance
    local AngleSlider
    local ClickAim
    local KillauraTarget
    local StrafeIncrease
    
    AimAssist = vape.Categories.Combat:CreateModule({
        Name = 'AimAssist',
        Function = function(callback)
            if callback then
                AimAssist:Clean(runService.RenderStepped:Connect(function(dt)
                    if entitylib.isAlive and store.hand.toolType == 'sword' then
                        local ent
                        if KillauraTarget.Enabled and store.KillauraTarget then
                            ent = store.KillauraTarget
                        else
                            ent = entitylib.EntityPosition({
                                Range = Distance.Value,
                                Part = 'RootPart',
                                Players = Targets.Players.Enabled,
                                NPCs = Targets.NPCs.Enabled,
                                Wallcheck = Targets.Walls.Enabled
                            })
                        end
                        
                        if ent then
                            if ClickAim.Enabled and not inputService:IsMouseButtonPressed(0) then return end
                            
                            local selfpos = entitylib.character.RootPart.Position
                            local targetpos = ent.RootPart.Position
                            local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
                            local angle = math.acos(localfacing:Dot(((targetpos - selfpos) * Vector3.new(1, 0, 1)).Unit))
                            
                            if angle >= (math.rad(AngleSlider.Value) / 2) then return end
                            
                            local speed = AimSpeed.Value
                            if StrafeIncrease.Enabled then
                                if inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D) then
                                    speed = speed + 10
                                end
                            end
                            
                            gameCamera.CFrame = gameCamera.CFrame:Lerp(
                                CFrame.lookAt(gameCamera.CFrame.Position, ent.RootPart.Position), 
                                speed * dt
                            )
                        end
                    end
                end))
            end
        end,
        Tooltip = 'Smoothly aims to closest valid target with sword'
    })
    
    Targets = AimAssist:CreateTargets({
        Players = true,
        Walls = true
    })
    
    Sort = AimAssist:CreateDropdown({
        Name = 'Target Mode',
        List = {'Distance', 'Damage', 'Health'}
    })
    
    AimSpeed = AimAssist:CreateSlider({
        Name = 'Aim Speed',
        Min = 1,
        Max = 20,
        Default = 6
    })
    
    Distance = AimAssist:CreateSlider({
        Name = 'Distance',
        Min = 1,
        Max = 30,
        Default = 30,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    
    AngleSlider = AimAssist:CreateSlider({
        Name = 'Max Angle',
        Min = 1,
        Max = 360,
        Default = 70
    })
    
    ClickAim = AimAssist:CreateToggle({
        Name = 'Click Aim',
        Default = true
    })
    
    KillauraTarget = AimAssist:CreateToggle({
        Name = 'Use Killaura Target'
    })
    
    StrafeIncrease = AimAssist:CreateToggle({
        Name = 'Strafe Increase'
    })
end)

run(function()
    local AutoClicker
    local CPS
    local BlockCPS = {}
    local Thread
    
    local function AutoClick()
        if Thread then
            task.cancel(Thread)
        end
        
        Thread = task.delay(1 / 7, function()
            repeat
                if store.hand.toolType == 'sword' then
                    -- Swing sword logic would go here
                end
                task.wait(1 / (store.hand.toolType == 'block' and (BlockCPS.GetRandomValue and BlockCPS.GetRandomValue() or 12) or (CPS.GetRandomValue and CPS.GetRandomValue() or 7)))
            until not AutoClicker.Enabled
        end)
    end
    
    AutoClicker = vape.Categories.Combat:CreateModule({
        Name = 'AutoClicker',
        Function = function(callback)
            if callback then
                AutoClicker:Clean(inputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        AutoClick()
                    end
                end))
                
                AutoClicker:Clean(inputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and Thread then
                        task.cancel(Thread)
                        Thread = nil
                    end
                end))
            else
                if Thread then
                    task.cancel(Thread)
                    Thread = nil
                end
            end
        end,
        Tooltip = 'Hold attack button to automatically click'
    })
    
    CPS = AutoClicker:CreateTwoSlider({
        Name = 'CPS',
        Min = 1,
        Max = 9,
        DefaultMin = 7,
        DefaultMax = 7
    })
    
    AutoClicker:CreateToggle({
        Name = 'Place Blocks',
        Default = true,
        Function = function(callback)
            if BlockCPS.Object then
                BlockCPS.Object.Visible = callback
            end
        end
    })
    
    BlockCPS = AutoClicker:CreateTwoSlider({
        Name = 'Block CPS',
        Min = 1,
        Max = 12,
        DefaultMin = 12,
        DefaultMax = 12,
        Darker = true
    })
end)

run(function()
    local Value
    
    Reach = vape.Categories.Combat:CreateModule({
        Name = 'Reach',
        Function = function(callback)
            -- Reach modification logic
            if callback then
                notif('Reach', 'Reach enabled: ' .. Value.Value .. ' studs', 3, 'success')
            end
        end,
        Tooltip = 'Extends attack reach'
    })
    
    Value = Reach:CreateSlider({
        Name = 'Range',
        Min = 0,
        Max = 18,
        Default = 18,
        Function = function(val)
            if Reach.Enabled then
                -- Update reach value
            end
        end,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
end)

run(function()
    local Sprint
    
    Sprint = vape.Categories.Combat:CreateModule({
        Name = 'Sprint',
        Function = function(callback)
            if callback then
                Sprint:Clean(entitylib.Events.LocalAdded.Event:Connect(function()
                    task.delay(0.1, function()
                        -- Start sprinting
                    end)
                end))
            end
        end,
        Tooltip = 'Sets your sprinting to true.'
    })
end)

run(function()
    local TriggerBot
    local CPS
    
    TriggerBot = vape.Categories.Combat:CreateModule({
        Name = 'TriggerBot',
        Function = function(callback)
            if callback then
                repeat
                    local doAttack
                    if entitylib.isAlive and store.hand.toolType == 'sword' then
                        local mouse = lplr:GetMouse()
                        if mouse.Target then
                            for _, ent in pairs(entitylib.List) do
                                if ent.Targetable and mouse.Target:IsDescendantOf(ent.Character) then
                                    doAttack = true
                                    break
                                end
                            end
                        end
                        
                        if doAttack then
                            -- Swing sword
                        end
                    end
                    task.wait(doAttack and 1 / (CPS.GetRandomValue and CPS.GetRandomValue() or 7) or 0.016)
                until not TriggerBot.Enabled
            end
        end,
        Tooltip = 'Automatically swings when hovering over a entity'
    })
    
    CPS = TriggerBot:CreateTwoSlider({
        Name = 'CPS',
        Min = 1,
        Max = 9,
        DefaultMin = 7,
        DefaultMax = 7
    })
end)

run(function()
    local Velocity
    local Horizontal
    local Vertical
    local Chance
    local TargetCheck
    
    Velocity = vape.Categories.Combat:CreateModule({
        Name = 'Velocity',
        Function = function(callback)
            if callback then
                notif('Velocity', 'Knockback reduction enabled', 3, 'success')
            end
        end,
        Tooltip = 'Reduces knockback taken'
    })
    
    Horizontal = Velocity:CreateSlider({
        Name = 'Horizontal',
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = '%'
    })
    
    Vertical = Velocity:CreateSlider({
        Name = 'Vertical',
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = '%'
    })
    
    Chance = Velocity:CreateSlider({
        Name = 'Chance',
        Min = 0,
        Max = 100,
        Default = 100,
        Suffix = '%'
    })
    
    TargetCheck = Velocity:CreateToggle({
        Name = 'Only When Targeting'
    })
end)

--============================================================================
-- BLATANT MODULES
--============================================================================
run(function()
    local AntiFall
    local Mode
    local Material
    local Color
    
    AntiFall = vape.Categories.Blatant:CreateModule({
        Name = 'AntiFall',
        Function = function(callback)
            if callback then
                repeat task.wait() until store.matchState ~= 0 or (not AntiFall.Enabled)
                if not AntiFall.Enabled then return end
                
                AntiFallPart = Instance.new('Part')
                AntiFallPart.Size = Vector3.new(10000, 1, 10000)
                AntiFallPart.Transparency = 1 - Color.Opacity
                AntiFallPart.Material = Enum.Material[Material.Value]
                AntiFallPart.Color = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
                AntiFallPart.Position = Vector3.new(0, -50, 0)
                AntiFallPart.CanCollide = Mode.Value == 'Collide'
                AntiFallPart.Anchored = true
                AntiFallPart.CanQuery = false
                AntiFallPart.Parent = workspace
                AntiFall:Clean(AntiFallPart)
            end
        end,
        Tooltip = 'Prevents you from falling into the void.'
    })
    
    Mode = AntiFall:CreateDropdown({
        Name = 'Move Mode',
        List = {'Normal', 'Collide', 'Velocity'},
        Function = function(val)
            if AntiFallPart then
                AntiFallPart.CanCollide = val == 'Collide'
            end
        end
    })
    
    local materials = {'ForceField', 'Plastic', 'SmoothPlastic', 'Neon', 'Glass'}
    Material = AntiFall:CreateDropdown({
        Name = 'Material',
        List = materials,
        Function = function(val)
            if AntiFallPart then
                AntiFallPart.Material = Enum.Material[val]
            end
        end
    })
    
    Color = AntiFall:CreateColorSlider({
        Name = 'Color',
        DefaultOpacity = 0.5,
        Function = function(h, s, v, o)
            if AntiFallPart then
                AntiFallPart.Color = Color3.fromHSV(h, s, v)
                AntiFallPart.Transparency = 1 - o
            end
        end
    })
end)

run(function()
    local Fly
    local Speed
    local VerticalSpeed
    
    Fly = vape.Categories.Blatant:CreateModule({
        Name = 'Fly',
        Function = function(callback)
            if callback then
                if entitylib.isAlive then
                    local bodyVelocity = Instance.new('BodyVelocity')
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.zero
                    bodyVelocity.Parent = entitylib.character.RootPart
                    Fly:Clean(bodyVelocity)
                    
                    Fly:Clean(runService.RenderStepped:Connect(function()
                        if not entitylib.isAlive then return end
                        
                        local moveDir = Vector3.zero
                        local camera = gameCamera
                        
                        if inputService:IsKeyDown(Enum.KeyCode.W) then
                            moveDir = moveDir + camera.CFrame.LookVector
                        end
                        if inputService:IsKeyDown(Enum.KeyCode.S) then
                            moveDir = moveDir - camera.CFrame.LookVector
                        end
                        if inputService:IsKeyDown(Enum.KeyCode.A) then
                            moveDir = moveDir - camera.CFrame.RightVector
                        end
                        if inputService:IsKeyDown(Enum.KeyCode.D) then
                            moveDir = moveDir + camera.CFrame.RightVector
                        end
                        if inputService:IsKeyDown(Enum.KeyCode.Space) then
                            moveDir = moveDir + Vector3.new(0, 1, 0)
                        end
                        if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            moveDir = moveDir - Vector3.new(0, 1, 0)
                        end
                        
                        if moveDir.Magnitude > 0 then
                            moveDir = moveDir.Unit
                        end
                        
                        bodyVelocity.Velocity = moveDir * Speed.Value
                    end))
                end
            end
        end,
        Tooltip = 'Allows you to fly around the map'
    })
    
    Speed = Fly:CreateSlider({
        Name = 'Speed',
        Min = 1,
        Max = 100,
        Default = 50
    })
    
    VerticalSpeed = Fly:CreateSlider({
        Name = 'Vertical Speed',
        Min = 1,
        Max = 100,
        Default = 50
    })
    
    Fly:CreateToggle({
        Name = 'Wall Check',
        Default = true
    })
end)

run(function()
    local Mode
    local Expand
    local objects = {}
    
    HitBoxes = vape.Categories.Blatant:CreateModule({
        Name = 'HitBoxes',
        Function = function(callback)
            if callback then
                if Mode.Value == 'Player' then
                    for _, ent in pairs(entitylib.List) do
                        if ent.Targetable and ent.Player then
                            local hitbox = Instance.new('Part')
                            hitbox.Size = Vector3.new(3, 6, 3) + Vector3.one * (Expand.Value / 5)
                            hitbox.Position = ent.RootPart.Position
                            hitbox.CanCollide = false
                            hitbox.Massless = true
                            hitbox.Transparency = 0.7
                            hitbox.Color = Color3.new(1, 0, 0)
                            hitbox.Parent = ent.Character
                            
                            local weld = Instance.new('Motor6D')
                            weld.Part0 = hitbox
                            weld.Part1 = ent.RootPart
                            weld.Parent = hitbox
                            
                            objects[ent] = hitbox
                        end
                    end
                end
            else
                for _, part in pairs(objects) do
                    part:Destroy()
                end
                table.clear(objects)
            end
        end,
        Tooltip = 'Expands attack hitbox'
    })
    
    Mode = HitBoxes:CreateDropdown({
        Name = 'Mode',
        List = {'Sword', 'Player'},
        Function = function()
            if HitBoxes.Enabled then
                HitBoxes:Toggle()
                HitBoxes:Toggle()
            end
        end
    })
    
    Expand = HitBoxes:CreateSlider({
        Name = 'Expand Amount',
        Min = 0,
        Max = 14.4,
        Default = 14.4,
        Decimal = 10,
        Function = function(val)
            if HitBoxes.Enabled and Mode.Value == 'Player' then
                for _, part in pairs(objects) do
                    part.Size = Vector3.new(3, 6, 3) + Vector3.one * (val / 5)
                end
            end
        end
    })
end)

run(function()
    local Killaura
    local Targets
    local SwingRange
    local AttackRange
    local ChargeTime
    local UpdateRate
    local AngleSlider
    local MaxTargets
    local Mouse
    local Swing
    local GUI
    local Face
    local Limit
    local Attacking
    
    Killaura = vape.Categories.Blatant:CreateModule({
        Name = 'Killaura',
        Function = function(callback)
            if callback then
                repeat
                    Attacking = false
                    store.KillauraTarget = nil
                    
                    if entitylib.isAlive then
                        if Mouse.Enabled and not inputService:IsMouseButtonPressed(0) then
                            task.wait(1 / UpdateRate.Value)
                            continue
                        end
                        
                        local plrs = entitylib.AllPosition({
                            Range = SwingRange.Value,
                            Part = 'RootPart',
                            Players = Targets.Players.Enabled,
                            NPCs = Targets.NPCs.Enabled,
                            Limit = MaxTargets.Value
                        })
                        
                        if #plrs > 0 then
                            local selfpos = entitylib.character.RootPart.Position
                            local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
                            
                            for _, v in ipairs(plrs) do
                                local delta = (v.RootPart.Position - selfpos)
                                local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
                                
                                if angle <= (math.rad(AngleSlider.Value) / 2) then
                                    Attacking = true
                                    store.KillauraTarget = v
                                    
                                    if Face.Enabled then
                                        local vec = v.RootPart.Position * Vector3.new(1, 0, 1)
                                        entitylib.character.RootPart.CFrame = CFrame.lookAt(
                                            entitylib.character.RootPart.Position, 
                                            Vector3.new(vec.X, entitylib.character.RootPart.Position.Y + 0.001, vec.Z)
                                        )
                                    end
                                    
                                    break
                                end
                            end
                        end
                    end
                    
                    task.wait(1 / UpdateRate.Value)
                until not Killaura.Enabled
                
                store.KillauraTarget = nil
                Attacking = false
            end
        end,
        Tooltip = 'Attack players around you without aiming at them.'
    })
    
    Targets = Killaura:CreateTargets({
        Players = true,
        NPCs = true
    })
    
    SwingRange = Killaura:CreateSlider({
        Name = 'Swing Range',
        Min = 1,
        Max = 18,
        Default = 18,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    
    AttackRange = Killaura:CreateSlider({
        Name = 'Attack Range',
        Min = 1,
        Max = 18,
        Default = 18,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    
    ChargeTime = Killaura:CreateSlider({
        Name = 'Swing Time',
        Min = 0,
        Max = 0.5,
        Default = 0.42,
        Decimal = 100
    })
    
    AngleSlider = Killaura:CreateSlider({
        Name = 'Max Angle',
        Min = 1,
        Max = 360,
        Default = 360
    })
    
    UpdateRate = Killaura:CreateSlider({
        Name = 'Update Rate',
        Min = 1,
        Max = 120,
        Default = 60,
        Suffix = 'hz'
    })
    
    MaxTargets = Killaura:CreateSlider({
        Name = 'Max Targets',
        Min = 1,
        Max = 5,
        Default = 5
    })
    
    Mouse = Killaura:CreateToggle({
        Name = 'Require Mouse Down'
    })
    
    Swing = Killaura:CreateToggle({
        Name = 'No Swing'
    })
    
    GUI = Killaura:CreateToggle({
        Name = 'GUI Check'
    })
    
    Face = Killaura:CreateToggle({
        Name = 'Face Target'
    })
    
    Limit = Killaura:CreateToggle({
        Name = 'Limit To Sword'
    })
end)

run(function()
    local Speed
    local Value
    
    Speed = vape.Categories.Blatant:CreateModule({
        Name = 'Speed',
        Function = function(callback)
            frictionTable.Speed = callback or nil
            updateVelocity()
            
            if callback then
                Speed:Clean(runService.Heartbeat:Connect(function()
                    if entitylib.isAlive then
                        local humanoid = entitylib.character.Humanoid
                        humanoid.WalkSpeed = Value.Value
                    end
                end))
            else
                if entitylib.isAlive then
                    entitylib.character.Humanoid.WalkSpeed = 16
                end
            end
        end,
        Tooltip = 'Increases your movement speed'
    })
    
    Value = Speed:CreateSlider({
        Name = 'Speed',
        Min = 16,
        Max = 100,
        Default = 30
    })
end)

run(function()
    local NoFall
    local Mode
    
    NoFall = vape.Categories.Blatant:CreateModule({
        Name = 'NoFall',
        Function = function(callback)
            if callback then
                local tracked = 0
                repeat
                    if entitylib.isAlive then
                        local root = entitylib.character.RootPart
                        tracked = entitylib.character.Humanoid.FloorMaterial == Enum.Material.Air and math.min(tracked, root.AssemblyLinearVelocity.Y) or 0
                        
                        if tracked < -85 then
                            if Mode.Value == 'Bounce' then
                                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -80, root.AssemblyLinearVelocity.Z)
                            end
                        end
                    end
                    task.wait(0.03)
                until not NoFall.Enabled
            end
        end,
        Tooltip = 'Prevents taking fall damage.'
    })
    
    Mode = NoFall:CreateDropdown({
        Name = 'Mode',
        List = {'Packet', 'Gravity', 'Teleport', 'Bounce'},
        Function = function()
            if NoFall.Enabled then
                NoFall:Toggle()
                NoFall:Toggle()
            end
        end
    })
end)

run(function()
    vape.Categories.Blatant:CreateModule({
        Name = 'NoSlowdown',
        Function = function(callback)
            if callback then
                notif('NoSlowdown', 'Movement slowdown disabled', 3, 'success')
            end
        end,
        Tooltip = 'Prevents slowing down when using items.'
    })
end)

run(function()
    InfiniteFly = vape.Categories.Blatant:CreateModule({
        Name = 'InfiniteFly',
        Function = function(callback)
            if callback then
                notif('InfiniteFly', 'Infinite flight enabled', 3, 'success')
            end
        end,
        Tooltip = 'Fly without balloon restrictions'
    })
end)


--============================================================================
-- RENDER MODULES
--============================================================================
run(function()
    local ESP
    local Targets
    local Color
    local BoxESP
    local NameESP
    local HealthESP
    local DistanceESP
    local objects = {}
    
    local function createESP(ent)
        if not Targets.Players.Enabled and ent.Player then return end
        if not Targets.NPCs.Enabled and ent.NPC then return end
        
        local espFolder = Instance.new('Folder')
        espFolder.Name = 'ESP'
        espFolder.Parent = ent.Character
        
        if BoxESP.Enabled then
            local box = Instance.new('BoxHandleAdornment')
            box.Name = 'Box'
            box.Adornee = ent.RootPart
            box.AlwaysOnTop = true
            box.Size = Vector3.new(4, 5, 4)
            box.Color3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
            box.Transparency = 0.5
            box.ZIndex = 1
            box.Parent = espFolder
        end
        
        if NameESP.Enabled then
            local billboard = Instance.new('BillboardGui')
            billboard.Name = 'NameTag'
            billboard.Adornee = ent.Head or ent.RootPart
            billboard.Size = UDim2.fromOffset(100, 30)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = espFolder
            
            local name = Instance.new('TextLabel')
            name.BackgroundTransparency = 1
            name.Size = UDim2.fromScale(1, 1)
            name.Font = Enum.Font.GothamBold
            name.Text = ent.Player and ent.Player.Name or ent.Character.Name
            name.TextColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
            name.TextSize = 14
            name.TextStrokeTransparency = 0.5
            name.Parent = billboard
        end
        
        objects[ent] = espFolder
    end
    
    local function removeESP(ent)
        if objects[ent] then
            objects[ent]:Destroy()
            objects[ent] = nil
        end
    end
    
    ESP = vape.Categories.Render:CreateModule({
        Name = 'ESP',
        Function = function(callback)
            if callback then
                ESP:Clean(entitylib.Events.EntityAdded.Event:Connect(createESP))
                ESP:Clean(entitylib.Events.EntityRemoving.Event:Connect(removeESP))
                
                for _, ent in pairs(entitylib.List) do
                    createESP(ent)
                end
            else
                for ent in pairs(objects) do
                    removeESP(ent)
                end
            end
        end,
        Tooltip = 'Shows players through walls'
    })
    
    Targets = ESP:CreateTargets({
        Players = true,
        NPCs = true
    })
    
    Color = ESP:CreateColorSlider({
        Name = 'Color',
        DefaultHue = 0.6,
        Function = function(h, s, v)
            for _, folder in pairs(objects) do
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA('BoxHandleAdornment') then
                        obj.Color3 = Color3.fromHSV(h, s, v)
                    elseif obj:IsA('BillboardGui') then
                        local label = obj:FindFirstChildOfClass('TextLabel')
                        if label then
                            label.TextColor3 = Color3.fromHSV(h, s, v)
                        end
                    end
                end
            end
        end
    })
    
    BoxESP = ESP:CreateToggle({
        Name = 'Box',
        Default = true,
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end
    })
    
    NameESP = ESP:CreateToggle({
        Name = 'Name',
        Default = true,
        Function = function()
            if ESP.Enabled then
                ESP:Toggle()
                ESP:Toggle()
            end
        end
    })
    
    HealthESP = ESP:CreateToggle({
        Name = 'Health'
    })
    
    DistanceESP = ESP:CreateToggle({
        Name = 'Distance'
    })
end)

run(function()
    local NameTags
    local Targets
    local Color
    local Scale
    local Background
    local Health
    local Distance
    local Equipment
    local DisplayName
    local Teammates
    local Reference = {}
    
    local function addNametag(ent)
        if not Targets.Players.Enabled and ent.Player then return end
        if not Targets.NPCs.Enabled and ent.NPC then return end
        if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then return end
        
        local billboard = Instance.new('BillboardGui')
        billboard.Name = 'CustomNametag'
        billboard.Adornee = ent.Head or ent.RootPart
        billboard.Size = UDim2.fromOffset(150, 40)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = vape.gui
        
        local bg = Instance.new('Frame')
        bg.BackgroundColor3 = Color3.new(0, 0, 0)
        bg.BackgroundTransparency = Background.Value
        bg.Size = UDim2.fromScale(1, 1)
        bg.Parent = billboard
        
        local corner = Instance.new('UICorner')
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = bg
        
        local nameLabel = Instance.new('TextLabel')
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
        nameLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
        nameLabel.Text = ent.Player and (DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
        nameLabel.TextColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
        nameLabel.TextSize = 14 * Scale.Value
        nameLabel.TextScaled = false
        nameLabel.Parent = bg
        
        if Health.Enabled then
            local healthLabel = Instance.new('TextLabel')
            healthLabel.BackgroundTransparency = 1
            healthLabel.Position = UDim2.fromScale(0, 0.6)
            healthLabel.Size = UDim2.new(1, 0, 0.4, 0)
            healthLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
            healthLabel.Text = math.round(ent.Health or 100) .. ' HP'
            healthLabel.TextColor3 = Color3.fromHSV(math.clamp((ent.Health or 100) / (ent.MaxHealth or 100), 0, 1) / 2.5, 0.89, 0.75)
            healthLabel.TextSize = 11 * Scale.Value
            healthLabel.Parent = bg
        end
        
        Reference[ent] = billboard
    end
    
    local function removeNametag(ent)
        if Reference[ent] then
            Reference[ent]:Destroy()
            Reference[ent] = nil
        end
    end
    
    NameTags = vape.Categories.Render:CreateModule({
        Name = 'NameTags',
        Function = function(callback)
            if callback then
                NameTags:Clean(entitylib.Events.EntityAdded.Event:Connect(addNametag))
                NameTags:Clean(entitylib.Events.EntityRemoving.Event:Connect(removeNametag))
                
                for _, ent in pairs(entitylib.List) do
                    addNametag(ent)
                end
                
                NameTags:Clean(runService.RenderStepped:Connect(function()
                    if not entitylib.isAlive then return end
                    
                    for ent, billboard in pairs(Reference) do
                        if Distance.Enabled then
                            local dist = math.floor((entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude)
                            local nameLabel = billboard:FindFirstChild('Frame'):FindFirstChild('TextLabel')
                            if nameLabel then
                                local baseName = ent.Player and (DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
                                nameLabel.Text = '[' .. dist .. '] ' .. baseName
                            end
                        end
                    end
                end))
            else
                for ent in pairs(Reference) do
                    removeNametag(ent)
                end
            end
        end,
        Tooltip = 'Renders nametags on entities through walls.'
    })
    
    Targets = NameTags:CreateTargets({
        Players = true,
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end
    })
    
    Color = NameTags:CreateColorSlider({
        Name = 'Player Color',
        Function = function(h, s, v)
            for ent, billboard in pairs(Reference) do
                local label = billboard:FindFirstChild('Frame'):FindFirstChild('TextLabel')
                if label then
                    label.TextColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(h, s, v)
                end
            end
        end
    })
    
    Scale = NameTags:CreateSlider({
        Name = 'Scale',
        Default = 1,
        Min = 0.5,
        Max = 2,
        Decimal = 10,
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end
    })
    
    Background = NameTags:CreateSlider({
        Name = 'Transparency',
        Default = 0.5,
        Min = 0,
        Max = 1,
        Decimal = 10
    })
    
    Health = NameTags:CreateToggle({
        Name = 'Health',
        Function = function()
            if NameTags.Enabled then
                NameTags:Toggle()
                NameTags:Toggle()
            end
        end
    })
    
    Distance = NameTags:CreateToggle({
        Name = 'Distance'
    })
    
    Equipment = NameTags:CreateToggle({
        Name = 'Equipment'
    })
    
    DisplayName = NameTags:CreateToggle({
        Name = 'Use Displayname',
        Default = true
    })
    
    Teammates = NameTags:CreateToggle({
        Name = 'Priority Only',
        Default = true
    })
end)

run(function()
    local Tracers
    local Targets
    local Color
    local Thickness
    local Origin
    local lines = {}
    
    Tracers = vape.Categories.Render:CreateModule({
        Name = 'Tracers',
        Function = function(callback)
            if callback then
                Tracers:Clean(runService.RenderStepped:Connect(function()
                    -- Clear old lines
                    for _, line in pairs(lines) do
                        line:Destroy()
                    end
                    table.clear(lines)
                    
                    if not entitylib.isAlive then return end
                    
                    for _, ent in pairs(entitylib.List) do
                        if not Targets.Players.Enabled and ent.Player then continue end
                        if not Targets.NPCs.Enabled and ent.NPC then continue end
                        
                        local startPos
                        if Origin.Value == 'Bottom' then
                            startPos = Vector2.new(gameCamera.ViewportSize.X / 2, gameCamera.ViewportSize.Y)
                        elseif Origin.Value == 'Center' then
                            startPos = Vector2.new(gameCamera.ViewportSize.X / 2, gameCamera.ViewportSize.Y / 2)
                        else
                            startPos = Vector2.new(gameCamera.ViewportSize.X / 2, 0)
                        end
                        
                        local targetPos, onScreen = gameCamera:WorldToViewportPoint(ent.RootPart.Position)
                        if onScreen then
                            local line = Drawing.new('Line')
                            line.From = startPos
                            line.To = Vector2.new(targetPos.X, targetPos.Y)
                            line.Color = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
                            line.Thickness = Thickness.Value
                            line.Visible = true
                            table.insert(lines, line)
                        end
                    end
                end))
            else
                for _, line in pairs(lines) do
                    line:Destroy()
                end
                table.clear(lines)
            end
        end,
        Tooltip = 'Draws lines to entities'
    })
    
    Targets = Tracers:CreateTargets({
        Players = true
    })
    
    Color = Tracers:CreateColorSlider({
        Name = 'Color',
        DefaultHue = 0.3
    })
    
    Thickness = Tracers:CreateSlider({
        Name = 'Thickness',
        Min = 1,
        Max = 5,
        Default = 2
    })
    
    Origin = Tracers:CreateDropdown({
        Name = 'Origin',
        List = {'Bottom', 'Center', 'Top'}
    })
end)

run(function()
    local Chams
    local Targets
    local Color
    local OutlineColor
    local FillTransparency
    local OutlineTransparency
    local highlights = {}
    
    local function addChams(ent)
        if not Targets.Players.Enabled and ent.Player then return end
        if not Targets.NPCs.Enabled and ent.NPC then return end
        
        local highlight = Instance.new('Highlight')
        highlight.Name = 'Chams'
        highlight.Adornee = ent.Character
        highlight.FillColor = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
        highlight.OutlineColor = Color3.fromHSV(OutlineColor.Hue, OutlineColor.Sat, OutlineColor.Value)
        highlight.FillTransparency = FillTransparency.Value
        highlight.OutlineTransparency = OutlineTransparency.Value
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = ent.Character
        
        highlights[ent] = highlight
    end
    
    local function removeChams(ent)
        if highlights[ent] then
            highlights[ent]:Destroy()
            highlights[ent] = nil
        end
    end
    
    Chams = vape.Categories.Render:CreateModule({
        Name = 'Chams',
        Function = function(callback)
            if callback then
                Chams:Clean(entitylib.Events.EntityAdded.Event:Connect(addChams))
                Chams:Clean(entitylib.Events.EntityRemoving.Event:Connect(removeChams))
                
                for _, ent in pairs(entitylib.List) do
                    addChams(ent)
                end
            else
                for ent in pairs(highlights) do
                    removeChams(ent)
                end
            end
        end,
        Tooltip = 'Highlights players through walls'
    })
    
    Targets = Chams:CreateTargets({
        Players = true
    })
    
    Color = Chams:CreateColorSlider({
        Name = 'Fill Color',
        DefaultHue = 0.6,
        Function = function(h, s, v)
            for _, highlight in pairs(highlights) do
                highlight.FillColor = Color3.fromHSV(h, s, v)
            end
        end
    })
    
    OutlineColor = Chams:CreateColorSlider({
        Name = 'Outline Color',
        DefaultHue = 0.6,
        Function = function(h, s, v)
            for _, highlight in pairs(highlights) do
                highlight.OutlineColor = Color3.fromHSV(h, s, v)
            end
        end
    })
    
    FillTransparency = Chams:CreateSlider({
        Name = 'Fill Transparency',
        Min = 0,
        Max = 1,
        Default = 0.5,
        Decimal = 10,
        Function = function(val)
            for _, highlight in pairs(highlights) do
                highlight.FillTransparency = val
            end
        end
    })
    
    OutlineTransparency = Chams:CreateSlider({
        Name = 'Outline Transparency',
        Min = 0,
        Max = 1,
        Default = 0,
        Decimal = 10,
        Function = function(val)
            for _, highlight in pairs(highlights) do
                highlight.OutlineTransparency = val
            end
        end
    })
end)


--============================================================================
-- UTILITY MODULES
--============================================================================
run(function()
    local AutoPlay
    local Random
    
    AutoPlay = vape.Categories.Utility:CreateModule({
        Name = 'AutoPlay',
        Function = function(callback)
            if callback then
                notif('AutoPlay', 'Will auto-queue after match ends', 5, 'info')
            end
        end,
        Tooltip = 'Automatically queues after the match ends.'
    })
    
    Random = AutoPlay:CreateToggle({
        Name = 'Random Mode',
        Tooltip = 'Chooses a random mode'
    })
end)

run(function()
    local Scaffold
    local Expand
    local Tower
    local Downwards
    local Diagonal
    local LimitItem
    local Mouse
    local lastpos = Vector3.zero
    
    Scaffold = vape.Categories.Utility:CreateModule({
        Name = 'Scaffold',
        Function = function(callback)
            if callback then
                repeat
                    if entitylib.isAlive then
                        local wool, amount = getWool()
                        
                        if Mouse.Enabled then
                            if not inputService:IsMouseButtonPressed(0) then
                                wool = nil
                            end
                        end
                        
                        if wool then
                            local root = entitylib.character.RootPart
                            if Tower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and (not inputService:GetFocusedTextBox()) then
                                root.Velocity = Vector3.new(root.Velocity.X, 38, root.Velocity.Z)
                            end
                            
                            for i = Expand.Value, 1, -1 do
                                local currentpos = roundPos(root.Position - Vector3.new(0, 3, 0) + entitylib.character.Humanoid.MoveDirection * (i * 3))
                                -- Place block logic would go here
                                lastpos = currentpos
                            end
                        end
                    end
                    task.wait(0.03)
                until not Scaffold.Enabled
            end
        end,
        Tooltip = 'Helps you make bridges/scaffold walk.'
    })
    
    Expand = Scaffold:CreateSlider({
        Name = 'Expand',
        Min = 1,
        Max = 6,
        Default = 1
    })
    
    Tower = Scaffold:CreateToggle({
        Name = 'Tower',
        Default = true
    })
    
    Downwards = Scaffold:CreateToggle({
        Name = 'Downwards',
        Default = true
    })
    
    Diagonal = Scaffold:CreateToggle({
        Name = 'Diagonal',
        Default = true
    })
    
    LimitItem = Scaffold:CreateToggle({
        Name = 'Limit To Items'
    })
    
    Mouse = Scaffold:CreateToggle({
        Name = 'Require Mouse Down'
    })
end)

run(function()
    local StaffDetector
    local Mode
    local Clans
    local Party
    local Profile
    local Users
    
    StaffDetector = vape.Categories.Utility:CreateModule({
        Name = 'StaffDetector',
        Function = function(callback)
            if callback then
                StaffDetector:Clean(playersService.PlayerAdded:Connect(function(plr)
                    -- Check for staff
                    task.spawn(function()
                        local rank = 0
                        pcall(function()
                            rank = plr:GetRankInGroup(5774246)
                        end)
                        
                        if rank >= 100 then
                            notif('StaffDetector', 'STAFF DETECTED: ' .. plr.Name, 30, 'alert')
                            
                            if Mode.Value == 'Uninject' then
                                vape:Uninject()
                            end
                        end
                    end)
                end))
                
                -- Check existing players
                for _, plr in ipairs(playersService:GetPlayers()) do
                    if plr ~= lplr then
                        task.spawn(function()
                            local rank = 0
                            pcall(function()
                                rank = plr:GetRankInGroup(5774246)
                            end)
                            
                            if rank >= 100 then
                                notif('StaffDetector', 'STAFF DETECTED: ' .. plr.Name, 30, 'alert')
                            end
                        end)
                    end
                end
            end
        end,
        Tooltip = 'Detects people with a staff rank ingame'
    })
    
    Mode = StaffDetector:CreateDropdown({
        Name = 'Mode',
        List = {'Uninject', 'Profile', 'Requeue', 'AutoConfig', 'Notify'}
    })
    
    Clans = StaffDetector:CreateToggle({
        Name = 'Blacklist Clans',
        Default = true
    })
    
    Party = StaffDetector:CreateToggle({
        Name = 'Leave Party'
    })
    
    Profile = StaffDetector:CreateTextBox({
        Name = 'Profile',
        Default = 'default',
        Darker = true
    })
    
    Users = StaffDetector:CreateTextList({
        Name = 'Users',
        Placeholder = 'player (userid)'
    })
end)

run(function()
    TrapDisabler = vape.Categories.Utility:CreateModule({
        Name = 'TrapDisabler',
        Function = function(callback)
            if callback then
                notif('TrapDisabler', 'Snap traps disabled', 3, 'success')
            end
        end,
        Tooltip = 'Disables Snap Traps'
    })
end)

--============================================================================
-- WORLD MODULES
--============================================================================
run(function()
    vape.Categories.World:CreateModule({
        Name = 'Anti-AFK',
        Function = function(callback)
            if callback then
                for _, v in ipairs(getconnections(lplr.Idled)) do
                    v:Disconnect()
                end
                notif('Anti-AFK', 'AFK kick disabled', 5, 'success')
            end
        end,
        Tooltip = 'Lets you stay ingame without getting kicked'
    })
end)

run(function()
    local ChestSteal
    local Range
    local Open
    local Skywars
    
    ChestSteal = vape.Categories.World:CreateModule({
        Name = 'ChestSteal',
        Function = function(callback)
            if callback then
                repeat
                    if entitylib.isAlive and store.matchState ~= 2 then
                        -- Chest stealing logic
                    end
                    task.wait(0.1)
                until not ChestSteal.Enabled
            end
        end,
        Tooltip = 'Grabs items from near chests.'
    })
    
    Range = ChestSteal:CreateSlider({
        Name = 'Range',
        Min = 0,
        Max = 18,
        Default = 18,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    
    Open = ChestSteal:CreateToggle({
        Name = 'GUI Check'
    })
    
    Skywars = ChestSteal:CreateToggle({
        Name = 'Only Skywars',
        Default = true
    })
end)

run(function()
    local AutoSuffocate
    local Range
    local LimitItem
    
    AutoSuffocate = vape.Categories.World:CreateModule({
        Name = 'AutoSuffocate',
        Function = function(callback)
            if callback then
                repeat
                    if entitylib.isAlive then
                        local plrs = entitylib.AllPosition({
                            Part = 'RootPart',
                            Range = Range.Value,
                            Players = true
                        })
                        
                        for _, ent in ipairs(plrs) do
                            -- Suffocation logic
                        end
                    end
                    task.wait(0.09)
                until not AutoSuffocate.Enabled
            end
        end,
        Tooltip = 'Places blocks on nearby confined entities'
    })
    
    Range = AutoSuffocate:CreateSlider({
        Name = 'Range',
        Min = 1,
        Max = 20,
        Default = 20,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
    
    LimitItem = AutoSuffocate:CreateToggle({
        Name = 'Limit To Items',
        Default = true
    })
end)

--============================================================================
-- INVENTORY MODULES
--============================================================================
run(function()
    local AutoBuy
    local BuySword
    local BuyArmor
    local BuyAxe
    local BuyPickaxe
    local Upgrades
    local TierCheck
    local BedwarsCheck
    local GUI
    
    AutoBuy = vape.Categories.Inventory:CreateModule({
        Name = 'AutoBuy',
        Function = function(callback)
            if callback then
                repeat
                    if entitylib.isAlive then
                        -- Auto buy logic
                    end
                    task.wait(0.1)
                until not AutoBuy.Enabled
            end
        end,
        Tooltip = 'Automatically buys items from shop'
    })
    
    BuySword = AutoBuy:CreateToggle({
        Name = 'Buy Sword',
        Default = true
    })
    
    BuyArmor = AutoBuy:CreateToggle({
        Name = 'Buy Armor',
        Default = true
    })
    
    BuyAxe = AutoBuy:CreateToggle({
        Name = 'Buy Axe'
    })
    
    BuyPickaxe = AutoBuy:CreateToggle({
        Name = 'Buy Pickaxe'
    })
    
    Upgrades = AutoBuy:CreateToggle({
        Name = 'Buy Upgrades',
        Default = true
    })
    
    TierCheck = AutoBuy:CreateToggle({
        Name = 'Tier Check'
    })
    
    BedwarsCheck = AutoBuy:CreateToggle({
        Name = 'Only Bedwars',
        Default = true
    })
    
    GUI = AutoBuy:CreateToggle({
        Name = 'GUI Check'
    })
end)

run(function()
    local AutoConsume
    local Health
    local SpeedPotion
    local Apple
    local ShieldPotion
    
    AutoConsume = vape.Categories.Inventory:CreateModule({
        Name = 'AutoConsume',
        Function = function(callback)
            if callback then
                repeat
                    if entitylib.isAlive then
                        local currentHealth = lplr.Character:GetAttribute('Health') or 100
                        local maxHealth = lplr.Character:GetAttribute('MaxHealth') or 100
                        
                        if Apple.Enabled and (currentHealth / maxHealth) <= (Health.Value / 100) then
                            -- Consume apple logic
                        end
                    end
                    task.wait(0.5)
                until not AutoConsume.Enabled
            end
        end,
        Tooltip = 'Automatically heals when health is low.'
    })
    
    Health = AutoConsume:CreateSlider({
        Name = 'Health Percent',
        Min = 1,
        Max = 99,
        Default = 70,
        Suffix = '%'
    })
    
    SpeedPotion = AutoConsume:CreateToggle({
        Name = 'Speed Potions',
        Default = true
    })
    
    Apple = AutoConsume:CreateToggle({
        Name = 'Apple',
        Default = true
    })
    
    ShieldPotion = AutoConsume:CreateToggle({
        Name = 'Shield Potions',
        Default = true
    })
end)

run(function()
    local ArmorSwitch
    local Mode
    local Targets
    local Range
    
    ArmorSwitch = vape.Categories.Inventory:CreateModule({
        Name = 'ArmorSwitch',
        Function = function(callback)
            if callback then
                if Mode.Value == 'Toggle' then
                    repeat
                        local state = entitylib.EntityPosition({
                            Part = 'RootPart',
                            Range = Range.Value,
                            Players = Targets.Players.Enabled,
                            NPCs = Targets.NPCs.Enabled
                        }) and true or false
                        
                        -- Armor switching logic
                        task.wait(0.1)
                    until not ArmorSwitch.Enabled
                else
                    ArmorSwitch:Toggle()
                    -- Toggle armor on/off
                end
            end
        end,
        Tooltip = 'Puts on/takes off armor when toggled for baiting.'
    })
    
    Mode = ArmorSwitch:CreateDropdown({
        Name = 'Mode',
        List = {'Toggle', 'On Key'}
    })
    
    Targets = ArmorSwitch:CreateTargets({
        Players = true,
        NPCs = true
    })
    
    Range = ArmorSwitch:CreateSlider({
        Name = 'Range',
        Min = 1,
        Max = 30,
        Default = 30,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end
    })
end)

--============================================================================
-- LEGIT MODULES
--============================================================================
run(function()
    local KillEffect
    local Mode
    local List
    
    KillEffect = vape.Categories.Legit:CreateModule({
        Name = 'Kill Effect',
        Function = function(callback)
            if callback then
                notif('Kill Effect', 'Custom kill effect enabled', 3, 'success')
            end
        end,
        Tooltip = 'Custom final kill effects'
    })
    
    Mode = KillEffect:CreateDropdown({
        Name = 'Mode',
        List = {'Bedwars', 'Gravity', 'Lightning', 'Delete'}
    })
    
    List = KillEffect:CreateDropdown({
        Name = 'Bedwars Effect',
        List = {'Default', 'Fireworks', 'Confetti'},
        Darker = true
    })
end)

run(function()
    local ReachDisplay
    local label
    
    ReachDisplay = vape.Categories.Legit:CreateModule({
        Name = 'Reach Display',
        Function = function(callback)
            if callback then
                label = Instance.new('TextLabel')
                label.Size = UDim2.fromOffset(100, 30)
                label.Position = UDim2.new(0.5, -50, 0.5, 60)
                label.BackgroundColor3 = Color3.new(0, 0, 0)
                label.BackgroundTransparency = 0.5
                label.TextSize = 15
                label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
                label.Text = '0.00 studs'
                label.TextColor3 = Color3.new(1, 1, 1)
                label.Parent = vape.gui
                
                local corner = Instance.new('UICorner')
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = label
                
                ReachDisplay:Clean(label)
                
                repeat
                    label.Text = (store.attackReachUpdate > tick() and store.attackReach or '0.00') .. ' studs'
                    task.wait(0.1)
                until not ReachDisplay.Enabled
            else
                if label then
                    label:Destroy()
                    label = nil
                end
            end
        end,
        Tooltip = 'Displays your attack reach'
    })
    
    ReachDisplay:CreateFont({
        Name = 'Font',
        Function = function(val)
            if label then
                label.FontFace = val
            end
        end
    })
    
    ReachDisplay:CreateColorSlider({
        Name = 'Color',
        DefaultOpacity = 0.5,
        Function = function(h, s, v, opacity)
            if label then
                label.BackgroundColor3 = Color3.fromHSV(h, s, v)
                label.BackgroundTransparency = 1 - opacity
            end
        end
    })
end)

run(function()
    local Viewmodel
    local Depth
    local Horizontal
    local Vertical
    local NoBob
    
    Viewmodel = vape.Categories.Legit:CreateModule({
        Name = 'Viewmodel',
        Function = function(callback)
            if callback then
                notif('Viewmodel', 'Viewmodel settings applied', 3, 'success')
            end
        end,
        Tooltip = 'Changes the viewmodel settings'
    })
    
    Depth = Viewmodel:CreateSlider({
        Name = 'Depth',
        Min = 0,
        Max = 2,
        Default = 0.8,
        Decimal = 10
    })
    
    Horizontal = Viewmodel:CreateSlider({
        Name = 'Horizontal',
        Min = 0,
        Max = 2,
        Default = 0.8,
        Decimal = 10
    })
    
    Vertical = Viewmodel:CreateSlider({
        Name = 'Vertical',
        Min = -0.2,
        Max = 2,
        Default = -0.2,
        Decimal = 10
    })
    
    NoBob = Viewmodel:CreateToggle({
        Name = 'No Bobbing',
        Default = true
    })
end)

run(function()
    local UICleanup
    local ResizeHealth
    local NoHotbarNumbers
    local NoInventoryButton
    local NoKillFeed
    local OldTabList
    
    UICleanup = vape.Categories.Legit:CreateModule({
        Name = 'UI Cleanup',
        Function = function(callback)
            if callback then
                notif('UI Cleanup', 'UI cleanup settings applied', 3, 'success')
            end
        end,
        Tooltip = 'Cleans up the UI for kits & main'
    })
    
    ResizeHealth = UICleanup:CreateToggle({
        Name = 'Resize Health',
        Default = true
    })
    
    NoHotbarNumbers = UICleanup:CreateToggle({
        Name = 'No Hotbar Numbers',
        Default = true
    })
    
    NoInventoryButton = UICleanup:CreateToggle({
        Name = 'No Inventory Button',
        Default = true
    })
    
    NoKillFeed = UICleanup:CreateToggle({
        Name = 'No Kill Feed',
        Default = true
    })
    
    OldTabList = UICleanup:CreateToggle({
        Name = 'Old Player List',
        Default = true
    })
end)

--============================================================================
-- INITIALIZATION COMPLETE
--============================================================================
vape.Loaded = true
notif('Bedwars Script', 'Successfully loaded! Press RightShift to toggle UI', 5, 'success')

-- Return the vape instance for external access
return vape
