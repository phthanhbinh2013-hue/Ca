local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cấu hình trạng thái hệ thống toàn cục
_G.CurrentLang = "VN"
_G.AutoHarvest = false
_G.AutoSteal = false
_G.AutoSell = false
_G.AutoSeeds = false
_G.AntiAFK = true

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
   Name = "ahgrow v2.6 🌿 Premium Suite",
   LoadingTitle = "ahgrow Premium v2.6",
   LoadingSubtitle = "Đã sửa lỗi ngôn ngữ & Hướng đi bộ 🎉",
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
-- BẢN DỊCH NGÔN NGỮ ĐỘNG (DÙNG ĐỂ CẬP NHẬT UI LẬP TỨC)
-- ===========================================================================
local Elements = {} -- Lưu trữ các phần tử UI để thay đổi chữ

local function UpdateLanguage()
    if _G.CurrentLang == "VN" then
        if Elements.SecHarvest then Elements.SecHarvest:SetText("Quản Lý Thu Hoạch Tự Động") end
        if Elements.ToggleHarvest then Elements.ToggleHarvest:SetText("Tự Động Thu Hoạch Trái (Auto Harvest)") end
        if Elements.SecSteal then Elements.SecSteal:SetText("Tự Động Đi Trộm Đồ") end
        if Elements.ToggleSteal then Elements.ToggleSteal:SetText("Kích Hoạt Auto Trộm Trái Cây Đêm") end
        if Elements.SecSell then Elements.SecSell:SetText("⚡ Tuyến Đường Tự Động Đi Bán Trái") end
        if Elements.ToggleSell then Elements.ToggleSell:SetText("Bật Auto Sell Đi Bộ Khi Đầy Kho") end
        if Elements.SecSeeds1 then Elements.SecSeeds1:SetText("📋 Cài Đặt 3 Hạt Giống Ưu Tiên") end
        if Elements.SecSeeds2 then Elements.SecSeeds2:SetText("⚡ Tuyến Đường Auto Seeds Khi Có Tải Lại Kho") end
        if Elements.ToggleSeeds then Elements.ToggleSeeds:SetText("Bật Auto Mua Hạt Khi Reset Stock") end
        if Elements.SecLang then Elements.SecLang:SetText("Cấu Hình Ngôn Ngữ Hệ Thống") end
        if Elements.ResetBtn then Elements.ResetBtn:SetText("Nút Reset Ngôn Ngữ Về Mặc Định") end
    else
        if Elements.SecHarvest then Elements.SecHarvest:SetText("Auto Harvest Management") end
        if Elements.ToggleHarvest then Elements.ToggleHarvest:SetText("Auto Harvest Fruits") end
        if Elements.SecSteal then Elements.SecSteal:SetText("Auto Steal System") end
        if Elements.ToggleSteal then Elements.ToggleSteal:SetText("Enable Night Steal Mode") end
        if Elements.SecSell then Elements.SecSell:SetText("⚡ Auto Sell Walk Route") end
        if Elements.ToggleSell then Elements.ToggleSell:SetText("Enable Auto Walk Sell on Full") end
        if Elements.SecSeeds1 then Elements.SecSeeds1:SetText("📋 Priority Seeds Configuration") end
        if Elements.SecSeeds2 then Elements.SecSeeds2:SetText("⚡ Auto Seeds Route on Stock Reset") end
        if Elements.ToggleSeeds then Elements.ToggleSeeds:SetText("Enable Auto Buy Seeds on Restock") end
        if Elements.SecLang then Elements.SecLang:SetText("System Language Configuration") end
        if Elements.ResetBtn then Elements.ResetBtn:SetText("Reset Language to Default Button") end
    end
end

-- ===========================================================================
-- HÀM ĐI BỘ ĐÚNG HƯỚNG (HUMANOID MOVETO)
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

-- CON ĐƯỜNG 1: TỰ ĐỘNG ĐI BÁN (AUTO SELL)
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
                            local oldMoney = player.leaderstats and player.leaderstats:FindFirstChild("Money") and player.leaderstats.Money.Value or 0
                            for _, connection in pairs(getconnections(option.MouseButton1Click)) do
                                connection:Fire()
                            end
                            task.wait(0.5)
                            local newMoney = player.leaderstats and player.leaderstats:FindFirstChild("Money") and player.leaderstats.Money.Value or oldMoney
                            local earned = newMoney - oldMoney
                            if earned > 0 then
                                Rayfield:Notify({Title = _G.CurrentLang == "VN" and "Bán Hàng" or "Shop Sell", Content = "+" .. tostring(earned) .. " $", Duration = 3})
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

-- CON ĐƯỜNG 2: TỰ ĐỘNG ĐI MUA HẠT (AUTO SEEDS KHI RESET STOCK)
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

--- ===========================================================================
--- ĐỊNH NGHĨA PHẦN TỬ UI & ĐĂNG KÝ VÀO HỆ THỐNG ĐỔI NGÔN NGỮ
--- ===========================================================================
Elements.SecHarvest = MainTab:CreateSection("Quản Lý Thu Hoạch Tự Động")

Elements.ToggleHarvest = MainTab:CreateToggle({
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

Elements.SecSteal = StealTab:CreateSection("Tự Động Đi Trộm Đồ")

Elements.ToggleSteal = StealTab:CreateToggle({
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
                                
