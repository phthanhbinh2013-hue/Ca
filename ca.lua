local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🐟 Fisch Hub V3.1 | 8s Delay Cast",
   LoadingTitle = "Optimizing Timers for Delta...",
   LoadingSubtitle = "by AI Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- VARIABLES & REPLICATED STORAGE REFS
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- FARMING STATES
local AutoEquip = false
local AutoCast = false
local AutoShake = false
local AutoReel = false
local MultiCast = false

------------------------------------------------------------------------
-- TAB 1: AUTO FARM (UPDATED 8-SECOND CAST LOGIC)
------------------------------------------------------------------------
local MainTab = Window:CreateTab("Auto Farm", "fish")

MainTab:CreateToggle({
   Name = "Auto Equip Fishing Rod",
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
            task.wait(0.8)
         end
      end)
   end
})

MainTab:CreateToggle({
   Name = "Auto Perfect Cast (8-Second Recast Loop)",
   CurrentValue = false,
   Flag = "ToggleCast",
   Callback = function(Value)
      AutoCast = Value
      task.spawn(function()
         while AutoCast do
            if not AutoCast then break end
            local Tool = Character:FindFirstChildOfClass("Tool")
            if Tool and Tool:FindFirstChild("Click") then
               -- Activate rod clicking
               Tool.Click:Activate()
               
               local CastEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("cast")
               if CastEvent then
                  -- Execute 100% Perfect Cast or Spam Packets based on toggle
                  local loopCount = MultiCast and 3 or 1
                  for i = 1, loopCount do
                     CastEvent:FireServer(100, true)
                     if MultiCast then task.wait(0.1) end
                  end
               end
            end
            -- Strictly wait for exactly 8 seconds before resetting and throwing a new rod
            task.wait(8.0)
         end
      end)
   end
})

MainTab:CreateToggle({
   Name = "Enable Multi-Cast Bait (Spam Packets)",
   CurrentValue = false,
   Flag = "ToggleMultiCast",
   Callback = function(Value)
      MultiCast = Value
   end
})

MainTab:CreateToggle({
   Name = "Auto Shake UI (Anti-Stuck Clicker)",
   CurrentValue = false,
   Flag = "ToggleShake",
   Callback = function(Value)
      AutoShake = Value
      task.spawn(function()
         while AutoShake do
            if not AutoShake then break end
            pcall(function()
               local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
               if PlayerGui:FindFirstChild("Shake") then
                  local ShakeUI = PlayerGui.Shake
                  if ShakeUI:FindFirstChild("button") and ShakeUI.button.Visible then
                     local SafeEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("shake")
                     if SafeEvent then
                        SafeEvent:FireServer()
                     end
                  end
               end
            end)
            task.wait(0.05)
         end
      end)
   end
})

MainTab:CreateToggle({
   Name = "Instant Reel (Instant Reward)",
   CurrentValue = false,
   Flag = "ToggleReel",
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
                     local ReelFinishEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("reelfinish")
                     if ReelFinishEvent then
                        ReelFinishEvent:FireServer(100, true)
                     end
                  end
               end
            end)
            task.wait(0.1)
         end
      end)
   end
})

-- BACKGROUND ENGINE AUTO-CLEANER
task.spawn(function()
   while true do
      task.wait(4)
      if AutoCast or AutoReel or AutoShake then
         pcall(function()
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            if PlayerGui:FindFirstChild("Reel") and not Character:FindFirstChildOfClass("Tool") then
               PlayerGui.Reel:Destroy()
               if PlayerGui:FindFirstChild("Cast") then PlayerGui.Cast:Destroy() end
               if PlayerGui:FindFirstChild("Shake") then PlayerGui.Shake:Destroy() end
            end
         end)
      end
   end
end)

------------------------------------------------------------------------
-- TAB 2: VISUAL DETECTORS (ISLAND, PLAYER & NPC ESP)
------------------------------------------------------------------------
local VisualsTab = Window:CreateTab("Visual ESP", "eye")
local ESP_Objects = {}

local function CreateESPLabel(target, name, color)
   if ESP_Objects[target] then return end
   
   local Billboard = Instance.new("BillboardGui")
   Billboard.Size = UDim2.new(0, 200, 0, 50)
   Billboard.AlwaysOnTop = true
   Billboard.Adornee = target
   
   local Label = Instance.new("TextLabel")
   Label.Size = UDim2.new(1, 0, 1, 0)
   Label.BackgroundTransparency = 1
   Label.TextColor3 = color
   Label.TextStrokeTransparency = 0.2
   Label.TextSize = 14
   Label.Font = Enum.Font.SourceSansBold
   Label.Text = name
   Label.Parent = Billboard
   
   Billboard.Parent = target
   ESP_Objects[target] = Billboard
end

local function ClearAllESP()
   for target, gui in pairs(ESP_Objects) do
      if gui then gui:Destroy() end
   end
   table.clear(ESP_Objects)
end

VisualsTab:CreateToggle({
   Name = "Show Islands, Players & NPCs Name (ESP)",
   CurrentValue = false,
   Flag = "ToggleESP",
   Callback = function(Value)
      if Value then
         for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
               CreateESPLabel(p.Character.HumanoidRootPart, "[Player] " .. p.Name, Color3.fromRGB(0, 255, 255))
            end
         end
         
         local IslandsFolder = workspace:FindFirstChild("Islands") or workspace:FindFirstChild("World")
         if IslandsFolder then
            for _, island in pairs(IslandsFolder:GetChildren()) do
               if island:IsA("BasePart") or island:FindFirstChildOfClass("BasePart") then
                  local targetPart = island:IsA("BasePart") and island or island:FindFirstChildOfClass("BasePart")
                  CreateESPLabel(targetPart, "[Island] " .. island.Name, Color3.fromRGB(255, 255, 0))
               end
            end
         end
         
         local NPCsFolder = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("WorldNPCs")
         if NPCsFolder then
            for _, npc in pairs(NPCsFolder:GetChildren()) do
               if npc:FindFirstChild("HumanoidRootPart") then
                  CreateESPLabel(npc.HumanoidRootPart, "[NPC] " .. npc.Name, Color3.fromRGB(0, 255, 0))
               end
            end
         end
      else
         ClearAllESP()
      end
   end
})

------------------------------------------------------------------------
-- TAB 3: ISLAND TELEPORT
------------------------------------------------------------------------
local TeleportTab = Window:CreateTab("Island TP", "map-pin")

local IslandsData = {
    ["Moosewood (Starter)"] = Vector3.new(370, 134, 250),
    ["Snowcap Island"] = Vector3.new(2622, 135, 2380),
    ["Roslit Volcano"] = Vector3.new(-1800, 140, -800),
    ["Coral Reef"] = Vector3.new(-200, 120, 1200),
    ["Sunken Ship"] = Vector3.new(2900, 115, -1700),
}

local IslandList = {}
for name, _ in pairs(IslandsData) do table.insert(IslandList, name) end
local SelectedIsland = "Moosewood (Starter)"

TeleportTab:CreateDropdown({
   Name = "Select Destination Island",
   Options = IslandList,
   CurrentOption = {SelectedIsland},
   MultipleOptions = false,
   Callback = function(Options) SelectedIsland = Options[1] end,
})

TeleportTab:CreateButton({
   Name = "Click to Teleport to Island",
   Callback = function()
      local TargetPos = IslandsData[SelectedIsland]
      if TargetPos and Character:FindFirstChild("HumanoidRootPart") then
         Character.HumanoidRootPart.CFrame = CFrame.new(TargetPos)
      end
   end,
})

------------------------------------------------------------------------
-- TAB 4: PLAYER TELEPORT
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
   Callback = function(Options) SelectedPlayerName = Options[1] end,
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
-- TAB 5: CHARACTER MODS
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

RunService.Stepped:Connect(function()
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
