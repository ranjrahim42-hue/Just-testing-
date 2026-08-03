Script Hub Library – UI Framework for Roblox

A lightweight, feature‑rich UI library for building script hubs with minimal effort.
It provides a draggable main window, tabbed navigation, and styled controls (image buttons, toggles, sliders) with smooth animations and hover feedback.

---

Installation

Load the library from your GitHub repository:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"))()
```

Note: Replace YourUsername/YourRepo with your actual GitHub username and repository name.

---

Basic Usage

1. Create the Main Window

```lua
local Window = Library.new("My Script Hub")
```

· Parameter: Title (string) – the text displayed in the header bar.

---

2. Create Tabs

Tabs appear as sidebar buttons; each tab holds its own controls.

```lua
local MainTab = Window:Tab({ Name = "Main Features" })
local PlayerTab = Window:Tab({ Name = "Player Settings" })
```

· Parameter table:
  · Name (string) – label shown on the tab button.

---

3. Add Controls

All controls are added to a tab instance.

---

ImageButton

Adds a clickable image with a glint sweep effect, hover scaling, and click feedback.

Syntax:
Tab:ImageButton({ ... })

Parameter Type Default Description
ImageId string Req. Asset ID (rbxassetid://ID) or full URL.
Size number 60 Width and height in pixels.
IsCircular boolean false If true, forces a perfect circle.
CornerRadius number 12 Corner radius (ignored when IsCircular = true).
GlintInterval number 4.0 Seconds between glint sweep animations.
Callback function nil Called when the button is clicked (no arguments).

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

An ON/OFF switch with smooth transitions.

Syntax:
Tab:Toggle({ ... })

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

A draggable slider bar that outputs numeric values.

Syntax:
Tab:Slider({ ... })

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

· All callbacks are optional.
· The library automatically handles UI scaling and responsiveness.
· For the image button, the glint effect runs in a loop; you can stop it by destroying the button or the window.
· Make sure your ImageId is valid – use a Roblox asset ID or a direct image URL.

---

License

This project is provided as‑is. Feel free to modify and distribute.
