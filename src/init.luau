
local Players = game:GetService("Players")
local player = Players.LocalPlayer

assert(player, "VCB: LocalPlayer tidak tersedia")

local playerGui = player:WaitForChild("PlayerGui")

-- Hindari membuat panel duplikat
local oldGui = playerGui:FindFirstChild("VCBTestUI")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "VCBTestUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "VCBPanel"
panel.Size = UDim2.fromOffset(260, 112)
panel.Position = UDim2.new(0.5, -130, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
panel.BorderSizePixel = 0
panel.Visible = true
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
title.Size = UDim2.new(1, -42, 0, 36)
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
button.BackgroundTransparency = 1
button.Font = Enum.Font.GothamBold
button.Text = "BYPASS"
button.TextSize = 14
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = frame

button.Activated:Connect(function()
    button.Text = "UI TEST OK"
    task.delay(1.2, function()
        if button.Parent then
            button.Text = "BYPASS"
        end
    end)
end)

print("[VCB] Test UI berhasil dibuat")
