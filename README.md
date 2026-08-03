-- 1. Load library
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua](https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua)"))()

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
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})
​[!IMPORTANT]
Be sure to replace YourUsername/YourRepo with your actual GitHub username and repository name. Ensure the URL points to raw content (raw.githubusercontent.com).
​⚡ Quick Start
​Get a basic UI up and running in seconds:

-- 1. Load library
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua](https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua)"))()

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
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})
📖 API Reference
​Library Initialisation
​Loads and executes the raw library code, returning the main library object.


local Library = loadstring(game:HttpGet(url))()



