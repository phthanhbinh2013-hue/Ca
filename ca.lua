-- NEONFISH ULTIMATE - HARD FIX (THỰC THI TRỰC TIẾP)
-- Dành cho mọi loại Executor: Delta, Hydrogen, Codex, Arceus...

local LibraryName = "Rayfield"
local success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source'))()
end)

if not success then
    -- Nếu load thất bại, dùng cách dự phòng
    warn("Rayfield Load Failed: " .. tostring(result))
    return
end

local Rayfield = result
local Window = Rayfield:CreateWindow({Name = "NeonFish Fix v16", LoadingTitle = "Loading Engine..."})

-- TEST GIAO DIỆN ĐƠN GIẢN
local Tab = Window:CreateTab("Main", 4483345998)
Tab:CreateToggle({
    Name = "Master Auto Farm",
    Callback = function(v)
        _G.AutoFarm = v
        while _G.AutoFarm do
            task.wait(0.5)
            print("Auto Farm Running...") 
            -- Đây là nơi code chính sẽ chạy
        end
    end
})

Rayfield:LoadConfiguration()
