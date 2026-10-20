return function(env)
    local C = env.C
    local _cs = env._cs
    local _isMobile = env._isMobile
    local createInstance = env.createInstance
    local makeFloatingPanel = env.makeFloatingPanel
    local makePanelTitleBar = env.makePanelTitleBar

    local PANEL_W = _isMobile and 240 or 260
    local PANEL_H = 112
    local PAD = 16

    _cs.vcbPanel = makeFloatingPanel(PANEL_W, PANEL_H, 0.5, 0)
    _cs.vcbPanel.Name = "VCBypassPanel"
    _G._vcbPanel = _cs.vcbPanel

    local bar = makePanelTitleBar(_cs.vcbPanel, "VCB", function()
        _cs.vcbPanel.Visible = false
    end)
    _cs.makePanelDraggable(_cs.vcbPanel, bar)

    local buttonFrame = createInstance("Frame", {
        Parent = _cs.vcbPanel,
        Name = "BypassButtonFrame",
        Position = UDim2.new(0, PAD, 0, 48),
        Size = UDim2.new(1, -PAD * 2, 0, 46),
        BackgroundColor3 = C.BACKGROUND or Color3.fromRGB(24, 24, 28),
        BorderSizePixel = 0,
        ZIndex = 151,
    })
    createInstance("UICorner", {
        Parent = buttonFrame,
        CornerRadius = UDim.new(0, 8),
    })
    createInstance("UIStroke", {
        Parent = buttonFrame,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = C.TEXT or Color3.fromRGB(235, 235, 235),
        Transparency = 0.65,
        Thickness = 1,
    })

    local button = createInstance("TextButton", {
        Parent = buttonFrame,
        Name = "BypassButton",
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "BYPASS",
        TextSize = 14,
        TextColor3 = C.TEXT or Color3.fromRGB(255, 255, 255),
        ZIndex = 152,
    })
    createInstance("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 6),
    })

    -- UI-only click feedback. This deliberately does not alter Roblox voice-chat internals.
    button.Activated:Connect(function()
        button.Text = "BYPASS (UI ONLY)"
        task.delay(1.2, function()
            if button and button.Parent then
                button.Text = "BYPASS"
            end
        end)
    end)

    return _cs.vcbPanel
end
