local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "🐟 Fisch Hub | Delta Version",
    SubTitle = "No Key Needed",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 400),
    Acrylic = false, -- Tắt Acrylic để Delta chạy mượt hơn, không bị lag máy
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Auto Fish", Icon = "fish" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Player", Icon = "user" })
}

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

------------------------------------------------------------------------
-- TAB 1: AUTO FISH
------------------------------------------------------------------------
Tabs.Main:AddParagraph({
    Title = "Instructions",
    Content = "Please hold your fishing rod before enabling Auto Features!"
})

local AutoCast = false
local AutoReel = false

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

Tabs.Main:AddToggle("AutoReel", {
    Title = "Instant Reel (Fast Fish)",
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
                task.wait(0.2) -- Tăng một chút thời gian chờ để Delta không bị quá tải
            end
        end)
    end
})

------------------------------------------------------------------------
-- TAB 2: ISLAND TELEPORT
------------------------------------------------------------------------
local Islands = {
    ["Moosewood (Starter Island)"] = Vector3.new(370, 134, 250),
    ["Snowcap Island"] = Vector3.new(2622, 135, 2380),
    ["Roslit Volcano"] = Vector3.new(-1800, 140, -800),
    ["Coral Reef"] = Vector3.new(-200, 120, 1200),
    ["Sunken Ship"] = Vector3.new(2900, 115, -1700),
}

local IslandNames = {}
for name, _ in pairs(Islands) do
    table.insert(IslandNames, name)
end

Tabs.Teleport:AddDropdown("IslandDropdown", {
    Title = "Select Destination Island",
    Values = IslandNames,
    CurrentValue = "Moosewood (Starter Island)",
    Callback = function(Value)
        local TargetPos = Islands[Value]
        if TargetPos and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = CFrame.new(TargetPos)
            Fluent:Notify({
                Title = "Teleportation",
                Content = "Successfully arrived at: " .. Value,
                Duration = 3
            })
        end
    end
})

------------------------------------------------------------------------
-- TAB 3: WALK SPEED & JUMP POWER
------------------------------------------------------------------------
local WalkSpeedValue = 16
Tabs.Misc:AddSlider("SpeedSlider", {
    Title = "Walk Speed",
    Description = "Default speed is 16",
    Min = 16,
    Max = 150,
    Default = 16,
    Rounding = 0,
    Callback = function(Value)
        WalkSpeedValue = Value
    end
})

local JumpPowerValue = 50
Tabs.Misc:AddSlider("JumpSlider", {
    Title = "Jump Power",
    Description = "Default power is 50",
    Min = 50,
    Max = 300,
    Default = 50,
    Rounding = 0,
    Callback = function(Value)
        JumpPowerValue = Value
    end
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
