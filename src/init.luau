
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
assert(player, "VCB: LocalPlayer tidak tersedia")

local playerGui = player:WaitForChild("PlayerGui")

-- Hapus UI lama jika script dijalankan ulang
local oldGui = playerGui:FindFirstChild("VCBTestUI")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "VCBTestUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "VCBPanel"
panel.Size = UDim2.fromOffset(260, 112)
panel.Position = UDim2.new(0.5, -130, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(235, 235, 235)
stroke.Transparency = 0.5
stroke.Thickness = 1
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -48, 0, 36)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "VCB"
title.TextSize = 15
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local close = Instance.new("TextButton")
close.Name = "CloseButton"
close.Size = UDim2.fromOffset(32, 28)
close.Position = UDim2.new(1, -36, 0, 4)
close.BackgroundTransparency = 1
close.Font = Enum.Font.GothamBold
close.Text = "X"
close.TextSize = 14
close.TextColor3 = Color3.new(1, 1, 1)
close.Parent = panel

close.Activated:Connect(function()
    gui:Destroy()
end)

-- Area judul untuk menggeser panel dengan mouse atau sentuhan
local dragging = false
local dragStart
local startPosition
local dragInput

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput
        or input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then

        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

local frame = Instance.new("Frame")
frame.Name = "BypassButtonFrame"
frame.Position = UDim2.fromOffset(16, 48)
frame.Size = UDim2.new(1, -32, 0, 46)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
frame.BorderSizePixel = 0
frame.Parent = panel

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

local button = Instance.new("TextButton")
button.Name = "BypassButton"
button.Size = UDim2.new(1, -4, 1, -4)
button.Position = UDim2.fromOffset(2, 2)
button.BackgroundColor3 = Color3.fromRGB(65, 90, 150)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBold
button.Text = "BYPASS"
button.TextSize = 14
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = button

button.Activated:Connect(function()
    button.Text = "UI TEST OK"

    task.delay(1.2, function()
        if button.Parent then
            button.Text = "BYPASS"
        end
    end)
end)

print("[VCB] UI berhasil dibuat")
