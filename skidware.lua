-- yes i know its i skidded from ai SHUT UP
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "skidware"
Junkie.identifier = "1124983"
Junkie.provider = "skidware"

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local GET_KEY_URL = "https://jnkie.com/flow/1db27df0-92a7-4a6d-b033-ea7fb002e55b"
local SAVE_FILE = "skidware_key.txt"

-- ─── Games Data ──────────────────────────────────────────────

local currentGameData = nil   -- will hold the selected game's data

local GAMES = {
    {
        name = "criminality",
        picture = "http://www.roblox.com/asset/?id=121327455340651",
        thumbnail = "http://www.roblox.com/asset/?id=129149130979282",
        loadstring = "https://api.jnkie.com/api/v1/luascripts/public/01d5855ef057a47339ba742cd6944c2393a300c07d8ea5d4b7b47b05122c5feb/download",
        gameId = "4588604953",
        lastUpdated = "2026-06-28",
        lastScriptUpdate = "2026-06-29"
    }
}

-- ─── Utility ───────────────────────────────────────────────

local function saveKey(key)
    if writefile then
        pcall(writefile, SAVE_FILE, key)
    end
end

local function loadKey()
    if readfile and isfile and isfile(SAVE_FILE) then
        local ok, data = pcall(readfile, SAVE_FILE)
        if ok and data and #data > 0 then return data end
    end
    return nil
end

local function verifyKey(key)
    if not key or #key == 0 then return false end
    local result = Junkie.check_key(key)
    if result and result.valid then
        return true
    else
        return false
    end
end

-- ─── GUI Setup ─────────────────────────────────────────────

local guiParent
local function getGuiParent()
    if syn and syn.protect_gui then
        return game:GetService("CoreGui")
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end
guiParent = getGuiParent()

-- Destroy existing GUI if re-executed
if guiParent:FindFirstChild("skid") then
    guiParent:FindFirstChild("skid"):Destroy()
end
if getgenv().SkidwareKeyGUI then
    pcall(function() getgenv().SkidwareKeyGUI:Destroy() end)
end

-- ─── Build GUI ─────────────────────────────────────────────

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkidwareKeyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if syn and syn.protect_gui then pcall(syn.protect_gui, ScreenGui) end
ScreenGui.Parent = guiParent
ScreenGui.ScreenInsets = 0
getgenv().SkidwareKeyGUI = ScreenGui

-- ─── Theme Colors ──────────────────────────────────────────

local COLORS = {
    bg = Color3.fromRGB(12, 12, 12),
    bgCard = Color3.fromRGB(22, 22, 22),
    fg = Color3.fromRGB(242, 242, 242),
    muted = Color3.fromRGB(153, 153, 153),
    border = Color3.fromRGB(242, 242, 242),
    accent = Color3.fromRGB(242, 242, 242),
    hover = Color3.fromRGB(16, 16, 16),
    success = Color3.fromRGB(80, 200, 120),
    error = Color3.fromRGB(220, 80, 80),
    warning = Color3.fromRGB(240, 200, 80),
    inputBg = Color3.fromRGB(16, 16, 16),
    placeholder = Color3.fromRGB(242, 242, 242),
}

-- ─── Animations ────────────────────────────────────────────

local function tween(obj, props, duration, style)
    style = style or Enum.EasingStyle.Quad
    local t = TweenService:Create(obj, TweenInfo.new(duration, style, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function tweenIn(obj, duration)
    obj.BackgroundTransparency = 1
    obj.Position = obj.Position + UDim2.new(0, 0, 0, 12)
    tween(obj, { BackgroundTransparency = 0, Position = obj.Position - UDim2.new(0, 0, 0, 12) }, duration or 0.35)
end

-- ─── Overlay ───────────────────────────────────────────────

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.6
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 1
Overlay.Parent = ScreenGui

-- Fade in overlay
Overlay.BackgroundTransparency = 1
tween(Overlay, { BackgroundTransparency = 0.6 }, 0.4)

-- ─── Main Card ─────────────────────────────────────────────

local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 400, 0, 310)
Card.Position = UDim2.new(0.5, -200, 0.5, -155)
Card.BackgroundColor3 = COLORS.bgCard
Card.BorderSizePixel = 0
Card.ZIndex = 2
Card.ClipsDescendants = true
Card.Parent = ScreenGui

-- Card border
local CardStroke = Instance.new("UIStroke")
CardStroke.Color = COLORS.border
CardStroke.Thickness = 1.5
CardStroke.Parent = Card

-- Card shadow (subtle)
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 0, 1, 0)
Shadow.Position = UDim2.new(0, 6, 0, 6)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Shadow.Parent = Card

-- Card entrance animation
Card.Position = UDim2.new(0.5, -200, 0.5, -155) + UDim2.new(0, 0, 0, 20)
Card.BackgroundTransparency = 1
tween(Card, { BackgroundTransparency = 0, Position = UDim2.new(0.5, -200, 0.5, -155) }, 0.4)

-- ─── Drag functionality ────────────────────────────────────

do
    local dragging, dragStart, startPos
    Card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Card.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Card.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ─── Title Bar ─────────────────────────────────────────────

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = COLORS.bg
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 3
TitleBar.Parent = Card

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = COLORS.fg
TitleStroke.Thickness = 1.5
TitleStroke.Parent = TitleBar

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 18, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "skidware"
TitleLabel.TextColor3 = COLORS.fg
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 17
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 4
TitleLabel.Parent = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -17)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = COLORS.muted
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.ZIndex = 4
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    tween(Overlay, { BackgroundTransparency = 1 }, 0.25)
    tween(Card, { BackgroundTransparency = 1, Position = Card.Position + UDim2.new(0, 0, 0, 20) }, 0.3).Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)
CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = COLORS.fg end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = COLORS.muted end)

-- ─── Wavy Divider ──────────────────────────────────────────

-- local WaveContainer = Instance.new("Frame")
-- WaveContainer.Size = UDim2.new(1, 0, 0, 14)
-- WaveContainer.Position = UDim2.new(0, 0, 0, 46)
-- WaveContainer.BackgroundTransparency = 1
-- WaveContainer.ZIndex = 3
-- WaveContainer.Parent = Card

-- -- Build wave from small segments
-- local waveSegments = 40
-- local segmentWidth = 400 / waveSegments
-- local amplitude = 4
-- local frequency = 2.2

-- for i = 0, waveSegments - 1 do
--     local seg = Instance.new("Frame")
--     local x = i * segmentWidth
--     local phase = (i / waveSegments) * math.pi * 2 * frequency
--     local y = 6 + math.sin(phase) * amplitude
--     seg.Size = UDim2.new(0, segmentWidth + 1, 0, 2)
--     seg.Position = UDim2.new(0, x, 0, y)
--     seg.BackgroundColor3 = COLORS.border
--     seg.BackgroundTransparency = 0
--     seg.BorderSizePixel = 0
--     seg.ZIndex = 3
--     seg.Parent = WaveContainer

--     -- Animate each segment with a slight delay
--     task.spawn(function()
--         seg.BackgroundTransparency = 1
--         task.wait(0.02 * (i / waveSegments))
--         tween(seg, { BackgroundTransparency = 0 }, 0.3 + 0.15 * (i / waveSegments))
--     end)
-- end

-- ─── Subtitle ──────────────────────────────────────────────

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -36, 0, 22)
Subtitle.Position = UDim2.new(0, 18, 0, 68)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "enter your script key to continue."
Subtitle.TextColor3 = COLORS.muted
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 13
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 3
Subtitle.Parent = Card

-- ─── Input Box ─────────────────────────────────────────────

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -36, 0, 44)
InputBox.Position = UDim2.new(0, 18, 0, 98)
InputBox.BackgroundColor3 = COLORS.inputBg
InputBox.BorderSizePixel = 0
InputBox.Text = ""
InputBox.PlaceholderText = "skid-xxxx-xxxx-xxxx"
InputBox.TextColor3 = COLORS.fg
InputBox.PlaceholderColor3 = COLORS.placeholder
InputBox.Font = Enum.Font.Code
InputBox.TextSize = 13
InputBox.ClearTextOnFocus = false
InputBox.ZIndex = 3
InputBox.Parent = Card

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(255,255,255)
InputStroke.Thickness = 0.5
InputStroke.Parent = InputBox

-- Input focus glow
local function focusGlow(active)
    if active then
        tween(InputStroke, { Thickness = 0.75, Color = COLORS.fg }, 0.15)
    else
        tween(InputStroke, { Thickness = 0.5, Color = COLORS.border }, 0.15)
    end
end
InputBox.Focused:Connect(function() focusGlow(true) end)
InputBox.FocusLost:Connect(function() focusGlow(false) end)

-- ─── Status Label ──────────────────────────────────────────

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -36, 0, 20)
StatusLabel.Position = UDim2.new(0, 18, 0, 148)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = COLORS.muted
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.ZIndex = 3
StatusLabel.Parent = Card

local statusTween

local function setStatus(msg, isError, isWarning)
    if statusTween then statusTween:Cancel() end
    StatusLabel.Text = msg
    local color = COLORS.muted
    if isError then color = COLORS.error
    elseif isWarning then color = COLORS.warning
    elseif msg:find("✓") or msg:find("✔") then color = COLORS.success
    end
    StatusLabel.TextColor3 = color
    statusTween = tween(StatusLabel, { TextTransparency = 0.3 }, 0.15)
    statusTween.Completed:Connect(function()
        statusTween = tween(StatusLabel, { TextTransparency = 0 }, 0.2)
    end)
end

-- ─── Buttons ───────────────────────────────────────────────

local function makeBracketButton(text, xOffset, width, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width, 0, 40)
    btn.Position = UDim2.new(0, xOffset, 0, yPos)
    btn.BackgroundColor3 = COLORS.bg
    btn.BorderSizePixel = 0
    btn.Text = "[ " .. text .. " ]"
    btn.TextColor3 = COLORS.fg
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.ZIndex = 3
    btn.Parent = Card
    btn.BackgroundTransparency = 0

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.border
    btnStroke.Thickness = 0.25
    btnStroke.Parent = btn

    local hoverTween
    btn.MouseEnter:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = tween(btn, { BackgroundColor3 = COLORS.hover, TextColor3 = COLORS.fg }, 0.15)
        tween(btnStroke, { Thickness = 0.5 }, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = tween(btn, { BackgroundColor3 = COLORS.bg, TextColor3 = COLORS.fg }, 0.15)
        tween(btnStroke, { Thickness = 0.25 }, 0.15)
    end)

    local clickTween
    btn.MouseButton1Down:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = tween(btn, { Position = btn.Position + UDim2.new(0, 0, 0, 2) }, 0.06)
    end)
    btn.MouseButton1Up:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = tween(btn, { Position = btn.Position - UDim2.new(0, 0, 0, 2) }, 0.08)
    end)

    return btn
end

local RedeemBtn = makeBracketButton("redeem key", 18, 176, 178)
local GetKeyBtn = makeBracketButton("get key", 206, 176, 178)

-- ─── Footer ────────────────────────────────────────────────

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -36, 0, 18)
Footer.Position = UDim2.new(0, 18, 0, 280)
Footer.BackgroundTransparency = 1
Footer.Text = "2026 skidware. no rights reserved — cheat responsibly"
Footer.TextColor3 = Color3.fromRGB(200,200,200)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 10
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.ZIndex = 3
Footer.Parent = Card

-- ─── Loader UI (built after key verification) ──────────────

local LoaderContainer = Instance.new("Frame")
LoaderContainer.Size = UDim2.new(1, 0, 1, 0)
LoaderContainer.BackgroundTransparency = 1
LoaderContainer.Visible = false
LoaderContainer.ZIndex = 3
LoaderContainer.Parent = Card

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0.35, -10, 1, -50) -- left side, with margin
LeftPanel.Position = UDim2.new(0, 10, 0, 50)
LeftPanel.BackgroundTransparency = 1
LeftPanel.ZIndex = 3
LeftPanel.Parent = LoaderContainer

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0.65, -20, 1, -50)
RightPanel.Position = UDim2.new(0.35, 10, 0, 50)
RightPanel.BackgroundTransparency = 1
RightPanel.ZIndex = 3
RightPanel.Parent = LoaderContainer

-- Left: Game list (sliding from bottom)
local GameListFrame = Instance.new("ScrollingFrame")
GameListFrame.Size = UDim2.new(1, 0, 1, 0)
GameListFrame.BackgroundTransparency = 1
GameListFrame.BorderSizePixel = 0
GameListFrame.ScrollBarThickness = 4
GameListFrame.ZIndex = 3
GameListFrame.Parent = LeftPanel
GameListFrame.VerticalScrollBarPosition = 1

-- We'll create a single game item for now
local function createGameItem(gameData, index)
    local item = Instance.new("Frame")
    item.Size = UDim2.new(1, -10, 0, 70)
    item.Position = UDim2.new(0, 5, 0, 5 + (index-1)*75)
    item.BackgroundColor3 = COLORS.bg
    item.BorderSizePixel = 0
    item.ZIndex = 3
    item.Parent = GameListFrame

    local itemStroke = Instance.new("UIStroke")
    itemStroke.Color = COLORS.muted
    itemStroke.Thickness = 1
    itemStroke.Parent = item

    -- Thumbnail
    local thumb = Instance.new("ImageLabel")
    thumb.Size = UDim2.new(0, 60, 0, 60)
    thumb.Position = UDim2.new(0, 5, 0.5, -30)
    thumb.BackgroundTransparency = 1
    thumb.Image = gameData.thumbnail
    thumb.ZIndex = 3
    thumb.Parent = item

    local thumbStroke = Instance.new("UIStroke")
    thumbStroke.Color = COLORS.muted
    thumbStroke.Thickness = 1
    thumbStroke.Transparency = 0.8
    thumbStroke.Parent = thumb

    -- Game name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -80, 0, 22)
    nameLabel.Position = UDim2.new(0, 70, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = gameData.name:upper()
    nameLabel.TextColor3 = COLORS.fg
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 3
    nameLabel.Parent = item

    -- Last updated (small)
    local updateLabel = Instance.new("TextLabel")
    updateLabel.Size = UDim2.new(1, -80, 0, 16)
    updateLabel.Position = UDim2.new(0, 70, 0, 32)
    updateLabel.BackgroundTransparency = 1
    updateLabel.Text = "EXPECT BUGS!"
    updateLabel.TextColor3 = COLORS.muted
    updateLabel.Font = Enum.Font.Gotham
    updateLabel.TextSize = 10
    updateLabel.TextXAlignment = Enum.TextXAlignment.Left
    updateLabel.ZIndex = 3
    updateLabel.Parent = item

    -- Select button (just visual for now)
    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(0, 60, 0, 60)
    selectBtn.Position = UDim2.new(0.70, 1, 0.5, -30)
    selectBtn.BackgroundColor3 = COLORS.bg
    selectBtn.BorderSizePixel = 0
    selectBtn.Text = "[ ]"
    selectBtn.TextColor3 = COLORS.fg
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.TextSize = 50
    selectBtn.ZIndex = 4
    selectBtn.Parent = item
    selectBtn.TextYAlignment = 0

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.border
    btnStroke.Thickness = 0.25
    btnStroke.Parent = selectBtn

    selectBtn.MouseButton1Click:Connect(function()
        -- When a game is selected, update the right panel
        updateRightPanel(gameData)
    end)

    return item
end

-- Build game items
for i, game in ipairs(GAMES) do
    createGameItem(game, i)
end

-- Right Panel Details (initially empty)
local rightContent = Instance.new("Frame")
rightContent.Size = UDim2.new(1, 0, 1, 0)
rightContent.BackgroundTransparency = 1
rightContent.ZIndex = 3
rightContent.Parent = RightPanel

-- We'll populate these later
local detailTitle, detailImage, detailUpdate, detailScriptUpdate, executeBtn

function updateRightPanel(gameData)

    currentGameData = gameData   -- store for use later
    -- Clear previous content
    for _, child in ipairs(rightContent:GetChildren()) do
        child:Destroy()
    end

    -- Game image (large)
    detailImage = Instance.new("ImageLabel")
    detailImage.Size = UDim2.new(0.8, 0, 0, 175)
    detailImage.Position = UDim2.new(0.1, 0, 0, 10)
    detailImage.BackgroundTransparency = 1
    detailImage.Image = gameData.picture
    detailImage.ZIndex = 3
    detailImage.Parent = rightContent

    local detailStroke = Instance.new("UIStroke")
    detailStroke.Color = COLORS.border
    detailStroke.Thickness = 1
    detailStroke.Parent = detailImage

    -- Game title
    detailTitle = Instance.new("TextLabel")
    detailTitle.Size = UDim2.new(1, -20, 0, 30)
    detailTitle.Position = UDim2.new(0, 10, 0, 180)
    detailTitle.BackgroundTransparency = 1
    detailTitle.Text = gameData.name:upper()
    detailTitle.TextColor3 = COLORS.fg
    detailTitle.Font = Enum.Font.GothamBold
    detailTitle.TextSize = 20
    detailTitle.TextXAlignment = Enum.TextXAlignment.Center
    detailTitle.ZIndex = 3
    detailTitle.Parent = rightContent

    -- Last updated
    detailUpdate = Instance.new("TextLabel")
    detailUpdate.Size = UDim2.new(1, -20, 0, 18)
    detailUpdate.Position = UDim2.new(0, 10, 0, 205)
    detailUpdate.BackgroundTransparency = 1
    detailUpdate.Text = "game updated: " .. gameData.lastUpdated
    detailUpdate.TextColor3 = COLORS.muted
    detailUpdate.Font = Enum.Font.Gotham
    detailUpdate.TextSize = 12
    detailUpdate.TextXAlignment = Enum.TextXAlignment.Left
    detailUpdate.ZIndex = 3
    detailUpdate.Parent = rightContent

    -- Script update
    detailScriptUpdate = Instance.new("TextLabel")
    detailScriptUpdate.Size = UDim2.new(1, -20, 0, 18)
    detailScriptUpdate.Position = UDim2.new(0, 10, 0, 205)
    detailScriptUpdate.BackgroundTransparency = 1
    detailScriptUpdate.Text = "script updated: " .. gameData.lastScriptUpdate
    detailScriptUpdate.TextColor3 = COLORS.muted
    detailScriptUpdate.Font = Enum.Font.Gotham
    detailScriptUpdate.TextSize = 12
    detailScriptUpdate.TextXAlignment = Enum.TextXAlignment.Right
    detailScriptUpdate.ZIndex = 3
    detailScriptUpdate.Parent = rightContent

    -- Execute button (slides from top)
    executeBtn = Instance.new("TextButton")
    executeBtn.Size = UDim2.new(0, 140, 0, 40)
    executeBtn.Position = UDim2.new(0.5, -70, 0, 325)
    executeBtn.BackgroundColor3 = COLORS.bg
    executeBtn.BorderSizePixel = 0
    executeBtn.Text = "[ execute ]"
    executeBtn.TextColor3 = COLORS.fg
    executeBtn.Font = Enum.Font.GothamBold
    executeBtn.TextSize = 16
    executeBtn.ZIndex = 4
    executeBtn.Parent = rightContent

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.border
    btnStroke.Thickness = 0
    btnStroke.Parent = executeBtn

    -- Hover for execute
    executeBtn.MouseEnter:Connect(function()
        tween(executeBtn, { BackgroundColor3 = COLORS.bg }, 0.15)
        tween(btnStroke, { Thickness = 0.25 }, 0.15)
    end)
    executeBtn.MouseLeave:Connect(function()
        tween(executeBtn, { BackgroundColor3 = COLORS.bg }, 0.15)
        tween(btnStroke, { Thickness = 0 }, 0.15)
    end)

    -- Execute action
    executeBtn.MouseButton1Click:Connect(function()
        -- 1. Fade out all children of the ScreenGui
        local fadeDuration = 1.5
        for _, child in ipairs(ScreenGui:GetChildren()) do
            if child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                local props = { BackgroundTransparency = 1 }
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    props.TextTransparency = 1
                end
                if child:IsA("ImageLabel") then
                    props.ImageTransparency = 1
                end
                tween(child, props, fadeDuration)
            end
        end

        -- 2. After fade completes, destroy the GUI
        task.wait(fadeDuration + 0.1)   -- give a tiny buffer for tweens to finish
        ScreenGui:Destroy()

        -- 3. Wait 1.5 more seconds
        task.wait(1.5)

        -- 4. Store the key for Jnkie's external loader
        getgenv().SCRIPT_KEY = getgenv().SkidwareKey

        -- 5. Load the selected game's script
        if currentGameData and currentGameData.loadstring then
            local scriptUrl = currentGameData.loadstring
            loadstring(game:HttpGet(scriptUrl))()
        else
            warn("No loadstring URL found for the selected game.")
        end
    end)

    -- Animation: slide from top (initial position above)
    --executeBtn.Position = UDim2.new(0.5, -70, 0, 325) + UDim2.new(0, 0, 0, 120)
    --executeBtn.BackgroundTransparency = 1
    --tween(executeBtn, { BackgroundTransparency = 0, Position = UDim2.new(0.5, -70, 0, 325) }, 0.8)
end

-- Select first game by default
if #GAMES > 0 then
    updateRightPanel(GAMES[1])
end

-- Initially hide LoaderContainer
LoaderContainer.Visible = false

-- ─── Transition on Key Verified ─────────────────────────────

local function transitionToLoader()
    -- Elements to fade out (key UI)
    local keyElements = {
        TitleBar, --TitleLabel, --CloseBtn, 
        Subtitle, InputBox, --WaveContainer,
        StatusLabel, RedeemBtn, GetKeyBtn, Footer
    }

    -- Fade out each element
    for _, el in ipairs(keyElements) do
        if el then
            local props = { BackgroundTransparency = 1 }
            -- Only text objects have TextTransparency
            if el:IsA("TextLabel") or el:IsA("TextButton") or el:IsA("TextBox") then
                props.TextTransparency = 1
                InputBox:Destroy()
            end
            if el:IsA("TextButton") then
                el:destroy()
            end
            
            tween(el, props, 0.3)
        end
    end

    -- -- Fade out the wave segments (they are children of WaveContainer)
    -- if WaveContainer then
    --     for _, seg in ipairs(WaveContainer:GetChildren()) do
    --         if seg:IsA("Frame") then
    --             tween(seg, { BackgroundTransparency = 1 }, 0.3)
    --         end
    --     end
    -- end

    -- Resize card horizontally (stretch)
    local targetWidth = 700
    local targetHeight = 450
    local newPos = UDim2.new(0.5, -targetWidth/2, 0.5, -targetHeight/2)
    tween(Card, { Size = UDim2.new(0, targetWidth, 0, targetHeight), Position = newPos }, 0.6)

    -- After resize, show loader container and animate panels
    task.wait(0.5) -- wait for resize to finish
    LoaderContainer.Visible = true

    -- Left panel slides from bottom
    LeftPanel.Position = UDim2.new(0, 10, 0, 50) + UDim2.new(0, 0, 0, 50)
    LeftPanel.BackgroundTransparency = 1
    tween(LeftPanel, { BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 50) }, 0.4)

    -- Right panel slides from top
    RightPanel.Position = UDim2.new(0.35, 10, 0, 50) - UDim2.new(0, 0, 0, 50)
    RightPanel.BackgroundTransparency = 1
    tween(RightPanel, { BackgroundTransparency = 1, Position = UDim2.new(0.35, 10, 0, 50) }, 0.4)
end

-- ─── onKeyVerified (modified) ──────────────────────────────

local function onKeyVerified(key)
    saveKey(key)
    getgenv().SkidwareKeyValid = true
    getgenv().SkidwareKey = key
    setStatus("✓ key valid — loading skidware...", false)

    -- Success animation on card
    tween(CardStroke, { Color = COLORS.success }, 0.5)
    task.wait(0.6)
    tween(CardStroke, { Color = COLORS.border }, 0.5)

    task.delay(1.0, function()
        transitionToLoader()
    end)
end

-- ─── Redeem Button Logic ───────────────────────────────────

RedeemBtn.MouseButton1Click:Connect(function()
    local key = InputBox.Text:match("^%s*(.-)%s*$")
    if not key or #key == 0 then
        setStatus("⚠ please enter a key.", false, true)
        return
    end
    setStatus("verifying...", false)
    RedeemBtn.Active = false
    tween(RedeemBtn, { TextTransparency = 0.4 }, 0.2)

    task.spawn(function()
        local valid = verifyKey(key)
        RedeemBtn.Active = true
        tween(RedeemBtn, { TextTransparency = 0 }, 0.2)

        if valid then
            onKeyVerified(key)
        else
            setStatus("✗ invalid or expired key.", true)
            if isfile and isfile(SAVE_FILE) then
                pcall(delfile, SAVE_FILE)
            end
            getgenv().SkidwareKeyValid = false
            -- Shake input box
            local origPos = InputBox.Position
            tween(InputBox, { Position = origPos + UDim2.new(0, 6, 0, 0) }, 0.06).Completed:Connect(function()
                tween(InputBox, { Position = origPos - UDim2.new(0, 6, 0, 0) }, 0.06).Completed:Connect(function()
                    tween(InputBox, { Position = origPos + UDim2.new(0, 3, 0, 0) }, 0.05).Completed:Connect(function()
                        tween(InputBox, { Position = origPos }, 0.06)
                    end)
                end)
            end)
            tween(InputStroke, { Color = COLORS.error }, 0.3).Completed:Connect(function()
                tween(InputStroke, { Color = COLORS.border }, 0.4)
            end)
        end
    end)
end)

-- Get key button
GetKeyBtn.MouseButton1Click:Connect(function()
    setStatus("opening key page...", false)
    if setclipboard then
        setclipboard(GET_KEY_URL)
        setStatus("✓ url copied to clipboard!", false)
    end
    if syn and syn.open_url then
        syn.open_url(GET_KEY_URL)
    end
end)

-- ─── Auto-load saved key ────────────────────────────────────

task.spawn(function()
    local saved = loadKey()
    if saved then
        InputBox.Text = saved
        setStatus("saved key found — verifying...", false)
        local valid = verifyKey(saved)
        if valid then
            onKeyVerified(saved)
        else
            setStatus("✗ saved key expired. get a new one.", true)
            pcall(delfile, SAVE_FILE)
            getgenv().SkidwareKeyValid = false
        end
    end
end)

-- ─── Enter key support ─────────────────────────────────────

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
        if ScreenGui and ScreenGui.Parent then
            RedeemBtn.MouseButton1Click:Fire()
        end
    end
end)
