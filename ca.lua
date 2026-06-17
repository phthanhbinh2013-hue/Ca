local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "FishGhost v2.5 | Professional Edition",
    SubTitle = "Fisch Optimization System",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
})

-- Các Tab chính
local Tabs = {
    Main = Window:AddTab({ Title = "Câu Cá & AI", Icon = "fishing" }),
    Economy = Window:AddTab({ Title = "Bán Cá & Mồi", Icon = "dollar-sign" }),
    World = Window:AddTab({ Title = "Tiện Ích & ESP", Icon = "map" }),
}

-- [MAIN TAB] Câu cá AI
local MainBox = Tabs.Main:AddLeftGroupbox("Hệ thống câu AI")
MainBox:AddToggle("AutoFish", {Title = "Kích hoạt Auto Câu (AI)", Default = false})
MainBox:AddSlider("Delay", {Title = "Độ trễ Anti-Ban (ms)", Min = 500, Max = 2500, Default = 1200})

-- [ECONOMY TAB] Bán cá & Mồi
local ShopBox = Tabs.Economy:AddLeftGroupbox("Quản lý tài chính")
ShopBox:AddToggle("AutoSell", {Title = "Auto Bán Cá khi đầy túi", Default = false})
ShopBox:AddDropdown("BaitMode", {Title = "Chế độ Mồi", Values = {"Tự động mua", "Dùng mồi hiện có"}})
ShopBox:AddButton({Title = "Dịch chuyển đến Merchant", Callback = function()
    local merchant = workspace:FindFirstChild("Merchants", true)
    if merchant then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = merchant.HumanoidRootPart.CFrame end
end})

-- [WORLD TAB] Tiện ích
local MiscBox = Tabs.World:AddLeftGroupbox("Tiện ích mở rộng")
MiscBox:AddToggle("ESP", {Title = "ESP Người chơi", Default = false})
MiscBox:AddToggle("NoClip", {Title = "Xuyên tường (NoClip)", Default = false})
MiscBox:AddSlider("Speed", {Title = "Tốc độ chạy", Min = 16, Max = 150, Default = 16})

-- Thông báo
Fluent:Notify({Title = "FishGhost v2.5", Content = "Đã tải xong bản v2.5!", Duration = 5})

-- --- ENGINE LOGIC ---
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoFish.Value then
            pcall(function()
                -- Logic quăng cần & nhấn phao (AI Detect)
                local rod = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if rod and rod:FindFirstChild("FishingRod") then
                    rod:Activate()
                    task.wait(Toggles.Delay.Value / 1000)
                    -- Giả lập nhấn nút cá cắn
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
                    task.wait(0.1)
                    game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
                end
            end)
        end
    end
end)
