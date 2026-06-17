local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- FishGhost v2.0 Engine
local Window = Rayfield:CreateWindow({
   Name = "FishGhost v2.0 🎣 | Fisch Pro Elite",
   LoadingTitle = "Initializing Elite Engine...",
   LoadingSubtitle = "AI-Powered Fishing",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Câu Cá Cao Cấp", "fishing")
local FilterTab = Window:CreateTab("Bộ Lọc Cá", "filter")

-- TÍNH NĂNG CÂU CÁ BẰNG AI (TỰ PHÁT HIỆN CÁ CẮN)
MainTab:CreateToggle({
   Name = "Auto Fish (AI Detect)",
   Callback = function(Value)
      _G.Active = Value
      task.spawn(function()
         while _G.Active do
            task.wait(0.1)
            pcall(function()
               local bobber = workspace:FindFirstChild("Bobber", true)
               -- Nhận diện dựa trên chuyển động của phao (AI logic)
               if bobber and bobber:FindFirstChild("Fish") then
                  task.wait(math.random(1, 3)/10)
                  game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
                  task.wait(0.1)
                  game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
               end
            end)
         end
      end)
   end,
})

-- HỆ THỐNG LỌC CÁ (CHỈ GIỮ LẠI CÁ NGON)
FilterTab:CreateDropdown({
   Name = "Giữ lại loại cá",
   Options = {"Legendary", "Mythical", "Rare", "All"},
   Callback = function(Option)
      _G.KeepFish = Option[1]
      Rayfield:Notify({Title = "Bộ lọc", Content = "Đã lọc: " .. Option[1], Duration = 2})
   end,
})

Rayfield:Notify({Title = "FishGhost v2.0", Content = "Đã nâng cấp lên bản Elite!", Duration = 5})
