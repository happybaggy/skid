if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local CLICK_OFFSET_Y = 50

if _G.farmLoopRunning then return end
_G.farmLoopRunning = true

local queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

Players.LocalPlayer.OnTeleport:Connect(function(State)
    if queueteleport then
        queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/happybaggy/skid/main/havocfarm.lua'))()")
    end
end)

local function clickObject(obj)
	if not obj or not obj:IsA("GuiObject") then return end
	if obj:IsA("GuiButton") then
		pcall(function()
			obj.Active = true
			obj.Visible = true
		end)
	end
	local x = obj.AbsolutePosition.X + obj.AbsoluteSize.X / 2
	local y = obj.AbsolutePosition.Y + obj.AbsoluteSize.Y / 2 + CLICK_OFFSET_Y
	pcall(function()
		VirtualInputManager:SendMouseMoveEvent(x, y, game, 0)
		task.wait(0.05)
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
		task.wait(0.05)
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
	end)
	if obj:IsA("GuiButton") then
		pcall(function()
			if obj.MouseButton1Click then obj.MouseButton1Click:Fire() end
			if obj.MouseButton1Down then obj.MouseButton1Down:Fire() task.wait(0.02) end
			if obj.MouseButton1Up then obj.MouseButton1Up:Fire() end
			if obj.Activated then obj.Activated:Fire() end
		end)
	end
	pcall(function()
		local touchBegin = { Position = Vector2.new(x, y), UserInputState = Enum.UserInputState.Begin, Touch = true }
		UserInputService:FireInputEvent(touchBegin)
		task.wait(0.05)
		local touchEnd = { Position = Vector2.new(x, y), UserInputState = Enum.UserInputState.End, Touch = true }
		UserInputService:FireInputEvent(touchEnd)
	end)
end

local function clickCenter()
	local viewport = Workspace.CurrentCamera.ViewportSize
	local x = viewport.X / 2
	local y = viewport.Y / 2
	pcall(function()
		VirtualInputManager:SendMouseMoveEvent(x, y, game, 0)
		task.wait(0.05)
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
		task.wait(0.05)
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
	end)
	pcall(function()
		local touchBegin = { Position = Vector2.new(x, y), UserInputState = Enum.UserInputState.Begin, Touch = true }
		UserInputService:FireInputEvent(touchBegin)
		task.wait(0.05)
		local touchEnd = { Position = Vector2.new(x, y), UserInputState = Enum.UserInputState.End, Touch = true }
		UserInputService:FireInputEvent(touchEnd)
	end)
end

local function sellAll()
	local ui = PlayerGui:FindFirstChild("UI")
	if not ui then return end
	local inventoryCategory = ui:FindFirstChild("inventoryCategory")
	if inventoryCategory then
		local overall = inventoryCategory:FindFirstChild("overall")
		if overall then
			clickObject(overall)
			task.wait(0.25)
		end
	end
	local hud = ui:FindFirstChild("HUD")
	if not hud then return end
	local backpack = hud:FindFirstChild("backpackFrame")
	if not backpack then return end
	local trader = backpack:FindFirstChild("traderCenterFrame") or backpack:FindFirstChild("trader")
	if not trader then return end
	local tradesellswitch = trader:FindFirstChild("traderSellButton")
	local realsellbutton = trader:FindFirstChild("dealButtonFrame") and trader.dealButtonFrame:FindFirstChild("dealButton")
	if not tradesellswitch or not realsellbutton then return end
	task.wait(0.25)
	clickObject(tradesellswitch)
	local playerContainer = backpack:FindFirstChild("player")
	if not playerContainer then return end
	local pocket = nil
	for _, child in ipairs(playerContainer:GetChildren()) do
		if child:IsA("Frame") and child.Name == "inventoryFrame" and child:GetAttribute("childrens") == 8 then
			pocket = child
			break
		end
	end
	if not pocket then return end
	local itemsContainer = pocket:FindFirstChild("items") or pocket
	for _, itemFrame in ipairs(itemsContainer:GetChildren()) do
		if itemFrame:IsA("Frame") then
			local button = itemFrame:FindFirstChild("button")
			if button then
				clickObject(button)
				task.wait(0.05)
			end
		end
	end
	local status = backpack:FindFirstChild("status")
	if status then
		local overall = status:FindFirstChild("overallFrame")
		if overall then
			local equipSlots = overall:FindFirstChild("equipment") and overall.equipment:FindFirstChild("slots")
			if equipSlots then
				for _, slot in ipairs(equipSlots:GetChildren()) do
					if slot:IsA("Frame") and slot:FindFirstChildOfClass("ObjectValue") then
						local button = slot:FindFirstChild("button")
						if button then clickObject(button) else clickObject(slot) end
						task.wait(0.05)
					end
				end
			end
			local weaponSlots = overall:FindFirstChild("weapons") and overall.weapons:FindFirstChild("slots")
			if weaponSlots then
				for _, slot in ipairs(weaponSlots:GetChildren()) do
					if slot:IsA("Frame") and slot:FindFirstChildOfClass("ObjectValue") then
						local button = slot:FindFirstChild("button")
						if button then clickObject(button) else clickObject(slot) end
						task.wait(0.05)
					end
				end
			end
		end
	end
	clickObject(realsellbutton)
	task.wait(0.5)
end

local function checkPrompt()
	local ui = PlayerGui:FindFirstChild("UI")
	if not ui then return false end
	local prompt = ui:FindFirstChild("__prompt")
	if not prompt then return false end
	local promptButtons = prompt:FindFirstChild("promptButtons")
	if not promptButtons then return false end
	local promptButton1 = promptButtons:FindFirstChild("promptButton1")
	if promptButton1 and promptButton1.Visible then
		clickObject(promptButton1)
		task.wait(0.5)
		return true
	end
	return false
end

local function waitForMainMenu()
	while true do
		clickCenter()
		task.wait(0.1)
		local lobbyBottom = PlayerGui:FindFirstChild("UI") and PlayerGui.UI:FindFirstChild("mainMenuFrame") and PlayerGui.UI.mainMenuFrame:FindFirstChild("lobbyBottom")
		if lobbyBottom and lobbyBottom.Visible then
			return lobbyBottom
		end
	end
end

while true do
	local lobbyBottom = waitForMainMenu()
	for _ = 1, 5 do
		if checkPrompt() then break end
		task.wait(0.1)
	end
	local traders = lobbyBottom:FindFirstChild("main") and lobbyBottom.main:FindFirstChild("traders")
	if traders then
		clickObject(traders)
		task.wait(0.5)
	end
	local traderList = PlayerGui:FindFirstChild("UI") and PlayerGui.UI:FindFirstChild("HUD") and PlayerGui.UI.HUD:FindFirstChild("traderListFrame")
	if traderList then
		local contents = traderList:FindFirstChild("contents")
		if contents then
			local dragov = contents:FindFirstChild("Dragov") or contents:FindFirstChildWhichIsA("TextButton")
			if dragov then
				clickObject(dragov)
				task.wait(0.5)
			end
		end
	end
	local dialogueFrame = PlayerGui:FindFirstChild("UI") and PlayerGui.UI:FindFirstChild("temp") and PlayerGui.UI.temp:FindFirstChild("dialogueFrame")
	while dialogueFrame do
		clickCenter()
		task.wait(0.1)
		local choice1 = dialogueFrame:FindFirstChild("main") and dialogueFrame.main:FindFirstChild("dialogueChoices") and dialogueFrame.main.dialogueChoices:FindFirstChild("1")
		if choice1 then
			clickObject(choice1)
			task.wait(0.1)
		end
		dialogueFrame = PlayerGui:FindFirstChild("UI") and PlayerGui.UI:FindFirstChild("temp") and PlayerGui.UI.temp:FindFirstChild("dialogueFrame")
	end
	sellAll()

	TeleportService:Teleport(game.PlaceId)
	task.wait(5)
end