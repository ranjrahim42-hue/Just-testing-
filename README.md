-- 1. LOADING THE LIBRARY & MAIN WINDOW
-- Loads your raw script from GitHub and creates the main window.
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"))()
```
-- Syntax:
-- local Window = Library.new(Title)
--
-- Parameters:
-- • Title (string) [REQUIRED]: Text displayed on the main header bar.

local Window = Library.new("My Script Hub")
-- 2. CREATING TABS
-- Adds sidebar buttons and dedicated pages to organize your controls.

-- Syntax:
```lua
-- local Tab = Window:Tab({ Name = "Tab Name" })
```
--
-- Parameters:
-- • Name (string) [REQUIRED]: The label shown on the tab's sidebar button.
```lua

local MainTab = Window:Tab({ Name = "Main Features" })

local PlayerTab = Window:Tab({ Name = "Player Settings" })

```
-- 3. IMAGE BUTTON
-- Adds a dynamic ImageButton with hover scaling, click feedback, and a glint sweep effect.

-- Syntax:
```lua

 MainTab:ImageButton({ Parameters... })
```
--
-- Parameters:
-- • ImageId (string)       [REQUIRED]: Asset ID format ("rbxassetid://ID" or URL).
-- • Size (number)          [DEFAULT: 60]: Button width & height in pixels.
-- • IsCircular (boolean)   [DEFAULT: false]: Forces a full circle if set to true.
-- • CornerRadius (number)  [DEFAULT: 12]: Soft corner radius in pixels (when IsCircular is false).
-- • GlintInterval (number) [DEFAULT: 4.0]: Delay in seconds between glint sweeps.
-- • Callback (function)    [OPTIONAL]: Code logic executed directly on click.

```lua
MainTab:ImageButton({
	ImageId = "rbxassetid://8964489619",
	Size = 70,
	IsCircular = false,
	CornerRadius = 14,
	GlintInterval = 3.5,
	Callback = function()
		print("Image Button Clicked directly!")
	end
})

```
-- 4. TOGGLE SWITCH
-- Creates an ON/OFF toggle switch with smooth state transitions.

-- Syntax:
-- Tab:Toggle({ Parameters... })
--
-- Parameters:
-- • Name (string)       [REQUIRED]: Title text displayed next to the switch.
-- • Default (boolean)   [DEFAULT: false]: Initial state (true = ON, false = OFF).
-- • Callback (function) [OPTIONAL]: Receives a boolean 'state' when toggled.
```lua
MainTab:Toggle({
	Name = "Auto Farm",
	Default = false,
	Callback = function(state: boolean)
		print("Auto Farm set to:", state)
	end
})

```

-- 5. SLIDER
-- Creates a draggable slider bar with live value updating.

-- Syntax:
-- Tab:Slider({ Parameters... })
--
-- Parameters:
-- • Name (string)       [REQUIRED]: Label title above the slider bar.
-- • Min (number)        [DEFAULT: 0]: Minimum numerical value.
-- • Max (number)        [DEFAULT: 100]: Maximum numerical value.
-- • Default (number)    [DEFAULT: Min]: Starting position of the slider track.
-- • Callback (function) [OPTIONAL]: Receives a number 'value' while dragging or clicking.
```lua
PlayerTab:Slider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 250,
	Default = 16,
	Callback = function(value: number)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = value
		end
	end
})

```
