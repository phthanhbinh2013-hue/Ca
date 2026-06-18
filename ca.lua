local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/bannable-v2/Rayfield-Fix/main/Source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "🌱 Garden 2",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Auto Engine",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Config = {
    AutoBuy = false,
    AutoSell = false,
    Seeds = {}
}

local function Interact(name)
    pcall(function()
        local NPC = workspace:FindFirstChild(name, true)
        if NPC and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = NPC:GetModelCFrame() + Vector3.new(0, 0, 5)
            task.wait(0.5)
            local cd = NPC:FindFirstChildOfClass("ClickDetector")
            if cd then fireclickdetector(cd) end
        end
    end)
end

local function ForceClick(obj)
    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        pcall(function()
            for _, conn in pairs(getconnections(obj.MouseButton1Click)) do
                conn:Fire()
            end
            obj.MouseButton1Click:Fire()
        end)
    end
end

local MainTab = Window:CreateTab("Auto Farm", 4483345998)

MainTab:CreateDropdown({
    Name = "Seeds",
    Options = {"Tomato", "Carrot", "Potato", "Pumpkin", "Strawberry", "Watermelon"},
    MultipleOptions = true,
    Callback = function(v) Config.Seeds = v end,
})

MainTab:CreateToggle({
    Name = "Auto Buy Seeds (Sam)",
    Callback = function(v) Config.AutoBuy = v end
})

MainTab:CreateToggle({
    Name = "Auto Sell Crops (Steven)",
    Callback = function(v) Config.AutoSell = v end
})

task.spawn(function()
    while true do
        if Config.AutoBuy then
            Interact("sam") 
            task.wait(1)
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                for _, v in pairs(PlayerGui:GetDescendants()) do
                    if v:IsA("TextButton") then
                        for _, s in pairs(Config.Seeds) do
                            if string.find(string.lower(v.Text), string.lower(s)) then
                                ForceClick(v)
                            end
                        end
                    end
                end
            end
        end
        
        if Config.AutoSell then
            Interact("steven")
            task.wait(1)
        end
        task.wait(2)
    end
end)
