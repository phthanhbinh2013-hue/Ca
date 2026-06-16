local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ahgrow v1.6 🌿 (AFK Edition)",
   LoadingTitle = "ahgrow v1.6 - Treo Máy Siêu Mượt",
   LoadingSubtitle = "Hệ Thống Tối Ưu Giảm Lag & Chống AFK",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Biến cấu hình trạng thái (Global Variables)
_G.AutoHarvest = false
_G.AutoSteal = false
_G.AutoEventSeed = false
_G.SuperLagReduction = false
_G.TargetPlayer = ""
_G.FlingLoop = false
_G.SelectedPlant = "Strawberry"

local SeedList = {"Strawberry", "Lúa mì", "Cà rốt", "Cà chua", "Dưa hấu", "Bắp"}

-- Khởi tạo các Tab chức năng trên UI
local MainTab = Window:CreateTab("Nông Trại", "leaf")
local StealTab = Window:CreateTab("Trộm Đêm", "shield-alert")
local ShopTab = Window:CreateTab("Cửa Hàng", "shopping-cart")
local SystemTab = Window:CreateTab("Hệ Thống", "sliders")

--- ===========================================================================
--- HÀM DI CHUYỂN AN TOÀN VÀ TƯƠNG TÁC NPC
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

local function executeNPCSellWorkflow()
    pcall(function()
        local player = game.Players.LocalPlayer
        
        _G.AutoHarvest = false
        _G.AutoSteal = false
        
        local npc = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("SellNPC") or workspace:FindFirstChild("NPC")
        if npc and npc:FindFirstChild("HumanoidRootPart") then
            safeTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
            task.wait(0.3)
            
            local prompt = npc:FindFirstChildOfClass("ProximityPrompt") or npc:GetComponentInChildren("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
                task.wait(0.4)
                
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
    end)
end

--- ===========================================================================
--- TAB 1: NÔNG TRẠI (MAIN FARM)
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
                      _G.AutoHarvest = false
                      executeNPCSellWorkflow()
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

MainTab:CreateDropdown({
   Name = "Lựa Chọn Loại Hạt Giống",
   Options = SeedList,
   CurrentOption = {"Strawberry"},
   MultipleOptions = false,
   Flag = "DropdownSeed",
   Callback = function(Option)
      _G.SelectedPlant = Option[1]
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
                      _G.AutoSteal = false
                      executeNPCSellWorkflow()
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
--- TAB 3: SỰ KIỆN & THƯƠNG NHÂN (NÚT SELL)
--- ===========================================================================
ShopTab:CreateSection("Sự Kiện & Thương Nhân")

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

ShopTab:CreateButton({
   Name = "Sell (Dịch chuyển tới NPC -> Nói chuyện -> Bán hết sạch mục #1)",
   Callback = function()
       executeNPCSellWorkflow()
   end,
})

--- ===========================================================================
--- TAB 4: HỆ THỐNG GIẢM LAG CỰC ĐOAN & ANTI-AFK BAO TREO ĐÊM
--- ===========================================================================
SystemTab:CreateSection("Bảo Vệ Máy & Chống Thoát Game")

-- [1] HỆ THỐNG ANTI-AFK PHẦN CỨNG (Luôn chạy ngầm bảo vệ)
local virtualUser = game:GetService("VirtualUser")
game.Players.LocalPlayer.Idled:Connect(function()
   virtualUser:CaptureController()
   virtualUser:ClickButton2(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
   task.wait(0.5)
end)

-- [2] TÍNH NĂNG GIẢM LAG MẠNH CHUYÊN TREO ĐÊM (Cực Kỳ Khuyên Dùng)
SystemTab:CreateToggle({
   Name = "Chế Độ Siêu Giảm Lag (Mượt 99% - Dành Cho Treo Máy)",
   CurrentValue = false,
   Flag = "SuperLagReduction",
   Callback = function(Value)
      _G.SuperLagReduction = Value
      if Value then
          pcall(function()
              -- Hạ đồ họa toàn bộ game xuống mức thấp nhất của engine
              settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
              game:GetService("Lighting").GlobalShadows = false
              game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
              
              -- Xóa toàn bộ hiệu ứng thừa thãi làm nặng máy khi AFK
              for _, v in pairs(workspace:GetDescendants()) do
                  if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") then
                      v.Enabled = false
                  elseif v:IsA("Decal") or v:IsA("Texture") then
                      v:Destroy() -- Xóa luôn ảnh dán trên bề mặt để giảm card đồ họa
                  elseif v:IsA("BasePart") then
                      v.Material = Enum.Material.SmoothPlastic -- Ép tất cả các khối thành nhựa mịn, triệt tiêu vân vật liệu nặng
                      v.Reflectance = 0
                  end
              end
              
              -- Giới hạn FPS trò chơi về mức 15 FPS (Giúp CPU/GPU ngủ đông cực mát máy khi treo)
              if setfpscap then
                  setfpscap(15)
              end
          end)
          Rayfield:Notify({Title = "Hệ Thống", Content = "Đã tối ưu hóa cấu hình siêu nhẹ và khóa 15 FPS để cày!", Duration = 4})
      else
          -- Khôi phục về mặc định nếu tắt tính năng
          if setfpscap then
              setfpscap(60)
          end
          Rayfield:Notify({Title = "Hệ Thống", Content = "Đã khôi phục mức FPS bình thường.", Duration = 3})
      end
   end,
})

SystemTab:CreateButton({
   Name = "Tắt Hoàn Toàn Script",
   Callback = function()
      _G.AutoHarvest = false
      _G.AutoSteal = false
      _G.AutoEventSeed = false
      _G.SuperLagReduction = false
      if setfpscap then setfpscap(60) end
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "ahgrow v1.6 Hoàn Tất!",
   Content = "Bản Treo Máy: Chống AFK và Ép Đồ Họa Đã Sẵn Sàng.",
   Duration = 5,
   Image = "check"
})
