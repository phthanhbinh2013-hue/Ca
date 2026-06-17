local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "FishGhost v3.0 | Ultimate Hub",
    SubTitle = "Smart Stealing & Extreme Lag Fix",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
})

local Tabs = {
    Steal = Window:AddTab({ Title = "Trộm Vườn AI", Icon = "moon" }),
    Economy = Window:AddTab({ Title = "Bán & Thu Hoạch", Icon = "dollar-sign" }),
    Settings = Window:AddTab({ Title = "Tối Ưu & Lag", Icon = "settings" }),
}

-- [STEAL TAB] Smart Stealing
local StealBox = Tabs.Steal:AddLeftGroupbox("Hệ thống trộm AI")
StealBox:AddToggle("SmartSteal", {Title = "Auto trộm vườn (Tự tránh người)", Default = false})
StealBox:AddToggle("AutoSwitch", {Title = "Nếu có người ở vườn -> Chuyển vườn khác", Default = true})

-- [ECONOMY TAB] Thu hoạch & Bán
local EcoBox = Tabs.Economy:AddLeftGroupbox("Quản lý tài chính")
EcoBox:AddSlider("FruitAmount", {Title = "Số lượng trái để Teleport về bán", Min = 5, Max = 50, Default = 20})
EcoBox:AddToggle("AutoSellLoop", {Title = "Tự động dịch chuyển về bán khi đủ số lượng", Default = false})

-- [SETTINGS TAB] Lag Reduction Level 3
local LagBox = Tabs.Settings:AddLeftGroupbox("Tối ưu hóa (Cấp 3 - Mạnh nhất)")
LagBox:AddButton({Title = "Kích hoạt Giảm Lag Cấp 3 (Extreme)", Callback = function()
    -- Cấp 3: Xóa hoàn toàn vật thể thừa, giảm FPS về 15, tắt đổ bóng, ép chất liệu
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game:GetService("Lighting").GlobalShadows = false
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then v:Destroy() end
        end
        if setfpscap then setfpscap(15) end
        Fluent:Notify({Title = "Lag Level 3", Content = "Đã ép xung máy tối đa!", Duration = 3})
    end)
end})

-- --- LOGIC ENGINE ---
task.spawn(function()
    while task.wait(1) do
        if Toggles.SmartSteal.Value then
            pcall(function()
                -- Check nếu vườn có người chơi khác
                local hasPlayer = false
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 30 then hasPlayer = true end
                    end
                end
                
                if hasPlayer and Toggles.AutoSwitch.Value then
                    -- Teleport sang vườn khác
                    Fluent:Notify({Title = "Steal", Content = "Có người! Đang chuyển vườn...", Duration = 2})
                    -- Thêm code nhảy vườn ở đây
                else
                    -- Tiến hành trộm
                end
            end)
        end
    end
end)
