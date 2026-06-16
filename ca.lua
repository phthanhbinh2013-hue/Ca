-- ==========================================
-- NEONFISH ULTIMATE MOBILE v4.0 (TÂM CÁ ĐỨNG YÊN)
-- THIẾT KẾ ĐƠN TRANG - TỐI ƯU HÓA HIỆU NĂNG
-- ==========================================

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "🐟 NeonFish v4.0 (Single Page)", 
    HidePremium = true, 
    SaveConfig = false, 
    ConfigFolder = "NeonFishV4",
    IntroText = "Loading NeonFish v4.0..."
})

-- CORE SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GLOBAL AUTOMATION STATES
local MasterFarm = false
local AutoBuyBait = false
local SelectedBaitName = "Basic Bait"
local FishingSpeedMode = "Instant"

---------------------------------------------------------
-- GOM TOÀN BỘ VÀO MỘT TRANG CHÍNH (MAIN HUB)
---------------------------------------------------------
local MainTab = Window:MakeTab({Name = "Main Hub", Icon = "rbxassetid://4483345998"})

-- Hệ thống hiển thị FPS động ổn định
local FpsLabel = MainTab:AddLabel("FPS: Calculating...")
task.spawn(function()
    while true do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        FpsLabel:Set("FPS: " .. fps)
        task.wait(1)
    end
end)

MainTab:AddLabel("--- FISHING CONFIGURATION ---")

-- Lựa chọn tốc độ câu cá (Nhanh / Cá ở giữa thanh)
MainTab:AddDropdown({
    Name = "Fishing Speed Mode",
    Default = "Instant",
    Options = {"Instant", "Fish Lock Center Bar"},
    Callback = function(Value) 
        FishingSpeedMode = Value 
    end
})

-- Nút khởi động câu cá All-in-One chất lượng cao
MainTab:AddToggle({
    Name = "🔥 Master Auto Farm Fish",
    Default = false,
    Callback = function(Value)
        MasterFarm = Value
    end
})

MainTab:AddLabel("--- EXPANDED BAIT SHOP ---")

-- Danh sách mồi mở rộng nằm ngay trên màn hình chính
MainTab:AddDropdown({
    Name = "Select Bait Type",
    Default = "Basic Bait",
    Options = {"Basic Bait", "Worm Bait", "Shrimp Bait", "Minnow Bait", "Squid Bait", "Fish Head Bait", "Bagel Bait", "Insect Bait"},
    Callback = function(Value) 
        SelectedBaitName = Value 
    end
})

-- Tự động mua mồi khi hết
MainTab:AddToggle({
    Name = "Auto Buy Selected Bait",
    Default = false,
    Callback = function(Value)
        AutoBuyBait = Value
        task.spawn(function()
            while AutoBuyBait do
                if not AutoBuyBait then break end
                pcall(function()
                    local BaitEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("buybait")
                    if BaitEvent then 
                        BaitEvent:FireServer(SelectedBaitName, 1) 
                    end
                end)
                task.wait(3.0) -- Giãn cách đồng bộ an toàn chống nghẽn gói tin
            end
        end)
    end
})

---------------------------------------------------------
-- THUẬT TOÁN ĐỒNG BỘ CHÍNH XÁC CAO VÀ CHỐNG KẸT UI
---------------------------------------------------------
task.spawn(function()
    while true do
        if MasterFarm then
            pcall(function()
                local Character = LocalPlayer.Character
                local Backpack = LocalPlayer:FindFirstChild("Backpack")
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                
                -- Bước 1: Tự động cầm cần câu
                if Character and not Character:FindFirstChildOfClass("Tool") and Backpack then
                    for _, v in pairs(Backpack:GetChildren()) do
                        if v:IsA("Tool") and (v.Name:lower():find("rod") or v:FindFirstChild("Click")) then
                            Character.Humanoid:EquipTool(v)
                            task.wait(0.3)
                            break
                        end
                    end
                end
                
                -- Bước 2: Tự động thả câu tuần tự
                local Tool = Character and Character:FindFirstChildOfClass("Tool")
                if Tool and Tool:FindFirstChild("Click") and PlayerGui then
                    if not PlayerGui:FindFirstChild("Reel") and not PlayerGui:FindFirstChild("Cast") then
                        Tool.Click:Activate()
                        local cast = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("cast")
                        if cast then cast:FireServer(100, true) end
                        task.wait(1.2)
                    end
                    
                    -- Bước 3: Tự động nhấp Shake UI siêu tốc (Auto Shake)
                    if PlayerGui:FindFirstChild("Shake") then
                        local btn = PlayerGui.Shake:FindFirstChild("button")
                        if btn and btn.Visible then
                            local shake = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("shake")
                            if shake then shake:FireServer() end
                        end
                    end
                end
            end)
        end
        task.wait(0.05) -- Chu kỳ quét đồng bộ tốc độ cao của v4.0
    end
end)

-- XỬ LÝ KÉO CẦU (Đồng bộ trực tiếp theo Khung hình Server)
RunService.Stepped:Connect(function()
    if MasterFarm then
        pcall(function()
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local Reel = PlayerGui and PlayerGui:FindFirstChild("Reel")
            if Reel then
                local finish = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("reelfinish")
                
                if FishingSpeedMode == "Instant" then
                    if finish then finish:FireServer(100, true) end
                elseif FishingSpeedMode == "Fish Lock Center Bar" then
                    local Bar = Reel:FindFirstChild("Bar")
                    local Fish = Reel:FindFirstChild("Fish")
                    if Bar and Fish then 
                        -- THUẬT TOÁN MỚI: Ép con cá phải dính chặt vào chính giữa thanh câu của bạn
                        Fish.Position = Bar.Position
                    end
                    if finish then finish:FireServer(100, false) end
                end
            end
        end)
    end
end)

-- KHỞI TẠO ORION SYSTEM
OrionLib:Init()
