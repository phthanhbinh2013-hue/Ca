-- Khởi tạo thư viện Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Tạo Cửa sổ giao diện chính
local Window = Rayfield:CreateWindow({
   Name = "Forsake Hub | Premium Edition",
   LoadingTitle = "Đang tải hệ thống bảo mật...",
   LoadingSubtitle = "by Gemini",
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
local MainTab = Window:CreateTab("Chức Năng", 4483362458)
local VisualsTab = Window:CreateTab("ESP (X-Ray)", 4483362458)

-- ==========================================
-- HỆ THỐNG ANTI-BAN (BYPASS/SPOOFING)
-- ==========================================
-- Chặn Server phát hiện việc thay đổi giá trị bộ nhớ hoặc tốc độ quá nhanh
local MT = getrawmetatable(game)
local OldNamecall = MT.__namecall
local OldIndex = MT.__index
setreadonly(MT, false)

-- Chặn kiểm tra từ phía Server (Bypass RemoteEvent kiểm tra thể lực/vị trí)
MT.__namecall = newcclosure(function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    -- Nếu server gửi lệnh kiểm tra vị trí hoặc chỉ số stamina bất thường, script sẽ bỏ qua
    if Method == "FireServer" and (tostring(Self) == "StaminaCheck" or tostring(Self) == "CheatCheck" or tostring(Self) == "BanRemote") then
        return nil
    end
    return OldNamecall(Self, ...)
end)

-- Tạo giá trị Stamina ảo để đánh lừa Anti-cheat nếu nó quét thuộc tính (.Value)
MT.__index = newcclosure(function(Self, Key)
    if not checkcaller() and Key == "Value" and (tostring(Self) == "Stamina" or tostring(Self) == "SprintEnergy") then
        return 100 -- Lúc nào cũng trả về 100 cho Server thấy, dù thực tế ta đang xài vô hạn
    end
    return OldIndex(Self, Key)
end)

setreadonly(MT, true)

-- ==========================================
-- LOGIC & BIẾN ĐIỀU KHIỂN
-- ==========================================
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local InfiniteStamina = false
local AutoFixPC = false

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- ==========================================
-- TAB 1: CHỨC NĂNG CHÍNH (MAIN FEATURES)
-- ==========================================

-- 1. Vô hạn Thể lực + Bảo mật nâng cao
MainTab:CreateToggle({
   Name = "Vô Hạn Thể Lực (Anti-Ban)",
   CurrentValue = false,
   Flag = "InfStaminaFlag",
   Callback = function(Value)
       InfiniteStamina = Value
       
       task.spawn(function()
           while InfiniteStamina do
               task.wait(0.1)
               -- Tìm biến thể lực của nhân vật
               local Stamina = Character:FindFirstChild("Stamina") or LocalPlayer:FindFirstChild("Stamina") or Character:FindFirstChild("SprintEnergy")
               if Stamina and (Stamina:IsA("NumberValue") or Stamina:IsA("IntValue")) then
                   -- Đặt trực tiếp thông qua script cục bộ
                   Stamina.Value = 100
               end
           end
       end)
   end,
})

-- 2. Tự động sửa máy (Delay 3s chống bị khóa tài khoản)
MainTab:CreateToggle({
   Name = "Tự Động Sửa Máy (Delay 3 Giây)",
   CurrentValue = false,
   Flag = "AutoFixFlag",
   Callback = function(Value)
       AutoFixPC = Value
       
       task.spawn(function()
           while AutoFixPC do
               -- Tìm máy tính trong bản đồ
               local Map = workspace:FindFirstChild("Map") or workspace
               local FoundComputer = false
               
               for _, obj in pairs(Map:GetDescendants()) do
                   if obj.Name == "Computer" and obj:FindFirstChild("ComputerTrigger") then
                       local Screen = obj:FindFirstChild("Screen")
                       -- Kiểm tra xem máy này đã được sửa xong chưa (Màu xanh lá là đã xong)
                       if Screen and Screen:FindFirstChild("BrickColor") and Screen.BrickColor ~= BrickColor.new("Bright green") then
                           
                           -- Di chuyển an toàn đến máy tính
                           if Character and Character:FindFirstChild("HumanoidRootPart") then
                               FoundComputer = true
                               Character.HumanoidRootPart.CFrame = obj.ComputerTrigger.CFrame + Vector3.new(0, 2, 0)
                               
                               -- Kích hoạt sửa máy (ProximityPrompt hoặc Trigger)
                               local prompt = obj.ComputerTrigger:FindFirstChildOfClass("ProximityPrompt")
                               if prompt then
                                   fireproximityprompt(prompt)
                               end
                               
                               -- GIỮ ĐÚNG DELAY 3 GIÂY trước khi chuyển sang hành động tiếp theo
                               -- Việc này giúp Server không phát hiện tốc độ tương tác bất thường
                               task.wait(3.0) 
                           end
                       end
                   end
                   if not AutoFixPC then break end
               end
               
               -- Nếu không tìm thấy máy nào cần sửa hoặc đã sửa hết, đợi 1 giây rồi quét lại
               if not FoundComputer then
                   task.wait(1.0)
               end
           end
       end)
   end,
})

-- ==========================================
-- TAB 2: ESP TRỰC QUAN (VISUALS)
-- ==========================================
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
        
        -- Nhận diện vai trò dựa trên vũ khí hoặc thuộc tính đặc trưng của Killer
        local isKiller = false
        if char:FindFirstChild("Hammer") or player:FindFirstChild("IsKiller") or char:FindFirstChild("Weapon") or player.TeamColor == BrickColor.new("Bright red") then
            isKiller = true
        end
        
        -- Màu sắc theo yêu cầu: Killer = Đỏ, Người sống sót = Xanh lá
        local espColor = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        
        -- Xóa ESP cũ trên người chơi này nếu có
        if char:FindFirstChild("ForsakeESP") then char.ForsakeESP:Destroy() end
        
        -- Tạo khối Highlight phát sáng xuyên tường
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "ForsakeESP"
        Highlight.Adornee = char
        Highlight.FillColor = espColor
        Highlight.FillTransparency = 0.4 -- Độ đậm của màu thân người
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Viền trắng cho rõ nét
        Highlight.OutlineTransparency = 0
        Highlight.Parent = char
        
        table.insert(EspObjects, Highlight)
    end
    
    if player.Character then highlight(player.Character) end
    player.CharacterAdded:Connect(highlight)
end

VisualsTab:CreateToggle({
   Name = "Kích Hoạt ESP (Người/Killer)",
   CurrentValue = false,
   Flag = "ESPFlag",
   Callback = function(Value)
       ESPEnabled = Value
       if ESPEnabled then
           for _, player in pairs(game.Players:GetPlayers()) do
               ApplyESP(player)
           end
           game.Players.PlayerAdded:Connect(ApplyESP)
       else
           ClearESP()
       end
   end,
})

-- Thông báo khởi động thành công an toàn
Rayfield:Notify({
   Title = "Forsake Anti-Ban",
   Content = "Đã kích hoạt hệ thống Bypass thành công. Chúc bạn trải nghiệm vui vẻ!",
   Duration = 5,
   Image = 4483362458,
})
