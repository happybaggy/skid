--ui librbay

-- baggyware UI Library
-- Matches the original visual style exactly
-- Usage: local Lib = loadstring(game:HttpGet("url"))()

local Library = {}
Library.__index = Library

-- ============================================================
-- SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local GuiService       = game:GetService("GuiService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
-- THEME  (mirrors the original gradient colours)
-- ============================================================
Library.Theme = {
    Color1   = Color3.fromRGB(34, 85,  114),   -- left  / header
    Color2   = Color3.fromRGB(34, 103,  89),   -- right / accent
    BG       = Color3.fromRGB(0,   0,    0),   -- panel background
    Text     = Color3.fromRGB(255, 255, 255),
    TextDim  = Color3.fromRGB(176, 176, 176),
    Title    = Color3.fromRGB(255, 255, 255),
    Stroke   = Color3.fromRGB(34,  103,  89),
    Font     = Font.new(
        "rbxasset://fonts/families/TitilliumWeb.json",
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    ),
    FontBold = Font.new(
        "rbxasset://fonts/families/TitilliumWeb.json",
        Enum.FontWeight.Bold,
        Enum.FontStyle.Normal
    ),
}

-- ============================================================
-- INTERNAL HELPERS
-- ============================================================

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        pcall(function() inst[k] = v end)
    end
    if parent then inst.Parent = parent end
    return inst
end

local function stroke(parent, thickness, color, mode)
    return new("UIStroke", {
        Thickness       = thickness or 1.3,
        Color           = color or Library.Theme.Stroke,
        ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border,
        LineJoinMode    = Enum.LineJoinMode.Miter,
    }, parent)
end

local function gradient(parent, c1, c2)
    c1 = c1 or Library.Theme.Color1
    c2 = c2 or Library.Theme.Color2
    return new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, c1),
            ColorSequenceKeypoint.new(0.330, c1),
            ColorSequenceKeypoint.new(0.663, c2),
            ColorSequenceKeypoint.new(1.000, c2),
        }),
    }, parent)
end

-- Create a small square toggle button (matches the original "button" frame style)
local function makeToggleBtn(parent)
    local btn = new("Frame", {
        BorderSizePixel    = 0,
        BackgroundColor3   = Color3.fromRGB(0, 0, 0),
        Size               = UDim2.new(0, 10, 0, 10),
        Position           = UDim2.new(0.89146, 0, 0.22, 0),
        BackgroundTransparency = 0.85,
        Name               = "button",
    }, parent)
    stroke(btn, 1.3, Library.Theme.Stroke)
    return btn
end

-- Create a left-aligned text label (the row label style)
local function makeLabel(parent, text, size)
    return new("TextLabel", {
        TextStrokeTransparency = 0,
        BorderSizePixel        = 0,
        TextSize               = size or 18,
        TextXAlignment         = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BackgroundColor3       = Color3.fromRGB(255, 255, 255),
        FontFace               = Library.Theme.Font,
        TextColor3             = Library.Theme.Text,
        Size                   = UDim2.new(0, 125, 0, 20),
        BorderColor3           = Color3.fromRGB(0, 0, 0),
        Text                   = text,
        Name                   = "text",
        Position               = UDim2.new(0, 5, 0, 0),
    }, parent)
end

-- A blank row frame (20px tall, transparent, full-width of section)
local function makeRow(parent, name)
    return new("Frame", {
        BorderSizePixel        = 0,
        BackgroundColor3       = Color3.fromRGB(255, 255, 255),
        Size                   = UDim2.new(0, 145, 0, 20),
        BorderColor3           = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Name                   = name or "row",
    }, parent)
end

-- ============================================================
-- WINDOW
-- ============================================================
--[[
    Library:CreateWindow(title, options?)
    options = {
        Size      = UDim2  (default 450×350)
        Position  = UDim2
        MenuKey   = Enum.KeyCode  (default RightControl)
    }
]]
function Library:CreateWindow(title, options)
    options = options or {}

    local guiParent = (syn and syn.protect_gui and game:GetService("CoreGui"))
                   or game:GetService("CoreGui")

    local screenGui = new("ScreenGui", {
        Name            = "BaggywareLib",
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn    = false,
        Enabled         = true,
    }, guiParent)

    -- watermark
    local watermarkFrame = new("Frame", {
        ZIndex           = 99999,
        BorderSizePixel  = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size             = UDim2.new(0, 174, 0, 26),
        Position         = UDim2.new(0, 5, 0, 2),
        Name             = "watermark",
    }, screenGui)
    gradient(watermarkFrame)

    local watermarkLabel = new("TextLabel", {
        TextStrokeTransparency = 0,
        BorderSizePixel        = 0,
        AutoLocalize           = false,
        TextSize               = 16,
        BackgroundColor3       = Color3.fromRGB(0, 0, 0),
        FontFace               = Library.Theme.Font,
        TextColor3             = Library.Theme.Title,
        BackgroundTransparency = 0.85,
        RichText               = true,
        Size                   = UDim2.new(0, 168, 0, 20),
        Text                   = "priv9.net alpha",
        Name                   = "mark",
        Position               = UDim2.new(0.011, 0, 0.08, 0),
    }, watermarkFrame)

    -- fps loop
    local fpsCount, fpsTimer = 0, tick()
    RunService.Heartbeat:Connect(function()
        fpsCount += 1
        local now = tick()
        if now - fpsTimer >= 1 then
            local fps = math.floor(fpsCount / (now - fpsTimer))
            fpsCount, fpsTimer = 0, now
            local lb = watermarkLabel
            if lb and lb.Parent then
                lb.Text = string.format(" priv9.net alpha | fps: %d  ", fps)
                -- resize watermark to fit text
                local bounds = lb.TextBounds
                lb.Size = UDim2.new(0, bounds.X, 0, bounds.Y)
                lb.Position = UDim2.new(0, 3, 0, 3)
                watermarkFrame.Size = UDim2.new(0, bounds.X + 6, 0, bounds.Y + 6)
            end
        end
    end)

    -- main frame
    local mainFrame = new("Frame", {
        BorderSizePixel  = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size             = options.Size or UDim2.new(0, 450, 0, 350),
        Position         = options.Position or UDim2.new(0.155, -39, 0.138, -15),
        Name             = "main",
        ZIndex           = 100000,
    }, screenGui)
    gradient(mainFrame)

    -- title bar
    new("TextLabel", {
        TextWrapped            = true,
        TextStrokeTransparency = 0,
        BorderSizePixel        = 0,
        TextSize               = 20,
        TextScaled             = true,
        BackgroundColor3       = Color3.fromRGB(0, 0, 0),
        FontFace               = Library.Theme.FontBold,
        TextColor3             = Library.Theme.Title,
        BackgroundTransparency = 0.85,
        Size                   = UDim2.new(0, 442, 0, 21),
        Text                   = title or "baggyware",
        Name                   = "title",
        Position               = UDim2.new(0.00889, 0, 0.00857, 0),
    }, mainFrame)

    -- tab button bar
    local buttonBar = new("Frame", {
        BorderSizePixel        = 0,
        BackgroundColor3       = Color3.fromRGB(0, 0, 0),
        Size                   = UDim2.new(0, 442, 0, 20),
        Position               = UDim2.new(0.00889, 0, 0.929, 0),
        Name                   = "buttons",
        BackgroundTransparency = 0.85,
    }, mainFrame)

    -- content folder
    local windowsFolder = new("Folder", { Name = "windows" }, mainFrame)

    -- dragging
    local dragging, dragStart, dragPos = false, nil, nil
    local targetPos = mainFrame.Position

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = input.Position
            local fp  = mainFrame.AbsolutePosition
            if pos.Y <= fp.Y + 25 then
                dragging  = true
                dragStart = pos
                dragPos   = mainFrame.Position
            end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local vp    = workspace.CurrentCamera.ViewportSize
            targetPos   = UDim2.new(
                dragPos.X.Scale + delta.X / vp.X, dragPos.X.Offset,
                dragPos.Y.Scale + delta.Y / vp.Y, dragPos.Y.Offset
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function(dt)
        local cur = mainFrame.Position
        mainFrame.Position = UDim2.new(
            cur.X.Scale + (targetPos.X.Scale - cur.X.Scale) * math.min(dt * 8, 1), cur.X.Offset,
            cur.Y.Scale + (targetPos.Y.Scale - cur.Y.Scale) * math.min(dt * 8, 1), cur.Y.Offset
        )
    end)

    -- menu toggle key
    local menuOpen   = true
    local menuKeyCode = options.MenuKey or Enum.KeyCode.RightControl
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == menuKeyCode then
            menuOpen       = not menuOpen
            mainFrame.Visible = menuOpen
        end
    end)

    -- --------------------------------------------------------
    -- Window object returned to the caller
    -- --------------------------------------------------------
    local Window = {
        _screen      = screenGui,
        _main        = mainFrame,
        _buttonBar   = buttonBar,
        _windows     = windowsFolder,
        _tabs        = {},
        _activeTab   = nil,
        _tabCount    = 0,
    }

    -- --------------------------------------------------------
    -- Window:CreateTab(name)
    -- --------------------------------------------------------
    function Window:CreateTab(name)
        self._tabCount += 1
        local tabIndex = self._tabCount

        -- How wide each tab button is
        local tabW = math.floor(442 / math.max(self._tabCount, 1))

        -- Tab content frame (full 450×350, transparent)
        local tabFrame = new("Frame", {
            BorderSizePixel        = 0,
            BackgroundColor3       = Color3.fromRGB(255, 255, 255),
            Size                   = UDim2.new(0, 450, 0, 350),
            BackgroundTransparency = 1,
            Visible                = false,
            Name                   = name .. "frame",
        }, self._windows)

        -- Tab button
        local tabBtn = new("TextButton", {
            TextWrapped            = true,
            TextStrokeTransparency = 0,
            BorderSizePixel        = 0,
            TextSize               = 14,
            TextScaled             = true,
            TextColor3             = Library.Theme.TextDim,
            BackgroundColor3       = Color3.fromRGB(255, 255, 255),
            FontFace               = Library.Theme.Font,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(0, tabW, 0, 20),
            Position               = UDim2.new(0, (tabIndex - 1) * tabW, 0, 0),
            Text                   = name,
            Name                   = name,
        }, self._buttonBar)

        -- Reposition all existing tab buttons so they share the bar evenly
        local function repositionTabButtons()
            local w = math.floor(442 / #self._tabs)
            for i, tab in ipairs(self._tabs) do
                tab._btn.Size     = UDim2.new(0, w, 0, 20)
                tab._btn.Position = UDim2.new(0, (i - 1) * w, 0, 0)
            end
        end

        -- section list used internally to layout panels
        local Tab = {
            _frame    = tabFrame,
            _btn      = tabBtn,
            _sections = {},          -- list of section frames added
            _colX     = { 0.00889, 0.34, 0.67111 }, -- left / mid / right X scale
            _colIdx   = 0,           -- next column to fill (cycles 0,1,2)
            _colUsedY = { 0, 0, 0 }, -- pixels used in each column so far (below header)
            _HEADER_Y = 0.08,        -- top of sections (scale)
            _GUTTER   = 4,           -- px gap between sections
        }

        table.insert(self._tabs, Tab)
        repositionTabButtons()

        -- switch to this tab
        local function activate()
            for _, t in ipairs(self._tabs) do
                t._frame.Visible = false
                t._btn.TextColor3 = Library.Theme.TextDim
            end
            tabFrame.Visible  = true
            tabBtn.TextColor3 = Library.Theme.Text
            self._activeTab   = Tab
        end

        tabBtn.MouseButton1Click:Connect(activate)

        -- auto-show first tab
        if tabIndex == 1 then activate() end

        -- --------------------------------------------------------
        -- Section layout helper
        -- --------------------------------------------------------
        -- We have 3 columns. Each section is ~145 px wide.
        -- Sections stack top-to-bottom within a column automatically.
        -- The caller does NOT need to care about positions.

        local SECTION_W   = 143   -- px, matches original
        local SECTION_TOP = 28    -- px from top of tabFrame reserved for title bar area

        local function nextColumnSlot(heightPx)
            Tab._colIdx = (Tab._colIdx % 3) + 1
            local best  = Tab._colIdx
            local bestPx = Tab._colUsedY[best] or 0

            local xScale = Tab._colX[best]
            local yPx    = SECTION_TOP + bestPx + (bestPx > 0 and Tab._GUTTER or 0)
            Tab._colUsedY[best] = bestPx + heightPx + (bestPx > 0 and Tab._GUTTER or 0)
            return xScale, yPx
        end

        -- --------------------------------------------------------
        -- Tab:CreateSection(name, heightPx?)
        -- Returns a Section object with component-builder methods.
        -- heightPx defaults to 142 (matches original panel size).
        -- --------------------------------------------------------
        function Tab:CreateSection(sectionName, heightPx)
            heightPx = heightPx or 142

            local xScale, yPx = nextColumnSlot(heightPx)

            local sectionFrame = new("Frame", {
                BorderSizePixel        = 0,
                BackgroundColor3       = Color3.fromRGB(0, 0, 0),
                Size                   = UDim2.new(0, SECTION_W, 0, heightPx),
                Position               = UDim2.new(xScale, 0, 0, yPx),
                Name                   = sectionName,
                BackgroundTransparency = 0.65,
            }, tabFrame)

            -- header label (coloured)
            new("TextLabel", {
                TextStrokeTransparency = 0,
                BorderSizePixel        = 0,
                TextSize               = 20,
                TextXAlignment         = Enum.TextXAlignment.Left,
                SelectionOrder         = 1,
                BackgroundColor3       = Library.Theme.Color1,
                FontFace               = Library.Theme.Font,
                TextColor3             = Library.Theme.Text,
                Size                   = UDim2.new(0, 145, 0, 20),
                Text                   = "  " .. sectionName,
                LayoutOrder            = -1,
                Name                   = "label",
            }, sectionFrame)

            -- auto-layout for rows below the header
            local listLayout = new("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, sectionFrame)

            -- ---- Section object --------------------------------
            local Section = {
                _frame      = sectionFrame,
                _rowCount   = 0,
            }

            -- internal: each component call adds rows in layout order
            local function nextOrder()
                Section._rowCount += 1
                return Section._rowCount
            end

            -- ------------------------------------------------
            -- Section:Toggle(label, callback, default?)
            -- ------------------------------------------------
            function Section:Toggle(labelText, callback, default)
                local row = makeRow(sectionFrame, labelText)
                row.LayoutOrder = nextOrder()

                makeLabel(row, labelText)

                local btn   = makeToggleBtn(row)
                local state = default or false

                local function setVisual(s)
                    local col = Library.Theme.Stroke
                    btn.BackgroundColor3       = s and col or Color3.fromRGB(0, 0, 0)
                    btn.BackgroundTransparency = s and 0   or 0.85
                end

                btn.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    state = not state
                    setVisual(state)
                    if callback then pcall(callback, state) end
                end)

                setVisual(state)

                -- return a handle so the caller can read/set state
                local handle = {}
                function handle:Set(v)
                    state = v
                    setVisual(v)
                    if callback then pcall(callback, v) end
                end
                function handle:Get() return state end
                return handle
            end

            -- ------------------------------------------------
            -- Section:Slider(label, min, max, default, callback)
            -- Takes up 40px (two rows)
            -- ------------------------------------------------
            function Section:Slider(labelText, minVal, maxVal, default, callback)
                -- container is 40px tall
                local container = new("Frame", {
                    BorderSizePixel        = 0,
                    BackgroundColor3       = Color3.fromRGB(255, 255, 255),
                    Size                   = UDim2.new(0, 145, 0, 40),
                    BackgroundTransparency = 1,
                    Name                   = labelText,
                    LayoutOrder            = nextOrder(),
                }, sectionFrame)

                local textLabel = makeLabel(container, labelText .. " - ")

                -- number box
                local numBox = new("TextBox", {
                    TextStrokeTransparency = 0,
                    Name                   = "number",
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    PlaceholderColor3      = Color3.fromRGB(176, 176, 176),
                    BorderSizePixel        = 0,
                    TextWrapped            = true,
                    TextSize               = 18,
                    TextColor3             = Color3.fromRGB(201, 201, 201),
                    BackgroundColor3       = Color3.fromRGB(255, 255, 255),
                    FontFace               = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                    ClearTextOnFocus       = false,
                    Size                   = UDim2.new(0, 61, 0, 20),
                    Position               = UDim2.new(0.52, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = tostring(default or minVal),
                }, container)

                -- track
                local track = new("Frame", {
                    BorderSizePixel        = 0,
                    BackgroundColor3       = Color3.fromRGB(0, 0, 0),
                    Size                   = UDim2.new(0, 133, 0, 12),
                    Position               = UDim2.new(0.04138, 0, 0.545, 0),
                    Name                   = "slider",
                    BackgroundTransparency = 0.85,
                }, container)
                stroke(track, 1.3, Library.Theme.Stroke)

                -- fill bar
                local fill = new("Frame", {
                    BorderSizePixel        = 0,
                    BackgroundColor3       = Library.Theme.Stroke,
                    Size                   = UDim2.new(0, 0, 1, 0),
                    Name                   = "fill",
                }, track)

                local value   = math.clamp(default or minVal, minVal, maxVal)
                local dragging = false

                local function setValue(v)
                    value = math.clamp(math.floor(v + 0.5), minVal, maxVal)
                    numBox.Text = tostring(value)
                    local ratio = (value - minVal) / math.max(maxVal - minVal, 1)
                    fill.Size   = UDim2.new(ratio, 0, 1, 0)
                    textLabel.Text = labelText .. " - "
                    if callback then pcall(callback, value) end
                end

                track.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                end)
                track.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local ratio = math.clamp(
                            (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        setValue(minVal + (maxVal - minVal) * ratio)
                    end
                end)
                numBox.FocusLost:Connect(function()
                    local v = tonumber(numBox.Text)
                    if v then setValue(v) else numBox.Text = tostring(value) end
                end)

                setValue(value)

                local handle = {}
                function handle:Set(v) setValue(v) end
                function handle:Get() return value end
                return handle
            end

            -- ------------------------------------------------
            -- Section:Dropdown(label, options, default, callback)
            -- ------------------------------------------------
            function Section:Dropdown(labelText, optionsList, default, callback)
                local row = makeRow(sectionFrame, labelText)
                row.LayoutOrder = nextOrder()

                makeLabel(row, labelText)

                local valLabel = new("TextLabel", {
                    TextStrokeTransparency = 0,
                    BorderSizePixel        = 0,
                    TextSize               = 18,
                    BackgroundColor3       = Color3.fromRGB(0, 0, 0),
                    FontFace               = Library.Theme.Font,
                    TextColor3             = Library.Theme.Text,
                    BackgroundTransparency = 0.65,
                    Size                   = UDim2.new(0, 50, 0, 10),
                    Position               = UDim2.new(0.62522, 0, 0.22, 0),
                    Name                   = "val",
                    Text                   = default or (optionsList[1] or ""),
                }, row)
                stroke(valLabel, 1.4, Library.Theme.Stroke)

                -- dropdown panel
                local dropFrame = new("Frame", {
                    Name                   = "BaggyDropdown",
                    ZIndex                 = 100001,
                    BorderSizePixel        = 0,
                    BackgroundColor3       = Color3.fromRGB(30, 30, 30),
                    Visible                = false,
                    Size                   = UDim2.new(0, 120, 0, #optionsList * 20),
                }, screenGui)
                stroke(dropFrame, 1, Library.Theme.Stroke)
                new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, dropFrame)

                local current = default or optionsList[1]

                for i, opt in ipairs(optionsList) do
                    local btn = new("TextButton", {
                        Size                   = UDim2.new(1, 0, 0, 20),
                        BackgroundColor3       = Color3.fromRGB(30, 30, 30),
                        BorderSizePixel        = 0,
                        Text                   = opt,
                        TextColor3             = Color3.fromRGB(200, 200, 200),
                        TextSize               = 14,
                        Font                   = Enum.Font.TitilliumWeb,
                        ZIndex                 = 201,
                        LayoutOrder            = i,
                    }, dropFrame)
                    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
                    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end)
                    btn.MouseButton1Click:Connect(function()
                        current         = opt
                        valLabel.Text   = opt
                        dropFrame.Visible = false
                        if callback then pcall(callback, opt) end
                    end)
                end

                local function updateDropPos()
                    local pos  = valLabel.AbsolutePosition
                    local size = valLabel.AbsoluteSize
                    local vp   = workspace.CurrentCamera.ViewportSize
                    local h    = #optionsList * 20
                    local y    = pos.Y + size.Y + 2
                    if y + h > vp.Y then y = pos.Y - h - 2 end
                    local x    = pos.X
                    if x + 120 > vp.X then x = vp.X - 122 end
                    dropFrame.Position = UDim2.fromOffset(x, y)
                end

                valLabel.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dropFrame.Visible = not dropFrame.Visible
                        if dropFrame.Visible then updateDropPos() end
                    end
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and dropFrame.Visible then
                        local mp  = input.Position
                        local dp  = dropFrame.AbsolutePosition
                        local ds  = dropFrame.AbsoluteSize
                        local ap  = valLabel.AbsolutePosition
                        local as  = valLabel.AbsoluteSize
                        local inDrop = mp.X >= dp.X and mp.X <= dp.X + ds.X and mp.Y >= dp.Y and mp.Y <= dp.Y + ds.Y
                        local inAnchor = mp.X >= ap.X and mp.X <= ap.X + as.X and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y
                        if not inDrop and not inAnchor then dropFrame.Visible = false end
                    end
                end)

                local handle = {}
                function handle:Set(v)
                    current       = v
                    valLabel.Text = v
                    if callback then pcall(callback, v) end
                end
                function handle:Get() return current end
                return handle
            end

            -- ------------------------------------------------
            -- Section:Keybind(label, default, callback)
            -- callback(keyString) called when binding changes
            -- ------------------------------------------------
            function Section:Keybind(labelText, default, callback)
                local row = makeRow(sectionFrame, labelText)
                row.LayoutOrder = nextOrder()

                makeLabel(row, labelText)

                local keyLabel = new("TextLabel", {
                    TextStrokeTransparency = 0,
                    BorderSizePixel        = 0,
                    TextSize               = 18,
                    BackgroundColor3       = Color3.fromRGB(0, 0, 0),
                    FontFace               = Library.Theme.Font,
                    TextColor3             = Library.Theme.Text,
                    BackgroundTransparency = 0.65,
                    Size                   = UDim2.new(0, 30, 0, 10),
                    Position               = UDim2.new(0.62522, 0, 0.22, 0),
                    Name                   = "hotkey",
                    Text                   = default or "nil",
                }, row)
                stroke(keyLabel, 1.4, Library.Theme.Stroke)

                local bound    = default
                local binding  = false

                local function inputToStr(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton2 then return "mouse 2"
                    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then return "mouse 3"
                    elseif input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode.Name:lower()
                    end
                    return nil
                end

                keyLabel.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    binding         = true
                    keyLabel.Text   = "..."
                    keyLabel.BackgroundColor3 = Library.Theme.Color1
                    keyLabel.BackgroundTransparency = 0
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if not binding then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then return end
                    if input.KeyCode == Enum.KeyCode.Backspace then
                        bound           = nil
                        keyLabel.Text   = "nil"
                        keyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        keyLabel.BackgroundTransparency = 0.65
                        binding         = false
                        if callback then pcall(callback, nil) end
                        return
                    end
                    local s = inputToStr(input)
                    if not s then return end
                    bound           = s
                    keyLabel.Text   = s
                    keyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    keyLabel.BackgroundTransparency = 0.65
                    binding         = false
                    if callback then pcall(callback, s) end
                end)

                local handle = {}
                function handle:GetBound() return bound end
                function handle:IsBound(input)
                    if not bound then return false end
                    local s = inputToStr(input)
                    return s == bound
                end
                return handle
            end

            -- ------------------------------------------------
            -- Section:Button(label, callback)
            -- ------------------------------------------------
            function Section:Button(labelText, callback)
                local row = makeRow(sectionFrame, labelText)
                row.LayoutOrder = nextOrder()

                local btn = new("TextLabel", {
                    TextStrokeTransparency = 0,
                    BorderSizePixel        = 0,
                    TextSize               = 18,
                    BackgroundColor3       = Color3.fromRGB(0, 0, 0),
                    FontFace               = Library.Theme.Font,
                    TextColor3             = Library.Theme.Text,
                    BackgroundTransparency = 0.65,
                    Size                   = UDim2.new(0, 133, 0, 15),
                    Position               = UDim2.new(0.03448, 0, 0.22, 0),
                    Name                   = "button",
                    Text                   = labelText,
                }, row)
                stroke(btn, 1.4, Library.Theme.Stroke)

                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if callback then pcall(callback) end
                    end
                end)
            end

            -- ------------------------------------------------
            -- Section:Label(text)  — static info text
            -- ------------------------------------------------
            function Section:Label(text)
                local row = makeRow(sectionFrame, text)
                row.LayoutOrder = nextOrder()
                makeLabel(row, text)
            end

            -- ------------------------------------------------
            -- Section:TextInput(label, placeholder, callback)
            -- ------------------------------------------------
            function Section:TextInput(labelText, placeholder, callback)
                local row = makeRow(sectionFrame, labelText)
                row.LayoutOrder = nextOrder()

                makeLabel(row, labelText)

                local box = new("TextBox", {
                    TextStrokeTransparency = 0,
                    BorderSizePixel        = 0,
                    TextSize               = 18,
                    BackgroundColor3       = Color3.fromRGB(0, 0, 0),
                    FontFace               = Library.Theme.Font,
                    TextColor3             = Library.Theme.Text,
                    BackgroundTransparency = 0.65,
                    Size                   = UDim2.new(0, 48, 0, 10),
                    Position               = UDim2.new(0.62522, 0, 0.22, 0),
                    Text                   = "",
                    Name                   = "input",
                    ClearTextOnFocus       = false,
                    PlaceholderText        = placeholder or "",
                    PlaceholderColor3      = Color3.fromRGB(180, 180, 180),
                }, row)
                stroke(box, 1.4, Library.Theme.Stroke)

                box.FocusLost:Connect(function()
                    if callback then pcall(callback, box.Text) end
                end)

                local handle = {}
                function handle:Get() return box.Text end
                function handle:Set(v) box.Text = v end
                return handle
            end

            table.insert(self._sections, Section)
            return Section
        end

        return Tab
    end

    -- --------------------------------------------------------
    -- Window:SetMenuKey(keyCode)
    -- --------------------------------------------------------
    function Window:SetMenuKey(keyCode)
        menuKeyCode = keyCode
    end

    -- --------------------------------------------------------
    -- Window:SetTitle(text)
    -- --------------------------------------------------------
    function Window:SetTitle(text)
        local titleLabel = self._main:FindFirstChild("title")
        if titleLabel then titleLabel.Text = text end
    end

    -- --------------------------------------------------------
    -- Window:Notify(text, duration, color)
    -- --------------------------------------------------------
    local notifContainer = new("Frame", {
        Name                   = "Notifications",
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 0),
        Position               = UDim2.new(0, 0, 0, 10),
        ZIndex                 = 100000,
    }, screenGui)

    local notifLayout = new("UIListLayout", {
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment   = Enum.VerticalAlignment.Top,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 4),
    }, notifContainer)

    function Window:Notify(text, duration, statusColor)
        duration = duration or 4

        local notif = new("Frame", {
            Name                   = "Notif",
            BackgroundColor3       = Color3.fromRGB(255, 255, 255),
            BorderSizePixel        = 0,
            ClipsDescendants       = true,
            ZIndex                 = 100000,
            Size                   = UDim2.new(0, 0, 0, 0),
        }, notifContainer)
        gradient(notif)

        if statusColor then
            new("Frame", {
                BackgroundColor3 = statusColor,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 0, 0, 0),
                Size             = UDim2.new(0, 3, 1, 0),
                ZIndex           = 101,
            }, notif)
        end

        local lbl = new("TextLabel", {
            Name                   = "text",
            BackgroundTransparency = 0.85,
            TextStrokeTransparency = 0,
            AutoLocalize           = false,
            BackgroundColor3       = Color3.fromRGB(0, 0, 0),
            TextColor3             = Library.Theme.Text,
            TextSize               = 18,
            FontFace               = Library.Theme.Font,
            TextXAlignment         = Enum.TextXAlignment.Center,
            Size                   = UDim2.new(1, -10, 1, -8),
            Position               = UDim2.new(0, 6, 0, 5),
            Text                   = text,
            ZIndex                 = 100001,
        }, notif)

        -- measure text to get target size
        local temp = new("TextLabel", {
            Font     = Enum.Font.TitilliumWeb,
            TextSize = 18,
            Text     = text,
            Visible  = false,
        }, notifContainer)
        task.wait()
        local bounds = temp.TextBounds
        local w, h   = math.min(bounds.X + 20, 600), bounds.Y + 12
        temp:Destroy()

        notif:TweenSize(UDim2.new(0, w, 0, h), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)

        task.spawn(function()
            task.wait(duration)
            notif:TweenSize(UDim2.new(0, 0, 0, h), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
            task.wait(0.4)
            if notif and notif.Parent then notif:Destroy() end
        end)
    end

    return Window
end

-- ============================================================
-- EXPORT
-- ============================================================
return Library