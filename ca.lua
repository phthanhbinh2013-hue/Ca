local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/bannable-v2/Rayfield-Fix/main/Source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "🌱 Garden 2 - Hardcore Interaction",
    LoadingTitle = "Loading Text Scanner Engine...",
    LoadingSubtitle = "Rayfield Premium v5",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local FarmSettings = {
    AutoBuyAndPlant = false,
    AutoSell = false,
    SelectedSeeds = {}
}

local function InteractWithNPC(npcName)
    pcall(function()
        local Character = LocalPlayer.Character
        local NPC = workspace:FindFirstChild(npcName, true) or workspace.NPCs:FindFirstChild(npcName)
        
        if NPC and Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = NPC:GetModelCFrame() * CFrame.new(0, 0, 3)
            task.wait(0.3)
            
            local Prompt = NPC:FindFirstChildOfClass("ProximityPrompt") or NPC:FindFirstChild("ProximityPrompt", true)
            if Prompt then
                fireproximityprompt(Prompt)
            end
            task.wait(0.5)
            
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        local DialogueBtn = gui:FindFirstChild("Option1", true) or gui:FindFirstChild("Next", true) or gui:FindFirstChild("Button", true)
                        if DialogueBtn and DialogueBtn.Visible then
                            local x, y = DialogueBtn.AbsolutePosition.X + (DialogueBtn.AbsoluteSize.X / 2), DialogueBtn.AbsolutePosition.Y + (DialogueBtn.AbsoluteSize.Y / 2)
                            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
                            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
                            break
                        end
                    end
                end
            end
        end
    end)
end

local function ScanAndBuySeeds()
    pcall(function()
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not PlayerGui then return end
        
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                local ShopFrame = gui:FindFirstChild("Shop") or gui:FindFirstChild("Seeds") or gui:FindFirstChild("Frame", true)
                if ShopFrame and ShopFrame.Visible then
                    
                    for _, item in pairs(ShopFrame:GetDescendants()) do
                        if item:IsA("TextLabel") or item:IsA("TextBox") then
                            local textLower = string.lower(item.Text)
                            
                            for seedName, isSelected in pairs(FarmSettings.SelectedSeeds) do
                                if isSelected and string.find(textLower, string.lower(seedName)) then
                                    local ClickTarget = item:FindFirstChildOfClass("TextButton") or item.Parent:FindFirstChildOfClass("TextButton") or item
                                    if ClickTarget then
                                        local x = ClickTarget.AbsolutePosition.X + (ClickTarget.AbsoluteSize.X / 2)
                                        local y = ClickTarget.AbsolutePosition.Y + (ClickTarget.AbsoluteSize.Y / 2)
                                        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
                                        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
                                        task.wait(0.2)
                                    end
                                end
                            end
                            
                        end
                    end
                    
                end
            end
        end
    end)
end

local MainTab = Window:CreateTab("Auto Economy", 4483345998)

MainTab:CreateDropdown({
    Name = "Chọn Nhiều Loại Hạt Giống",
    Options = {"Tomato", "Carrot", "Potato", "Pumpkin", "Strawberry", "Watermelon"},
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        FarmSettings.SelectedSeeds = {}
        for _, seed in pairs(Options) do
            FarmSettings.SelectedSeeds[seed] = true
        end
    end,
})

MainTab:CreateToggle({
    Name = "🛒 Auto Buy Selected Seeds",
    CurrentValue = false,
    Callback = function(v) FarmSettings.AutoBuyAndPlant = v end,
})

MainTab:CreateToggle({
    Name = "💰 Auto Sell Crops",
    CurrentValue = false,
    Callback = function(v) FarmSettings.AutoSell = v end
})

task.spawn(function()
    while true do
        if FarmSettings.AutoBuyAndPlant then
            InteractWithNPC("Seed") 
            task.wait(0.5)
            ScanAndBuySeeds()
            task.wait(1)
        end
        
        if FarmSettings.AutoSell then
            InteractWithNPC("Sell")
            task.wait(1.5)
        end
        task.wait(1)
    end
end)
