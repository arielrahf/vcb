
return function(env)
    local C = env.C
    local _cs = env._cs
    local _isMobile = env._isMobile
    local createInstance = env.createInstance
    local makeFloatingPanel = env.makeFloatingPanel
    local makePanelTitleBar = env.makePanelTitleBar

    assert(_cs, "VCB: _cs is missing")
    assert(createInstance, "VCB: createInstance is missing")
    assert(makeFloatingPanel, "VCB: makeFloatingPanel is missing")
    assert(makePanelTitleBar, "VCB: makePanelTitleBar is missing")

    local PANEL_W = _isMobile and 240 or 260
    local PANEL_H = 112
    local PAD = 16

    -- Buat panel utama
    local panel = makeFloatingPanel(PANEL_W, PANEL_H, 0.5, 0)
    assert(panel, "VCB: failed to create floating panel")

    panel.Name = "VCBypassPanel"
    panel.Visible = true

    _cs.vcbPanel = panel
    _G._vcbPanel = panel

    -- Title bar dengan tombol tutup
    makePanelTitleBar(panel, "VCB", function()
        panel.Visible = false
    end)

    -- Frame pembungkus tombol
    local buttonFrame = createInstance("Frame", {
        Parent = panel,
        Name = "BypassButtonFrame",
        Position = UDim2.new(0, PAD, 0, 48),
        Size = UDim2.new(1, -PAD * 2, 0, 46),
        BackgroundColor3 = C.BACKGROUND
            or Color3.fromRGB(24, 24, 28),
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

    -- Tombol BYPASS
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
        TextColor3 = C.TEXT
            or Color3.fromRGB(255, 255, 255),
        ZIndex = 152,
    })

    createInstance("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 6),
    })

    -- Umpan balik visual saja; tidak mengubah voice chat Roblox
    button.Activated:Connect(function()
        button.Text = "BYPASS (UI ONLY)"

        task.delay(1.2, function()
            if button.Parent then
                button.Text = "BYPASS"
            end
        end)
    end)

    print("[VCB] Panel created successfully")

    return panel
end
