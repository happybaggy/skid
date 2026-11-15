
local Library = {}
Library.__index = Library

local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local Players = game:GetService("Players")
local GS      = game:GetService("GuiService")
local TS      = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local LP      = Players.LocalPlayer

local F   = Font.new("rbxasset://fonts/families/TitilliumWeb.json",  Enum.FontWeight.Regular,  Enum.FontStyle.Normal)
local FB  = Font.new("rbxasset://fonts/families/TitilliumWeb.json",  Enum.FontWeight.Bold,     Enum.FontStyle.Normal)
local FSB = Font.new("rbxasset://fonts/families/TitilliumWeb.json",  Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
local FN  = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular,  Enum.FontStyle.Normal)

local SW = 145   

local COLS = {
    left   = { xScale = 0.00889, side = "left"   },
    middle = { xScale = 0.34000, side = "middle"  },
    right  = { xScale = 0.67111, side = "right"   },
}


local function N(class, props)
    local i = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            pcall(function() i[k] = v end)
        end
    end
    return i
end

local function C(parent, class, props)
    local i = N(class, props)
    i.Parent = parent
    return i
end

local function Stroke(parent, color, thick)
    return C(parent, "UIStroke", {
        Color           = color or Color3.fromRGB(34, 103, 89),
        Thickness       = thick or 1.3,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode    = Enum.LineJoinMode.Miter,
    })
end

local function inputStr(i)
    if     i.UserInputType == Enum.UserInputType.MouseButton2 then return "mouse 2"
    elseif i.UserInputType == Enum.UserInputType.MouseButton3 then return "mouse 3"
    elseif i.UserInputType == Enum.UserInputType.Keyboard      then return i.KeyCode.Name:lower()
    end
end

local function tW(text, size)
    return TS:GetTextSize(text, size or 18, Enum.Font.TitilliumWeb, Vector2.new(9999, 9999)).X
end



Library._theme = {
    c1     = Color3.fromRGB(34, 85,  114),  
    c2     = Color3.fromRGB(34, 85,  114),  
    c3     = Color3.fromRGB(34, 103,  89),  
    merged = true,                          
}
Library._windows = {}

function Library:_grad()
    local t = self._theme
    if t.merged then
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, t.c1),
            ColorSequenceKeypoint.new(0.330, t.c1),
            ColorSequenceKeypoint.new(0.663, t.c3),
            ColorSequenceKeypoint.new(1.000, t.c3),
        })
    end
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0.000, t.c1),
        ColorSequenceKeypoint.new(0.165, t.c1),
        ColorSequenceKeypoint.new(0.330, t.c2),
        ColorSequenceKeypoint.new(0.660, t.c2),
        ColorSequenceKeypoint.new(0.825, t.c3),
        ColorSequenceKeypoint.new(1.000, t.c3),
    })
end

function Library:_accent(side)
    local t = self._theme
    if side == "left"   then return t.c1 end
    if side == "right"  then return t.c3 end
    
    return t.merged and t.c1:Lerp(t.c3, 0.5) or t.c2
end

function Library:SetTheme(cfg)
    for k, v in pairs(cfg) do self._theme[k] = v end
    for _, w in ipairs(self._windows) do pcall(function() w:_refreshTheme() end) end
end



Library._nGui  = nil
Library._nCont = nil

function Library:_ensureNotify()
    if self._nGui and self._nGui.Parent then return end
    local gui = N("ScreenGui", {
        Name           = "__LibNotify",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,   -- template's parent almost certainly has this
    })
    gui.Parent = CoreGui
    local cont = C(gui, "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,0),
        Position = UDim2.new(0,0,0,10),
        ZIndex = 100000,
    })
    C(cont, "UIListLayout", {
        FillDirection      = Enum.FillDirection.Vertical,
        HorizontalAlignment= Enum.HorizontalAlignment.Right,
        VerticalAlignment  = Enum.VerticalAlignment.Top,
        SortOrder          = Enum.SortOrder.LayoutOrder,
        Padding            = UDim.new(0,4),
    })
    self._nGui  = gui
    self._nCont = cont
end

function Library:Notify(text, duration, color)
    duration = duration or 4
    self:_ensureNotify()

    local frame = C(self._nCont, "Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),  -- ADD: matches template
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 100001,
        Size             = UDim2.new(0,0,0,0),
    })
    C(frame, "UIGradient", { Color = self:_grad() })

    if color then
        C(frame, "Frame", {
            BackgroundColor3 = color,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0,3,1,0),
            ZIndex           = 100003,
        })
    end

    local textLabel = C(frame, "TextLabel", {
        Text                   = text,
        RichText               = true,
        AutoLocalize           = false,
        BackgroundColor3       = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.85,
        TextColor3             = Color3.fromRGB(255,255,255),
        TextSize               = 18,
        FontFace               = FSB,
        TextStrokeTransparency = 0,
        TextXAlignment         = Enum.TextXAlignment.Center,
        TextYAlignment         = Enum.TextYAlignment.Center,
        Size                   = UDim2.new(1, -10, 1, -8),
        Position               = UDim2.new(0, 6, 0, 5),
        BorderSizePixel        = 0,
        ZIndex                 = 100002,
    })

    local temp = Instance.new("TextLabel")
    temp.FontFace    = FSB
    temp.TextSize    = 18
    temp.Text        = text
    temp.TextWrapped = false
    temp.Parent      = self._nCont
    temp.Visible     = false
    task.wait()
    local bounds = temp.TextBounds
    temp:Destroy()

    local paddingX, paddingY = 10, 6
    local w = math.min(bounds.X + paddingX + 10, 600)
    local h = bounds.Y + paddingY

    frame:TweenSize(UDim2.new(0, w, 0, h), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

    task.delay(duration, function()
        frame:TweenSize(UDim2.new(0,0,0,h), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(0.3)
        if frame.Parent then frame:Destroy() end
    end)
end



local Window = {}
Window.__index = Window

function Library:Window(cfg)
    cfg = cfg or {}
    local w = setmetatable({}, Window)
    w._lib        = self
    w._tabs       = {}
    w._binds      = {}
    w._curBind    = nil
    w._justOpened = false

    w._m = {
        grads   = {},
        headers = {},
        strokes = {},
        fills   = {},
        onBtns  = {},
    }

    local guiParent = (pcall(function() return syn.protect_gui end) and CoreGui) or CoreGui
    w._gui = N("ScreenGui", {
        Name = cfg.Name or "baggyware",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        Enabled        = true,
    })
    w._gui.Parent = guiParent

    w._main = C(w._gui, "Frame", {
        Name = "main", BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size     = cfg.Size     or UDim2.new(0,450,0,350),
        Position = cfg.Position or UDim2.new(0.155,-39,0.139,-15),
        ZIndex   = 100000,
    })
    local mg = C(w._main, "UIGradient", { Name="uig", Color = self:_grad() })
    table.insert(w._m.grads, mg)

    w._tabBar = C(w._main, "Frame", {
        Name = "buttons", BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.85,
        Size = UDim2.new(0,442,0,20), Position = UDim2.new(0.00889,0,0.92899,0),
        ZIndex = 100001,
    })

    w._wFolder = C(w._main, "Folder", { Name = "windows" })

    w._title = C(w._main, "TextLabel", {
        Name = "title", Text = cfg.Title or "baggyware",
        TextSize = 20, TextScaled = true, TextWrapped = true,
        TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.85,
        Size = UDim2.new(0,442,0,21), Position = UDim2.new(0.00889,0,0.00857,0),
        BorderSizePixel = 0, FontFace = FB, ZIndex = 100001,
    })

    
    w._tip = C(w._gui, "TextLabel", {
        Name = "Tooltip",
        BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 20, FontFace = FB,
        Size = UDim2.new(0,200,0,28), Visible = false,
        ZIndex = 100003, BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        TextStrokeTransparency = 0,
        TextStrokeColor3 = Color3.fromRGB(0,0,0),
    })

    if cfg.Watermark ~= false then
        w:_watermark(cfg.Watermark or "baggyware")
    end
    w:_drag()
    w:_bindListener()
    w:_tipRenderer()

    table.insert(Library._windows, w)
    return w
end

function Window:_refreshTheme()
    local grad = Library:_grad()
    for _, g in ipairs(self._m.grads)   do if g and g.Parent then g.Color = grad end end
    for _, h in ipairs(self._m.headers) do if h[1] and h[1].Parent then h[1].BackgroundColor3 = Library:_accent(h[2]) end end
    for _, s in ipairs(self._m.strokes) do if s[1] and s[1].Parent then s[1].Color            = Library:_accent(s[2]) end end
    for _, f in ipairs(self._m.fills)   do if f[1] and f[1].Parent then f[1].BackgroundColor3 = Library:_accent(f[2]) end end
    for _, b in ipairs(self._m.onBtns)  do
        if b[1] and b[1].Parent and b[1].BackgroundTransparency < 0.5 then
            b[1].BackgroundColor3 = Library:_accent(b[2])
        end
    end
    if self._wGrad and self._wGrad.Parent then self._wGrad.Color = grad end
end

function Window:_watermark(text)
    self._wFrame = C(self._gui, "Frame", {
        Name = "watermark", BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size = UDim2.new(0,174,0,26), Position = UDim2.new(0,5,0,2), ZIndex = 99999,
    })
    self._wGrad = C(self._wFrame, "UIGradient", { Name="uig", Color = Library:_grad() })
    self._wLabel = C(self._wFrame, "TextLabel", {
        Name = "mark", Text = " " .. text .. " | fps: 0  ",
        TextSize = 20, TextStrokeTransparency = 0,
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.85,
        Size = UDim2.new(0,168,0,20), Position = UDim2.new(0.01169,0,0.08,0),
        BorderSizePixel = 0, FontFace = FSB, RichText = true, AutoLocalize = false,
        ZIndex = 100000,
    })
    local fps, timer, margin = 0, tick(), 3
    RS.Heartbeat:Connect(function()
        fps = fps + 1
        local now = tick()
        if now - timer < 1 then return end
        local rate = math.floor(fps / (now - timer))
        fps, timer = 0, now
        self._wLabel.Text = string.format(" %s | fps: %d  ", text, rate)
        local w = tW(self._wLabel.Text, 20)
        self._wLabel.Size  = UDim2.new(0, w,   0, 20)
        self._wLabel.Position = UDim2.new(0, margin, 0, margin)
        self._wFrame.Size  = UDim2.new(0, w + margin*2, 0, 20 + margin*2)
    end)
end

function Window:_drag()
    local dragging, ds, dp = false, nil, nil
    local target = self._main.Position
    self._main.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local ap = self._main.AbsolutePosition
        if i.Position.Y <= ap.Y + 25 then
            dragging, ds, dp = true, i.Position, self._main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d  = i.Position - ds
        local vp = workspace.CurrentCamera.ViewportSize
        target = UDim2.new(dp.X.Scale + d.X/vp.X, dp.X.Offset, dp.Y.Scale + d.Y/vp.Y, dp.Y.Offset)
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RS.RenderStepped:Connect(function(dt)
        if not self._main.Parent then return end
        local c = self._main.Position
        self._main.Position = UDim2.new(
            c.X.Scale + (target.X.Scale - c.X.Scale) * math.min(dt*8,1), c.X.Offset,
            c.Y.Scale + (target.Y.Scale - c.Y.Scale) * math.min(dt*8,1), c.Y.Offset
        )
    end)
end

function Window:_bindListener()
    UIS.InputBegan:Connect(function(input)
        local bd = self._curBind
        if not bd then return end
        if self._justOpened then self._justOpened = false; return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            bd.label.BackgroundColor3 = Color3.fromRGB(180,30,30)
            bd.label.BackgroundTransparency = 0
            task.delay(0.35, function()
                if self._curBind == bd and bd.label.Parent then
                    bd.label.BackgroundColor3 = Library:_accent("left")
                    bd.label.BackgroundTransparency = 0
                end
            end)
            return
        end

        if input.KeyCode == Enum.KeyCode.Backspace and not bd.menuKey then
            bd.bound = nil
            bd.label.Text = "nil"
            bd.label.BackgroundColor3 = Color3.fromRGB(0,0,0)
            bd.label.BackgroundTransparency = 0.65
            self._curBind = nil
            if bd.onChange then bd.onChange(nil) end
            return
        end

        local str = inputStr(input)
        if not str then return end
        if bd.menuKey and input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        bd.bound = str
        bd.label.Text = str
        bd.label.BackgroundColor3 = Color3.fromRGB(0,0,0)
        bd.label.BackgroundTransparency = 0.65
        self._curBind = nil
        if bd.onChange then bd.onChange(str) end
    end)
end

function Window:_tipRenderer()
    RS.RenderStepped:Connect(function()
        if not self._tip.Visible then return end
        local w = tW(self._tip.Text, 20) + 16
        local h = 28
        self._tip.Size = UDim2.new(0, w, 0, h)
        local mp = UIS:GetMouseLocation()
        local vp = workspace.CurrentCamera.ViewportSize
        self._tip.Position = UDim2.new(0,
            math.clamp(mp.X, 5, vp.X - w - 5), 0,
            math.clamp(mp.Y - 90, 5, vp.Y - h - 5)
        )
    end)
end

function Window:SetTitle(t)       self._title.Text = t end
function Window:SetVisible(v)     self._main.Visible = v end
function Window:Toggle()          self._main.Visible = not self._main.Visible end
function Window:Notify(t, d, c)   Library:Notify(t, d, c) end

function Window:MenuBind(cfg)
    cfg = cfg or {}
    local key = cfg.Key or "rightalt"
    UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if inputStr(i) == key then
            if cfg.OnToggle then pcall(cfg.OnToggle)
            else self:Toggle() end
        end
    end)
end



local Tab = {}
Tab.__index = Tab

function Window:Tab(cfg)
    cfg = type(cfg) == "string" and { Name = cfg } or cfg
    local t  = setmetatable({}, Tab)
    t._win   = self
    t._name  = cfg.Name or "tab"

    t._btn = C(self._tabBar, "TextButton", {
        Name = t._name, Text = t._name,
        TextSize = 14, TextScaled = true, TextWrapped = true,
        TextStrokeTransparency = 0,
        TextColor3 = Color3.fromRGB(176,176,176),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1, FontFace = F,
        BorderSizePixel = 0, ZIndex = 100002,
        Size = UDim2.new(0,147,0,20), Position = UDim2.new(0,0,0,0),
    })
    t._frame = C(self._wFolder, "Frame", {
        Name = t._name .. "frame",
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0,450,0,350),
        Visible = false,
    })

    t._btn.MouseButton1Click:Connect(function()
        for _, tab in ipairs(self._tabs) do
            tab._frame.Visible = false
            tab._btn.TextColor3 = Color3.fromRGB(176,176,176)
        end
        t._frame.Visible = true
        t._btn.TextColor3 = Color3.fromRGB(255,255,255)
    end)

    table.insert(self._tabs, t)

    local bw = math.floor(442 / #self._tabs)
    for i, tab in ipairs(self._tabs) do
        tab._btn.Size     = UDim2.new(0, bw, 0, 20)
        tab._btn.Position = UDim2.new(0, (i-1)*bw, 0, 0)
    end

    if #self._tabs == 1 then
        t._frame.Visible = true
        t._btn.TextColor3 = Color3.fromRGB(255,255,255)
    end
    return t
end



local Section = {}
Section.__index = Section

function Tab:Section(cfg)
    cfg  = type(cfg) == "string" and { Name=cfg } or cfg
    local s   = setmetatable({}, Section)
    s._win    = self._win
    s._m      = self._win._m
    s._name   = cfg.Name   or "section"
    s._col    = cfg.Column or "left"
    s._side   = (COLS[s._col] or COLS.left).side
    s._order  = 0

    local ci  = COLS[s._col] or COLS.left
    local yPos = cfg.Y      or 0.08
    local h    = cfg.Height or 142

    s._frame = C(self._frame, "Frame", {
        Name = s._name, BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.65,
        Size = UDim2.new(0, SW, 0, h),
        Position = UDim2.new(ci.xScale, 0, yPos, 0),
    })
    C(s._frame, "UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })

    s._header = C(s._frame, "TextLabel", {
        Name = "label", Text = "  " .. s._name,
        TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Library:_accent(s._side), FontFace = F,
        Size = UDim2.new(0, SW, 0, 20), BorderSizePixel = 0,
        SelectionOrder = 1, LayoutOrder = -1,
    })
    table.insert(s._m.headers, { s._header, s._side })
    return s
end

function Section:_accent() return Library:_accent(self._side) end

function Section:_tip(row, text)
    if not text then return end
    local tip = self._win._tip
    row.MouseEnter:Connect(function() tip.Text = text; tip.Visible = true  end)
    row.MouseLeave:Connect(function()                   tip.Visible = false end)
end

function Section:_row(h)
    local o = self._order; self._order = o + 1
    return C(self._frame, "Frame", {
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, SW, 0, h or 20),
        LayoutOrder = o,
    })
end

function Section:_label(parent, text)
    return C(parent, "TextLabel", {
        Name = "text", Text = text,
        TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 1,
        FontFace = F, BorderSizePixel = 0, TextDirection = Enum.TextDirection.LeftToRight,
        Size = UDim2.new(0,125,0,20), Position = UDim2.new(0,5,0,0),
    })
end



function Section:Toggle(cfg)
    cfg   = type(cfg) == "string" and { Name=cfg } or cfg
    local name   = cfg.Name    or "toggle"
    local state  = cfg.Default or false
    local accent = self:_accent()
    local win    = self._win

    local row = self:_row(20)
    row.Name = name
    self:_label(row, name)
    self:_tip(row, cfg.Tooltip)

    local btn = C(row, "Frame", {
        Name = "button", BorderSizePixel = 0,
        BackgroundColor3 = state and accent or Color3.fromRGB(0,0,0),
        BackgroundTransparency = state and 0 or 0.85,
        Size = UDim2.new(0,10,0,10), Position = UDim2.new(0.89146,0,0.22,0),
    })
    local bs = Stroke(btn, accent, 1.3)
    table.insert(self._m.strokes, { bs, self._side })
    table.insert(self._m.onBtns,  { btn, self._side })

    local hotkeyLbl, bd = nil, nil
    if cfg.Hotkey then
        hotkeyLbl = C(row, "TextLabel", {
            Name = "hotkey", Text = cfg.DefaultKey or "nil",
            TextSize = 18, TextStrokeTransparency = 0,
            TextColor3 = Color3.fromRGB(255,255,255),
            BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.65,
            FontFace = F, Size = UDim2.new(0,30,0,10),
            Position = UDim2.new(0.62522,0,0.22,0), BorderSizePixel = 0,
        })
        local hs = Stroke(hotkeyLbl, accent, 1.4)
        table.insert(self._m.strokes, { hs, self._side })
    end

    local function sync()
        local ca = self:_accent()
        btn.BackgroundColor3      = state and ca or Color3.fromRGB(0,0,0)
        btn.BackgroundTransparency = state and 0 or 0.85
        local bs_curr = btn:FindFirstChildWhichIsA("UIStroke")
        if bs_curr then bs_curr.Color = ca end
        
        if hotkeyLbl then
            local hs_curr = hotkeyLbl:FindFirstChildWhichIsA("UIStroke")
            if hs_curr then hs_curr.Color = ca end
        end
    end

    btn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        state = not state; sync()
        if state      and cfg.OnEnable  then pcall(cfg.OnEnable)       end
        if not state  and cfg.OnDisable then pcall(cfg.OnDisable)      end
        if cfg.OnChange then pcall(cfg.OnChange, state) end
    end)

    if cfg.Hotkey and hotkeyLbl then
        bd = {
            label   = hotkeyLbl,
            menuKey = false,
            bound   = cfg.DefaultKey,
            mode    = cfg.BindMode or "toggle",
            onChange= cfg.OnBind,
            name    = name,
        }
        win._binds[name] = bd

        hotkeyLbl.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                if win._curBind then
                    local p = win._curBind
                    p.label.BackgroundColor3  = Color3.fromRGB(0,0,0)
                    p.label.BackgroundTransparency = 0.65
                    p.label.Text = p.bound or "nil"
                end
                win._curBind = bd; win._justOpened = true
                hotkeyLbl.Text = "..."
                hotkeyLbl.BackgroundColor3  = Library:_accent("left")
                hotkeyLbl.BackgroundTransparency = 0
            elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
                if win._curBind == bd then
                    win._curBind = nil
                    hotkeyLbl.Text = bd.bound or "nil"
                    hotkeyLbl.BackgroundColor3  = Color3.fromRGB(0,0,0)
                    hotkeyLbl.BackgroundTransparency = 0.65
                end
                bd.mode = bd.mode == "toggle" and "hold" or "toggle"
            end
        end)

        UIS.InputBegan:Connect(function(i, gpe)
            if gpe or win._curBind then return end
            if not bd.bound or inputStr(i) ~= bd.bound then return end
            if bd.mode == "hold" then
                state = true; sync()
                if cfg.OnEnable  then pcall(cfg.OnEnable)       end
                if cfg.OnChange  then pcall(cfg.OnChange, true)  end
            else
                state = not state; sync()
                if state     and cfg.OnEnable  then pcall(cfg.OnEnable)       end
                if not state and cfg.OnDisable then pcall(cfg.OnDisable)      end
                if cfg.OnChange then pcall(cfg.OnChange, state) end
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if not bd.bound or bd.mode ~= "hold" then return end
            if inputStr(i) == bd.bound and state then
                state = false; sync()
                if cfg.OnDisable then pcall(cfg.OnDisable)       end
                if cfg.OnChange  then pcall(cfg.OnChange, false) end
            end
        end)
    end

    return {
        Row  = row, Btn = btn, Bind = bd,
        Set  = function(_, v)
            state = v; sync()
            if state     and cfg.OnEnable  then pcall(cfg.OnEnable)       end
            if not state and cfg.OnDisable then pcall(cfg.OnDisable)      end
        end,
        Get  = function() return state end,
    }
end



function Section:Slider(cfg)
    cfg   = type(cfg) == "string" and { Name=cfg } or cfg
    local name   = cfg.Name    or "slider"
    local minV   = cfg.Min     or 0
    local maxV   = cfg.Max     or 100
    local defV   = cfg.Default or minV
    local isInt  = cfg.Int     ~= false
    local fmt    = cfg.Format  or "%.0f"
    local accent = self:_accent()
    local value  = defV

    local row = self:_row(40)
    row.Name = name
    local labelText = name .. " - "
    self:_label(row, labelText)
    self:_tip(row, cfg.Tooltip)

    
    local textW = tW(labelText, 18)

    local track = C(row, "Frame", {
        Name = "slider", BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.85,
        Size = UDim2.new(1, -12, 0, 12), Position = UDim2.new(0, 6, 0, 24),
    })
    local ts = Stroke(track, accent, 1.3)
    table.insert(self._m.strokes, { ts, self._side }) 
    
    local fill = C(track, "Frame", {
        Name = "fill", BorderSizePixel = 0,
        BackgroundColor3 = accent, Size = UDim2.new(0,0,1,0),
    })
    table.insert(self._m.fills, { fill, self._side })

    local numBox = C(row, "TextBox", {
        Name = "number", Text = tostring(defV),
        TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(201,201,201),
        BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 1,
        FontFace = FN, Size = UDim2.new(1, -(textW + 15), 0, 20),
        Position = UDim2.new(0, textW + 5, 0, 0), BorderSizePixel = 0,
        ClearTextOnFocus = false, TextWrapped = false,
    })

    local dragging = false
    local function set(v)
        if isInt then v = math.floor(v + 0.5) end
        value = math.clamp(v, minV, maxV)
        numBox.Text = string.format(isInt and "%d" or fmt, value)
        fill.Size   = UDim2.new((value - minV) / math.max(maxV - minV, 1), 0, 1, 0)
        if cfg.OnChange then pcall(cfg.OnChange, value) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging = true
        set(minV + (maxV-minV) * math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
    end)
    track.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        set(minV + (maxV-minV) * math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
    end)
    numBox.FocusLost:Connect(function()
        local v = tonumber(numBox.Text)
        if v then set(v) else numBox.Text = string.format(isInt and "%d" or fmt, value) end
    end)
    set(defV)

    return {
        Row = row,
        Set = function(_, v) set(v) end,
        Get = function() return value end,
    }
end



function Section:Dropdown(cfg)
    cfg   = type(cfg) == "string" and { Name=cfg } or cfg
    local name    = cfg.Name    or "dropdown"
    local options = cfg.Options or {}
    local current = cfg.Default or options[1] or "none"
    local accent  = self:_accent()
    local gui     = self._win._gui

    local row = self:_row(20)
    row.Name = name
    self:_label(row, name)
    self:_tip(row, cfg.Tooltip)

    local val = C(row, "TextLabel", {
        Name = "val", Text = tostring(current),
        TextSize = 18, TextStrokeTransparency = 0,
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.65,
        FontFace = F, Size = UDim2.new(0,50,0,10),
        Position = UDim2.new(0.62522,0,0.22,0), BorderSizePixel = 0,
    })
    local vs = Stroke(val, accent, 1.4)
    table.insert(self._m.strokes, { vs, self._side })

    local popup = C(gui, "Frame", {
        Name = "dropdown", ZIndex = 100001, BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        Size = UDim2.fromOffset(100, #options * 20), Visible = false,
    })
    local ps = Stroke(popup, accent, 1)
    table.insert(self._m.strokes, { ps, self._side })
    C(popup, "UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })

    local function buildPopup()
        for _, c in ipairs(popup:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local maxW = 0
        for _, o in ipairs(options) do maxW = math.max(maxW, tW(o, 14)) end
        local w = math.max(val.AbsoluteSize.X, math.min(maxW + 16, 600))
        popup.Size = UDim2.fromOffset(w, #options * 20)
        for i, opt in ipairs(options) do
            local b = C(popup, "TextButton", {
                Size=UDim2.new(1,0,0,20), BorderSizePixel=0,
                BackgroundColor3=Color3.fromRGB(30,30,30),
                Text=opt, TextColor3=Color3.fromRGB(200,200,200),
                TextSize=14, Font=Enum.Font.TitilliumWeb,
                ZIndex=201, LayoutOrder=i,
            })
            b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(30,30,30) end)
            b.MouseButton1Click:Connect(function()
                current = opt; val.Text = opt; popup.Visible = false
                if cfg.OnChange then pcall(cfg.OnChange, opt) end
            end)
        end
    end
    buildPopup()

    local function posPopup()
        local ap, as = val.AbsolutePosition, val.AbsoluteSize
        local vp = workspace.CurrentCamera.ViewportSize
        local pw = popup.AbsoluteSize.X
        local ph = popup.AbsoluteSize.Y
        local y = ap.Y + as.Y + 2
        if y + ph > vp.Y then y = ap.Y - ph - 2 end
        popup.Position = UDim2.fromOffset(math.clamp(ap.X + as.X/2 - pw/2, 2, vp.X - pw - 2), y)
    end

    val.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        popup.Visible = not popup.Visible
        if popup.Visible then
            posPopup()
            for _, c in ipairs(gui:GetChildren()) do
                if c.Name == "dropdown" and c ~= popup then c.Visible = false end
            end
        end
    end)
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 or not popup.Visible then return end
        local mp, dp, ds = i.Position, popup.AbsolutePosition, popup.AbsoluteSize
        if mp.X<dp.X or mp.X>dp.X+ds.X or mp.Y<dp.Y or mp.Y>dp.Y+ds.Y then
            local ap, as = val.AbsolutePosition, val.AbsoluteSize
            if not (mp.X>=ap.X and mp.X<=ap.X+as.X and mp.Y>=ap.Y and mp.Y<=ap.Y+as.Y) then
                popup.Visible = false
            end
        end
    end)

    return {
        Row   = row, Label = val,
        Set   = function(_, v) current = v; val.Text = tostring(v); if cfg.OnChange then pcall(cfg.OnChange, v) end end,
        Get   = function() return current end,
        SetOptions = function(_, opts) options = opts; buildPopup() end,
    }
end



function Section:MultiSelect(cfg)
    cfg   = type(cfg) == "string" and { Name=cfg } or cfg
    local name     = cfg.Name    or "multiselect"
    local options  = cfg.Options or {}
    local selected = {}
    for _, v in ipairs(cfg.Default or {}) do selected[v] = true end
    local accent   = self:_accent()
    local gui      = self._win._gui

    local row = self:_row(20)
    row.Name = name
    self:_label(row, name)
    self:_tip(row, cfg.Tooltip)

    local val = C(row, "TextLabel", {
        Name = "val", Text = "none",
        TextSize = 18, TextStrokeTransparency = 0,
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.65,
        FontFace = F, Size = UDim2.new(0,50,0,10),
        Position = UDim2.new(0.62522,0,0.22,0), BorderSizePixel = 0,
    })
    local ms = Stroke(val, accent, 1.4)
    table.insert(self._m.strokes, { ms, self._side })

    local function emit()
        local out = {}
        for _, o in ipairs(options) do if selected[o] then table.insert(out, o) end end
        val.Text = #out == 0 and "none" or #out == 1 and out[1] or "(...)"
        if cfg.OnChange then pcall(cfg.OnChange, out) end
    end

    local maxW = 0
    for _, o in ipairs(options) do maxW = math.max(maxW, tW(o, 14)) end
    local popup = C(gui, "Frame", {
        Name = "dropdown", ZIndex = 100001, BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        Size = UDim2.fromOffset(math.max(60, math.min(maxW+16,600)), #options*20),
        Visible = false,
    })
    local ps = Stroke(popup, accent, 1)
    table.insert(self._m.strokes, { ps, self._side })
    C(popup, "UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })

    for i, opt in ipairs(options) do
        local b = C(popup, "TextButton", {
            Size=UDim2.new(1,0,0,20), BorderSizePixel=0,
            BackgroundColor3=Color3.fromRGB(30,30,30),
            Text=opt, TextColor3=selected[opt] and Color3.fromRGB(255,255,255) or Color3.fromRGB(176,176,176),
            TextSize=14, Font=Enum.Font.TitilliumWeb, ZIndex=201, LayoutOrder=i,
        })
        b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(30,30,30) end)
        b.MouseButton1Click:Connect(function()
            selected[opt] = not selected[opt]
            b.TextColor3 = selected[opt] and Color3.fromRGB(255,255,255) or Color3.fromRGB(176,176,176)
            emit()
        end)
    end

    local function posPopup()
        local ap, as = val.AbsolutePosition, val.AbsoluteSize
        local vp = workspace.CurrentCamera.ViewportSize
        local pw = popup.AbsoluteSize.X
        local ph = popup.AbsoluteSize.Y
        local y = ap.Y + as.Y + 2
        if y + ph > vp.Y then y = ap.Y - ph - 2 end
        popup.Position = UDim2.fromOffset(math.clamp(ap.X+as.X/2-pw/2, 2, vp.X-pw-2), y)
    end
    val.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        popup.Visible = not popup.Visible
        if popup.Visible then posPopup()
            for _, c in ipairs(gui:GetChildren()) do
                if c.Name == "dropdown" and c ~= popup then c.Visible = false end
            end
        end
    end)
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 or not popup.Visible then return end
        local mp, dp, ds = i.Position, popup.AbsolutePosition, popup.AbsoluteSize
        if mp.X<dp.X or mp.X>dp.X+ds.X or mp.Y<dp.Y or mp.Y>dp.Y+ds.Y then
            local ap, as = val.AbsolutePosition, val.AbsoluteSize
            if not (mp.X>=ap.X and mp.X<=ap.X+as.X and mp.Y>=ap.Y and mp.Y<=ap.Y+as.Y) then
                popup.Visible = false
            end
        end
    end)
    emit()

    return {
        Row = row,
        Get = function()
            local out = {}
            for _, o in ipairs(options) do if selected[o] then table.insert(out, o) end end
            return out
        end,
    }
end



function Section:ColorPicker(cfg)
    cfg   = type(cfg) == "string" and { Name=cfg } or cfg
    local name    = cfg.Name    or "color"
    local current = cfg.Default or Color3.fromRGB(255,255,255)
    local accent  = self:_accent()
    local gui     = self._win._gui

    local row = self:_row(20)
    row.Name = name
    self:_label(row, name)
    self:_tip(row, cfg.Tooltip)

    local swatch = C(row, "Frame", {
        Name = "colorchanger", BorderSizePixel = 0,
        BackgroundColor3 = current,
        Size = UDim2.new(0,40,0,10), Position = UDim2.new(0.68406,0,0.22,0),
    })
    
    local ss = Stroke(swatch, accent, 1.3)
    table.insert(self._m.strokes, { ss, self._side })

    local open, hue = false, 0

    local pm = C(gui, "TextButton", {
        Name = "colorpicker", ZIndex = 100001, Visible = false,
        AutoButtonColor = false, Text = "",
        Size = UDim2.fromOffset(180,196), BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(40,40,40),
    })
    C(pm, "Frame", { ZIndex=98, Size=UDim2.fromOffset(186,202), BorderSizePixel=0, BackgroundColor3=Color3.fromRGB(0,0,0),   Position=UDim2.fromOffset(-3,-3) })
    C(pm, "Frame", { ZIndex=98, Size=UDim2.fromOffset(182,198), BorderSizePixel=0, BackgroundColor3=Color3.fromRGB(60,60,60), Position=UDim2.fromOffset(-1,-1) })

    local hc = C(pm, "ImageLabel", {
        ZIndex=101, Position=UDim2.new(0,3,0,3), Size=UDim2.new(0,172,0,172),
        Image="rbxassetid://4155801252", ScaleType=Enum.ScaleType.Stretch,
        BackgroundColor3=Color3.new(1,0,0), BorderSizePixel=1, BorderColor3=Color3.fromRGB(0,0,0),
    })
    local hp = C(pm, "ImageLabel", {
        ZIndex=102, BackgroundTransparency=1, BorderSizePixel=0,
        Position=UDim2.new(0,0,0,0), Size=UDim2.new(0,7,0,7),
        Image="rbxassetid://6885856475",
    })
    local sel = C(pm, "TextLabel", {
        ZIndex=101, Position=UDim2.new(0,3,0,181), Size=UDim2.new(0,173,0,10),
        BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=1,
        BorderColor3=Color3.fromRGB(0,0,0), Text="",
    })
    C(sel, "UIGradient", { Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.new(1,0,0)),
        ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
        ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)),
        ColorSequenceKeypoint.new(0.50, Color3.new(0,1,1)),
        ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)),
        ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
        ColorSequenceKeypoint.new(1.00, Color3.new(1,0,0)),
    }) })
    local sp = C(sel, "Frame", {
        ZIndex=102, BackgroundColor3=Color3.fromRGB(40,40,40),
        Position=UDim2.new(0,0,0,0), Size=UDim2.new(0,2,0,10),
        BorderColor3=Color3.fromRGB(255,255,255), BorderSizePixel=1,
    })

    local function setColor(c)
        current = Color3.new(math.clamp(c.R,0,1), math.clamp(c.G,0,1), math.clamp(c.B,0,1))
        
        swatch.BackgroundColor3 = current
        if cfg.OnChange then pcall(cfg.OnChange, current) end
    end

    local function mxy()
        local p = UIS:GetMouseLocation()
        local g = GS:GetGuiInset()
        return p.X, p.Y - g.Y
    end

    local function refreshHue()
        local mx, my = mxy()
        local x = math.clamp((mx - hc.AbsolutePosition.X) / hc.AbsoluteSize.X, 0, 1)
        local y = math.clamp((my - hc.AbsolutePosition.Y) / hc.AbsoluteSize.Y, 0, 1)
        hp:TweenPosition(UDim2.new(
            math.clamp(x*hc.AbsoluteSize.X, 0.5, 0.952*hc.AbsoluteSize.X) / hc.AbsoluteSize.X, 0,
            math.clamp(y*hc.AbsoluteSize.Y, 0.5, 0.885*hc.AbsoluteSize.Y) / hc.AbsoluteSize.Y, 0
        ), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05)
        setColor(Color3.fromHSV(hue,
            math.clamp(x*hc.AbsoluteSize.X, 0.5, hc.AbsoluteSize.X) / hc.AbsoluteSize.X,
            1 - math.clamp(y*hc.AbsoluteSize.Y, 0.5, hc.AbsoluteSize.Y) / hc.AbsoluteSize.Y
        ))
    end

    local function refreshSel()
        local mx = mxy()
        local pos = math.clamp((mx - hc.AbsolutePosition.X) / hc.AbsoluteSize.X, 0, 1)
        hue = 1 - pos
        sp:TweenPosition(UDim2.new(pos,0,0,0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05)
        hc.BackgroundColor3 = Color3.fromHSV(1-pos, 1, 1)
        local px = (hp.AbsolutePosition.X - hc.AbsolutePosition.X) / hc.AbsoluteSize.X
        local py = (hp.AbsolutePosition.Y - hc.AbsolutePosition.Y) / hc.AbsoluteSize.Y
        setColor(Color3.fromHSV(hue,
            math.clamp(px*hc.AbsoluteSize.X, 0.5, hc.AbsoluteSize.X) / hc.AbsoluteSize.X,
            1 - math.clamp(py*hc.AbsoluteSize.Y, 0.5, hc.AbsoluteSize.Y) / hc.AbsoluteSize.Y
        ))
    end

    local dH, dS = false, false
    hc.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dH=true;refreshHue() end end)
    hc.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dH=false end end)
    sel.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dS=true;refreshSel() end end)
    sel.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dS=false end end)
    UIS.InputChanged:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if dH then refreshHue() end
        if dS then refreshSel() end
    end)

    local function posPopup()
        local ap, as = swatch.AbsolutePosition, swatch.AbsoluteSize
        local vp = workspace.CurrentCamera.ViewportSize
        local x = ap.X + as.X + 4
        if x + 186 > vp.X then x = ap.X - 186 end
        pm.Position = UDim2.fromOffset(x, math.min(ap.Y, vp.Y - 200))
    end

    swatch.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        open = not open; pm.Visible = open
        if open then posPopup()
            for _, c in ipairs(gui:GetChildren()) do
                if c.Name == "colorpicker" and c ~= pm then c.Visible = false end
            end
        end
    end)
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 or not open then return end
        local mp, pp, ps = i.Position, pm.AbsolutePosition, pm.AbsoluteSize
        if mp.X<pp.X or mp.X>pp.X+ps.X or mp.Y<pp.Y or mp.Y>pp.Y+ps.Y then
            local ap, as = swatch.AbsolutePosition, swatch.AbsoluteSize
            if not (mp.X>=ap.X and mp.X<=ap.X+as.X and mp.Y>=ap.Y and mp.Y<=ap.Y+as.Y) then
                open = false; pm.Visible = false
            end
        end
    end)

    setColor(current)
    return {
        Row = row, Swatch = swatch, Picker = pm,
        Get = function() return current end,
        Set = function(_, c) setColor(c) end,
    }
end



function Section:TextInput(cfg)
    cfg   = type(cfg) == "string" and { Name=cfg } or cfg
    local name   = cfg.Name    or "input"
    local defVal = cfg.Default or "nil"
    local accent = self:_accent()

    local row = self:_row(20)
    row.Name = name
    self:_label(row, name)
    self:_tip(row, cfg.Tooltip)

    local box = C(row, "TextBox", {
        Name = "input", Text = defVal,
        PlaceholderText = cfg.Placeholder or " " .. defVal .. " ",
        PlaceholderColor3 = Color3.fromRGB(180,180,180),
        TextSize = 18, TextStrokeTransparency = 0,
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.65,
        FontFace = F, Size = UDim2.new(0,48,0,10),
        Position = UDim2.new(0.62522,0,0.22,0), BorderSizePixel = 0,
        ClearTextOnFocus = cfg.ClearOnFocus or false,
        TextEditable = cfg.ReadOnly ~= true, TextWrapped = false,
    })
    local s = Stroke(box, accent, 1.4)
    table.insert(self._m.strokes, { s, self._side })
    if cfg.OnChange then box.FocusLost:Connect(function() pcall(cfg.OnChange, box.Text) end) end

    return {
        Row = row, Box = box,
        Get = function() return box.Text end,
        Set = function(_, v)
            box.Text = tostring(v)
            if cfg.OnChange then pcall(cfg.OnChange, box.Text) end
        end,
    }
end



function Section:Button(cfg)
    cfg   = type(cfg) == "string" and { Name=cfg } or cfg
    local name   = cfg.Name or "button"
    local accent = self:_accent()

    local row = self:_row(20)
    row.Name = name
    self:_tip(row, cfg.Tooltip)

    local lbl = C(row, "TextLabel", {
        Name = "button", Text = name,
        TextSize = 18, TextStrokeTransparency = 0,
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.65,
        FontFace = F, Size = UDim2.new(0,133,0,15),
        Position = UDim2.new(0.03448,0,0.22,0), BorderSizePixel = 0,
    })
    local s = Stroke(lbl, accent, 1.4)
    table.insert(self._m.strokes, { s, self._side })

    lbl.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            if cfg.OnClick then pcall(cfg.OnClick) end
        end
    end)
    return { Row = row, Lbl = lbl }
end



function Section:Keybind(cfg)
    cfg   = type(cfg) == "string" and { Name=cfg } or cfg
    local name   = cfg.Name    or "keybind"
    local isMenu = cfg.MenuKey or false
    local accent = self:_accent()
    local win    = self._win

    local row = self:_row(20)
    row.Name = name
    self:_label(row, name)
    self:_tip(row, cfg.Tooltip)

    local lbl = C(row, "TextLabel", {
        Name = "hotkey", Text = cfg.Default or "nil",
        TextSize = 18, TextStrokeTransparency = 0,
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.65,
        FontFace = F, Size = UDim2.new(0,48,0,10),
        Position = UDim2.new(0.62522,0,0.22,0), BorderSizePixel = 0,
    })
    local s = Stroke(lbl, accent, 1.4)
    table.insert(self._m.strokes, { s, self._side })

    local bd = {
        label   = lbl, menuKey = isMenu, bound = cfg.Default,
        mode    = cfg.Mode or "toggle", onChange = cfg.OnChange, name = name,
    }
    win._binds[name] = bd

    lbl.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            if win._curBind then
                local p = win._curBind
                p.label.BackgroundColor3  = Color3.fromRGB(0,0,0)
                p.label.BackgroundTransparency = 0.65
                p.label.Text = p.bound or "nil"
            end
            win._curBind = bd; win._justOpened = true
            lbl.Text = "..."
            lbl.BackgroundColor3  = Library:_accent("left")
            lbl.BackgroundTransparency = 0
        elseif i.UserInputType == Enum.UserInputType.MouseButton2 and not isMenu then
            if win._curBind == bd then
                win._curBind = nil
                lbl.Text = bd.bound or "nil"
                lbl.BackgroundColor3  = Color3.fromRGB(0,0,0)
                lbl.BackgroundTransparency = 0.65
            end
            bd.mode = bd.mode == "toggle" and "hold" or "toggle"
        end
    end)

    return { Row=row, Label=lbl, Bind=bd, Get=function() return bd.bound, bd.mode end }
end



function Section:ScrollList(cfg)
    cfg   = type(cfg) == "string" and { Name=cfg } or cfg
    local entryH = cfg.EntryHeight or 20
    local accent  = self:_accent()

    local sf = C(self._frame, "ScrollingFrame", {
        Name = "sf", Active = true, BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(41,41,41),
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
        Size = UDim2.new(0,137,0,112),
        ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
        Position = UDim2.new(0.02759,0,0.16901,0),
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0,0,0,0),
        LayoutOrder = self._order,
    })
    self._order = self._order + 1
    local st = Stroke(sf, accent, 1.5)
    table.insert(self._m.strokes, { st, self._side })
    C(sf, "UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })

    local entries = {}
    local function refresh() sf.CanvasSize = UDim2.new(0,0,0,#entries*entryH) end

    return {
        Frame = sf,
        AddEntry = function(_, text, opts)
            opts = opts or {}
            local btn = C(sf, "TextButton", {
                TextWrapped=true, TextStrokeTransparency=0, BorderSizePixel=0,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextSize=14, TextScaled=true,
                TextColor3=Color3.fromRGB(255,255,255),
                BackgroundColor3=Color3.fromRGB(255,255,255),
                BackgroundTransparency=1,
                FontFace=Font.new("rbxasset://fonts/families/TitilliumWeb.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal),
                Size=UDim2.new(0,137,0,entryH),
                Text=text, Name=tostring(#entries+1),
                LayoutOrder=#entries+1,
            })
            if opts.OnClick then
                btn.MouseButton1Click:Connect(function() pcall(opts.OnClick, btn) end)
            end
            if opts.OnRightClick then
                btn.MouseButton2Click:Connect(function() pcall(opts.OnRightClick, btn) end)
            end
            table.insert(entries, btn); refresh()
            return btn
        end,
        Remove = function(_, btn)
            for i, e in ipairs(entries) do
                if e == btn then e:Destroy(); table.remove(entries,i); refresh(); break end
            end
        end,
        Clear = function()
            for _, e in ipairs(entries) do if e.Parent then e:Destroy() end end
            entries = {}; refresh()
        end,
        Count = function() return #entries end,
    }
end



function Section:GradientSquares(cfg)
    cfg = cfg or {}
    local accent = self:_accent()

    local container = C(self._frame, "Frame", {
        Name = "gradientpicker", BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, SW, 0, 45), LayoutOrder = self._order,
    })
    self._order = self._order + 1

    local positions = { 0.03448, 0.36552, 0.70345 }
    local keys      = { "c1", "c2", "c3" }
    local sides     = { "left", "middle", "right" }
    local squares   = {}

    for i = 1, 3 do
        local sq = C(container, "Frame", {
            Name = "Gradient" .. i, BorderSizePixel = 0,
            BackgroundColor3 = Library._theme[keys[i]],
            Size = UDim2.new(0,36,0,36),
            Position = UDim2.new(positions[i], 0, 0.11111, 0),
        })
        local s = Stroke(sq, accent, 1.4)
        table.insert(self._m.strokes, { s, self._side })

        local hue, open = 0, false
        local pm = C(self._win._gui, "TextButton", {
            Name = "colorpicker", ZIndex = 100001, Visible = false,
            AutoButtonColor = false, Text = "",
            Size = UDim2.fromOffset(180,196), BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(40,40,40),
        })
        C(pm,"Frame",{ZIndex=98,Size=UDim2.fromOffset(186,202),BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(0,0,0),Position=UDim2.fromOffset(-3,-3)})
        C(pm,"Frame",{ZIndex=98,Size=UDim2.fromOffset(182,198),BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(60,60,60),Position=UDim2.fromOffset(-1,-1)})
        local hc=C(pm,"ImageLabel",{ZIndex=101,Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,172,0,172),Image="rbxassetid://4155801252",ScaleType=Enum.ScaleType.Stretch,BackgroundColor3=Color3.new(1,0,0),BorderSizePixel=1,BorderColor3=Color3.fromRGB(0,0,0)})
        local hp=C(pm,"ImageLabel",{ZIndex=102,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,0,0,0),Size=UDim2.new(0,7,0,7),Image="rbxassetid://6885856475"})
        local sel=C(pm,"TextLabel",{ZIndex=101,Position=UDim2.new(0,3,0,181),Size=UDim2.new(0,173,0,10),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=1,BorderColor3=Color3.fromRGB(0,0,0),Text=""})
        C(sel,"UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,0,0)),ColorSequenceKeypoint.new(0.17,Color3.new(1,0,1)),ColorSequenceKeypoint.new(0.33,Color3.new(0,0,1)),ColorSequenceKeypoint.new(0.50,Color3.new(0,1,1)),ColorSequenceKeypoint.new(0.67,Color3.new(0,1,0)),ColorSequenceKeypoint.new(0.83,Color3.new(1,1,0)),ColorSequenceKeypoint.new(1.00,Color3.new(1,0,0))})})
        local sp=C(sel,"Frame",{ZIndex=102,BackgroundColor3=Color3.fromRGB(40,40,40),Position=UDim2.new(0,0,0,0),Size=UDim2.new(0,2,0,10),BorderColor3=Color3.fromRGB(255,255,255),BorderSizePixel=1})

        local key = keys[i]
        local function setColor(c)
            Library._theme[key] = Color3.new(math.clamp(c.R,0,1),math.clamp(c.G,0,1),math.clamp(c.B,0,1))
            sq.BackgroundColor3 = Library._theme[key]
            for _, w in ipairs(Library._windows) do pcall(function() w:_refreshTheme() end) end
            if cfg.OnChange then pcall(cfg.OnChange, Library._theme) end
        end
        local function mxy() local p=UIS:GetMouseLocation(); local g=GS:GetGuiInset(); return p.X,p.Y-g.Y end
        local function rH()
            local mx,my=mxy()
            local x=math.clamp((mx-hc.AbsolutePosition.X)/hc.AbsoluteSize.X,0,1)
            local y=math.clamp((my-hc.AbsolutePosition.Y)/hc.AbsoluteSize.Y,0,1)
            hp:TweenPosition(UDim2.new(math.clamp(x*hc.AbsoluteSize.X,0.5,0.952*hc.AbsoluteSize.X)/hc.AbsoluteSize.X,0,math.clamp(y*hc.AbsoluteSize.Y,0.5,0.885*hc.AbsoluteSize.Y)/hc.AbsoluteSize.Y,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
            setColor(Color3.fromHSV(hue,math.clamp(x*hc.AbsoluteSize.X,0.5,hc.AbsoluteSize.X)/hc.AbsoluteSize.X,1-math.clamp(y*hc.AbsoluteSize.Y,0.5,hc.AbsoluteSize.Y)/hc.AbsoluteSize.Y))
        end
        local function rS()
            local mx=mxy()
            local pos=math.clamp((mx-hc.AbsolutePosition.X)/hc.AbsoluteSize.X,0,1)
            hue=1-pos
            sp:TweenPosition(UDim2.new(pos,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
            hc.BackgroundColor3=Color3.fromHSV(1-pos,1,1)
            local px=(hp.AbsolutePosition.X-hc.AbsolutePosition.X)/hc.AbsoluteSize.X
            local py=(hp.AbsolutePosition.Y-hc.AbsolutePosition.Y)/hc.AbsoluteSize.Y
            setColor(Color3.fromHSV(hue,math.clamp(px*hc.AbsoluteSize.X,0.5,hc.AbsoluteSize.X)/hc.AbsoluteSize.X,1-math.clamp(py*hc.AbsoluteSize.Y,0.5,hc.AbsoluteSize.Y)/hc.AbsoluteSize.Y))
        end
        local dH,dS=false,false
        hc.InputBegan:Connect(function(ii) if ii.UserInputType==Enum.UserInputType.MouseButton1 then dH=true;rH() end end)
        hc.InputEnded:Connect(function(ii) if ii.UserInputType==Enum.UserInputType.MouseButton1 then dH=false end end)
        sel.InputBegan:Connect(function(ii) if ii.UserInputType==Enum.UserInputType.MouseButton1 then dS=true;rS() end end)
        sel.InputEnded:Connect(function(ii) if ii.UserInputType==Enum.UserInputType.MouseButton1 then dS=false end end)
        UIS.InputChanged:Connect(function(ii) if ii.UserInputType~=Enum.UserInputType.MouseMovement then return end; if dH then rH() end; if dS then rS() end end)

        local function posPm()
            local ap,as=sq.AbsolutePosition,sq.AbsoluteSize
            local vp=workspace.CurrentCamera.ViewportSize
            local x=ap.X+as.X+4; if x+186>vp.X then x=ap.X-186 end
            pm.Position=UDim2.fromOffset(x,math.min(ap.Y,vp.Y-200))
        end
        sq.InputBegan:Connect(function(ii)
            if ii.UserInputType==Enum.UserInputType.MouseButton1 then
                open=not open; pm.Visible=open
                if open then posPm()
                    for _,c in ipairs(self._win._gui:GetChildren()) do
                        if c.Name=="colorpicker" and c~=pm then c.Visible=false end
                    end
                end
            elseif ii.UserInputType==Enum.UserInputType.MouseButton2 and i==2 then
                Library._theme.merged = not Library._theme.merged
                for _, w in ipairs(Library._windows) do pcall(function() w:_refreshTheme() end) end
                if cfg.OnChange then pcall(cfg.OnChange, Library._theme) end
            end
        end)
        UIS.InputBegan:Connect(function(ii)
            if ii.UserInputType~=Enum.UserInputType.MouseButton1 or not open then return end
            local mp,pp,ps=ii.Position,pm.AbsolutePosition,pm.AbsoluteSize
            if mp.X<pp.X or mp.X>pp.X+ps.X or mp.Y<pp.Y or mp.Y>pp.Y+ps.Y then
                local ap,as=sq.AbsolutePosition,sq.AbsoluteSize
                if not(mp.X>=ap.X and mp.X<=ap.X+as.X and mp.Y>=ap.Y and mp.Y<=ap.Y+as.Y) then
                    open=false; pm.Visible=false
                end
            end
        end)

        squares[i] = sq
    end
    return { Container = container, Squares = squares }
end

return Library