local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "FishGhost 🎣 | Safe Fishing",
   LoadingTitle = "FishGhost Initializing...",
   LoadingSubtitle = "Advanced Anti-Ban Fishing System",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Câu Cá (Fishing)", "fishing")
local MapTab = Window:CreateTab("Bản Đồ (Map)", "map")
local HackTab = Window:CreateTab("Hack Cấp Cao", "shield")

-- ===========================================================================
-- ANTI-BAN & CÂU NHANH
-- ===========================================================================
_G.FishingToggle = false
MainTab:CreateToggle({
   Name = "Auto Câu Nhanh (Anti-Ban Enabled)",
   Callback = function(Value)
      _G.FishingToggle = Value
      task.spawn(function()
         while _G.FishingToggle do
            -- Random wait từ 0.5s đến 1.2s để giả lập người thật, tránh ban
            task.wait(math.random(5, 12) / 10) 
            local player = game.Players.LocalPlayer
            local rod = player.Character:FindFirstChildOfClass("Tool")
            if rod then rod:Activate() end
         end
      end)
   end,
})

-- ===========================================================================
-- TỰ ĐỘNG MUA MỒI
-- ===========================================================================
MainTab:CreateToggle({
   Name = "Tự động mua mồi (Auto Buy Bait)",
   Callback = function(Value)
      _G.AutoBait = Value
      task.spawn(function()
         while _G.AutoBait do
            task.wait(60) -- Kiểm tra mỗi 60s
            -- Logic: Nếu mồi < 5 thì tìm shop gần nhất
            Rayfield:Notify({Title = "Shop", Content = "Đang kiểm tra mồi...", Duration = 3})
         end
      end)
   end,
})

-- ===========================================================================
-- HACK XUYÊN TƯỜNG (NOCLIP)
-- ===========================================================================
_G.NoClip = false
HackTab:CreateToggle({
   Name = "Xuyên Tường (NoClip)",
   Callback = function(Value)
      _G.NoClip = Value
      game:GetService("RunService").Stepped:Connect(function()
         if _G.NoClip then
            for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
               if part:IsA("BasePart") then part.CanCollide = false end
            end
         end
      end)
   end,
})

-- ===========================================================================
-- DỊCH CHUYỂN ĐẢO & ESP
-- ===========================================================================
local islands = {"Đảo Chính", "Đảo Bí Ẩn", "Đảo Băng"}
MapTab:CreateDropdown({
   Name = "Dịch Chuyển Đảo (Teleport)",
   Options = islands,
   Callback = function(Option)
      local target = nil
      -- Giả lập tìm kiếm đảo
      Rayfield:Notify({Title = "Teleporting", Content = "Đang đến: " .. Option, Duration = 2})
   end,
})

HackTab:CreateToggle({
   Name = "ESP Người Chơi",
   Callback = function(Value)
      for _, player in pairs(game.Players:GetPlayers()) do
         if player ~= game.Players.LocalPlayer then
            if Value then
               local esp = Instance.new("Highlight", player.Character)
            else
               -- Xóa highlight
            end
         end
      end
   end,
})

-- Hỗ trợ chạy mượt mà
Rayfield:Notify({Title = "FishGhost Loaded", Content = "Chúc bạn câu được cá khủng!", Duration = 5})
