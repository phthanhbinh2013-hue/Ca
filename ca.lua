local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Biến lưu cấu hình hệ thống toàn cục
_G.CurrentLang = "VN" -- "VN" hoặc "EN"
_G.AutoHarvest = false
_G.AutoSteal = false
_G.AutoSell = false
_G.AutoSeeds = false
_G.AntiAFK = true
_G.SuperLagReduction = false

-- Thứ tự hạt giống ưu tiên quét mua
_G.Priority1 = "Carrot"
_G.Priority2 = "Strawberry"
_G.Priority3 = "Blueberry"

local SeedList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", 
    "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean", "Banana", "Grape", 
    "Coconut", "Mango", "Dragon Fruit", "Acorn", "Cherry", "Sunflower", 
    "Venus Fly Trap", "Pomegranate", "Poison Apple", "Moon Bloom", "Dragon's Breath"
}

-- Khởi tạo Menu chính với lời chúc loading
local Window = Rayfield:CreateWindow({
   Name = "ahgrow v2.5 🌿 Premium Suite",
   LoadingTitle = "ahgrow Premium Loader v2.5",
   LoadingSubtitle = "Chúc bạn chơi game vui vẻ! 🎉",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ===========================================================================
-- KHỞI TẠO CÁC TAB CHỨC NĂNG CÓ HÌNH ẢNH BIỂU TƯỢNG (ICONS)
-- ===========================================================================
-- Sử dụng mã Icon Lucide/Rayfield hợp lệ để hiển thị hình ảnh trực quan
local MainTab = Window:CreateTab("Khu Vườn (Garden)", "leaf") 
local StealTab = Window:CreateTab("Trộm Đêm (Steal)", "moon") 
local ShopTab = Window:CreateTab("Cửa Hàng (Shop)", "shopping-cart") 
local SystemTab = Window:CreateTab("Cài Đặt (Settings)", "settings") 

--- ===========================================================================
--- HÀM XỬ LÝ LOGIC CHUYÊN SÂU (FIX LỖI KHÔNG ĐƯỢC HẠT & KHÔNG BÁN ĐƯỢC TRÁI)
--- ===========================================================================
local function safeTeleport(targetCFrame)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = targetCFrame
    end
end

-- Hàm thực thi Auto Sell: Buộc dừng nhặt trái -> Đi bán -> Bán xong hồi phục trạng thái nhặt
local function runAutoSellLogic()
    local player = game.Players.LocalPlayer
    local npc = workspace:FindFirstChild("Merchant") or workspace:FindFirstChild("SellNPC") or workspace:FindFirstChild("Sam")
    
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        local oldHarvest = _G.AutoHarvest
        local oldSteal = _G.AutoSteal
        
        -- Sửa lỗi kẹt luồng: Ép dừng nhặt trái ngay lập tức để giải phóng hành động
        _G.AutoHarvest = false
        _G.AutoSteal = false
        task.wait(0.1)
        
        -- Dịch chuyển trực diện đến thương nhân bán đồ
        safeTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
        task.wait(0.3)
        
        local prompt = npc:FindFirstChildOfClass("ProximityPrompt") or npc:GetComponentInChildren("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(0.4)
            
            -- Trả lời hội thoại lời nói số #1 không cần click chuột để dọn kho
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
        task.wait(0.4)
        
        -- Khôi phục trạng thái làm việc ban đầu sau khi giải phóng túi đồ thành công
        _G.AutoHarvest = oldHarvest
        _G.AutoSteal = oldSteal
    end
end

-- Hàm thực thi Auto Seeds: Tự động gom hạt theo danh sách ưu tiên khi xuất hiện
local function runAutoSeedsLogic()
    local player = game.Players.LocalPlayer
    local seedNPC = workspace:FindFirstChild("SeedMerchant") or workspace:FindFirstChild("SeedNPC") or workspace:FindFirstChild("Sam")
    
    if seedNPC and seedNPC:FindFirstChild("HumanoidRootPart") then
        safeTeleport(seedNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
        task.wait(0.3)
        
        local prompt = seedNPC:FindFirstChildOfClass("ProximityPrompt") or seedNPC:GetComponentInChildren("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(0.4)
            
            local shopGui = player.PlayerGui:FindFirstChild("SeedShopGui") or player.PlayerGui:FindFirstChild("ShopGui")
            if shopGui and shopGui.Enabled then
                local priorities = {_G.Priority1, _G.Priority2, _G.Priority3}
                for _, targetSeed in ipairs(priorities) do
                    for _, item in pairs(shopGui:GetDescendants()) do
                        if item:IsA("TextLabel") and item.Text:lower():match(targetSeed:lower()) then
                            local btn = item.Parent:FindFirstChildOfClass("TextButton") or item.Parent:FindFirstChild("BuyButton")
                            if btn then
                                for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                                    conn:Fire()
                                    task.wait(0.05)
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
--- 🌾 TAB 1: KHU VƯỜN TRỒNG (GARDEN)
--- ===========================================================================
MainTab:CreateSection("Quản Lý Thu Hoạch Tự Động")

MainTab:CreateToggle({
   Name = "Tự Động Thu Hoạch Trái (Auto Harvest)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoHarvest = Value
      task.spawn(function()
          while _G.AutoHarvest do
              task.wait(0.3)
              pcall(function()
                  local player = game.Players.LocalPlayer
                  local isFull = false
                  
                  -- Quét GUI phát hiện túi đầy để tự động dừng nhặt đi bán
                  for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                      if gui:IsA("TextLabel") and gui.Text:match("Inventory is full") and gui.Visible then
                          isFull = true
                          break
                      end
                  end
                  
                  if isFull and _G.AutoSell then
                      runAutoSellLogic()
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

--- ===========================================================================
--- 🌙 TAB 2: CHẾ ĐỘ TRỘM ĐÊM (STEAL)
--- ===========================================================================
StealTab:CreateSection("Tự Động Đi Trộm Đồ Nhà Hàng Xóm")

StealTab:CreateToggle({
   Name = "Kích Hoạt Auto Trộm Trái Cây Đêm",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoSteal = Value
      task.spawn(function()
          while _G.AutoSteal do
              task.wait(0.4)
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

--- ===========================================================================
--- 🛒 TAB 3: CỬA HÀNG (SHOP - TÁCH BIỆT SEEDS & SELL)
--- ===========================================================================
-- PHÂN ĐOẠN 1: TÁCH RIÊNG KHU VỰC BÁN TRÁI CÂY (AUTO SELL)
ShopTab:CreateSection("⚡ PHẦN KHU VỰC TỰ ĐỘNG BÁN (AUTO SELL)")

ShopTab:CreateToggle({
   Name = "Bật Tính Năng Tự Động Bán Trái Cây Khi Đầy Kho",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoSell = Value
      if Value then
          task.spawn(function()
              while _G.AutoSell do
                  task.wait(2)
                  pcall(function()
                      local isFull = false
                      for _, gui in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
                          if gui:IsA("TextLabel") and gui.Text:match("Inventory is full") and gui.Visible then
                              isFull = true
                              break
                          end
                      end
                      if isFull then runAutoSellLogic() end
                  end)
              end
          end)
      end
   end,
})

-- PHÂN ĐOẠN 2: TÁCH RIÊNG KHU VỰC MUA HẠT GIỐNG (AUTO SEEDS)
ShopTab:CreateSection("🌱 PHẦN KHU VỰC TỰ ĐỘNG MUA HẠT (AUTO SEEDS)")

ShopTab:CreateDropdown({
   Name = "Hạt Giống Ưu Tiên 1 (Priority 1)",
   Options = SeedList,
   CurrentOption = {"Carrot"},
   MultipleOptions = false,
   Callback = function(Option) _G.Priority1 = Option[1] end,
})

ShopTab:CreateDropdown({
   Name = "Hạt Giống Ưu Tiên 2 (Priority 2)",
   Options = SeedList,
   CurrentOption = {"Strawberry"},
   MultipleOptions = false,
   Callback = function(Option) _G.Priority2 = Option[1] end,
})

ShopTab:CreateDropdown({
   Name = "Hạt Giống Ưu Tiên 3 (Priority 3)",
   Options = SeedList,
   CurrentOption = {"Blueberry"},
   MultipleOptions = false,
   Callback = function(Option) _G.Priority3 = Option[1] end,
})

ShopTab:CreateToggle({
   Name = "Bật Tính Năng Auto Quét Mua Hạt Giống Khi Xuất Hiện",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoSeeds = Value
      if Value then
          task.spawn(function()
              while _G.AutoSeeds do
                  runAutoSeedsLogic()
                  task.wait(5) -- Quét định kỳ chống bỏ sót hạt giống xịn
              end
          end)
      end
   end,
})

--- ===========================================================================
--- ⚙️ TAB 4: CÀI ĐẶT HỆ THỐNG (SETTINGS)
--- ===========================================================================
SystemTab:CreateSection("Cấu Hình Ngôn Ngữ Hệ Thống")

local LangDropdown = SystemTab:CreateDropdown({
   Name = "Chọn Ngôn Ngữ / Select Language",
   Options = {"Tiếng Việt (VN)", "English (EN)"},
   CurrentOption = {"Tiếng Việt (VN)"},
   MultipleOptions = false,
   Callback = function(Option)
      if Option[1] == "Tiếng Việt (VN)" then
          _G.CurrentLang = "VN"
          Rayfield:Notify({Title = "Hệ Thống", Content = "Đã chuyển sang Tiếng Việt", Duration = 2})
      else
          _G.CurrentLang = "EN"
          Rayfield:Notify({Title = "System", Content = "Switched to English Language", Duration = 2})
      end
   end,
})

SystemTab:CreateButton({
   Name = "Nút Reset Ngôn Ngữ Về Mặc Định (Tiếng Việt)",
   Callback = function()
       _G.CurrentLang = "VN"
       LangDropdown:Set({"Tiếng Việt (VN)"})
       Rayfield:Notify({Title = "Hệ Thống", Content = "Đã khôi phục cài đặt gốc thành công!", Duration = 3})
   end,
})

SystemTab:CreateSection("Cấu Hình Treo Máy Xuyên Đêm Không Lag")

SystemTab:CreateToggle({
   Name = "Bật Chống Treo Máy (Anti-AFK)",
   CurrentValue = true,
   Callback = function(Value) _G.AntiAFK = Value end,
})

-- Kích hoạt chặn kích hoạt cơ chế AFK Kick của Roblox
local virtualUser = game:GetService("VirtualUser")
game.Players.LocalPlayer.Idled:Connect(function()
   if _G.AntiAFK then
       virtualUser:CaptureController()
       virtualUser:ClickButton2(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
   end
end)

SystemTab:CreateToggle({
   Name = "Chế Độ Siêu Giảm Lag (Mượt Máy Cày Đêm)",
   CurrentValue = false,
   Callback = function(Value)
      _G.SuperLagReduction = Value
      if Value then
          pcall(function()
              settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
              game:GetService("Lighting").GlobalShadows = false
              for _, v in pairs(workspace:GetDescendants()) do
                  if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
              end
              if setfpscap then setfpscap(15) end
          end)
      else
          if setfpscap then setfpscap(60) end
      end
   end,
})
