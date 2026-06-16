-- =========================================================
-- GROW A GARDEN 2 - HARD FIX INJECTION (RAYFIELD INTERFACE)
-- SỬA LỖI 100% KHÔNG HIỆN GIAO DIỆN TRÊN MOBILE
-- =========================================================

-- Tải thư viện thông qua link phân phối tốc độ cao (Bypass chặn mạng)
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/bannable-v2/Rayfield-Fix/main/Source.lua'))()
    or loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source'))()
end)

if not success or not Rayfield then
    -- Phương án dự phòng cuối cùng nếu Github bị chặn hoàn toàn: Chuyển hướng Console
    warn("👉 KHÔNG THỂ TẢI ĐƯỢC RAYFIELD. VUI LÒNG BẬT VPN 1.1.1.1 VÀ THỬ LẠI! 👈")
    return
end

-- KHỞI TẠO CỬA SỔ
local Window = Rayfield:CreateWindow({
    Name = "🌱 Grow a Garden 2 - NeonHub v2",
    LoadingTitle = "Injecting Garden Engine...",
    LoadingSubtitle = "Anti-Crash & Anti-Boot Error",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Settings = {
    AutoPlant = false,
    AutoWater = false,
    AutoHarvest = false,
    AutoSell = false,
    AutoBuySeeds = false,
    SelectedSeed = "Tomato",
    WalkSpeed = 16
}

-- HÀM DÒ TÌM REMOTES
local function GetGardenEvent(name)
    for _, child in pairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") and (child.Name:lower():find(name:lower())) then
            return child
        end
    end
    return nil
end

---------------------------------------------------------
-- TAB 1: AUTO FARM
---------------------------------------------------------
local FarmTab = Window:CreateTab("Auto Farm", 4483345998)

FarmTab:CreateToggle({
    Name = "🌱 Auto Plant Seeds (Tự Động Gieo Hạt)",
    CurrentValue = false,
    Callback = function(Value) Settings.AutoPlant = Value end,
})

FarmTab:CreateToggle({
    Name = "💧 Auto Water Plants (Tự Động Tưới Nước)",
    CurrentValue = false,
    Callback = function(Value) Settings.AutoWater = Value end,
})

FarmTab:CreateToggle({
    Name = "✂️ Auto Harvest (Tự Động Thu Hoạch)",
    CurrentValue = false,
    Callback = function(Value) Settings.AutoHarvest = Value end,
})

-- Vòng lặp nông trại tuần tự bảo vệ CPU
task.spawn(function()
    while true do
        if not (Settings.AutoPlant or Settings.AutoWater or Settings.AutoHarvest) then 
            task.wait(1) 
        else
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
        end
    end
end)

---------------------------------------------------------
-- TAB 2: SHOP & ECONOMY
---------------------------------------------------------
local ShopTab = Window:CreateTab("Shop & Sell", 4483345998)

ShopTab:CreateDropdown({
    Name = "Select Seed Type",
    Options = {"Tomato", "Carrot", "Potato", "Pumpkin", "Strawberry", "Watermelon"},
    CurrentOption = {"Tomato"},
    MultipleOptions = false,
    Callback = function(Option) Settings.SelectedSeed = Option[1] end,
})

ShopTab:CreateToggle({
    Name = "🛒 Auto Buy Selected Seed",
    CurrentValue = false,
    Callback = function(Value) Settings.AutoBuySeeds = Value end,
})

ShopTab:CreateToggle({
    Name = "💰 Auto Sell Crops (Tự Động Bán)",
    CurrentValue = false,
    Callback = function(Value) Settings.AutoSell = Value end,
})

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
-- TAB 3: UTILITIES
---------------------------------------------------------
local UtilTab = Window:CreateTab("Utilities", 4483345998)

UtilTab:CreateSlider({
    Name = "WalkSpeed Modifier",
    Min = 16, Max = 120, CurrentValue = 16,
    Callback = function(Value)
        Settings.WalkSpeed = Value
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end)
    end,
})

UtilTab:CreateButton({
    Name = "Fullbright (Sáng Rực Bản Đồ)",
    Callback = function()
        pcall(function()
            game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").Brightness = 2
        end)
    end,
})
