local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cấu hình trạng thái hệ thống toàn cục
_G.CurrentLang = "VN"
_G.AutoHarvest = false
_G.AutoSteal = false
_G.AutoSell = false
_G.AutoSeeds = false
_G.AntiAFK = true
_G.LagReductionLevel = 0 -- 0: Tắt, 1: Thường, 2: Cấp 2 Siêu Mạnh

-- 3 Hạt giống ưu tiên do bạn chọn
_G.Priority1 = "Carrot"
_G.Priority2 = "Strawberry"
_G.Priority3 = "Blueberry"

local SeedList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", 
    "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean", "Banana", "Grape", 
    "Coconut", "Mango", "Dragon Fruit", "Acorn", "Cherry", "Sunflower", 
    "Venus Fly Trap", "Pomegranate", "Poison Apple", "Moon Bloom", "Dragon's Breath"
}

-- Khởi tạo Menu chính
local Window = Rayfield:CreateWindow({
   Name = "ahgrow v2.7 🌿 Premium Smooth Suite",
   LoadingTitle = "ahgrow Premium v2.7",
   LoadingSubtitle = "Fix Ngôn Ngữ & Thêm Giảm Lag Cấp 2 🚀",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Tạo các Tab với Icon trực quan
local MainTab = Window:CreateTab("Khu Vườn (Garden)", "leaf") 
local StealTab = Window:CreateTab("Trộm Đêm (Steal)", "moon") 
local ShopSellTab = Window:CreateTab("Cửa Hàng Sell", "dollar-sign")
local ShopSeedsTab = Window:CreateTab("Cửa Hàng Seeds", "shopping-bag")
local SystemTab = Window:CreateTab("Cài Đặt (Settings)", "settings") 

-- ===========================================================================
-- HỆ THỐNG CẬP NHẬT NGÔN NGỮ ĐA TẦNG (FIX LỖI)
-- ===========================================================================
local UIElements = {}

local function ApplyLanguageUpdate()
    local isVN = (_G.CurrentLang == "VN")
    
    -- Từ điển dịch thuật
    local trans = {
        SecHarvest = isVN and "Quản Lý Thu Hoạch Tự Động" or "Auto Harvest Management",
        ToggleHarvest = isVN and "Tự Động Thu Hoạch Trái (Auto Harvest)" or "Auto Harvest Fruits",
        SecSteal = isVN and "Tự Động Đi Trộm Đồ" or "Auto Steal System",
        ToggleSteal = isVN and "Kích Hoạt Auto Trộm Trái Cây Đêm" or "Enable Night Steal Mode",
        SecSell = isVN and "⚡ Tuyến Đường Tự Động Đi Bán Trái" or "⚡ Auto Sell Walk Route",
        ToggleSell = isVN and "Bật Auto Sell Đi Bộ Khi Đầy Kho" or "Enable Auto Walk Sell on Full",
        SecSeeds1 = isVN and "📋 Cài Đặt 3 Hạt Giống Ưu Tiên" or "📋 Priority Seeds Settings",
        SecSeeds2 = isVN and "⚡ Tuyến Đường Auto Seeds Khi Có Tải Lại Kho" or "⚡ Auto Seeds Route on Restock",
        ToggleSeeds = isVN and "Bật Auto Mua Hạt Khi Reset Stock" or "Enable Auto Buy Seeds on Restock",
        SecLang = isVN and "Cấu Hình Ngôn Ngữ Hệ Thống" or "System Language Settings",
        ResetBtn = isVN and "Nút Reset Ngôn Ngữ Về Mặc Định" or "Reset Language to Default"
    }

    -- Cập nhật chữ hiển thị trực tiếp vào phần tử UI
    pcall(function()
        for key, text in pairs(trans) do
            if UIElements[key] then 
                UIElements[key]:SetText(text)
            end
        end
    end)
end

-- ===========================================================================
-- HỆ THỐNG GIẢM LAG CẤP 2 (SUPER EXTREME SMOOTH MODE)
-- ===========================================================================
local function ApplyLagReduction()
    if _G.LagReductionLevel == 0 then
        if setfpscap then setfpscap(60) end
    elseif _G.LagReductionLevel == 1 then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game:GetService("Lighting").GlobalShadows = false
        if setfpscap then setfpscap(45) end
    elseif _G.LagReductionLevel == 2 then
        -- KÍCH HOẠT GIẢM LAG CẤP 2 BIẾN GAME THÀNH LOW POLY
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").BlurEffects:Clear()
            
            -- Ép tất cả các vật thể thành chất liệu trơn bóng cơ bản để giảm tải GPU
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy()
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then
                    v.Enabled = false
                end
            end
            
            -- Khóa FPS thấp để máy siêu mát khi cày đêm
            if setfpscap then setfpscap(20) end
        end)
    end
end

-- ===========================================================================
-- LOGIC ĐI BỘ (WALK LOGIC)
-- ===========================================================================
local function walkToPosition(targetPos)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        humanoid:MoveTo(targetPos)
        local startTime = tick()
        while (rootPart.Position - targetPos).Magnitude > 5 and (tick() - startTime) < 12 do
            task.wait(0.1)
            humanoid:MoveTo(targetPos)
        end
        return (rootPart.Position - targetPos).Magnitude <= 5
    end
    return false
end

-- CON ĐƯỜNG 1: AUTO SELL
local function runAutoSellRoute()
    local player = game.Players.LocalPlayer
    _G.AutoHarvest = false
    _G.AutoSteal = false
    task.wait(0.1)
    
    local sellNPC = workspace:FindFirstChild("Steven") or workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("SellNPC")
    if sellNPC and sellNPC:FindFirstChild("HumanoidRootPart") then
        local reachedSell = walkToPosition(sellNPC.HumanoidRootPart.Position)
        if reachedSell then
            task.wait(0.3)
            local prompt = sellNPC:FindFirstChildOfClass("ProximityPrompt") or sellNPC:GetComponentInChildren("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
                task.wait(0.5)
                
                local dialogGui = player.PlayerGui:FindFirstChild("DialogGui") or player.PlayerGui:FindFirstChild("TalkGui")
                if dialogGui then
                    for _, option in pairs(dialogGui:GetDescendants()) do
                        if option:IsA("TextButton") and (option.Text:match("1") or option.Name:match("1")) then
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
    _G.AutoHarvest = true
end

-- CON ĐƯỜNG 2: AUTO SEEDS
local function runAutoSeedsRoute()
    local player = game.Players.LocalPlayer
    local seedNPC = workspace:FindFirstChild("Sam") or workspace:FindFirstChild("SeedMerchant") or workspace:FindFirstChild("SeedNPC")
    if seedNPC and seedNPC:FindFirstChild("HumanoidRootPart") then
        local reachedSeeds = walkToPosition(seedNPC.HumanoidRootPart.Position)
        if reachedSeeds then
            task.wait(0.3)
            local prompt = seedNPC:FindFirstChildOfClass("ProximityPrompt") or seedNPC:GetComponentInChildren("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
                task.wait(0.6)
                
                local shopGui = player.PlayerGui:FindFirstChild("SeedShopGui") or player.PlayerGui:FindFirstChild("ShopGui")
                if shopGui and shopGui.Enabled then
                    local targets = {_G.Priority1, _G.Priority2, _G.Priority3}
                    for _, targetSeed in ipairs(targets) do
                        for _, item in pairs(shopGui:GetDescendants()) do
                            if item:IsA("TextLabel") and string.lower(item.Text) == string.lower(targetSeed) then
                                local itemButton = item.Parent:IsA("TextButton") and item.Parent or item.Parent:FindFirstChildOfClass("TextButton")
                                if itemButton then
                                    for _, conn in pairs(getconnections(itemButton.MouseButton1Click)) do
                                        conn:Fire()
                                    end
                                    task.wait(0.2)
                                    
                                    for _, btn in pairs(shopGui:GetDescendants()) do
                                        if btn:IsA("TextButton") and (btn.BackgroundColor3 == Color3.fromRGB(0, 255, 0) or btn.BackgroundColor3 == Color3.fromRGB(0, 200, 0) or btn.Name:lower():match("buy") or btn.Text:lower():match("buy")) then
                                            for _, buyConn in pairs(getconnections(btn.MouseButton1Click)) do
                                                buyConn:Fire()
                                            end
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ===========================================================================
-- KHỞI TẠO CÁC PHẦN TỬ GIAO DIỆN
-- ===========================================================================
UIElements.SecHarvest = MainTab:CreateSection("Quản Lý Thu Hoạch Tự Động")

UIElements.ToggleHarvest = MainTab:CreateToggle({
   Name = "Tự Động Thu Hoạch Trái (Auto Harvest)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoHarvest = Value
      task.spawn(function()
          while _G.AutoHarvest do
              task.wait(0.5)
              pcall(function()
                  local player = game.Players.LocalPlayer
                  local isFull = false
                  for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                      if gui:IsA("TextLabel") and (gui.Text:match("Inventory is full") or gui.Text:match("full")) and gui.Visible then
                          isFull = true
                          break
                      end
                  end
                  if isFull and _G.AutoSell then
                      runAutoSellRoute()
                  else
                      for _, v in pairs(workspace:GetDescendants()) do
                          if _G.AutoHarvest and v:IsA("ProximityPrompt") and (v.ActionText:match("Harvest") or v.ActionText:match("Pick")) then
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

UIElements.SecSteal = StealTab:CreateSection("Tự Động Đi Trộm Đồ")

UIElements.ToggleSteal = StealTab:CreateToggle({
   Name = "Kích Hoạt Auto Trộm Trái Cây Đêm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoSteal = Value
      task.spawn(function()
          while _G.AutoSteal do
              task.wait(0.5)
              pcall(function()
                  local clockTime = game.Lighting.ClockTime
                  if clockTime >= 18 or clockTime <= 5 then
                      for _, v in pairs(workspace:GetDescendants()) do
                          if _G.AutoSteal and v:IsA("ProximityPrompt") and v.ActionText:match("Steal") then
                              if v.Parent and v.Parent:IsA("BasePart") then
                                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Parent.CFrame * CFrame.new(0, 1, 0)
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

UIElements.SecSell = ShopSellTab:CreateSection("⚡ Tuyến Đường Tự Động Đi Bán Trái")

UIElements.ToggleSell = ShopSellTab:CreateToggle({
   Name = "Bật Auto Sell Đi Bộ Khi Đầy Kho",
   CurrentValue = false,
   Callback = function(Value) _G.AutoSell = Value end,
})

UIElements.SecSeeds1 = ShopSeedsTab:CreateSection("📋 Cài Đặt 3 Hạt Giống Ưu Tiên")

ShopSeedsTab:CreateDropdown({
   Name = "Priority 1",
   Options = SeedList,
   CurrentOption = {"Carrot"},
   MultipleOptions = false,
   Callback = function(Option) _G.Priority1 = Option[1] end,
})

ShopSeedsTab:CreateDropdown({
   Name = "Priority 2",
   Options = SeedList,
   CurrentOption = {"Strawberry"},
   MultipleOptions = false,
   Callback = function(Option) _G.Priority2 = Option[1] end,
})

ShopSeedsTab:CreateDropdown({
   Name = "Priority 3",
   Options = SeedList,
   CurrentOption = {"Blueberry"},
   MultipleOptions = false,
   Callback = function(Option) _G.Priority3 = Option[1] end,
})

UIElements.SecSeeds2 = ShopSeedsTab:CreateSection("⚡ Tuyến Đường Auto Seeds Khi Có Tải Lại Kho")

UIElements.ToggleSeeds = ShopSeedsTab:CreateToggle({
   Name = "Bật Auto Mua Hạt Khi Reset Stock",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoSeeds = Value
      if Value then
          task.spawn(function()
              local lastRestockState = ""
              while _G.AutoSeeds do
                  task.wait(1)
                  pcall(function()
                      local player = game.Players.LocalPlayer
                      local restockLabel = nil
                      for _, v in pairs(player.PlayerGui:GetDescendants()) do
                          if v:IsA("TextLabel") and (v.Text:match("Restock in") or v.Text:match("Reset in")) then
                              restockLabel = v
                              break
                          end
                      end
                      if restockLabel then
                          if restockLabel.Text ~= lastRestockState and (restockLabel.Text:match("5m") or restockLabel.Text:match("4m 59s")) then
                              lastRestockState = restockLabel.Text
                              runAutoSeedsRoute()
                          end
                      else
                          runAutoSeedsRoute()
                          task.wait(20)
                      end
                  end)
              end
          end)
      end
   end,
})

UIElements.SecLang = SystemTab:CreateSection("Cấu Hình Ngôn Ngữ Hệ Thống")

local LangDropdown = SystemTab:CreateDropdown({
   Name = "Chọn Ngôn Ngữ / Select Language",
   Options = {"Tiếng Việt (VN)", "English (EN)"},
   CurrentOption = {"Tiếng Việt (VN)"},
   MultipleOptions = false,
   Callback = function(Option)
      if Option[1] == "Tiếng Việt (VN)" then
          _G.CurrentLang = "VN"
      else
          _G.CurrentLang = "EN"
      end
      ApplyLanguageUpdate()
   end,
})

UIElements.ResetBtn = SystemTab:CreateButton({
   Name = "Nút Reset Ngôn Ngữ Về Mặc Định",
   Callback = function()
       _G.CurrentLang = "VN"
       LangDropdown:Set({"Tiếng Việt (VN)"})
       ApplyLanguageUpdate()
   end,
})

SystemTab:CreateSection("Tối Ưu Treo Máy AFK & Giảm Tải Phần Cứng")

SystemTab:CreateDropdown({
   Name = "Chế Độ Giảm Lag (Lag Reduction Mode)",
   Options = {"Tắt (Disable)", "Cấp 1 (Normal Low)", "Cấp 2 (Super Extreme)"},
   CurrentOption = {"Tắt (Disable)"},
   MultipleOptions = false,
   Callback = function(Option)
       if Option[1] == "Tắt (Disable)" then _G.LagReductionLevel = 0
       elseif Option[1] == "Cấp 1 (Normal Low)" then _G.LagReductionLevel = 1
       elseif Option[1] == "Cấp 2 (Super Extreme)" then _G.LagReductionLevel = 2 end
       ApplyLagReduction()
   end,
})

SystemTab:CreateToggle({
   Name = "Bật Chống Treo Máy (Anti-AFK)",
   CurrentValue = true,
   Callback = function(Value) _G.AntiAFK = Value end,
})

local virtualUser = game:GetService("VirtualUser")
game.Players.LocalPlayer.Idled:Connect(function()
   if _G.AntiAFK then
       virtualUser:CaptureController()
       virtualUser:ClickButton2(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
   end
end)
