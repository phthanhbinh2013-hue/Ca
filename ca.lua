-- =========================================================
-- GROW A GARDEN 2 - AUTOMATION EMPIRE V1.0
-- THƯ VIỆN GIAO DIỆN: RAYFIELD LIBRARY (MOBILE OPTIMIZED)
-- =========================================================

-- KHỞI TẠO THƯ VIỆN RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
    Name = "🌱 Grow a Garden 2 - NeonHub",
    LoadingTitle = "Injecting Garden Engine...",
    LoadingSubtitle = "Optimized for Mobile",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "GardenHub"
    },
    KeySystem = false -- Vào thẳng menu không cần tốn thời gian lấy key
})

-- CORE SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- TRẠNG THÁI TÍNH NĂNG (CONFIG)
local Settings = {
    AutoPlant = false,
    AutoWater = false,
    AutoHarvest = false,
    AutoSell = false,
    AutoBuySeeds = false,
    SelectedSeed = "Tomato", -- Mặc định hạt giống đầu game
    WalkSpeed = 16
}

-- HÀM TỰ DÒ EVENT TRONG GAME (Chống lỗi khi game update)
local function GetGardenEvent(name)
    -- Tự động quét trong ReplicatedStorage để tìm RemoteEvent phù hợp
    for _, child in pairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") and (child.Name:lower():find(name:lower())) then
            return child
        end
    end
    return nil
end

---------------------------------------------------------
-- TAB 1: AUTOMATION (TỰ ĐỘNG HÓA KHU VƯỜN)
---------------------------------------------------------
local FarmTab = Window:CreateTab("Auto Farm", 4483345998)

local FpsParagraph = FarmTab:CreateParagraph({Title = "Garden Performance", Content = "FPS: Calculating..."})

-- Đồng hồ đo FPS mượt mà
task.spawn(function()
    while true do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        FpsParagraph:SetContent("FPS: " .. fps .. " | Garden Status: Active 🌱")
        task.wait(1)
    end
end)

FarmTab:CreateSection("--- Trồng Trọt & Chăm Sóc ---")

FarmTab:CreateToggle({
    Name = "🌱 Auto Plant Seeds (Tự Động Gieo Hạt)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoPlant = Value
    end,
})

FarmTab:CreateToggle({
    Name = "💧 Auto Water Plants (Tự Động Tưới Nước)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoWater = Value
    end,
})

FarmTab:CreateToggle({
    Name = "✂️ Auto Harvest (Tự Động Thu Hoạch)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoHarvest = Value
    end,
})

-- VÒNG LẶP CHÍNH XỬ LÝ NÔNG TRẠI (Chạy ngầm tốc độ cao)
task.spawn(function()
    while true do
        pcall(function()
            -- 1. Xử lý Tự động gieo hạt
            if Settings.AutoPlant then
                local PlantEvent = GetGardenEvent("plant") or GetGardenEvent("seed")
                if PlantEvent then
                    PlantEvent:FireServer(Settings.SelectedSeed)
                end
            end
            task.wait(0.1)

            -- 2. Xử lý Tự động tưới nước
            if Settings.AutoWater then
                local WaterEvent = GetGardenEvent("water") or GetGardenEvent("moisture")
                if WaterEvent then
                    WaterEvent:FireServer()
                end
            end
            task.wait(0.1)

            -- 3. Xử lý Tự động thu hoạch
            if Settings.AutoHarvest then
                local HarvestEvent = GetGardenEvent("harvest") or GetGardenEvent("collect")
                if HarvestEvent then
                    HarvestEvent:FireServer()
                end
            end
        end)
        task.wait(0.3) -- Giãn cách tối ưu để điện thoại không bị lag
    end
end)

---------------------------------------------------------
-- TAB 2: SHOP & ECONOMY (MỒI, HẠT GIỐNG & KINH TẾ)
---------------------------------------------------------
local ShopTab = Window:CreateTab("Shop & Sell", 4483345998)

ShopTab:CreateDropdown({
    Name = "Select Seed Type",
    Options = {"Tomato", "Carrot", "Potato", "Pumpkin", "Strawberry", "Watermelon"}, -- Thay đổi tùy theo các loại hạt có trong game của bạn
    CurrentOption = {"Tomato"},
    MultipleOptions = false,
    Callback = function(Option)
        Settings.SelectedSeed = Option[1]
    end,
})

ShopTab:CreateToggle({
    Name = "🛒 Auto Buy Selected Seed",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoBuySeeds = Value
    end,
})

ShopTab:CreateToggle({
    Name = "💰 Auto Sell Crops (Tự Động Bán Sản Vật)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoSell = Value
    end,
})

-- Vòng lặp quản lý kinh tế
task.spawn(function()
    while true do
        pcall(function()
            -- Mua hạt giống tự động
            if Settings.AutoBuySeeds then
                local BuyEvent = GetGardenEvent("buy") or GetGardenEvent("shop")
                if BuyEvent then
                    BuyEvent:FireServer(Settings.SelectedSeed, 1)
                end
            end
            
            -- Bán nông sản kiếm tiền
            if Settings.AutoSell then
                local SellEvent = GetGardenEvent("sell") or GetGardenEvent("vendor")
                if SellEvent then
                    SellEvent:FireServer()
                end
            end
        end)
        task.wait(2.0) -- Giãn cách an toàn chống spam gói tin lên server
    end
end)

---------------------------------------------------------
-- TAB 3: UTILITIES (TIỆN ÍCH NHÂN VẬT)
---------------------------------------------------------
local UtilTab = Window:CreateTab("Utilities", 4483345998)

UtilTab:CreateSlider({
    Name = "WalkSpeed Modifier (Tốc độ chạy)",
    Min = 16,
    Max = 120,
    CurrentValue = 16,
    Callback = function(Value)
        Settings.WalkSpeed = Value
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end)
    end,
})

-- Đồng bộ lại tốc độ khi nhân vật bị reset/hồi sinh
LocalPlayer.CharacterAdded:Connect(function(Char)
    local Hum = Char:WaitForChild("Humanoid")
    task.wait(0.5)
    Hum.WalkSpeed = Settings.WalkSpeed
end)

UtilTab:CreateButton({
    Name = "Clear Night (Bật Fullbright sáng rực map)",
    Callback = function()
        pcall(function()
            local Lighting = game:GetService("Lighting")
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14 -- Đóng băng thời gian ở giữa trưa
        end)
    end,
})

-- TỰ ĐỘNG DỌN RÁC HOẠT ẢNH ĐỂ ĐIỆN THOẠI TREO 24/7 KHÔNG NÓNG MÁY
task.spawn(function()
    while task.wait(15) do
        collectgarbage("step", 250)
    end
end)
