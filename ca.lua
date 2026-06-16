local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ahgrow v2.1 🌿 (Instant Buy & Smart Sell)",
   LoadingTitle = "ahgrow v2.1 Premium",
   LoadingSubtitle = "Chúc bạn chơi game vui vẻ! 🎉",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Các biến trạng thái logic toàn cục
_G.AutoHarvest = false
_G.AutoSteal = false
_G.AutoEventSeed = false
_G.AutoBuySeeds = false
_G.AutoExpandPlot = false
_G.SuperLagReduction = false
_G.AntiAFK = true

-- Thiết lập cấu hình thứ tự ưu tiên mua cây (Mặc định xếp từ cao xuống thấp)
_G.Priority1 = "Carrot"
_G.Priority2 = "Strawberry"
_G.Priority3 = "Blueberry"

-- Cập nhật toàn bộ danh sách hạt giống bằng tiếng Anh theo game Grow A Garden 2
local SeedList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", 
    "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean", "Banana", "Grape", 
    "Coconut", "Mango", "Dragon Fruit", "Acorn", "Cherry", "Sunflower", 
    "Venus Fly Trap", "Pomegranate", "Poison Apple", "Moon Bloom", "Dragon's Breath"
}

-- Phân tách các Tab UI gọn gàng
local MainTab = Window:CreateTab("Vườn Trồng", "leaf")
local StealTab = Window:CreateTab("Trộm Đêm", "shield-alert")
local ShopTab = Window:CreateTab("Cửa Hàng", "shopping-cart")
local SystemTab = Window:CreateTab("Hệ Thống", "sliders")

--- ===========================================================================
--- HÀM BỔ TRỢ DI CHUYỂN & XỬ LÝ SỰ KIỆN TỰ ĐỘNG
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

-- Hệ thống Auto Sell hoàn toàn tự động: Tự động dừng nhặt khi bán đồ
local function autoSellWorkflow()
    local player = game.Players.LocalPlayer
    local npc = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("SellNPC") or workspace:FindFirstChild("NPC")
    
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        -- ÉP BUỘC DỪNG NHẶT TRÁI để tránh xung đột hệ thống khi túi đầy
        local oldHarvest = _G.AutoHarvest
        local oldSteal = _G.AutoSteal
        _G.AutoHarvest = false
        _G.AutoSteal = false
        
        -- Tiến hành dịch chuyển tới khu vực thương nhân bán đồ
        safeTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
        task.wait(0.3)
        
        local prompt = npc:FindFirstChildOfClass("ProximityPrompt") or npc:GetComponentInChildren("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(0.4)
            
            -- Chọn phản hồi số 1 để bán sạch kho đồ
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
        task.wait(0.5) -- Đợi hệ thống xử lý giao dịch bán tiền cộng vào tài khoản
        
        -- SAU KHI BÁN XONG: Tự động khôi phục và bật lại trạng thái cày cuốc ban đầu
        _G.AutoHarvest = oldHarvest
        _G.AutoSteal = oldSteal
    end
end

-- Tính năng phát hiện hạt giống ưu tiên trong shop và mua ngay lập tức
local function buySeedsByPriority()
    local player = game.Players.LocalPlayer
    local seedNPC = workspace:FindFirstChild("SeedMerchant") or workspace:FindFirstChild("SeedNPC") or workspace:FindFirstChild("NPC") or workspace:FindFirstChild("Sam")
    
    if seedNPC and seedNPC:FindFirstChild("HumanoidRootPart") then
        safeTeleport(seedNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
        task.wait(0.3)
        
        local prompt = seedNPC:FindFirstChildOfClass("ProximityPrompt") or seedNPC:GetComponentInChildren("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(0.5)
            
            local shopGui = player.PlayerGui:FindFirstChild("SeedShopGui") or player.PlayerGui:FindFirstChild("ShopGui") or player.PlayerGui:FindFirstChild("MerchantGui")
            if shopGui and shopGui.Enabled then
                local priorityOrder = {_G.Priority1, _G.Priority2, _G.Priority3}
                
                -- Quét tìm hạt giống theo cấp độ thiết lập ưu tiên
                for _, currentTargetTree in ipairs(priorityOrder) do
                    for _, itemCard in pairs(shopGui:GetDescendants()) do
                        if itemCard:IsA("TextLabel") and itemCard.Text:lower():match(currentTargetTree:lower()) then
                            local buyButton = itemCard.Parent:FindFirstChildOfClass("TextButton") or itemCard.Parent:FindFirstChild("BuyButton")
                            if buyButton then
                                for _, connection in pairs(getconnections(buyButton.MouseButton1Click)) do
                                    connection:Fire()
                                    task.wait(0.1)
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

--- ===========================================================================
--- TAB 1: PHÂN VƯỜN TRỒNG & THIẾT LẬP THỨ TỰ ƯU TIÊN MUA HẠT
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
                  
                  -- Quét GUI phát hiện trạng thái kho đồ bị đầy
                  for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                      if gui:IsA("TextLabel") and gui.Text:match("Inventory is full") and gui.Visible then
                          isFull = true
                          break
                      end
                  end
                  
                  if isFull then
                      autoSellWorkflow() -- Kích hoạt hàm: Dừng nhặt -> Đi bán -> Bán xong tự bật nhặt lại
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

MainTab:CreateSection("Cấu Hình Thứ Tự Ưu Tiên Mua Cây (Instant Scan)")

MainTab:CreateDropdown({
   Name = "Ưu Tiên Số 1 (Priority 1)",
   Options = SeedList,
   CurrentOption = {"Carrot"},
   MultipleOptions = false,
   Flag = "P1",
   Callback = function(Option) _G.Priority1 = Option[1] end,
})

MainTab:CreateDropdown({
   Name = "Ưu Tiên Số 2 (Priority 2)",
   Options = SeedList,
   CurrentOption = {"Strawberry"},
   MultipleOptions = false,
   Flag = "P2",
   Callback = function(Option) _G.Priority2 = Option[1] end,
})

MainTab:CreateDropdown({
   Name = "Ưu Tiên Số 3 (Priority 3)",
   Options = SeedList,
   CurrentOption = {"Blueberry"},
   MultipleOptions = false,
   Flag = "P3",
   Callback = function(Option) _G.Priority3 = Option[1] end,
})

MainTab:CreateToggle({
   Name = "Tự Động Quét Mua Khi Có Cây Ưu Tiên",
   CurrentValue = false,
   Flag = "ToggleBuySeedsPriority",
   Callback = function(Value)
      _G.AutoBuySeeds = Value
      task.spawn(function()
          while _G.AutoBuySeeds do
              task.wait(1)
              pcall(function()
                  local player = game.Players.LocalPlayer
                  local foundPrioritySeed = false
                  
                  -- Tìm kiếm trực tiếp trên UI của Shop xem có chứa tên các cây ưu tiên không
                  local shopGui = player.PlayerGui:FindFirstChild("SeedShopGui") or player.PlayerGui:FindFirstChild("ShopGui") or player.PlayerGui:FindFirstChild("MerchantGui")
                  if shopGui then
                      local priorities = {_G.Priority1, _G.Priority2, _G.Priority3}
                      for _, textLabel in pairs(shopGui:GetDescendants()) do
                          if textLabel:IsA("TextLabel") then
                              for _, seedName in ipairs(priorities) do
                                  if textLabel.Text:lower():match(seedName:lower()) then
                                      foundPrioritySeed = true
                                      break
                                  end
                              end
                          end
                          if foundPrioritySeed then break end
                      end
                  end
                  
                  -- Nếu phát hiện thấy cây nằm trong danh sách ưu tiên hoặc khi hệ thống Restock, mua ngay lập tức
                  if foundPrioritySeed then
                      buySeedsByPriority()
                      task.wait(5) -- Dãn cách thời gian quét tiếp theo sau khi mua thành công
                  else
                      -- Quét dự phòng liên tục để không bị bỏ lỡ lượt hàng
                      buySeedsByPriority()
                      task.wait(10)
                  end
              end)
          end
      end)
   end,
})

MainTab:CreateSection("Bản Mở Rộng Đất (Grow A Garden 2)")

MainTab:CreateToggle({
   Name = "Tự Động Mở Rộng Ô Đất (Auto Expand Plot)",
   CurrentValue = false,
   Flag = "ToggleExpandPlot",
   Callback = function(Value)
      _G.AutoExpandPlot = Value
      task.spawn(function()
          while _G.AutoExpandPlot do
              task.wait(3)
              pcall(function()
                  for _, obj in pairs(workspace:GetDescendants()) do
                      if _G.AutoExpandPlot and obj:IsA("BasePart") and (obj.Name:match("Expand") or obj.Name:match("Plot") or obj.Name:match("Mở rộng")) then
                          local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
                          if prompt then
                              local player = game.Players.LocalPlayer
                              player.Character.HumanoidRootPart.CFrame = obj.CFrame * CFrame.new(0, 2, 0)
                              task.wait(0.2)
                              fireproximityprompt(prompt)
                          end
                      end
                  end
              end)
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

SystemTab:CreateToggle({
   Name = "Kích Hoạt Tính Năng Chống Treo Máy (Anti-AFK)",
   CurrentValue = true,
   Flag = "ToggleAntiAFK",
   Callback = function(Value)
      _G.AntiAFK = Value
   end
})

local virtualUser = game:GetService("VirtualUser")
game.Players.LocalPlayer.Idled:Connect(function()
   if _G.AntiAFK then
       virtualUser:CaptureController()
       virtualUser:ClickButton2(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
       task.wait(0.5)
   end
end)

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
              if setfpscap then setfpscap(15) end
          end)
      else
          if setfpscap then setfpscap(60) end
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
      _G.AutoExpandPlot = false
      _G.SuperLagReduction = false
      _G.AntiAFK = false
      if setfpscap then setfpscap(60) end
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "ahgrow v2.1 Hoàn Tất!",
   Content = "Hệ thống Instant Buy & Smart Auto Sell đã sẵn sàng hoạt động.",
   Duration = 5,
   Image = "check"
})
