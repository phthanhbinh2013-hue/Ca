-- 1. Cải tiến Auto Harvest & Auto Sell (Phát hiện đầy kho)
task.spawn(function()
    while _G.AutoHarvest do
        task.wait(0.5)
        pcall(function()
            local player = game.Players.LocalPlayer
            -- Quét màn hình xem có dòng chữ báo đầy kho không
            local isFull = false
            for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextLabel") and (gui.Text:lower():match("full") or gui.Text:lower():match("inventory")) then
                    isFull = true
                    break
                end
            end
            
            -- Nếu đầy kho và bật auto sell thì chạy đi bán
            if isFull and _G.AutoSell then
                runAutoSellRoute() 
            end
            
            -- [Logic thu hoạch giữ nguyên...]
        end)
    end
end)

-- 2. Cải tiến Auto Seeds (Quét 10s một lần & tự nhận diện hạt)
task.spawn(function()
    while _G.AutoSeeds do
        task.wait(10) -- Quét mỗi 10 giây
        pcall(function()
            local player = game.Players.LocalPlayer
            local shopGui = player.PlayerGui:FindFirstChild("SeedShopGui") -- Cần đổi tên đúng theo game
            
            if shopGui and shopGui.Enabled then
                -- Hệ thống tự quét danh sách hạt đang có Stock
                local items = shopGui:GetDescendants()
                local targets = {_G.Priority1, _G.Priority2, _G.Priority3}
                
                for _, targetSeed in ipairs(targets) do
                    for _, item in pairs(items) do
                        if item:IsA("TextLabel") and item.Text == targetSeed then
                            -- Kiểm tra nếu hạt đó không hiện chữ "NO STOCK"
                            local parentFrame = item.Parent
                            local isOutOfStock = false
                            for _, v in pairs(parentFrame:GetDescendants()) do
                                if v:IsA("TextLabel") and v.Text:lower():match("no stock") then
                                    isOutOfStock = true
                                end
                            end
                            
                            if not isOutOfStock then
                                -- Mua hạt giống (thực hiện click button buy)
                                -- [Code thực hiện click mua tại đây]
                            end
                        end
                    end
                end
            else
                -- Nếu chưa mở shop, có thể thêm đoạn code lại gần NPC Sam để mở shop
                runAutoSeedsRoute() 
            end
        end)
    end
end)
