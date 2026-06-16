-- =========================================================
-- GROW A GARDEN 2 - REDZ PREMIUM V4 (ULTRA OPTIMIZED)
-- FIX CHẠY NHANH - BIÊN DỊCH BỘ LỌC ESP PET MYTHICAL+
-- =========================================================

local RedzLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDZ39/Redz39/main/RedzLib-V5.lua"))()

local Window = RedzLib:MakeWindow({
    Title = "🌱 Garden 2 Empire - V4",
    SubTitle = "Rayfield Alternative (Redz UI)",
    SaveFolder = "GardenV4Config"
})

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- CONFIG STATES
local Settings = {
    AutoPlant = false,
    AutoWater = false,
    AutoHarvest = false,
    AutoSell = false,
    AutoBuySeeds = false,
    SelectedSeed = "Tomato",
    WalkSpeed = 16,
    EspPetEnabled = false,
    EspFilter = "All Pets" -- Lọc độ hiếm: "All Pets", "Mythical Only", "Legendary & Up"
}

-- BỘ LƯU TRỮ ĐỐI TƯỢNG ESP
local ActiveEspObjects = {}

-- HÀM DÒ TÌM REMOTE EVENT THÔNG MINH
local function GetGardenEvent(name)
    for _, child in pairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") and (child.Name:lower():find(name:lower())) then
            return child
        end
    end
    return nil
end

---------------------------------------------------------
-- TAB 1: AUTO FARM (TỐI ƯU HOÀN TOÀN)
---------------------------------------------------------
local FarmTab = Window:MakeTab({"Auto Farm", "rbxassetid://4483345998"})

FarmTab:AddSection({"Trồng Trọt Tuần Tự"})

FarmTab:AddToggle({
    Name = "🌱 Auto Plant Seeds",
    Default = false,
    Callback = function(v) Settings.AutoPlant = v end
})

FarmTab:AddToggle({
    Name = "💧 Auto Water Plants",
    Default = false,
    Callback = function(v) Settings.AutoWater = v end
})

FarmTab:AddToggle({
    Name = "✂️ Auto Harvest",
    Default = false,
    Callback = function(v) Settings.AutoHarvest = v end
})

-- Luồng cày nông trại không gây delay CPU
task.spawn(function()
    while true do
        if Settings.AutoPlant or Settings.AutoWater or Settings.AutoHarvest then
            pcall(function()
                if Settings.AutoPlant then
                    local ev = GetGardenEvent("plant") or GetGardenEvent("seed")
                    if ev then ev:FireServer(Settings.SelectedSeed) end
                end
                task.wait(0.08)
                if Settings.AutoWater then
                    local ev = GetGardenEvent("water") or GetGardenEvent("moisture")
                    if ev then ev:FireServer() end
                end
                task.wait(0.08)
                if Settings.AutoHarvest then
                    local ev = GetGardenEvent("harvest") or GetGardenEvent("collect")
                    if ev then ev:FireServer() end
                end
            end)
            task.wait(0.15)
        else
            task.wait(0.5)
        end
    end
end)

---------------------------------------------------------
-- TAB 2: SHOP & ECONOMY
---------------------------------------------------------
local ShopTab = Window:MakeTab({"Shop & Sell", "rbxassetid://4483345998"})

ShopTab:AddDropdown({
    Name = "Select Seed Type",
    Options = {"Tomato", "Carrot", "Potato", "Pumpkin", "Strawberry", "Watermelon"},
    Default = "Tomato",
    Callback = function(Option) Settings.SelectedSeed = Option end
})

ShopTab:AddToggle({
    Name = "🛒 Auto Buy Selected Seed",
    Default = false,
    Callback = function(v) Settings.AutoBuySeeds = v end
})

ShopTab:AddToggle({
    Name = "💰 Auto Sell Crops",
    Default = false,
    Callback = function(v) Settings.AutoSell = v end
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
            task.wait(1.5)
        else
            task.wait(1)
        end
    end
end)

---------------------------------------------------------
-- TAB 3: VISUALS & ESP PET (TÍNH NĂNG MỚI THEO YÊU CẦU)
---------------------------------------------------------
local VisualTab = Window:MakeTab({"Visuals/ESP", "rbxassetid://4483345998"})

VisualTab:AddSection({"Bộ Lọc ESP Thú Cưng"})

VisualTab:AddDropdown({
    Name = "ESP Rarity Filter",
    Options = {"All Pets", "Mythical Only", "Legendary & Up"},
    Default = "All Pets",
    Callback = function(Option)
        Settings.EspFilter = Option
    end
})

-- Hàm dọn dẹp ESP cũ
local function ClearAllPetEsp()
    for pet, esp in pairs(ActiveEspObjects) do
        if esp then esp:Destroy() end
        ActiveEspObjects[pet] = nil
    end
end

-- Hàm tạo ESP cho từng con Pet cụ thể
local function ApplyEspToPet(pet)
    if not pet:IsA("Model") or ActiveEspObjects[pet] then return end

    -- Đọc thuộc tính độ hiếm (phổ biến trong cấu trúc Roblox là đặt tên hoặc qua StringValue)
    local rarityValue = pet:FindFirstChild("Rarity") or pet:FindFirstChild("RarityValue")
    local petRarity = rarityValue and rarityValue.Value or pet.Name

    -- Kiểm tra bộ lọc người dùng chọn
    if Settings.EspFilter == "Mythical Only" and not string.find(string.lower(petRarity), "mythical") then
        return
    elseif Settings.EspFilter == "Legendary & Up" then
        if not (string.find(string.lower(petRarity), "legendary") or string.find(string.lower(petRarity), "mythical")) then
            return
        end
    end

    -- Vẽ Box Highlight (Chế độ phát sáng xuyên tường hiện đại)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "PetEspHighlight"
    Highlight.Adornee = pet
    Highlight.FillColor = string.find(string.lower(petRarity), "mythical") and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(255, 215, 0)
    Highlight.FillTransparency = 0.4
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.OutlineTransparency = 0
    Highlight.Parent = CoreGui

    ActiveEspObjects[pet] = Highlight
end

VisualTab:AddToggle({
    Name = "🐾 Enable Pet ESP Tracker",
    Default = false,
    Callback = function(Value)
        Settings.EspPetEnabled = Value
        if not Value then ClearAllPetEsp() end
    end
})

-- Vòng lặp quét thế giới tìm Pet để vẽ ESP
task.spawn(function()
    while true do
        if Settings.EspPetEnabled then
            pcall(function()
                -- Quét trong Workspace (Nơi chứa Pet rơi ra hoặc Pet đi theo người)
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("pet") or obj:FindFirstChild("HumanoidRootPart")) then
                        if obj ~= LocalPlayer.Character then
                            ApplyEspToPet(obj)
                        end
                    end
                end
                
                -- Dọn dẹp các Pet đã biến mất khỏi Game
                for pet, esp in pairs(ActiveEspObjects) do
                    if not pet or not pet.Parent then
                        if esp then esp:Destroy() end
                        ActiveEspObjects[pet] = nil
                    end
                end
            end)
        end
        task.wait(2.0)
    end
end)

---------------------------------------------------------
-- TAB 4: UTILITIES & FIX CHẠY NHANH
---------------------------------------------------------
local UtilTab = Window:MakeTab({"Utilities", "rbxassetid://4483345998"})

UtilTab:AddSection({"Tối Ưu Nhân Vật"})

UtilTab:AddSlider({
    Name = "WalkSpeed Customizer",
    Min = 16, Max = 150, Default = 16,
    Callback = function(Value)
        Settings.WalkSpeed = Value
    end
})

-- FIX CHẠY NHANH TUYỆT ĐỐI: Khóa dính chỉ số WalkSpeed theo từng khung hình máy máy
RunService.Stepped:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.WalkSpeed ~= Settings.WalkSpeed then
                LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
            end
        end
    end)
end)

UtilTab:AddButton({
    Name = "Fullbright (Sáng Rực Bản Đồ)",
    Callback = function()
        pcall(function()
            local Lighting = game:GetService("Lighting")
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        end)
    end
})

-- TỰ ĐỘNG GIẢI PHÓNG BỘ NHỚ CHỐNG VĂNG GAME (TREO ĐÊM)
task.spawn(function()
    while task.wait(10) do
        collectgarbage("step", 200)
    end
end)
