
-- VCB Final UI v1.0
-- UI demo: tidak mengubah sistem internal voice chat Roblox.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
assert(player, "VCB: LocalPlayer tidak tersedia")

local playerGui = player:WaitForChild("PlayerGui")

-- Bersihkan versi sebelumnya
local oldGui = playerGui:FindFirstChild("VCBFinalUI")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "VCBFinalUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local COLORS = {
    panel = Color3.fromRGB(24, 24, 28),
    button = Color3.fromRGB(65, 90, 150),
    buttonHover = Color3.fromRGB(80, 108, 174),
    text = Color3.fromRGB(255, 255, 255),
    stroke = Color3.fromRGB(235, 235, 235),
}

local function create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function round(object, radius)
    create("UICorner", {
        CornerRadius = UDim.new(0, radius),
    }, object)
end

-- Panel utama
local panel = create("Frame", {
    Name = "VCBPanel",
    Size = UDim2.fromOffset(260, 112),
    Position = UDim2.new(0.5, -130, 0.35, 0),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    Active = true,
    Visible = true,
}, gui)

round(panel, 8)

create("UIStroke", {
    Color = COLORS.stroke,
    Transparency = 0.5,
    Thickness = 1,
}, panel)

-- Judul
local title = create("TextLabel", {
    Name = "Title",
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(1, -54, 0, 36),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "VCB",
    TextSize = 15,
    TextColor3 = COLORS.text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

-- Tombol tutup
local closeButton = create("TextButton", {
    Name = "CloseButton",
    Size = UDim2.fromOffset(32, 28),
    Position = UDim2.new(1, -36, 0, 4),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "X",
    TextSize = 14,
    TextColor3 = COLORS.text,
}, panel)

-- Tombol utama
local buttonFrame = create("Frame", {
    Name = "BypassButtonFrame",
    Position = UDim2.fromOffset(16, 48),
    Size = UDim2.new(1, -32, 0, 46),
    BackgroundColor3 = Color3.fromRGB(35, 35, 42),
    BorderSizePixel = 0,
}, panel)

round(buttonFrame, 8)

local bypassButton = create("TextButton", {
    Name = "BypassButton",
    Position = UDim2.fromOffset(2, 2),
    Size = UDim2.new(1, -4, 1, -4),
    BackgroundColor3 = COLORS.button,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Font = Enum.Font.GothamBold,
    Text = "BYPASS",
    TextSize = 14,
    TextColor3 = COLORS.text,
}, buttonFrame)

round(bypassButton, 6)

-- Tombol mini untuk membuka panel kembali
local reopenButton = create("TextButton", {
    Name = "ReopenButton",
    Size = UDim2.fromOffset(46, 46),
    Position = UDim2.new(0, 18, 0.5, -23),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "VCB",
    TextSize = 13,
    TextColor3 = COLORS.text,
    Visible = false,
}, gui)

round(reopenButton, 10)

create("UIStroke", {
    Color = COLORS.stroke,
    Transparency = 0.5,
    Thickness = 1,
}, reopenButton)

closeButton.Activated:Connect(function()
    panel.Visible = false
    reopenButton.Visible = true
end)

reopenButton.Activated:Connect(function()
    panel.Visible = true
    reopenButton.Visible = false
end)

-- Feedback tombol demo
local busy = false

bypassButton.Activated:Connect(function()
    if busy then
        return
    end

    busy = true
    bypassButton.Text = "UI TEST OK"
    bypassButton.BackgroundColor3 = COLORS.buttonHover

    task.delay(1.2, function()
        if bypassButton.Parent then
            bypassButton.Text = "BYPASS"
            bypassButton.BackgroundColor3 = COLORS.button
        end

        busy = false
    end)
end)

-- Geser panel melalui area judul
local dragging = false
local dragStart = nil
local startPosition = nil
local activeTouch = nil

title.InputBegan:Connect(function(input)
    local isMouse = input.UserInputType
        == Enum.UserInputType.MouseButton1
    local isTouch = input.UserInputType
        == Enum.UserInputType.Touch

    if isMouse or isTouch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position
        activeTouch = isTouch and input or nil

        if isMouse then
            activeTouch = nil
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    local isMouseMove = input.UserInputType
        == Enum.UserInputType.MouseMovement
    local isMatchingTouch = activeTouch ~= nil
        and input == activeTouch

    if not isMouseMove and not isMatchingTouch then
        return
    end

    local delta = input.Position - dragStart

    panel.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or (activeTouch and input == activeTouch) then
        dragging = false
        activeTouch = nil
    end
end)

print("[VCB] Final UI berhasil dibuat")
