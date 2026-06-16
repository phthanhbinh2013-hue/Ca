local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ahgrow v1.8 🌿 (AFK Night Edition)",
   LoadingTitle = "ahgrow v1.8 Premium",
   LoadingSubtitle = "Chúc bạn chơi game vui vẻ! 🎉", -- Thêm lời chúc khi loading script theo yêu cầu
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Các biến trạng thái logic toàn cục
_G.AutoHarvest = false
_G.AutoSteal = false
_G.AutoEventSeed = false
_G.AutoBuySeeds = false
_G.SuperLagReduction = false
_G.AntiAFK = true -- Mặc định bật ngầm bảo vệ khi chạy
_G.SelectedSeedToBuy = "Strawberry"

local SeedList = {"Strawberry", "Lúa mì", "Cà rốt", "Cà chua", "Dưa hấu", "Bắp"}

-- Phân tách lại cấu trúc các Tab theo đúng yêu cầu của bạn
local MainTab = Window:CreateTab("Vườn Trồng", "leaf")
local StealTab = Window:CreateTab("Trộm Đêm", "shield-alert")
local ShopTab = Window:CreateTab("Cửa Hàng", "shopping-cart")
local SystemTab = Window:CreateTab("Hệ Thống", "sliders")

--- ===========================================================================
--- HÀM BỔ TRỢ DI CHUYỂN & CHUỖI XỬ LÝ NPC TỰ ĐỘNG
--- ===========================================================================
local function safeTeleport(targetCFrame)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local tweenService = game:GetService("TweenService")
        local info = TweenInfo.new(0.35, Enum.EasingStyle.Linear)
        local tween = tweenService:Create(player.Character.HumanoidRootPart, info, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Vòng lặp tự động bán đồ (Thay thế việc phải ấn nút Sell thủ công trên video 1000021081.mp4)
local function autoSellWorkflow()
    local player = game.Players.LocalPlayer
    local npc = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("SellNPC") or workspace:FindFirstChild("NPC")
    
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        -- Lưu tạm trạng thái farm trước khi ngắt để bán
        local oldHarvest = _G.AutoHarvest
        local oldSteal = _G.AutoSteal
        _G.AutoHarvest = false
        _G.AutoSteal = false
        
        -- Dịch chuyển trực diện tới NPC
        safeTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
        task.wait(0.3)
        
        -- Kích hoạt hội thoại
        local prompt = npc:FindFirstChildOfClass("ProximityPrompt") or npc:GetComponentInChildren("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(0.4)
            
            -- Chọn mục thoại #1: Bán hết tất cả trong kho đồ
            local dialogGui = player.PlayerGui:FindFirstChild("DialogGui") or player.PlayerGui:FindFirstChild("TalkGui")
            if dialogGui then
                for _, option in pairs(dialogGui:GetDescendants()) do
                    if option:IsA("TextButton") and (option.Text:match("1") or option.Name:match("Option1") or option.Name:match("1")) then
                        for _, connection in pairs(getconnections(option.MouseButton1Click)) do
                            connection:Fire()
                        end
                        break
                    end
                end
            end
        end
        task.wait(0.3)
        -- Khôi phục lại trạng thái nhặt trái sau khi bán sạch kho đồ thành công
        _G.AutoHarvest = oldHarvest
        _G.AutoSteal = oldSteal
    end
end

-- Hàm thực hiện tự động tương tác NPC mua hạt nhiều lần
local function autoBuySeedsWorkflow()
    local player = game.Players.LocalPlayer
    local seedNPC = workspace:FindFirstChild("SeedMerchant") or workspace:FindFirstChild("SeedNPC") or workspace:FindFirstChild("NPC")
    
    if seedNPC and seedNPC:FindFirstChild("HumanoidRootPart") then
        safeTeleport(seedNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
        task.wait(0.3)
        
        local prompt = seedNPC:FindFirstChildOfClass("ProximityPrompt") or seedNPC:GetComponentInChildren("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(0.4)
            
            -- Chọn mục nói chuyện số #1 để mở bảng chọn hoặc tiến hành mua trực tiếp
            local dialogGui = player.PlayerGui:FindFirstChild("DialogGui") or player.PlayerGui:FindFirstChild("TalkGui")
            if dialogGui then
                for _, option in pairs(dialogGui:GetDescendants()) do
                    if option:IsA("TextButton") and (option.Text:match("1") or option.Name:match("Option1") or option.Name:match("1")) then
                        for _, connection in pairs(getconnections(option.MouseButton1Click)) do
                            connection:Fire()
                        end
                        break
                    end
                end
            end
        end
    end
end

--- ===========================================================================
--- TAB 1: PHÂN VƯỜN TRỒNG & TỰ ĐỘNG MUA HẠT
--- ===========================================================================
MainTab:CreateSection("Quản Lý Thu Hoạch & Gieo Hạt")

MainTab:CreateToggle({
   Name = "Tự Động Thu Hoạch Trái (Auto Harvest)",
   CurrentValue = false,
   Flag = "ToggleHarvest",
   Callback = function(Value)
      _G.AutoHarvest = Value
      task.spawn(function()
          while _G.AutoHarvest do
              task.wait(0.4)
              pcall(function()
                  local player = game.Players.LocalPlayer
                  local isFull = false
                  
                  -- Kiểm tra lỗi đầy kho hiển thị trên GUI như video 1000021081.mp4
                  for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                      if gui:IsA("TextLabel") and gui.Text:match("Inventory is full") and gui.Visible then
                          isFull = true
                          break
                      end
                  end
                  
                  -- Sửa lỗi trên video: Kho đầy -> Tự động dừng nhặt -> Tự động đi Sell -> Bán xong tự kích hoạt lại
                  if isFull then
                      autoSellWorkflow()
                  else
                      for _, v in pairs(workspace:GetDescendants()) do
                          if _G.AutoHarvest and v:IsA("ProximityPrompt") and (v.ActionText:match("Harvest") or v.ActionText:match("Thu hoạch") or v.ActionText:match("Pick")) then
                              if v.Parent and v.Parent:IsA("BasePart") then
                                  player.Character.HumanoidRootPart.CFrame = v.Parent.CFrame * CFrame.new(0, 1, 0)
                                  task.wait(0.1)
                                  fireproximityprompt(v)
                              end
                          end
                      end
                  end
              end)
          end
      end)
   end,
})

MainTab:CreateSection("Cửa Hàng Hạt Giống Tại Vườn")

MainTab:CreateDropdown({
   Name = "Bảng Chọn Loại Hạt Muốn Mua",
   Options = SeedList,
   CurrentOption = {"Strawberry"},
   MultipleOptions = false,
   Flag = "DropdownBuySeed",
   Callback = function(Option)
      _G.SelectedSeedToBuy = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "Tự Động Mua Hạt Giống Liên Tục",
   CurrentValue = false,
   Flag = "ToggleBuySeeds",
   Callback = function(Value)
      _G.AutoBuySeeds = Value
      task.spawn(function()
          while _G.AutoBuySeeds do
              autoBuySeedsWorkflow()
              task.wait(2) -- Tần suất giãn cách giữa các lần mua lặp lại liên tục khi NPC bán
          end
      end)
   end,
})

--- ===========================================================================
--- TAB 2: TỰ ĐỘNG ĐI TRỘM ĐÊM
--- ===========================================================================
StealTab:CreateSection("Hệ Thống Trộm Đồ")

StealTab:CreateToggle({
   Name = "Kích Hoạt Tự Động Trộm Trái Cây",
   CurrentValue = false,
   Flag = "ToggleSteal",
   Callback = function(Value)
      _G.AutoSteal = Value
      task.spawn(function()
          while _G.AutoSteal do
              task.wait(0.4)
              pcall(function()
                  local player = game.Players.LocalPlayer
                  local isFull = false
                  
                  for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                      if gui:IsA("TextLabel") and gui.Text:match("Inventory is full") and gui.Visible then
                          isFull = true
                          break
                      end
                  end

                  if isFull then
                      autoSellWorkflow()
                  else
                      local clockTime = game.Lighting.ClockTime
                      if clockTime >= 18 or clockTime <= 5 then
                          for _, v in pairs(workspace:GetDescendants()) do
                              if _G.AutoSteal and v:IsA("ProximityPrompt") and (v.ActionText:match("Steal") or v.ActionText:match("Trộm")) then
                                  if v.Parent and v.Parent:IsA("BasePart") then
                                      player.Character.HumanoidRootPart.CFrame = v.Parent.CFrame * CFrame.new(0, 1, 0)
                                      task.wait(0.1)
                                      fireproximityprompt(v)
                                  end
                              end
                          end
                      end
                  end
              end)
          end
      end)
   end,
})

--- ===========================================================================
--- TAB 3: SỰ KIỆN HẠT GIỐNG TỰ ĐỘNG DI CHUYỂN
--- ===========================================================================
ShopTab:CreateSection("Sự Kiện Đặc Biệt")

ShopTab:CreateToggle({
   Name = "Tự Động Tới Lấy Hạt Giống Khi Có Event",
   CurrentValue = false,
   Flag = "ToggleEventSeed",
   Callback = function(Value)
      _G.AutoEventSeed = Value
      task.spawn(function()
          while _G.AutoEventSeed do
              task.wait(0.5)
              pcall(function()
                  for _, obj in pairs(workspace:GetChildren()) do
                      if obj:IsA("BasePart") and (obj.Name:match("Seed") or obj.Name:match("Event") or obj.Name:match("Hạt giống")) then
                          safeTeleport(obj.CFrame * CFrame.new(0, 1, 0))
                          task.wait(0.2)
                      elseif obj:IsA("Model") and (obj.Name:match("Seed") or obj.Name:match("Event")) then
                          local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                          if primary then
                              safeTeleport(primary.CFrame * CFrame.new(0, 1, 0))
                              task.wait(0.2)
                          end
                      end
                  end
              end)
          end
      end)
   end,
})

--- ===========================================================================
--- TAB 4: THIẾT LẬP HỆ THỐNG & TREO MÁY XUYÊN ĐÊM (GIẢM LAG + ANTI-AFK)
--- ===========================================================================
SystemTab:CreateSection("Cấu Hình Treo Máy Xuyên Đêm")

-- Tính năng 1: Thiết lập Anti-AFK trong mục cài đặt bảo vệ hệ thống
SystemTab:CreateToggle({
   Name = "Kích Hoạt Tính Năng Chống Treo Máy (Anti-AFK)",
   CurrentValue = true,
   Flag = "ToggleAntiAFK",
   Callback = function(Value)
      _G.AntiAFK = Value
      if Value then
          Rayfield:Notify({Title = "Hệ Thống", Content = "Anti-AFK đang bảo vệ ngầm.", Duration = 2})
      end
   end,
})

-- Kích hoạt vòng lặp ảo mô phỏng tương tác phần cứng chặn đứng Roblox Kick
local virtualUser = game:GetService("VirtualUser")
game.Players.LocalPlayer.Idled:Connect(function()
   if _G.AntiAFK then
       virtualUser:CaptureController()
       virtualUser:ClickButton2(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
       task.wait(0.5)
   end
end)

-- Tính năng 2: Chế độ giảm lag đồ họa cực đoan để cày đêm mát máy
SystemTab:CreateToggle({
   Name = "Chế Độ Siêu Giảm Lag Mạnh (Xóa Texture & Khóa 15 FPS)",
   CurrentValue = false,
   Flag = "SuperLagReduction",
   Callback = function(Value)
      _G.SuperLagReduction = Value
      if Value then
          pcall(function()
              settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
              game:GetService("Lighting").GlobalShadows = false
              
              for _, v in pairs(workspace:GetDescendants()) do
                  if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") then
                      v.Enabled = false
                  elseif v:IsA("Decal") or v:IsA("Texture") then
                      v:Destroy()
                  elseif v:IsA("BasePart") then
                      v.Material = Enum.Material.SmoothPlastic
                      v.Reflectance = 0
                  end
              end
              
              if setfpscap then
                  setfpscap(15) -- Giới hạn 15 FPS giúp giải phóng CPU/GPU khi ngủ
              end
          end)
          Rayfield:Notify({Title = "Hệ Thống", Content = "Đã bật cấu hình siêu mượt cày đêm!", Duration = 3})
      else
          if setfpscap then
              setfpscap(60)
          end
      end
   end,
})

SystemTab:CreateButton({
   Name = "Tắt Hoàn Toàn Script",
   Callback = function()
      _G.AutoHarvest = false
      _G.AutoSteal = false
      _G.AutoEventSeed = false
      _G.AutoBuySeeds = false
      _G.SuperLagReduction = false
      _G.AntiAFK = false
      if setfpscap then setfpscap(60) end
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "ahgrow v1.8 Hoàn Tất!",
   Content = "Chúc bạn chơi game vui vẻ! Hệ thống đã chạy ngầm.",
   Duration = 5,
   Image = "check"
})
