-- Services
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local GetChildren = game.GetChildren
local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local FindFirstChild = game.FindFirstChild
local RenderStepped = RunService.RenderStepped
local GuiInset = GuiService.GetGuiInset
local GetMouseLocation = UserInputService.GetMouseLocation
local Mouse = LocalPlayer:GetMouse()

local resume = coroutine.resume
local create = coroutine.create

local espCam = workspace.CurrentCamera
local espPlrs = game:GetService("Players")
local espPlr = espPlrs.LocalPlayer

-- Drag state (declared at top level so all sections can see them)
local draggingFakeSpeed = false
local draggingRecoil = false
local draggingSmooth = false

--[=[
 d888b  db    db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88    88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88    88    88            odD'      88      88    88 88ooo88 
88  ooo 88    88    88          .88'        88      88    88 88~~~88 
88. ~8~ 88b  d88   .88.        j88.         88booo. 88b  d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

-- Instances: 408 | Scripts: 0 | Modules: 0 | Tags: 0
local G2L = {}

-- StarterGui.baggyware
local guiParent = nil

-- 1. Try Hidden UI (gethui)
if typeof(gethui) == "function" then
    local huiSuccess, hui = pcall(gethui)
    if huiSuccess and hui then
        guiParent = hui
    end
end

-- 2. Fallback to CoreGui with write-access testing
if not guiParent then
    local coreGuiSuccess = pcall(function()
        local coreGui = game:GetService("CoreGui")
        -- Your brilliant write-access test frame
        local t = Instance.new("Frame", coreGui)
        t:Destroy()

        guiParent = coreGui
    end)
end

-- 3. Ultimate fallback to PlayerGui
if not guiParent then
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer or players.PlayerAdded:Wait()
    guiParent = localPlayer:WaitForChild("PlayerGui", 5)
end

local function buildUI()
    G2L["1"] = Instance.new("ScreenGui", guiParent)
    G2L["1"]["Name"] = [[baggyware]]
    G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
    G2L["1"]["ResetOnSpawn"] = false

    -- StarterGui.baggyware.main
    G2L["2"] = Instance.new("Frame", G2L["1"])
    G2L["2"]["BorderSizePixel"] = 0
    G2L["2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["2"]["Size"] = UDim2.new(0, 450, 0, 350)
    G2L["2"]["Position"] = UDim2.new(0.15534, -39, 0.13889, -15)
    G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["2"]["Name"] = [[main]]

    -- StarterGui.baggyware.main.uig
    G2L["3"] = Instance.new("UIGradient", G2L["2"])
    G2L["3"]["Name"] = [[uig]]
    G2L["3"]["Color"] = ColorSequence.new({
        ColorSequenceKeypoint.new(0.000, Color3.fromRGB(34, 85, 114)),
        ColorSequenceKeypoint.new(0.330, Color3.fromRGB(34, 85, 114)),
        ColorSequenceKeypoint.new(0.663, Color3.fromRGB(34, 103, 89)),
        ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 103, 89)),
    })

    -- StarterGui.baggyware.main.buttons
    G2L["4"] = Instance.new("Frame", G2L["2"])
    G2L["4"]["BorderSizePixel"] = 0
    G2L["4"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["4"]["Size"] = UDim2.new(0, 442, 0, 20)
    G2L["4"]["Position"] = UDim2.new(0.00889, 0, 0.92899, 0)
    G2L["4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["4"]["Name"] = [[buttons]]
    G2L["4"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.buttons.aimbot
    G2L["5"] = Instance.new("TextButton", G2L["4"])
    G2L["5"]["TextWrapped"] = true
    G2L["5"]["TextStrokeTransparency"] = 0
    G2L["5"]["BorderSizePixel"] = 0
    G2L["5"]["TextSize"] = 14
    G2L["5"]["TextScaled"] = true
    G2L["5"]["TextColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["5"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["5"]["BackgroundTransparency"] = 1
    G2L["5"]["Size"] = UDim2.new(0, 147, 0, 20)
    G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["5"]["Text"] = [[aimbot]]
    G2L["5"]["Name"] = [[aimbot]]

    -- StarterGui.baggyware.main.buttons.misc
    G2L["6"] = Instance.new("TextButton", G2L["4"])
    G2L["6"]["TextWrapped"] = true
    G2L["6"]["TextStrokeTransparency"] = 0
    G2L["6"]["BorderSizePixel"] = 0
    G2L["6"]["TextSize"] = 14
    G2L["6"]["TextScaled"] = true
    G2L["6"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["6"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["6"]["BackgroundTransparency"] = 1
    G2L["6"]["Size"] = UDim2.new(0, 147, 0, 20)
    G2L["6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["6"]["Text"] = [[misc]]
    G2L["6"]["Name"] = [[misc]]
    G2L["6"]["Position"] = UDim2.new(0.66516, 0, 0, 0)

    -- StarterGui.baggyware.main.buttons.visuals
    G2L["7"] = Instance.new("TextButton", G2L["4"])
    G2L["7"]["TextWrapped"] = true
    G2L["7"]["TextStrokeTransparency"] = 0
    G2L["7"]["BorderSizePixel"] = 0
    G2L["7"]["TextSize"] = 14
    G2L["7"]["TextScaled"] = true
    G2L["7"]["TextColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["7"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["7"]["BackgroundTransparency"] = 1
    G2L["7"]["Size"] = UDim2.new(0, 147, 0, 20)
    G2L["7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["7"]["Text"] = [[visuals]]
    G2L["7"]["Name"] = [[visuals]]
    G2L["7"]["Position"] = UDim2.new(0.33258, 0, 0, 0)

    -- StarterGui.baggyware.main.windows
    G2L["8"] = Instance.new("Folder", G2L["2"])
    G2L["8"]["Name"] = [[windows]]

    -- StarterGui.baggyware.main.windows.miscframe
    G2L["9"] = Instance.new("Frame", G2L["8"])
    G2L["9"]["BorderSizePixel"] = 0
    G2L["9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["9"]["Size"] = UDim2.new(0, 450, 0, 350)
    G2L["9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["9"]["Name"] = [[miscframe]]
    G2L["9"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.theme
    G2L["a"] = Instance.new("Frame", G2L["9"])
    G2L["a"]["BorderSizePixel"] = 0
    G2L["a"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a"]["Size"] = UDim2.new(0, 143, 0, 146)
    G2L["a"]["Position"] = UDim2.new(0.67111, 0, 0.49938, 0)
    G2L["a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a"]["Name"] = [[theme]]
    G2L["a"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.miscframe.theme.label
    G2L["b"] = Instance.new("TextLabel", G2L["a"])
    G2L["b"]["TextStrokeTransparency"] = 0
    G2L["b"]["BorderSizePixel"] = 0
    G2L["b"]["TextSize"] = 20
    G2L["b"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["b"]["SelectionOrder"] = 1
    G2L["b"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["b"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["b"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["b"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b"]["Text"] = [[  theme]]
    G2L["b"]["LayoutOrder"] = -1
    G2L["b"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.miscframe.theme.UIListLayout
    G2L["c"] = Instance.new("UIListLayout", G2L["a"])
    G2L["c"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.miscframe.theme.theme
    G2L["d"] = Instance.new("Frame", G2L["a"])
    G2L["d"]["BorderSizePixel"] = 0
    G2L["d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["d"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d"]["Name"] = [[theme]]
    G2L["d"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.theme.theme.text
    G2L["e"] = Instance.new("TextLabel", G2L["d"])
    G2L["e"]["TextStrokeTransparency"] = 0
    G2L["e"]["BorderSizePixel"] = 0
    G2L["e"]["TextSize"] = 18
    G2L["e"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["e"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["e"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["e"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["e"]["BackgroundTransparency"] = 1
    G2L["e"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e"]["Text"] = [[theme]]
    G2L["e"]["Name"] = [[text]]
    G2L["e"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.theme.theme.theme
    G2L["f"] = Instance.new("TextLabel", G2L["d"])
    G2L["f"]["TextStrokeTransparency"] = 0
    G2L["f"]["BorderSizePixel"] = 0
    G2L["f"]["TextSize"] = 18
    G2L["f"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["f"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f"]["BackgroundTransparency"] = 0.65
    G2L["f"]["Size"] = UDim2.new(0, 48, 0, 10)
    G2L["f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f"]["Text"] = [[nil]]
    G2L["f"]["Name"] = [[theme]]
    G2L["f"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.theme.theme.theme.UIStroke
    G2L["10"] = Instance.new("UIStroke", G2L["f"])
    G2L["10"]["Thickness"] = 1.4
    G2L["10"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["10"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["10"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.theme.savetheme
    G2L["11"] = Instance.new("Frame", G2L["a"])
    G2L["11"]["BorderSizePixel"] = 0
    G2L["11"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["11"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["11"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["11"]["Name"] = [[savetheme]]
    G2L["11"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.theme.savetheme.saveconfig
    G2L["12"] = Instance.new("TextLabel", G2L["11"])
    G2L["12"]["TextStrokeTransparency"] = 0
    G2L["12"]["BorderSizePixel"] = 0
    G2L["12"]["TextSize"] = 18
    G2L["12"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["12"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["12"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["12"]["BackgroundTransparency"] = 0.65
    G2L["12"]["Size"] = UDim2.new(0, 133, 0, 15)
    G2L["12"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["12"]["Text"] = [[save theme]]
    G2L["12"]["Name"] = [[savetheme]]
    G2L["12"]["Position"] = UDim2.new(0.03448, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.theme.savetheme.saveconfig.UIStroke
    G2L["13"] = Instance.new("UIStroke", G2L["12"])
    G2L["13"]["Thickness"] = 1.4
    G2L["13"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["13"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["13"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.theme.loadtheme
    G2L["14"] = Instance.new("Frame", G2L["a"])
    G2L["14"]["BorderSizePixel"] = 0
    G2L["14"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["14"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["14"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["14"]["Name"] = [[loadtheme]]
    G2L["14"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.theme.loadtheme.loadconfig
    G2L["15"] = Instance.new("TextLabel", G2L["14"])
    G2L["15"]["TextStrokeTransparency"] = 0
    G2L["15"]["BorderSizePixel"] = 0
    G2L["15"]["TextSize"] = 18
    G2L["15"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["15"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["15"]["BackgroundTransparency"] = 0.65
    G2L["15"]["Size"] = UDim2.new(0, 133, 0, 15)
    G2L["15"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15"]["Text"] = [[load theme]]
    G2L["15"]["Name"] = [[loadtheme]]
    G2L["15"]["Position"] = UDim2.new(0.03448, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.theme.loadtheme.loadconfig.UIStroke
    G2L["16"] = Instance.new("UIStroke", G2L["15"])
    G2L["16"]["Thickness"] = 1.4
    G2L["16"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["16"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["16"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme
    G2L["17"] = Instance.new("Frame", G2L["a"])
    G2L["17"]["BorderSizePixel"] = 0
    G2L["17"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["17"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["17"]["Name"] = [[randomtheme]]
    G2L["17"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme.saveconfig
    G2L["18"] = Instance.new("TextLabel", G2L["17"])
    G2L["18"]["TextStrokeTransparency"] = 0
    G2L["18"]["BorderSizePixel"] = 0
    G2L["18"]["TextSize"] = 18
    G2L["18"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["18"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["18"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["18"]["BackgroundTransparency"] = 0.65
    G2L["18"]["Size"] = UDim2.new(0, 133, 0, 15)
    G2L["18"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["18"]["Text"] = [[randomize theme]]
    G2L["18"]["Name"] = [[randomizetheme]]
    G2L["18"]["Position"] = UDim2.new(0.03448, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme.saveconfig.UIStroke
    G2L["19"] = Instance.new("UIStroke", G2L["18"])
    G2L["19"]["Thickness"] = 1.4
    G2L["19"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["19"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["19"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme
    G2L["1a"] = Instance.new("Frame", G2L["a"])
    G2L["1a"]["BorderSizePixel"] = 0
    G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["1a"]["Size"] = UDim2.new(0, 145, 0, 45)
    G2L["1a"]["Position"] = UDim2.new(0, 0, 0.68493, 0)
    G2L["1a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["1a"]["Name"] = [[gradientpicker]]
    G2L["1a"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme.Gradient1
    G2L["1b"] = Instance.new("Frame", G2L["1a"])
    G2L["1b"]["BorderSizePixel"] = 0
    G2L["1b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["1b"]["Size"] = UDim2.new(0, 36, 0, 36)
    G2L["1b"]["Position"] = UDim2.new(0.03448, 0, 0.11111, 0)
    G2L["1b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["1b"]["Name"] = [[Gradient1]]

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme.Gradient1.UIStroke
    G2L["1c"] = Instance.new("UIStroke", G2L["1b"])
    G2L["1c"]["Thickness"] = 1.4
    G2L["1c"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["1c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["1c"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme.Gradient2
    G2L["1d"] = Instance.new("Frame", G2L["1a"])
    G2L["1d"]["BorderSizePixel"] = 0
    G2L["1d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["1d"]["Size"] = UDim2.new(0, 36, 0, 36)
    G2L["1d"]["Position"] = UDim2.new(0.36552, 0, 0.11111, 0)
    G2L["1d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["1d"]["Name"] = [[Gradient2]]

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme.Gradient2.UIStroke
    G2L["1e"] = Instance.new("UIStroke", G2L["1d"])
    G2L["1e"]["Thickness"] = 1.4
    G2L["1e"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["1e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["1e"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme.Gradient2
    G2L["1f"] = Instance.new("Frame", G2L["1a"])
    G2L["1f"]["BorderSizePixel"] = 0
    G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["1f"]["Size"] = UDim2.new(0, 36, 0, 36)
    G2L["1f"]["Position"] = UDim2.new(0.70345, 0, 0.11111, 0)
    G2L["1f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["1f"]["Name"] = [[Gradient2]]

    -- StarterGui.baggyware.main.windows.miscframe.theme.randomtheme.Gradient2.UIStroke
    G2L["20"] = Instance.new("UIStroke", G2L["1f"])
    G2L["20"]["Thickness"] = 1.4
    G2L["20"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["20"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["20"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.whitelist
    G2L["21"] = Instance.new("Frame", G2L["9"])
    G2L["21"]["BorderSizePixel"] = 0
    G2L["21"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["21"]["Size"] = UDim2.new(0, 145, 0, 146)
    G2L["21"]["Position"] = UDim2.new(0.00889, 0, 0.49938, 0)
    G2L["21"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["21"]["Name"] = [[whitelist]]
    G2L["21"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.miscframe.whitelist.UIListLayout
    G2L["22"] = Instance.new("UIListLayout", G2L["21"])
    G2L["22"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.miscframe.whitelist.label
    G2L["23"] = Instance.new("TextLabel", G2L["21"])
    G2L["23"]["TextStrokeTransparency"] = 0
    G2L["23"]["BorderSizePixel"] = 0
    G2L["23"]["TextSize"] = 20
    G2L["23"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["23"]["SelectionOrder"] = 1
    G2L["23"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["23"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["23"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["23"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["23"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["23"]["Text"] = [[  whitelist]]
    G2L["23"]["LayoutOrder"] = -1
    G2L["23"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.miscframe.whitelist.sf
    G2L["24"] = Instance.new("ScrollingFrame", G2L["21"])
    G2L["24"]["Active"] = true
    G2L["24"]["BorderSizePixel"] = 0
    G2L["24"]["Name"] = [[sf]]
    G2L["24"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41)
    G2L["24"]["VerticalScrollBarPosition"] = Enum.VerticalScrollBarPosition.Left
    G2L["24"]["Size"] = UDim2.new(0, 137, 0, 112)
    G2L["24"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["24"]["Position"] = UDim2.new(0.02759, 0, 0.16901, 0)
    G2L["24"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["24"]["ScrollBarThickness"] = 3

    -- StarterGui.baggyware.main.windows.miscframe.whitelist.sf.player
    G2L["25"] = Instance.new("TextButton", G2L["24"])
    G2L["25"]["TextWrapped"] = true
    G2L["25"]["TextStrokeTransparency"] = 0
    G2L["25"]["BorderSizePixel"] = 0
    G2L["25"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["25"]["TextSize"] = 14
    G2L["25"]["TextScaled"] = true
    G2L["25"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["25"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["25"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    G2L["25"]["BackgroundTransparency"] = 1
    G2L["25"]["Size"] = UDim2.new(0, 137, 0, 20)
    G2L["25"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["25"]["Text"] = [[   DisplayName (@Username)]]
    G2L["25"]["Name"] = [[player]]

    -- StarterGui.baggyware.main.windows.miscframe.whitelist.sf.UIListLayout
    G2L["26"] = Instance.new("UIListLayout", G2L["24"])
    G2L["26"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.miscframe.whitelist.sf.UIStroke
    G2L["27"] = Instance.new("UIStroke", G2L["24"])
    G2L["27"]["Thickness"] = 1.5
    G2L["27"]["Color"] = Color3.fromRGB(34, 85, 114)
    G2L["27"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.misc
    G2L["28"] = Instance.new("Frame", G2L["9"])
    G2L["28"]["BorderSizePixel"] = 0
    G2L["28"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["28"]["Size"] = UDim2.new(0, 145, 0, 142)
    G2L["28"]["Position"] = UDim2.new(0.00889, 0, 0.08, 0)
    G2L["28"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["28"]["Name"] = [[misc]]
    G2L["28"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.miscframe.misc.UIListLayout
    G2L["29"] = Instance.new("UIListLayout", G2L["28"])
    G2L["29"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.miscframe.misc.label
    G2L["2a"] = Instance.new("TextLabel", G2L["28"])
    G2L["2a"]["TextStrokeTransparency"] = 0
    G2L["2a"]["BorderSizePixel"] = 0
    G2L["2a"]["TextSize"] = 20
    G2L["2a"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["2a"]["SelectionOrder"] = 1
    G2L["2a"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["2a"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["2a"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["2a"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["2a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["2a"]["Text"] = [[  misc]]
    G2L["2a"]["LayoutOrder"] = -1
    G2L["2a"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.miscframe.misc.fullbright
    G2L["2b"] = Instance.new("Frame", G2L["28"])
    G2L["2b"]["BorderSizePixel"] = 0
    G2L["2b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["2b"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["2b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["2b"]["Name"] = [[fullbright]]
    G2L["2b"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.misc.fullbright.text
    G2L["2c"] = Instance.new("TextLabel", G2L["2b"])
    G2L["2c"]["TextStrokeTransparency"] = 0
    G2L["2c"]["BorderSizePixel"] = 0
    G2L["2c"]["TextSize"] = 18
    G2L["2c"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["2c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["2c"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["2c"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["2c"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["2c"]["BackgroundTransparency"] = 1
    G2L["2c"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["2c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["2c"]["Text"] = [[fullbright]]
    G2L["2c"]["Name"] = [[text]]
    G2L["2c"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.misc.fullbright.button
    G2L["2d"] = Instance.new("Frame", G2L["2b"])
    G2L["2d"]["BorderSizePixel"] = 0
    G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["2d"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["2d"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["2d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["2d"]["Name"] = [[button]]
    G2L["2d"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.misc.fullbright.button.UIStroke
    G2L["2e"] = Instance.new("UIStroke", G2L["2d"])
    G2L["2e"]["Thickness"] = 1.3
    G2L["2e"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["2e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["2e"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.misc.fullbright.hotkey
    G2L["2f"] = Instance.new("TextLabel", G2L["2b"])
    G2L["2f"]["TextStrokeTransparency"] = 0
    G2L["2f"]["BorderSizePixel"] = 0
    G2L["2f"]["TextSize"] = 18
    G2L["2f"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["2f"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["2f"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["2f"]["BackgroundTransparency"] = 0.65
    G2L["2f"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["2f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["2f"]["Text"] = [[nil]]
    G2L["2f"]["Name"] = [[hotkey]]
    G2L["2f"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.misc.fullbright.hotkey.UIStroke
    G2L["30"] = Instance.new("UIStroke", G2L["2f"])
    G2L["30"]["Thickness"] = 1.4
    G2L["30"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["30"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["30"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.misc.freecam
    G2L["31"] = Instance.new("Frame", G2L["28"])
    G2L["31"]["BorderSizePixel"] = 0
    G2L["31"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["31"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["31"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["31"]["Name"] = [[freecam]]
    G2L["31"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.misc.freecam.text
    G2L["32"] = Instance.new("TextLabel", G2L["31"])
    G2L["32"]["TextStrokeTransparency"] = 0
    G2L["32"]["BorderSizePixel"] = 0
    G2L["32"]["TextSize"] = 18
    G2L["32"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["32"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["32"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["32"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["32"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["32"]["BackgroundTransparency"] = 1
    G2L["32"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["32"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["32"]["Text"] = [[freecam]]
    G2L["32"]["Name"] = [[text]]
    G2L["32"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.misc.freecam.button
    G2L["33"] = Instance.new("Frame", G2L["31"])
    G2L["33"]["BorderSizePixel"] = 0
    G2L["33"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["33"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["33"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["33"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["33"]["Name"] = [[button]]
    G2L["33"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.misc.freecam.button.UIStroke
    G2L["34"] = Instance.new("UIStroke", G2L["33"])
    G2L["34"]["Thickness"] = 1.3
    G2L["34"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["34"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["34"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.misc.freecam.hotkey
    G2L["35"] = Instance.new("TextLabel", G2L["31"])
    G2L["35"]["TextStrokeTransparency"] = 0
    G2L["35"]["BorderSizePixel"] = 0
    G2L["35"]["TextSize"] = 18
    G2L["35"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["35"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["35"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["35"]["BackgroundTransparency"] = 0.65
    G2L["35"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["35"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["35"]["Text"] = [[nil]]
    G2L["35"]["Name"] = [[hotkey]]
    G2L["35"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.misc.freecam.hotkey.UIStroke
    G2L["36"] = Instance.new("UIStroke", G2L["35"])
    G2L["36"]["Thickness"] = 1.4
    G2L["36"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["36"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["36"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement
    G2L["37"] = Instance.new("Frame", G2L["9"])
    G2L["37"]["BorderSizePixel"] = 0
    G2L["37"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["37"]["Size"] = UDim2.new(0, 145, 0, 292)
    G2L["37"]["Position"] = UDim2.new(0.34, 0, 0.08, 0)
    G2L["37"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["37"]["Name"] = [[movement]]
    G2L["37"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.miscframe.movement.label
    G2L["38"] = Instance.new("TextLabel", G2L["37"])
    G2L["38"]["TextStrokeTransparency"] = 0
    G2L["38"]["BorderSizePixel"] = 0
    G2L["38"]["TextSize"] = 20
    G2L["38"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["38"]["SelectionOrder"] = 1
    G2L["38"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["38"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["38"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["38"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["38"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["38"]["Text"] = [[  movement]]
    G2L["38"]["LayoutOrder"] = -1
    G2L["38"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.miscframe.movement.UIListLayout
    G2L["39"] = Instance.new("UIListLayout", G2L["37"])
    G2L["39"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.miscframe.movement.bhop
    G2L["3a"] = Instance.new("Frame", G2L["37"])
    G2L["3a"]["BorderSizePixel"] = 0
    G2L["3a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["3a"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["3a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["3a"]["Name"] = [[bhop]]
    G2L["3a"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.bhop.text
    G2L["3b"] = Instance.new("TextLabel", G2L["3a"])
    G2L["3b"]["TextStrokeTransparency"] = 0
    G2L["3b"]["BorderSizePixel"] = 0
    G2L["3b"]["TextSize"] = 18
    G2L["3b"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["3b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["3b"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["3b"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["3b"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["3b"]["BackgroundTransparency"] = 1
    G2L["3b"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["3b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["3b"]["Text"] = [[bhop]]
    G2L["3b"]["Name"] = [[text]]
    G2L["3b"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.bhop.button
    G2L["3c"] = Instance.new("Frame", G2L["3a"])
    G2L["3c"]["BorderSizePixel"] = 0
    G2L["3c"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["3c"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["3c"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["3c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["3c"]["Name"] = [[button]]
    G2L["3c"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.movement.bhop.button.UIStroke
    G2L["3d"] = Instance.new("UIStroke", G2L["3c"])
    G2L["3d"]["Thickness"] = 1.3
    G2L["3d"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["3d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["3d"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.bhop.hotkey
    G2L["3e"] = Instance.new("TextLabel", G2L["3a"])
    G2L["3e"]["TextStrokeTransparency"] = 0
    G2L["3e"]["BorderSizePixel"] = 0
    G2L["3e"]["TextSize"] = 18
    G2L["3e"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["3e"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["3e"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["3e"]["BackgroundTransparency"] = 0.65
    G2L["3e"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["3e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["3e"]["Text"] = [[nil]]
    G2L["3e"]["Name"] = [[hotkey]]
    G2L["3e"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.bhop.hotkey.UIStroke
    G2L["3f"] = Instance.new("UIStroke", G2L["3e"])
    G2L["3f"]["Thickness"] = 1.4
    G2L["3f"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["3f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["3f"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.speedhack
    G2L["40"] = Instance.new("Frame", G2L["37"])
    G2L["40"]["BorderSizePixel"] = 0
    G2L["40"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["40"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["40"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["40"]["Name"] = [[speedhack]]
    G2L["40"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.speedhack.text
    G2L["41"] = Instance.new("TextLabel", G2L["40"])
    G2L["41"]["TextStrokeTransparency"] = 0
    G2L["41"]["BorderSizePixel"] = 0
    G2L["41"]["TextSize"] = 18
    G2L["41"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["41"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["41"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["41"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["41"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["41"]["BackgroundTransparency"] = 1
    G2L["41"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["41"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["41"]["Text"] = [[speedhack]]
    G2L["41"]["Name"] = [[text]]
    G2L["41"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.speedhack.button
    G2L["42"] = Instance.new("Frame", G2L["40"])
    G2L["42"]["BorderSizePixel"] = 0
    G2L["42"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["42"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["42"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["42"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["42"]["Name"] = [[button]]
    G2L["42"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.movement.speedhack.button.UIStroke
    G2L["43"] = Instance.new("UIStroke", G2L["42"])
    G2L["43"]["Thickness"] = 1.3
    G2L["43"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["43"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["43"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.speedhack.hotkey
    G2L["44"] = Instance.new("TextLabel", G2L["40"])
    G2L["44"]["TextStrokeTransparency"] = 0
    G2L["44"]["BorderSizePixel"] = 0
    G2L["44"]["TextSize"] = 18
    G2L["44"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["44"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["44"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["44"]["BackgroundTransparency"] = 0.65
    G2L["44"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["44"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["44"]["Text"] = [[nil]]
    G2L["44"]["Name"] = [[hotkey]]
    G2L["44"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.speedhack.hotkey.UIStroke
    G2L["45"] = Instance.new("UIStroke", G2L["44"])
    G2L["45"]["Thickness"] = 1.4
    G2L["45"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["45"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["45"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.flight
    G2L["46"] = Instance.new("Frame", G2L["37"])
    G2L["46"]["BorderSizePixel"] = 0
    G2L["46"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["46"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["46"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["46"]["Name"] = [[flight]]
    G2L["46"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.flight.text
    G2L["47"] = Instance.new("TextLabel", G2L["46"])
    G2L["47"]["TextStrokeTransparency"] = 0
    G2L["47"]["BorderSizePixel"] = 0
    G2L["47"]["TextSize"] = 18
    G2L["47"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["47"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["47"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["47"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["47"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["47"]["BackgroundTransparency"] = 1
    G2L["47"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["47"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["47"]["Text"] = [[flight]]
    G2L["47"]["Name"] = [[text]]
    G2L["47"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.flight.button
    G2L["48"] = Instance.new("Frame", G2L["46"])
    G2L["48"]["BorderSizePixel"] = 0
    G2L["48"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["48"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["48"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["48"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["48"]["Name"] = [[button]]
    G2L["48"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.movement.flight.button.UIStroke
    G2L["49"] = Instance.new("UIStroke", G2L["48"])
    G2L["49"]["Thickness"] = 1.3
    G2L["49"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["49"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["49"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.flight.hotkey
    G2L["4a"] = Instance.new("TextLabel", G2L["46"])
    G2L["4a"]["TextStrokeTransparency"] = 0
    G2L["4a"]["BorderSizePixel"] = 0
    G2L["4a"]["TextSize"] = 18
    G2L["4a"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["4a"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["4a"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["4a"]["BackgroundTransparency"] = 0.65
    G2L["4a"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["4a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["4a"]["Text"] = [[nil]]
    G2L["4a"]["Name"] = [[hotkey]]
    G2L["4a"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.flight.hotkey.UIStroke
    G2L["4b"] = Instance.new("UIStroke", G2L["4a"])
    G2L["4b"]["Thickness"] = 1.4
    G2L["4b"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["4b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["4b"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.noclip
    G2L["4c"] = Instance.new("Frame", G2L["37"])
    G2L["4c"]["BorderSizePixel"] = 0
    G2L["4c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["4c"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["4c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["4c"]["Name"] = [[noclip]]
    G2L["4c"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.noclip.text
    G2L["4d"] = Instance.new("TextLabel", G2L["4c"])
    G2L["4d"]["TextStrokeTransparency"] = 0
    G2L["4d"]["BorderSizePixel"] = 0
    G2L["4d"]["TextSize"] = 18
    G2L["4d"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["4d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["4d"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["4d"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["4d"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["4d"]["BackgroundTransparency"] = 1
    G2L["4d"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["4d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["4d"]["Text"] = [[noclip]]
    G2L["4d"]["Name"] = [[text]]
    G2L["4d"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.noclip.button
    G2L["4e"] = Instance.new("Frame", G2L["4c"])
    G2L["4e"]["BorderSizePixel"] = 0
    G2L["4e"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["4e"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["4e"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["4e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["4e"]["Name"] = [[button]]
    G2L["4e"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.movement.noclip.button.UIStroke
    G2L["4f"] = Instance.new("UIStroke", G2L["4e"])
    G2L["4f"]["Thickness"] = 1.3
    G2L["4f"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["4f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["4f"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.noclip.hotkey
    G2L["50"] = Instance.new("TextLabel", G2L["4c"])
    G2L["50"]["TextStrokeTransparency"] = 0
    G2L["50"]["BorderSizePixel"] = 0
    G2L["50"]["TextSize"] = 18
    G2L["50"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["50"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["50"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["50"]["BackgroundTransparency"] = 0.65
    G2L["50"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["50"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["50"]["Text"] = [[nil]]
    G2L["50"]["Name"] = [[hotkey]]
    G2L["50"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.noclip.hotkey.UIStroke
    G2L["51"] = Instance.new("UIStroke", G2L["50"])
    G2L["51"]["Thickness"] = 1.4
    G2L["51"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["51"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["51"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.spin
    G2L["52"] = Instance.new("Frame", G2L["37"])
    G2L["52"]["BorderSizePixel"] = 0
    G2L["52"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["52"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["52"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["52"]["Name"] = [[spin]]
    G2L["52"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.spin.text
    G2L["53"] = Instance.new("TextLabel", G2L["52"])
    G2L["53"]["TextStrokeTransparency"] = 0
    G2L["53"]["BorderSizePixel"] = 0
    G2L["53"]["TextSize"] = 18
    G2L["53"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["53"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["53"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["53"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["53"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["53"]["BackgroundTransparency"] = 1
    G2L["53"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["53"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["53"]["Text"] = [[spin]]
    G2L["53"]["Name"] = [[text]]
    G2L["53"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.spin.button
    G2L["54"] = Instance.new("Frame", G2L["52"])
    G2L["54"]["BorderSizePixel"] = 0
    G2L["54"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["54"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["54"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["54"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["54"]["Name"] = [[button]]
    G2L["54"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.movement.spin.button.UIStroke
    G2L["55"] = Instance.new("UIStroke", G2L["54"])
    G2L["55"]["Thickness"] = 1.3
    G2L["55"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["55"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["55"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.spin.hotkey
    G2L["56"] = Instance.new("TextLabel", G2L["52"])
    G2L["56"]["TextStrokeTransparency"] = 0
    G2L["56"]["BorderSizePixel"] = 0
    G2L["56"]["TextSize"] = 18
    G2L["56"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["56"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["56"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["56"]["BackgroundTransparency"] = 0.65
    G2L["56"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["56"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["56"]["Text"] = [[nil]]
    G2L["56"]["Name"] = [[hotkey]]
    G2L["56"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.spin.hotkey.UIStroke
    G2L["57"] = Instance.new("UIStroke", G2L["56"])
    G2L["57"]["Thickness"] = 1.4
    G2L["57"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["57"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["57"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.speed
    G2L["58"] = Instance.new("Frame", G2L["37"])
    G2L["58"]["BorderSizePixel"] = 0
    G2L["58"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["58"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["58"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["58"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["58"]["Name"] = [[speed]]
    G2L["58"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.speed.text
    G2L["59"] = Instance.new("TextLabel", G2L["58"])
    G2L["59"]["TextStrokeTransparency"] = 0
    G2L["59"]["BorderSizePixel"] = 0
    G2L["59"]["TextSize"] = 18
    G2L["59"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["59"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["59"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["59"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["59"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["59"]["BackgroundTransparency"] = 1
    G2L["59"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["59"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["59"]["Text"] = [[movespeed -]]
    G2L["59"]["Name"] = [[text]]
    G2L["59"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.speed.slider
    G2L["5a"] = Instance.new("Frame", G2L["58"])
    G2L["5a"]["BorderSizePixel"] = 0
    G2L["5a"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["5a"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["5a"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["5a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["5a"]["Name"] = [[slider]]
    G2L["5a"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.movement.speed.slider.UIStroke
    G2L["5b"] = Instance.new("UIStroke", G2L["5a"])
    G2L["5b"]["Thickness"] = 1.3
    G2L["5b"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["5b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["5b"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.speed.number
    G2L["5c"] = Instance.new("TextBox", G2L["58"])
    G2L["5c"]["CursorPosition"] = -1
    G2L["5c"]["TextStrokeTransparency"] = 0
    G2L["5c"]["Name"] = [[number]]
    G2L["5c"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["5c"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["5c"]["BorderSizePixel"] = 0
    G2L["5c"]["TextWrapped"] = true
    G2L["5c"]["TextSize"] = 18
    G2L["5c"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["5c"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["5c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["5c"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["5c"]["ClearTextOnFocus"] = false
    G2L["5c"]["Size"] = UDim2.new(0, 61, 0, 20)
    G2L["5c"]["Position"] = UDim2.new(0.52177, 0, 0, 0)
    G2L["5c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["5c"]["Text"] = [[0]]
    G2L["5c"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.flightspeed
    G2L["5d"] = Instance.new("Frame", G2L["37"])
    G2L["5d"]["BorderSizePixel"] = 0
    G2L["5d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["5d"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["5d"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["5d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["5d"]["Name"] = [[flightspeed]]
    G2L["5d"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.flightspeed.text
    G2L["5e"] = Instance.new("TextLabel", G2L["5d"])
    G2L["5e"]["TextStrokeTransparency"] = 0
    G2L["5e"]["BorderSizePixel"] = 0
    G2L["5e"]["TextSize"] = 18
    G2L["5e"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["5e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["5e"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["5e"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["5e"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["5e"]["BackgroundTransparency"] = 1
    G2L["5e"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["5e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["5e"]["Text"] = [[flightspeed -]]
    G2L["5e"]["Name"] = [[text]]
    G2L["5e"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.flightspeed.slider
    G2L["5f"] = Instance.new("Frame", G2L["5d"])
    G2L["5f"]["BorderSizePixel"] = 0
    G2L["5f"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["5f"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["5f"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["5f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["5f"]["Name"] = [[slider]]
    G2L["5f"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.movement.flightspeed.slider.UIStroke
    G2L["60"] = Instance.new("UIStroke", G2L["5f"])
    G2L["60"]["Thickness"] = 1.3
    G2L["60"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["60"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["60"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.flightspeed.number
    G2L["61"] = Instance.new("TextBox", G2L["5d"])
    G2L["61"]["TextStrokeTransparency"] = 0
    G2L["61"]["Name"] = [[number]]
    G2L["61"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["61"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["61"]["BorderSizePixel"] = 0
    G2L["61"]["TextWrapped"] = true
    G2L["61"]["TextSize"] = 18
    G2L["61"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["61"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["61"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["61"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["61"]["ClearTextOnFocus"] = false
    G2L["61"]["Size"] = UDim2.new(0, 61, 0, 20)
    G2L["61"]["Position"] = UDim2.new(0.52177, 0, 0, 0)
    G2L["61"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["61"]["Text"] = [[0]]
    G2L["61"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.spinspeed
    G2L["62"] = Instance.new("Frame", G2L["37"])
    G2L["62"]["BorderSizePixel"] = 0
    G2L["62"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["62"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["62"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["62"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["62"]["Name"] = [[spinspeed]]
    G2L["62"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.movement.spinspeed.text
    G2L["63"] = Instance.new("TextLabel", G2L["62"])
    G2L["63"]["TextStrokeTransparency"] = 0
    G2L["63"]["BorderSizePixel"] = 0
    G2L["63"]["TextSize"] = 18
    G2L["63"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["63"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["63"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["63"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["63"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["63"]["BackgroundTransparency"] = 1
    G2L["63"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["63"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["63"]["Text"] = [[spinspeed -]]
    G2L["63"]["Name"] = [[text]]
    G2L["63"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.movement.spinspeed.slider
    G2L["64"] = Instance.new("Frame", G2L["62"])
    G2L["64"]["BorderSizePixel"] = 0
    G2L["64"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["64"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["64"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["64"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["64"]["Name"] = [[slider]]
    G2L["64"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.movement.spinspeed.slider.UIStroke
    G2L["65"] = Instance.new("UIStroke", G2L["64"])
    G2L["65"]["Thickness"] = 1.3
    G2L["65"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["65"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["65"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.movement.spinspeed.number
    G2L["66"] = Instance.new("TextBox", G2L["62"])
    G2L["66"]["CursorPosition"] = -1
    G2L["66"]["TextStrokeTransparency"] = 0
    G2L["66"]["Name"] = [[number]]
    G2L["66"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["66"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["66"]["BorderSizePixel"] = 0
    G2L["66"]["TextWrapped"] = true
    G2L["66"]["TextSize"] = 18
    G2L["66"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["66"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["66"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["66"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["66"]["ClearTextOnFocus"] = false
    G2L["66"]["Size"] = UDim2.new(0, 65, 0, 20)
    G2L["66"]["Position"] = UDim2.new(0.49419, 0, 0, 0)
    G2L["66"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["66"]["Text"] = [[0]]
    G2L["66"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.config
    G2L["67"] = Instance.new("Frame", G2L["9"])
    G2L["67"]["BorderSizePixel"] = 0
    G2L["67"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["67"]["Size"] = UDim2.new(0, 143, 0, 142)
    G2L["67"]["Position"] = UDim2.new(0.67111, 0, 0.08, 0)
    G2L["67"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["67"]["Name"] = [[config]]
    G2L["67"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.miscframe.config.label
    G2L["68"] = Instance.new("TextLabel", G2L["67"])
    G2L["68"]["TextStrokeTransparency"] = 0
    G2L["68"]["BorderSizePixel"] = 0
    G2L["68"]["TextSize"] = 20
    G2L["68"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["68"]["SelectionOrder"] = 1
    G2L["68"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["68"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["68"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["68"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["68"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["68"]["Text"] = [[  config]]
    G2L["68"]["LayoutOrder"] = -1
    G2L["68"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.miscframe.config.UIListLayout
    G2L["69"] = Instance.new("UIListLayout", G2L["67"])
    G2L["69"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.miscframe.config.menu key
    G2L["6a"] = Instance.new("Frame", G2L["67"])
    G2L["6a"]["BorderSizePixel"] = 0
    G2L["6a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["6a"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["6a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["6a"]["Name"] = [[menu key]]
    G2L["6a"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.config.menu key.text
    G2L["6b"] = Instance.new("TextLabel", G2L["6a"])
    G2L["6b"]["TextStrokeTransparency"] = 0
    G2L["6b"]["BorderSizePixel"] = 0
    G2L["6b"]["TextSize"] = 18
    G2L["6b"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["6b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["6b"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["6b"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["6b"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["6b"]["BackgroundTransparency"] = 1
    G2L["6b"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["6b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["6b"]["Text"] = [[menu key]]
    G2L["6b"]["Name"] = [[text]]
    G2L["6b"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.config.menu key.hotkey
    G2L["6c"] = Instance.new("TextLabel", G2L["6a"])
    G2L["6c"]["TextStrokeTransparency"] = 0
    G2L["6c"]["BorderSizePixel"] = 0
    G2L["6c"]["TextSize"] = 18
    G2L["6c"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["6c"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["6c"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["6c"]["BackgroundTransparency"] = 0.65
    G2L["6c"]["Size"] = UDim2.new(0, 48, 0, 10)
    G2L["6c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["6c"]["Text"] = [[right ctrl]]
    G2L["6c"]["Name"] = [[hotkey]]
    G2L["6c"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.config.menu key.hotkey.UIStroke
    G2L["6d"] = Instance.new("UIStroke", G2L["6c"])
    G2L["6d"]["Thickness"] = 1.4
    G2L["6d"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["6d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["6d"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.config.config
    G2L["6e"] = Instance.new("Frame", G2L["67"])
    G2L["6e"]["BorderSizePixel"] = 0
    G2L["6e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["6e"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["6e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["6e"]["Name"] = [[config]]
    G2L["6e"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.config.config.text
    G2L["6f"] = Instance.new("TextLabel", G2L["6e"])
    G2L["6f"]["TextStrokeTransparency"] = 0
    G2L["6f"]["BorderSizePixel"] = 0
    G2L["6f"]["TextSize"] = 18
    G2L["6f"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["6f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["6f"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["6f"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["6f"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["6f"]["BackgroundTransparency"] = 1
    G2L["6f"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["6f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["6f"]["Text"] = [[config]]
    G2L["6f"]["Name"] = [[text]]
    G2L["6f"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.config.config.config
    G2L["70"] = Instance.new("TextLabel", G2L["6e"])
    G2L["70"]["TextStrokeTransparency"] = 0
    G2L["70"]["BorderSizePixel"] = 0
    G2L["70"]["TextSize"] = 18
    G2L["70"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["70"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["70"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["70"]["BackgroundTransparency"] = 0.65
    G2L["70"]["Size"] = UDim2.new(0, 48, 0, 10)
    G2L["70"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["70"]["Text"] = [[nil]]
    G2L["70"]["Name"] = [[config]]
    G2L["70"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.config.config.config.UIStroke
    G2L["71"] = Instance.new("UIStroke", G2L["70"])
    G2L["71"]["Thickness"] = 1.4
    G2L["71"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["71"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["71"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.config.saveconfig
    G2L["72"] = Instance.new("Frame", G2L["67"])
    G2L["72"]["BorderSizePixel"] = 0
    G2L["72"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["72"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["72"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["72"]["Name"] = [[saveconfig]]
    G2L["72"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.config.saveconfig.saveconfig
    G2L["73"] = Instance.new("TextLabel", G2L["72"])
    G2L["73"]["TextStrokeTransparency"] = 0
    G2L["73"]["BorderSizePixel"] = 0
    G2L["73"]["TextSize"] = 18
    G2L["73"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["73"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["73"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["73"]["BackgroundTransparency"] = 0.65
    G2L["73"]["Size"] = UDim2.new(0, 133, 0, 15)
    G2L["73"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["73"]["Text"] = [[save config]]
    G2L["73"]["Name"] = [[saveconfig]]
    G2L["73"]["Position"] = UDim2.new(0.03448, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.config.saveconfig.saveconfig.UIStroke
    G2L["74"] = Instance.new("UIStroke", G2L["73"])
    G2L["74"]["Thickness"] = 1.4
    G2L["74"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["74"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["74"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.config.loadconfig
    G2L["75"] = Instance.new("Frame", G2L["67"])
    G2L["75"]["BorderSizePixel"] = 0
    G2L["75"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["75"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["75"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["75"]["Name"] = [[loadconfig]]
    G2L["75"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.config.loadconfig.loadconfig
    G2L["76"] = Instance.new("TextLabel", G2L["75"])
    G2L["76"]["TextStrokeTransparency"] = 0
    G2L["76"]["BorderSizePixel"] = 0
    G2L["76"]["TextSize"] = 18
    G2L["76"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["76"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["76"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["76"]["BackgroundTransparency"] = 0.65
    G2L["76"]["Size"] = UDim2.new(0, 133, 0, 15)
    G2L["76"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["76"]["Text"] = [[load config]]
    G2L["76"]["Name"] = [[loadconfig]]
    G2L["76"]["Position"] = UDim2.new(0.03448, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.miscframe.config.loadconfig.loadconfig.UIStroke
    G2L["77"] = Instance.new("UIStroke", G2L["76"])
    G2L["77"]["Thickness"] = 1.4
    G2L["77"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["77"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["77"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.miscframe.config.watermark
    G2L["78"] = Instance.new("Frame", G2L["67"])
    G2L["78"]["BorderSizePixel"] = 0
    G2L["78"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["78"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["78"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["78"]["Name"] = [[watermark]]
    G2L["78"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.miscframe.config.watermark.text
    G2L["79"] = Instance.new("TextLabel", G2L["78"])
    G2L["79"]["TextStrokeTransparency"] = 0
    G2L["79"]["BorderSizePixel"] = 0
    G2L["79"]["TextSize"] = 18
    G2L["79"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["79"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["79"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["79"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["79"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["79"]["BackgroundTransparency"] = 1
    G2L["79"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["79"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["79"]["Text"] = [[watermark]]
    G2L["79"]["Name"] = [[text]]
    G2L["79"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.miscframe.config.watermark.button
    G2L["7a"] = Instance.new("Frame", G2L["78"])
    G2L["7a"]["BorderSizePixel"] = 0
    G2L["7a"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["7a"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["7a"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["7a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["7a"]["Name"] = [[button]]
    G2L["7a"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.miscframe.config.watermark.button.UIStroke
    G2L["7b"] = Instance.new("UIStroke", G2L["7a"])
    G2L["7b"]["Thickness"] = 1.3
    G2L["7b"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["7b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["7b"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe
    G2L["7c"] = Instance.new("Frame", G2L["8"])
    G2L["7c"]["Visible"] = false
    G2L["7c"]["BorderSizePixel"] = 0
    G2L["7c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["7c"]["Size"] = UDim2.new(0, 450, 0, 350)
    G2L["7c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["7c"]["Name"] = [[visualsframe]]
    G2L["7c"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.fov
    G2L["7d"] = Instance.new("Frame", G2L["7c"])
    G2L["7d"]["BorderSizePixel"] = 0
    G2L["7d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["7d"]["Size"] = UDim2.new(0, 143, 0, 146)
    G2L["7d"]["Position"] = UDim2.new(0.67111, 0, 0.49938, 0)
    G2L["7d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["7d"]["Name"] = [[fov]]
    G2L["7d"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.visualsframe.fov.label
    G2L["7e"] = Instance.new("TextLabel", G2L["7d"])
    G2L["7e"]["TextStrokeTransparency"] = 0
    G2L["7e"]["BorderSizePixel"] = 0
    G2L["7e"]["TextSize"] = 20
    G2L["7e"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["7e"]["SelectionOrder"] = 1
    G2L["7e"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["7e"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["7e"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["7e"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["7e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["7e"]["Text"] = [[  fov changer]]
    G2L["7e"]["LayoutOrder"] = -1
    G2L["7e"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.visualsframe.fov.UIListLayout
    G2L["7f"] = Instance.new("UIListLayout", G2L["7d"])
    G2L["7f"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.visualsframe.fov.enabled
    G2L["80"] = Instance.new("Frame", G2L["7d"])
    G2L["80"]["BorderSizePixel"] = 0
    G2L["80"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["80"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["80"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["80"]["Name"] = [[enabled]]
    G2L["80"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.fov.enabled.text
    G2L["81"] = Instance.new("TextLabel", G2L["80"])
    G2L["81"]["TextStrokeTransparency"] = 0
    G2L["81"]["BorderSizePixel"] = 0
    G2L["81"]["TextSize"] = 18
    G2L["81"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["81"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["81"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["81"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["81"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["81"]["BackgroundTransparency"] = 1
    G2L["81"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["81"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["81"]["Text"] = [[enabled]]
    G2L["81"]["Name"] = [[text]]
    G2L["81"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.fov.enabled.button
    G2L["82"] = Instance.new("Frame", G2L["80"])
    G2L["82"]["BorderSizePixel"] = 0
    G2L["82"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["82"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["82"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["82"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["82"]["Name"] = [[button]]
    G2L["82"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.fov.enabled.button.UIStroke
    G2L["83"] = Instance.new("UIStroke", G2L["82"])
    G2L["83"]["Thickness"] = 1.3
    G2L["83"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["83"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["83"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.fov.amount
    G2L["84"] = Instance.new("Frame", G2L["7d"])
    G2L["84"]["BorderSizePixel"] = 0
    G2L["84"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["84"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["84"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["84"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["84"]["Name"] = [[amount]]
    G2L["84"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.fov.amount.text
    G2L["85"] = Instance.new("TextLabel", G2L["84"])
    G2L["85"]["TextStrokeTransparency"] = 0
    G2L["85"]["BorderSizePixel"] = 0
    G2L["85"]["TextSize"] = 18
    G2L["85"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["85"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["85"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["85"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["85"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["85"]["BackgroundTransparency"] = 1
    G2L["85"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["85"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["85"]["Text"] = [[amount - ]]
    G2L["85"]["Name"] = [[text]]
    G2L["85"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.fov.amount.slider
    G2L["86"] = Instance.new("Frame", G2L["84"])
    G2L["86"]["BorderSizePixel"] = 0
    G2L["86"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["86"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["86"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["86"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["86"]["Name"] = [[slider]]
    G2L["86"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.fov.amount.slider.UIStroke
    G2L["87"] = Instance.new("UIStroke", G2L["86"])
    G2L["87"]["Thickness"] = 1.3
    G2L["87"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["87"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["87"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.fov.amount.number
    G2L["88"] = Instance.new("TextBox", G2L["84"])
    G2L["88"]["TextStrokeTransparency"] = 0
    G2L["88"]["Name"] = [[number]]
    G2L["88"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["88"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["88"]["BorderSizePixel"] = 0
    G2L["88"]["TextWrapped"] = true
    G2L["88"]["TextSize"] = 18
    G2L["88"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["88"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["88"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["88"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["88"]["ClearTextOnFocus"] = false
    G2L["88"]["Size"] = UDim2.new(0, 83, 0, 20)
    G2L["88"]["Position"] = UDim2.new(0.38207, 0, 0, 0)
    G2L["88"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["88"]["Text"] = [[90]]
    G2L["88"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.fov.zoomkey
    G2L["89"] = Instance.new("Frame", G2L["7d"])
    G2L["89"]["BorderSizePixel"] = 0
    G2L["89"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["89"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["89"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["89"]["Name"] = [[zoomkey]]
    G2L["89"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.fov.zoomkey.hotkey
    G2L["8a"] = Instance.new("TextLabel", G2L["89"])
    G2L["8a"]["TextStrokeTransparency"] = 0
    G2L["8a"]["BorderSizePixel"] = 0
    G2L["8a"]["TextSize"] = 18
    G2L["8a"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["8a"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["8a"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["8a"]["BackgroundTransparency"] = 0.65
    G2L["8a"]["Size"] = UDim2.new(0, 50, 0, 10)
    G2L["8a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["8a"]["Text"] = [[nil]]
    G2L["8a"]["Name"] = [[hotkey]]
    G2L["8a"]["Position"] = UDim2.new(0.59701, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.fov.zoomkey.hotkey.UIStroke
    G2L["8b"] = Instance.new("UIStroke", G2L["8a"])
    G2L["8b"]["Thickness"] = 1.4
    G2L["8b"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["8b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["8b"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.fov.zoomkey.text
    G2L["8c"] = Instance.new("TextLabel", G2L["89"])
    G2L["8c"]["TextStrokeTransparency"] = 0
    G2L["8c"]["BorderSizePixel"] = 0
    G2L["8c"]["TextSize"] = 18
    G2L["8c"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["8c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["8c"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["8c"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["8c"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["8c"]["BackgroundTransparency"] = 1
    G2L["8c"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["8c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["8c"]["Text"] = [[zoom key]]
    G2L["8c"]["Name"] = [[text]]
    G2L["8c"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.fov.zoomamount
    G2L["8d"] = Instance.new("Frame", G2L["7d"])
    G2L["8d"]["BorderSizePixel"] = 0
    G2L["8d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["8d"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["8d"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["8d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["8d"]["Name"] = [[zoomamount]]
    G2L["8d"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.fov.zoomamount.text
    G2L["8e"] = Instance.new("TextLabel", G2L["8d"])
    G2L["8e"]["TextStrokeTransparency"] = 0
    G2L["8e"]["BorderSizePixel"] = 0
    G2L["8e"]["TextSize"] = 18
    G2L["8e"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["8e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["8e"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["8e"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["8e"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["8e"]["BackgroundTransparency"] = 1
    G2L["8e"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["8e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["8e"]["Text"] = [[zoom amount - ]]
    G2L["8e"]["Name"] = [[text]]
    G2L["8e"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.fov.zoomamount.slider
    G2L["8f"] = Instance.new("Frame", G2L["8d"])
    G2L["8f"]["BorderSizePixel"] = 0
    G2L["8f"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["8f"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["8f"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["8f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["8f"]["Name"] = [[slider]]
    G2L["8f"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.fov.zoomamount.slider.UIStroke
    G2L["90"] = Instance.new("UIStroke", G2L["8f"])
    G2L["90"]["Thickness"] = 1.3
    G2L["90"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["90"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["90"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.fov.zoomamount.number
    G2L["91"] = Instance.new("TextBox", G2L["8d"])
    G2L["91"]["TextStrokeTransparency"] = 0
    G2L["91"]["Name"] = [[number]]
    G2L["91"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["91"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["91"]["BorderSizePixel"] = 0
    G2L["91"]["TextWrapped"] = true
    G2L["91"]["TextSize"] = 18
    G2L["91"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["91"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["91"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["91"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["91"]["ClearTextOnFocus"] = false
    G2L["91"]["Size"] = UDim2.new(0, 50, 0, 20)
    G2L["91"]["Position"] = UDim2.new(0.59701, 0, 0, 0)
    G2L["91"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["91"]["Text"] = [[60]]
    G2L["91"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options
    G2L["92"] = Instance.new("Frame", G2L["7c"])
    G2L["92"]["BorderSizePixel"] = 0
    G2L["92"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["92"]["Size"] = UDim2.new(0, 145, 0, 292)
    G2L["92"]["Position"] = UDim2.new(0.34, 0, 0.08, 0)
    G2L["92"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["92"]["Name"] = [[options]]
    G2L["92"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.visualsframe.options.box
    G2L["93"] = Instance.new("Frame", G2L["92"])
    G2L["93"]["BorderSizePixel"] = 0
    G2L["93"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["93"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["93"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["93"]["Name"] = [[box]]
    G2L["93"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.box.text
    G2L["94"] = Instance.new("TextLabel", G2L["93"])
    G2L["94"]["TextStrokeTransparency"] = 0
    G2L["94"]["BorderSizePixel"] = 0
    G2L["94"]["TextSize"] = 18
    G2L["94"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["94"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["94"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["94"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["94"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["94"]["BackgroundTransparency"] = 1
    G2L["94"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["94"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["94"]["Text"] = [[box]]
    G2L["94"]["Name"] = [[text]]
    G2L["94"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.box.button
    G2L["95"] = Instance.new("Frame", G2L["93"])
    G2L["95"]["BorderSizePixel"] = 0
    G2L["95"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["95"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["95"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["95"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["95"]["Name"] = [[button]]
    G2L["95"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.options.box.button.UIStroke
    G2L["96"] = Instance.new("UIStroke", G2L["95"])
    G2L["96"]["Thickness"] = 1.3
    G2L["96"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["96"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["96"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.skeleton
    G2L["97"] = Instance.new("Frame", G2L["92"])
    G2L["97"]["BorderSizePixel"] = 0
    G2L["97"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["97"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["97"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["97"]["Name"] = [[skeleton]]
    G2L["97"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.skeleton.text
    G2L["98"] = Instance.new("TextLabel", G2L["97"])
    G2L["98"]["TextStrokeTransparency"] = 0
    G2L["98"]["BorderSizePixel"] = 0
    G2L["98"]["TextSize"] = 18
    G2L["98"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["98"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["98"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["98"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["98"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["98"]["BackgroundTransparency"] = 1
    G2L["98"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["98"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["98"]["Text"] = [[skeleton]]
    G2L["98"]["Name"] = [[text]]
    G2L["98"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.skeleton.button
    G2L["99"] = Instance.new("Frame", G2L["97"])
    G2L["99"]["BorderSizePixel"] = 0
    G2L["99"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["99"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["99"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["99"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["99"]["Name"] = [[button]]
    G2L["99"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.options.skeleton.button.UIStroke
    G2L["9a"] = Instance.new("UIStroke", G2L["99"])
    G2L["9a"]["Thickness"] = 1.3
    G2L["9a"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["9a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["9a"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.UIListLayout
    G2L["9b"] = Instance.new("UIListLayout", G2L["92"])
    G2L["9b"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.visualsframe.options.label
    G2L["9c"] = Instance.new("TextLabel", G2L["92"])
    G2L["9c"]["TextStrokeTransparency"] = 0
    G2L["9c"]["BorderSizePixel"] = 0
    G2L["9c"]["TextSize"] = 20
    G2L["9c"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["9c"]["SelectionOrder"] = 1
    G2L["9c"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["9c"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["9c"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["9c"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["9c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["9c"]["Text"] = [[  option (nil)]]
    G2L["9c"]["LayoutOrder"] = -1
    G2L["9c"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.visualsframe.options.color
    G2L["9d"] = Instance.new("Frame", G2L["92"])
    G2L["9d"]["BorderSizePixel"] = 0
    G2L["9d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["9d"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["9d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["9d"]["Name"] = [[color]]
    G2L["9d"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.color.text
    G2L["9e"] = Instance.new("TextLabel", G2L["9d"])
    G2L["9e"]["TextStrokeTransparency"] = 0
    G2L["9e"]["BorderSizePixel"] = 0
    G2L["9e"]["TextSize"] = 18
    G2L["9e"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["9e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["9e"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["9e"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["9e"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["9e"]["BackgroundTransparency"] = 1
    G2L["9e"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["9e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["9e"]["Text"] = [[box/skel color]]
    G2L["9e"]["Name"] = [[text]]
    G2L["9e"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.color.colorchanger
    G2L["9f"] = Instance.new("Frame", G2L["9d"])
    G2L["9f"]["BorderSizePixel"] = 0
    G2L["9f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["9f"]["Size"] = UDim2.new(0, 40, 0, 10)
    G2L["9f"]["Position"] = UDim2.new(0.68406, 0, 0.22, 0)
    G2L["9f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["9f"]["Name"] = [[colorchanger]]

    -- StarterGui.baggyware.main.windows.visualsframe.options.color.colorchanger.UIStroke
    G2L["a0"] = Instance.new("UIStroke", G2L["9f"])
    G2L["a0"]["Thickness"] = 1.3
    G2L["a0"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["a0"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["a0"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.healthbar
    G2L["a1"] = Instance.new("Frame", G2L["92"])
    G2L["a1"]["BorderSizePixel"] = 0
    G2L["a1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["a1"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["a1"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a1"]["Name"] = [[healthbar]]
    G2L["a1"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.healthbar.text
    G2L["a2"] = Instance.new("TextLabel", G2L["a1"])
    G2L["a2"]["TextStrokeTransparency"] = 0
    G2L["a2"]["BorderSizePixel"] = 0
    G2L["a2"]["TextSize"] = 18
    G2L["a2"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["a2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["a2"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["a2"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["a2"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["a2"]["BackgroundTransparency"] = 1
    G2L["a2"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["a2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a2"]["Text"] = [[health bar]]
    G2L["a2"]["Name"] = [[text]]
    G2L["a2"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.healthbar.button
    G2L["a3"] = Instance.new("Frame", G2L["a1"])
    G2L["a3"]["BorderSizePixel"] = 0
    G2L["a3"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a3"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["a3"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["a3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a3"]["Name"] = [[button]]
    G2L["a3"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.options.healthbar.button.UIStroke
    G2L["a4"] = Instance.new("UIStroke", G2L["a3"])
    G2L["a4"]["Thickness"] = 1.3
    G2L["a4"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["a4"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["a4"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.name
    G2L["a5"] = Instance.new("Frame", G2L["92"])
    G2L["a5"]["BorderSizePixel"] = 0
    G2L["a5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["a5"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["a5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a5"]["Name"] = [[name]]
    G2L["a5"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.name.text
    G2L["a6"] = Instance.new("TextLabel", G2L["a5"])
    G2L["a6"]["TextStrokeTransparency"] = 0
    G2L["a6"]["BorderSizePixel"] = 0
    G2L["a6"]["TextSize"] = 18
    G2L["a6"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["a6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["a6"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["a6"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["a6"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["a6"]["BackgroundTransparency"] = 1
    G2L["a6"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["a6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a6"]["Text"] = [[name]]
    G2L["a6"]["Name"] = [[text]]
    G2L["a6"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.name.button
    G2L["a7"] = Instance.new("Frame", G2L["a5"])
    G2L["a7"]["BorderSizePixel"] = 0
    G2L["a7"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a7"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["a7"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["a7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a7"]["Name"] = [[button]]
    G2L["a7"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.options.name.button.UIStroke
    G2L["a8"] = Instance.new("UIStroke", G2L["a7"])
    G2L["a8"]["Thickness"] = 1.3
    G2L["a8"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["a8"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["a8"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.text color
    G2L["a9"] = Instance.new("Frame", G2L["92"])
    G2L["a9"]["BorderSizePixel"] = 0
    G2L["a9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["a9"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["a9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["a9"]["Name"] = [[text color]]
    G2L["a9"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.text color.text
    G2L["aa"] = Instance.new("TextLabel", G2L["a9"])
    G2L["aa"]["TextStrokeTransparency"] = 0
    G2L["aa"]["BorderSizePixel"] = 0
    G2L["aa"]["TextSize"] = 18
    G2L["aa"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["aa"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["aa"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["aa"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["aa"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["aa"]["BackgroundTransparency"] = 1
    G2L["aa"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["aa"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["aa"]["Text"] = [[text color]]
    G2L["aa"]["Name"] = [[text]]
    G2L["aa"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.text color.colorchanger
    G2L["ab"] = Instance.new("Frame", G2L["a9"])
    G2L["ab"]["BorderSizePixel"] = 0
    G2L["ab"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["ab"]["Size"] = UDim2.new(0, 40, 0, 10)
    G2L["ab"]["Position"] = UDim2.new(0.68406, 0, 0.22, 0)
    G2L["ab"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ab"]["Name"] = [[colorchanger]]

    -- StarterGui.baggyware.main.windows.visualsframe.options.text color.colorchanger.UIStroke
    G2L["ac"] = Instance.new("UIStroke", G2L["ab"])
    G2L["ac"]["Thickness"] = 1.3
    G2L["ac"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["ac"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["ac"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.weapon
    G2L["ad"] = Instance.new("Frame", G2L["92"])
    G2L["ad"]["BorderSizePixel"] = 0
    G2L["ad"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["ad"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["ad"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ad"]["Name"] = [[weapon]]
    G2L["ad"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.weapon.text
    G2L["ae"] = Instance.new("TextLabel", G2L["ad"])
    G2L["ae"]["TextStrokeTransparency"] = 0
    G2L["ae"]["BorderSizePixel"] = 0
    G2L["ae"]["TextSize"] = 18
    G2L["ae"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["ae"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["ae"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["ae"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["ae"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["ae"]["BackgroundTransparency"] = 1
    G2L["ae"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["ae"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ae"]["Text"] = [[weapon]]
    G2L["ae"]["Name"] = [[text]]
    G2L["ae"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.weapon.button
    G2L["af"] = Instance.new("Frame", G2L["ad"])
    G2L["af"]["BorderSizePixel"] = 0
    G2L["af"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["af"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["af"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["af"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["af"]["Name"] = [[button]]
    G2L["af"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.options.weapon.button.UIStroke
    G2L["b0"] = Instance.new("UIStroke", G2L["af"])
    G2L["b0"]["Thickness"] = 1.3
    G2L["b0"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["b0"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["b0"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.distance
    G2L["b1"] = Instance.new("Frame", G2L["92"])
    G2L["b1"]["BorderSizePixel"] = 0
    G2L["b1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["b1"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["b1"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b1"]["Name"] = [[distance]]
    G2L["b1"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.distance.text
    G2L["b2"] = Instance.new("TextLabel", G2L["b1"])
    G2L["b2"]["TextStrokeTransparency"] = 0
    G2L["b2"]["BorderSizePixel"] = 0
    G2L["b2"]["TextSize"] = 18
    G2L["b2"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["b2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["b2"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["b2"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["b2"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["b2"]["BackgroundTransparency"] = 1
    G2L["b2"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["b2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b2"]["Text"] = [[distance]]
    G2L["b2"]["Name"] = [[text]]
    G2L["b2"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.distance.button
    G2L["b3"] = Instance.new("Frame", G2L["b1"])
    G2L["b3"]["BorderSizePixel"] = 0
    G2L["b3"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b3"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["b3"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["b3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b3"]["Name"] = [[button]]
    G2L["b3"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.options.distance.button.UIStroke
    G2L["b4"] = Instance.new("UIStroke", G2L["b3"])
    G2L["b4"]["Thickness"] = 1.3
    G2L["b4"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["b4"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["b4"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.chams
    G2L["b5"] = Instance.new("Frame", G2L["92"])
    G2L["b5"]["BorderSizePixel"] = 0
    G2L["b5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["b5"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["b5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b5"]["Name"] = [[chams]]
    G2L["b5"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.chams.text
    G2L["b6"] = Instance.new("TextLabel", G2L["b5"])
    G2L["b6"]["TextStrokeTransparency"] = 0
    G2L["b6"]["BorderSizePixel"] = 0
    G2L["b6"]["TextSize"] = 18
    G2L["b6"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["b6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["b6"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["b6"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["b6"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["b6"]["BackgroundTransparency"] = 1
    G2L["b6"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["b6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b6"]["Text"] = [[chams]]
    G2L["b6"]["Name"] = [[text]]
    G2L["b6"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.chams.button
    G2L["b7"] = Instance.new("Frame", G2L["b5"])
    G2L["b7"]["BorderSizePixel"] = 0
    G2L["b7"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b7"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["b7"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["b7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b7"]["Name"] = [[button]]
    G2L["b7"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.options.chams.button.UIStroke
    G2L["b8"] = Instance.new("UIStroke", G2L["b7"])
    G2L["b8"]["Thickness"] = 1.3
    G2L["b8"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["b8"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["b8"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.health
    G2L["b9"] = Instance.new("Frame", G2L["92"])
    G2L["b9"]["BorderSizePixel"] = 0
    G2L["b9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["b9"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["b9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["b9"]["Name"] = [[health]]
    G2L["b9"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.health.text
    G2L["ba"] = Instance.new("TextLabel", G2L["b9"])
    G2L["ba"]["TextStrokeTransparency"] = 0
    G2L["ba"]["BorderSizePixel"] = 0
    G2L["ba"]["TextSize"] = 18
    G2L["ba"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["ba"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["ba"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["ba"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["ba"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["ba"]["BackgroundTransparency"] = 1
    G2L["ba"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["ba"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ba"]["Text"] = [[tracers]]
    G2L["ba"]["Name"] = [[text]]
    G2L["ba"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.health.button
    G2L["bb"] = Instance.new("Frame", G2L["b9"])
    G2L["bb"]["BorderSizePixel"] = 0
    G2L["bb"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["bb"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["bb"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["bb"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["bb"]["Name"] = [[button]]
    G2L["bb"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.options.health.button.UIStroke
    G2L["bc"] = Instance.new("UIStroke", G2L["bb"])
    G2L["bc"]["Thickness"] = 1.3
    G2L["bc"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["bc"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["bc"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.offscreenarrow
    G2L["bd"] = Instance.new("Frame", G2L["92"])
    G2L["bd"]["BorderSizePixel"] = 0
    G2L["bd"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["bd"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["bd"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["bd"]["Name"] = [[offscreenarrow]]
    G2L["bd"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.offscreenarrow.text
    G2L["be"] = Instance.new("TextLabel", G2L["bd"])
    G2L["be"]["TextStrokeTransparency"] = 0
    G2L["be"]["BorderSizePixel"] = 0
    G2L["be"]["TextSize"] = 18
    G2L["be"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["be"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["be"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["be"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["be"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["be"]["BackgroundTransparency"] = 1
    G2L["be"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["be"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["be"]["Text"] = [[offscreen arrow]]
    G2L["be"]["Name"] = [[text]]
    G2L["be"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.offscreenarrow.button
    G2L["bf"] = Instance.new("Frame", G2L["bd"])
    G2L["bf"]["BorderSizePixel"] = 0
    G2L["bf"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["bf"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["bf"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["bf"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["bf"]["Name"] = [[button]]
    G2L["bf"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.options.offscreenarrow.button.UIStroke
    G2L["c0"] = Instance.new("UIStroke", G2L["bf"])
    G2L["c0"]["Thickness"] = 1.3
    G2L["c0"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["c0"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["c0"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.offscreencolor
    G2L["c1"] = Instance.new("Frame", G2L["92"])
    G2L["c1"]["BorderSizePixel"] = 0
    G2L["c1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["c1"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["c1"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["c1"]["Name"] = [[offscreencolor]]
    G2L["c1"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.offscreencolor.text
    G2L["c2"] = Instance.new("TextLabel", G2L["c1"])
    G2L["c2"]["TextStrokeTransparency"] = 0
    G2L["c2"]["BorderSizePixel"] = 0
    G2L["c2"]["TextSize"] = 18
    G2L["c2"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["c2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["c2"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["c2"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["c2"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["c2"]["BackgroundTransparency"] = 1
    G2L["c2"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["c2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["c2"]["Text"] = [[offscreen color]]
    G2L["c2"]["Name"] = [[text]]
    G2L["c2"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.offscreencolor.colorchanger
    G2L["c3"] = Instance.new("Frame", G2L["c1"])
    G2L["c3"]["BorderSizePixel"] = 0
    G2L["c3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["c3"]["Size"] = UDim2.new(0, 40, 0, 10)
    G2L["c3"]["Position"] = UDim2.new(0.68406, 0, 0.22, 0)
    G2L["c3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["c3"]["Name"] = [[colorchanger]]

    -- StarterGui.baggyware.main.windows.visualsframe.options.offscreencolor.colorchanger.UIStroke
    G2L["c4"] = Instance.new("UIStroke", G2L["c3"])
    G2L["c4"]["Thickness"] = 1.3
    G2L["c4"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["c4"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["c4"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.options.chamscolor
    G2L["c5"] = Instance.new("Frame", G2L["92"])
    G2L["c5"]["BorderSizePixel"] = 0
    G2L["c5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["c5"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["c5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["c5"]["Name"] = [[chamscolor]]
    G2L["c5"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.options.chamscolor.text
    G2L["c6"] = Instance.new("TextLabel", G2L["c5"])
    G2L["c6"]["TextStrokeTransparency"] = 0
    G2L["c6"]["BorderSizePixel"] = 0
    G2L["c6"]["TextSize"] = 18
    G2L["c6"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["c6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["c6"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["c6"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["c6"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["c6"]["BackgroundTransparency"] = 1
    G2L["c6"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["c6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["c6"]["Text"] = [[chams color]]
    G2L["c6"]["Name"] = [[text]]
    G2L["c6"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.options.chamscolor.colorchanger
    G2L["c7"] = Instance.new("Frame", G2L["c5"])
    G2L["c7"]["BorderSizePixel"] = 0
    G2L["c7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["c7"]["Size"] = UDim2.new(0, 40, 0, 10)
    G2L["c7"]["Position"] = UDim2.new(0.68406, 0, 0.22, 0)
    G2L["c7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["c7"]["Name"] = [[colorchanger]]

    -- StarterGui.baggyware.main.windows.visualsframe.options.chamscolor.colorchanger.UIStroke
    G2L["c8"] = Instance.new("UIStroke", G2L["c7"])
    G2L["c8"]["Thickness"] = 1.3
    G2L["c8"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["c8"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["c8"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.filters
    G2L["c9"] = Instance.new("Frame", G2L["7c"])
    G2L["c9"]["BorderSizePixel"] = 0
    G2L["c9"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["c9"]["Size"] = UDim2.new(0, 145, 0, 146)
    G2L["c9"]["Position"] = UDim2.new(0.00889, 0, 0.49938, 0)
    G2L["c9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["c9"]["Name"] = [[filters]]
    G2L["c9"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.visualsframe.filters.label
    G2L["ca"] = Instance.new("TextLabel", G2L["c9"])
    G2L["ca"]["TextStrokeTransparency"] = 0
    G2L["ca"]["BorderSizePixel"] = 0
    G2L["ca"]["TextSize"] = 20
    G2L["ca"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["ca"]["SelectionOrder"] = 1
    G2L["ca"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["ca"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["ca"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["ca"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["ca"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ca"]["Text"] = [[  filters]]
    G2L["ca"]["LayoutOrder"] = -1
    G2L["ca"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.visualsframe.filters.UIListLayout
    G2L["cb"] = Instance.new("UIListLayout", G2L["c9"])
    G2L["cb"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.visualsframe.filters.maxdistance
    G2L["cc"] = Instance.new("Frame", G2L["c9"])
    G2L["cc"]["BorderSizePixel"] = 0
    G2L["cc"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["cc"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["cc"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["cc"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["cc"]["Name"] = [[maxdistance]]
    G2L["cc"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.filters.maxdistance.text
    G2L["cd"] = Instance.new("TextLabel", G2L["cc"])
    G2L["cd"]["TextStrokeTransparency"] = 0
    G2L["cd"]["BorderSizePixel"] = 0
    G2L["cd"]["TextSize"] = 18
    G2L["cd"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["cd"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["cd"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["cd"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["cd"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["cd"]["BackgroundTransparency"] = 1
    G2L["cd"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["cd"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["cd"]["Text"] = [[max distance - ]]
    G2L["cd"]["Name"] = [[text]]
    G2L["cd"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.filters.maxdistance.slider
    G2L["ce"] = Instance.new("Frame", G2L["cc"])
    G2L["ce"]["BorderSizePixel"] = 0
    G2L["ce"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ce"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["ce"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["ce"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ce"]["Name"] = [[slider]]
    G2L["ce"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.filters.maxdistance.slider.UIStroke
    G2L["cf"] = Instance.new("UIStroke", G2L["ce"])
    G2L["cf"]["Thickness"] = 1.3
    G2L["cf"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["cf"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["cf"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.filters.maxdistance.number
    G2L["d0"] = Instance.new("TextBox", G2L["cc"])
    G2L["d0"]["TextStrokeTransparency"] = 0
    G2L["d0"]["Name"] = [[number]]
    G2L["d0"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["d0"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["d0"]["BorderSizePixel"] = 0
    G2L["d0"]["TextWrapped"] = true
    G2L["d0"]["TextSize"] = 18
    G2L["d0"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["d0"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["d0"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["d0"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["d0"]["ClearTextOnFocus"] = false
    G2L["d0"]["Size"] = UDim2.new(0, 56, 0, 20)
    G2L["d0"]["Position"] = UDim2.new(0.56715, 0, 0, 0)
    G2L["d0"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d0"]["Text"] = [[0]]
    G2L["d0"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.filters.enabled
    G2L["d1"] = Instance.new("Frame", G2L["c9"])
    G2L["d1"]["BorderSizePixel"] = 0
    G2L["d1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["d1"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["d1"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d1"]["Name"] = [[enabled]]
    G2L["d1"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.filters.enabled.button
    G2L["d2"] = Instance.new("Frame", G2L["d1"])
    G2L["d2"]["BorderSizePixel"] = 0
    G2L["d2"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d2"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["d2"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["d2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d2"]["Name"] = [[button]]
    G2L["d2"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.filters.enabled.button.UIStroke
    G2L["d3"] = Instance.new("UIStroke", G2L["d2"])
    G2L["d3"]["Thickness"] = 1.3
    G2L["d3"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["d3"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["d3"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.filters.enabled.text
    G2L["d4"] = Instance.new("TextLabel", G2L["d1"])
    G2L["d4"]["TextStrokeTransparency"] = 0
    G2L["d4"]["BorderSizePixel"] = 0
    G2L["d4"]["TextSize"] = 18
    G2L["d4"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["d4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["d4"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["d4"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["d4"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["d4"]["BackgroundTransparency"] = 1
    G2L["d4"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["d4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d4"]["Text"] = [[enabled]]
    G2L["d4"]["Name"] = [[text]]
    G2L["d4"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.filters.friend
    G2L["d5"] = Instance.new("Frame", G2L["c9"])
    G2L["d5"]["BorderSizePixel"] = 0
    G2L["d5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["d5"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["d5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d5"]["Name"] = [[friend]]
    G2L["d5"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.filters.friend.text
    G2L["d6"] = Instance.new("TextLabel", G2L["d5"])
    G2L["d6"]["TextStrokeTransparency"] = 0
    G2L["d6"]["BorderSizePixel"] = 0
    G2L["d6"]["TextSize"] = 18
    G2L["d6"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["d6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["d6"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["d6"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["d6"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["d6"]["BackgroundTransparency"] = 1
    G2L["d6"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["d6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d6"]["Text"] = [[friendly]]
    G2L["d6"]["Name"] = [[text]]
    G2L["d6"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.filters.friend.button
    G2L["d7"] = Instance.new("Frame", G2L["d5"])
    G2L["d7"]["BorderSizePixel"] = 0
    G2L["d7"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d7"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["d7"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["d7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d7"]["Name"] = [[button]]
    G2L["d7"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.filters.friend.button.UIStroke
    G2L["d8"] = Instance.new("UIStroke", G2L["d7"])
    G2L["d8"]["Thickness"] = 1.3
    G2L["d8"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["d8"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["d8"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.filters.downed
    G2L["d9"] = Instance.new("Frame", G2L["c9"])
    G2L["d9"]["BorderSizePixel"] = 0
    G2L["d9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["d9"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["d9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["d9"]["Name"] = [[downed]]
    G2L["d9"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.filters.downed.text
    G2L["da"] = Instance.new("TextLabel", G2L["d9"])
    G2L["da"]["TextStrokeTransparency"] = 0
    G2L["da"]["BorderSizePixel"] = 0
    G2L["da"]["TextSize"] = 18
    G2L["da"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["da"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["da"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["da"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["da"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["da"]["BackgroundTransparency"] = 1
    G2L["da"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["da"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["da"]["Text"] = [[downed]]
    G2L["da"]["Name"] = [[text]]
    G2L["da"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.filters.downed.button
    G2L["db"] = Instance.new("Frame", G2L["d9"])
    G2L["db"]["BorderSizePixel"] = 0
    G2L["db"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["db"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["db"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["db"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["db"]["Name"] = [[button]]
    G2L["db"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.filters.downed.button.UIStroke
    G2L["dc"] = Instance.new("UIStroke", G2L["db"])
    G2L["dc"]["Thickness"] = 1.3
    G2L["dc"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["dc"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["dc"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.filters.dead
    G2L["dd"] = Instance.new("Frame", G2L["c9"])
    G2L["dd"]["BorderSizePixel"] = 0
    G2L["dd"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["dd"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["dd"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["dd"]["Name"] = [[dead]]
    G2L["dd"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.filters.dead.text
    G2L["de"] = Instance.new("TextLabel", G2L["dd"])
    G2L["de"]["TextStrokeTransparency"] = 0
    G2L["de"]["BorderSizePixel"] = 0
    G2L["de"]["TextSize"] = 18
    G2L["de"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["de"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["de"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["de"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["de"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["de"]["BackgroundTransparency"] = 1
    G2L["de"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["de"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["de"]["Text"] = [[dead]]
    G2L["de"]["Name"] = [[text]]
    G2L["de"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.filters.dead.button
    G2L["df"] = Instance.new("Frame", G2L["dd"])
    G2L["df"]["BorderSizePixel"] = 0
    G2L["df"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["df"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["df"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["df"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["df"]["Name"] = [[button]]
    G2L["df"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.filters.dead.button.UIStroke
    G2L["e0"] = Instance.new("UIStroke", G2L["df"])
    G2L["e0"]["Thickness"] = 1.3
    G2L["e0"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["e0"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["e0"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.selection
    G2L["e1"] = Instance.new("Frame", G2L["7c"])
    G2L["e1"]["BorderSizePixel"] = 0
    G2L["e1"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e1"]["Size"] = UDim2.new(0, 145, 0, 142)
    G2L["e1"]["Position"] = UDim2.new(0.00889, 0, 0.08, 0)
    G2L["e1"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e1"]["Name"] = [[selection]]
    G2L["e1"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.visualsframe.selection.label
    G2L["e2"] = Instance.new("TextLabel", G2L["e1"])
    G2L["e2"]["TextStrokeTransparency"] = 0
    G2L["e2"]["BorderSizePixel"] = 0
    G2L["e2"]["TextSize"] = 20
    G2L["e2"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["e2"]["SelectionOrder"] = 1
    G2L["e2"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["e2"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["e2"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["e2"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["e2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e2"]["Text"] = [[  selection]]
    G2L["e2"]["LayoutOrder"] = -1
    G2L["e2"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.visualsframe.selection.sf
    G2L["e3"] = Instance.new("ScrollingFrame", G2L["e1"])
    G2L["e3"]["Active"] = true
    G2L["e3"]["BorderSizePixel"] = 0
    G2L["e3"]["Name"] = [[sf]]
    G2L["e3"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41)
    G2L["e3"]["VerticalScrollBarPosition"] = Enum.VerticalScrollBarPosition.Left
    G2L["e3"]["Size"] = UDim2.new(0, 137, 0, 112)
    G2L["e3"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e3"]["Position"] = UDim2.new(0.02759, 0, 0.16901, 0)
    G2L["e3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e3"]["ScrollBarThickness"] = 3

    -- StarterGui.baggyware.main.windows.visualsframe.selection.sf.player
    G2L["e4"] = Instance.new("TextButton", G2L["e3"])
    G2L["e4"]["TextWrapped"] = true
    G2L["e4"]["TextStrokeTransparency"] = 0
    G2L["e4"]["BorderSizePixel"] = 0
    G2L["e4"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["e4"]["TextSize"] = 14
    G2L["e4"]["TextScaled"] = true
    G2L["e4"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["e4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["e4"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    G2L["e4"]["BackgroundTransparency"] = 1
    G2L["e4"]["Size"] = UDim2.new(0, 137, 0, 20)
    G2L["e4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e4"]["Text"] = [[   player]]
    G2L["e4"]["Name"] = [[player]]

    -- StarterGui.baggyware.main.windows.visualsframe.selection.sf.UIListLayout
    G2L["e5"] = Instance.new("UIListLayout", G2L["e3"])
    G2L["e5"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.visualsframe.selection.sf.dealer
    G2L["e6"] = Instance.new("TextButton", G2L["e3"])
    G2L["e6"]["TextWrapped"] = true
    G2L["e6"]["TextStrokeTransparency"] = 0
    G2L["e6"]["BorderSizePixel"] = 0
    G2L["e6"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["e6"]["TextSize"] = 14
    G2L["e6"]["TextScaled"] = true
    G2L["e6"]["TextColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["e6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["e6"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    G2L["e6"]["BackgroundTransparency"] = 1
    G2L["e6"]["Size"] = UDim2.new(0, 137, 0, 20)
    G2L["e6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e6"]["Text"] = [[   dealer]]
    G2L["e6"]["Name"] = [[dealer]]

    -- StarterGui.baggyware.main.windows.visualsframe.selection.sf.droppeditems
    G2L["e7"] = Instance.new("TextButton", G2L["e3"])
    G2L["e7"]["TextWrapped"] = true
    G2L["e7"]["TextStrokeTransparency"] = 0
    G2L["e7"]["BorderSizePixel"] = 0
    G2L["e7"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["e7"]["TextSize"] = 14
    G2L["e7"]["TextScaled"] = true
    G2L["e7"]["TextColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["e7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["e7"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    G2L["e7"]["BackgroundTransparency"] = 1
    G2L["e7"]["Size"] = UDim2.new(0, 137, 0, 20)
    G2L["e7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e7"]["Text"] = [[   dropped items]]
    G2L["e7"]["Name"] = [[droppeditems]]

    -- StarterGui.baggyware.main.windows.visualsframe.selection.sf.crates
    G2L["e8"] = Instance.new("TextButton", G2L["e3"])
    G2L["e8"]["TextWrapped"] = true
    G2L["e8"]["TextStrokeTransparency"] = 0
    G2L["e8"]["BorderSizePixel"] = 0
    G2L["e8"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["e8"]["TextSize"] = 14
    G2L["e8"]["TextScaled"] = true
    G2L["e8"]["TextColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["e8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["e8"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    G2L["e8"]["BackgroundTransparency"] = 1
    G2L["e8"]["Size"] = UDim2.new(0, 137, 0, 20)
    G2L["e8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e8"]["Text"] = [[   crates]]
    G2L["e8"]["Name"] = [[crates]]

    -- StarterGui.baggyware.main.windows.visualsframe.selection.sf.safes
    G2L["e9"] = Instance.new("TextButton", G2L["e3"])
    G2L["e9"]["TextWrapped"] = true
    G2L["e9"]["TextStrokeTransparency"] = 0
    G2L["e9"]["BorderSizePixel"] = 0
    G2L["e9"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["e9"]["TextSize"] = 14
    G2L["e9"]["TextScaled"] = true
    G2L["e9"]["TextColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["e9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["e9"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    G2L["e9"]["BackgroundTransparency"] = 1
    G2L["e9"]["Size"] = UDim2.new(0, 137, 0, 20)
    G2L["e9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["e9"]["Text"] = [[   safes]]
    G2L["e9"]["Name"] = [[safes]]

    -- StarterGui.baggyware.main.windows.visualsframe.selection.sf.UIStroke
    G2L["ea"] = Instance.new("UIStroke", G2L["e3"])
    G2L["ea"]["Thickness"] = 1.5
    G2L["ea"]["Color"] = Color3.fromRGB(34, 85, 114)
    G2L["ea"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.selection.UIStroke
    G2L["eb"] = Instance.new("UIStroke", G2L["e1"])
    G2L["eb"]["Thickness"] = 1.5
    G2L["eb"]["Color"] = Color3.fromRGB(34, 85, 114)
    G2L["eb"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.radar
    G2L["ec"] = Instance.new("Frame", G2L["7c"])
    G2L["ec"]["BorderSizePixel"] = 0
    G2L["ec"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ec"]["Size"] = UDim2.new(0, 143, 0, 142)
    G2L["ec"]["Position"] = UDim2.new(0.67111, 0, 0.08, 0)
    G2L["ec"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ec"]["Name"] = [[radar]]
    G2L["ec"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.visualsframe.radar.label
    G2L["ed"] = Instance.new("TextLabel", G2L["ec"])
    G2L["ed"]["TextStrokeTransparency"] = 0
    G2L["ed"]["BorderSizePixel"] = 0
    G2L["ed"]["TextSize"] = 20
    G2L["ed"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["ed"]["SelectionOrder"] = 1
    G2L["ed"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["ed"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["ed"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["ed"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["ed"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ed"]["Text"] = [[  radar]]
    G2L["ed"]["LayoutOrder"] = -1
    G2L["ed"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.visualsframe.radar.UIListLayout
    G2L["ee"] = Instance.new("UIListLayout", G2L["ec"])
    G2L["ee"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.visualsframe.radar.enabled
    G2L["ef"] = Instance.new("Frame", G2L["ec"])
    G2L["ef"]["BorderSizePixel"] = 0
    G2L["ef"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["ef"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["ef"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["ef"]["Name"] = [[enabled]]
    G2L["ef"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.radar.enabled.text
    G2L["f0"] = Instance.new("TextLabel", G2L["ef"])
    G2L["f0"]["TextStrokeTransparency"] = 0
    G2L["f0"]["BorderSizePixel"] = 0
    G2L["f0"]["TextSize"] = 18
    G2L["f0"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["f0"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f0"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["f0"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["f0"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f0"]["BackgroundTransparency"] = 1
    G2L["f0"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["f0"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f0"]["Text"] = [[enabled]]
    G2L["f0"]["Name"] = [[text]]
    G2L["f0"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.radar.enabled.button
    G2L["f1"] = Instance.new("Frame", G2L["ef"])
    G2L["f1"]["BorderSizePixel"] = 0
    G2L["f1"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f1"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["f1"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["f1"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f1"]["Name"] = [[button]]
    G2L["f1"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.radar.enabled.button.UIStroke
    G2L["f2"] = Instance.new("UIStroke", G2L["f1"])
    G2L["f2"]["Thickness"] = 1.3
    G2L["f2"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["f2"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["f2"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.radar.range
    G2L["f3"] = Instance.new("Frame", G2L["ec"])
    G2L["f3"]["BorderSizePixel"] = 0
    G2L["f3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f3"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["f3"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["f3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f3"]["Name"] = [[range]]
    G2L["f3"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.radar.range.text
    G2L["f4"] = Instance.new("TextLabel", G2L["f3"])
    G2L["f4"]["TextStrokeTransparency"] = 0
    G2L["f4"]["BorderSizePixel"] = 0
    G2L["f4"]["TextSize"] = 18
    G2L["f4"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["f4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f4"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["f4"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["f4"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f4"]["BackgroundTransparency"] = 1
    G2L["f4"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["f4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f4"]["Text"] = [[range - ]]
    G2L["f4"]["Name"] = [[text]]
    G2L["f4"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.radar.range.slider
    G2L["f5"] = Instance.new("Frame", G2L["f3"])
    G2L["f5"]["BorderSizePixel"] = 0
    G2L["f5"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f5"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["f5"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["f5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f5"]["Name"] = [[slider]]
    G2L["f5"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.radar.range.slider.UIStroke
    G2L["f6"] = Instance.new("UIStroke", G2L["f5"])
    G2L["f6"]["Thickness"] = 1.3
    G2L["f6"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["f6"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["f6"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.radar.range.number
    G2L["f7"] = Instance.new("TextBox", G2L["f3"])
    G2L["f7"]["TextStrokeTransparency"] = 0
    G2L["f7"]["Name"] = [[number]]
    G2L["f7"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["f7"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["f7"]["BorderSizePixel"] = 0
    G2L["f7"]["TextWrapped"] = true
    G2L["f7"]["TextSize"] = 18
    G2L["f7"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["f7"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["f7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f7"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["f7"]["ClearTextOnFocus"] = false
    G2L["f7"]["Size"] = UDim2.new(0, 93, 0, 20)
    G2L["f7"]["Position"] = UDim2.new(0.31724, 0, 0, 0)
    G2L["f7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f7"]["Text"] = [[200]]
    G2L["f7"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.radar.players
    G2L["f8"] = Instance.new("Frame", G2L["ec"])
    G2L["f8"]["BorderSizePixel"] = 0
    G2L["f8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f8"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["f8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f8"]["Name"] = [[players]]
    G2L["f8"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.radar.players.text
    G2L["f9"] = Instance.new("TextLabel", G2L["f8"])
    G2L["f9"]["TextStrokeTransparency"] = 0
    G2L["f9"]["BorderSizePixel"] = 0
    G2L["f9"]["TextSize"] = 18
    G2L["f9"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["f9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f9"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["f9"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["f9"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["f9"]["BackgroundTransparency"] = 1
    G2L["f9"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["f9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["f9"]["Text"] = [[players]]
    G2L["f9"]["Name"] = [[text]]
    G2L["f9"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.radar.players.button
    G2L["fa"] = Instance.new("Frame", G2L["f8"])
    G2L["fa"]["BorderSizePixel"] = 0
    G2L["fa"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["fa"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["fa"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["fa"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["fa"]["Name"] = [[button]]
    G2L["fa"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.radar.players.button.UIStroke
    G2L["fb"] = Instance.new("UIStroke", G2L["fa"])
    G2L["fb"]["Thickness"] = 1.3
    G2L["fb"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["fb"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["fb"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.radar.dealers
    G2L["fc"] = Instance.new("Frame", G2L["ec"])
    G2L["fc"]["BorderSizePixel"] = 0
    G2L["fc"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["fc"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["fc"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["fc"]["Name"] = [[dealers]]
    G2L["fc"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.radar.dealers.text
    G2L["fd"] = Instance.new("TextLabel", G2L["fc"])
    G2L["fd"]["TextStrokeTransparency"] = 0
    G2L["fd"]["BorderSizePixel"] = 0
    G2L["fd"]["TextSize"] = 18
    G2L["fd"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["fd"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["fd"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["fd"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["fd"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["fd"]["BackgroundTransparency"] = 1
    G2L["fd"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["fd"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["fd"]["Text"] = [[dealers]]
    G2L["fd"]["Name"] = [[text]]
    G2L["fd"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.radar.dealers.button
    G2L["fe"] = Instance.new("Frame", G2L["fc"])
    G2L["fe"]["BorderSizePixel"] = 0
    G2L["fe"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["fe"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["fe"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["fe"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["fe"]["Name"] = [[button]]
    G2L["fe"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.radar.dealers.button.UIStroke
    G2L["ff"] = Instance.new("UIStroke", G2L["fe"])
    G2L["ff"]["Thickness"] = 1.3
    G2L["ff"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["ff"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["ff"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.visualsframe.radar.loot
    G2L["100"] = Instance.new("Frame", G2L["ec"])
    G2L["100"]["BorderSizePixel"] = 0
    G2L["100"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["100"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["100"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["100"]["Name"] = [[loot]]
    G2L["100"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.visualsframe.radar.loot.text
    G2L["101"] = Instance.new("TextLabel", G2L["100"])
    G2L["101"]["TextStrokeTransparency"] = 0
    G2L["101"]["BorderSizePixel"] = 0
    G2L["101"]["TextSize"] = 18
    G2L["101"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["101"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["101"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["101"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["101"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["101"]["BackgroundTransparency"] = 1
    G2L["101"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["101"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["101"]["Text"] = [[loot]]
    G2L["101"]["Name"] = [[text]]
    G2L["101"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.visualsframe.radar.loot.button
    G2L["102"] = Instance.new("Frame", G2L["100"])
    G2L["102"]["BorderSizePixel"] = 0
    G2L["102"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["102"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["102"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["102"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["102"]["Name"] = [[button]]
    G2L["102"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.visualsframe.radar.loot.button.UIStroke
    G2L["103"] = Instance.new("UIStroke", G2L["102"])
    G2L["103"]["Thickness"] = 1.3
    G2L["103"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["103"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["103"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe
    G2L["104"] = Instance.new("Frame", G2L["8"])
    G2L["104"]["Visible"] = false
    G2L["104"]["BorderSizePixel"] = 0
    G2L["104"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["104"]["Size"] = UDim2.new(0, 450, 0, 350)
    G2L["104"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["104"]["Name"] = [[aimbotframe]]
    G2L["104"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot
    G2L["105"] = Instance.new("Frame", G2L["104"])
    G2L["105"]["BorderSizePixel"] = 0
    G2L["105"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["105"]["Size"] = UDim2.new(0, 143, 0, 146)
    G2L["105"]["Position"] = UDim2.new(0.67111, 0, 0.49938, 0)
    G2L["105"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["105"]["Name"] = [[ragebot]]
    G2L["105"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.label
    G2L["106"] = Instance.new("TextLabel", G2L["105"])
    G2L["106"]["TextStrokeTransparency"] = 0
    G2L["106"]["BorderSizePixel"] = 0
    G2L["106"]["TextSize"] = 20
    G2L["106"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["106"]["SelectionOrder"] = 1
    G2L["106"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["106"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["106"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["106"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["106"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["106"]["Text"] = [[  ragebot]]
    G2L["106"]["LayoutOrder"] = -1
    G2L["106"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.enabled
    G2L["107"] = Instance.new("Frame", G2L["105"])
    G2L["107"]["BorderSizePixel"] = 0
    G2L["107"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["107"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["107"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["107"]["Name"] = [[enabled]]
    G2L["107"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.enabled.text
    G2L["108"] = Instance.new("TextLabel", G2L["107"])
    G2L["108"]["TextStrokeTransparency"] = 0
    G2L["108"]["BorderSizePixel"] = 0
    G2L["108"]["TextSize"] = 18
    G2L["108"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["108"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["108"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["108"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["108"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["108"]["BackgroundTransparency"] = 1
    G2L["108"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["108"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["108"]["Text"] = [[enabled]]
    G2L["108"]["Name"] = [[text]]
    G2L["108"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.enabled.button
    G2L["109"] = Instance.new("Frame", G2L["107"])
    G2L["109"]["BorderSizePixel"] = 0
    G2L["109"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["109"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["109"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["109"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["109"]["Name"] = [[button]]
    G2L["109"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.enabled.button.UIStroke
    G2L["10a"] = Instance.new("UIStroke", G2L["109"])
    G2L["10a"]["Thickness"] = 1.3
    G2L["10a"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["10a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["10a"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.enabled.hotkey
    G2L["10b"] = Instance.new("TextLabel", G2L["107"])
    G2L["10b"]["TextStrokeTransparency"] = 0
    G2L["10b"]["BorderSizePixel"] = 0
    G2L["10b"]["TextSize"] = 18
    G2L["10b"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["10b"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["10b"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["10b"]["BackgroundTransparency"] = 0.65
    G2L["10b"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["10b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["10b"]["Text"] = [[nil]]
    G2L["10b"]["Name"] = [[hotkey]]
    G2L["10b"]["Position"] = UDim2.new(0.61883, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.enabled.hotkey.UIStroke
    G2L["10c"] = Instance.new("UIStroke", G2L["10b"])
    G2L["10c"]["Thickness"] = 1.4
    G2L["10c"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["10c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["10c"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.UIListLayout
    G2L["10d"] = Instance.new("UIListLayout", G2L["105"])
    G2L["10d"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.manipulation
    G2L["10e"] = Instance.new("Frame", G2L["105"])
    G2L["10e"]["BorderSizePixel"] = 0
    G2L["10e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["10e"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["10e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["10e"]["Name"] = [[manipulation]]
    G2L["10e"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.manipulation.text
    G2L["10f"] = Instance.new("TextLabel", G2L["10e"])
    G2L["10f"]["TextStrokeTransparency"] = 0
    G2L["10f"]["BorderSizePixel"] = 0
    G2L["10f"]["TextSize"] = 18
    G2L["10f"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["10f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["10f"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["10f"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["10f"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["10f"]["BackgroundTransparency"] = 1
    G2L["10f"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["10f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["10f"]["Text"] = [[manipulation]]
    G2L["10f"]["Name"] = [[text]]
    G2L["10f"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.manipulation.button
    G2L["110"] = Instance.new("Frame", G2L["10e"])
    G2L["110"]["BorderSizePixel"] = 0
    G2L["110"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["110"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["110"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["110"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["110"]["Name"] = [[button]]
    G2L["110"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.manipulation.button.UIStroke
    G2L["111"] = Instance.new("UIStroke", G2L["110"])
    G2L["111"]["Thickness"] = 1.3
    G2L["111"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["111"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["111"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.manipulation.hotkey
    G2L["112"] = Instance.new("TextLabel", G2L["10e"])
    G2L["112"]["TextStrokeTransparency"] = 0
    G2L["112"]["BorderSizePixel"] = 0
    G2L["112"]["TextSize"] = 18
    G2L["112"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["112"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["112"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["112"]["BackgroundTransparency"] = 0.65
    G2L["112"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["112"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["112"]["Text"] = [[nil]]
    G2L["112"]["Name"] = [[hotkey]]
    G2L["112"]["Position"] = UDim2.new(0.61883, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.ragebot.manipulation.hotkey.UIStroke
    G2L["113"] = Instance.new("UIStroke", G2L["112"])
    G2L["113"]["Thickness"] = 1.4
    G2L["113"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["113"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["113"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.mods
    G2L["114"] = Instance.new("Frame", G2L["104"])
    G2L["114"]["BorderSizePixel"] = 0
    G2L["114"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["114"]["Size"] = UDim2.new(0, 145, 0, 145)
    G2L["114"]["Position"] = UDim2.new(0.00889, 0, 0.50286, 0)
    G2L["114"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["114"]["Name"] = [[mods]]
    G2L["114"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.UIListLayout
    G2L["115"] = Instance.new("UIListLayout", G2L["114"])
    G2L["115"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.label
    G2L["116"] = Instance.new("TextLabel", G2L["114"])
    G2L["116"]["TextStrokeTransparency"] = 0
    G2L["116"]["BorderSizePixel"] = 0
    G2L["116"]["TextSize"] = 20
    G2L["116"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["116"]["SelectionOrder"] = 1
    G2L["116"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["116"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["116"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["116"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["116"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["116"]["Text"] = [[  weapon modifications]]
    G2L["116"]["LayoutOrder"] = -1
    G2L["116"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.nospread
    G2L["117"] = Instance.new("Frame", G2L["114"])
    G2L["117"]["BorderSizePixel"] = 0
    G2L["117"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["117"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["117"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["117"]["Name"] = [[nospread]]
    G2L["117"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.nospread.text
    G2L["118"] = Instance.new("TextLabel", G2L["117"])
    G2L["118"]["TextStrokeTransparency"] = 0
    G2L["118"]["BorderSizePixel"] = 0
    G2L["118"]["TextSize"] = 18
    G2L["118"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["118"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["118"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["118"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["118"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["118"]["BackgroundTransparency"] = 1
    G2L["118"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["118"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["118"]["Text"] = [[no-spread]]
    G2L["118"]["Name"] = [[text]]
    G2L["118"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.nospread.button
    G2L["119"] = Instance.new("Frame", G2L["117"])
    G2L["119"]["BorderSizePixel"] = 0
    G2L["119"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["119"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["119"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["119"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["119"]["Name"] = [[button]]
    G2L["119"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.nospread.button.UIStroke
    G2L["11a"] = Instance.new("UIStroke", G2L["119"])
    G2L["11a"]["Thickness"] = 1.3
    G2L["11a"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["11a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["11a"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.wallbang
    G2L["11b"] = Instance.new("Frame", G2L["114"])
    G2L["11b"]["BorderSizePixel"] = 0
    G2L["11b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["11b"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["11b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["11b"]["Name"] = [[wallbang]]
    G2L["11b"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.wallbang.text
    G2L["11c"] = Instance.new("TextLabel", G2L["11b"])
    G2L["11c"]["TextStrokeTransparency"] = 0
    G2L["11c"]["BorderSizePixel"] = 0
    G2L["11c"]["TextSize"] = 18
    G2L["11c"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["11c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["11c"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["11c"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["11c"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["11c"]["BackgroundTransparency"] = 1
    G2L["11c"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["11c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["11c"]["Text"] = [[wallbang]]
    G2L["11c"]["Name"] = [[text]]
    G2L["11c"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.wallbang.button
    G2L["11d"] = Instance.new("Frame", G2L["11b"])
    G2L["11d"]["BorderSizePixel"] = 0
    G2L["11d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["11d"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["11d"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["11d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["11d"]["Name"] = [[button]]
    G2L["11d"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.wallbang.button.UIStroke
    G2L["11e"] = Instance.new("UIStroke", G2L["11d"])
    G2L["11e"]["Thickness"] = 1.3
    G2L["11e"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["11e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["11e"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.recoil
    G2L["11f"] = Instance.new("Frame", G2L["114"])
    G2L["11f"]["BorderSizePixel"] = 0
    G2L["11f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["11f"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["11f"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["11f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["11f"]["Name"] = [[recoil]]
    G2L["11f"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.recoil.text
    G2L["120"] = Instance.new("TextLabel", G2L["11f"])
    G2L["120"]["TextStrokeTransparency"] = 0
    G2L["120"]["BorderSizePixel"] = 0
    G2L["120"]["TextSize"] = 18
    G2L["120"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["120"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["120"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["120"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["120"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["120"]["BackgroundTransparency"] = 1
    G2L["120"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["120"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["120"]["Text"] = [[recoil multiplier - ]]
    G2L["120"]["Name"] = [[text]]
    G2L["120"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.recoil.slider
    G2L["121"] = Instance.new("Frame", G2L["11f"])
    G2L["121"]["BorderSizePixel"] = 0
    G2L["121"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["121"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["121"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["121"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["121"]["Name"] = [[slider]]
    G2L["121"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.recoil.slider.UIStroke
    G2L["122"] = Instance.new("UIStroke", G2L["121"])
    G2L["122"]["Thickness"] = 1.3
    G2L["122"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["122"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["122"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.recoil.number
    G2L["123"] = Instance.new("TextBox", G2L["11f"])
    G2L["123"]["CursorPosition"] = -1
    G2L["123"]["TextStrokeTransparency"] = 0
    G2L["123"]["Name"] = [[number]]
    G2L["123"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["123"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["123"]["BorderSizePixel"] = 0
    G2L["123"]["TextWrapped"] = true
    G2L["123"]["TextSize"] = 18
    G2L["123"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["123"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["123"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["123"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["123"]["ClearTextOnFocus"] = false
    G2L["123"]["Size"] = UDim2.new(0, 45, 0, 20)
    G2L["123"]["Position"] = UDim2.new(0.62234, 0, 0, 0)
    G2L["123"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["123"]["Text"] = [[1]]
    G2L["123"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.bulletspeed
    G2L["124"] = Instance.new("Frame", G2L["114"])
    G2L["124"]["BorderSizePixel"] = 0
    G2L["124"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["124"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["124"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["124"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["124"]["Name"] = [[bulletspeed]]
    G2L["124"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.bulletspeed.text
    G2L["125"] = Instance.new("TextLabel", G2L["124"])
    G2L["125"]["TextStrokeTransparency"] = 0
    G2L["125"]["BorderSizePixel"] = 0
    G2L["125"]["TextSize"] = 18
    G2L["125"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["125"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["125"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["125"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["125"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["125"]["BackgroundTransparency"] = 1
    G2L["125"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["125"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["125"]["Text"] = [[bullet speed - ]]
    G2L["125"]["Name"] = [[text]]
    G2L["125"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.bulletspeed.slider
    G2L["126"] = Instance.new("Frame", G2L["124"])
    G2L["126"]["BorderSizePixel"] = 0
    G2L["126"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["126"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["126"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["126"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["126"]["Name"] = [[slider]]
    G2L["126"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.bulletspeed.slider.UIStroke
    G2L["127"] = Instance.new("UIStroke", G2L["126"])
    G2L["127"]["Thickness"] = 1.3
    G2L["127"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["127"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["127"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.mods.bulletspeed.number
    G2L["128"] = Instance.new("TextBox", G2L["124"])
    G2L["128"]["TextStrokeTransparency"] = 0
    G2L["128"]["Name"] = [[number]]
    G2L["128"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["128"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["128"]["BorderSizePixel"] = 0
    G2L["128"]["TextWrapped"] = true
    G2L["128"]["TextSize"] = 18
    G2L["128"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["128"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["128"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["128"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["128"]["ClearTextOnFocus"] = false
    G2L["128"]["Size"] = UDim2.new(0, 59, 0, 20)
    G2L["128"]["Position"] = UDim2.new(0.53093, 0, 0, 0)
    G2L["128"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["128"]["Text"] = [[0]]
    G2L["128"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect
    G2L["129"] = Instance.new("Frame", G2L["104"])
    G2L["129"]["BorderSizePixel"] = 0
    G2L["129"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["129"]["Size"] = UDim2.new(0, 145, 0, 293)
    G2L["129"]["Position"] = UDim2.new(0.34, 0, 0.08, 0)
    G2L["129"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["129"]["Name"] = [[targetselect]]
    G2L["129"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.UIListLayout
    G2L["12a"] = Instance.new("UIListLayout", G2L["129"])
    G2L["12a"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.label
    G2L["12b"] = Instance.new("TextLabel", G2L["129"])
    G2L["12b"]["TextStrokeTransparency"] = 0
    G2L["12b"]["BorderSizePixel"] = 0
    G2L["12b"]["TextSize"] = 20
    G2L["12b"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["12b"]["SelectionOrder"] = 1
    G2L["12b"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["12b"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["12b"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["12b"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["12b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["12b"]["Text"] = [[  target selection]]
    G2L["12b"]["LayoutOrder"] = -1
    G2L["12b"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignorefriendlys
    G2L["12c"] = Instance.new("Frame", G2L["129"])
    G2L["12c"]["BorderSizePixel"] = 0
    G2L["12c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["12c"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["12c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["12c"]["Name"] = [[ignorefriendlys]]
    G2L["12c"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignorefriendlys.text
    G2L["12d"] = Instance.new("TextLabel", G2L["12c"])
    G2L["12d"]["TextStrokeTransparency"] = 0
    G2L["12d"]["BorderSizePixel"] = 0
    G2L["12d"]["TextSize"] = 18
    G2L["12d"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["12d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["12d"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["12d"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["12d"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["12d"]["BackgroundTransparency"] = 1
    G2L["12d"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["12d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["12d"]["Text"] = [[ignore friendlys]]
    G2L["12d"]["Name"] = [[text]]
    G2L["12d"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignorefriendlys.button
    G2L["12e"] = Instance.new("Frame", G2L["12c"])
    G2L["12e"]["BorderSizePixel"] = 0
    G2L["12e"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["12e"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["12e"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["12e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["12e"]["Name"] = [[button]]
    G2L["12e"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignorefriendlys.button.UIStroke
    G2L["12f"] = Instance.new("UIStroke", G2L["12e"])
    G2L["12f"]["Thickness"] = 1.3
    G2L["12f"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["12f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["12f"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignoreinvincible
    G2L["130"] = Instance.new("Frame", G2L["129"])
    G2L["130"]["BorderSizePixel"] = 0
    G2L["130"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["130"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["130"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["130"]["Name"] = [[ignoreinvincible]]
    G2L["130"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignoreinvincible.text
    G2L["131"] = Instance.new("TextLabel", G2L["130"])
    G2L["131"]["TextStrokeTransparency"] = 0
    G2L["131"]["BorderSizePixel"] = 0
    G2L["131"]["TextSize"] = 18
    G2L["131"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["131"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["131"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["131"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["131"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["131"]["BackgroundTransparency"] = 1
    G2L["131"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["131"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["131"]["Text"] = [[ignore invincible]]
    G2L["131"]["Name"] = [[text]]
    G2L["131"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignoreinvincible.button
    G2L["132"] = Instance.new("Frame", G2L["130"])
    G2L["132"]["BorderSizePixel"] = 0
    G2L["132"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["132"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["132"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["132"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["132"]["Name"] = [[button]]
    G2L["132"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignoreinvincible.button.UIStroke
    G2L["133"] = Instance.new("UIStroke", G2L["132"])
    G2L["133"]["Thickness"] = 1.3
    G2L["133"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["133"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["133"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignoredowned
    G2L["134"] = Instance.new("Frame", G2L["129"])
    G2L["134"]["BorderSizePixel"] = 0
    G2L["134"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["134"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["134"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["134"]["Name"] = [[ignoredowned]]
    G2L["134"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignoredowned.text
    G2L["135"] = Instance.new("TextLabel", G2L["134"])
    G2L["135"]["TextStrokeTransparency"] = 0
    G2L["135"]["BorderSizePixel"] = 0
    G2L["135"]["TextSize"] = 18
    G2L["135"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["135"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["135"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["135"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["135"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["135"]["BackgroundTransparency"] = 1
    G2L["135"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["135"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["135"]["Text"] = [[ignore downed]]
    G2L["135"]["Name"] = [[text]]
    G2L["135"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignoredowned.button
    G2L["136"] = Instance.new("Frame", G2L["134"])
    G2L["136"]["BorderSizePixel"] = 0
    G2L["136"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["136"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["136"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["136"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["136"]["Name"] = [[button]]
    G2L["136"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.ignoredowned.button.UIStroke
    G2L["137"] = Instance.new("UIStroke", G2L["136"])
    G2L["137"]["Thickness"] = 1.3
    G2L["137"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["137"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["137"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.hitbox
    G2L["138"] = Instance.new("Frame", G2L["129"])
    G2L["138"]["BorderSizePixel"] = 0
    G2L["138"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["138"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["138"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["138"]["Name"] = [[hitbox]]
    G2L["138"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.hitbox.text
    G2L["139"] = Instance.new("TextLabel", G2L["138"])
    G2L["139"]["TextStrokeTransparency"] = 0
    G2L["139"]["BorderSizePixel"] = 0
    G2L["139"]["TextSize"] = 18
    G2L["139"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["139"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["139"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["139"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["139"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["139"]["BackgroundTransparency"] = 1
    G2L["139"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["139"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["139"]["Text"] = [[hit target]]
    G2L["139"]["Name"] = [[text]]
    G2L["139"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.hitbox.hotkey
    G2L["13a"] = Instance.new("TextLabel", G2L["138"])
    G2L["13a"]["TextStrokeTransparency"] = 0
    G2L["13a"]["BorderSizePixel"] = 0
    G2L["13a"]["TextSize"] = 18
    G2L["13a"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["13a"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["13a"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["13a"]["BackgroundTransparency"] = 0.65
    G2L["13a"]["Size"] = UDim2.new(0, 50, 0, 10)
    G2L["13a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["13a"]["Text"] = [[Head]]
    G2L["13a"]["Name"] = [[hotkey]]
    G2L["13a"]["Position"] = UDim2.new(0.59074, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.hitbox.hotkey.UIStroke
    G2L["13b"] = Instance.new("UIStroke", G2L["13a"])
    G2L["13b"]["Thickness"] = 1.4
    G2L["13b"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["13b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["13b"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.maxdistance
    G2L["13c"] = Instance.new("Frame", G2L["129"])
    G2L["13c"]["BorderSizePixel"] = 0
    G2L["13c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["13c"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["13c"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["13c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["13c"]["Name"] = [[maxdistance]]
    G2L["13c"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.maxdistance.text
    G2L["13d"] = Instance.new("TextLabel", G2L["13c"])
    G2L["13d"]["TextStrokeTransparency"] = 0
    G2L["13d"]["BorderSizePixel"] = 0
    G2L["13d"]["TextSize"] = 18
    G2L["13d"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["13d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["13d"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["13d"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["13d"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["13d"]["BackgroundTransparency"] = 1
    G2L["13d"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["13d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["13d"]["Text"] = [[max distance - ]]
    G2L["13d"]["Name"] = [[text]]
    G2L["13d"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.maxdistance.slider
    G2L["13e"] = Instance.new("Frame", G2L["13c"])
    G2L["13e"]["BorderSizePixel"] = 0
    G2L["13e"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["13e"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["13e"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["13e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["13e"]["Name"] = [[slider]]
    G2L["13e"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.maxdistance.slider.UIStroke
    G2L["13f"] = Instance.new("UIStroke", G2L["13e"])
    G2L["13f"]["Thickness"] = 1.3
    G2L["13f"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["13f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["13f"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.maxdistance.number
    G2L["140"] = Instance.new("TextBox", G2L["13c"])
    G2L["140"]["CursorPosition"] = -1
    G2L["140"]["TextStrokeTransparency"] = 0
    G2L["140"]["Name"] = [[number]]
    G2L["140"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["140"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["140"]["BorderSizePixel"] = 0
    G2L["140"]["TextWrapped"] = true
    G2L["140"]["TextSize"] = 18
    G2L["140"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["140"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["140"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["140"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["140"]["ClearTextOnFocus"] = false
    G2L["140"]["Size"] = UDim2.new(0, 52, 0, 20)
    G2L["140"]["Position"] = UDim2.new(0.59074, 0, 0, 0)
    G2L["140"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["140"]["Text"] = [[0]]
    G2L["140"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.fovradius
    G2L["145"] = Instance.new("Frame", G2L["129"])
    G2L["145"]["BorderSizePixel"] = 0
    G2L["145"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["145"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["145"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["145"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["145"]["Name"] = [[fovradius]]
    G2L["145"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.fovradius.text
    G2L["146"] = Instance.new("TextLabel", G2L["145"])
    G2L["146"]["TextStrokeTransparency"] = 0
    G2L["146"]["BorderSizePixel"] = 0
    G2L["146"]["TextSize"] = 18
    G2L["146"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["146"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["146"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["146"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["146"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["146"]["BackgroundTransparency"] = 1
    G2L["146"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["146"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["146"]["Text"] = [[fov radius -]]
    G2L["146"]["Name"] = [[text]]
    G2L["146"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.fovradius.slider
    G2L["147"] = Instance.new("Frame", G2L["145"])
    G2L["147"]["BorderSizePixel"] = 0
    G2L["147"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["147"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["147"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["147"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["147"]["Name"] = [[slider]]
    G2L["147"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.fovradius.slider.UIStroke
    G2L["148"] = Instance.new("UIStroke", G2L["147"])
    G2L["148"]["Thickness"] = 1.3
    G2L["148"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["148"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["148"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.fovradius.number
    G2L["149"] = Instance.new("TextBox", G2L["145"])
    G2L["149"]["CursorPosition"] = -1
    G2L["149"]["TextStrokeTransparency"] = 0
    G2L["149"]["Name"] = [[number]]
    G2L["149"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["149"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["149"]["BorderSizePixel"] = 0
    G2L["149"]["TextWrapped"] = true
    G2L["149"]["TextSize"] = 18
    G2L["149"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["149"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["149"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["149"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["149"]["ClearTextOnFocus"] = false
    G2L["149"]["Size"] = UDim2.new(0, 66, 0, 20)
    G2L["149"]["Position"] = UDim2.new(0.48729, 0, 0, 0)
    G2L["149"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["149"]["Text"] = [[0]]
    G2L["149"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.visible check
    G2L["14a"] = Instance.new("Frame", G2L["129"])
    G2L["14a"]["BorderSizePixel"] = 0
    G2L["14a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["14a"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["14a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["14a"]["Name"] = [[visible check]]
    G2L["14a"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.visible check.text
    G2L["14b"] = Instance.new("TextLabel", G2L["14a"])
    G2L["14b"]["TextStrokeTransparency"] = 0
    G2L["14b"]["BorderSizePixel"] = 0
    G2L["14b"]["TextSize"] = 18
    G2L["14b"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["14b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["14b"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["14b"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["14b"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["14b"]["BackgroundTransparency"] = 1
    G2L["14b"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["14b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["14b"]["Text"] = [[visible check]]
    G2L["14b"]["Name"] = [[text]]
    G2L["14b"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.visible check.button
    G2L["14c"] = Instance.new("Frame", G2L["14a"])
    G2L["14c"]["BorderSizePixel"] = 0
    G2L["14c"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["14c"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["14c"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["14c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["14c"]["Name"] = [[button]]
    G2L["14c"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.visible check.button.UIStroke
    G2L["14d"] = Instance.new("UIStroke", G2L["14c"])
    G2L["14d"]["Thickness"] = 1.3
    G2L["14d"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["14d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["14d"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn fov
    G2L["14e"] = Instance.new("Frame", G2L["129"])
    G2L["14e"]["BorderSizePixel"] = 0
    G2L["14e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["14e"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["14e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["14e"]["Name"] = [[drawn fov]]
    G2L["14e"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn fov.text
    G2L["14f"] = Instance.new("TextLabel", G2L["14e"])
    G2L["14f"]["TextStrokeTransparency"] = 0
    G2L["14f"]["BorderSizePixel"] = 0
    G2L["14f"]["TextSize"] = 18
    G2L["14f"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["14f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["14f"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["14f"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["14f"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["14f"]["BackgroundTransparency"] = 1
    G2L["14f"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["14f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["14f"]["Text"] = [[drawn fov]]
    G2L["14f"]["Name"] = [[text]]
    G2L["14f"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn fov.button
    G2L["150"] = Instance.new("Frame", G2L["14e"])
    G2L["150"]["BorderSizePixel"] = 0
    G2L["150"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["150"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["150"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["150"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["150"]["Name"] = [[button]]
    G2L["150"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn fov.button.UIStroke
    G2L["151"] = Instance.new("UIStroke", G2L["150"])
    G2L["151"]["Thickness"] = 1.3
    G2L["151"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["151"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["151"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn tracer
    G2L["152"] = Instance.new("Frame", G2L["129"])
    G2L["152"]["BorderSizePixel"] = 0
    G2L["152"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["152"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["152"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["152"]["Name"] = [[drawn tracer]]
    G2L["152"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn tracer.text
    G2L["153"] = Instance.new("TextLabel", G2L["152"])
    G2L["153"]["TextStrokeTransparency"] = 0
    G2L["153"]["BorderSizePixel"] = 0
    G2L["153"]["TextSize"] = 18
    G2L["153"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["153"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["153"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["153"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["153"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["153"]["BackgroundTransparency"] = 1
    G2L["153"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["153"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["153"]["Text"] = [[drawn tracer]]
    G2L["153"]["Name"] = [[text]]
    G2L["153"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn tracer.button
    G2L["154"] = Instance.new("Frame", G2L["152"])
    G2L["154"]["BorderSizePixel"] = 0
    G2L["154"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["154"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["154"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["154"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["154"]["Name"] = [[button]]
    G2L["154"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn tracer.button.UIStroke
    G2L["155"] = Instance.new("UIStroke", G2L["154"])
    G2L["155"]["Thickness"] = 1.3
    G2L["155"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["155"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["155"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn colors
    G2L["156"] = Instance.new("Frame", G2L["129"])
    G2L["156"]["BorderSizePixel"] = 0
    G2L["156"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["156"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["156"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["156"]["Name"] = [[drawn colors]]
    G2L["156"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn colors.text
    G2L["157"] = Instance.new("TextLabel", G2L["156"])
    G2L["157"]["TextStrokeTransparency"] = 0
    G2L["157"]["BorderSizePixel"] = 0
    G2L["157"]["TextSize"] = 18
    G2L["157"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["157"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["157"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["157"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["157"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["157"]["BackgroundTransparency"] = 1
    G2L["157"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["157"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["157"]["Text"] = [[drawn colors]]
    G2L["157"]["Name"] = [[text]]
    G2L["157"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn colors.colorchanger
    G2L["158"] = Instance.new("Frame", G2L["156"])
    G2L["158"]["BorderSizePixel"] = 0
    G2L["158"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["158"]["Size"] = UDim2.new(0, 40, 0, 10)
    G2L["158"]["Position"] = UDim2.new(0.68406, 0, 0.22, 0)
    G2L["158"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["158"]["Name"] = [[colorchanger]]

    -- StarterGui.baggyware.main.windows.aimbotframe.targetselect.drawn colors.colorchanger.UIStroke
    G2L["159"] = Instance.new("UIStroke", G2L["158"])
    G2L["159"]["Thickness"] = 1.3
    G2L["159"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["159"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["159"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot
    G2L["15a"] = Instance.new("Frame", G2L["104"])
    G2L["15a"]["BorderSizePixel"] = 0
    G2L["15a"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15a"]["Size"] = UDim2.new(0, 145, 0, 142)
    G2L["15a"]["Position"] = UDim2.new(0.00889, 0, 0.08, 0)
    G2L["15a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15a"]["Name"] = [[aimbot]]
    G2L["15a"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.enabled
    G2L["15b"] = Instance.new("Frame", G2L["15a"])
    G2L["15b"]["BorderSizePixel"] = 0
    G2L["15b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["15b"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["15b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15b"]["Name"] = [[enabled]]
    G2L["15b"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.enabled.text
    G2L["15c"] = Instance.new("TextLabel", G2L["15b"])
    G2L["15c"]["TextStrokeTransparency"] = 0
    G2L["15c"]["BorderSizePixel"] = 0
    G2L["15c"]["TextSize"] = 18
    G2L["15c"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["15c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["15c"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["15c"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["15c"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["15c"]["BackgroundTransparency"] = 1
    G2L["15c"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["15c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15c"]["Text"] = [[enabled]]
    G2L["15c"]["Name"] = [[text]]
    G2L["15c"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.enabled.button
    G2L["15d"] = Instance.new("Frame", G2L["15b"])
    G2L["15d"]["Active"] = true
    G2L["15d"]["BorderSizePixel"] = 0
    G2L["15d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15d"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["15d"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["15d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15d"]["Name"] = [[button]]
    G2L["15d"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.enabled.button.UIStroke
    G2L["15e"] = Instance.new("UIStroke", G2L["15d"])
    G2L["15e"]["Thickness"] = 1.3
    G2L["15e"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["15e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["15e"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.enabled.hotkey
    G2L["15f"] = Instance.new("TextLabel", G2L["15b"])
    G2L["15f"]["TextStrokeTransparency"] = 0
    G2L["15f"]["BorderSizePixel"] = 0
    G2L["15f"]["TextSize"] = 18
    G2L["15f"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15f"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["15f"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["15f"]["BackgroundTransparency"] = 0.65
    G2L["15f"]["Size"] = UDim2.new(0, 50, 0, 10)
    G2L["15f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["15f"]["Text"] = [[nil]]
    G2L["15f"]["Name"] = [[hotkey]]
    G2L["15f"]["Position"] = UDim2.new(0.48729, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.enabled.hotkey.UIStroke
    G2L["160"] = Instance.new("UIStroke", G2L["15f"])
    G2L["160"]["Thickness"] = 1.4
    G2L["160"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["160"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["160"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.aimkey
    G2L["161"] = Instance.new("Frame", G2L["15a"])
    G2L["161"]["BorderSizePixel"] = 0
    G2L["161"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["161"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["161"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["161"]["Name"] = [[aimkey]]
    G2L["161"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.aimkey.text
    G2L["162"] = Instance.new("TextLabel", G2L["161"])
    G2L["162"]["TextStrokeTransparency"] = 0
    G2L["162"]["BorderSizePixel"] = 0
    G2L["162"]["TextSize"] = 18
    G2L["162"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["162"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["162"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["162"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["162"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["162"]["BackgroundTransparency"] = 1
    G2L["162"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["162"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["162"]["Text"] = [[aim key]]
    G2L["162"]["Name"] = [[text]]
    G2L["162"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.aimkey.hotkey
    G2L["163"] = Instance.new("TextLabel", G2L["161"])
    G2L["163"]["TextStrokeTransparency"] = 0
    G2L["163"]["BorderSizePixel"] = 0
    G2L["163"]["TextSize"] = 18
    G2L["163"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["163"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["163"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["163"]["BackgroundTransparency"] = 0.65
    G2L["163"]["Size"] = UDim2.new(0, 50, 0, 10)
    G2L["163"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["163"]["Text"] = [[mouse 2]]
    G2L["163"]["Name"] = [[hotkey]]
    G2L["163"]["Position"] = UDim2.new(0.59701, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.aimkey.hotkey.UIStroke
    G2L["164"] = Instance.new("UIStroke", G2L["163"])
    G2L["164"]["Thickness"] = 1.4
    G2L["164"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["164"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["164"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.UIListLayout
    G2L["165"] = Instance.new("UIListLayout", G2L["15a"])
    G2L["165"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.label
    G2L["166"] = Instance.new("TextLabel", G2L["15a"])
    G2L["166"]["TextStrokeTransparency"] = 0
    G2L["166"]["BorderSizePixel"] = 0
    G2L["166"]["TextSize"] = 20
    G2L["166"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["166"]["SelectionOrder"] = 1
    G2L["166"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["166"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["166"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["166"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["166"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["166"]["Text"] = [[  aimbot]]
    G2L["166"]["LayoutOrder"] = -1
    G2L["166"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.slient
    G2L["167"] = Instance.new("Frame", G2L["15a"])
    G2L["167"]["BorderSizePixel"] = 0
    G2L["167"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["167"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["167"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["167"]["Name"] = [[slient]]
    G2L["167"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.slient.text
    G2L["168"] = Instance.new("TextLabel", G2L["167"])
    G2L["168"]["TextStrokeTransparency"] = 0
    G2L["168"]["BorderSizePixel"] = 0
    G2L["168"]["TextSize"] = 18
    G2L["168"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["168"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["168"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["168"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["168"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["168"]["BackgroundTransparency"] = 1
    G2L["168"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["168"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["168"]["Text"] = [[slient]]
    G2L["168"]["Name"] = [[text]]
    G2L["168"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.slient.button
    G2L["169"] = Instance.new("Frame", G2L["167"])
    G2L["169"]["BorderSizePixel"] = 0
    G2L["169"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["169"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["169"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["169"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["169"]["Name"] = [[button]]
    G2L["169"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.slient.button.UIStroke
    G2L["16a"] = Instance.new("UIStroke", G2L["169"])
    G2L["16a"]["Thickness"] = 1.3
    G2L["16a"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["16a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["16a"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.slient.hotkey
    G2L["16b"] = Instance.new("TextLabel", G2L["167"])
    G2L["16b"]["TextStrokeTransparency"] = 0
    G2L["16b"]["BorderSizePixel"] = 0
    G2L["16b"]["TextSize"] = 18
    G2L["16b"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["16b"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["16b"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["16b"]["BackgroundTransparency"] = 0.65
    G2L["16b"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["16b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["16b"]["Text"] = [[nil]]
    G2L["16b"]["Name"] = [[hotkey]]
    G2L["16b"]["Position"] = UDim2.new(0.62522, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.slient.hotkey.UIStroke
    G2L["16c"] = Instance.new("UIStroke", G2L["16b"])
    G2L["16c"]["Thickness"] = 1.4
    G2L["16c"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["16c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["16c"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.smooth
    G2L["16d"] = Instance.new("Frame", G2L["15a"])
    G2L["16d"]["BorderSizePixel"] = 0
    G2L["16d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["16d"]["Size"] = UDim2.new(0, 145, 0, 40)
    G2L["16d"]["Position"] = UDim2.new(0, 0, 0.28169, 0)
    G2L["16d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["16d"]["Name"] = [[smooth]]
    G2L["16d"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.smooth.text
    G2L["16e"] = Instance.new("TextLabel", G2L["16d"])
    G2L["16e"]["TextStrokeTransparency"] = 0
    G2L["16e"]["BorderSizePixel"] = 0
    G2L["16e"]["TextSize"] = 18
    G2L["16e"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["16e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["16e"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["16e"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["16e"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["16e"]["BackgroundTransparency"] = 1
    G2L["16e"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["16e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["16e"]["Text"] = [[smooth - ]]
    G2L["16e"]["Name"] = [[text]]
    G2L["16e"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.smooth.slider
    G2L["16f"] = Instance.new("Frame", G2L["16d"])
    G2L["16f"]["BorderSizePixel"] = 0
    G2L["16f"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["16f"]["Size"] = UDim2.new(0, 133, 0, 12)
    G2L["16f"]["Position"] = UDim2.new(0.04138, 0, 0.545, 0)
    G2L["16f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["16f"]["Name"] = [[slider]]
    G2L["16f"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.smooth.slider.UIStroke
    G2L["170"] = Instance.new("UIStroke", G2L["16f"])
    G2L["170"]["Thickness"] = 1.3
    G2L["170"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["170"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["170"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.smooth.number
    G2L["171"] = Instance.new("TextBox", G2L["16d"])
    G2L["171"]["TextStrokeTransparency"] = 0
    G2L["171"]["Name"] = [[number]]
    G2L["171"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["171"]["PlaceholderColor3"] = Color3.fromRGB(176, 176, 176)
    G2L["171"]["BorderSizePixel"] = 0
    G2L["171"]["TextWrapped"] = true
    G2L["171"]["TextSize"] = 18
    G2L["171"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["171"]["TextColor3"] = Color3.fromRGB(201, 201, 201)
    G2L["171"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["171"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/SourceSansPro.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["171"]["ClearTextOnFocus"] = false
    G2L["171"]["Size"] = UDim2.new(0, 81, 0, 20)
    G2L["171"]["Position"] = UDim2.new(0.38535, 0, 0, 0)
    G2L["171"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["171"]["Text"] = [[0]]
    G2L["171"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.silentmethod
    G2L["161"] = Instance.new("Frame", G2L["15a"])
    G2L["161"]["BorderSizePixel"] = 0
    G2L["161"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["161"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["161"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["161"]["Name"] = [[silentmethod]]
    G2L["161"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.silentmethod.text
    G2L["162"] = Instance.new("TextLabel", G2L["161"])
    G2L["162"]["TextStrokeTransparency"] = 0
    G2L["162"]["BorderSizePixel"] = 0
    G2L["162"]["TextSize"] = 18
    G2L["162"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["162"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["162"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["162"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["162"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["162"]["BackgroundTransparency"] = 1
    G2L["162"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["162"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["162"]["Text"] = [[silent method]]
    G2L["162"]["Name"] = [[text]]
    G2L["162"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.silentmethod.method
    G2L["163"] = Instance.new("TextLabel", G2L["161"])
    G2L["163"]["TextStrokeTransparency"] = 0
    G2L["163"]["BorderSizePixel"] = 0
    G2L["163"]["TextSize"] = 18
    G2L["163"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["163"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["163"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["163"]["BackgroundTransparency"] = 0.65
    G2L["163"]["Size"] = UDim2.new(0, 50, 0, 10)
    G2L["163"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["163"]["Text"] = [[Raycast]]
    G2L["163"]["Name"] = [[method]]
    G2L["163"]["Position"] = UDim2.new(0.59701, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.aimbot.silentmethod.method.UIStroke
    G2L["164"] = Instance.new("UIStroke", G2L["163"])
    G2L["164"]["Thickness"] = 1.4
    G2L["164"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["164"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["164"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.melee
    G2L["172"] = Instance.new("Frame", G2L["104"])
    G2L["172"]["BorderSizePixel"] = 0
    G2L["172"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["172"]["Size"] = UDim2.new(0, 143, 0, 142)
    G2L["172"]["Position"] = UDim2.new(0.67111, 0, 0.08, 0)
    G2L["172"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["172"]["Name"] = [[melee]]
    G2L["172"]["BackgroundTransparency"] = 0.65

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.UIListLayout
    G2L["173"] = Instance.new("UIListLayout", G2L["172"])
    G2L["173"]["SortOrder"] = Enum.SortOrder.LayoutOrder

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.label
    G2L["174"] = Instance.new("TextLabel", G2L["172"])
    G2L["174"]["TextStrokeTransparency"] = 0
    G2L["174"]["BorderSizePixel"] = 0
    G2L["174"]["TextSize"] = 20
    G2L["174"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["174"]["SelectionOrder"] = 1
    G2L["174"]["BackgroundColor3"] = Color3.fromRGB(34, 85, 114)
    G2L["174"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["174"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["174"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["174"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["174"]["Text"] = [[  melee]]
    G2L["174"]["LayoutOrder"] = -1
    G2L["174"]["Name"] = [[label]]

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.hitboxextend
    G2L["175"] = Instance.new("Frame", G2L["172"])
    G2L["175"]["BorderSizePixel"] = 0
    G2L["175"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["175"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["175"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["175"]["Name"] = [[hitboxextend]]
    G2L["175"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.hitboxextend.text
    G2L["176"] = Instance.new("TextLabel", G2L["175"])
    G2L["176"]["TextStrokeTransparency"] = 0
    G2L["176"]["BorderSizePixel"] = 0
    G2L["176"]["TextSize"] = 18
    G2L["176"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["176"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["176"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["176"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["176"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["176"]["BackgroundTransparency"] = 1
    G2L["176"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["176"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["176"]["Text"] = [[hitbox extender]]
    G2L["176"]["Name"] = [[text]]
    G2L["176"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.hitboxextend.button
    G2L["177"] = Instance.new("Frame", G2L["175"])
    G2L["177"]["BorderSizePixel"] = 0
    G2L["177"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["177"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["177"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["177"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["177"]["Name"] = [[button]]
    G2L["177"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.hitboxextend.button.UIStroke
    G2L["178"] = Instance.new("UIStroke", G2L["177"])
    G2L["178"]["Thickness"] = 1.3
    G2L["178"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["178"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["178"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.hitboxextend.hotkey
    G2L["179"] = Instance.new("TextLabel", G2L["175"])
    G2L["179"]["TextStrokeTransparency"] = 0
    G2L["179"]["BorderSizePixel"] = 0
    G2L["179"]["TextSize"] = 18
    G2L["179"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["179"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["179"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["179"]["BackgroundTransparency"] = 0.65
    G2L["179"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["179"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["179"]["Text"] = [[nil]]
    G2L["179"]["Name"] = [[hotkey]]
    G2L["179"]["Position"] = UDim2.new(0.61883, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.hitboxextend.hotkey.UIStroke
    G2L["17a"] = Instance.new("UIStroke", G2L["179"])
    G2L["17a"]["Thickness"] = 1.4
    G2L["17a"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["17a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["17a"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.killaura
    G2L["17b"] = Instance.new("Frame", G2L["172"])
    G2L["17b"]["BorderSizePixel"] = 0
    G2L["17b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["17b"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["17b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["17b"]["Name"] = [[killaura]]
    G2L["17b"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.killaura.text
    G2L["17c"] = Instance.new("TextLabel", G2L["17b"])
    G2L["17c"]["TextStrokeTransparency"] = 0
    G2L["17c"]["BorderSizePixel"] = 0
    G2L["17c"]["TextSize"] = 18
    G2L["17c"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["17c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["17c"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["17c"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["17c"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["17c"]["BackgroundTransparency"] = 1
    G2L["17c"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["17c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["17c"]["Text"] = [[killaura]]
    G2L["17c"]["Name"] = [[text]]
    G2L["17c"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.killaura.button
    G2L["17d"] = Instance.new("Frame", G2L["17b"])
    G2L["17d"]["BorderSizePixel"] = 0
    G2L["17d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["17d"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["17d"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["17d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["17d"]["Name"] = [[button]]
    G2L["17d"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.killaura.button.UIStroke
    G2L["17e"] = Instance.new("UIStroke", G2L["17d"])
    G2L["17e"]["Thickness"] = 1.3
    G2L["17e"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["17e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["17e"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.killaura.hotkey
    G2L["17f"] = Instance.new("TextLabel", G2L["17b"])
    G2L["17f"]["TextStrokeTransparency"] = 0
    G2L["17f"]["BorderSizePixel"] = 0
    G2L["17f"]["TextSize"] = 18
    G2L["17f"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["17f"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["17f"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["17f"]["BackgroundTransparency"] = 0.65
    G2L["17f"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["17f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["17f"]["Text"] = [[nil]]
    G2L["17f"]["Name"] = [[hotkey]]
    G2L["17f"]["Position"] = UDim2.new(0.61883, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.killaura.hotkey.UIStroke
    G2L["180"] = Instance.new("UIStroke", G2L["17f"])
    G2L["180"]["Thickness"] = 1.4
    G2L["180"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["180"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["180"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.stompaura
    G2L["181"] = Instance.new("Frame", G2L["172"])
    G2L["181"]["BorderSizePixel"] = 0
    G2L["181"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["181"]["Size"] = UDim2.new(0, 145, 0, 20)
    G2L["181"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["181"]["Name"] = [[stompaura]]
    G2L["181"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.stompaura.text
    G2L["182"] = Instance.new("TextLabel", G2L["181"])
    G2L["182"]["TextStrokeTransparency"] = 0
    G2L["182"]["BorderSizePixel"] = 0
    G2L["182"]["TextSize"] = 18
    G2L["182"]["TextXAlignment"] = Enum.TextXAlignment.Left
    G2L["182"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["182"]["TextDirection"] = Enum.TextDirection.LeftToRight
    G2L["182"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["182"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["182"]["BackgroundTransparency"] = 1
    G2L["182"]["Size"] = UDim2.new(0, 125, 0, 20)
    G2L["182"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["182"]["Text"] = [[stomp aura]]
    G2L["182"]["Name"] = [[text]]
    G2L["182"]["Position"] = UDim2.new(0, 5, 0, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.stompaura.button
    G2L["183"] = Instance.new("Frame", G2L["181"])
    G2L["183"]["BorderSizePixel"] = 0
    G2L["183"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["183"]["Size"] = UDim2.new(0, 10, 0, 10)
    G2L["183"]["Position"] = UDim2.new(0.89146, 0, 0.22, 0)
    G2L["183"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["183"]["Name"] = [[button]]
    G2L["183"]["BackgroundTransparency"] = 0.85

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.stompaura.button.UIStroke
    G2L["184"] = Instance.new("UIStroke", G2L["183"])
    G2L["184"]["Thickness"] = 1.3
    G2L["184"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["184"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["184"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.stompaura.hotkey
    G2L["185"] = Instance.new("TextLabel", G2L["181"])
    G2L["185"]["TextStrokeTransparency"] = 0
    G2L["185"]["BorderSizePixel"] = 0
    G2L["185"]["TextSize"] = 18
    G2L["185"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["185"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["185"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["185"]["BackgroundTransparency"] = 0.65
    G2L["185"]["Size"] = UDim2.new(0, 30, 0, 10)
    G2L["185"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["185"]["Text"] = [[nil]]
    G2L["185"]["Name"] = [[hotkey]]
    G2L["185"]["Position"] = UDim2.new(0.61883, 0, 0.22, 0)

    -- StarterGui.baggyware.main.windows.aimbotframe.melee.stompaura.hotkey.UIStroke
    G2L["186"] = Instance.new("UIStroke", G2L["185"])
    G2L["186"]["Thickness"] = 1.4
    G2L["186"]["Color"] = Color3.fromRGB(34, 103, 89)
    G2L["186"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
    G2L["186"]["LineJoinMode"] = Enum.LineJoinMode.Miter

    -- StarterGui.baggyware.main.windows.colorpickerframe
    G2L["187"] = Instance.new("Frame", G2L["8"])
    G2L["187"]["Visible"] = false
    G2L["187"]["BorderSizePixel"] = 0
    G2L["187"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["187"]["Size"] = UDim2.new(0, 300, 0, 350)
    G2L["187"]["Position"] = UDim2.new(1, 0, 0, 0)
    G2L["187"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["187"]["Name"] = [[colorpickerframe]]
    G2L["187"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.main.windows.colorpickerframe.ColourWheel
    G2L["188"] = Instance.new("ImageButton", G2L["187"])
    G2L["188"]["Active"] = false
    G2L["188"]["BorderSizePixel"] = 0
    G2L["188"]["BackgroundTransparency"] = 1
    G2L["188"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["188"]["Selectable"] = false
    G2L["188"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
    G2L["188"]["Image"] = [[http://www.roblox.com/asset/?id=6020299385]]
    G2L["188"]["Size"] = UDim2.new(0.70839, 0, 0.60719, 0)
    G2L["188"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
    G2L["188"]["Name"] = [[ColourWheel]]
    G2L["188"]["Position"] = UDim2.new(0.63574, 0, 0.36065, 0)

    -- StarterGui.baggyware.main.windows.colorpickerframe.ColourWheel.UIAspectRatioConstraint
    G2L["189"] = Instance.new("UIAspectRatioConstraint", G2L["188"])
    G2L["189"]["AspectRatio"] = 1

    -- StarterGui.baggyware.main.windows.colorpickerframe.ColourWheel.Picker
    G2L["18a"] = Instance.new("ImageLabel", G2L["188"])
    G2L["18a"]["BorderSizePixel"] = 0
    G2L["18a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["18a"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
    G2L["18a"]["Image"] = [[http://www.roblox.com/asset/?id=3678860011]]
    G2L["18a"]["Size"] = UDim2.new(0.09003, 0, 0.09003, 0)
    G2L["18a"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
    G2L["18a"]["BackgroundTransparency"] = 1
    G2L["18a"]["Name"] = [[Picker]]
    G2L["18a"]["Position"] = UDim2.new(0.5, 0, 0.5, 0)

    -- StarterGui.baggyware.main.windows.colorpickerframe.DarknessPicker
    G2L["18b"] = Instance.new("ImageButton", G2L["187"])
    G2L["18b"]["Active"] = false
    G2L["18b"]["SliceScale"] = 0.12
    G2L["18b"]["BorderSizePixel"] = 0
    G2L["18b"]["SliceCenter"] = Rect.new(100, 100, 100, 100)
    G2L["18b"]["ScaleType"] = Enum.ScaleType.Slice
    G2L["18b"]["BackgroundTransparency"] = 1
    G2L["18b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["18b"]["Selectable"] = false
    G2L["18b"]["ZIndex"] = 2
    G2L["18b"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
    G2L["18b"]["Image"] = [[rbxassetid://3570695787]]
    G2L["18b"]["Size"] = UDim2.new(0.16113, 0, 0.87751, 0)
    G2L["18b"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
    G2L["18b"]["Name"] = [[DarknessPicker]]
    G2L["18b"]["Position"] = UDim2.new(0.12196, 0, 0.49716, 0)

    -- StarterGui.baggyware.main.windows.colorpickerframe.DarknessPicker.UIGradient
    G2L["18c"] = Instance.new("UIGradient", G2L["18b"])
    G2L["18c"]["Rotation"] = 90
    G2L["18c"]["Color"] = ColorSequence.new({
        ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 0, 0)),
    })

    -- StarterGui.baggyware.main.windows.colorpickerframe.DarknessPicker.Slider
    G2L["18d"] = Instance.new("ImageLabel", G2L["18b"])
    G2L["18d"]["ZIndex"] = 2
    G2L["18d"]["BorderSizePixel"] = 0
    G2L["18d"]["SliceCenter"] = Rect.new(100, 100, 100, 100)
    G2L["18d"]["SliceScale"] = 0.12
    G2L["18d"]["ScaleType"] = Enum.ScaleType.Slice
    G2L["18d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["18d"]["ImageColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["18d"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
    G2L["18d"]["Image"] = [[rbxassetid://3570695787]]
    G2L["18d"]["Size"] = UDim2.new(1.28656, 0, 0.0265, 0)
    G2L["18d"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
    G2L["18d"]["BackgroundTransparency"] = 1
    G2L["18d"]["Name"] = [[Slider]]
    G2L["18d"]["Position"] = UDim2.new(0.4912, 0, 0.07336, 0)

    -- StarterGui.baggyware.main.windows.colorpickerframe.DarknessPicker.UIAspectRatioConstraint
    G2L["18e"] = Instance.new("UIAspectRatioConstraint", G2L["18b"])
    G2L["18e"]["AspectRatio"] = 0.15739

    -- StarterGui.baggyware.main.windows.colorpickerframe.ColourDisplay
    G2L["18f"] = Instance.new("ImageLabel", G2L["187"])
    G2L["18f"]["ZIndex"] = 2
    G2L["18f"]["BorderSizePixel"] = 0
    G2L["18f"]["SliceCenter"] = Rect.new(100, 100, 100, 100)
    G2L["18f"]["SliceScale"] = 0.12
    G2L["18f"]["ScaleType"] = Enum.ScaleType.Slice
    G2L["18f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["18f"]["Image"] = [[rbxassetid://3570695787]]
    G2L["18f"]["Size"] = UDim2.new(0.25466, 0, 0.21828, 0)
    G2L["18f"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
    G2L["18f"]["BackgroundTransparency"] = 1
    G2L["18f"]["Name"] = [[ColourDisplay]]
    G2L["18f"]["Position"] = UDim2.new(0.28095, 0, 0.70681, 0)

    -- StarterGui.baggyware.main.windows.colorpickerframe.ColourDisplay.UIAspectRatioConstraint
    G2L["190"] = Instance.new("UIAspectRatioConstraint", G2L["18f"])

    -- StarterGui.baggyware.main.windows.colorpickerframe.Hexcode
    G2L["191"] = Instance.new("TextBox", G2L["187"])
    G2L["191"]["TextStrokeTransparency"] = 0
    G2L["191"]["Name"] = [[Hexcode]]
    G2L["191"]["PlaceholderColor3"] = Color3.fromRGB(179, 179, 179)
    G2L["191"]["BorderSizePixel"] = 0
    G2L["191"]["TextSize"] = 18
    G2L["191"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["191"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["191"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    G2L["191"]["ClearTextOnFocus"] = false
    G2L["191"]["PlaceholderText"] = [[#FFFFFF]]
    G2L["191"]["Size"] = UDim2.new(0, 124, 0, 29)
    G2L["191"]["Position"] = UDim2.new(0.57333, 0, 0.72286, 0)
    G2L["191"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["191"]["Text"] = [[]]

    -- StarterGui.baggyware.main.windows.colorpickerframe.Confirm
    G2L["192"] = Instance.new("TextButton", G2L["187"])
    G2L["192"]["TextStrokeTransparency"] = 0
    G2L["192"]["BorderSizePixel"] = 0
    G2L["192"]["TextSize"] = 18
    G2L["192"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["192"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["192"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    G2L["192"]["Size"] = UDim2.new(0, 125, 0, 31)
    G2L["192"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["192"]["Text"] = [[confirm selection]]
    G2L["192"]["Name"] = [[Confirm]]
    G2L["192"]["Position"] = UDim2.new(0.57, 0, 0.83429, 0)

    -- StarterGui.baggyware.main.title
    G2L["193"] = Instance.new("TextLabel", G2L["2"])
    G2L["193"]["TextWrapped"] = true
    G2L["193"]["TextStrokeTransparency"] = 0
    G2L["193"]["BorderSizePixel"] = 0
    G2L["193"]["TextSize"] = 20
    G2L["193"]["TextScaled"] = true
    G2L["193"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["193"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.Bold,
        Enum.FontStyle.Normal
    )
    G2L["193"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["193"]["BackgroundTransparency"] = 0.85
    G2L["193"]["Size"] = UDim2.new(0, 442, 0, 21)
    G2L["193"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["193"]["Text"] = "priv9.net | roblox [studio]"
    G2L["193"]["Name"] = [[title]]
    G2L["193"]["Position"] = UDim2.new(0.00889, 0, 0.00857, 0)

    -- StarterGui.baggyware.watermark
    G2L["194"] = Instance.new("Frame", G2L["1"])
    G2L["194"]["ZIndex"] = 99999
    G2L["194"]["BorderSizePixel"] = 0
    G2L["194"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["194"]["Size"] = UDim2.new(0, 174, 0, 26)
    G2L["194"]["Position"] = UDim2.new(-0.00039, 0, 0, 0)
    G2L["194"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["194"]["Name"] = [[watermark]]

    -- StarterGui.baggyware.watermark.mark
    G2L["195"] = Instance.new("TextLabel", G2L["194"])
    G2L["195"]["TextStrokeTransparency"] = 0
    G2L["195"]["BorderSizePixel"] = 0
    G2L["195"]["AutoLocalize"] = false
    G2L["195"]["TextSize"] = 20
    G2L["195"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["195"]["FontFace"] = Font.new(
        [[rbxasset://fonts/families/TitilliumWeb.json]],
        Enum.FontWeight.SemiBold,
        Enum.FontStyle.Normal
    )
    G2L["195"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["195"]["BackgroundTransparency"] = 0.85
    G2L["195"]["RichText"] = true
    G2L["195"]["Size"] = UDim2.new(0, 168, 0, 20)
    G2L["195"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["195"]["Text"] = [[priv9.net alpha | fps: 373]]
    G2L["195"]["Name"] = [[mark]]
    G2L["195"]["Position"] = UDim2.new(0.01169, 0, 0.08, 0)

    -- StarterGui.baggyware.watermark.uig
    G2L["196"] = Instance.new("UIGradient", G2L["194"])
    G2L["196"]["Name"] = [[uig]]
    G2L["196"]["Color"] = ColorSequence.new({
        ColorSequenceKeypoint.new(0.000, Color3.fromRGB(34, 85, 114)),
        ColorSequenceKeypoint.new(0.330, Color3.fromRGB(34, 85, 114)),
        ColorSequenceKeypoint.new(0.663, Color3.fromRGB(34, 103, 89)),
        ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 103, 89)),
    })

    -- StarterGui.baggyware.watermark.layout
    G2L["197"] = Instance.new("Frame", G2L["194"])
    G2L["197"]["BorderSizePixel"] = 0
    G2L["197"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["197"]["Size"] = UDim2.new(0, 150, 0, 350)
    G2L["197"]["Position"] = UDim2.new(-0.00575, 0, 1, 0)
    G2L["197"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["197"]["Name"] = [[layout]]
    G2L["197"]["BackgroundTransparency"] = 1

    -- StarterGui.baggyware.radar
    G2L["198"] = Instance.new("ViewportFrame", G2L["1"])
    G2L["198"]["Visible"] = false
    G2L["198"]["BorderSizePixel"] = 0
    G2L["198"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
    G2L["198"]["Size"] = UDim2.new(0, 269, 0, 269)
    G2L["198"]["Position"] = UDim2.new(0, 0, 0.02407, 0)
    G2L["198"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    G2L["198"]["Name"] = [[radar]]
end

buildUI()

local function createDropdown(anchorLabel, options, currentValue, onSelect)
    local dropdown = Instance.new("Frame", G2L["1"])
    dropdown.Name = "dropdown"
    dropdown.ZIndex = 200
    dropdown.BorderSizePixel = 0
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dropdown.Size = UDim2.fromOffset(100, #options * 20)
    dropdown.Visible = false

    local stroke = Instance.new("UIStroke", dropdown)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(34, 103, 89)

    local layout = Instance.new("UIListLayout", dropdown)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton", dropdown)
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.BorderSizePixel = 0
        btn.Text = opt
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 14
        btn.Font = Enum.Font.TitilliumWeb
        btn.ZIndex = 201
        btn.LayoutOrder = i

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end)
        btn.MouseButton1Click:Connect(function()
            anchorLabel.Text = opt
            dropdown.Visible = false
            onSelect(opt)
        end)
    end

    local function updatePosition()
        local pos = anchorLabel.AbsolutePosition
        local size = anchorLabel.AbsoluteSize
        local vp = workspace.CurrentCamera.ViewportSize
        local dropH = #options * 20
        local y = pos.Y + size.Y + 2
        if y + dropH > vp.Y then
            y = pos.Y - dropH - 2
        end
        dropdown.Position = UDim2.fromOffset(pos.X, y)
    end

    anchorLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dropdown.Visible = not dropdown.Visible
            if dropdown.Visible then
                updatePosition()
                -- close other dropdowns
                for _, d in ipairs(G2L["1"]:GetChildren()) do
                    if d.Name == "dropdown" and d ~= dropdown then
                        d.Visible = false
                    end
                end
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdown.Visible then
            local mp = input.Position
            local dp = dropdown.AbsolutePosition
            local ds = dropdown.AbsoluteSize
            if mp.X < dp.X or mp.X > dp.X + ds.X or mp.Y < dp.Y or mp.Y > dp.Y + ds.Y then
                local ap = anchorLabel.AbsolutePosition
                local as = anchorLabel.AbsoluteSize
                if
                    not (
                        mp.X >= ap.X
                        and mp.X <= ap.X + as.X
                        and mp.Y >= ap.Y
                        and mp.Y <= ap.Y + as.Y
                    )
                then
                    dropdown.Visible = false
                end
            end
        end
    end)

    return dropdown
end

local GuiService = game:GetService("GuiService")
-- Color Picker System
local ColorPicker = {}

local function createColorPicker(anchorFrame, defaultColor, callback)
    local picker = {}
    picker.value = defaultColor or Color3.fromRGB(255, 255, 255)
    picker.color = 0
    picker.open = false

    local function getMousePos()
        local pos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        return pos.X, pos.Y - inset.Y
    end

    picker.Main = Instance.new("TextButton", G2L["1"])
    picker.Main.Name = "colorpicker"
    picker.Main.ZIndex = 100
    picker.Main.Visible = false
    picker.Main.AutoButtonColor = false
    picker.Main.Text = ""
    picker.Main.Size = UDim2.fromOffset(180, 196)
    picker.Main.BorderSizePixel = 0
    picker.Main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local outline1 = Instance.new("Frame", picker.Main)
    outline1.ZIndex = 98
    outline1.Size = picker.Main.Size + UDim2.fromOffset(6, 6)
    outline1.BorderSizePixel = 0
    outline1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    outline1.Position = UDim2.fromOffset(-3, -3)

    local outline2 = Instance.new("Frame", picker.Main)
    outline2.ZIndex = 98
    outline2.Size = picker.Main.Size + UDim2.fromOffset(2, 2)
    outline2.BorderSizePixel = 0
    outline2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    outline2.Position = UDim2.fromOffset(-1, -1)

    picker.hue = Instance.new("ImageLabel", picker.Main)
    picker.hue.ZIndex = 101
    picker.hue.Position = UDim2.new(0, 3, 0, 3)
    picker.hue.Size = UDim2.new(0, 172, 0, 172)
    picker.hue.Image = "rbxassetid://4155801252"
    picker.hue.ScaleType = Enum.ScaleType.Stretch
    picker.hue.BackgroundColor3 = Color3.new(1, 0, 0)
    picker.hue.BorderSizePixel = 1
    picker.hue.BorderColor3 = Color3.fromRGB(0, 0, 0)

    picker.huePointer = Instance.new("ImageLabel", picker.Main)
    picker.huePointer.ZIndex = 102
    picker.huePointer.BackgroundTransparency = 1
    picker.huePointer.BorderSizePixel = 0
    picker.huePointer.Position = UDim2.new(0, 0, 0, 0)
    picker.huePointer.Size = UDim2.new(0, 7, 0, 7)
    picker.huePointer.Image = "rbxassetid://6885856475"

    picker.selector = Instance.new("TextLabel", picker.Main)
    picker.selector.ZIndex = 101
    picker.selector.Position = UDim2.new(0, 3, 0, 181)
    picker.selector.Size = UDim2.new(0, 173, 0, 10)
    picker.selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    picker.selector.BorderSizePixel = 1
    picker.selector.BorderColor3 = Color3.fromRGB(0, 0, 0)
    picker.selector.Text = ""

    local rainbow = Instance.new("UIGradient", picker.selector)
    rainbow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.new(1, 0, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.new(0, 0, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.new(0, 1, 0)),
        ColorSequenceKeypoint.new(0.83, Color3.new(1, 1, 0)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0)),
    })

    picker.pointer = Instance.new("Frame", picker.selector)
    picker.pointer.ZIndex = 102
    picker.pointer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    picker.pointer.Position = UDim2.new(0, 0, 0, 0)
    picker.pointer.Size = UDim2.new(0, 2, 0, 10)
    picker.pointer.BorderColor3 = Color3.fromRGB(255, 255, 255)
    picker.pointer.BorderSizePixel = 1

    if not anchorFrame then
        warn("[baggyware] createColorPicker anchorFrame is nil")
        function picker:Set(color)
            picker.value = Color3.new(
                math.clamp(color.R, 0, 1),
                math.clamp(color.G, 0, 1),
                math.clamp(color.B, 0, 1)
            )
            if callback then
                pcall(callback, picker.value)
            end
        end
        function picker:RefreshHue() end
        function picker:RefreshSelector() end
        return picker
    end

    function picker:Set(color)
        picker.value = Color3.new(
            math.clamp(color.R, 0, 1),
            math.clamp(color.G, 0, 1),
            math.clamp(color.B, 0, 1)
        )
        local darker = Color3.new(
            math.clamp(picker.value.R / 1.7, 0, 1),
            math.clamp(picker.value.G / 1.7, 0, 1),
            math.clamp(picker.value.B / 1.7, 0, 1)
        )
        local grad = anchorFrame:FindFirstChildWhichIsA("UIGradient")
        if grad then
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, picker.value),
                ColorSequenceKeypoint.new(1, darker),
            })
        else
            anchorFrame.BackgroundColor3 = picker.value
        end
        if callback then
            pcall(callback, picker.value)
        end
    end

    function picker:RefreshHue()
        local mouseX, mouseY = getMousePos() -- fixed: no more mouse.X/Y
        local x =
            math.clamp((mouseX - picker.hue.AbsolutePosition.X) / picker.hue.AbsoluteSize.X, 0, 1)
        local y =
            math.clamp((mouseY - picker.hue.AbsolutePosition.Y) / picker.hue.AbsoluteSize.Y, 0, 1)
        picker.huePointer:TweenPosition(
            UDim2.new(
                math.clamp(x * picker.hue.AbsoluteSize.X, 0.5, 0.952 * picker.hue.AbsoluteSize.X)
                    / picker.hue.AbsoluteSize.X,
                0,
                math.clamp(y * picker.hue.AbsoluteSize.Y, 0.5, 0.885 * picker.hue.AbsoluteSize.Y)
                    / picker.hue.AbsoluteSize.Y,
                0
            ),
            Enum.EasingDirection.In,
            Enum.EasingStyle.Sine,
            0.05
        )
        picker:Set(
            Color3.fromHSV(
                picker.color,
                math.clamp(x * picker.hue.AbsoluteSize.X, 0.5, picker.hue.AbsoluteSize.X)
                    / picker.hue.AbsoluteSize.X,
                1
                    - math.clamp(y * picker.hue.AbsoluteSize.Y, 0.5, picker.hue.AbsoluteSize.Y)
                        / picker.hue.AbsoluteSize.Y
            )
        )
    end

    function picker:RefreshSelector()
        local mouseX, _ = getMousePos() -- fixed: no more mouse.X
        local pos =
            math.clamp((mouseX - picker.hue.AbsolutePosition.X) / picker.hue.AbsoluteSize.X, 0, 1)
        picker.color = 1 - pos
        picker.pointer:TweenPosition(
            UDim2.new(pos, 0, 0, 0),
            Enum.EasingDirection.In,
            Enum.EasingStyle.Sine,
            0.05
        )
        picker.hue.BackgroundColor3 = Color3.fromHSV(1 - pos, 1, 1)

        local px = (picker.huePointer.AbsolutePosition.X - picker.hue.AbsolutePosition.X)
            / picker.hue.AbsoluteSize.X
        local py = (picker.huePointer.AbsolutePosition.Y - picker.hue.AbsolutePosition.Y)
            / picker.hue.AbsoluteSize.Y
        picker:Set(
            Color3.fromHSV(
                picker.color,
                math.clamp(px * picker.hue.AbsoluteSize.X, 0.5, picker.hue.AbsoluteSize.X)
                    / picker.hue.AbsoluteSize.X,
                1
                    - math.clamp(py * picker.hue.AbsoluteSize.Y, 0.5, picker.hue.AbsoluteSize.Y)
                        / picker.hue.AbsoluteSize.Y
            )
        )
    end

    local function updatePickerPosition()
        local absPos = anchorFrame.AbsolutePosition
        local absSize = anchorFrame.AbsoluteSize
        local vp = workspace.CurrentCamera.ViewportSize
        local x = absPos.X + absSize.X + 4
        local y = absPos.Y
        if x + 186 > vp.X then
            x = absPos.X - 186
        end
        if y + 200 > vp.Y then
            y = vp.Y - 200
        end
        picker.Main.Position = UDim2.fromOffset(x, y)
    end

    local draggingHue = false
    local draggingSelector = false

    anchorFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            picker.open = not picker.open
            picker.Main.Visible = picker.open
            if picker.open then
                updatePickerPosition()
                for _, other in pairs(ColorPicker) do
                    if other ~= picker and other.open then
                        other.open = false
                        other.Main.Visible = false
                    end
                end
            end
        end
    end)

    picker.hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
            picker:RefreshHue()
        end
    end)
    picker.hue.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = false
        end
    end)

    picker.selector.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSelector = true
            picker:RefreshSelector()
        end
    end)
    picker.selector.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSelector = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingHue then
                picker:RefreshHue()
            end
            if draggingSelector then
                picker:RefreshSelector()
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and picker.open then
            local pos = input.Position
            local mp = picker.Main.AbsolutePosition
            local ms = picker.Main.AbsoluteSize
            if pos.X < mp.X or pos.X > mp.X + ms.X or pos.Y < mp.Y or pos.Y > mp.Y + ms.Y then
                local ap = anchorFrame.AbsolutePosition
                local as = anchorFrame.AbsoluteSize
                if
                    not (
                        pos.X >= ap.X
                        and pos.X <= ap.X + as.X
                        and pos.Y >= ap.Y
                        and pos.Y <= ap.Y + as.Y
                    )
                then
                    picker.open = false
                    picker.Main.Visible = false
                end
            end
        end
    end)

    picker:Set(defaultColor or Color3.fromRGB(255, 255, 255))
    table.insert(ColorPicker, picker)
    return picker
end

local executor = (getexecutorname and getexecutorname()) or "Unknown Executor"

-- // SILENT AIM
local SilentAim = {
    Enabled = false,
    FOVRadius = 360,
    ShowFOV = false,
    TargetPart = "Head",
    TeamCheck = false,
    IgnoreInvincible = false, -- add this
}

local silentFOVCircle = Drawing.new("Circle")
silentFOVCircle.Thickness = 1
silentFOVCircle.NumSides = 100
silentFOVCircle.Radius = SilentAim.FOVRadius
silentFOVCircle.Filled = false
silentFOVCircle.Visible = false
silentFOVCircle.ZIndex = 999
silentFOVCircle.Transparency = 1
silentFOVCircle.Color = Color3.fromRGB(255, 255, 255)

RunService.RenderStepped:Connect(function()
    if SilentAim.ShowFOV then
        local mousePos = UserInputService:GetMouseLocation()
        silentFOVCircle.Visible = true
        silentFOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        silentFOVCircle.Radius = SilentAim.FOVRadius
    else
        silentFOVCircle.Visible = false
    end
end)

local function getClosestPlayerToMouse()
    if not SilentAim.TargetPart then
        return
    end
    local Closest
    local DistanceToMouse
    for _, Player in next, GetPlayers(Players) do
        if Player == LocalPlayer then
            continue
        end
        if SilentAim.TeamCheck and Player.Team == LocalPlayer.Team then
            continue
        end

        local Character = Player.Character
        if not Character then
            continue
        end

        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then
            continue
        end

        local ScreenPosition, OnScreen = WorldToScreen(Camera, HumanoidRootPart.Position)
        local ScreenPosition = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
        if not OnScreen then
            continue
        end

        local Distance = (GetMouseLocation(UserInputService) - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or SilentAim.FOVRadius or 2000) then
            Closest = Character[SilentAim.TargetPart] or Character["HumanoidRootPart"]
            DistanceToMouse = Distance
        end
    end
    return Closest
end

local function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = {
        ArgCountRequired = 3,
        Args = { "Instance", "Ray", "table", "boolean", "boolean" },
    },
    FindPartOnRayWithWhitelist = {
        ArgCountRequired = 3,
        Args = { "Instance", "Ray", "table", "boolean" },
    },
    FindPartOnRay = {
        ArgCountRequired = 2,
        Args = { "Instance", "Ray", "Instance", "boolean", "boolean" },
    },
    Raycast = {
        ArgCountRequired = 3,
        Args = { "Instance", "Vector3", "Vector3", "RaycastParams" },
    },
}

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then
        return false
    end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then
            Matches = Matches + 1
        end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local SelectedMethod = "Raycast"

createDropdown(
    G2L["163"],
    { "Raycast", "FindPartOnRay", "FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist" },
    SelectedMethod,
    function(val)
        SelectedMethod = val
        G2L["163"].Text = val
    end
)

local silentaimsupported = hookmetamethod ~= nil
    and newcclosure ~= nil
    and checkcaller ~= nil
    and getnamecallmethod ~= nil
-- force silent aim error
local silentaimsupported = nil

if silentaimsupported then
    local oldNamecall
    oldNamecall = hookmetamethod(
        game,
        "__namecall",
        newcclosure(function(self, ...) -- Added 'self' here
            -- 1. Bail out immediately if the call is generated by your own UI or script
            if checkcaller() then
                return oldNamecall(self, ...)
            end

            -- 2. HONEYPOT PROXY BYPASS: If 'self' isn't a real game Instance, skip it.
            if typeof(self) ~= "Instance" then
                return oldNamecall(self, ...)
            end

            local Method = getnamecallmethod()

            -- 3. HARDENED CRASH LOOP DEFLECTOR
            if Method == "GetDescendants" and self == game then
                return {} -- Hand back empty table; loop instantly finishes.
            end

            local Arguments = { ... } -- Holds parameters passed *after* 'self'

            -- 4. SILENT AIM LOGIC
            if SilentAim.Enabled and self == workspace then
                -- ──── OLD RAYCAST METHODS ──────────────────────────────────────────
                if Method == "FindPartOnRayWithIgnoreList" and SelectedMethod == Method then
                    if
                        ValidateArguments(
                            { self, unpack(Arguments) },
                            ExpectedArguments.FindPartOnRayWithIgnoreList
                        )
                    then
                        local A_Ray = Arguments[1]
                        local HitPart = getClosestPlayerToMouse()
                        if HitPart then
                            local Origin = A_Ray.Origin
                            local Direction = getDirection(Origin, HitPart.Position)
                            Arguments[1] = Ray.new(Origin, Direction)
                            return oldNamecall(self, table.unpack(Arguments))
                        end
                    end
                elseif Method == "FindPartOnRayWithWhitelist" and SelectedMethod == Method then
                    if
                        ValidateArguments(
                            { self, unpack(Arguments) },
                            ExpectedArguments.FindPartOnRayWithWhitelist
                        )
                    then
                        local A_Ray = Arguments[1]
                        local HitPart = getClosestPlayerToMouse()
                        if HitPart then
                            local Origin = A_Ray.Origin
                            local Direction = getDirection(Origin, HitPart.Position)
                            Arguments[1] = Ray.new(Origin, Direction)
                            return oldNamecall(self, table.unpack(Arguments))
                        end
                    end
                elseif
                    (Method == "FindPartOnRay" or Method == "findPartOnRay")
                    and SelectedMethod:lower() == "findpartonray"
                then
                    if
                        ValidateArguments(
                            { self, unpack(Arguments) },
                            ExpectedArguments.FindPartOnRay
                        )
                    then
                        local A_Ray = Arguments[1]
                        local HitPart = getClosestPlayerToMouse()
                        if HitPart then
                            local Origin = A_Ray.Origin
                            Arguments[1] = Ray.new(Origin, getDirection(Origin, HitPart.Position))
                            return oldNamecall(self, table.unpack(Arguments))
                        end
                    end

                -- ──── MODERN RAYCAST METHOD ────────────────────────────────────────
                elseif Method == "Raycast" and SelectedMethod == "Raycast" then
                    if
                        ValidateArguments({ self, unpack(Arguments) }, ExpectedArguments.Raycast)
                    then
                        local HitPart = getClosestPlayerToMouse()
                        if HitPart then
                            local Origin = Arguments[1]
                            Arguments[2] = getDirection(Origin, HitPart.Position)
                            return oldNamecall(self, table.unpack(Arguments))
                        end
                    end
                end
            end

            -- Return exactly how the engine passed it if no conditions met
            return oldNamecall(self, ...)
        end)
    )
else
    -- UI warning layer is deferred via task.spawn to run AFTER your G2L layer builds completely
    task.spawn(function()
        repeat
            task.wait()
        until G2L and G2L["167"]

        local silentRow = G2L["167"]
        local silentBtn = silentRow and silentRow:FindFirstChild("button")
        local silentText = silentRow and silentRow:FindFirstChild("text")
        if silentText then
            silentText.TextColor3 = Color3.fromRGB(100, 100, 100)
            silentText.Text = "silent (unsupported)"
        end
        if silentBtn then
            silentBtn.BackgroundTransparency = 1
        end
        warn("[baggyware] Silent aim not supported on this executor.")
    end)
end

-- // THEME GRADIENT SYSTEM
local themeGradients = {
    color1 = Color3.fromRGB(34, 85, 114),
    color2 = Color3.fromRGB(34, 103, 89),
    color3 = Color3.fromRGB(34, 103, 89),
    merged = true,
}

local managedGradients = {
    G2L["3"],
    G2L["196"],
}

-- If merged: average color1 and color3 mathematically (white + black = gray, etc.)
-- If unmerged: just use color2 as-is
local function getMiddleColor()
    if themeGradients.merged then
        -- 0.5 gets the exact halfway point between color1 and color3
        return themeGradients.color1:Lerp(themeGradients.color3, 0.5)
    else
        return themeGradients.color2
    end
end

local function getColumnColor(column)
    if column == "left" then
        return themeGradients.color1
    end
    if column == "middle" then
        return getMiddleColor()
    end
    if column == "right" then
        return themeGradients.color3
    end
    return themeGradients.color1
end

local sectionColumns = {
    -- MISC TAB
    { frame = G2L["28"], column = "left" }, -- miscframe.misc
    { frame = G2L["37"], column = "middle" }, -- miscframe.movement
    { frame = G2L["67"], column = "right" }, -- miscframe.config
    { frame = G2L["21"], column = "left" }, -- miscframe.whitelist
    { frame = G2L["a"], column = "right" }, -- miscframe.theme

    -- VISUALS TAB
    { frame = G2L["e1"], column = "left" }, -- visualsframe.selection
    { frame = G2L["92"], column = "middle" }, -- visualsframe.options
    { frame = G2L["ec"], column = "right" }, -- visualsframe.radar
    { frame = G2L["c9"], column = "left" }, -- visualsframe.filters
    { frame = G2L["7d"], column = "right" }, -- visualsframe.fov

    -- AIMBOT TAB
    { frame = G2L["15a"], column = "left" }, -- aimbotframe.aimbot
    { frame = G2L["129"], column = "middle" }, -- aimbotframe.targetselect
    { frame = G2L["172"], column = "right" }, -- aimbotframe.melee
    { frame = G2L["114"], column = "left" }, -- aimbotframe.mods
    { frame = G2L["105"], column = "right" }, -- aimbotframe.ragebot
}

local function applyColumnColors()
    for _, entry in ipairs(sectionColumns) do
        local frame = entry.frame
        local color = getColumnColor(entry.column)
        if not frame or not frame.Parent then
            continue
        end

        -- Label header background
        local labelFrame = frame:FindFirstChild("label")
        if labelFrame and labelFrame:IsA("TextLabel") then
            labelFrame.BackgroundColor3 = color
        end

        -- Every UIStroke inside this section
        for _, desc in ipairs(frame:GetDescendants()) do
            if desc:IsA("UIStroke") then
                desc.Color = color
            end
            -- Slider fill bars
            if desc:IsA("Frame") and desc.Name == "fill" then
                desc.BackgroundColor3 = color
            end
            -- Enabled toggle buttons (when ON, their BackgroundColor3 is the theme color)
            if desc:IsA("Frame") and desc.Name == "button" then
                -- Only recolor if currently "on" (non-transparent)
                if desc.BackgroundTransparency < 0.5 then
                    desc.BackgroundColor3 = color
                end
            end
        end

        -- ScrollingFrame UIStroke
        local sf = frame:FindFirstChild("sf")
        if sf then
            local sfStroke = sf:FindFirstChildWhichIsA("UIStroke")
            if sfStroke then
                sfStroke.Color = color
            end
        end
    end
end

local function buildGradientSequence()
    if themeGradients.merged then
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, themeGradients.color1),
            ColorSequenceKeypoint.new(0.330, themeGradients.color1),
            ColorSequenceKeypoint.new(0.663, themeGradients.color3),
            ColorSequenceKeypoint.new(1.000, themeGradients.color3),
        })
    else
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0.000, themeGradients.color1),
            ColorSequenceKeypoint.new(0.165, themeGradients.color1),
            ColorSequenceKeypoint.new(0.330, themeGradients.color2),
            ColorSequenceKeypoint.new(0.660, themeGradients.color2),
            ColorSequenceKeypoint.new(0.825, themeGradients.color3),
            ColorSequenceKeypoint.new(1.000, themeGradients.color3),
        })
    end
end

local function applyThemeGradients()
    local seq = buildGradientSequence()
    for _, grad in ipairs(managedGradients) do
        grad.Color = seq
    end
    applyColumnColors()
end

local function refreshGradientSquares()
    if not G2L["1b"] or not G2L["1d"] or not G2L["1f"] then
        return
    end

    G2L["1b"].BackgroundColor3 = themeGradients.color1
    G2L["1f"].BackgroundColor3 = themeGradients.color3

    if themeGradients.merged then
        -- Show the mathematically derived middle color on the square
        G2L["1d"].BackgroundColor3 = getMiddleColor()
        G2L["1d"].BackgroundTransparency = 0.35
        -- Remove any UIGradient that may have been added before
        local existing = G2L["1d"]:FindFirstChildWhichIsA("UIGradient")
        if existing then
            existing:Destroy()
        end
    else
        G2L["1d"].BackgroundColor3 = themeGradients.color2
        G2L["1d"].BackgroundTransparency = 0
        local existing = G2L["1d"]:FindFirstChildWhichIsA("UIGradient")
        if existing then
            existing:Destroy()
        end
    end

    local stroke2 = G2L["1e"]
    if stroke2 then
        stroke2.Color = themeGradients.merged and Color3.fromRGB(150, 150, 150)
            or Color3.fromRGB(34, 103, 89)
    end
end

-- Gradient 1 picker
local gradientPicker1 = createColorPicker(G2L["1b"], themeGradients.color1, function(color)
    themeGradients.color1 = color
    applyThemeGradients()
    refreshGradientSquares()
end)

-- Gradient 2 picker (disabled/blocked during merge)
local gradientPicker2 = createColorPicker(G2L["1d"], themeGradients.color2, function(color)
    if not themeGradients.merged then
        themeGradients.color2 = color
        applyThemeGradients()
        refreshGradientSquares()
    end
end)

if G2L["1d"] then
    G2L["1d"].InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- 1. Close picker if open
            if gradientPicker2.open then
                gradientPicker2.open = false
                gradientPicker2.Main.Visible = false
            end

            -- 2. Execute toggle logic safely
            themeGradients.merged = not themeGradients.merged

            refreshGradientSquares()
            applyThemeGradients()

            -- 3. Execute temporary visual feedback flash
            local flashColor = themeGradients.merged and Color3.fromRGB(120, 120, 120)
                or Color3.fromRGB(34, 103, 89)
            G2L["1d"].BackgroundColor3 = flashColor

            task.delay(0.3, function()
                refreshGradientSquares()
            end)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            -- Right click logic strictly handles picker removal
            if gradientPicker2.open then
                gradientPicker2.open = false
                gradientPicker2.Main.Visible = false
            end
        end
    end)
end

-- Gradient 3 picker
local gradientPicker3 = createColorPicker(G2L["1f"], themeGradients.color3, function(color)
    themeGradients.color3 = color
    applyThemeGradients()
    refreshGradientSquares()
end)

-- Apply on load
applyThemeGradients()
refreshGradientSquares()

-- // MISC TOGGLES
local function wireToggle(rowFrame, onEnable, onDisable)
    local state = false
    local btn = rowFrame:FindFirstChild("button")
    if not btn then
        return
    end

    local function getOnColor()
        -- Find which column this row's parent section belongs to
        local ancestor = rowFrame.Parent
        while ancestor do
            for _, entry in ipairs(sectionColumns) do
                if entry.frame == ancestor then
                    return getColumnColor(entry.column)
                end
            end
            ancestor = ancestor.Parent
        end
        local stroke = btn:FindFirstChildWhichIsA("UIStroke")
        return stroke and stroke.Color or Color3.fromRGB(34, 103, 89)
    end

    local function updateVisual()
        local onColor = getOnColor()
        btn.BackgroundColor3 = state and onColor or Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = state and 0 or 0.85
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateVisual()
            if state then
                onEnable()
            else
                onDisable()
            end
        end
    end)

    updateVisual()
end

-- // WIRE SILENT AIM TOGGLES

-- Silent aim enabled toggle (G2L["167"] is the slient row in aimbot tab)
wireToggle(G2L["167"], function()
    if not canUseSilentAim then
        return
    end
    SilentAim.Enabled = true
end, function()
    SilentAim.Enabled = false
end)

-- FOV circle visibility toggle (drawn fov row G2L["14e"])
wireToggle(G2L["14e"], function()
    SilentAim.ShowFOV = true
end, function()
    SilentAim.ShowFOV = false
end)

-- Team check toggle (ignorefriendlys row G2L["12c"])
wireToggle(G2L["12c"], function()
    SilentAim.TeamCheck = true
end, function()
    SilentAim.TeamCheck = false
end)

wireToggle(G2L["130"], function()
    SilentAim.IgnoreInvincible = true
end, function()
    SilentAim.IgnoreInvincible = false
end)

-- Hit target dropdown cycling (clicking the hotkey label on G2L["138"])
-- Cycles Head -> Torso -> HumanoidRootPart -> Head
local targetParts = { "Head", "Torso", "HumanoidRootPart" }
local hitTargetLabel = G2L["13a"]
hitTargetLabel.Text = SilentAim.TargetPart

createDropdown(hitTargetLabel, targetParts, SilentAim.TargetPart, function(val)
    SilentAim.TargetPart = val
end)

-- Set labels
G2L["193"]["Text"] = "priv9.net | roblox [" .. executor .. "]"

-- FPS Counter
local frameCount = 0
local lastUpdate = tick()
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastUpdate >= 1 then
        G2L["195"]["Text"] = "priv9.net alpha | fps: " .. frameCount
        frameCount = 0
        lastUpdate = now
    end
end)

-- Move runtime locals into function scope to avoid main-chunk register limits
local function main()
    local function wireSlider(sliderFrame, minVal, maxVal, defaultVal, onChange)
        local track = sliderFrame:FindFirstChild("slider")
        local numBox = sliderFrame:FindFirstChild("number")
        if not track or not numBox then
            return
        end

        local dragging = false
        local value = defaultVal

        local function updateValue(v)
            value = math.clamp(math.floor(v), minVal, maxVal)
            numBox.Text = tostring(value)
            -- Visual fill: resize a fill frame inside the track
            local fill = track:FindFirstChild("fill")
            if fill then
                local ratio = (value - minVal) / (maxVal - minVal)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
            end
            if onChange then
                onChange(value)
            end
        end

        -- Create a fill bar inside the slider track
        local fill = track:FindFirstChild("fill")
        if not fill then
            fill = Instance.new("Frame", track)
            fill.Name = "fill"
            fill.BorderSizePixel = 0
            fill.BackgroundColor3 = Color3.fromRGB(34, 103, 89)
            fill.Size = UDim2.new(0, 0, 1, 0)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local trackPos = track.AbsolutePosition.X
                local trackSize = track.AbsoluteSize.X
                local mouseX = input.Position.X
                local ratio = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
                updateValue(minVal + (maxVal - minVal) * ratio)
            end
        end)

        -- Allow typing directly in the number box
        numBox.FocusLost:Connect(function()
            local v = tonumber(numBox.Text)
            if v then
                updateValue(v)
            end
        end)

        updateValue(defaultVal)
    end

    -- // TAB SWITCHING
    local frames = {
        misc = G2L["9"],
        visuals = G2L["7c"],
        aimbot = G2L["104"],
    }

    local tabButtons = {
        misc = G2L["6"],
        visuals = G2L["7"],
        aimbot = G2L["5"],
    }

    local activeColor = Color3.fromRGB(255, 255, 255)
    local inactiveColor = Color3.fromRGB(176, 176, 176)

    local function switchTab(tab)
        for name, frame in pairs(frames) do
            frame.Visible = (name == tab)
        end
        for name, btn in pairs(tabButtons) do
            btn.TextColor3 = (name == tab) and activeColor or inactiveColor
        end
    end

    switchTab("misc")

    tabButtons.misc.MouseButton1Click:Connect(function()
        switchTab("misc")
    end)
    tabButtons.visuals.MouseButton1Click:Connect(function()
        switchTab("visuals")
    end)
    tabButtons.aimbot.MouseButton1Click:Connect(function()
        switchTab("aimbot")
    end)

    -- // DRAGGABLE MAIN FRAME
    local mainFrame = G2L["2"]
    local dragMain = false
    local dragMainStart, dragMainPos
    local mainTarget = mainFrame.Position

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = input.Position
            local framePos = mainFrame.AbsolutePosition
            local frameSize = mainFrame.AbsoluteSize
            if
                pos.X >= framePos.X
                and pos.X <= framePos.X + frameSize.X
                and pos.Y >= framePos.Y
                and pos.Y <= framePos.Y + 25
            then
                dragMain = true
                dragMainStart = pos
                dragMainPos = mainFrame.Position
            end
        end
    end)

    local dealerColors = {
        ArmoryDealer = Color3.fromRGB(30, 80, 180), -- deep blue
        Dealer = Color3.fromRGB(210, 120, 30), -- orange
    }

    UserInputService.InputChanged:Connect(function(input)
        if dragMain and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragMainStart
            local vp = workspace.CurrentCamera.ViewportSize
            mainTarget = UDim2.new(
                dragMainPos.X.Scale + delta.X / vp.X,
                dragMainPos.X.Offset,
                dragMainPos.Y.Scale + delta.Y / vp.Y,
                dragMainPos.Y.Offset
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragMain = false
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        local current = mainFrame.Position
        mainFrame.Position = UDim2.new(
            current.X.Scale + (mainTarget.X.Scale - current.X.Scale) * math.min(dt * 8, 1),
            current.X.Offset,
            current.Y.Scale + (mainTarget.Y.Scale - current.Y.Scale) * math.min(dt * 8, 1),
            current.Y.Offset
        )
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragWM and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragWMStart
            local vp = workspace.CurrentCamera.ViewportSize
            wmTarget = UDim2.new(
                dragWMPos.X.Scale + delta.X / vp.X,
                dragWMPos.X.Offset,
                dragWMPos.Y.Scale + delta.Y / vp.Y,
                dragWMPos.Y.Offset
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragWM = false
        end
    end)

    -- // MENU KEY
    local menuOpen = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then
            return
        end
        if input.KeyCode == Enum.KeyCode.RightControl then
            menuOpen = not menuOpen
            G2L["2"].Visible = menuOpen
        end
    end)

    local bhopEnabled = false
    local bhopConn

    local function startBhop()
        bhopEnabled = true

        bhopConn = RunService.Heartbeat:Connect(function()
            local char = Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then
                return
            end

            if hum.FloorMaterial ~= Enum.Material.Air then
                local vel = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(vel.X, hum.JumpPower, vel.Z)
            end
        end)
    end

    local function stopBhop()
        bhopEnabled = false
        if bhopConn then
            bhopConn:Disconnect()
            bhopConn = nil
        end
    end

    -- Noclip
    local noclipConn
    local function startNoclip()
        noclipConn = RunService.Stepped:Connect(function()
            local character = Players.LocalPlayer.Character
            if not character then
                return
            end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
    local function stopNoclip()
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        local character = Players.LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end

    -- Flight
    local flightConn
    local flightBodyVel, flightBodyGyro
    local flightSpeed = 50
    local function startFlight()
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not rootPart then
            return
        end
        humanoid.PlatformStand = true
        flightBodyVel = Instance.new("BodyVelocity", rootPart)
        flightBodyVel.Velocity = Vector3.zero
        flightBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flightBodyGyro = Instance.new("BodyGyro", rootPart)
        flightBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flightBodyGyro.P = 1e4
        flightConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir += cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir -= cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir -= cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir += cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir -= Vector3.new(0, 1, 0)
            end
            flightBodyVel.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * flightSpeed
                or Vector3.zero
            flightBodyGyro.CFrame = cam.CFrame
        end)
    end
    local function stopFlight()
        if flightConn then
            flightConn:Disconnect()
            flightConn = nil
        end
        if flightBodyVel then
            flightBodyVel:Destroy()
            flightBodyVel = nil
        end
        if flightBodyGyro then
            flightBodyGyro:Destroy()
            flightBodyGyro = nil
        end
        local humanoid = Players.LocalPlayer.Character
            and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    -- Fake Speed (CFrame-based multiplier)
    local fakeSpeedEnabled = false
    local fakeSpeedMultiplier = 1
    local lastFakePos = nil
    local fakeSpeedConn

    local function startFakeSpeed()
        fakeSpeedEnabled = true
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            return
        end

        lastFakePos = rootPart.CFrame

        fakeSpeedConn = RunService.Heartbeat:Connect(function(dt)
            local char = Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then
                return
            end

            -- Get the velocity-based movement direction from humanoid
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                -- Calculate extra distance to add on top of normal movement
                -- multiplier - 1 gives the "extra" factor
                local extra = moveDir * (hum.WalkSpeed * (fakeSpeedMultiplier - 1) * dt)
                root.CFrame = root.CFrame + extra
            end
        end)
    end

    local function stopFakeSpeed()
        fakeSpeedEnabled = false
        if fakeSpeedConn then
            fakeSpeedConn:Disconnect()
            fakeSpeedConn = nil
        end
    end

    -- Spin
    local spinConn
    local spinSpeed = 10
    local function startSpin()
        spinConn = RunService.RenderStepped:Connect(function()
            local rootPart = Players.LocalPlayer.Character
                and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            end
        end)
    end
    local function stopSpin()
        if spinConn then
            spinConn:Disconnect()
            spinConn = nil
        end
    end

    -- Self-Contained Freecam Setup (Free Mouse + Right-Click Look + Input Isolation)

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    local fcConnection = nil
    local cameraSpeed = 1.0
    local lookSensitivity = 0.4

    -- Tracking keystrokes
    local movements =
        { Forward = false, Backward = false, Left = false, Right = false, Up = false, Down = false }
    local keys = {
        [Enum.KeyCode.W] = "Forward",
        [Enum.KeyCode.S] = "Backward",
        [Enum.KeyCode.A] = "Left",
        [Enum.KeyCode.D] = "Right",
        [Enum.KeyCode.E] = "Up",
        [Enum.KeyCode.Q] = "Down",
    }

    -- Safely fetches the player's core control module to disable character movement
    local function setCharacterMovementEnabled(enabled)
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local controls = LocalPlayer:FindFirstChild("PlayerScripts")
            and LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if controls then
            local modules = require(LocalPlayer.PlayerScripts.PlayerModule)
            local controlsModule = modules and modules.GetControls and modules:GetControls()
            if controlsModule then
                if enabled then
                    controlsModule:Enable()
                else
                    controlsModule:Disable()
                end
            end
        end
    end

    -- // FREECAM (replace your entire existing freecam section)
    local freecamActive = false

    local function startFreecam()
        freecamActive = true

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and not rootPart:FindFirstChild("_FCFreeze") then
            local attachment = Instance.new("Attachment")
            attachment.Name = "_FCFreezeAttachment"
            attachment.Parent = rootPart

            local freezeVel = Instance.new("LinearVelocity")
            freezeVel.Name = "_FCFreeze"
            freezeVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            freezeVel.VectorVelocity = Vector3.zero
            freezeVel.MaxForce = math.huge
            freezeVel.Attachment0 = attachment
            freezeVel.Parent = rootPart
        end

        setCharacterMovementEnabled(false)

        Camera.CameraType = Enum.CameraType.Scriptable
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default

        local beganBind = UserInputService.InputBegan:Connect(function(input, processed)
            if keys[input.KeyCode] then
                movements[keys[input.KeyCode]] = true
            end
        end)
        local endedBind = UserInputService.InputEnded:Connect(function(input)
            if keys[input.KeyCode] then
                movements[keys[input.KeyCode]] = false
            end
        end)

        fcConnection = RunService.RenderStepped:Connect(function()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                local delta = UserInputService:GetMouseDelta()
                local cframe = Camera.CFrame
                Camera.CFrame = CFrame.lookAt(cframe.Position, cframe.Position + cframe.LookVector)
                    * CFrame.Angles(0, -delta.X * (lookSensitivity / 100), 0)
                    * CFrame.Angles(-delta.Y * (lookSensitivity / 100), 0, 0)
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end

            local moveVector = Vector3.zero
            if movements.Forward then
                moveVector = moveVector + Camera.CFrame.LookVector
            end
            if movements.Backward then
                moveVector = moveVector - Camera.CFrame.LookVector
            end
            if movements.Left then
                moveVector = moveVector - Camera.CFrame.RightVector
            end
            if movements.Right then
                moveVector = moveVector + Camera.CFrame.RightVector
            end
            if movements.Up then
                moveVector = moveVector + Vector3.yAxis
            end
            if movements.Down then
                moveVector = moveVector - Vector3.yAxis
            end

            if moveVector.Magnitude > 0 then
                Camera.CFrame = Camera.CFrame + (moveVector.Unit * cameraSpeed)
            end
        end)

        shared._fcBegan, shared._fcEnded = beganBind, endedBind
    end

    local function stopFreecam()
        freecamActive = false

        if fcConnection then
            fcConnection:Disconnect()
            fcConnection = nil
        end
        if shared._fcBegan then
            shared._fcBegan:Disconnect()
        end
        if shared._fcEnded then
            shared._fcEnded:Disconnect()
        end
        for k in pairs(movements) do
            movements[k] = false
        end

        Camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default

        setCharacterMovementEnabled(true)

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local freezeVel = rootPart:FindFirstChild("_FCFreeze")
            local attachment = rootPart:FindFirstChild("_FCFreezeAttachment")
            if freezeVel then
                freezeVel:Destroy()
            end
            if attachment then
                attachment:Destroy()
            end
        end
    end

    -- Fullbright
    local originalBrightness = Lighting.Brightness
    local originalAmbient = Lighting.Ambient
    local originalOutdoor = Lighting.OutdoorAmbient
    local originalFog = Lighting.FogEnd
    local function enableFullbright()
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.FogEnd = 1e9
    end
    local function disableFullbright()
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoor
        Lighting.FogEnd = originalFog
    end

    local function onFrameClick(frame, callback)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                callback()
            end
        end)
    end

    -- Watermark toggle
    local function showWatermark()
        G2L["194"].Visible = true
    end
    local function hideWatermark()
        G2L["194"].Visible = false
    end

    -- Radar toggle
    local function showRadar()
        G2L["198"].Visible = true
    end
    local function hideRadar()
        G2L["198"].Visible = false
    end

    -- Write Toggles

    wireToggle(G2L["2b"], enableFullbright, disableFullbright)
    wireToggle(G2L["31"], startFreecam, stopFreecam)
    wireToggle(G2L["3a"], startBhop, stopBhop)
    wireToggle(G2L["40"], startFakeSpeed, stopFakeSpeed)
    wireToggle(G2L["46"], startFlight, stopFlight)
    wireToggle(G2L["4c"], startNoclip, stopNoclip)
    wireToggle(G2L["52"], startSpin, stopSpin)
    wireToggle(G2L["78"], showWatermark, hideWatermark)
    wireToggle(G2L["d9"], function()
        ESP.ShowDowned = true
    end, function()
        ESP.ShowDowned = false
    end)

    -- Config name dropdown (using the config label as anchor)
    local configNames = { "config1", "config2", "config3" } -- populate however you like
    createDropdown(G2L["70"], configNames, "nil", function(val)
        G2L["70"].Text = val
        -- load/save logic here
    end)

    -- Theme dropdown
    local themeNames = { "default", "red", "blue", "green" }
    createDropdown(G2L["f"], themeNames, "nil", function(val)
        G2L["f"].Text = val
        -- apply theme logic here
    end)
    -- // ESP INTEGRATION
    local ESP = {
        Enabled = false,
        Boxes = false,
        Skeleton = false,
        Chams = false,
        OffscreenArrow = false,
        ShowDowned = true,
        ShowDead,
        OffscreenColor = Color3.fromRGB(199, 255, 255),
        ChamsColor = Color3.fromRGB(199, 255, 255),
        ChamsTransparency = 0.2,
        Color = Color3.fromRGB(199, 255, 255),
        ToolColor = Color3.fromRGB(199, 255, 255),
        FaceCamera = false,
        Names = false,
        Distance = false,
        Health = false,
        HealthBar = false,
        Tool = false,
        Tracers = false,
        TeamColor = true,
        Thickness = 1.5,
        AttachShift = 1,
        TeamMates = true,
        Players = true,
        DistanceS = 2000,
        Objects = setmetatable({}, { __mode = "kv" }),
        Overrides = {},
    }

    -- Core body parts to sample (skip accessories, tools, small handles)
    local CORE_PARTS = {
        Head = true,
        Torso = true, -- R6
        ["Upper Torso"] = true, -- R15
        ["Lower Torso"] = true, -- R15
        LeftUpperArm = true,
        RightUpperArm = true,
        LeftUpperLeg = true,
        RightUpperLeg = true,
        LeftLowerLeg = true,
        RightLowerLeg = true,
        LeftFoot = true,
        RightFoot = true,
        LeftHand = true,
        RightHand = true,
        ["Left Arm"] = true, -- R6
        ["Right Arm"] = true, -- R6
        ["Left Leg"] = true, -- R6
        ["Right Leg"] = true, -- R6
        HumanoidRootPart = false, -- explicitly excluded
    }

    local function Draw(obj, props)
        local new = Drawing.new(obj)
        for i, v in pairs(props or {}) do
            new[i] = v
        end
        return new
    end

    -- // RADAR SYSTEM
    local radarSystem = {
        Enabled = false,
        Range = 200,
        ShowPlayers = true,
        ShowDealers = true,
        ShowLoot = false,
        Size = 269, -- matches the ViewportFrame size
    }

    -- Replace the radar setup section (everything before the blip pool)

    local radarFrame = G2L["198"]

    -- Remove circular clipping, make it square
    radarFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

    -- Clear any existing children first
    for _, child in ipairs(radarFrame:GetChildren()) do
        child:Destroy()
    end

    -- Simple dark background
    local radarBG = Instance.new("Frame", radarFrame)
    radarBG.Size = UDim2.fromScale(1, 1)
    radarBG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    radarBG.BorderSizePixel = 0
    radarBG.ZIndex = 1

    -- Grid lines
    local gridH = Instance.new("Frame", radarBG)
    gridH.Size = UDim2.new(1, 0, 0, 1)
    gridH.Position = UDim2.fromScale(0, 0.5)
    gridH.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    gridH.BorderSizePixel = 0
    gridH.ZIndex = 2

    local gridV = Instance.new("Frame", radarBG)
    gridV.Size = UDim2.new(0, 1, 1, 0)
    gridV.Position = UDim2.fromScale(0.5, 0)
    gridV.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    gridV.BorderSizePixel = 0
    gridV.ZIndex = 2

    -- Square border using UIStroke
    local borderFrame = Instance.new("Frame", radarFrame)
    borderFrame.Size = UDim2.fromScale(1, 1)
    borderFrame.BackgroundTransparency = 1
    borderFrame.BorderSizePixel = 0
    borderFrame.ZIndex = 10

    local borderStroke = Instance.new("UIStroke", borderFrame)
    borderStroke.Thickness = 1.5
    borderStroke.Color = Color3.fromRGB(34, 103, 89)

    -- Self blip removed, replaced with crosshair at center
    local crossH = Instance.new("Frame", radarFrame)
    crossH.AnchorPoint = Vector2.new(0.5, 0.5)
    crossH.Position = UDim2.fromScale(0.5, 0.5)
    crossH.Size = UDim2.fromOffset(8, 1)
    crossH.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    crossH.BorderSizePixel = 0
    crossH.ZIndex = 10

    local crossV = Instance.new("Frame", radarFrame)
    crossV.AnchorPoint = Vector2.new(0.5, 0.5)
    crossV.Position = UDim2.fromScale(0.5, 0.5)
    crossV.Size = UDim2.fromOffset(1, 8)
    crossV.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    crossV.BorderSizePixel = 0
    crossV.ZIndex = 10

    -- North label
    local northLabel = Instance.new("TextLabel", radarFrame)
    northLabel.Size = UDim2.fromOffset(12, 12)
    northLabel.Position = UDim2.new(0.5, -6, 0, 2)
    northLabel.BackgroundTransparency = 1
    northLabel.Text = "N"
    northLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    northLabel.TextSize = 10
    northLabel.Font = Enum.Font.GothamBold
    northLabel.ZIndex = 10

    -- Blip pool
    local blipPool = {}
    local activeBlips = {}

    local function getBlip()
        local blip = table.remove(blipPool)
        if not blip then
            blip = Instance.new("Frame")
            blip.AnchorPoint = Vector2.new(0.5, 0.5)
            blip.BorderSizePixel = 0
            blip.ZIndex = 5

            -- Circle shape
            local corner = Instance.new("UICorner", blip)
            corner.CornerRadius = UDim.new(1, 0)

            -- Black outline stroke
            local stroke = Instance.new("UIStroke", blip)
            stroke.Thickness = 1
            stroke.Color = Color3.fromRGB(0, 0, 0)

            blip.Parent = radarFrame
        end
        return blip
    end

    local function releaseBlip(blip)
        blip.Visible = false
        table.insert(blipPool, blip)
    end

    -- Local player blip (always center, always white, always on top)
    local selfBlip = Instance.new("Frame", radarFrame)
    selfBlip.AnchorPoint = Vector2.new(0.5, 0.5)
    selfBlip.Position = UDim2.fromScale(0.5, 0.5)
    selfBlip.Size = UDim2.fromOffset(7, 7)
    selfBlip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    selfBlip.BorderSizePixel = 0
    selfBlip.ZIndex = 10

    local selfCorner = Instance.new("UICorner", selfBlip)
    selfCorner.CornerRadius = UDim.new(1, 0)

    -- Self direction indicator (small line showing which way you face)
    local selfDir = Instance.new("Frame", selfBlip)
    selfDir.Name = "Dir"
    selfDir.AnchorPoint = Vector2.new(0.5, 1)
    selfDir.Position = UDim2.new(0.5, 0, 0, 0)
    selfDir.Size = UDim2.fromOffset(2, 5)
    selfDir.BorderSizePixel = 0
    selfDir.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    selfDir.ZIndex = 11

    local selfStroke = Instance.new("UIStroke", selfBlip)
    selfStroke.Thickness = 1
    selfStroke.Color = Color3.fromRGB(0, 0, 0)

    -- Radar label
    local radarLabel = Instance.new("TextLabel", radarFrame)
    radarLabel.Size = UDim2.new(1, 0, 0, 14)
    radarLabel.Position = UDim2.new(0, 0, 1, -16)
    radarLabel.BackgroundTransparency = 1
    radarLabel.Text = "radar"
    radarLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    radarLabel.TextSize = 11
    radarLabel.Font = Enum.Font.Code
    radarLabel.ZIndex = 5
    radarLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Convert world position to radar screen position
    -- // WORLD TO RADAR (replace your entire existing worldToRadar function)
    local function worldToRadar(worldPos, localPos)
        local diff = worldPos - localPos

        local camCF = workspace.CurrentCamera.CFrame
        local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
        local flatForward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit

        local x = diff:Dot(flatRight)
        local y = -diff:Dot(flatForward)

        local sizeX = radarFrame.AbsoluteSize.X
        local sizeY = radarFrame.AbsoluteSize.Y
        local halfX = sizeX / 2
        local halfY = sizeY / 2
        local scale = halfX / radarSystem.Range

        local screenX = math.clamp(halfX + x * scale, 2, sizeX - 2)
        local screenY = math.clamp(halfY + y * scale, 2, sizeY - 2)

        return screenX, screenY
    end

    -- Get blip color based on relationship
    local function getBlipColor(player)
        local success, color = pcall(function()
            if player == Players.LocalPlayer then
                return Color3.fromRGB(255, 255, 255)
            end

            -- Whitelist check wrapped safely
            local isWhitelisted = false
            pcall(function()
                local uid = rawget(player, "UserId")
                if uid then
                    isWhitelisted = rawget(whitelist, uid) == true
                        or rawget(whitelist, tostring(uid)) == true
                end
            end)

            if isWhitelisted then
                return Color3.fromRGB(0, 255, 100)
            end

            -- Team check wrapped safely
            local isTeammate = false
            pcall(function()
                local pt = rawget(player, "Team")
                local lpt = rawget(Players.LocalPlayer, "Team")
                if pt and lpt and pt == lpt then
                    isTeammate = true
                end
            end)

            if isTeammate then
                return Color3.fromRGB(0, 255, 100)
            end

            return Color3.fromRGB(255, 50, 50)
        end)

        if success and color then
            return color
        end
        return Color3.fromRGB(255, 50, 50)
    end

    -- Helper: check if a player is whitelisted
    local function isWhitelisted(player)
        return whitelist and player and player.UserId and whitelist[player.UserId] == true
    end

    -- Rotation helper: rotate a frame's direction arrow to face a direction
    local function getBlipRotation(worldPos, localPos)
        local camCF = workspace.CurrentCamera.CFrame
        local diff = worldPos - localPos
        local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
        local flatForward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local x = diff:Dot(flatRight)
        local y = -diff:Dot(flatForward)
        return math.atan2(x, -y) * (180 / math.pi)
    end

    -- // RADAR LOOP (replace your entire existing startRadar and stopRadar functions)
    local radarConn
    local function startRadar()
        radarSystem.Enabled = true
        radarFrame.Visible = true

        radarConn = RunService.Heartbeat:Connect(function()
            if not radarSystem.Enabled then
                return
            end

            -- Center point: camera when in freecam, root when not
            local localPos
            if freecamActive then
                localPos = workspace.CurrentCamera.CFrame.Position
            else
                local localChar = Players.LocalPlayer.Character
                local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
                if not localRoot then
                    return
                end
                localPos = localRoot.Position
            end

            -- Release all active blips back to pool
            for _, blip in ipairs(activeBlips) do
                releaseBlip(blip)
            end
            activeBlips = {}

            if radarSystem.ShowPlayers then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == Players.LocalPlayer then
                        continue
                    end

                    pcall(function()
                        if not player or not player.Parent then
                            return
                        end

                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if not root then
                            return
                        end
                        if hum and hum.Health <= 0 then
                            return
                        end

                        local dist = (root.Position - localPos).Magnitude
                        if dist > radarSystem.Range then
                            return
                        end

                        local sx, sy = worldToRadar(root.Position, localPos)
                        local color = getBlipColor(player)
                        local blip = getBlip()

                        blip.Size = UDim2.fromOffset(5, 5)
                        blip.Position = UDim2.fromOffset(sx, sy)
                        blip.BackgroundColor3 = color
                        blip.Visible = true

                        table.insert(activeBlips, blip)
                    end)
                end
            end
            -- Inside the radar Heartbeat loop, after ShowPlayers block:

            if radarSystem.ShowDealers then
                local shopz = workspace:FindFirstChild("Map")
                    and workspace.Map:FindFirstChild("Shopz")
                if shopz then
                    for _, child in ipairs(shopz:GetChildren()) do
                        pcall(function()
                            local part = child:FindFirstChildWhichIsA("BasePart")
                            if not part then
                                return
                            end
                            local dist = (part.Position - localPos).Magnitude
                            if dist > radarSystem.Range then
                                return
                            end
                            local sx, sy = worldToRadar(part.Position, localPos)
                            local color = dealerColors[child.Name] or Color3.fromRGB(210, 120, 30)
                            local blip = getBlip()
                            blip.Size = UDim2.fromOffset(5, 5)
                            blip.Position = UDim2.fromOffset(sx, sy)
                            blip.BackgroundColor3 = color
                            blip.Visible = true
                            table.insert(activeBlips, blip)
                        end)
                    end
                end
            end

            if radarSystem.ShowLoot then
                local filter = workspace:FindFirstChild("Filter")
                local spawned = filter and filter:FindFirstChild("SpawnedTools")
                if spawned then
                    for _, child in ipairs(spawned:GetChildren()) do
                        pcall(function()
                            if not child:IsA("Model") then
                                return
                            end
                            local part = child:FindFirstChildWhichIsA("BasePart")
                            if not part then
                                return
                            end
                            local dist = (part.Position - localPos).Magnitude
                            if dist > radarSystem.Range then
                                return
                            end
                            local sx, sy = worldToRadar(part.Position, localPos)
                            local blip = getBlip()
                            blip.Size = UDim2.fromOffset(4, 4)
                            blip.Position = UDim2.fromOffset(sx, sy)
                            blip.BackgroundColor3 = Color3.fromRGB(255, 220, 50)
                            blip.Visible = true
                            table.insert(activeBlips, blip)
                        end)
                    end
                end
            end
        end)
    end

    local function stopRadar()
        radarSystem.Enabled = false
        radarFrame.Visible = false

        if radarConn then
            radarConn:Disconnect()
            radarConn = nil
        end

        for _, blip in ipairs(activeBlips) do
            releaseBlip(blip)
        end
        activeBlips = {}
    end

    function ESP:GetTeam(p)
        return p and p.Team
    end
    function ESP:IsTeamMate(p)
        local targetTeam = self:GetTeam(p)
        local localTeam = self:GetTeam(espPlr)
        return targetTeam and localTeam and targetTeam == localTeam
    end
    function ESP:GetColor(obj)
        local p = espPlrs:GetPlayerFromCharacter(obj)
        return p and self.TeamColor and p.Team and p.Team.TeamColor.Color or self.Color
    end
    function ESP:GetBox(obj)
        return self.Objects[obj]
    end

    local boxBase = {}
    boxBase.__index = boxBase

    function boxBase:Remove()
        ESP.Objects[self.Object] = nil
        for i, v in pairs(self.Components) do
            v.Visible = false
            v:Remove()
            self.Components[i] = nil
        end
        -- clean up part cache connections
        if self._cacheConns then
            for _, c in ipairs(self._cacheConns) do
                c:Disconnect()
            end
            self._cacheConns = nil
        end

        if self.Highlight then
            self.Highlight:Destroy()
            self.Highlight = nil
        end

        if self._arrowGui then
            self._arrowGui:Destroy()
            self._arrowGui = nil
        end
    end

    -- Build and cache the list of core body parts for a character
    function boxBase:RebuildPartCache()
        self._partCache = {}
        local character = self.Player and self.Player.Character or self.Object
        if not character then
            return
        end
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and CORE_PARTS[part.Name] then
                table.insert(self._partCache, part)
            end
        end
    end

    function boxBase:SetupCacheListeners()
        local character = self.Player and self.Player.Character or self.Object
        if not character then
            return
        end
        self._cacheConns = {}
        table.insert(
            self._cacheConns,
            character.ChildAdded:Connect(function(child)
                if child:IsA("BasePart") and CORE_PARTS[child.Name] then
                    table.insert(self._partCache, child)
                end
            end)
        )
        table.insert(
            self._cacheConns,
            character.ChildRemoved:Connect(function(child)
                if child:IsA("BasePart") and CORE_PARTS[child.Name] then
                    for i, part in ipairs(self._partCache) do
                        if part == child then
                            table.remove(self._partCache, i)
                            break
                        end
                    end
                end
            end)
        )
    end

    function boxBase:Update()
        if not self.PrimaryPart then
            return self:Remove()
        end

        -- Early exit: is root part even in front of camera?
        local rootPos = self.PrimaryPart.Position
        local camCF = espCam.CFrame
        local toTarget = rootPos - camCF.p
        if toTarget:Dot(camCF.LookVector) <= 0 then
            for i, v in pairs(self.Components) do
                if i ~= "OffscreenArrow" then
                    v.Visible = false
                end
            end
            -- no return, let arrow section run below
        end

        local color = self.Color
            or self.ColorDynamic and self:ColorDynamic()
            or ESP:GetColor(self.Object)
            or ESP.Color
        local allow = true
        if self.Player and not ESP.TeamMates and ESP:IsTeamMate(self.Player) then
            allow = false
        end
        if self.Player and not ESP.Players then
            allow = false
        end
        if not workspace:IsAncestorOf(self.PrimaryPart) then
            allow = false
        end
        if not allow then
            for i, v in pairs(self.Components) do
                v.Visible = false
            end
            return
        end

        local rootCF = self.PrimaryPart.CFrame
        local dist = math.floor((rootCF.p - camCF.p).magnitude)
        if dist >= ESP.DistanceS then
            for i, v in pairs(self.Components) do
                v.Visible = false
            end
            return
        end

        -- Build screen bounding box from cached core parts
        -- Only sample top-center and bottom-center of each part
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local anyOnScreen = false

        if self._partCache then
            for _, part in ipairs(self._partCache) do
                if part and part.Parent then
                    local cf = part.CFrame
                    local hy = part.Size.Y / 2

                    local topScreen, topVis =
                        espCam:WorldToViewportPoint((cf * CFrame.new(0, hy, 0)).p)
                    local bottomScreen, botVis =
                        espCam:WorldToViewportPoint((cf * CFrame.new(0, -hy, 0)).p)

                    if topScreen.Z > 0 then
                        if topVis then
                            anyOnScreen = true
                        end
                        minX = math.min(minX, topScreen.X)
                        minY = math.min(minY, topScreen.Y)
                        maxX = math.max(maxX, topScreen.X)
                        maxY = math.max(maxY, topScreen.Y)
                    end
                    if bottomScreen.Z > 0 then
                        if botVis then
                            anyOnScreen = true
                        end
                        minX = math.min(minX, bottomScreen.X)
                        minY = math.min(minY, bottomScreen.Y)
                        maxX = math.max(maxX, bottomScreen.X)
                        maxY = math.max(maxY, bottomScreen.Y)
                    end
                end
            end
        end

        -- Fallback
        if minX == math.huge then
            local screen, onScreen = espCam:WorldToViewportPoint(rootCF.p)
            if onScreen and screen.Z > 0 then
                anyOnScreen = true
                local fallback = 30
                minX = screen.X - fallback
                minY = screen.Y - fallback * 2
                maxX = screen.X + fallback
                maxY = screen.Y + fallback * 2
            end
        end

        if not anyOnScreen or minX == math.huge then
            for i, v in pairs(self.Components) do
                if i ~= "OffscreenArrow" then
                    v.Visible = false
                end
            end
            -- no return, let arrow section run below
        end

        local left = minX
        local right = maxX
        local top = minY
        local bottom = maxY
        local boxH = bottom - top
        local boxW = right - left

        -- // BOX
        if ESP.Boxes then
            self.Components.Quad.Visible = true
            self.Components.Quad.PointA = Vector2.new(left, top)
            self.Components.Quad.PointB = Vector2.new(right, top)
            self.Components.Quad.PointC = Vector2.new(right, bottom)
            self.Components.Quad.PointD = Vector2.new(left, bottom)
            self.Components.Quad.Color = color
        else
            self.Components.Quad.Visible = false
        end

        -- // NAME
        if ESP.Names then
            local nameSize = 14
            local nameHeight = nameSize * 0.6
            self.Components.Name.Visible = true
            self.Components.Name.Position = Vector2.new((left + right) / 2, top - nameHeight - 2)
            self.Components.Name.Text = self.Name
            self.Components.Name.Color = ESP.TextColor or Color3.fromRGB(255, 255, 255)
            self.Components.Name.Center = true
            self.Components.Name.Size = nameSize
        else
            self.Components.Name.Visible = false
        end

        -- // HEALTH

        local hum = self.Player
            and self.Player.Character
            and self.Player.Character:FindFirstChildOfClass("Humanoid")
        local barX = left - math.max(boxW * 0.03, 4)

        -- // DEAD CHECK

        local isDead = hum and hum.Health <= 0

        if isDead then
            if not ESP.ShowDead then
                for i, v in pairs(self.Components) do
                    v.Visible = false
                end
                return
            end
        end

        -- // HEALTH BAR (draw BG first, then fill on top)
        if self.Player and ESP.HealthBar and hum then
            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local filledTop = bottom - (boxH * hpRatio)
            local r = math.floor((1 - hpRatio) * 255)
            local g = math.floor(hpRatio * 255)

            -- BG drawn first (lower Z = drawn first = behind)
            self.Components.HealthBarBG.Visible = true
            self.Components.HealthBarBG.From = Vector2.new(barX, top)
            self.Components.HealthBarBG.To = Vector2.new(barX, bottom)
            self.Components.HealthBarBG.Color = Color3.fromRGB(30, 30, 30)
            self.Components.HealthBarBG.Thickness = 4 -- slightly thicker so it shows as outline

            -- Fill drawn second (renders on top)
            self.Components.HealthBar.Visible = true
            self.Components.HealthBar.From = Vector2.new(barX, filledTop)
            self.Components.HealthBar.To = Vector2.new(barX, bottom)
            self.Components.HealthBar.Color = Color3.fromRGB(r, g, 0)
            self.Components.HealthBar.Thickness = 2
        else
            self.Components.HealthBar.Visible = false
            self.Components.HealthBarBG.Visible = false
        end

        -- // HEALTH TEXT
        if self.Player and ESP.Health and hum then
            local healthText = math.floor(hum.Health + 0.5) .. "/" .. math.floor(hum.MaxHealth)
            local healthSize = 11
            local healthHeight = healthSize * 0.6
            self.Components.Health.Visible = true
            self.Components.Health.Position = Vector2.new(barX - 40, bottom - healthHeight)
            self.Components.Health.Text = healthText
            self.Components.Health.Color = ESP.TextColor or Color3.fromRGB(255, 255, 255)
            self.Components.Health.Center = false
            self.Components.Health.Size = healthSize
        else
            self.Components.Health.Visible = false
        end

        -- // SKELETON
        if ESP.Skeleton and self.Player then
            local char = self.Player.Character
            local skelColor = ESP.Color

            local function getPart(name)
                return char and char:FindFirstChild(name)
            end

            local function partPos(name)
                local p = getPart(name)
                return p and p.Position or nil
            end

            local function toScreen(pos)
                if not pos then
                    return nil, false
                end
                local screen, vis = espCam:WorldToViewportPoint(pos)
                if screen.Z > 0 then
                    return Vector2.new(screen.X, screen.Y), vis
                end
                return nil, false
            end

            local function drawBone(component, fromPos, toPos)
                local a, aVis = toScreen(fromPos)
                local b, bVis = toScreen(toPos)
                if a and b and (aVis or bVis) then
                    self.Components[component].Visible = true
                    self.Components[component].From = a
                    self.Components[component].To = b
                    self.Components[component].Color = skelColor
                else
                    self.Components[component].Visible = false
                end
            end

            -- Joint positions
            local headPos = partPos("Head")
            local torsoPos = partPos("Torso")
            local leftArmPos = partPos("Left Arm")
            local rightArmPos = partPos("Right Arm")
            local leftLegPos = partPos("Left Leg")
            local rightLegPos = partPos("Right Leg")

            -- Shoulder joints (edge of torso)
            local torso = getPart("Torso")
            local leftShoulderPos = torso
                    and (torso.CFrame * CFrame.new(-torso.Size.X / 2, torso.Size.Y / 4, 0)).p
                or nil
            local rightShoulderPos = torso
                    and (torso.CFrame * CFrame.new(torso.Size.X / 2, torso.Size.Y / 4, 0)).p
                or nil

            -- Hip joints (edge of torso bottom)
            local leftHipPos = torso
                    and (torso.CFrame * CFrame.new(-torso.Size.X / 4, -torso.Size.Y / 2, 0)).p
                or nil
            local rightHipPos = torso
                    and (torso.CFrame * CFrame.new(torso.Size.X / 4, -torso.Size.Y / 2, 0)).p
                or nil

            -- Head to torso (neck)
            drawBone(
                "SkelHead",
                headPos,
                torsoPos
                    and (getPart("Torso").CFrame * CFrame.new(0, getPart("Torso").Size.Y / 2, 0)).p
            )

            -- Torso spine (center)
            drawBone(
                "SkelSpine",
                torsoPos and (torso.CFrame * CFrame.new(0, torso.Size.Y / 2, 0)).p,
                torsoPos and (torso.CFrame * CFrame.new(0, -torso.Size.Y / 2, 0)).p
            )

            -- Shoulders (torso center top to shoulder joints)
            drawBone("SkelLeftShoulder", rightShoulderPos, leftShoulderPos)

            -- Arms (shoulder joint to hand)
            drawBone(
                "SkelLeftArm",
                leftShoulderPos,
                leftArmPos
                    and (getPart("Left Arm").CFrame * CFrame.new(
                        0,
                        -getPart("Left Arm").Size.Y / 2,
                        0
                    )).p
            )
            drawBone(
                "SkelRightArm",
                rightShoulderPos,
                rightArmPos
                    and (getPart("Right Arm").CFrame * CFrame.new(
                        0,
                        -getPart("Right Arm").Size.Y / 2,
                        0
                    )).p
            )

            -- Hip line (connecting both hips)
            drawBone("SkelHips", leftHipPos, rightHipPos)

            -- Legs (hip joint down to feet)
            drawBone(
                "SkelLeftLeg",
                leftHipPos,
                leftLegPos
                    and (getPart("Left Leg").CFrame * CFrame.new(
                        0,
                        -getPart("Left Leg").Size.Y / 2,
                        0
                    )).p
            )
            drawBone(
                "SkelRightLeg",
                rightHipPos,
                rightLegPos
                    and (getPart("Right Leg").CFrame * CFrame.new(
                        0,
                        -getPart("Right Leg").Size.Y / 2,
                        0
                    )).p
            )

            -- Hide unused component
            self.Components["SkelRightShoulder"].Visible = false
        else
            self.Components["SkelHead"].Visible = false
            self.Components["SkelSpine"].Visible = false
            self.Components["SkelHips"].Visible = false
            self.Components["SkelLeftArm"].Visible = false
            self.Components["SkelRightArm"].Visible = false
            self.Components["SkelLeftLeg"].Visible = false
            self.Components["SkelRightLeg"].Visible = false
            self.Components["SkelLeftShoulder"].Visible = false
            self.Components["SkelRightShoulder"].Visible = false
        end

        -- Friend filter
        if self.Player and not ESP.ShowFriendly then
            if isWhitelisted(self.Player) or ESP:IsTeamMate(self.Player) then
                allow = false
            end
        end

        -- Downed filter
        if self.Player and not ESP.ShowDowned then
            local ok, isDowned = pcall(function()
                local charStats = game:GetService("ReplicatedStorage"):FindFirstChild("CharStats")
                local playerStats = charStats and charStats:FindFirstChild(self.Player.Name)
                local downedVal = playerStats and playerStats:FindFirstChild("Downed")
                return downedVal and downedVal.Value == true
            end)
            if ok and isDowned then
                allow = false
            end
        end

        if not allow then
            for i, v in pairs(self.Components) do
                v.Visible = false
            end
            return
        end

        -- // CHAMS
        if ESP.Chams and self.Player then
            local char = self.Player.Character
            if char then
                if not self.Highlight then
                    self.Highlight = Instance.new("Highlight")
                    self.Highlight.FillTransparency = ESP.ChamsTransparency
                    self.Highlight.OutlineTransparency = 1
                    self.Highlight.FillColor = ESP.ChamsColor
                    self.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    self.Highlight.Parent = char
                end
                self.Highlight.FillColor = ESP.ChamsColor
                self.Highlight.FillTransparency = ESP.ChamsTransparency
            end
        else
            if self.Highlight then
                self.Highlight:Destroy()
                self.Highlight = nil
            end
        end

        -- // OFFSCREEN ARROW
        local arrowRootScreen = espCam:WorldToViewportPoint(rootCF.p)
        local arrow = self.Components["OffscreenArrow"]
        if arrow and ESP.OffscreenArrow and self.Player then
            local vp = espCam.ViewportSize
            local onScreen = arrowRootScreen.Z > 0
                and arrowRootScreen.X >= 0
                and arrowRootScreen.X <= vp.X
                and arrowRootScreen.Y >= 0
                and arrowRootScreen.Y <= vp.Y

            if not onScreen then
                local centerX = vp.X / 2
                local centerY = vp.Y / 2
                local radius = math.min(vp.X, vp.Y) * 0.42

                local camCFrame = espCam.CFrame
                local toPlayer = rootCF.p - camCFrame.Position

                -- Flatten to camera-relative horizontal/vertical
                local rightDot = toPlayer:Dot(camCFrame.RightVector)
                local upDot = toPlayer:Dot(camCFrame.UpVector)
                local forwardDot = toPlayer:Dot(camCFrame.LookVector)

                -- Project onto the horizontal plane around the camera
                -- If behind, flip horizontal so arrow wraps around sides correctly
                local dirX, dirY
                if forwardDot >= 0 then
                    dirX = rightDot
                    dirY = -upDot
                else
                    -- Behind camera: flip horizontal, keep vertical
                    -- This makes arrows wrap: left stays left, right stays right
                    -- but they push toward top/bottom edges when directly behind
                    if math.abs(rightDot) > math.abs(upDot) then
                        -- More to the side: keep side, push vertical to center
                        dirX = rightDot > 0 and 1 or -1
                        dirY = -upDot
                    else
                        -- More above/below: push to top/bottom
                        dirX = rightDot
                        dirY = upDot > 0 and -1 or 1
                    end
                end

                local len = math.sqrt(dirX * dirX + dirY * dirY)
                if len == 0 then
                    len = 1
                end
                dirX = dirX / len
                dirY = dirY / len

                local arrowX = math.clamp(centerX + dirX * radius, 20, vp.X - 20)
                local arrowY = math.clamp(centerY + dirY * radius, 20, vp.Y - 20)

                arrow.Visible = true
                arrow.ImageColor3 = ESP.OffscreenColor or Color3.fromRGB(255, 255, 255)
                arrow.Position = UDim2.new(0, arrowX, 0, arrowY)
                arrow.Rotation = math.atan2(dirY, dirX) * (180 / math.pi) - 180
            else
                arrow.Visible = false
            end
        else
            if arrow then
                arrow.Visible = false
            end
        end

        local boxCenterX = (left + right) / 2
        local boxWidth = right - left

        -- declare ALL shared variables BEFORE any block that uses them
        local toolShown = false
        local toolTextHeight = 12 * 0.6
        local boxCenterX = (left + right) / 2

        -- // WEAPON
        if self.Player and ESP.Tool then
            local tool = self.Player.Character
                and self.Player.Character:FindFirstChildOfClass("Tool")
            if tool then
                toolShown = true
                self.Components.Tool.Visible = true
                self.Components.Tool.Position = Vector2.new(boxCenterX, bottom + 6)
                self.Components.Tool.Text = tool.Name
                self.Components.Tool.Color = ESP.TextColor or Color3.fromRGB(255, 255, 255)
                self.Components.Tool.Center = true
                self.Components.Tool.Size = 12
            else
                self.Components.Tool.Visible = false
            end
        else
            self.Components.Tool.Visible = false
        end

        -- // DISTANCE
        if ESP.Distance then
            local distText = dist .. "m"
            local distY = toolShown and (bottom + toolTextHeight + 8) or (bottom + 6)
            self.Components.Distance.Visible = true
            self.Components.Distance.Position = Vector2.new(boxCenterX, distY)
            self.Components.Distance.Text = distText
            self.Components.Distance.Color = ESP.TextColor or Color3.fromRGB(255, 255, 255)
            self.Components.Distance.Center = true
            self.Components.Distance.Size = 12
        else
            self.Components.Distance.Visible = false
        end

        -- // TRACER
        if ESP.Tracers then
            local attachPoint
            if ESP.Boxes and minX ~= math.huge then
                -- attach to bottom-center of the ESP box
                attachPoint = Vector2.new((left + right) / 2, bottom)
            else
                -- fallback: attach to torso/root position
                local torsoScreen, tv = espCam:WorldToViewportPoint(rootCF.p)
                if tv and torsoScreen.Z > 0 then
                    attachPoint = Vector2.new(torsoScreen.X, torsoScreen.Y)
                end
            end

            if attachPoint then
                self.Components.Tracer.Visible = true
                self.Components.Tracer.From = attachPoint
                self.Components.Tracer.To =
                    Vector2.new(espCam.ViewportSize.X / 2, espCam.ViewportSize.Y / ESP.AttachShift)
                self.Components.Tracer.Color = color
            else
                self.Components.Tracer.Visible = false
            end
        else
            self.Components.Tracer.Visible = false
        end
    end

    function ESP:Add(obj, options)
        if not obj.Parent and not options.RenderInNil then
            return warn(obj, "has no parent")
        end
        local box = setmetatable({
            Name = options.Name or obj.Name,
            Type = "Box",
            Color = options.Color,
            Size = options.Size or Vector3.new(4, 6, 0),
            Object = obj,
            Player = options.Player or espPlrs:GetPlayerFromCharacter(obj),
            PrimaryPart = options.PrimaryPart
                or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild(
                    "HumanoidRootPart"
                ) or obj:FindFirstChildWhichIsA("BasePart"))
                or obj:IsA("BasePart") and obj,
            Components = {},
            IsEnabled = options.IsEnabled,
            Temporary = options.Temporary,
            ColorDynamic = options.ColorDynamic,
            RenderInNil = options.RenderInNil,
            _partCache = {},
            _cacheConns = {},
        }, boxBase)

        if self:GetBox(obj) then
            self:GetBox(obj):Remove()
        end

        box.Components["Quad"] = Draw("Quad", {
            Thickness = self.Thickness,
            Color = self.Color,
            Transparency = 1,
            Filled = false,
            Visible = false,
        })
        box.Components["Name"] = Draw("Text", {
            Text = box.Name,
            Color = self.Color,
            Center = false,
            Outline = true,
            Size = 14,
            Visible = false,
        })
        box.Components["Distance"] = Draw(
            "Text",
            { Color = self.Color, Center = false, Outline = true, Size = 12, Visible = false }
        )
        box.Components["Health"] = Draw(
            "Text",
            { Color = self.Color, Center = false, Outline = true, Size = 11, Visible = false }
        )
        box.Components["HealthBar"] = Draw(
            "Line",
            { Thickness = 4, Color = Color3.fromRGB(0, 255, 0), Transparency = 1, Visible = false }
        )
        box.Components["HealthBarBG"] = Draw(
            "Line",
            { Thickness = 4, Color = Color3.fromRGB(30, 30, 30), Transparency = 1, Visible = false }
        )
        box.Components["Tool"] = Draw(
            "Text",
            { Color = self.Color, Center = false, Outline = true, Size = 12, Visible = false }
        )
        box.Components["Tracer"] = Draw(
            "Line",
            { Thickness = self.Thickness, Color = self.Color, Transparency = 1, Visible = false }
        )
        -- Skeleton lines (R6: 7 bones)
        box.Components["SkelHead"] =
            Draw("Line", { Thickness = 1.5, Color = self.Color, Transparency = 1, Visible = false })
        box.Components["SkelSpine"] =
            Draw("Line", { Thickness = 1.5, Color = self.Color, Transparency = 1, Visible = false })
        box.Components["SkelHips"] =
            Draw("Line", { Thickness = 1.5, Color = self.Color, Transparency = 1, Visible = false })
        box.Components["SkelLeftArm"] =
            Draw("Line", { Thickness = 1.5, Color = self.Color, Transparency = 1, Visible = false })
        box.Components["SkelRightArm"] =
            Draw("Line", { Thickness = 1.5, Color = self.Color, Transparency = 1, Visible = false })
        box.Components["SkelLeftLeg"] =
            Draw("Line", { Thickness = 1.5, Color = self.Color, Transparency = 1, Visible = false })
        box.Components["SkelRightLeg"] =
            Draw("Line", { Thickness = 1.5, Color = self.Color, Transparency = 1, Visible = false })
        box.Components["SkelLeftShoulder"] =
            Draw("Line", { Thickness = 1.5, Color = self.Color, Transparency = 1, Visible = false })
        box.Components["SkelRightShoulder"] =
            Draw("Line", { Thickness = 1.5, Color = self.Color, Transparency = 1, Visible = false })

        local arrowGui = Instance.new("ScreenGui")
        arrowGui.Name = "ArrowGui_" .. tostring(obj)
        arrowGui.ResetOnSpawn = false
        arrowGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        arrowGui.Parent = Players.LocalPlayer.PlayerGui

        local arrowImg = Instance.new("ImageLabel", arrowGui)
        arrowImg.Image = "rbxassetid://8317995440"
        arrowImg.BackgroundTransparency = 1
        arrowImg.Size = UDim2.new(0, 20, 0, 20)
        arrowImg.AnchorPoint = Vector2.new(0.5, 0.5)
        arrowImg.Visible = false
        arrowImg.ZIndex = 99999

        box.Components["OffscreenArrow"] = arrowImg
        box._arrowGui = arrowGui -- store reference for cleanup

        -- Build initial part cache and set up listeners
        box:RebuildPartCache()
        box:SetupCacheListeners()

        self.Objects[obj] = box

        -- Add this near the top of ESP:Add or in the update loop player check
        -- After: if not allow then ...

        obj.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                box:Remove()
            end
        end)
        local hum = obj:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function()
                box:Remove()
            end)
        end

        return box
    end

    -- Update loop: use Heartbeat instead of RenderStepped
    local frameSkip = 0
    RunService.Heartbeat:Connect(function()
        espCam = workspace.CurrentCamera
        if not ESP.Enabled then
            return
        end

        -- Throttle: update every 2 heartbeats
        frameSkip += 1
        if frameSkip < 2 then
            return
        end
        frameSkip = 0

        for i, v in pairs(ESP.Objects) do
            if v.Update then
                local s, e = pcall(v.Update, v)
                if not s then
                    warn("[ESP]", e)
                end
            end
        end
    end)

    -- Player hooks
    local function espCharAdded(char)
        local p = espPlrs:GetPlayerFromCharacter(char)
        if not char:FindFirstChild("HumanoidRootPart") then
            local ev
            ev = char.ChildAdded:Connect(function(c)
                if c.Name == "HumanoidRootPart" then
                    ev:Disconnect()
                    local box = ESP:Add(char, { Name = p.Name, Player = p, PrimaryPart = c })
                end
            end)
        else
            ESP:Add(char, { Name = p.Name, Player = p, PrimaryPart = char.HumanoidRootPart })
        end
    end

    local function espPlayerAdded(p)
        p.CharacterAdded:Connect(function(char)
            espCharAdded(char)
        end)
        if p.Character then
            coroutine.wrap(espCharAdded)(p.Character)
        end
    end

    espPlrs.PlayerAdded:Connect(espPlayerAdded)
    for _, v in ipairs(espPlrs:GetPlayers()) do
        if v ~= espPlr then
            espPlayerAdded(v)
        end
    end

    -- Add after boxBase definition
    local objectBase = {}
    objectBase.__index = objectBase

    function objectBase:Remove()
        ESP.Objects[self.Object] = nil
        for i, v in pairs(self.Components) do
            v.Visible = false
            v:Remove()
            self.Components[i] = nil
        end
    end

    function objectBase:Update()
        if not self.PrimaryPart or not workspace:IsAncestorOf(self.PrimaryPart) then
            return self:Remove()
        end

        local camCF = espCam.CFrame
        local rootPos = self.PrimaryPart.Position
        local dist = math.floor((rootPos - camCF.p).Magnitude)

        if dist >= ESP.DistanceS then
            for _, v in pairs(self.Components) do
                v.Visible = false
            end
            return
        end

        local screen, onScreen = espCam:WorldToViewportPoint(rootPos)
        if not onScreen or screen.Z <= 0 then
            for _, v in pairs(self.Components) do
                v.Visible = false
            end
            return
        end

        local sx, sy = screen.X, screen.Y

        self.Components["Name"].Visible = true
        self.Components["Name"].Position = Vector2.new(sx, sy - 8)
        self.Components["Name"].Text = self.Name
        self.Components["Name"].Color = self.Color
        self.Components["Name"].Center = true
        self.Components["Name"].Size = 13
        self.Components["Name"].Outline = true

        self.Components["Distance"].Visible = true
        self.Components["Distance"].Position = Vector2.new(sx, sy + 4)
        self.Components["Distance"].Text = dist .. "m"
        self.Components["Distance"].Color = Color3.fromRGB(200, 200, 200)
        self.Components["Distance"].Center = true
        self.Components["Distance"].Size = 11
        self.Components["Distance"].Outline = true
    end

    function ESP:AddObject(obj, options)
        if self.Objects[obj] then
            self.Objects[obj]:Remove()
        end

        local primaryPart = obj:IsA("BasePart") and obj
            or obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChildWhichIsA("BasePart")
        if not primaryPart then
            return
        end

        local box = setmetatable({
            Name = options.Name or obj.Name,
            Color = options.Color or Color3.fromRGB(200, 200, 200),
            Object = obj,
            PrimaryPart = primaryPart,
            Components = {},
        }, objectBase)

        box.Components["Name"] = Draw("Text", { Visible = false, Outline = true, Size = 13 })
        box.Components["Distance"] = Draw("Text", { Visible = false, Outline = true, Size = 11 })

        self.Objects[obj] = box

        obj.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                box:Remove()
            end
        end)

        return box
    end

    local ESP_Dealers = { Enabled = false }

    local function scanDealers()
        local shopz = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Shopz")
        if not shopz then
            return
        end
        for _, child in ipairs(shopz:GetChildren()) do
            local color = dealerColors[child.Name]
            if color and not ESP.Objects[child] then
                ESP:AddObject(child, { Name = child.Name, Color = color })
            end
        end
    end

    local function hookDealerFolder()
        local shopz = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Shopz")
        if not shopz then
            return
        end
        shopz.ChildAdded:Connect(function(child)
            if not ESP_Dealers.Enabled then
                return
            end
            local color = dealerColors[child.Name]
            if color then
                task.wait() -- let it fully load
                ESP:AddObject(child, { Name = child.Name, Color = color })
            end
        end)
        shopz.ChildRemoved:Connect(function(child)
            if ESP.Objects[child] then
                ESP.Objects[child]:Remove()
            end
        end)
    end

    local function enableDealerESP()
        ESP_Dealers.Enabled = true
        scanDealers()
        hookDealerFolder()
    end

    local function disableDealerESP()
        ESP_Dealers.Enabled = false
        local shopz = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Shopz")
        if not shopz then
            return
        end
        for _, child in ipairs(shopz:GetChildren()) do
            if ESP.Objects[child] then
                ESP.Objects[child]:Remove()
            end
        end
    end

    local ESP_Safes = { Enabled = false }

    local safePrefixes = {
        Register = Color3.fromRGB(130, 130, 130), -- gray
        MediumSafe = Color3.fromRGB(10, 80, 40), -- deep dark green
        SmallSafe = Color3.fromRGB(100, 10, 10), -- deep dark red
    }

    local function getSafeColor(name)
        for prefix, color in pairs(safePrefixes) do
            if name:sub(1, #prefix) == prefix then
                return color, prefix
            end
        end
        return nil, nil
    end

    local function scanSafes()
        local bred = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("BredMakurz")
        if not bred then
            return
        end
        for _, child in ipairs(bred:GetChildren()) do
            local color, prefix = getSafeColor(child.Name)
            if color and not ESP.Objects[child] then
                ESP:AddObject(child, { Name = prefix, Color = color })
            end
        end
    end

    local function hookSafeFolder()
        local bred = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("BredMakurz")
        if not bred then
            return
        end
        bred.ChildAdded:Connect(function(child)
            if not ESP_Safes.Enabled then
                return
            end
            local color, prefix = getSafeColor(child.Name)
            if color then
                task.wait()
                ESP:AddObject(child, { Name = prefix, Color = color })
            end
        end)
        bred.ChildRemoved:Connect(function(child)
            if ESP.Objects[child] then
                ESP.Objects[child]:Remove()
            end
        end)
    end

    local function enableSafeESP()
        ESP_Safes.Enabled = true
        scanSafes()
        hookSafeFolder()
    end

    local function disableSafeESP()
        ESP_Safes.Enabled = false
        local bred = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("BredMakurz")
        if not bred then
            return
        end
        for _, child in ipairs(bred:GetChildren()) do
            if ESP.Objects[child] then
                ESP.Objects[child]:Remove()
            end
        end
    end

    local ESP_Crates = { Enabled = false }

    local crateColors = {
        C = Color3.fromRGB(10, 80, 40), -- deep dark green
        S = Color3.fromRGB(130, 130, 130), -- gray
    }

    local function getCrateColor(name)
        local prefix = name:sub(1, 1):upper()
        return crateColors[prefix]
    end

    local crateFolders = { "C1", "S1", "S2" }

    local function scanCrates()
        local mapFolder = workspace:FindFirstChild("Map")
        if not mapFolder then
            return
        end
        for _, folderName in ipairs(crateFolders) do
            local folder = mapFolder:FindFirstChild(folderName)
            if folder then
                for _, child in ipairs(folder:GetChildren()) do
                    local color = getCrateColor(child.Name)
                    if color and not ESP.Objects[child] then
                        ESP:AddObject(child, {
                            Name = child.Name:sub(1, 1) == "C" and "Crate" or "Supply",
                            Color = color,
                        })
                    end
                end
            end
        end
    end

    local function hookCrateFolders()
        local mapFolder = workspace:FindFirstChild("Map")
        if not mapFolder then
            return
        end
        for _, folderName in ipairs(crateFolders) do
            local folder = mapFolder:FindFirstChild(folderName)
            if folder then
                folder.ChildAdded:Connect(function(child)
                    if not ESP_Crates.Enabled then
                        return
                    end
                    local color = getCrateColor(child.Name)
                    if color then
                        task.wait()
                        ESP:AddObject(child, {
                            Name = child.Name:sub(1, 1) == "C" and "Crate" or "Supply",
                            Color = color,
                        })
                    end
                end)
                folder.ChildRemoved:Connect(function(child)
                    if ESP.Objects[child] then
                        ESP.Objects[child]:Remove()
                    end
                end)
            end
        end
    end

    local function enableCrateESP()
        ESP_Crates.Enabled = true
        scanCrates()
        hookCrateFolders()
    end

    local function disableCrateESP()
        ESP_Crates.Enabled = false
        local mapFolder = workspace:FindFirstChild("Map")
        if not mapFolder then
            return
        end
        for _, folderName in ipairs(crateFolders) do
            local folder = mapFolder:FindFirstChild(folderName)
            if folder then
                for _, child in ipairs(folder:GetChildren()) do
                    if ESP.Objects[child] then
                        ESP.Objects[child]:Remove()
                    end
                end
            end
        end
    end

    local ESP_Items = { Enabled = false }

    local function scanDroppedItems()
        local filter = workspace:FindFirstChild("Filter")
        local spawned = filter and filter:FindFirstChild("SpawnedTools")
        if not spawned then
            return
        end
        for _, child in ipairs(spawned:GetChildren()) do
            if child:IsA("Model") and not ESP.Objects[child] then
                ESP:AddObject(
                    child,
                    { Name = "dropped item", Color = Color3.fromRGB(180, 180, 180) }
                )
            end
        end
    end

    local function hookDroppedItems()
        local filter = workspace:FindFirstChild("Filter")
        local spawned = filter and filter:FindFirstChild("SpawnedTools")
        if not spawned then
            return
        end
        spawned.ChildAdded:Connect(function(child)
            if not ESP_Items.Enabled then
                return
            end
            if child:IsA("Model") then
                task.wait()
                ESP:AddObject(
                    child,
                    { Name = "dropped item", Color = Color3.fromRGB(180, 180, 180) }
                )
            end
        end)
        spawned.ChildRemoved:Connect(function(child)
            if ESP.Objects[child] then
                ESP.Objects[child]:Remove()
            end
        end)
    end

    local function enableItemESP()
        ESP_Items.Enabled = true
        scanDroppedItems()
        hookDroppedItems()
    end

    local function disableItemESP()
        ESP_Items.Enabled = false
        local filter = workspace:FindFirstChild("Filter")
        local spawned = filter and filter:FindFirstChild("SpawnedTools")
        if not spawned then
            return
        end
        for _, child in ipairs(spawned:GetChildren()) do
            if ESP.Objects[child] then
                ESP.Objects[child]:Remove()
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        espCam = workspace.CurrentCamera
        if ESP.Enabled then
            for i, v in pairs(ESP.Objects) do
                if v.Update then
                    local s, e = pcall(v.Update, v)
                    if not s then
                        warn("[ESP]", e)
                    end
                end
            end
        end
    end)

    -- // WIRE ESP TOGGLES
    wireToggle(G2L["d1"], function()
        ESP.Enabled = true
    end, function()
        ESP.Enabled = false
        for i, v in pairs(ESP.Objects) do
            for _, c in pairs(v.Components) do
                c.Visible = false
            end
            -- Remove chams/highlights
            if v.Highlight then
                v.Highlight:Destroy()
                v.Highlight = nil
            end
        end
    end)

    wireToggle(G2L["b5"], function()
        ESP.Chams = true
    end, function()
        ESP.Chams = false
        for _, v in pairs(ESP.Objects) do
            if v.Highlight then
                v.Highlight:Destroy()
                v.Highlight = nil
            end
        end
    end)
    wireToggle(G2L["93"], function()
        ESP.Boxes = true
    end, function()
        ESP.Boxes = false
    end)
    wireToggle(G2L["a5"], function()
        ESP.Names = true
    end, function()
        ESP.Names = false
    end)
    wireToggle(G2L["b1"], function()
        ESP.Distance = true
    end, function()
        ESP.Distance = false
    end)
    -- was: wireToggle(G2L["b9"], function() ESP.Health = true end, function() ESP.Health = false end)
    wireToggle(G2L["b9"], function()
        ESP.Tracers = true
    end, function()
        ESP.Tracers = false
    end)
    wireToggle(G2L["a1"], function()
        ESP.HealthBar = true
        ESP.Health = true
    end, function()
        ESP.HealthBar = false
        ESP.Health = false
    end)
    wireToggle(G2L["dd"], function()
        ESP.ShowDead = true
    end, function()
        ESP.ShowDead = false
    end)
    wireToggle(G2L["ad"], function()
        ESP.Tool = true
    end, function()
        ESP.Tool = false
    end)
    -- was: wireToggle(G2L["152"], function() ESP.Tracers = true end, function() ESP.Tracers = false end)
    wireToggle(G2L["fc"], function()
        radarSystem.ShowDealers = true
    end, function()
        radarSystem.ShowDealers = false
    end)
    wireToggle(G2L["100"], function()
        radarSystem.ShowLoot = true
    end, function()
        radarSystem.ShowLoot = false
    end)
    local mouseTracerLine = Drawing.new("Line")
    mouseTracerLine.Thickness = 1.5
    mouseTracerLine.Color = Color3.fromRGB(255, 255, 255)
    mouseTracerLine.Transparency = 1
    mouseTracerLine.Visible = false

    local mouseTracerEnabled = false

    RunService.RenderStepped:Connect(function()
        if not mouseTracerEnabled or not SilentAim.Enabled then
            mouseTracerLine.Visible = false
            return
        end

        local target = getClosestPlayerToMouse()
        if not target then
            mouseTracerLine.Visible = false
            return
        end

        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(target.Position)
        if not onScreen or screenPos.Z <= 0 then
            mouseTracerLine.Visible = false
            return
        end

        mouseTracerLine.Visible = true
        mouseTracerLine.From = UserInputService:GetMouseLocation()
        mouseTracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
        --mouseTracerLine.Color = drawnColorPicker and drawnColorPicker.value or Color3.fromRGB(255, 255, 255)
    end)

    wireToggle(G2L["152"], function()
        mouseTracerEnabled = true
    end, function()
        mouseTracerEnabled = false
        mouseTracerLine.Visible = false
    end)
    wireToggle(G2L["97"], function()
        ESP.Skeleton = true
    end, function()
        ESP.Skeleton = false
    end)
    wireToggle(G2L["bd"], function()
        ESP.OffscreenArrow = true
    end, function()
        ESP.OffscreenArrow = false
    end)
    -- // SELECTION PANEL (Visuals tab)
    local selectionButtons = {
        G2L["e4"], -- player
        G2L["e6"], -- dealer
        G2L["e7"], -- droppeditems
        G2L["e8"], -- crates
        G2L["e9"], -- safes
    }
    local optionLabel = G2L["9c"]
    local currentSelection = "player"

    local activeSelColor = Color3.fromRGB(255, 255, 255)
    local inactiveSelColor = Color3.fromRGB(176, 176, 176)

    local function updateSelectionLabel(name)
        optionLabel.Text = "  option (" .. name .. ")"
    end

    local function switchSelection(btn, name)
        for _, b in ipairs(selectionButtons) do
            b.TextColor3 = inactiveSelColor
        end
        btn.TextColor3 = activeSelColor
        currentSelection = name
        updateSelectionLabel(name)
    end

    -- Default: player selected
    switchSelection(G2L["e4"], "player")

    -- Replace your existing G2L["e6"]-G2L["e9"] click handlers with:
    local function makeObjToggle(btn, name, enableFn, disableFn)
        local active = false
        btn.MouseButton1Click:Connect(function()
            active = not active
            btn.TextColor3 = active and activeSelColor or inactiveSelColor
            updateSelectionLabel(name .. (active and " [on]" or ""))
            if active then
                enableFn()
            else
                disableFn()
            end
        end)
    end

    makeObjToggle(G2L["e6"], "dealer", enableDealerESP, disableDealerESP)
    makeObjToggle(G2L["e7"], "dropped items", enableItemESP, disableItemESP)
    makeObjToggle(G2L["e8"], "crates", enableCrateESP, disableCrateESP)
    makeObjToggle(G2L["e9"], "safes", enableSafeESP, disableSafeESP)

    G2L["e4"].MouseButton1Click:Connect(function()
        switchSelection(G2L["e4"], "player")
    end)

    -- // WHITELIST PANEL (Misc tab)
    local whitelistSF = G2L["24"] -- the scrolling frame
    local whitelistTemplate = G2L["25"] -- template button (player)
    whitelistTemplate.Visible = false -- hide template

    local whitelistEntries = {} -- [userId] = TextButton

    -- shared whitelist store used by ESP and UI
    whitelist = {} -- [userId] = true/false

    local whitelistedColor = Color3.fromRGB(255, 255, 255)
    local unwhitelistedColor = Color3.fromRGB(176, 176, 176)

    -- Move Speed slider (1–10, default 2)
    local fakeSpeedTrack = G2L["58"]:FindFirstChild("slider")
    local fakeSpeedNumBox = G2L["58"]:FindFirstChild("number")
    fakeSpeedNumBox.Text = "2.0"
    fakeSpeedMultiplier = 2.0

    fakeSpeedTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingFakeSpeed = true
        end
    end)
    fakeSpeedTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingFakeSpeed = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingFakeSpeed and input.UserInputType == Enum.UserInputType.MouseMovement then
            local ratio = math.clamp(
                (input.Position.X - fakeSpeedTrack.AbsolutePosition.X)
                    / fakeSpeedTrack.AbsoluteSize.X,
                0,
                1
            )
            local v = math.floor((1 + (10 - 1) * ratio) * 10 + 0.5) / 10 -- 1.0 to 10.0, step 0.1
            fakeSpeedMultiplier = v
            fakeSpeedNumBox.Text = string.format("%.1f", v)
        end
    end)
    fakeSpeedNumBox.FocusLost:Connect(function()
        local v = tonumber(fakeSpeedNumBox.Text)
        if v then
            fakeSpeedMultiplier = math.clamp(v, 1, 10)
            fakeSpeedNumBox.Text = string.format("%.1f", fakeSpeedMultiplier)
        end
    end)

    -- Flight Speed slider (10–200, default 50)
    wireSlider(G2L["5d"], 10, 200, 50, function(v)
        flightSpeed = v
    end)

    -- Spin Speed slider (1–100, default 10)
    wireSlider(G2L["62"], 1, 100, 10, function(v)
        spinSpeed = v
    end)

    local startingfov = Camera.FieldOfView

    -- FOV Amount slider (10–120, default 90)
    wireSlider(G2L["84"], 10, 120, startingfov, function(v)
        workspace.CurrentCamera.FieldOfView = v
    end)

    -- Zoom Amount slider (10–120, default 60)
    wireSlider(G2L["8d"], 10, 120, 60, function(v)
        -- store zoom FOV for use with zoom key
    end)

    -- ESP Max Distance slider (0–2000, default 2000)
    wireSlider(G2L["cc"], 0, 5000, 2500, function(v)
        ESP.DistanceS = v
    end)

    -- Aimbot Max Distance slider
    wireSlider(G2L["13c"], 0, 2500, 500, function(v)
        -- store for aimbot distance check
    end)

    -- FOV radius slider (G2L["145"])
    wireSlider(G2L["145"], 0, 1440, 360, function(v)
        SilentAim.FOVRadius = v
        silentFOVCircle.Radius = v
    end)
    do
        local recoilTrack = G2L["11f"]:FindFirstChild("slider")
        local recoilNumBox = G2L["11f"]:FindFirstChild("number")
        local recoilValue = 1.0
        recoilNumBox.Text = "1.00"

        recoilTrack.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingRecoil = true
            end
        end)
        recoilTrack.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingRecoil = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingRecoil and input.UserInputType == Enum.UserInputType.MouseMovement then
                local ratio = math.clamp(
                    (input.Position.X - recoilTrack.AbsolutePosition.X) / recoilTrack.AbsoluteSize.X,
                    0,
                    1
                )
                recoilValue = math.floor(ratio * 500 + 0.5) / 100 -- 0.00 to 5.00
                recoilNumBox.Text = string.format("%.2f", recoilValue)
            end
        end)
        recoilNumBox.FocusLost:Connect(function()
            local v = tonumber(recoilNumBox.Text)
            if v then
                recoilValue = math.clamp(v, 0, 5)
                recoilNumBox.Text = string.format("%.2f", recoilValue)
            end
        end)
    end

    -- Bullet Speed slider
    wireSlider(G2L["124"], 0, 500, 0, function(v)
        -- store bullet speed
    end)

    do
        -- Smooth slider (0–100, default 0)
        local smoothTrack = G2L["16d"]:FindFirstChild("slider")
        local smoothNumBox = G2L["16d"]:FindFirstChild("number")
        local smoothValue = 0.00
        smoothNumBox.Text = "0.00"

        local smoothFill = smoothTrack:FindFirstChild("fill")
        if not smoothFill then
            smoothFill = Instance.new("Frame", smoothTrack)
            smoothFill.Name = "fill"
            smoothFill.BorderSizePixel = 0
            smoothFill.BackgroundColor3 = Color3.fromRGB(34, 103, 89)
            smoothFill.Size = UDim2.new(0, 0, 1, 0)
        end

        local function updateSmooth(v)
            smoothValue = math.clamp(math.floor(v * 100 + 0.5) / 100, 0, 1)
            smoothNumBox.Text = string.format("%.2f", smoothValue)
            smoothFill.Size = UDim2.new(smoothValue, 0, 1, 0)
            -- use smoothValue wherever needed
        end

        smoothTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSmooth = true
            end
        end)
        smoothTrack.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSmooth = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSmooth and input.UserInputType == Enum.UserInputType.MouseMovement then
                local ratio = math.clamp(
                    (input.Position.X - smoothTrack.AbsolutePosition.X) / smoothTrack.AbsoluteSize.X,
                    0,
                    1
                )
                updateSmooth(ratio)
            end
        end)
        smoothNumBox.FocusLost:Connect(function()
            local v = tonumber(smoothNumBox.Text)
            if v then
                updateSmooth(v)
            end
        end)

        updateSmooth(0)
    end
    -- Wire radar toggle from visuals tab
    wireToggle(G2L["ef"], startRadar, stopRadar)

    -- Wire radar range slider
    wireSlider(G2L["f3"], 50, 1000, 200, function(v)
        radarSystem.Range = v
    end)
    wireToggle(G2L["d5"], function()
        ESP.ShowFriendly = true
    end, function()
        ESP.ShowFriendly = false
    end)
    -- Wire radar player toggles
    wireToggle(G2L["f8"], function()
        radarSystem.ShowPlayers = true
    end, function()
        radarSystem.ShowPlayers = false
    end)

    wireToggle(G2L["100"], function()
        radarSystem.ShowLoot = true
    end, function()
        radarSystem.ShowLoot = false
    end)

    -- Wire all color pickers
    local boxSkelPicker = createColorPicker(
        G2L["9f"],
        Color3.fromRGB(199, 255, 255),
        function(color)
            ESP.Color = color
        end
    )

    local textColorPicker = createColorPicker(
        G2L["ab"],
        Color3.fromRGB(255, 255, 255),
        function(color)
            ESP.TextColor = color
        end
    )

    local offscreenColorPicker = createColorPicker(
        G2L["c3"],
        Color3.fromRGB(199, 255, 255),
        function(color)
            ESP.OffscreenColor = color
        end
    )

    local chamsColorPicker = createColorPicker(
        G2L["c7"],
        Color3.fromRGB(199, 255, 255),
        function(color)
            ESP.ChamsColor = color
            for _, v in pairs(ESP.Objects) do
                if v.Highlight then
                    v.Highlight.FillColor = color
                end
            end
        end
    )

    local drawnColorPicker = createColorPicker(
        G2L["158"],
        Color3.fromRGB(255, 255, 255),
        function(color)
            silentFOVCircle.Color = color
            mouseTracerLine.Color = color
        end
    )

    local function createWhitelistEntry(player)
        local uid = player.UserId
        if whitelistEntries[uid] then
            return
        end

        local btn = whitelistTemplate:Clone()
        btn.Name = tostring(uid)
        btn.Text = "   " .. player.DisplayName .. " (@" .. player.Name .. ")"
        btn.TextColor3 = unwhitelistedColor
        btn.Visible = true
        btn.Parent = whitelistSF

        whitelist[uid] = not whitelist[uid]

        btn.MouseButton1Click:Connect(function()
            whitelist[uid] = not whitelist[uid]
            btn.TextColor3 = whitelist[uid] and whitelistedColor or unwhitelistedColor
        end)

        whitelistEntries[uid] = btn

        -- Resize scrolling frame canvas
        local count = 0
        for _ in pairs(whitelistEntries) do
            count += 1
        end
        whitelistSF.CanvasSize = UDim2.new(0, 0, 0, count * 20)
    end

    local function removeWhitelistEntry(player)
        local uid = player.UserId
        if whitelistEntries[uid] then
            whitelistEntries[uid]:Destroy()
            whitelistEntries[uid] = nil
            whitelist[uid] = nil
            local count = 0
            for _ in pairs(whitelistEntries) do
                count += 1
            end
            whitelistSF.CanvasSize = UDim2.new(0, 0, 0, count * 20)
        end
    end

    -- Populate existing players
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then
            createWhitelistEntry(p)
        end
    end

    Players.PlayerAdded:Connect(function(p)
        if p ~= Players.LocalPlayer then
            createWhitelistEntry(p)
        end
    end)

    Players.PlayerRemoving:Connect(removeWhitelistEntry)

    -- // KEYBIND SYSTEM
    local Keybinds = {}
    local currentlyBinding = nil
    local justOpenedBind = false -- prevents the right-click that opens binding from immediately registering

    local function inputToString(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            return "mouse 2"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            return "mouse 3"
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            return input.KeyCode.Name:lower()
        end
        return nil
    end

    local function flashRed(label)
        label.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        label.BackgroundTransparency = 0
        task.delay(0.35, function()
            if currentlyBinding and currentlyBinding.label == label then
                label.BackgroundColor3 = Color3.fromRGB(34, 85, 114)
                label.BackgroundTransparency = 0
            end
        end)
    end

    local function registerKeybind(label, isMenuKey, onBind)
        local data = {
            label = label,
            isMenuKey = isMenuKey,
            onBind = onBind,
            bound = nil,
            mode = "toggle",
        }
        table.insert(Keybinds, data)

        label.InputBegan:Connect(function(input)
            -- LEFT CLICK: open bind listener
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if currentlyBinding then
                    currentlyBinding.label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    currentlyBinding.label.BackgroundTransparency = 0.65
                    currentlyBinding.label.Text = currentlyBinding.bound or "nil"
                end
                currentlyBinding = data
                justOpenedBind = true
                label.Text = "..."
                label.BackgroundColor3 = Color3.fromRGB(34, 85, 114)
                label.BackgroundTransparency = 0

            -- RIGHT CLICK: open toggle/hold dropdown (not for menu key)
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not isMenuKey then
                -- Close bind listener if open
                if currentlyBinding == data then
                    currentlyBinding = nil
                    label.Text = data.bound or "nil"
                    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    label.BackgroundTransparency = 0.65
                end

                -- Order options so current mode is on top
                local options = data.mode == "hold" and { "hold", "toggle" } or { "toggle", "hold" }

                createDropdown(label, options, data.mode, function(val)
                    data.mode = val
                    -- label text stays as the keybind name, unchanged
                end)
            end
        end)

        return data
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not currentlyBinding then
            return
        end

        -- Eat the mouse 2 InputEnded that fires right after opening
        if justOpenedBind then
            justOpenedBind = false
        end

        local data = currentlyBinding

        -- Left click: not allowed as a bind
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            flashRed(data.label)
            return
        end

        -- Backspace: clear (but not for menu key)
        if input.KeyCode == Enum.KeyCode.Backspace then
            if data.isMenuKey then
                flashRed(data.label)
            else
                data.bound = nil
                data.label.Text = "nil"
                data.label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                data.label.BackgroundTransparency = 0.65
                currentlyBinding = nil
                if data.onBind then
                    data.onBind(nil)
                end
            end
            return
        end

        -- Menu key: keyboard only
        if data.isMenuKey and input.UserInputType ~= Enum.UserInputType.Keyboard then
            flashRed(data.label)
            return
        end

        local str = inputToString(input)
        if not str then
            return
        end

        data.bound = str
        data.label.Text = str
        data.label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        data.label.BackgroundTransparency = 0.65
        currentlyBinding = nil

        if data.onBind then
            data.onBind(str)
        end
    end)

    local function inputMatchesBind(input, boundStr)
        if not boundStr then
            return false
        end
        return inputToString(input) == boundStr
    end

    local Binds = {}
    Binds.aimbot = registerKeybind(G2L["15f"], false, function(str) end)
    Binds.silent = registerKeybind(G2L["16b"], false, function(str) end)
    Binds.ragebot = registerKeybind(G2L["10b"], false, function(str) end)
    Binds.manip = registerKeybind(G2L["112"], false, function(str) end)
    Binds.fullbright = registerKeybind(G2L["2f"], false, function(str) end)
    Binds.freecam = registerKeybind(G2L["35"], false, function(str) end)
    Binds.bhop = registerKeybind(G2L["3e"], false, function(str) end)
    Binds.speed = registerKeybind(G2L["44"], false, function(str) end)
    Binds.flight = registerKeybind(G2L["4a"], false, function(str) end)
    Binds.noclip = registerKeybind(G2L["50"], false, function(str) end)
    Binds.spin = registerKeybind(G2L["56"], false, function(str) end)
    Binds.killaura = registerKeybind(G2L["17f"], false, function(str) end)
    Binds.stomp = registerKeybind(G2L["185"], false, function(str) end)
    Binds.hitbox = registerKeybind(G2L["179"], false, function(str) end)
    Binds.zoom = registerKeybind(G2L["8a"], false, function(str) end)

    -- // REGISTER ALL KEYBINDS

    Binds.menuKey = registerKeybind(G2L["6c"], true, function(str) end)
    Binds.menuKey.bound = "rightalt"
    G2L["6c"].Text = "rightalt"

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or currentlyBinding then
            return
        end
        if Binds.menuKey.bound and input.UserInputType == Enum.UserInputType.Keyboard then
            if inputToString(input) == Binds.menuKey.bound then
                menuOpen = not menuOpen
                G2L["2"].Visible = menuOpen
            end
        end
    end)

    local Dragging = {
        smooth = false,
        recoil = false,
        fakeSpeed = false,
    }

    -- // TOGGLE STATE TRACKING
    -- Each entry tracks its own enabled state and the on/off functions to call
    local hotkeyToggles = {
        {
            bind = Binds.fullbright,
            state = false,
            onEnable = enableFullbright,
            onDisable = disableFullbright,
            row = G2L["2b"],
        },
        {
            bind = Binds.freecam,
            state = false,
            onEnable = startFreecam,
            onDisable = stopFreecam,
            row = G2L["31"],
        },
        {
            bind = Binds.bhop,
            state = false,
            onEnable = startBhop,
            onDisable = stopBhop,
            row = G2L["3a"],
        },
        {
            bind = Binds.speed,
            state = false,
            onEnable = startFakeSpeed,
            onDisable = stopFakeSpeed,
            row = G2L["40"],
        },
        {
            bind = Binds.flight,
            state = false,
            onEnable = startFlight,
            onDisable = stopFlight,
            row = G2L["46"],
        },
        {
            bind = Binds.noclip,
            state = false,
            onEnable = startNoclip,
            onDisable = stopNoclip,
            row = G2L["4c"],
        },
        {
            bind = Binds.spin,
            state = false,
            onEnable = startSpin,
            onDisable = stopSpin,
            row = G2L["52"],
        },
    }

    -- Sync the toggle button visual to match state
    local function syncToggleVisual(row, state)
        local btn = row and row:FindFirstChild("button")
        if not btn then
            return
        end
        local stroke = btn:FindFirstChildWhichIsA("UIStroke")
        local onColor = stroke and stroke.Color or Color3.fromRGB(34, 103, 89)
        btn.BackgroundColor3 = state and onColor or Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = state and 0 or 0.85
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or currentlyBinding then
            return
        end

        local str = inputToString(input)
        if not str then
            return
        end

        for _, entry in ipairs(hotkeyToggles) do
            if entry.bind.bound == str then
                if entry.bind.mode == "hold" then
                    -- hold: enable on press
                    entry.state = true
                    syncToggleVisual(entry.row, true)
                    entry.onEnable()
                else
                    entry.state = not entry.state
                    syncToggleVisual(entry.row, entry.state)
                    if entry.state then
                        entry.onEnable()
                    else
                        entry.onDisable()
                    end
                end
            end
        end

        -- Zoom: hold style
        if Binds.zoom.bound == str then
            originalFOV = workspace.CurrentCamera.FieldOfView
            workspace.CurrentCamera.FieldOfView = tonumber(G2L["91"].Text) or 60
            zoomActive = true
        end
    end)

    local zoomActive = false
    local originalFOV = 90

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or currentlyBinding then
            return
        end
        if not Binds.zoom.bound then
            return
        end
        if inputToString(input) ~= Binds.zoom.bound then
            return
        end
        if zoomActive then
            return
        end

        zoomActive = true
        originalFOV = workspace.CurrentCamera.FieldOfView
        workspace.CurrentCamera.FieldOfView = tonumber(G2L["91"].Text) or 60
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not zoomActive then
            return
        end
        if not Binds.zoom.bound then
            return
        end

        local str
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            str = "mouse 2"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            str = "mouse 3"
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            str = input.KeyCode.Name:lower()
        end

        if str == Binds.zoom.bound then
            workspace.CurrentCamera.FieldOfView = originalFOV
            zoomActive = false
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        local str = inputToString(input)
        if not str then
            return
        end
        for _, entry in ipairs(hotkeyToggles) do
            if entry.bind.bound == str and entry.bind.mode == "hold" and entry.state then
                entry.state = false
                syncToggleVisual(entry.row, false)
                entry.onDisable()
            end
        end
    end)
end
main()
