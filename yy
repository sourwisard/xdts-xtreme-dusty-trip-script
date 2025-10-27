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
	{ name = "Placeholder1", target = placeholder1 },
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
visibilityButton.Size = UDim2.fromScale(0.1, 0.1)
visibilityButton.Position = UDim2.fromScale(.5, 0) -- top-left corner
visibilityButton.Text = "Hide Frame"
visibilityButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
visibilityButton.TextColor3 = Color3.fromRGB(255, 255, 255)
visibilityButton.TextScaled = true
visibilityButton.Parent = screenGui
Instance.new("UICorner", visibilityButton).CornerRadius = UDim.new(0.03, 0)
visibilityButton.Visible = true
visibilityButton.Activated:Connect(function()
	outerFrame.Visible = not outerFrame.Visible
	visibilityButton.Text = outerFrame.Visible and "Hide Frame" or "Show Frame"
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

local bringall = Instance.new("TextButton")
bringall.Size = UDim2.fromScale(0.1, 0.1)
bringall.Position = UDim2.fromScale(.05, 0.21)
bringall.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bringall.Text = "bringall"
bringall.TextColor3 = Color3.fromRGB(255, 255, 255)
bringall.TextScaled = true
bringall.Parent = itemsTab
Instance.new("UICorner", bringall).CornerRadius = UDim.new(0.02, 0)

local bringallof1 = Instance.new("TextButton")
bringallof1.Size = UDim2.fromScale(0.1, 0.1)
bringallof1.Position = UDim2.fromScale(.05, 0.32)
bringallof1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bringallof1.Text = "bringallof1"
bringallof1.TextColor3 = Color3.fromRGB(255, 255, 255)
bringallof1.TextScaled = true
bringallof1.Parent = itemsTab
Instance.new("UICorner", bringallof1).CornerRadius = UDim.new(0.02, 0)

local bringallselectedtosphere = Instance.new("TextButton")
bringallselectedtosphere.Size = UDim2.fromScale(0.1, 0.1)
bringallselectedtosphere.Position = UDim2.fromScale(.05, 0.43)
bringallselectedtosphere.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bringallselectedtosphere.Text = "tp selected to sphere"
bringallselectedtosphere.TextColor3 = Color3.fromRGB(255, 255, 255)
bringallselectedtosphere.TextScaled = true
bringallselectedtosphere.Parent = itemsTab
Instance.new("UICorner", bringallselectedtosphere).CornerRadius = UDim.new(0.02, 0)

local togglemobileb = Instance.new("TextButton")
togglemobileb.Size = UDim2.fromScale(0.1, 0.1)
togglemobileb.Position = UDim2.fromScale(.16, 0.1)
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
	"burger","m4a1","pistol","ammo_crate", "analogclock", "apple", "back", "banana", "bar", "beam", "blade", "bottlecap", "bowlball", "box", "bread", "brick", "candy", "coffin", "comic4", "comic6", "cone", "dice", "dieselcan", "dogtag", "donut", "dynamite", "engine", "flashlight", "food", "fr", "frontbumper", "gear", "glassbottle", "grate", "grill", "heater", "hood", "iron", "ironboard", "key fragment", "landmine", "leftlight", "lever", "licenseplate1", "licenseplate2", "licenseplate4", "loosechair", "muhoboika", "oilcan", "onion", "pan", "paper", "peper", "pin", "pizza", "pot", "pot2", "radiator", "radioactivebarrel", "rearbumper", "rightlight", "shield", "silenced pistol", "silver bar", "siren", "specialradio", "sponge", "spraypaint", "stairs", "swarm grenade", "toilet", "vaz", "vaza", "wallet1", "wallet4", "weight", "wheel", "wing", "woodplanmks"
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
				if descendant:IsA("BasePart") and descendant.Name ~= movePartName then
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
local yOffset = 5
local sphereLocked = false

toggleButton.Activated:Connect(function()
	if spheresActive then
		-- Stop updates first
		spheresActive = false
		sphereLocked = false  -- unlock automatically when removing

		-- Fully delete spheres
		if mainSphere then
			mainSphere:Destroy()
			mainSphere = nil
		end
		if ySphere then
			ySphere:Destroy()
			ySphere = nil
		end
	else
		-- Create new spheres and enable updates
		mainSphere = Instance.new("Part")
		mainSphere.Shape = Enum.PartType.Ball
		mainSphere.Size = Vector3.new(0.5, 0.5, 0.5)
		mainSphere.Color = Color3.fromRGB(0, 170, 255)
		mainSphere.Material = Enum.Material.Neon
		mainSphere.Anchored = true
		mainSphere.CanCollide = false
		mainSphere.Parent = workspace

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
--mobile support
lockspheres.Activated:Connect(function()
	sphereLocked = not sphereLocked
end)


-- Update spheres only when active
RunService.RenderStepped:Connect(function()
	if not spheresActive or not mainSphere or not ySphere or sphereLocked then
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

	mainSphere.Position = hitPos
	ySphere.Position = hitPos + Vector3.new(0, yOffset, 0)
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
