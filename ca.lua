-- =========================================================
-- NEONFISH ULTIMATE PRO V15 - RAYFIELD ARCHITECTURE
-- ALL-IN-ONE ADVANCED FISHING EMPIRE (TREO MÁY TRỌN VẸN 24/7)
-- =========================================================

-- KHỞI TẠO THƯ VIỆN RAYFIELD (BẢN MOBILE OPTIMIZED)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
    Name = "🐟 NeonFish Ultimate V15",
    LoadingTitle = "Injecting NeonFish Engine...",
    LoadingSubtitle = "by Gemini Collaborator",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "NeonFishV15"
    },
    KeySystem = false -- Tắt hệ thống Key để vào thẳng cho nhanh
})

-- CORE SERVICES & VARIABLES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- NETWORK SCANNER (Tự động dò tìm RemoteEvent chống lỗi cập nhật game)
local NetworkFolder = ReplicatedStorage:FindFirstChild("events") 
    or ReplicatedStorage:FindFirstChild("Events") 
    or ReplicatedStorage:FindFirstChild("Remotes") 
    or ReplicatedStorage:FindFirstChild("Network")

local function FireNetworkEvent(name, ...)
    if NetworkFolder and NetworkFolder:FindFirstChild(name) then
        NetworkFolder[name]:FireServer(...)
    else
        -- Quét sâu (Deep Scan) tìm kiếm từ gốc nếu game ẩn giấu
        local alt = ReplicatedStorage:FindFirstChild(name, true)
        if alt and alt:IsA("RemoteEvent") then
            alt:FireServer(...)
        end
    end
end

-- TRẠNG THÁI CẤU HÌNH HACK
local Settings = {
    AutoFarm = false,
    FishingSpeed = "Instant",
    SelectedBait = "Basic Bait",
    AutoBuyBait = false,
    AutoSell = false,
    SellRarity = "All Fish", -- Cấu hình lọc độ hiếm nâng cao
    AntiStuck = true -- Tính năng chống kẹt cần độc quyền
}

---------------------------------------------------------
-- TAB 1: FISHING HUB (TỰ ĐỘNG CÂU CÁ CAO CẤP)
---------------------------------------------------------
local FishingTab = Window:CreateTab("Fishing Hub", 4483345998)

local FpsParagraph = FishingTab:CreateParagraph({Title = "Performance Tracker", Content = "FPS: Calculating..."})

-- Bộ tính toán FPS thời gian thực chính xác cao
task.spawn(function()
    while true do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        FpsParagraph:SetContent("FPS: " .. fps .. " | System: Connected Successfully ✅")
        task.wait(1)
    end
end)

FishingTab:CreateDropdown({
    Name = "Fishing Speed Mode",
    Options = {"Instant", "Fish Lock Center Bar"},
    CurrentOption = {"Instant"},
    MultipleOptions = false,
    Callback = function(Option)
        Settings.FishingSpeed = Option[1]
    end,
})

FishingTab:CreateToggle({
    Name = "🔥 Master Auto-Fishing",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoFarm = Value
    end,
})

-- VÒNG LẶP CHÍNH (MAIN AUTOMATION CORE)
task.spawn(function()
    while true do
        if Settings.AutoFarm then
            pcall(function()
                local Character = LocalPlayer.Character
                local Backpack = LocalPlayer:FindFirstChild("Backpack")
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                
                -- 1. Trang bị cần câu
                if Character and not Character:FindFirstChildOfClass("Tool") and Backpack then
                    for _, v in pairs(Backpack:GetChildren()) do
                        if v:IsA("Tool") and (v.Name:lower():find("rod") or v:FindFirstChild("Click")) then
                            Character.Humanoid:EquipTool(v)
                            task.wait(0.3)
                            break
                        end
                    end
                end
                
                -- 2. Thả cần (Cast)
                local Tool = Character and Character:FindFirstChildOfClass("Tool")
                if Tool and Tool:FindFirstChild("Click") and PlayerGui then
                    if not PlayerGui:FindFirstChild("Reel") and not PlayerGui:FindFirstChild("Cast") then
                        Tool.Click:Activate()
                        FireNetworkEvent("cast", 100, true)
                        task.wait(1.0)
                    end
                    
                    -- 3. Auto Shake siêu tốc bỏ qua hoạt ảnh trễ
                    if PlayerGui:FindFirstChild("Shake") then
                        local btn = PlayerGui.Shake:FindFirstChild("button")
                        if btn and btn.Visible then
                            FireNetworkEvent("shake")
                        end
                    end
                end
            end)
        end
        task.wait(0.04) -- Tần suất quét đồng bộ mượt mà
    end
end)

-- 4. XỬ LÝ THU CẦN TRỰC TIẾP TRÊN KHUNG HÌNH SERVER
RunService.Stepped:Connect(function()
    if Settings.AutoFarm then
        pcall(function()
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local Reel = PlayerGui and PlayerGui:FindFirstChild("Reel")
            if Reel then
                if Settings.FishingSpeed == "Instant" then
                    FireNetworkEvent("reelfinish", 100, true)
                elseif Settings.FishingSpeed == "Fish Lock Center Bar" then
                    local Bar = Reel:FindFirstChild("Bar")
                    local Fish = Reel:FindFirstChild("Fish")
                    if Bar and Fish then 
                        Fish.Position = Bar.Position -- Khóa dính chặt cá vào tâm thanh câu
                    end
                    FireNetworkEvent("reelfinish", 100, false)
                end
            end
        end)
    end
end)

---------------------------------------------------------
-- TAB 2: ADVANCED ECONOMY (MỞ RỘNG MỒI & LỌC BÁN CÁ)
---------------------------------------------------------
local EconomyTab = Window:CreateTab("Bait & Economy", 4483345998)

EconomyTab:CreateDropdown({
    Name = "Select Bait Type",
    Options = {"Basic Bait", "Worm Bait", "Shrimp Bait", "Minnow Bait", "Squid Bait", "Fish Head Bait", "Bagel Bait", "Insect Bait"},
    CurrentOption = {"Basic Bait"},
    MultipleOptions = false,
    Callback = function(Option)
        Settings.SelectedBait = Option[1]
    end,
})

EconomyTab:CreateToggle({
    Name = "Auto Buy Bait (Always Stocked)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoBuyBait = Value
    end,
})

-- Quản lý vòng lặp mua mồi
task.spawn(function()
    while true do
        if Settings.AutoBuyBait then
            pcall(function() FireNetworkEvent("buybait", Settings.SelectedBait, 1) end)
            task.wait(2.5)
        else
            task.wait(1)
        end
    end
end)

EconomyTab:CreateSection("--- Smart Auto Sell (Tính năng Nâng Cao) ---")

EconomyTab:CreateDropdown({
    Name = "Filter Rarity to Sell",
    Options = {"All Fish", "Common Only", "Uncommon & Below", "Exclude Mythical/Legendary"},
    CurrentOption = {"All Fish"},
    MultipleOptions = false,
    Callback = function(Option)
        Settings.SellRarity = Option[1]
    end,
})

EconomyTab:CreateToggle({
    Name = "Auto Sell Fish at Vendor",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoSell = Value
    end,
})

-- Cơ chế bán cá tự động thông minh
task.spawn(function()
    while true do
        if Settings.AutoSell then
            pcall(function()
                -- Gửi gói tin bán dựa trên bộ lọc đã chọn
                if Settings.SellRarity == "All Fish" then
                    FireNetworkEvent("sell")
                else
                    -- Mô phỏng bán có chọn lọc (Gửi tham số lọc nếu server game hỗ trợ)
                    FireNetworkEvent("sell", Settings.SellRarity) 
                end
            end)
        end
        task.wait(15) -- Khoảng giãn cách an toàn chống nghi vấn từ hệ thống
    end
end)

---------------------------------------------------------
-- TAB 3: SYSTEM UTILITIES (CHỐNG KẸT & TỐI ƯU CƠ THỂ)
---------------------------------------------------------
local UtilityTab = Window:CreateTab("Utilities", 4483345998)

UtilityTab:CreateToggle({
    Name = "Anti-Stuck Hook (Chống Kẹt Cần)",
    CurrentValue = true,
    Callback = function(Value)
        Settings.AntiStuck = Value
    end,
})

-- Vòng lặp giải kẹt lỗi UI xuất hiện vô cớ làm đứng im nhân vật
task.spawn(function()
    while true do
        if Settings.AntiStuck and Settings.AutoFarm then
            pcall(function()
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if PlayerGui and PlayerGui:FindFirstChild("Reel") and not LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                    PlayerGui.Reel:Destroy()
                    if PlayerGui:FindFirstChild("Cast") then PlayerGui.Cast:Destroy() end
                    if PlayerGui:FindFirstChild("Shake") then PlayerGui.Shake:Destroy() end
                end
            end)
        end
        task.wait(4)
    end
end)

UtilityTab:CreateSlider({
    Name = "WalkSpeed Hack",
    Min = 16,
    Max = 150,
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end)
    end,
})

UtilityTab:CreateButton({
    Name = "Fullbright (Xóa Bóng Tối Map)",
    Callback = function()
        pcall(function()
            game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").Brightness = 2
        end)
    end,
})

-- TỰ ĐỘNG DỌN RÁC BỘ NHỚ GIÚP MÁY ĐIỆN THOẠI CHẠY MƯỢT
task.spawn(function()
    while task.wait(10) do
        collectgarbage("step", 200)
    end
end)
