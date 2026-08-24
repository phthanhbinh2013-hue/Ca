local CoreGui = game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
MainFrame.Size = UDim2.new(0, 350, 0, 220)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 22, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 10, 16))
}
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Title Frame
local TitleFrame = Instance.new("Frame")
TitleFrame.Parent = MainFrame
TitleFrame.Position = UDim2.new(0, 20, 0, 12)
TitleFrame.Size = UDim2.new(1, -60, 0, 28)
TitleFrame.BackgroundTransparency = 1

local TitleV = Instance.new("TextLabel")
TitleV.Parent = TitleFrame
TitleV.Position = UDim2.new(0, 0, 0, -2)
TitleV.Size = UDim2.new(0, 22, 1, 0)
TitleV.Text = "V"
TitleV.TextColor3 = Color3.fromRGB(0, 210, 255)
TitleV.TextSize = 20
TitleV.Font = Enum.Font.GothamBold
TitleV.TextXAlignment = Enum.TextXAlignment.Left
TitleV.BackgroundTransparency = 1

local TitleSub = Instance.new("TextLabel")
TitleSub.Parent = TitleFrame
TitleSub.Position = UDim2.new(0, 20, 0, 2)
TitleSub.Size = UDim2.new(1, -20, 1, 0)
TitleSub.Text = "Control Center"
TitleSub.TextColor3 = Color3.fromRGB(220, 230, 240)
TitleSub.TextSize = 13
TitleSub.Font = Enum.Font.GothamBold
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Position = UDim2.new(1, -36, 0, 14)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(120, 140, 160)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundTransparency = 1

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Key Input TextBox
local KeyInput = Instance.new("TextBox")
KeyInput.Parent = MainFrame
KeyInput.Position = UDim2.new(0, 20, 0, 48)
KeyInput.Size = UDim2.new(1, -40, 0, 40)
KeyInput.PlaceholderText = "Paste Key here..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(80, 100, 125)
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.BackgroundColor3 = Color3.fromRGB(16, 25, 38)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 12
KeyInput.TextXAlignment = Enum.TextXAlignment.Center
KeyInput.ClearTextOnFocus = false

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(1, 0)
InputCorner.Parent = KeyInput

local InputStroke = Instance.new("UIStroke")
InputStroke.Thickness = 1
InputStroke.Color = Color3.fromRGB(30, 55, 85)
InputStroke.Parent = KeyInput

-- Button Container Frame
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Parent = MainFrame
ButtonContainer.Position = UDim2.new(0, 20, 0, 100)
ButtonContainer.Size = UDim2.new(1, -40, 0, 38)
ButtonContainer.BackgroundTransparency = 1

local ButtonLayout = Instance.new("UIListLayout")
ButtonLayout.Parent = ButtonContainer
ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonLayout.Padding = UDim.new(0, 12)

-- GET KEY Button
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Name = "1_GetKeyBtn"
GetKeyBtn.Parent = ButtonContainer
GetKeyBtn.Size = UDim2.new(0.5, -6, 1, 0)
GetKeyBtn.Text = "GET KEY"
GetKeyBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(16, 35, 58)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 12
GetKeyBtn.TextXAlignment = Enum.TextXAlignment.Center

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(1, 0)
GetKeyCorner.Parent = GetKeyBtn

-- SUBMIT Button
local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Name = "2_SubmitBtn"
SubmitBtn.Parent = ButtonContainer
SubmitBtn.Size = UDim2.new(0.5, -6, 1, 0)
SubmitBtn.Text = "SUBMIT"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 12
SubmitBtn.TextXAlignment = Enum.TextXAlignment.Center

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(1, 0)
SubmitCorner.Parent = SubmitBtn

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Position = UDim2.new(0, 20, 0, 150)
StatusLabel.Size = UDim2.new(1, -40, 0, 60)
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextWrapped = true

-- UI Shake Effect
local function ShakeUI()
    local OriginalPos = UDim2.new(0.5, -175, 0.5, -110)
    local ShakeOffset = 8
    local TweenInfoFast = TweenInfo.new(0.04, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    local Positions = {
        UDim2.new(0.5, -175 - ShakeOffset, 0.5, -110),
        UDim2.new(0.5, -175 + ShakeOffset, 0.5, -110),
        UDim2.new(0.5, -175 - (ShakeOffset/2), 0.5, -110),
        UDim2.new(0.5, -175 + (ShakeOffset/2), 0.5, -110),
        OriginalPos
    }

    task.spawn(function()
        for _, Pos in ipairs(Positions) do
            local Tween = TweenService:Create(MainFrame, TweenInfoFast, {Position = Pos})
            Tween:Play()
            Tween.Completed:Wait()
        end
    end)
end

-- Hover Animation
SubmitBtn.MouseEnter:Connect(function()
    TweenService:Create(SubmitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 160, 255)}):Play()
end)
SubmitBtn.MouseLeave:Connect(function()
    TweenService:Create(SubmitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 132, 255)}):Play()
end)

-- Click Event for GET KEY (Copy Link)
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KeyURL)
        StatusLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
        StatusLabel.Text = "✓ Key URL copied to clipboard!"
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
        StatusLabel.Text = "Executor does not support clipboard functionality."
    end
end)

-- Click Event for SUBMIT
SubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == EncryptedKey then
        StatusLabel.TextColor3 = Color3.fromRGB(0, 230, 120)
        StatusLabel.Text = "✓ Access Granted! Loading script..."
        InputStroke.Color = Color3.fromRGB(0, 230, 120)
        
        SaveKeyLocally(EncryptedKey)
        
        task.wait(0.8)
        ScreenGui:Destroy()
        loadstring(game:HttpGet(ScriptURL))()
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
        StatusLabel.Text = "✕ Invalid Key! Please try again."
        InputStroke.Color = Color3.fromRGB(255, 70, 70)
        
        KeyInput.Text = ""
        ShakeUI()
    end
end)
