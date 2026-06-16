local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ahgrow v1 🌿",
   LoadingTitle = "ahgrow v1 Premium",
   LoadingSubtitle = "Đã Vá Lỗi Theo Video Thực Tế",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

_G.AutoHarvest = false
_G.AutoSteal = false
_G.AutoSellFull = false
_G.TargetPlayer = ""
_G.FlingLoop = false
_G.SelectedPlant = "Strawberry"

local SeedList = {"Strawberry", "Lúa mì", "Cà rốt", "Cà chua", "Dưa hấu", "Bắp"}

local MainTab = Window:CreateTab("Tự Động", "leaf")
local StealTab = Window:CreateTab("Trộm Đồ", "shield-alert")
local TrollTab = Window:CreateTab("Phá Hoại", "zap")
local ShopTab = Window:CreateTab("Cửa Hàng", "shopping-cart")
local SystemTab = Window:CreateTab("Hệ Thống", "sliders")

local function clickSellButton()
    pcall(function()
        local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetDescendants()) do
                if gui:IsA("TextButton") and (gui.Text:lower():match("sell") or gui.Name:lower():match("sell")) then
                    if gui.Visible then
                        for _, connection in pairs(getconnections(gui.MouseButton1Click)) do
                            connection:Fire()
                        end
                        for _, connection in pairs(getconnections(gui.MouseButton1Down)) do
                            connection:Fire()
                        end
                    end
                end
            end
        end
    end)
end

MainTab:CreateSection("Quản Lý Thu Hoạch & Gieo Hạt")

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
                      if v:IsA("ProximityPrompt") and (v.ActionText:match("Harvest") or v.ActionText:match("Thu hoạch") or v.ActionText:match("Pick")) then
                          if v.Parent and v.Parent:IsA("BasePart") then
                              local player = game.Players.LocalPlayer
                              if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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

StealTab:CreateSection("Hệ Thống Trộm Đêm")

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
                  local clockTime = game.Lighting.ClockTime
                  if clockTime >= 18 or clockTime <= 5 then
                      for _, v in pairs(workspace:GetDescendants()) do
                          if v:IsA("ProximityPrompt") and (v.ActionText:match("Steal") or v.ActionText:match("Trộm")) then
                              if v.Parent and v.Parent:IsA("BasePart") then
                                  local player = game.Players.LocalPlayer
                                  if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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

TrollTab:CreateSection("Làm Văng Người Chơi Để Trộm (Fling)")

TrollTab:CreateInput({
   Name = "Nhập Tên Người Muốn Làm Văng",
   PlaceholderText = "Tên người chơi...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       for _, p in pairs(game.Players:GetPlayers()) do
           if p.Name:lower():sub(1, #Text) == Text:lower() or p.DisplayName:lower():sub(1, #Text) == Text:lower() then
               _G.TargetPlayer = p.Name
               Rayfield:Notify({Title = "ahgrow v1", Content = "Mục tiêu đã chọn: " .. p.Name, Duration = 3})
               break
           end
       end
   end,
})

TrollTab:CreateToggle({
   Name = "Bật Vòng Lặp Làm Văng Mục Tiêu (Fling)",
   CurrentValue = false,
   Flag = "FlingToggle",
   Callback = function(Value)
      _G.FlingLoop = Value
      task.spawn(function()
          local lplr = game.Players.LocalPlayer
          while _G.FlingLoop do
              task.wait(0.1)
              pcall(function()
                  local target = game.Players:FindFirstChild(_G.TargetPlayer)
                  if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                      local bV = Instance.new("BodyAngularVelocity")
                      bV.AngularVelocity = Vector3.new(0, 99999, 0)
                      bV.MaxTorque = Vector3.new(0, math.huge, 0)
                      bV.Parent = lplr.Character.HumanoidRootPart
                      
                      lplr.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0.5)
                      
                      task.wait(0.2)
                      bV:Destroy()
                  end
              end)
          end
      end)
   end,
})

ShopTab:CreateSection("Quản Lý Giao Thương")

ShopTab:CreateToggle({
   Name = "Tự Động Bán Khi Đầy Kho (Auto Sell)",
   CurrentValue = false,
   Flag = "ToggleSellAll",
   Callback = function(Value)
      _G.AutoSellFull = Value
      task.spawn(function()
          while _G.AutoSellFull do
              task.wait(0.5)
              pcall(function()
                  local localPlayer = game.Players.LocalPlayer
                  local inventoryText = ""
                  
                  for _, v in pairs(localPlayer.PlayerGui:GetDescendants()) do
                      if v:IsA("TextLabel") and v.Text:match("Inventory is full") then
                          inventoryText = v.Text
                          break
                      end
                  end
                  
                  if inventoryText ~= "" or localPlayer.Character: someMethod() then
                      clickSellButton()
                  else
                      local label = localPlayer.PlayerGui:FindFirstChild("Inventory", true)
                      if label and label:IsA("TextLabel") and label.Text:match("%[%s*%d+%s*/%s*%d+%s*%]") then
                          clickSellButton()
                      end
                  end
              end)
          end
      end)
   end,
})

SystemTab:CreateSection("Tối Ưu Hoá Đồ Hoạ")

SystemTab:CreateToggle({
   Name = "Bật Chế Độ Giảm Lag",
   CurrentValue = false,
   Flag = "ToggleLag",
   Callback = function(Value)
      if Value then
          pcall(function()
              settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
              for _, v in pairs(workspace:GetDescendants()) do
                  if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Decal") then
                      v.Enabled = false
                  end
              end
          end)
      end
   end,
})

SystemTab:CreateButton({
   Name = "Tắt Hoàn Toàn Script",
   Callback = function()
      _G.AutoHarvest = false
      _G.AutoSteal = false
      _G.FlingLoop = false
      _G.AutoSellFull = false
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "ahgrow v1 Hoàn Tất!",
   Content = "Hệ thống đã sẵn sàng hoạt động.",
   Duration = 4,
   Image = "check"
})
