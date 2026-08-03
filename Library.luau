--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Library Table Structure
local Library = {}
Library.__index = Library

local Tab = {}
Tab.__index = Tab

-- Helper Tweens
local FAST_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SPRING_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ==========================================
-- 🚀 1. LIBRARY CREATION (MAIN WINDOW)
-- ==========================================
function Library.new(title: string)
	local self = setmetatable({}, Library)
	
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CustomUILibrary"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui
	self.ScreenGui = screenGui

	-- Main Window Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.fromOffset(500, 350)
	mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
	mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	self.MainFrame = mainFrame

	local windowCorner = Instance.new("UICorner")
	windowCorner.CornerRadius = UDim.new(0, 10)
	windowCorner.Parent = mainFrame

	-- Top Bar / Title
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 1, 0)
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = topBar

	-- Tab Sidebar Container
	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "TabSidebar"
	tabContainer.Size = UDim2.new(0, 130, 1, -40)
	tabContainer.Position = UDim2.new(0, 0, 0, 40)
	tabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	tabContainer.BorderSizePixel = 0
	tabContainer.Parent = mainFrame

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 5)
	tabListLayout.Parent = tabContainer

	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingTop = UDim.new(0, 8)
	tabPadding.PaddingLeft = UDim.new(0, 8)
	tabPadding.PaddingRight = UDim.new(0, 8)
	tabPadding.Parent = tabContainer

	-- Elements Container Area
	local pageContainer = Instance.new("Frame")
	pageContainer.Name = "PageContainer"
	pageContainer.Size = UDim2.new(1, -130, 1, -40)
	pageContainer.Position = UDim2.new(0, 130, 0, 40)
	pageContainer.BackgroundTransparency = 1
	pageContainer.Parent = mainFrame

	self.TabSidebar = tabContainer
	self.PageContainer = pageContainer
	self.Tabs = {}

	-- Draggable Main Window
	local dragging, dragStart, startPos
	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return self
end

-- ==========================================
-- 📂 2. TAB CREATION
-- ==========================================
function Library:Tab(options: { Name: string })
	local tabObj = setmetatable({}, Tab)
	
	-- Sidebar Button
	local tabButton = Instance.new("TextButton")
	tabButton.Name = options.Name .. "Button"
	tabButton.Size = UDim2.new(1, 0, 0, 32)
	tabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	tabButton.Text = options.Name
	tabButton.TextColor3 = Color3.fromRGB(180, 180, 190)
	tabButton.Font = Enum.Font.GothamMedium
	tabButton.TextSize = 13
	tabButton.AutoButtonColor = false
	tabButton.Parent = self.TabSidebar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = tabButton

	-- Content Page ScrollingFrame
	local page = Instance.new("ScrollingFrame")
	page.Name = options.Name .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.ScrollBarThickness = 3
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Parent = self.PageContainer

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 8)
	pageLayout.Parent = page

	local pagePadding = Instance.new("UIPadding")
	pagePadding.PaddingTop = UDim.new(0, 10)
	pagePadding.PaddingLeft = UDim.new(0, 10)
	pagePadding.PaddingRight = UDim.new(0, 10)
	pagePadding.Parent = page

	tabObj.Page = page
	tabObj.Button = tabButton

	-- Selection Logic
	local function selectTab()
		for _, t in pairs(self.Tabs) do
			t.Page.Visible = false
			TweenService:Create(t.Button, FAST_INFO, {
				BackgroundColor3 = Color3.fromRGB(28, 28, 34),
				TextColor3 = Color3.fromRGB(180, 180, 190)
			}):Play()
		end
		page.Visible = true
		TweenService:Create(tabButton, FAST_INFO, {
			BackgroundColor3 = Color3.fromRGB(60, 115, 255),
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end

	tabButton.MouseButton1Click:Connect(selectTab)
	table.insert(self.Tabs, tabObj)

	if #self.Tabs == 1 then
		selectTab()
	end

	return tabObj
end

-- ==========================================
-- 🖼️ 3. IMAGE BUTTON ELEMENT (WITH GLINT)
-- ==========================================
function Tab:ImageButton(options: { ImageId: string, Size: number?, IsCircular: boolean?, CornerRadius: number?, GlintInterval: number?, Callback: () -> () })
	local sizePx = options.Size or 60
	local isCircular = options.IsCircular or false
	local cornerRadius = options.CornerRadius or 12
	local glintInterval = options.GlintInterval or 4.0

	local wrapper = Instance.new("Frame")
	wrapper.Size = UDim2.new(1, 0, 0, sizePx + 10)
	wrapper.BackgroundTransparency = 1
	wrapper.Parent = self.Page

	local imageButton = Instance.new("ImageButton")
	imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
	imageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageButton.Size = UDim2.fromOffset(sizePx, sizePx)
	imageButton.Image = options.ImageId
	imageButton.BackgroundTransparency = 1
	imageButton.AutoButtonColor = false
	imageButton.ClipsDescendants = true
	imageButton.Parent = wrapper

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = isCircular and UDim.new(1, 0) or UDim.new(0, cornerRadius)
	uiCorner.Parent = imageButton

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Transparency = 0.8
	uiStroke.Thickness = 2
	uiStroke.Parent = imageButton

	-- Glint Effect
	local glintFrame = Instance.new("Frame")
	glintFrame.Size = UDim2.new(0.3, 0, 2, 0)
	glintFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	glintFrame.Position = UDim2.new(-0.6, 0, 0.5, 0)
	glintFrame.Rotation = 25
	glintFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	glintFrame.BorderSizePixel = 0
	glintFrame.ZIndex = 5
	glintFrame.Parent = imageButton

	local glintGradient = Instance.new("UIGradient")
	glintGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	glintGradient.Parent = glintFrame

	task.spawn(function()
		while imageButton.Parent do
			task.wait(glintInterval)
			glintFrame.Position = UDim2.new(-0.6, 0, 0.5, 0)
			TweenService:Create(glintFrame, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Position = UDim2.new(1.6, 0, 0.5, 0)
			}):Play()
		end
	end)

	-- Hover & Click Animations
	imageButton.MouseEnter:Connect(function()
		TweenService:Create(imageButton, SPRING_INFO, { Size = UDim2.fromOffset(sizePx * 1.1, sizePx * 1.1), Rotation = 3 }):Play()
		TweenService:Create(uiStroke, FAST_INFO, { Transparency = 0.3 }):Play()
	end)

	imageButton.MouseLeave:Connect(function()
		TweenService:Create(imageButton, SPRING_INFO, { Size = UDim2.fromOffset(sizePx, sizePx), Rotation = 0 }):Play()
		TweenService:Create(uiStroke, FAST_INFO, { Transparency = 0.8 }):Play()
	end)

	imageButton.MouseButton1Down:Connect(function()
		TweenService:Create(imageButton, FAST_INFO, { Size = UDim2.fromOffset(sizePx * 0.95, sizePx * 0.95), Rotation = -2 }):Play()
	end)

	imageButton.MouseButton1Up:Connect(function()
		TweenService:Create(imageButton, SPRING_INFO, { Size = UDim2.fromOffset(sizePx * 1.1, sizePx * 1.1), Rotation = 3 }):Play()
	end)

	imageButton.MouseButton1Click:Connect(function()
		if options.Callback then
			task.spawn(options.Callback)
		end
	end)
end

-- ==========================================
-- 🔘 4. TOGGLE ELEMENT
-- ==========================================
function Tab:Toggle(options: { Name: string, Default: boolean?, Callback: (state: boolean) -> () })
	local state = options.Default or false

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	frame.Parent = self.Page

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Text = options.Name
	label.TextColor3 = Color3.fromRGB(230, 230, 230)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = frame

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.new(0, 40, 0, 20)
	switch.Position = UDim2.new(1, -50, 0.5, -10)
	switch.BackgroundColor3 = state and Color3.fromRGB(60, 115, 255) or Color3.fromRGB(50, 50, 60)
	switch.Text = ""
	switch.AutoButtonColor = false
	switch.Parent = frame

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switch

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 16, 0, 16)
	indicator.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	indicator.Parent = switch

	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(1, 0)
	indCorner.Parent = indicator

	switch.MouseButton1Click:Connect(function()
		state = not state
		local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		local targetColor = state and Color3.fromRGB(60, 115, 255) or Color3.fromRGB(50, 50, 60)

		TweenService:Create(indicator, FAST_INFO, { Position = targetPos }):Play()
		TweenService:Create(switch, FAST_INFO, { BackgroundColor3 = targetColor }):Play()

		if options.Callback then
			task.spawn(options.Callback, state)
		end
	end)
end

-- ==========================================
-- 🎚️ 5. SLIDER ELEMENT
-- ==========================================
function Tab:Slider(options: { Name: string, Min: number, Max: number, Default: number?, Callback: (value: number) -> () })
	local min = options.Min or 0
	local max = options.Max or 100
	local default = options.Default or min
	local currentVal = math.clamp(default, min, max)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 48)
	frame.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	frame.Parent = self.Page

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, -12, 0, 20)
	label.Position = UDim2.new(0, 12, 0, 6)
	label.Text = options.Name
	label.TextColor3 = Color3.fromRGB(230, 230, 230)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.4, -12, 0, 20)
	valueLabel.Position = UDim2.new(0.6, 0, 0, 6)
	valueLabel.Text = tostring(currentVal)
	valueLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.BackgroundTransparency = 1
	valueLabel.Parent = frame

	local sliderTrack = Instance.new("TextButton")
	sliderTrack.Size = UDim2.new(1, -24, 0, 6)
	sliderTrack.Position = UDim2.new(0, 12, 1, -14)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	sliderTrack.Text = ""
	sliderTrack.AutoButtonColor = false
	sliderTrack.Parent = frame

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = sliderTrack

	local sliderFill = Instance.new("Frame")
	local fillPercent = (currentVal - min) / (max - min)
	sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(60, 115, 255)
	sliderFill.Parent = sliderTrack

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = sliderFill

	local dragging = false

	local function updateSlider(input: InputObject)
		local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
		local val = math.floor(min + (max - min) * percent)

		valueLabel.Text = tostring(val)
		TweenService:Create(sliderFill, FAST_INFO, { Size = UDim2.new(percent, 0, 1, 0) }):Play()

		if options.Callback then
			task.spawn(options.Callback, val)
		end
	end

	sliderTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateSlider(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- VERY IMPORTANT: Return the module table at the end
return Library
