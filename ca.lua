-- =========================================================
-- GROW A GARDEN 2 - ULTRA COMPATIBILITY CORE (KAVO UI)
-- SỬA LỖI TUYỆT ĐỐI KHÔNG LÊN GIAO DIỆN TRÊN MOBILE
-- =========================================================

-- Khởi tạo thư viện Kavo (Cực nhẹ, tương thích 100% với Delta/Hydrogen)
local KavoUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- Chọn phong cách giao diện tối rực rỡ (Neon)
local Window = KavoUi.CreateLib("🌱 Grow a Garden 2 - NeonHub", "Midnight")

-- SERVICES & PLAYERS
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- CONFIG STATES
local Settings = {
    AutoPlant = false,
    AutoWater = false,
    AutoHarvest = false,
    AutoSell = false,
    AutoBuySeeds = false,
    SelectedSeed = "Tomato",
    WalkSpeed = 16
}

-- HÀM DÒ TÌM REMOTE EVENT CHỐNG UPDATE GAME
local function GetGardenEvent(name)
    for _, child in pairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") and (child.Name:lower():find(name:lower())) then
            return child
        end
    end
    return nil
end

---------------------------------------------------------
-- CẤU TRÚC PHÂN CHIA TABS TRÊN KAVO UI
---------------------------------------------------------
local FarmTab = Window:NewTab("Auto Farm")
local FarmSection = FarmTab:NewSection("Trồng Trọt & Chăm Sóc")

FarmSection:NewToggle("🌱 Auto Plant Seeds (Tự Gieo Hạt)", "Tự động trồng hạt giống đã chọn", function(Value)
    Settings.AutoPlant = Value
end)

FarmSection:NewToggle("💧 Auto Water Plants (Tự Tưới Nước)", "Tự động giữ độ ẩm cho đất", function(Value)
    Settings.AutoWater = Value
end)

FarmSection:NewToggle("✂️ Auto Harvest (Tự Thu Hoạch)", "Tự động hái nông sản khi chín", function(Value)
    Settings.AutoHarvest = Value
end)

-- Vòng lặp nông trại chạy ngầm an toàn
task.spawn(function()
    while true do
        if Settings.AutoPlant or Settings.AutoWater or Settings.AutoHarvest then
            pcall(function()
                if Settings.AutoPlant then
                    local ev = GetGardenEvent("plant") or GetGardenEvent("seed")
                    if ev then ev:FireServer(Settings.SelectedSeed) end
                end
                task.wait(0.1)
                if Settings.AutoWater then
                    local ev = GetGardenEvent("water") or GetGardenEvent("moisture")
                    if ev then ev:FireServer() end
                end
                task.wait(0.1)
                if Settings.AutoHarvest then
                    local ev = GetGardenEvent("harvest") or GetGardenEvent("collect")
                    if ev then ev:FireServer() end
                end
            end)
            task.wait(0.2)
        else
            task.wait(0.5)
        end
    end
end)

---------------------------------------------------------
-- TAB ĐỔI MỒI / HẠT GIỐNG & KINH TẾ
---------------------------------------------------------
local ShopTab = Window:NewTab("Shop & Sell")
local ShopSection = ShopTab:NewSection("Cửa Hàng Nông Sản")

ShopSection:NewDropdown("Select Seed Type", "Chọn loại hạt để trồng và mua", {"Tomato", "Carrot", "Potato", "Pumpkin", "Strawberry", "Watermelon"}, function(Option)
    Settings.SelectedSeed = Option
end)

ShopSection:NewToggle("🛒 Auto Buy Selected Seed", "Tự động mua thêm hạt giống khi trồng", function(Value)
    Settings.AutoBuySeeds = Value
end)

ShopSection:NewToggle("💰 Auto Sell Crops (Tự Động Bán)", "Tự động bán sạch sản vật kiếm tiền", function(Value)
    Settings.AutoSell = Value
end)

-- Vòng lặp quản lý tiền tệ và kho bãi
task.spawn(function()
    while true do
        if Settings.AutoBuySeeds or Settings.AutoSell then
            pcall(function()
                if Settings.AutoBuySeeds then
                    local ev = GetGardenEvent("buy") or GetGardenEvent("shop")
                    if ev then ev:FireServer(Settings.SelectedSeed, 1) end
                end
                task.wait(0.5)
                if Settings.AutoSell then
                    local ev = GetGardenEvent("sell") or GetGardenEvent("vendor")
                    if ev then ev:FireServer() end
                end
            end)
            task.wait(2.0)
        else
            task.wait(1)
        end
    end
end)

---------------------------------------------------------
-- TAB TIỆN ÍCH UTILITIES
---------------------------------------------------------
local UtilTab = Window:NewTab("Utilities")
local UtilSection = UtilTab:NewSection("Hỗ Trợ Nhân Vật")

UtilSection:NewSlider("WalkSpeed Modifier", "Thay đổi tốc độ chạy của bạn", 120, 16, function(Value)
    Settings.WalkSpeed = Value
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end)
end)

UtilSection:NewButton("Fullbright (Sáng Rực Bản Đồ)", "Xóa tan màn đêm trong game", function()
    pcall(function()
        local Lighting = game:GetService("Lighting")
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    end)
end)

-- Tự động áp dụng lại tốc độ chạy sau khi nhân vật hồi sinh
LocalPlayer.CharacterAdded:Connect(function(Char)
    local Hum = Char:WaitForChild("Humanoid")
    task.wait(0.5)
    Hum.WalkSpeed = Settings.WalkSpeed
end)
