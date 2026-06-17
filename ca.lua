-- Khởi tạo thư viện Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Tạo Cửa sổ giao diện chính
local Window = Rayfield:CreateWindow({
   Name = "Forsake Hub | V2 Fixed",
   LoadingTitle = "Đang tải hệ thống...",
   LoadingSubtitle = "chơi cẩn thận ban nha! ♥️",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ForsakeHubConfigs",
      FileName = "FleeTheFacility"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

-- Tạo các Tab chức năng
local MainTab = Window:CreateTab("Chức Năng Chính", 4483362458)
-- Đổi icon hoặc giữ nguyên để tối ưu
local VisualsTab = Window:CreateTab("ESP & Tầm Nhìn", 4483362458)

-- ==========================================
-- LOGIC & BIẾN ĐIỀU KHIỂN
-- ==========================================
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local InfiniteStamina = false
local AutoFixPC = false
local FullBrightEnabled = false

-- Lưu trữ cài đặt ánh sáng gốc của game để khôi phục khi tắt
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient
local OriginalClockTime = Lighting.ClockTime

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- ==========================================
-- TAB 1: CHỨC NĂNG CHÍNH
-- ==========================================

-- 1. Vô hạn Thể lực (Bản Fix chạy luồng mượt chống crash)
MainTab:CreateToggle({
   Name = "Vô Hạn Thể Lực (Safe Mode)",
   CurrentValue = false,
   Flag = "InfStaminaFlag",
   Callback = function(Value)
       InfiniteStamina = Value
       
       task.spawn(function()
           while InfiniteStamina do
               task.wait(0.2) -- Tăng nhẹ delay để tránh quá tải/Phát hiện từ server
               if Character then
                   -- Quét tất cả các vị trí có thể chứa thuộc tính Stamina mà không dùng metatable chuyên sâu
                   for _, v in pairs(Character:GetDescendants()) do
                       if (v.Name == "Stamina" or v.Name == "SprintEnergy") and v:IsA("NumberValue") then
                           v.Value = 100
                       end
                   end
                   for _, v in pairs(LocalPlayer:GetDescendants()) do
                       if (v.Name == "Stamina" or v.Name == "SprintEnergy") and v:IsA("NumberValue") then
                           v.Value = 100
                       end
                   end
               end
           end
       end)
   end,
})

-- 2. Tự động sửa máy (Delay đúng 3 giây, tự động tìm mục tiêu chuẩn xác)
MainTab:CreateToggle({
   Name = "Tự Động Sửa Máy (Delay 3s)",
   CurrentValue = false,
   Flag = "AutoFixFlag",
   Callback = function(Value)
       AutoFixPC = Value
       
       task.spawn(function()
           while AutoFixPC do
               local FoundComputer = false
               -- Quét tìm máy tính trong Workspace
               for _, obj in pairs(workspace:GetDescendants()) do
                   if obj.Name == "Computer" and obj:FindFirstChild("ComputerTrigger") then
                       local Screen = obj:FindFirstChild("Screen")
                       -- Nếu máy chưa xanh (chưa sửa xong) thì tiến hành di chuyển tới
                       if Screen and Screen:FindFirstChild("BrickColor") and Screen.BrickColor ~= BrickColor.new("Bright green") then
                           if Character and Character:FindFirstChild("HumanoidRootPart") then
                               FoundComputer = true
                               -- Dịch chuyển đến vị trí an toàn ngay sát máy tính
                               Character.HumanoidRootPart.CFrame = obj.ComputerTrigger.CFrame + Vector3.new(0, 2, 0)
                               
                               task.wait(0.2)
                               -- Giả lập nhấn nút sửa máy (ProximityPrompt)
                               local prompt = obj.ComputerTrigger:FindFirstChildOfClass("ProximityPrompt")
                               if prompt then
                                   fireproximityprompt(prompt)
                               end
                               
                               -- Giữ đúng khoảng thời gian delay 3 giây theo yêu cầu
                               task.wait(3.0)
                           end
                       end
                   end
                   if not AutoFixPC then break end
               end
               
               -- Nếu không tìm thấy máy nào cần sửa, quét lại sau 1 giây
               if not FoundComputer then
                   task.wait(1.0)
               end
           end
       end)
   end,
})

-- ==========================================
-- TAB 2: ESP & TẦM NHÌN (VISUALS & FULL BRIGHT)
-- ==========================================

-- 1. Nhìn rõ vào buổi tối (Full Bright / Night Vision)
VisualsTab:CreateToggle({
   Name = "Nhìn Rõ Ban Đêm (Full Bright)",
   CurrentValue = false,
   Flag = "FullBrightFlag",
   Callback = function(Value)
       FullBrightEnabled = Value
       
       if FullBrightEnabled then
           -- Tạo vòng lặp liên tục để ghi đè ánh sáng tối của map
           task.spawn(function()
               while FullBrightEnabled do
                   Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                   Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                   Lighting.ClockTime = 14 -- Đưa thời gian map về buổi trưa sáng sủa
                   task.wait(0.5)
               end
           end)
       else
           -- Khôi phục lại trạng thái tối gốc của game khi tắt tính năng
           Lighting.Ambient = OriginalAmbient
           Lighting.OutdoorAmbient = OriginalOutdoorAmbient
           Lighting.ClockTime = OriginalClockTime
       end
   end,
})

-- 2. ESP Người sống sót (Xanh lá) & Killer (Đỏ)
local ESPEnabled = false
local EspObjects = {}

local function ClearESP()
    for _, obj in pairs(EspObjects) do
        if obj then obj:Destroy() end
    end
    EspObjects = {}
end

local function ApplyESP(player)
    if player == LocalPlayer then return end
    
    local function highlight(char)
        task.wait(0.5)
        if not ESPEnabled or not char:IsDescendantOf(workspace) then return end
        
        -- Nhận diện vai trò Killer (Dựa trên vũ khí hoặc Team)
        local isKiller = false
        if char:FindFirstChild("Hammer") or player:FindFirstChild("IsKiller") or char:FindFirstChild("Weapon") or player.TeamColor == BrickColor.new("Bright red") then
            isKiller = true
        end
        
        -- Người sống sót = Xanh lá, Killer = Đỏ
        local espColor = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        
        if char:FindFirstChild("ForsakeESP") then char.ForsakeESP:Destroy() end
        
        -- Tạo Highlight phát sáng xuyên tường
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "ForsakeESP"
        Highlight.Adornee = char
        Highlight.FillColor = espColor
        Highlight.FillTransparency = 0.4
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.OutlineTransparency = 0
        Highlight.Parent = char
        
        table.insert(EspObjects, Highlight)
    end
    
    if player.Character then highlight(player.Character) end
    player.CharacterAdded:Connect(highlight)
end

VisualsTab:CreateToggle({
   Name = "Kích Hoạt ESP (X-Ray)",
   CurrentValue = false,
   Flag = "ESPFlag",
   Callback = function(Value)
       ESPEnabled = Value
       if ESPEnabled then
           for _, player in pairs(Players:GetPlayers()) do
               ApplyESP(player)
           end
           Players.PlayerAdded:Connect(ApplyESP)
       else
           ClearESP()
       end
   end,
})

-- Thông báo khi load xong script
Rayfield:Notify({
   Title = "Forsake Hub V2",
   Content = "Đã sửa lỗi không nhận script và thêm Full Bright thành công!",
   Duration = 5,
   Image = 4483362458,
})
