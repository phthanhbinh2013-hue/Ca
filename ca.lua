local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UI-Library/LinoriaLib/main/Library.lua"))()
-- Lưu ý: Linoria là thư viện dạng "cửa sổ nối" chuyên nghiệp nhất hiện nay trên Roblox

local Window = Library:CreateWindow({
    Title = "FishGhost v3.0 | Elite Dashboard",
    Center = true,
    AutoShow = true,
})

-- Tạo các Tab dạng "cửa sổ nối"
local Tabs = {
    Main = Window:AddTab("Câu Cá & AI"),
    Shop = Window:AddTab("Cửa Hàng & Bán"),
    Misc = Window:AddTab("Tiện Ích & ESP")
}

-- [Main Tab] - Câu cá thông minh
local MainBox = Tabs.Main:AddLeftGroupbox("Auto AI Fishing")
MainBox:AddToggle("AutoFish", {Text = "Kích hoạt AI Fishing", Default = false})
MainBox:AddSlider("Delay", {Text = "Độ trễ Anti-Ban (ms)", Default = 800, Min = 500, Max = 2000})

-- [Shop Tab] - Cửa hàng & Mồi
local ShopBox = Tabs.Shop:AddLeftGroupbox("Quản lý Mồi & Bán")
ShopBox:AddToggle("AutoSell", {Text = "Auto Bán Cá (Túi đầy)", Default = false})
ShopBox:AddDropdown("BaitType", {Text = "Chọn Mồi Mua Tự Động", Values = {"Mồi thường", "Mồi cao cấp"}})

-- [Misc Tab] - Tiện ích
local MiscBox = Tabs.Misc:AddLeftGroupbox("ESP & Nhân vật")
MiscBox:AddToggle("ESP", {Text = "ESP Người chơi", Default = false})
MiscBox:AddToggle("NoClip", {Text = "Xuyên tường (NoClip)", Default = false})
MiscBox:AddButton("Dịch chuyển Shop", function() 
    -- Code Teleport tại đây
end)

Library:Notify("FishGhost v3.0 đã sẵn sàng!")
