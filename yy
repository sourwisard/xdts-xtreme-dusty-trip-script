--// Services
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local PlayerGui = game:GetService("CoreGui") or plr.PlayerGui
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Character = plr.Character or plr.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ValidObjectsUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

--// Outer Frame
local outerFrame = Instance.new("Frame")
outerFrame.Size = UDim2.fromScale(0.6, 0.7)
outerFrame.Position = UDim2.fromScale(0.2, 0.15)
outerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
outerFrame.BorderSizePixel = 0
outerFrame.Parent = screenGui
Instance.new("UICorner", outerFrame).CornerRadius = UDim.new(0.03, 0)
outerFrame.Visible = true
--// Helper function to hide all tabs
local function hideAllTabs()
	for _, frame in ipairs(outerFrame:GetChildren()) do
		if frame:IsA("Frame") and frame.Name:find("TabFrame") then
			frame.Visible = false
		end
	end
end

--// Create Tab Frame helper
local function createTabFrame(name)
	local frame = Instance.new("Frame")
	frame.Name = name .. "TabFrame"
	frame.Size = UDim2.fromScale(0.8, 0.9)
	frame.Position = UDim2.fromScale(0.2, 0.1)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = outerFrame
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0.02, 0)
	return frame
end

--// Tabs
local mainTab = createTabFrame("Main")
local itemsTab = createTabFrame("Items")
local playerTab = createTabFrame("Players")
local placeholder1 = createTabFrame("Placeholder1")
local placeholder2 = createTabFrame("Placeholder2")
local placeholder3 = createTabFrame("Placeholder3")
mainTab.Visible = true

--// Tab Buttons
local tabs = {
	{ name = "Main", target = mainTab },
	{ name = "Items", target = itemsTab },
	{ name = "Players", target = playerTab },
	{ name = "get model name", target = placeholder1 },
	{ name = "Placeholder2", target = placeholder2 },
	{ name = "Placeholder3", target = placeholder3 },
}

for i, info in ipairs(tabs) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromScale(0.1, 0.1)
	button.Position = UDim2.fromScale(0, (i - 1) * 0.11)
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	button.Text = info.name
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Parent = outerFrame
	Instance.new("UICorner", button).CornerRadius = UDim.new(0.02, 0)

	button.Activated:Connect(function()
		hideAllTabs()
		info.target.Visible = true
	end)
end

--// ITEMS TAB: scrolling frame (works now)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.fromScale(0.3, 0.96)
scrollFrame.Position = UDim2.fromScale(0.7, 0.02)
scrollFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 10
scrollFrame.Parent = itemsTab
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0.02, 0)

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Padding = UDim.new(0, 6)
scrollLayout.Parent = scrollFrame
scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
end)

local selectedItemLabel = Instance.new("TextLabel")
selectedItemLabel.Size = UDim2.fromScale(0.35, 0.1)
selectedItemLabel.Position = UDim2.fromScale(0.05, 0.85)
selectedItemLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
selectedItemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedItemLabel.TextScaled = true
selectedItemLabel.Text = "Selected: None"
selectedItemLabel.Parent = itemsTab
Instance.new("UICorner", selectedItemLabel).CornerRadius = UDim.new(0.02, 0)

--// Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromScale(0.1, 0.1)
closeButton.Position = UDim2.fromScale(0.9, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Parent = outerFrame
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0.03, 0)
closeButton.Activated:Connect(function()
	screenGui:Destroy()
end)

----------------------------------------------------------------------------------- Visibility toggle button
local visibilityButton = Instance.new("TextButton")
visibilityButton.Size = UDim2.fromScale(0.05, 0.1)
visibilityButton.Position = UDim2.fromScale(.4, 0) -- top-left corner
visibilityButton.Text = "Hide Frame"
visibilityButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
visibilityButton.TextColor3 = Color3.fromRGB(255, 255, 255)
visibilityButton.TextScaled = true
visibilityButton.Parent = screenGui
Instance.new("UICorner", visibilityButton).CornerRadius = UDim.new(0.03, 0)
visibilityButton.Visible = true
visibilityButton.ZIndex = 999
visibilityButton.Activated:Connect(function()
	outerFrame.Visible = not outerFrame.Visible
	visibilityButton.Text = outerFrame.Visible and "Hide Frame" or "Show Frame"
end)

local dragging = false
local dragStartPos
local startPos

visibilityButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStartPos = input.Position
		startPos = visibilityButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

visibilityButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragging then
			local delta = input.Position - dragStartPos
			visibilityButton.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end
end)

------------------------------------------------------------------------------------end of visibility toggle button

------------------------------------------------------------------------------------item tab buttons
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.fromScale(0.1, 0.1)
toggleButton.Position = UDim2.fromScale(.05, 0.1)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Text = "tp spheres"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Parent = itemsTab
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0.02, 0)

local offsetspheres = Instance.new("TextBox")
offsetspheres.Size = UDim2.fromScale(0.1, 0.1)
offsetspheres.Position = UDim2.fromScale(.25, 0.1)
offsetspheres.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
offsetspheres.Text = "2"
offsetspheres.TextColor3 = Color3.fromRGB(255, 255, 255)
offsetspheres.TextScaled = true
offsetspheres.Parent = itemsTab
offsetspheres.ClearTextOnFocus = false
Instance.new("UICorner", offsetspheres).CornerRadius = UDim.new(0.02, 0)

local offsetlabel = Instance.new("TextLabel")
offsetlabel.Size = UDim2.fromScale(0.1, 0.1)
offsetlabel.Position = UDim2.fromScale(.15, 0.1)
offsetlabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
offsetlabel.Text = " y offset ="
offsetlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
offsetlabel.TextScaled = true
offsetlabel.Parent = itemsTab
Instance.new("UICorner", offsetlabel).CornerRadius = UDim.new(0.02, 0)

local bringall = Instance.new("TextButton")
bringall.Size = UDim2.fromScale(0.1, 0.1)
bringall.Position = UDim2.fromScale(.05, 0.21)
bringall.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bringall.Text = "bringall"
bringall.TextColor3 = Color3.fromRGB(255, 255, 255)
bringall.TextScaled = true
bringall.Parent = itemsTab
Instance.new("UICorner", bringall).CornerRadius = UDim.new(0.02, 0)

local bringwithloop = Instance.new("TextButton")
bringwithloop.Size = UDim2.fromScale(0.1, 0.1)
bringwithloop.Position = UDim2.fromScale(.16, 0.21)
bringwithloop.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bringwithloop.Text = "bringwithloop"
bringwithloop.TextColor3 = Color3.fromRGB(255, 255, 255)
bringwithloop.TextScaled = true
bringwithloop.Parent = itemsTab
Instance.new("UICorner", bringwithloop).CornerRadius = UDim.new(0.02, 0)

local bringalltosphere = Instance.new("TextButton")
bringalltosphere.Size = UDim2.fromScale(0.1, 0.1)
bringalltosphere.Position = UDim2.fromScale(.05, 0.32)
bringalltosphere.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bringalltosphere.Text = "bringalltosphere"
bringalltosphere.TextColor3 = Color3.fromRGB(255, 255, 255)
bringalltosphere.TextScaled = true
bringalltosphere.Parent = itemsTab
Instance.new("UICorner", bringalltosphere).CornerRadius = UDim.new(0.02, 0)

local bringallof1 = Instance.new("TextButton")
bringallof1.Size = UDim2.fromScale(0.1, 0.1)
bringallof1.Position = UDim2.fromScale(.05, 0.43)
bringallof1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bringallof1.Text = "bringallof1"
bringallof1.TextColor3 = Color3.fromRGB(255, 255, 255)
bringallof1.TextScaled = true
bringallof1.Parent = itemsTab
Instance.new("UICorner", bringallof1).CornerRadius = UDim.new(0.02, 0)

local bringallselectedtosphere = Instance.new("TextButton")
bringallselectedtosphere.Size = UDim2.fromScale(0.1, 0.1)
bringallselectedtosphere.Position = UDim2.fromScale(.05, 0.54)
bringallselectedtosphere.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bringallselectedtosphere.Text = "tp selected to sphere"
bringallselectedtosphere.TextColor3 = Color3.fromRGB(255, 255, 255)
bringallselectedtosphere.TextScaled = true
bringallselectedtosphere.Parent = itemsTab
Instance.new("UICorner", bringallselectedtosphere).CornerRadius = UDim.new(0.02, 0)

local togglemobileb = Instance.new("TextButton")
togglemobileb.Size = UDim2.fromScale(0.1, 0.1)
togglemobileb.Position = UDim2.fromScale(.05, 0.65)
togglemobileb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
togglemobileb.Text = "lock spheres"
togglemobileb.TextColor3 = Color3.fromRGB(255, 255, 255)
togglemobileb.TextScaled = true
togglemobileb.Parent = itemsTab
Instance.new("UICorner", togglemobileb).CornerRadius = UDim.new(0.02, 0)


-----------------------------------------------------------------------------------end of item tab buttons
--------------------------------------------------------of lockspheres
local lockspheres = Instance.new("TextButton")
lockspheres.Size = UDim2.fromScale(0.05, 0.1)
lockspheres.Position = UDim2.fromScale(.9, .5)
lockspheres.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
lockspheres.Text = "lockspheres"
lockspheres.TextColor3 = Color3.fromRGB(255, 255, 255)
lockspheres.TextScaled = true
lockspheres.Parent = screenGui
Instance.new("UICorner", lockspheres).CornerRadius = UDim.new(0.02, 0)
lockspheres.Visible = false
togglemobileb.Activated:Connect(function()
	lockspheres.Visible = not lockspheres.Visible
end)
--------------------------------------------------------end of lockspheres

-- List of names to include (all lowercase)
local validNames = {
	"burger","m4a1","pistol","ammo_crate", "analogclock", "bottlecap",
	"bowlball", "comic4", "comic6", "cone", "dice",
	"dynamite", "gear",
	"key fragment", "landmine",
	"pan", "pot", "pot2", "radioactivebarrel",
	"rearbumper", "silenced pistol", "silver bar", "specialradio",
	"swarm grenade", "vaz", "vaza", "wallet1", "wallet4","sword"
}

-- Function to get all valid models in Workspace & ReplicatedStorage
local function GetValidObjects()
	local validModels = {}

	local function NameMatches(name)
		name = name:lower()
		for _, valid in ipairs(validNames) do
			if name == valid then
				return true
			end
		end
		return false
	end

	local function scan(obj)
		if obj:IsA("Model") and obj ~= plr.Character and NameMatches(obj.Name) then
			-- Only include if it has at least one BasePart and doesn't include the move part
			local hasValidPart = false
			for _, descendant in ipairs(obj:GetDescendants()) do
				if descendant:IsA("BasePart") then
					hasValidPart = true
					break
				end
			end

			if hasValidPart then
				table.insert(validModels, obj)
			end
		end

		-- Only scan children in workspace (not ReplicatedStorage)
		for _, child in ipairs(obj:GetChildren()) do
			if child:IsA("Model") then
				scan(child)
			end
		end
	end

	for _, child in ipairs(workspace:GetChildren()) do
		scan(child)
	end

	return validModels
end

local validNameSet = {}
for _, name in ipairs(validNames) do
	validNameSet[string.lower(name)] = true
end



-- Auto-refresh scroll frame
task.spawn(function()
	while screenGui.Parent do
		-- Clear old buttons
		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		-- Get valid objects once per refresh
		local models = GetValidObjects()
		local counts = {}
		for _, m in ipairs(models) do
			local lname = m.Name:lower()
			counts[lname] = (counts[lname] or 0) + 1
		end

		-- Sort names
		local sortedNames = {}
		for name in pairs(counts) do
			table.insert(sortedNames, name)
		end
		table.sort(sortedNames)

		-- Create buttons
		for _, name in ipairs(sortedNames) do
			local displayText = string.format("%s (x%d)", name, counts[name])
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, 0, 0, 30)
			button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.TextScaled = true
			button.TextWrapped = true
			button.Text = displayText
			button.Parent = scrollFrame
			Instance.new("UICorner", button).CornerRadius = UDim.new(0.02, 0)

			-- Hover effect
			button.MouseEnter:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
			end)
			button.MouseLeave:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end)

			-- Select item on click
			button.MouseButton1Click:Connect(function()
				selectedItemLabel.Text = "Selected: " .. name .. " (x" .. counts[name] .. ")"
			end)
		end

		task.wait(1)
	end
end)



-------------------------------------------------------------------------------sphere teleport stuffs
local spheresActive = false
local mainSphere
local ySphere
local yOffset = 2
local sphereLocked = false

offsetspheres.FocusLost:Connect(function(enterPressed)
	local newVal = tonumber(offsetspheres.Text)
	if newVal then
		yOffset = newVal
		print("[SphereUI] Y offset set to:", yOffset)
	else
		offsetspheres.Text = tostring(yOffset)
	end
end)

-- Toggle spheres on/off
toggleButton.Activated:Connect(function()
	if spheresActive then
		-- Turn off spheres
		spheresActive = false
		sphereLocked = false

		if mainSphere then
			mainSphere:Destroy()
			mainSphere = nil
		end
		if ySphere then
			ySphere:Destroy()
			ySphere = nil
		end
	else
		-- Create main sphere
		mainSphere = Instance.new("Part")
		mainSphere.Shape = Enum.PartType.Ball
		mainSphere.Size = Vector3.new(0.5, 0.5, 0.5)
		mainSphere.Color = Color3.fromRGB(0, 170, 255)
		mainSphere.Material = Enum.Material.Neon
		mainSphere.Anchored = true
		mainSphere.CanCollide = false
		mainSphere.Parent = workspace

		-- Create Y-offset sphere
		ySphere = Instance.new("Part")
		ySphere.Shape = Enum.PartType.Ball
		ySphere.Size = Vector3.new(0.5, 0.5, 0.5)
		ySphere.Color = Color3.fromRGB(255, 50, 50)
		ySphere.Material = Enum.Material.Neon
		ySphere.Anchored = true
		ySphere.CanCollide = false
		ySphere.Parent = workspace

		spheresActive = true
	end
end)

-- Lock toggle with "P"
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.P and spheresActive then
		sphereLocked = not sphereLocked
	end
end)

-- Mobile lock toggle
lockspheres.Activated:Connect(function()
	sphereLocked = not sphereLocked
end)

-- Update spheres every frame
RunService.RenderStepped:Connect(function()
	if not spheresActive or not mainSphere or not ySphere then
		return
	end

	local mousePos = UserInputService:GetMouseLocation()
	local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {mainSphere, ySphere, plr.Character}
	params.IgnoreWater = true

	local rayResult = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
	local hitPos = rayResult and rayResult.Position or (ray.Origin + ray.Direction * 5)

	-- ✅ Only stop mainSphere when locked; ySphere still follows
	if not sphereLocked then
		mainSphere.Position = hitPos
	end
	ySphere.Position = mainSphere.Position + Vector3.new(0, yOffset, 0)
end)

--------------------------------------------------------end of sphere teleport stuffs
-------------------------------------------------------------------------------
-- BRING ALL BUTTON FUNCTIONALITY (sets PrimaryPart automatically)
-------------------------------------------------------------------------------

bringall.Activated:Connect(function()
	local models = GetValidObjects()
	if #models == 0 then
		warn("No valid objects found to bring.")
		return
	end

	local broughtCount = 0

	for _, obj in ipairs(models) do
		-- Find or assign a primary part
		local primaryPart = obj.PrimaryPart
		if not primaryPart then
			for _, part in ipairs(obj:GetDescendants()) do
				if part:IsA("BasePart") then
					obj.PrimaryPart = part
					primaryPart = part
					break
				end
			end
		end

		-- Teleport if found
		if primaryPart then
			local targetPos = HumanoidRootPart.Position + Vector3.new(0, 3, 0)
			local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
			obj:SetPrimaryPartCFrame(CFrame.new(targetPos + offset))
			broughtCount += 1
		end
	end

	print("[BringAll] Brought " .. broughtCount .. " items to player.")
end)

-------------------------------------------------------------------------------
-- BRING ALL OF SELECTED ITEM (sets PrimaryPart automatically)
-------------------------------------------------------------------------------

bringallof1.Activated:Connect(function()
	-- Get the selected name from the label text
	local selectedText = selectedItemLabel.Text
	local selectedName = selectedText:match("Selected:%s*(.-)%s*%(")
	if not selectedName or selectedName == "None" then
		warn("[BringAllOf] No item selected.")
		return
	end

	selectedName = selectedName:lower()

	-- Get all valid objects and filter only the selected one
	local models = GetValidObjects()
	local broughtCount = 0

	for _, obj in ipairs(models) do
		if obj.Name:lower() == selectedName then
			-- Find or assign a primary part
			local primaryPart = obj.PrimaryPart
			if not primaryPart then
				for _, part in ipairs(obj:GetDescendants()) do
					if part:IsA("BasePart") then
						obj.PrimaryPart = part
						primaryPart = part
						break
					end
				end
			end

			-- Teleport if found
			if primaryPart then
				local targetPos = HumanoidRootPart.Position + Vector3.new(0, 3, 0)
				local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
				obj:SetPrimaryPartCFrame(CFrame.new(targetPos + offset))
				broughtCount += 1
			end
		end
	end

	print("[BringAllOf] Brought " .. broughtCount .. " '" .. selectedName .. "' items to player.")
end)



-------------------------------------------------------------------------------
-- BRING ALL OF SELECTED ITEM (sets PrimaryPart automatically)
-------------------------------------------------------------------------------
local bringingAll = false

bringalltosphere.Activated:Connect(function()
	bringingAll = not bringingAll

	if bringingAll then
		print("[BringAll] Auto bring started.")
	else
		print("[BringAll] Auto bring stopped.")

		-- Unanchor everything when stopped
		local models = GetValidObjects()
		for _, obj in ipairs(models) do
			for _, part in ipairs(obj:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = false
				end
			end
		end
		return
	end

	task.spawn(function()
		while bringingAll do
			local models = GetValidObjects()
			if #models == 0 then
				warn("No valid objects found to bring.")
				task.wait(1)
				continue
			end

			local broughtCount = 0
			for _, obj in ipairs(models) do
				-- Find or assign a primary part
				local primaryPart = obj.PrimaryPart
				if not primaryPart then
					for _, part in ipairs(obj:GetDescendants()) do
						if part:IsA("BasePart") then
							obj.PrimaryPart = part
							primaryPart = part
							break
						end
					end
				end

				-- Teleport if found
				if primaryPart and ySphere then
					local targetPos = ySphere.Position
					primaryPart.Anchored = true
					obj:SetPrimaryPartCFrame(CFrame.new(targetPos))
					broughtCount += 1
				end
			end

			print("[BringAll] Brought " .. broughtCount .. " items to player.")
			task.wait(1) -- repeat every second
		end
	end)
end)

--------------------------------------------------------------------
-- INSERT KEY TOGGLE UI VISIBILITY
--------------------------------------------------------------------
local uiVisible = true

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		uiVisible = not uiVisible
		outerFrame.Visible = not uiVisible
	end
end)

-----------------------------------------------------------------
local DISTANCE_THRESHOLD = 350
local FOLLOW_OFFSET = Vector3.new(0, 15, 250)
local FOLLOW_SPEED = 0.08

--// State
local following = false
local processedModels = {}
local followModels = {}

local function setPrimaryPart(model)
	if not model:IsA("Model") then return end
	if model.PrimaryPart then return end
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("BasePart") then
			model.PrimaryPart = obj
			break
		end
	end
end

--// Track eligible models
local function trackModel(model)
	if not following then return end -- only track when active
	if not model:IsA("Model") then return end
	local lowerName = string.lower(model.Name)
	if not validNameSet[lowerName] then return end
	if processedModels[model] or followModels[model] then return end

	setPrimaryPart(model)
	if model.PrimaryPart then
		processedModels[model] = true
	end
end

--// Teleport models close to player if far
local function checkAndTeleport()
	for model in pairs(processedModels) do
		if model and model.PrimaryPart then
			local distance = (model.PrimaryPart.Position - HumanoidRootPart.Position).Magnitude
			if distance >= DISTANCE_THRESHOLD then
				local targetCFrame = HumanoidRootPart.CFrame + FOLLOW_OFFSET

				-- Anchor and reposition
				for _, part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Anchored = true
					end
				end
				model:SetPrimaryPartCFrame(targetCFrame)

				followModels[model] = true
				processedModels[model] = nil
			end
		end
	end
end

--// Smoothly move anchored models
local function moveFollowModels()
	for model in pairs(followModels) do
		if model and model.PrimaryPart then
			local current = model.PrimaryPart.CFrame
			local target = HumanoidRootPart.CFrame + FOLLOW_OFFSET
			local newCFrame = current:Lerp(target, FOLLOW_SPEED)
			model:SetPrimaryPartCFrame(newCFrame)
		else
			followModels[model] = nil
		end
	end
end

--// Drop all models outward
local function dropAllModels()
	following = false
	local index = 0
	for model in pairs(followModels) do
		if model and model.PrimaryPart then
			local angle = math.rad(index * 30)
			local offset = Vector3.new(math.cos(angle)*250, 15, math.sin(angle)*250)
			local dropCFrame = HumanoidRootPart.CFrame + offset
			model:SetPrimaryPartCFrame(dropCFrame)
			index += 1
		end
	end
	-- Keep them anchored but reset lists
	processedModels = {}
	followModels = {}
end

--// Toggle follow/drop
local function toggleFollow()
	if following then
		dropAllModels()
	else
		following = true
		-- Fresh scan of all valid models at start
		for _, model in ipairs(workspace:GetDescendants()) do
			trackModel(model)
		end
	end
end

--// Auto-track only new models while following
Workspace.DescendantAdded:Connect(trackModel)

--// Run loop
RunService.Heartbeat:Connect(function()
	if following then
		checkAndTeleport()
		moveFollowModels()
	end
end)

bringwithloop.Activated:Connect(function()
	toggleFollow()
	if following == true then
		bringwithloop.Text = "looping..."
	else
		bringwithloop.Text = "bringwithloop"
	end
end)


-----------------------------------------------

local mouse = plr:GetMouse()

local RaycastGUI = Instance.new("TextBox")
RaycastGUI.Size = UDim2.fromScale(0.8, 0.8)
RaycastGUI.Position = UDim2.fromScale(0.1, 0.1)
RaycastGUI.Text = ""
RaycastGUI.ClearTextOnFocus = false
RaycastGUI.TextScaled = false -- disable auto scaling
RaycastGUI.TextSize = 18        -- smaller text
RaycastGUI.TextWrapped = true   -- enable wrapping
RaycastGUI.TextXAlignment = Enum.TextXAlignment.Left
RaycastGUI.TextYAlignment = Enum.TextYAlignment.Top
RaycastGUI.TextColor3 = Color3.new(1, 1, 1)
RaycastGUI.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RaycastGUI.BackgroundTransparency = 0.5
RaycastGUI.Parent = placeholder1



-- Table to store hit model names
local hitModels = {}

-- Function to get the top-level model of a part
local function getModel(part)
	if not part then return nil end
	local model = part:FindFirstAncestorOfClass("Model")
	if model then
		return model.Name
	end
	return nil
end

-- Function to perform raycast
local function castRay()
	local character = plr.Character
	if not character then return end
	local head = character:FindFirstChild("Head")
	if not head then return end

	local origin = head.Position
	local direction = (mouse.Hit.Position - origin).Unit * 1000 -- Ray length 1000 studs

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character} -- Ignore self
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(origin, direction, raycastParams)
	if result and result.Instance then
		local modelName = getModel(result.Instance)
		if modelName and not table.find(hitModels, modelName) then
			table.insert(hitModels, modelName)
			RaycastGUI.Text = '"' .. table.concat(hitModels, '","') .. '"'
		end
	end
end

-- Raycast on left click
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		castRay()
	end
end)

local frameVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightAlt then
		frameVisible = not frameVisible
		outerFrame.Visible = frameVisible
		visibilityButton.Visible = frameVisible
	end
end)
