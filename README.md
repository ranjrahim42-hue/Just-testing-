--[[
================================================================================
                        🛠️ CUSTOM LUAU UI LIBRARY DOCS
================================================================================

A lightweight, modern, modular Roblox UI library built with strict Luau 
practices, OOP design, and built-in interactive animations.

--------------------------------------------------------------------------------
🚀 QUICKSTART & LOADING
--------------------------------------------------------------------------------
To load the library remotely, fetch the raw file from your GitHub repository:

    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"))()
    local Window = Library.new("My Script Hub")

================================================================================
📌 ELEMENTS & PARAMETERS GUIDE
================================================================================

1. MAIN WINDOW
   Creates the primary UI container frame with full drag support.
   
   Syntax:
       local Window = Library.new(Title)
       
   Parameters:
       • Title (string) [REQUIRED]: Header text displayed at the top bar.


2. TABS
   Creates a tab category on the sidebar and a dedicated page container.
   
   Syntax:
       local MainTab = Window:Tab({
           Name = "Main Features"
       })
       
   Parameters:
       • Name (string) [REQUIRED]: Button label in the sidebar navigation.


3. IMAGE BUTTON
   Adds a dynamic ImageButton with hover scaling, micro-tilts, click 
   compressions, and a customizable periodic glint sweep effect.
   
   Syntax:
       MainTab:ImageButton({
           ImageId = "rbxassetid://8964489619",
           Size = 70,
           IsCircular = false,
           CornerRadius = 14,
           GlintInterval = 3.5,
           Callback = function()
               print("Image Button Pressed!")
           end
       })
       
   Parameters:
       • ImageId (string) [REQUIRED]: Asset ID format ("rbxassetid://ID" or URL).
       • Size (number) [DEFAULT: 60]: Button size in pixels (Width & Height).
       • IsCircular (boolean) [DEFAULT: false]: Forces full circular rounding if true.
       • CornerRadius (number) [DEFAULT: 12]: Corner radius in pixels (if not circular).
       • GlintInterval (number) [DEFAULT: 4.0]: Time delay in seconds between glints.
       • Callback (function) [OPTIONAL]: Function executed via task.spawn on click.


4. TOGGLE
   Creates an interactive switch with smooth color transitions & sliding indicators.
   
   Syntax:
       MainTab:Toggle({
           Name = "Auto Farm",
           Default = false,
           Callback = function(state)
               print("Toggle state:", state)
           end
       })
       
   Parameters:
       • Name (string) [REQUIRED]: Label displayed next to the toggle switch.
       • Default (boolean) [DEFAULT: false]: Initial state (true = ON, false = OFF).
       • Callback (function) [OPTIONAL]: Passes boolean 'state' when clicked.


5. SLIDER
   Creates a drag-enabled numerical slider with live value updating.
   
   Syntax:
       MainTab:Slider({
           Name = "WalkSpeed",
           Min = 16,
           Max = 250,
           Default = 16,
           Callback = function(value)
               game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
           end
       })
       
   Parameters:
       • Name (string) [REQUIRED]: Title text displayed above the track.
       • Min (number) [DEFAULT: 0]: Minimum allowed value.
       • Max (number) [DEFAULT: 100]: Maximum allowed value.
       • Default (number) [DEFAULT: Min]: Starting value for the track.
       • Callback (function) [OPTIONAL]: Passes number 'val' while dragging/clicking.

================================================================================
💡 EXAMPLE IMPLEMENTATION SCRIPT
================================================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"))()

local Window = Library.new("Cheat Engine Hub")
local MainTab = Window:Tab({ Name = "Farming" })
local PlayerTab = Window:Tab({ Name = "Local Player" })

MainTab:ImageButton({
    ImageId = "rbxassetid://8964489619",
    Size = 80,
    IsCircular = true,
    GlintInterval = 2.0,
    Callback = function()
        print("Action executed directly!")
    end
})

MainTab:Toggle({
    Name = "Auto Collect",
    Default = true,
    Callback = function(enabled)
        _G.AutoCollect = enabled
    end
})

PlayerTab:Slider({
    Name = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
    end
})

================================================================================
]]
