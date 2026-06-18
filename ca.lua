local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/bannable-v2/Rayfield-Fix/main/Source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "🌱 Garden 2 - Safe-Turbo",
    LoadingTitle = "Initializing...",
    LoadingSubtitle = "Optimized Delay: 1.5s",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local LocalPlayer = game.Players.LocalPlayer
local Config = { AutoBuy = false, AutoSell = false, AutoSteal = false, Seeds = {}, WalkSpeed = 16, JumpPower = 50 }

local function ForceInteract(npcName)
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    local Target = workspace:FindFirstChild(npcName, true)
    if Target then
        Character.HumanoidRootPart.CFrame = Target:GetPivot() + Vector3.new(0, 0, 3)
        task.wait(1.5) -- Đã chỉnh lên 1.5s
        local Prompt = Target:FindFirstChildOfClass("ProximityPrompt", true)
        if Prompt then fireproximityprompt(Prompt) end
        local Click = Target:FindFirstChildOfClass("ClickDetector", true)
        if Click then fireclickdetector(Click) end
    end
end

task.spawn(function()
    while true do
        if Config.AutoBuy then
            ForceInteract("sam")
            task.wait(1.5) -- Đã chỉnh lên 1.5s
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                for _, v in pairs(PlayerGui:GetDescendants()) do
                    if v:IsA("TextButton") then
                        for _, s in pairs(Config.Seeds) do
                            if v.Text:lower():find(s:lower()) then
                                pcall(function() v.MouseButton1Click:Fire() end)
                            end
                        end
                    end
                end
            end
        end
        
        if Config.AutoSell then
            ForceInteract("steven")
            task.wait(1.5) -- Đã chỉnh lên 1.5s
        end

        if Config.AutoSteal then
            local success = false
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 5)
                    task.wait(1.5) -- Delay di chuyển an toàn
                    success = true; break 
                end
            end
            task.wait(1.5) -- Delay sau khi cố trộm
        end
        task.wait(1.5) -- Delay chung cho vòng lặp
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Config.JumpPower
    end
end)
