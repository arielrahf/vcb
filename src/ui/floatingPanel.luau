return function(env, w, h, anchorX, anchorY)
local C = env.C
local _fixedPanels = env._fixedPanels
local _nvFloatCloseRest = env._nvFloatCloseRest
local _nvL = env._nvL
local createInstance = env.createInstance
local runService = env.runService
local screen = env.screen
local tween = env.tween
local userInputService = env.userInputService
	w = tonumber(w) or 220
	h = tonumber(h) or 100
	anchorX = tonumber(anchorX) or 0.5
	anchorY = tonumber(anchorY) or 0.5

	local pnl = createInstance("Frame", { Parent = screen, Size = UDim2.new(0, w, 0, h), AnchorPoint = Vector2.new(anchorX, anchorY) })
	do
		local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
		local vpX = tonumber(vp and vp.X) or 1280
		local vpY = tonumber(vp and vp.Y) or 720
		local sc = tonumber(_G._getScale and _G._getScale()) or 1
		if sc <= 0 then sc = 1 end
		local scaledW, scaledH = w * sc, h * sc
		local minX, maxX = scaledW * anchorX, vpX - scaledW * (1 - anchorX)
		local minY, maxY = scaledH * anchorY, vpY - scaledH * (1 - anchorY)
		if minX > maxX then minX, maxX = maxX, minX end
		if minY > maxY then minY, maxY = maxY, minY end
		local px = math.clamp(anchorX * vpX, minX, maxX)
		local py = math.clamp(anchorY * vpY, minY, maxY)
		pnl.Position = UDim2.new(0, px, 0, py)
	end
	pnl.BackgroundColor3 = C.PANEL
	pnl.BackgroundTransparency = 0
	pnl.BorderSizePixel = 0
	_G._nv_windows.track(pnl)
	pnl.ZIndex = 150
	pnl.Active = true
	pnl.Visible = false
	pnl.ClipsDescendants = false
	pnl:SetAttribute("_nvDesignW", w)
	pnl:SetAttribute("_nvDesignH", h)
	createInstance("UICorner", { Parent = pnl, CornerRadius = UDim.new(0, 14) })
	


	local pStroke = createInstance("UIStroke", { Parent = pnl, Color = C.STROKE, Thickness = 1, Transparency = 0.45, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	pcall(function() pStroke.LineJoinMode = Enum.LineJoinMode.Round end)
	_G._nv_utilitySurface(pnl)
	_fixedPanels[#_fixedPanels + 1] = pnl
	local pnlUIScale = createInstance("UIScale", { Parent = pnl })

	local function _computePanelScale()
		if pnl:GetAttribute("_nvPlaceHold") then
			return pnlUIScale.Scale
		end
		local forced = pnl:GetAttribute("_nvPlaceScale")
		if type(forced) == "number" and forced > 0 then return forced end
		local vp2 = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
		local vp2X = tonumber(vp2 and vp2.X) or 1280
		local vp2Y = tonumber(vp2 and vp2.Y) or 720
		local globalSc = tonumber(_G._getScale and _G._getScale()) or 1
		if globalSc <= 0 then globalSc = 1 end
		local SAFE_MARGIN = 24
		local maxFitScale = math.min(
			(vp2X - SAFE_MARGIN) / math.max(w,pnl.Size.X.Offset),
			(vp2Y - SAFE_MARGIN) / (math.max(h,pnl.Size.Y.Offset)+(tonumber(pnl:GetAttribute("_nvDragPadBottom"))or 0))
		)
		maxFitScale = math.max(tonumber(maxFitScale) or 0.35, 0.35)
		local userZoom = tonumber(pnl:GetAttribute("_nvUserZoom"))
		if userZoom and userZoom > 0 then return math.min(userZoom, maxFitScale) end
		return math.min(globalSc, maxFitScale)
	end

	pnlUIScale.Scale = _computePanelScale()
	_G._floatingPanelScales = _G._floatingPanelScales or {}
	_G._floatingPanelScales[#_G._floatingPanelScales + 1] = {
		instance = pnlUIScale,
		recompute = _computePanelScale,
	}
	pnl:GetPropertyChangedSignal("Visible"):Connect(function()
		if not pnl.Visible then return end
		if pnl:GetAttribute("_nvPlaceGo") then
			pnl:SetAttribute("_nvPlaceGo", nil)
		elseif _nvL.placeWindows and not (_G._nv_windows and (_G._nv_windows.placing or _G._nv_windows.restoring)) and type(_G._nv_askPlaceWindow) == "function" then
			pnl.Visible = false
			_G._nv_askPlaceWindow(pnl, function(rect)
				if not pnl.Parent or pnl.Visible then return end
				if not _G._nvPlaceRects then _G._nvPlaceRects = setmetatable({}, {__mode = "k"}) end
				_G._nvPlaceRects[pnl] = rect
				pnl:SetAttribute("_nvPlaceGo", true)
				pnl.Visible = true
			end)
			return
		end
		local placed = _G._nvPlaceRects and _G._nvPlaceRects[pnl]
		if placed then _G._nvPlaceRects[pnl] = nil end
		pnl:SetAttribute("_nvClosing", nil)
		if _G._nv_toneNow then pcall(_G._nv_toneNow, pnl) end

		pnl:SetAttribute("_nvCloseTok", (tonumber(pnl:GetAttribute("_nvCloseTok")) or 0) + 1)
		if _G._nv_frameFadeOf and _G._nv_frameFadeOf(pnl) > 0.001 and _G._nv_frameFade then
			_G._nv_frameFade(pnl, 0)
		end
		local closeAx = pnl:GetAttribute("_nvCloseAx")
		if typeof(closeAx) == "number" then
			pnl.AnchorPoint = Vector2.new(closeAx, tonumber(pnl:GetAttribute("_nvCloseAy")) or 0.5)
			pnl:SetAttribute("_nvCloseAx", nil)
			pnl:SetAttribute("_nvCloseAy", nil)
		end
		local rest = _nvFloatCloseRest[pnl]
		if rest then
			pnl.Position = rest
			tween(pnl, TweenInfo.new(0), {Position = rest})
			_nvFloatCloseRest[pnl] = nil
		end
		pnl.BackgroundTransparency = 1
		if placed then
			pnl:SetAttribute("_nvPlaceScale", placed.scale)
		else
			pnl:SetAttribute("_nvPlaceScale", nil)
			if pnl:GetAttribute("_nvStretched") then
				local dw = tonumber(pnl:GetAttribute("_nvDesignW"))
				local dh = tonumber(pnl:GetAttribute("_nvDesignH"))
				if dw and dh then pnl.Size = UDim2.fromOffset(dw, dh) end
				pnl:SetAttribute("_nvStretched", nil)
			end
		end
		local targetScale = tonumber(_computePanelScale()) or 1
		if targetScale <= 0 then targetScale = 1 end
		if not placed then
			tween(pnlUIScale, TweenInfo.new(0), {Scale = targetScale})
			if type(_G._nv_placeFloatingPanel) == "function" then
				pcall(_G._nv_placeFloatingPanel, pnl)
			end
		end
		local sh = pnl:FindFirstChild("DarkGlow")
		if sh then pcall(function() sh.Transparency = 0.45 end) end
		local surface = pnl:FindFirstChild("UtilitySurface")
		if surface then surface.Visible = true end
		local edge = pnl:FindFirstChildOfClass("UIStroke") or (surface and surface:FindFirstChildOfClass("UIStroke"))
		if edge then edge.Enabled = true end
		if placed and type(_G._nv_playPlacedOpen) == "function" then
			_G._nv_playPlacedOpen(pnl, pnlUIScale, placed)
		else
			pnlUIScale.Scale = targetScale
			local restPos = pnl.Position
			pnl.Position = restPos + UDim2.fromOffset(0, 10)
			tween(pnl, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = restPos})
		end
		if _G._nv_scrollFadeAll then task.defer(pcall, _G._nv_scrollFadeAll, pnl) end
	end)

	do
		local MIN_W, MIN_H = w, h
		local function stretchable() return not _G._nv_panelZooms(pnl) end
		local rsz = createInstance("TextButton", {
			Parent = pnl,
			Name = "ResizeHandle",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, 16, 1, 16),
			Size = UDim2.new(0, 44, 0, 44),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 900,
		})
		local _rzing = false
		rsz.MouseEnter:Connect(function()
			if not stretchable() then return end
			pcall(function() userInputService.MouseIcon = "rbxasset://SystemCursors/SizeNWSE" end)
		end)
		rsz.MouseLeave:Connect(function() if not _rzing then pcall(function() userInputService.MouseIcon = "" end) end end)
		local _rzStartPosX, _rzStartPosY, _rzStartM, _rzStartW, _rzStartH = 0, 0, nil, w, h
		local _rzConn, _rzEndConn, _rzFocusConn
		local function stopResize()
			_rzing = false
			pcall(function() userInputService.MouseIcon = "" end)
			if _rzConn then _rzConn:Disconnect()  _rzConn = nil end
			if _rzEndConn then _rzEndConn:Disconnect()  _rzEndConn = nil end
			if _rzFocusConn then _rzFocusConn:Disconnect()  _rzFocusConn = nil end
			if _cs and _cs._nvDragOwner == rsz then _cs._nvDragOwner = nil end
		end
		local function updateResize()
			if not _rzing or not pnl.Parent then return end
			local sc = pnlUIScale.Scale  if sc <= 0 then sc = 1 end
			local d = userInputService:GetMouseLocation() - _rzStartM
			local cam = workspace.CurrentCamera
			local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
			local ap = pnl.AbsolutePosition
			local _, _, capW, capH = _G._nv_panelLimits(pnl)
			local maxW = math.max(MIN_W, math.min(capW, (vp.X - ap.X - 6) / sc))
			local maxH = math.max(MIN_H, math.min(capH, (vp.Y - ap.Y - 6) / sc))
			local nextW = math.clamp(_rzStartW + d.X / sc, MIN_W, maxW)
			local nextH = math.clamp(_rzStartH + d.Y / sc, MIN_H, maxH)
			if nextW ~= pnl.Size.X.Offset or nextH ~= pnl.Size.Y.Offset then
				pnl.Size = UDim2.new(0, nextW, 0, nextH)
				local apt = pnl.AnchorPoint
				pnl.Position = UDim2.new(0, _rzStartPosX + (nextW - _rzStartW) * apt.X * sc, 0, _rzStartPosY + (nextH - _rzStartH) * apt.Y * sc)
			end
		end
		rsz.InputBegan:Connect(function(inp)
			if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
			if not stretchable() then return end
			if _cs and _cs._nvDragOwner ~= nil and _cs._nvDragOwner ~= rsz then return end
			local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
			_rzStartPosX = pnl.Position.X.Offset + pnl.Position.X.Scale * vp.X
			_rzStartPosY = pnl.Position.Y.Offset + pnl.Position.Y.Scale * vp.Y
			_rzStartM = userInputService:GetMouseLocation()
			_rzStartW = pnl.Size.X.Offset ; _rzStartH = pnl.Size.Y.Offset
			_rzing = true
			if _cs then _cs._nvDragOwner = rsz end
			_rzConn = runService.RenderStepped:Connect(function()
				updateResize()
			end)
			_rzEndConn = userInputService.InputEnded:Connect(function(ended)
				if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
					stopResize()
				end
			end)
			_rzFocusConn = userInputService.WindowFocusReleased:Connect(stopResize)
		end)
		pnl.AncestryChanged:Connect(function(_, parent)
			if not parent then stopResize() end
		end)
	end

	return pnl
end
