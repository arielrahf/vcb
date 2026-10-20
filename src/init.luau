```lua
-- VCB Final UI V2
-- UI preview only; tidak memodifikasi sistem voice chat Roblox.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
assert(player, "VCB: LocalPlayer tidak tersedia")

local playerGui = player:WaitForChild("PlayerGui")

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
    surface = Color3.fromRGB(38, 38, 45),
    accent = Color3.fromRGB(65, 90, 150),
    accentHover = Color3.fromRGB(80, 108, 174),
    text = Color3.fromRGB(255, 255, 255),
    subtle = Color3.fromRGB(165, 165, 175),
    red = Color3.fromRGB(190, 65, 75),
    green = Color3.fromRGB(65, 155, 120),
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

local function stroke(object, transparency)
    create("UIStroke", {
        Color = COLORS.text,
        Transparency = transparency or 0.85,
        Thickness = 1,
    }, object)
end

local function animate(object, properties)
    TweenService:Create(
        object,
        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    ):Play()
end

-- Panel utama
local panel = create("Frame", {
    Name = "VCBPanel",
    Size = UDim2.fromOffset(280, 190),
    Position = UDim2.new(0.5, -140, 0.3, 0),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    Active = true,
}, gui)

round(panel, 10)
stroke(panel, 0.65)

-- Title bar
local titleBar = create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundTransparency = 1,
    Active = true,
}, panel)

local title = create("TextLabel", {
    Name = "Title",
    Position = UDim2.fromOffset(13, 0),
    Size = UDim2.new(1, -55, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "VC BYPASSER",
    TextSize = 14,
    TextColor3 = COLORS.text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)

local closeButton = create("TextButton", {
    Name = "CloseButton",
    Size = UDim2.fromOffset(30, 28),
    Position = UDim2.new(1, -34, 0, 5),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "X",
    TextSize = 14,
    TextColor3 = COLORS.text,
}, titleBar)

-- Pemilih versi: V2 saja
local versionLabel = create("TextLabel", {
    Position = UDim2.fromOffset(14, 43),
    Size = UDim2.new(1, -28, 0, 18),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "VERSION",
    TextSize = 10,
    TextColor3 = COLORS.subtle,
    TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local versionButton = create("TextButton", {
    Name = "VersionV2",
    Position = UDim2.fromOffset(14, 64),
    Size = UDim2.new(1, -28, 0, 32),
    BackgroundColor3 = COLORS.accent,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "BYPASS V2  ✓",
    TextSize = 12,
    TextColor3 = COLORS.text,
}, panel)

round(versionButton, 7)

-- Tombol preview
local executeButton = create("TextButton", {
    Name = "ExecutePreview",
    Position = UDim2.fromOffset(14, 105),
    Size = UDim2.new(1, -28, 0, 36),
    BackgroundColor3 = COLORS.surface,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "EXECUTE V2 PREVIEW",
    TextSize = 12,
    TextColor3 = COLORS.text,
}, panel)

round(executeButton, 7)
stroke(executeButton, 0.9)

-- Status
local note = create("TextLabel", {
    Name = "Status",
    Position = UDim2.fromOffset(14, 145),
    Size = UDim2.new(1, -70, 0, 30),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "V2 selected - UI preview only",
    TextSize = 10,
    TextWrapped = true,
    TextColor3 = COLORS.subtle,
    TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

-- Tombol mikrofon visual
local micButton = create("TextButton", {
    Name = "MicPreview",
    Position = UDim2.new(1, -48, 0, 146),
    Size = UDim2.fromOffset(34, 30),
    BackgroundColor3 = COLORS.surface,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "MIC",
    TextSize = 10,
    TextColor3 = COLORS.text,
}, panel)

round(micButton, 8)

-- Tombol untuk membuka panel kembali
local reopenButton = create("TextButton", {
    Name = "ReopenButton",
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.new(0, 18, 0.5, -24),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "VCB",
    TextSize = 12,
    TextColor3 = COLORS.text,
    Visible = false,
}, gui)

round(reopenButton, 12)
stroke(reopenButton, 0.65)

-- Buka dan tutup
closeButton.Activated:Connect(function()
    panel.Visible = false
    reopenButton.Visible = true
end)

reopenButton.Activated:Connect(function()
    panel.Visible = true
    reopenButton.Visible = false
end)

-- Pilihan V2
versionButton.Activated:Connect(function()
    note.Text = "V2 selected - UI preview only"
    animate(versionButton, {
        BackgroundColor3 = COLORS.accentHover,
    })

    task.delay(0.2, function()
        if versionButton.Parent then
            animate(versionButton, {
                BackgroundColor3 = COLORS.accent,
            })
        end
    end)
end)

-- Preview UI, bukan bypass voice chat
local previewActive = false

executeButton.Activated:Connect(function()
    previewActive = not previewActive

    if previewActive then
        executeButton.Text = "V2 PREVIEW ACTIVE"
        executeButton.BackgroundColor3 = COLORS.green
        note.Text = "Preview aktif - voice chat tidak diubah"
    else
        executeButton.Text = "EXECUTE V2 PREVIEW"
        executeButton.BackgroundColor3 = COLORS.surface
        note.Text = "Preview reset - UI only"
    end
end)

-- Status mikrofon visual saja
local micMuted = false

micButton.Activated:Connect(function()
    micMuted = not micMuted

    if micMuted then
        micButton.Text = "OFF"
        micButton.BackgroundColor3 = COLORS.red
        note.Text = "Mic visual OFF - voice chat tidak diubah"
    else
        micButton.Text = "MIC"
        micButton.BackgroundColor3 = COLORS.surface
        note.Text = "Mic visual ON - voice chat tidak diubah"
    end
end)

-- Geser panel melalui title bar
local dragging = false
local dragStart
local startPosition
local activeTouch

titleBar.InputBegan:Connect(function(input)
    local mouse = input.UserInputType
        == Enum.UserInputType.MouseButton1
    local touch = input.UserInputType
        == Enum.UserInputType.Touch

    if mouse or touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position
        activeTouch = touch and input or nil
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    local mouseMove = input.UserInputType
        == Enum.UserInputType.MouseMovement
    local touchMove = activeTouch ~= nil
        and input == activeTouch

    if not mouseMove and not touchMove then
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

print("[VCB] Final UI V2 berhasil dibuat")
```