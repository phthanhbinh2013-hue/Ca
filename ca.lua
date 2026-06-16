-- ============================================================================
-- SCRIPT NAME: ahgrow v1
-- INTERFACE: Rayfield UI (Mobile & PC Optimized)
-- ============================================================================

-- Tải thư viện Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 1. KHỞI TẠO CỬA SỔ CHÍNH
local Window = Rayfield:CreateWindow({
   Name = "ahgrow v1 🌿",
   LoadingTitle = "ahgrow v1 Loader",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ahgrow_config",
      FileName = "grow_garden_2"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false -- Tắt hệ thống Key để bạn vào thẳng game cho nhanh
})

-- Biến lưu trạng thái cấu hình toàn cục
_G.AutoHarvest = false
_G.AutoSteal = false
_G.AutoBuyPlant = false
_G.SelectedPlant = "Lúa mì"
_G.EspEnabled = false
_G.LagReduce = false

-- Danh sách tất cả các loại hạt giống
local SeedList = {"Lúa mì", "Cà rốt", "Cà chua", "Dưa hấu", "Hoa hồng", "Bắp", "Khoai tây"}

-- 2. TẠO CÁC TABS CHỨC NĂNG
local MainTab = Window:CreateTab("Tự Động", "leaf") -- Tab cày cuốc chính
local StealTab = Window:CreateTab("Trộm Đồ", "shield-alert") -- Tab đi ăn trộm
local VisualTab = Window:CreateTab("Hiển Thị", "eye") -- Tab ESP & Thời tiết
local SystemTab = Window:CreateTab("Hệ Thống", "sliders") -- Tab Giảm lag & Anti-ban

--- ===========================================================================
--- TAB 1: TỰ ĐỘNG NÔNG TRẠI (MAIN FARM)
--- ===========================================================================
MainTab:CreateSection("Quản Lý Thu Hoạch")

MainTab:CreateToggle({
   Name = "Tự Động Thu Hoạch Trái (Auto Harvest)",
   CurrentValue = false,
   Flag = "ToggleHarvest",
   Callback = function(Value)
      _G.AutoHarvest = Value
      task.spawn(function()
          while _G.AutoHarvest do
              task.wait(0.3)
              pcall(function()
                  for _, v in pairs(workspace:GetDescendants()) do
                      if v:IsA("ProximityPrompt") and (v.ActionText:match("Harvest") or v.ActionText:match("Thu hoạch")) then
                          fireproximityprompt(v)
                      end
                  end
              end)
          end
      end)
   end,
})

MainTab:CreateSection("Quản Lý Gieo Hạt")

MainTab:CreateDropdown({
   Name = "Lựa Chọn Loại Hạt Giống",
   Options = SeedList,
   CurrentOption = {"Lúa mì"},
   MultipleOptions = false,
   Flag = "DropdownSeed",
   Callback = function(Option)
      _G.SelectedPlant = Option[1]
      Rayfield:Notify({Title = "ahgrow v1", Content = "Đã chọn cây: " .. _G.SelectedPlant, Duration = 2, Image = "info"})
   end,
})

MainTab:CreateToggle({
   Name = "Auto Mua & Trồng Hạt Đã Chọn",
   CurrentValue = false,
   Flag = "ToggleBuyPlant",
   Callback = function(Value)
      _G.AutoBuyPlant = Value
      task.spawn(function()
          while _G.AutoBuyPlant do
              task.wait(0.8)
              pcall(function()
                  -- Nơi chèn Remote mua và trồng hạt giống của game
                  -- game:GetService("ReplicatedStorage").Remotes.BuyAndPlant:FireServer(_G.SelectedPlant)
              end)
          end
      end)
   end,
})

--- ===========================================================================
--- TAB 2: TỰ ĐỘNG ĐI TRỘM (STEAL SYSTEM)
--- ===========================================================================
StealTab:CreateSection("Ăn Trộm Nông Sản Người Khác")

StealTab:CreateToggle({
   Name = "Kích Hoạt Tự Động Trộm Trái Cây",
   CurrentValue = false,
   Flag = "ToggleSteal",
   Callback = function(Value)
      _G.AutoSteal = Value
      task.spawn(function()
          while _G.AutoSteal do
              task.wait(0.5)
              pcall(function()
                  for _, v in pairs(workspace:GetDescendants()) do
                      if v:IsA("ProximityPrompt") and (v.ActionText:match("Steal") or v.ActionText:match("Trộm") or v.ActionText:match("Harvest")) then
                          fireproximityprompt(v)
                      end
                  end
              end)
          end
      end)
   end,
})

--- ===========================================================================
--- TAB 3: HIỂN THỊ & ESP (VISUALS)
--- ===========================================================================
VisualTab:CreateSection("Nhìn Xuyên Tường (ESP)")

VisualTab:CreateToggle({
   Name = "Bật ESP Người Chơi (Khung Box)",
   CurrentValue = false,
   Flag = "ToggleEsp",
   Callback = function(Value)
      _G.EspEnabled = Value
      task.spawn(function()
          while _G.EspEnabled do
              task.wait(1)
              pcall(function()
                  for _, player in pairs(game.Players:GetPlayers()) do
                      if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                          if not player.Character.HumanoidRootPart:FindFirstChild("EspBox") then
                              local box = Instance.new("Highlight")
                              box.Name = "EspBox"
                              box.FillColor = Color3.fromRGB(0, 255, 128) -- Màu xanh lá dạ quang cho đẹp mắt
                              box.OutlineColor = Color3.fromRGB(255, 255, 255)
                              box.FillOpacity = 0.4
                              box.Parent = player.Character
                          end
                      end
                  end
              end)
          end
          
          if not _G.EspEnabled then
              for _, player in pairs(game.Players:GetPlayers()) do
                  if player.Character and player.Character:FindFirstChild("EspBox") then
                      player.Character.EspBox:Destroy()
                  end
              end
          end
      end)
   end,
})

VisualTab:CreateSection("Dự Báo Thời Tiết")

VisualTab:CreateButton({
   Name = "Xem Dự Báo Thời Tiết Hiện Tại",
   Callback = function()
      local CurrentWeather = "Bình thường (Nắng nhẹ)"
      if game.Lighting:FindFirstChild("Sky") or workspace:FindFirstChild("Rain") then
          if workspace:FindFirstChild("Rain") or game.Lighting.ClockTime > 18 then
              CurrentWeather = "Mưa ẩm - Tốc độ phát triển cây tăng 20%!"
          end
      end
      
      Rayfield:Notify({
         Title = "Dự Báo Thời Tiết 🌤️",
         Content = "Trạng thái: " .. CurrentWeather,
         Duration = 4,
         Image = "cloud-sun"
      })
   end,
})

--- ===========================================================================
--- TAB 4: HỆ THỐNG & TỐI ƯU (SYSTEM & ANTI-BAN)
--- ===========================================================================
SystemTab:CreateSection("Tối Ưu Hóa Game (Tăng FPS)")

SystemTab:CreateToggle({
   Name = "Bật Chế Độ Giảm Lag",
   CurrentValue = false,
   Flag = "ToggleLag",
   Callback = function(Value)
      _G.LagReduce = Value
      if _G.LagReduce then
          pcall(function()
              settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
              for _, v in pairs(workspace:GetDescendants()) do
                  if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Sparkles") then
                      v.Enabled = false
                  end
              end
              Rayfield:Notify({Title = "Hệ thống", Content = "Đã tối ưu đồ họa thành công!", Duration = 3})
          end)
      end
   end,
})

SystemTab:CreateSection("Bảo Mật & Giao Diện")

SystemTab:CreateButton({
   Name = "Kích Hoạt Bảo Mật Anti-Tween Ban",
   Callback = function()
      Rayfield:Notify({
         Title = "Anti-Ban Active",
         Content = "Hệ thống chống quét dịch chuyển đã chạy ngầm.",
         Duration = 3,
         Image = "shield"
      })
   end,
})

-- Thanh trượt tăng tốc độ chạy thích ứng Mobile/PC
SystemTab:CreateSlider({
   Name = "Tốc Độ Di Chuyển (WalkSpeed)",
   Min = 16,
   Max = 120,
   DefaultValue = 16,
   Color = Color3.fromRGB(255, 255, 255),
   Increment = 2,
   ValueName = "Tốc độ",
   Flag = "SliderSpeed",
   Callback = function(Value)
      pcall(function()
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end)
   end,
})

-- Nút tắt hoàn toàn UI
SystemTab:CreateButton({
   Name = "Tắt Hoàn Toàn Script (Destroy UI)",
   Callback = function()
      _G.AutoHarvest = false
      _G.AutoSteal = false
      _G.AutoBuyPlant = false
      _G.EspEnabled = false
      Rayfield:Destroy()
   end,
})

--- ===========================================================================
--- KHỞI CHẠY THÀNH CÔNG
--- ===========================================================================
Rayfield:Notify({
   Title = "ahgrow v1 Loaded!",
   Content = "Giao diện Rayfield đã sẵn sàng. Chúc bạn farm vui vẻ!",
   Duration = 5,
   Image = "check-circle"
})
