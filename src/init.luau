local ok, err = pcall(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    assert(player, "LocalPlayer tidak tersedia")

    local gui = Instance.new("ScreenGui")
    gui.Name = "VCBDebugUI"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(260, 120)
    frame.Position = UDim2.new(0.5, -130, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 40)
    label.BackgroundTransparency = 1
    label.Text = "VCB BERHASIL MUNCUL"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 48)
    button.Position = UDim2.fromOffset(12, 52)
    button.Text = "BYPASS"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(65, 90, 150)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 15
    button.Parent = frame

    button.Activated:Connect(function()
        button.Text = "UI BERFUNGSI"
    end)

    print("[VCB] UI berhasil dibuat")
end)

if not ok then
    warn("[VCB ERROR] " .. tostring(err))
end