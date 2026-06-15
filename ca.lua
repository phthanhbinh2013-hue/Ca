local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🐟 Fisch Hub V2 | Rayfield Edition",
   LoadingTitle = "Loading Delta Optimizer...",
   LoadingSubtitle = "by AI Assistant",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false -- No Key Needed
})

-- VARIABLES
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

local AutoEquip = false
local AutoCast = false
local AutoReel = false

------------------------------------------------------------------------
-- TAB 1: MAIN FISHING (AUTOMATION & FIXES)
------------------------------------------------------------------------
local MainTab = Window:CreateTab("Main Fishing", "fish")

MainTab:CreateToggle({
   Name = "Auto Equip Rod",
   CurrentValue = false,
   Flag = "ToggleEquip",
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

MainTab:CreateToggle({
   Name = "Auto Perfect Cast (100% Luck)",
   CurrentValue = false,
   Flag = "ToggleCast",
   Callback = function(Value)
      AutoCast = Value
      task.spawn(function()
         while AutoCast do
            if not AutoCast then break end
            local Tool = Character:FindFirstChildOfClass("Tool")
            if Tool and Tool:FindFirstChild("Click") then
               -- Active tool casting
               Tool.Click:Activate()
               
               -- Perfect Cast Modifier (Bypasses the strength meter to get 100% Perfect)
               local Events = game:GetService("ReplicatedStorage"):FindFirstChild("events")
               if Events and Events:FindFirstChild("cast") then
                  Events.cast:FireServer(100, true) -- Sets power to maximum perfect level
               end
            end
            task.wait(2.5) -- Safe smart loop delay to prevent execution crashes
         end
      end)
   end
})

MainTab:CreateToggle({
   Name = "Instant Reel (Fast Farm)",
   CurrentValue = false,
   Flag = "ToggleReel",
   Callback = function(Value)
      AutoReel = Value
      task.spawn(function()
         while AutoReel do
            if not AutoReel then break end
            pcall(function()
               local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
               -- Checks if the mini-game bar GUI pops up on screen
               if PlayerGui:FindFirstChild("Reel") then
                  local Reel = PlayerGui.Reel
                  if Reel:FindFirstChild("Bar") then
                     local Events = game:GetService("ReplicatedStorage"):FindFirstChild("events")
                     if Events and Events:FindFirstChild("reelfinish") then
                        -- Instantly triggers successful catch event with 100% accuracy
                        Events.reelfinish:FireServer(100, true)
                     end
                  end
               end
            end)
            task.wait(0.1) -- Ultra-fast checking interval when bar appears
         end
      end)
   end
})

-- Smart Auto-Fix Background Anti-Stuck Loop
task.spawn(function()
   while true do
      task.wait(5) -- Checks every 5 seconds
      if AutoCast or AutoReel then
         pcall(function()
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            -- If fishing GUI breaks or character gets frozen in casting state
            if PlayerGui:FindFirstChild("Reel") and not Character:FindFirstChildOfClass("Tool") then
               PlayerGui.Reel:Destroy()
               if PlayerGui:FindFirstChild("Cast") then PlayerGui.Cast:Destroy() end
               Rayfield:Notify({
                  Name = "Anti-Stuck System",
                  Content = "Glitch detected! Automatically reset fishing status.",
                  Duration = 2,
                  Image = "alert-triangle"
               })
            end
         end)
      end
   end
end)

------------------------------------------------------------------------
-- TAB 2: ISLAND TELEPORT
------------------------------------------------------------------------
local TeleportTab = Window:CreateTab("Island TP", "map-pin")

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

TeleportTab:CreateDropdown({
   Name = "Select Destination Island",
   Options = IslandNames,
   CurrentOption = {SelectedIsland},
   MultipleOptions = false,
   Callback = function(Options)
      SelectedIsland = Options[1]
   end,
})

TeleportTab:CreateButton({
   Name = "Click to Teleport to Island",
   Callback = function()
      local TargetPos = Islands[SelectedIsland]
      if TargetPos and Character:FindFirstChild("HumanoidRootPart") then
         Character.HumanoidRootPart.CFrame = CFrame.new(TargetPos)
         Rayfield:Notify({
            Name = "Teleportation",
            Content = "Arrived safely at " .. SelectedIsland,
            Duration = 3,
            Image = "map-pin"
         })
      end
   end,
})

------------------------------------------------------------------------
-- TAB 3: PLAYER TELEPORT
------------------------------------------------------------------------
local PlayerTab = Window:CreateTab("Player TP", "users")
local SelectedPlayerName = ""

local function GetPlayerNames()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

local PlayerDropdown = PlayerTab:CreateDropdown({
   Name = "Select Target User Name",
   Options = GetPlayerNames(),
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Options)
      SelectedPlayerName = Options[1]
   end,
})

game.Players.PlayerAdded:Connect(function() PlayerDropdown:Refresh(GetPlayerNames()) end)
game.Players.PlayerRemoving:Connect(function() PlayerDropdown:Refresh(GetPlayerNames()) end)

PlayerTab:CreateButton({
   Name = "Teleport to Selected Player",
   Callback = function()
      if SelectedPlayerName ~= "" then
         local TargetPlayer = game.Players:FindFirstChild(SelectedPlayerName)
         if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if Character:FindFirstChild("HumanoidRootPart") then
               Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
            end
         end
      end
   end,
})

------------------------------------------------------------------------
-- TAB 4: CHARACTER MODS
------------------------------------------------------------------------
local MiscTab = Window:CreateTab("Character", "sliders")
local Noclip = false
local Fullbright = false
local WalkSpeedValue = 16
local JumpPowerValue = 50

MiscTab:CreateToggle({
   Name = "Noclip (Walk Through Walls)",
   CurrentValue = false,
   Flag = "ToggleNoclip",
   Callback = function(Value) Noclip = Value end
})

game:GetService("RunService").Stepped:Connect(function()
    if Noclip and Character then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

MiscTab:CreateToggle({
   Name = "Fullbright (Clear Night Vision)",
   CurrentValue = false,
   Flag = "ToggleBright",
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

MiscTab:CreateSlider({
   Name = "Walk Speed Customizer",
   Range = {16, 150},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SliderSpeed",
   Callback = function(Value) WalkSpeedValue = Value end,
})

MiscTab:CreateSlider({
   Name = "Jump Power Customizer",
   Range = {50, 300},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "SliderJump",
   Callback = function(Value) JumpPowerValue = Value end,
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
