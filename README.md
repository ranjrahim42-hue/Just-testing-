```markdown
# Script Hub Library

[![Lua](https://img.shields.io/badge/Lua-5.1-blue.svg)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Roblox-API-red.svg)](https://developer.roblox.com/)

A lightweight, feature‑rich UI framework for building script hubs in Roblox.  
Easily create draggable windows with tabs, image buttons, toggles, and sliders – all with smooth animations and minimal boilerplate.

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
  - [Library Initialisation](#library-initialisation)
  - [Window Creation](#window-creation)
  - [Tab Creation](#tab-creation)
  - [Controls](#controls)
    - [ImageButton](#imagebutton)
    - [Toggle](#toggle)
    - [Slider](#slider)
- [Full Example](#full-example)
- [Notes](#notes)
- [License](#license)

---

## Installation

Load the library from your GitHub repository (raw URL):

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"))()
```

Important: Replace YourUsername/YourRepo with your actual GitHub username and repository name. Ensure the file is served as raw content.

---

Quick Start

```lua
-- 1. Load library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"))()

-- 2. Create main window
local Window = Library.new("My Script Hub")

-- 3. Create tabs
local MainTab = Window:Tab({ Name = "Main Features" })
local PlayerTab = Window:Tab({ Name = "Player Settings" })

-- 4. Add controls
MainTab:Toggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

PlayerTab:Slider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})
```

---

API Reference

Library Initialisation

loadstring(game:HttpGet(url))() – returns the library object.

Window Creation

```lua
local Window = Library.new(Title)
```

Parameter Type Required Description
Title string Yes Text displayed in the header bar.

Tab Creation

```lua
local Tab = Window:Tab({ Name = "Tab Name" })
```

Parameter Type Required Description
Name string Yes Label shown on the sidebar button.

---

Controls

All controls are added to a tab instance (e.g., Tab:ControlName({ ... })).

---

ImageButton

Adds a clickable image with a glint sweep effect, hover scaling, and click feedback.

```lua
Tab:ImageButton({ ... })
```

Parameters:

Parameter Type Default Description
ImageId string Req. Asset ID (rbxassetid://ID) or full URL of the image.
Size number 60 Width and height in pixels.
IsCircular boolean false If true, forces a perfect circle (overrides CornerRadius).
CornerRadius number 12 Soft corner radius (ignored when IsCircular = true).
GlintInterval number 4.0 Delay (in seconds) between automatic glint sweeps.
Callback function nil Called when the button is clicked (no arguments passed).

Example:

```lua
MainTab:ImageButton({
    ImageId = "rbxassetid://8964489619",
    Size = 70,
    IsCircular = false,
    CornerRadius = 14,
    GlintInterval = 3.5,
    Callback = function()
        print("Image Button clicked!")
    end
})
```

---

Toggle

An ON/OFF switch with smooth state transitions.

```lua
Tab:Toggle({ ... })
```

Parameters:

Parameter Type Default Description
Name string Req. Label displayed next to the switch.
Default boolean false Initial state (true = ON, false = OFF).
Callback function nil Receives the new state (boolean) when toggled.

Example:

```lua
MainTab:Toggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm set to:", state)
    end
})
```

---

Slider

A draggable slider bar that outputs numeric values in real time.

```lua
Tab:Slider({ ... })
```

Parameters:

Parameter Type Default Description
Name string Req. Label displayed above the slider.
Min number 0 Minimum value.
Max number 100 Maximum value.
Default number Min value Starting position of the slider.
Callback function nil Receives the current value (number) while dragging.

Example:

```lua
PlayerTab:Slider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})
```

---

Full Example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"))()
local Window = Library.new("My Script Hub")

local MainTab = Window:Tab({ Name = "Main Features" })
local PlayerTab = Window:Tab({ Name = "Player Settings" })

MainTab:ImageButton({
    ImageId = "rbxassetid://8964489619",
    Size = 70,
    Callback = function() print("Clicked!") end
})

MainTab:Toggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(s) print("Farm:", s) end
})

PlayerTab:Slider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
})
```

---

Notes

· All callbacks are optional – the UI will still render correctly.
· The library automatically handles scaling and responsiveness.
· The glint effect on ImageButton runs in a loop; it stops when the button or window is destroyed.
· Ensure your ImageId is a valid Roblox asset ID (rbxassetid://...) or a direct image URL.
· For security, load the library from a trusted source and verify the raw URL.

---

License

This project is provided as‑is under the MIT License. Feel free to modify and distribute.

```
