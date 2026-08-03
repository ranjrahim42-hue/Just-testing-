<div align="center">

# 🔧 Script Hub Library

[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?style=flat-square&logo=lua&logoColor=white)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Roblox-API-000000?style=flat-square&logo=roblox&logoColor=white)](https://developer.roblox.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

**A lightweight, feature-rich UI framework for building Roblox script hubs.**

Easily create draggable windows with tabs, image buttons, toggles, and sliders — all powered by smooth animations and minimal boilerplate.

</div>

---

## 📑 Table of Contents

- [✨ Features](#-features)
- [📦 Installation](#-installation)
- [🚀 Quick Start](#-quick-start)
- [📖 API Reference](#-api-reference)
  - [Library Initialisation](#library-initialisation)
  - [Window Creation](#window-creation)
  - [Tab Creation](#tab-creation)
  - [Controls](#controls)
    - [ImageButton](#imagebutton)
    - [Toggle](#toggle)
    - [Slider](#slider)
- [📋 Full Example](#-full-example)
- [📝 Notes & Best Practices](#-notes--best-practices)
- [📄 License](#-license)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🪟 **Draggable Windows** | Smooth, animated window frames with custom titles |
| 📑 **Tab System** | Organize your controls into clean, switchable tabs |
| 🖼️ **Image Buttons** | Clickable images with glint sweep effects and hover scaling |
| 🔘 **Toggles** | Animated ON/OFF switches with smooth state transitions |
| 📊 **Sliders** | Draggable numeric sliders with real-time value output |
| ✨ **Smooth Animations** | Spring-physics-based tweens for a polished feel |
| 📱 **Responsive** | Automatic scaling and layout handling |
| 🧩 **Minimal Boilerplate** | Get a full UI running in under 20 lines |

---

## 📦 Installation

Load the library directly into your script environment using `loadstring`:

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"
))()
```

> ⚠️ **Important:** Replace `YourUsername/YourRepo` with your actual GitHub username and repository name. Ensure the file is served as raw content.

---

## 🚀 Quick Start

```lua
-- 1. Load the library
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"
))()

-- 2. Create the main window
local Window = Library.new("My Script Hub")

-- 3. Create tabs
local MainTab    = Window:Tab({ Name = "Main Features" })
local PlayerTab  = Window:Tab({ Name = "Player Settings" })

-- 4. Add controls
MainTab:Toggle({
    Name     = "Auto Farm",
    Default  = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

PlayerTab:Slider({
    Name     = "WalkSpeed",
    Min      = 16,
    Max      = 250,
    Default  = 16,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})
```

---

## 📖 API Reference

### Library Initialisation

```lua
local Library = loadstring(game:HttpGet(url))()
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `url` | `string` | ✅ Yes | Raw GitHub URL pointing to `Library.lua` |

**Returns:** `Library` — the library object used to create windows.

---

### Window Creation

```lua
local Window = Library.new(Title)
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Title` | `string` | ✅ Yes | Text displayed in the window header bar |

**Returns:** `Window` — a window instance with tab creation methods.

---

### Tab Creation

```lua
local Tab = Window:Tab({ Name = "Tab Name" })
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Name` | `string` | ✅ Yes | Label shown on the sidebar tab button |

**Returns:** `Tab` — a tab instance for adding controls.

---

### Controls

All controls are added to a tab instance via `Tab:ControlName({ ... })`.

---

#### ImageButton

Adds a clickable image with a glint sweep effect, hover scaling, and click feedback.

```lua
Tab:ImageButton({
    ImageId       = "rbxassetid://8964489619",
    Size          = 70,
    IsCircular    = false,
    CornerRadius  = 14,
    GlintInterval = 3.5,
    Callback      = function()
        print("Image Button clicked!")
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ImageId` | `string` | **Required** | Asset ID (`rbxassetid://ID`) or full image URL |
| `Size` | `number` | `60` | Width and height in pixels |
| `IsCircular` | `boolean` | `false` | Forces a perfect circle (overrides `CornerRadius`) |
| `CornerRadius` | `number` | `12` | Soft corner radius (ignored when `IsCircular = true`) |
| `GlintInterval` | `number` | `4.0` | Delay in seconds between automatic glint sweeps |
| `Callback` | `function` | `nil` | Called when the button is clicked (no arguments) |

---

#### Toggle

An ON/OFF switch with smooth state transitions.

```lua
Tab:Toggle({
    Name     = "Auto Farm",
    Default  = false,
    Callback = function(state)
        print("Auto Farm set to:", state)
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | **Required** | Label displayed next to the switch |
| `Default` | `boolean` | `false` | Initial state (`true` = ON, `false` = OFF) |
| `Callback` | `function` | `nil` | Receives the new state (`boolean`) when toggled |

---

#### Slider

A draggable slider bar that outputs numeric values in real time.

```lua
Tab:Slider({
    Name     = "WalkSpeed",
    Min      = 16,
    Max      = 250,
    Default  = 16,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | `string` | **Required** | Label displayed above the slider |
| `Min` | `number` | `0` | Minimum value |
| `Max` | `number` | `100` | Maximum value |
| `Default` | `number` | `Min` | Starting position of the slider |
| `Callback` | `function` | `nil` | Receives the current value (`number`) while dragging |

---

## 📋 Full Example

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"
))()

local Window = Library.new("My Script Hub")

local MainTab   = Window:Tab({ Name = "Main Features" })
local PlayerTab = Window:Tab({ Name = "Player Settings" })

-- Image Button
MainTab:ImageButton({
    ImageId  = "rbxassetid://8964489619",
    Size     = 70,
    Callback = function()
        print("Clicked!")
    end
})

-- Toggle
MainTab:Toggle({
    Name     = "Auto Farm",
    Default  = false,
    Callback = function(state)
        print("Farm:", state)
    end
})

-- Slider
PlayerTab:Slider({
    Name     = "WalkSpeed",
    Min      = 16,
    Max      = 250,
    Default  = 16,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})
```

---

## 📝 Notes & Best Practices

- **Callbacks are optional** — the UI will render correctly even without them.
- **Automatic cleanup** — the library handles scaling and responsiveness automatically.
- **Glint lifecycle** — the glint effect on `ImageButton` runs in a loop; it stops automatically when the button or window is destroyed.
- **Valid assets** — ensure your `ImageId` is a valid Roblox asset ID (`rbxassetid://...`) or a direct image URL.
- **Security** — always load the library from a trusted source and verify the raw URL before execution.
- **Performance** — avoid creating excessive tabs or controls; reuse existing ones when possible.

---

## 📄 License

This project is provided as-is under the [MIT License](LICENSE). Feel free to modify and distribute.

<div align="center">

Made with 💜 for the Roblox scripting community.

</div>
