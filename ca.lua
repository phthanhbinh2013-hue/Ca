local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🐟 NeonFish Ultimate Mobile V6",
   LoadingTitle = "Optimizing Mobile Garbage Collector...",
   LoadingSubtitle = "Secure Mobile Framework Active",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- CORE SYSTEMS & REPLICATED STORAGE REFS
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- GLOBAL AUTOMATION STATES
local AutoEquip = false
local AutoCast = false
local AutoShake = false
local MultiCast = false
local FishingSpeedMode = "Instant" 

-- ESP MEMORY ARRAYS
local PlayerESP_Storage = {}
local IslandESP_Storage = {}
local NpcESP_Storage = {}

------------------------------------------------------------------------
-- 🛡️ ADVANCED MOBILE ANTI-BAN & MEMORY SPOOFER (FIXED & SECURED)
------------------------------------------------------------------------
local RawMetatable = getrawmetatable(game)
local OldIndex = RawMetatable.__index
setreadonly(RawMetatable, false)

RawMetatable.__index = newcclosure(function(self, key)
    if not checkcaller() and self:IsA("Humanoid") then
        if key == "WalkSpeed" then return 16 end
        if key == "JumpPower" then return 50 end
    end
    return OldIndex(self, key)
end)
setreadonly(RawMetatable, true)

-- Admin Detect Watchdog (Security Event)
RunService.Heartbeat:Connect(function()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player:IsInGroup(game.CreatorId) or (player.AccountAge < 1 and player ~= LocalPlayer) then
                Rayfield:Notify({
                    Name = "⚠️ ANTI-STAFF PROTECTION",
                    Content = "Staff or Alt detected: " .. player.Name .. ". Play safely!",
                    Duration = 3,
                    Image = "shield-alert"
                })
            end
        end
    end)
end)

-- MOBILE PERFORMANCE OPTIMIZER (Garbage Collection & Memory Cleaner)
task.spawn(function()
    while task.wait(10) do
        -- Periodically forces unused memory release to prevent mobile client crashes
        setfpscap(60)
        collectgarbage("collect")
    end
end)

------------------------------------------------------------------------
-- TAB 1: PERFECT FISHING ENGINE (DUAL METHOD MOBILE EXCLUSIVE)
------------------------------------------------------------------------
local MainTab = Window:CreateTab("Neon Fishing", "fish")

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
            task.wait(0.6)
         end
      end)
   end
})

MainTab:CreateToggle({
   Name = "Auto Perfect Cast (8s Recast Delay)",
   CurrentValue = false,
   Flag = "ToggleCast",
   Callback = function(Value)
      AutoCast = Value
      task.spawn(function()
         while AutoCast do
            if not AutoCast then break end
            local Tool = Character:FindFirstChildOfClass("Tool")
            if Tool and Tool:FindFirstChild("Click") then
               Tool.Click:Activate()
               
               local CastEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("cast")
               if CastEvent then
                  local loopCount = MultiCast and 3 or 1
                  for i = 1, loopCount do
                     CastEvent:FireServer(100, true)
                     if MultiCast then task.wait(0.08) end
                  end
               end
            end
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
            task.wait(0.03 + math.random(0, 15) / 1000) -- Safe random interval for mobile CPU stability
         end
      end)
   end
})

MainTab:CreateDropdown({
   Name = "Select Fishing Speed Mode",
   Options = {"Instant", "Legit Perfect Center"},
   CurrentOption = {"Instant"},
   MultipleOptions = false,
   Callback = function(Options)
      FishingSpeedMode = Options[1]
   end,
})

-- MOBILE HIGH-PRECISION DUAL-MODE REEL LOOPER
RunService.Heartbeat:Connect(function()
    pcall(function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        if PlayerGui:FindFirstChild("Reel") then
            local Reel = PlayerGui.Reel
            local Bar = Reel:FindFirstChild("Bar")
            local FishTarget = Reel:FindFirstChild("Fish")
            
            if Bar then
               local ReelFinishEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("reelfinish")
               
               if FishingSpeedMode == "Instant" then
                  -- Mode 1: Instant Server Teleportation Catch
                  if ReelFinishEvent then
                     ReelFinishEvent:FireServer(100, true)
                  end
               elseif FishingSpeedMode == "Legit Perfect Center" and FishTarget then
                  -- Mode 2: Perfect Mathematical Center Tracking (Zero Failures)
                  -- Keeps the fish precisely centered inside the player's catch bar
                  Bar.Position = UDim2.new(FishTarget.Position.X.Scale, 0, FishTarget.Position.Y.Scale, 0)
                  
                  if ReelFinishEvent then
                     ReelFinishEvent:FireServer(100, false)
                  end
               end
            end
         end
    end)
end)

-- ABSOLUTE STUCK FIX CLEANER ENGINE
task.spawn(function()
   while true do
      task.wait(4)
      pcall(function()
         local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
         if PlayerGui:FindFirstChild("Reel") and not Character:FindFirstChildOfClass("Tool") then
            PlayerGui.Reel:Destroy()
            if PlayerGui:FindFirstChild("Cast") then PlayerGui.Cast:Destroy() end
            if PlayerGui:FindFirstChild("Shake") then PlayerGui.Shake:Destroy() end
         end
      end)
   end
end)

------------------------------------------------------------------------
-- TAB 2: SEPARATED ADVANCED VISUAL REPLICATOR (MOBILE OPTIMIZED ESP)
------------------------------------------------------------------------
local VisualsTab = Window:CreateTab("Visual Monitors", "eye")

local function GenerateLabel(target, name, color, storage)
   if storage[target] then return end
   
   local Billboard = Instance.new("BillboardGui")
   Billboard.Size = UDim2.new(0, 180, 0, 45) -- Scaled down down for mobile layouts
   Billboard.AlwaysOnTop = true
   Billboard.Adornee = target
   
   local Label = Instance.new("TextLabel")
   Label.Size = UDim2.new(1, 0, 1, 0)
   Label.BackgroundTransparency = 1
   Label.TextColor3 = color
   Label.TextStrokeTransparency = 0.3
   Label.TextSize = 11 -- Optimized text scaling
   Label.Font = Enum.Font.SourceSansBold
   Label.Text = name
   Label.Parent = Billboard
   
   Billboard.Parent = target
   storage[target] = Billboard
end

VisualsTab:CreateToggle({
   Name = "ESP Tracker: Show Active Players",
   CurrentValue = false,
   Flag = "TogglePlayerESP",
   Callback = function(Value)
      if Value then
         task.spawn(function()
            while task.wait(3) do -- Increased wait step to reduce CPU latency on mobile
               if not Value then break end
               for _, p in pairs(Players:GetPlayers()) do
                  if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                     GenerateLabel(p.Character.HumanoidRootPart, "[Player] " .. p.Name, Color3.fromRGB(0, 240, 255), PlayerESP_Storage)
                  end
               end
            end
         end)
      else
         for target, gui in pairs(PlayerESP_Storage) do if gui then gui:Destroy() end end
         table.clear(PlayerESP_Storage)
      end
   end
})

VisualsTab:CreateToggle({
   Name = "ESP Tracker: Show Islands Name",
   CurrentValue = false,
   Flag = "ToggleIslandESP",
   Callback = function(Value)
      if Value then
         local RootTargets = {workspace, workspace:FindFirstChild("World"), workspace:FindFirstChild("Islands")}
         for _, layer in pairs(RootTargets) do
            if layer then
               for _, obj in pairs(layer:GetChildren()) do
                  if obj:IsA("BasePart") or obj:FindFirstChildOfClass("BasePart") then
                     local node = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                     if obj.Name:lower():find("island") or obj.Name:lower():find("zone") or obj.Name == "Moosewood" then
                        GenerateLabel(node, "[Island] " .. obj.Name, Color3.fromRGB(255, 230, 0), IslandESP_Storage)
                     end
                  end
               end
            end
         end
      else
         for target, gui in pairs(IslandESP_Storage) do if gui then gui:Destroy() end end
         table.clear(IslandESP_Storage)
      end
   end
})

VisualsTab:CreateToggle({
   Name = "ESP Tracker: Show NPCs Vendor",
   CurrentValue = false,
   Flag = "ToggleNpcESP",
   Callback = function(Value)
      if Value then
         local NpcLayer = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("WorldNPCs")
         if NpcLayer then
            for _, npc in pairs(NpcLayer:GetChildren()) do
               if npc:FindFirstChild("HumanoidRootPart") then
                  GenerateLabel(npc.HumanoidRootPart, "[NPC] " .. npc.Name, Color3.fromRGB(50, 255, 50), NpcESP_Storage)
               end
            end
         end
      else
         for target, gui in pairs(NpcESP_Storage) do if gui then gui:Destroy() end end
         table.clear(NpcESP_Storage)
      end
   end
})

------------------------------------------------------------------------
-- TAB 3: ISLAND TELEPORT INTERFACE
------------------------------------------------------------------------
local TeleportTab = Window:CreateTab("Island Map TP", "map-pin")

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
   Name = "Select Coordinates Target",
   Options = IslandList,
   CurrentOption = {SelectedIsland},
   MultipleOptions = false,
   Callback = function(Options) SelectedIsland = Options[1] end,
 })

TeleportTab:CreateButton({
   Name = "Execute Warp to Island Vector",
   Callback = function()
      local TargetPos = IslandsData[SelectedIsland]
      if TargetPos and Character:FindFirstChild("HumanoidRootPart") then
         Character.HumanoidRootPart.CFrame = CFrame.new(TargetPos)
      end
   end,
})

------------------------------------------------------------------------
-- TAB 4: ACTIVE SERVERS USER WARP
------------------------------------------------------------------------
local PlayerTab = Window:CreateTab("Target User TP", "users")
local SelectedPlayerName = ""

local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

local PlayerDropdown = PlayerTab:CreateDropdown({
   Name = "Select Target Profile Identity",
   Options = GetPlayerNames(),
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Options) SelectedPlayerName = Options[1] end,
})

Players.PlayerAdded:Connect(function() PlayerDropdown:Refresh(GetPlayerNames()) end)
Players.PlayerRemoving:Connect(function() PlayerDropdown:Refresh(GetPlayerNames()) end)

PlayerTab:CreateButton({
   Name = "Execute Teleport to Target Vector",
   Callback = function()
      if SelectedPlayerName ~= "" then
         local TargetPlayer = Players:FindFirstChild(SelectedPlayerName)
         if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if Character:FindFirstChild("HumanoidRootPart") then
               Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
         end
      end
   end,
})

------------------------------------------------------------------------
-- TAB 5: CHARACTER UTILITIES MOD
------------------------------------------------------------------------
local MiscTab = Window:CreateTab("Character Hack", "sliders")
local Noclip = false
local Fullbright = false
local WalkSpeedValue = 16
local JumpPowerValue = 50

MiscTab:CreateToggle({
   Name = "Noclip Status (Phase Through Collisions)",
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
   Name = "Fullbright Status (Permanent Light Vision)",
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
   Name = "Velocity Walk Speed Modifier",
   Range = {16, 150},
   Increment = 1,
   Suffix = "WalkSpeed",
   CurrentValue = 16,
   Flag = "SliderSpeed",
   Callback = function(Value) WalkSpeedValue = Value end,
})

MiscTab:CreateSlider({
   Name = "Velocity Jump Height Modifier",
   Range = {50, 300},
   Increment = 1,
   Suffix = "JumpPower",
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
