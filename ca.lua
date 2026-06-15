local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Initialize UI Window
local Window = Fluent:CreateWindow({
    Title = "🐟 Fisch Hub | Premium Delta",
    SubTitle = "No Key Needed",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Fishing", Icon = "fish" }),
    Teleport = Window:AddTab({ Title = "Island TP", Icon = "map-pin" }),
    Players = Window:AddTab({ Title = "Player TP", Icon = "users" }),
    Misc = Window:AddTab({ Title = "Character", Icon = "sliders" }),
    Settings = Window:AddTab({ Title = "Language", Icon = "settings" })
}

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Language = "EN"

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

local LangText = {
    VN = {
        fix_msg = "Đã reset trạng thái câu cá để sửa lỗi kẹt!",
        notify_tp = "Đã dịch chuyển đến: "
    },
    EN = {
        fix_msg = "Fishing status reset to fix glitch!",
        notify_tp = "Teleported to: "
    }
}

------------------------------------------------------------------------
-- TAB: LANGUAGE SETTINGS
------------------------------------------------------------------------
Tabs.Settings:AddDropdown("LangDropdown", {
    Title = "Select Menu Language",
    Values = {"English", "Tiếng Việt"},
    CurrentValue = "English",
    Callback = function(Value)
        if Value == "Tiếng Việt" then
            Language = "VN"
        else
            Language = "EN"
        end
        Fluent:Notify({
            Title = "Language Status",
            Content = Language == "EN" and "Language set to English!" or "Đã chuyển sang Tiếng Việt!",
            Duration = 2
        })
    end
})

------------------------------------------------------------------------
-- TAB 1: AUTO FISHING & FIX SYSTEM
------------------------------------------------------------------------
local AutoEquip = false
local AutoCast = false
local AutoReel = false

-- 1. Auto Equip Rod
Tabs.Main:AddToggle("AutoEquip", {
    Title = "Auto Equip Fishing Rod",
    Default = false,
    Callback = function(Value)
        AutoEquip = Value
        task.spawn(function()
            while AutoEquip do
                if not AutoEquip then break end
                if not Character:FindFirstChildOfClass("Tool") then
                    local Backpack = LocalPlayer:FindFirstChild("Backpack")
                    if Backpack then
                        for _, tool in pairs(Backpack:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:lower():find("rod") or tool:FindFirstChild("Click")) then
                                Character.Humanoid:EquipTool(tool)
                                break
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

-- 2. Fix Auto Fishing Glitch Button
Tabs.Main:AddButton({
    Title = "Fix Auto Fishing Glitch",
    Callback = function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        if PlayerGui:FindFirstChild("Reel") then PlayerGui.Reel:Destroy() end
        if PlayerGui:FindFirstChild("Cast") then PlayerGui.Cast:Destroy() end
        AutoCast = false
        AutoReel = false
        Fluent:Notify({Title = "System Fix", Content = LangText[Language].fix_msg, Duration = 2})
    end
})

-- 3. Auto Cast Rod
Tabs.Main:AddToggle("AutoCast", {
    Title = "Auto Cast Rod",
    Default = false,
    Callback = function(Value)
        AutoCast = Value
        task.spawn(function()
            while AutoCast do
                if not AutoCast then break end
                local Tool = Character:FindFirstChildOfClass("Tool")
                if Tool and Tool:FindFirstChild("Click") then
                    Tool.Click:Activate()
                end
                task.wait(1.5)
            end
        end)
    end
})

-- 4. Instant Reel
Tabs.Main:AddToggle("AutoReel", {
    Title = "Instant Reel (Fast Catch)",
    Default = false,
    Callback = function(Value)
        AutoReel = Value
        task.spawn(function()
            while AutoReel do
                if not AutoReel then break end
                pcall(function()
                    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
                    if PlayerGui:FindFirstChild("Reel") then
                        local Reel = PlayerGui.Reel
                        if Reel:FindFirstChild("Bar") then
                            local Events = game:GetService("ReplicatedStorage"):FindFirstChild("events")
                            if Events and Events:FindFirstChild("reelfinish") then
                                Events.reelfinish:FireServer(100, true)
                            end
                        end
                    end
                end)
                task.wait(0.2)
            end
        end)
    end
})

------------------------------------------------------------------------
-- TAB 2: ISLAND TELEPORT SYSTEM
------------------------------------------------------------------------
local Islands = {
    ["Moosewood (Starter)"] = Vector3.new(370, 134, 250),
    ["Snowcap Island"] = Vector3.new(2622, 135, 2380),
    ["Roslit Volcano"] = Vector3.new(-1800, 140, -800),
    ["Coral Reef"] = Vector3.new(-200, 120, 1200),
    ["Sunken Ship"] = Vector3.new(2900, 115, -1700),
}

local IslandNames = {}
for name, _ in pairs(Islands) do table.insert(IslandNames, name) end

local SelectedIsland = "Moosewood (Starter)"

Tabs.Teleport:AddDropdown("IslandDropdown", {
    Title = "Select Destination Island",
    Values = IslandNames,
    CurrentValue = SelectedIsland,
    Callback = function(Value)
        SelectedIsland = Value
    end
})

Tabs.Teleport:AddButton({
    Title = "Click to Teleport to Island",
    Callback = function()
        local TargetPos = Islands[SelectedIsland]
        if TargetPos and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = CFrame.new(TargetPos)
            Fluent:Notify({Title = "Teleportation", Content = LangText[Language].notify_tp .. SelectedIsland, Duration = 3})
        end
    end
})

------------------------------------------------------------------------
-- TAB 3: PLAYER TELEPORT SYSTEM (SCANNER)
------------------------------------------------------------------------
local SelectedPlayerName = ""

local function GetPlayerNames()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local PlayerDropdown = Tabs.Players:AddDropdown("PlayerDropdown", {
    Title = "Select Target User Name",
    Values = GetPlayerNames(),
    CurrentValue = "",
    Callback = function(Value)
        SelectedPlayerName = Value
    end
})

game.Players.PlayerAdded:Connect(function() PlayerDropdown:SetValues(GetPlayerNames()) end)
game.Players.PlayerRemoving:Connect(function() PlayerDropdown:SetValues(GetPlayerNames()) end)

Tabs.Players:AddButton({
    Title = "Teleport to Selected Player",
    Callback = function()
        if SelectedPlayerName ~= "" then
            local TargetPlayer = game.Players:FindFirstChild(SelectedPlayerName)
            if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if Character:FindFirstChild("HumanoidRootPart") then
                    Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
                    Fluent:Notify({Title = "Player Teleport", Content = LangText[Language].notify_tp .. SelectedPlayerName, Duration = 3})
                end
            end
        end
    end
})

------------------------------------------------------------------------
-- TAB 4: NOCLIP, FULLBRIGHT, SPEED, JUMP
------------------------------------------------------------------------
local Noclip = false
local Fullbright = false
local WalkSpeedValue = 16
local JumpPowerValue = 50

-- 1. Noclip (Walk Through Walls)
Tabs.Misc:AddToggle("NoclipToggle", {
    Title = "Noclip (Walk Through Walls)",
    Default = false,
    Callback = function(Value)
        Noclip = Value
    end
})

game:GetService("RunService").Stepped:Connect(function()
    if Noclip and Character then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 2. Fullbright (Night Vision)
Tabs.Misc:AddToggle("BrightToggle", {
    Title = "Fullbright (Clear Night Vision)",
    Default = false,
    Callback = function(Value)
        Fullbright = Value
        if Fullbright then
            game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").Brightness = 2
        else
            game:GetService("Lighting").Ambient = Color3.fromRGB(130, 130, 130)
        end
    end
})

-- 3. Speed & Jump Power Sliders
Tabs.Misc:AddSlider("SpeedSlider", {
    Title = "Walk Speed Customizer",
    Min = 16, Max = 150, Default = 16, Rounding = 0,
    Callback = function(Value) WalkSpeedValue = Value end
})

Tabs.Misc:AddSlider("JumpSlider", {
    Title = "Jump Power Customizer",
    Min = 50, Max = 300, Default = 50, Rounding = 0,
    Callback = function(Value) JumpPowerValue = Value end
})

task.spawn(function()
    while true do
        pcall(function()
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.WalkSpeed = WalkSpeedValue
                Character.Humanoid.JumpPower = JumpPowerValue
                Character.Humanoid.UseJumpPower = true
            end
        end)
        task.wait(0.5)
    end
end)

Window:SelectTab(1)
