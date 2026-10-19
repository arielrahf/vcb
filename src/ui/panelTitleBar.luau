return function(env, pnl, title, onClose)
local C = env.C
local _nvFloatCloseRest = env._nvFloatCloseRest
local _nvL = env._nvL
local createInstance = env.createInstance
local tween = env.tween
	local BAR_H = tonumber(pnl:GetAttribute("UtilityTitleHeight")) or 34
	local BTN = 28
	local CLOSE_RIGHT = 14
	local HEAD_H = BAR_H + 14
	local MIN_GAP = 4

	local bar = createInstance("Frame", { Parent = pnl, Name = "TitleBar", Size = UDim2.new(1, 0, 0, HEAD_H), BackgroundTransparency = 1, BorderSizePixel = 0, Active = true, ZIndex = 151 })

	local rightReserve = CLOSE_RIGHT + BTN + MIN_GAP + BTN + 10
	if type(title) == "string" and title == title:upper() and title:find("%a") then
		local KEEP = {VC = true, ESP = true, UGC = true, FOV = true, ID = true, UI = true, NPC = true, FPS = true}
		local words = {}
		for word in title:gmatch("%S+") do
			if KEEP[word] then words[#words + 1] = word
			elseif #words == 0 then words[#words + 1] = word:sub(1, 1) .. word:sub(2):lower()
			else words[#words + 1] = word:lower() end
		end
		title = table.concat(words, " ")
	end
	local lbl = createInstance("TextLabel", {
		Parent = bar,
		Name = "Title",
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = BAR_H >= 44 and 18 or 14,
		TextColor3 = C.TEXT,
		Position = UDim2.new(0, 18, 0, 0),
		Size = UDim2.new(1, -rightReserve, 1, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 152,
	})

	local closeBtn = createInstance("TextButton", {
		Parent = bar,
		Name = "CloseBtn",
		Text = "",
		Size = UDim2.new(0, BTN, 0, BTN),
		Position = UDim2.new(1, -(CLOSE_RIGHT + BTN), 0.5, -BTN / 2),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 153,
		AutoButtonColor = false,
	})
	createInstance("UICorner", { Parent = closeBtn, CornerRadius = UDim.new(1, 0) })

	local closeIcon = createInstance("ImageLabel", { Parent = closeBtn, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5) })
	if _G._nv_lazyFluent then _G._nv_lazyFluent(closeIcon, "clear") end
	closeIcon.ImageColor3 = Color3.new(1, 1, 1)
	closeIcon.ImageTransparency = 0.35
	closeIcon.Size = UDim2.new(0, 17, 0, 17)
	closeIcon.ZIndex = 154

	local minBtn = createInstance("TextButton", {
		Parent = bar,
		Name = "MinimizeBtn",
		Text = "",
		Size = UDim2.new(0, BTN, 0, BTN),
		Position = UDim2.new(1, -(CLOSE_RIGHT + BTN + MIN_GAP + BTN), 0.5, -BTN / 2),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 153,
		AutoButtonColor = false,
	})
	createInstance("UICorner", { Parent = minBtn, CornerRadius = UDim.new(1, 0) })

	local minIcon = createInstance("ImageLabel", { Parent = minBtn, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5) })
	if _G._nv_lazyFluent then _G._nv_lazyFluent(minIcon, "chevrondown") end
	minIcon.ImageColor3 = Color3.new(1, 1, 1)
	minIcon.ImageTransparency = 0.35
	minIcon.Size = UDim2.new(0, 16, 0, 16)
	minIcon.ZIndex = 154

	local function panelScale()
		local us = pnl:FindFirstChildOfClass("UIScale")
		return (us and us.Scale) or 1
	end

	local function viewport()
		local cam = workspace.CurrentCamera
		return cam and cam.ViewportSize or Vector2.new(1280, 720)
	end

	local function rawPos()
		local vp = viewport()
		return pnl.Position.X.Offset + pnl.Position.X.Scale * vp.X,
			pnl.Position.Y.Offset + pnl.Position.Y.Scale * vp.Y
	end

	local function topLimit()
		local margin = 8
		local host = pnl.Parent
		if not (host and host:IsA("ScreenGui") and host.IgnoreGuiInset) then return margin end
		local ok, inset = pcall(function() return game:GetService("GuiService"):GetGuiInset() end)
		if ok and typeof(inset) == "Vector2" then return math.max(margin, inset.Y) end
		return margin
	end

	local function anchorPx()
		local vp = viewport()
		return pnl.Position.X.Offset + pnl.Position.X.Scale * vp.X,
			pnl.Position.Y.Offset + pnl.Position.Y.Scale * vp.Y
	end

	local function posKeepingTop(newW, newH)
		local sc = panelScale()
		if sc <= 0 then sc = 1 end
		local ax, ay = pnl.AnchorPoint.X, pnl.AnchorPoint.Y
		local px, py = anchorPx()
		local topX = px - ax * pnl.Size.X.Offset * sc
		local topY = py - ay * pnl.Size.Y.Offset * sc
		return UDim2.fromOffset(topX + ax * newW * sc, topY + ay * newH * sc)
	end

	local function clampPosFor(w, h, px, py)
		local vp = viewport()
		local sc = panelScale()
		if sc <= 0 then sc = 1 end
		local sw, sh = w * sc, h * sc
		local ax, ay = pnl.AnchorPoint.X, pnl.AnchorPoint.Y
		local pad = (tonumber(pnl:GetAttribute("_nvDragPadBottom")) or 0) * sc
		local margin, topMin = 8, topLimit()
		local minX, maxX = margin + sw * ax, vp.X - margin - sw * (1 - ax)
		local minY, maxY = topMin + sh * ay, vp.Y - margin - pad - sh * (1 - ay)
		if minX > maxX then px = minX else px = math.clamp(px, minX, maxX) end
		if minY > maxY then py = minY else py = math.clamp(py, minY, maxY) end
		return UDim2.new(0, px, 0, py)
	end

	local function setResizeVisible(vis)
		local rsz = pnl:FindFirstChild("ResizeHandle")
		local grip = pnl:FindFirstChild("ResizeGrip")
		if rsz and rsz:IsA("GuiObject") then rsz.Visible = vis end
		if grip and grip:IsA("GuiObject") then grip.Visible = vis end
	end

	local function isTitleChrome(ch)
		if not ch then return true end
		local n = ch.Name
		if n == "UtilitySurface" or n == "TitleBar" or n == "PanelOverlay" or n == "WpOverlay" or n == "Wallpaper"
			or n == "BlueCornerGlow" or n == "ResizeHandle" or n == "ResizeGrip" then
			return true
		end
		return ch:IsA("UIScale") or ch:IsA("UICorner") or ch:IsA("UIStroke") or ch:IsA("UIGradient")
	end

	local bodyVisCache = nil
	local function hideBodyForMin(extra)
		bodyVisCache = {}
		for _, ch in pnl:GetChildren() do
			if ch:IsA("GuiObject") and not isTitleChrome(ch) and ch ~= extra then
				bodyVisCache[ch] = ch.Visible
				ch.Visible = false
			end
		end
		local glow = pnl:FindFirstChild("BlueCornerGlow")
		if glow and glow:IsA("GuiObject") then
			bodyVisCache[glow] = glow.Visible
			glow.Visible = false
		end
	end

	local function restoreBodyAfterMin()
		if not bodyVisCache then return end
		for ch, vis in bodyVisCache do
			if ch and ch.Parent then
				ch.Visible = vis
			end
		end
		bodyVisCache = nil
	end

	local pinned = nil
	local function pinBody(w, h)
		if pinned then return end
		pinned = {}
		for _, ch in pnl:GetChildren() do
			if ch:IsA("GuiObject") and not isTitleChrome(ch) then
				local sz, pos, ap = ch.Size, ch.Position, ch.AnchorPoint
				if sz.X.Scale ~= 0 or sz.Y.Scale ~= 0 or pos.X.Scale ~= 0 or pos.Y.Scale ~= 0 then
					local sw = sz.X.Scale * w + sz.X.Offset
					local sh = sz.Y.Scale * h + sz.Y.Offset
					pinned[ch] = {sz, pos, ap}
					ch.AnchorPoint = Vector2.zero
					ch.Position = UDim2.fromOffset(pos.X.Scale * w + pos.X.Offset - ap.X * sw, pos.Y.Scale * h + pos.Y.Offset - ap.Y * sh)
					ch.Size = UDim2.fromOffset(sw, sh)
				end
			end
		end
	end

	local function unpinBody()
		if not pinned then return end
		for ch, rest in pinned do
			if ch.Parent == pnl then
				ch.AnchorPoint = rest[3]
				ch.Position = rest[2]
				ch.Size = rest[1]
			end
		end
		pinned = nil
	end

	local fadedBody = {}
	local function fadeBody(hiding, dur, delay)
		if not _G._nv_frameFade then return end
		if hiding then
			table.clear(fadedBody)
			for _, ch in pnl:GetChildren() do
				if ch:IsA("GuiObject") and ch.Visible and not isTitleChrome(ch) then fadedBody[#fadedBody + 1] = ch end
			end
		end
		local ti = nil
		if dur > 0 then
			ti = TweenInfo.new(dur, hiding and Enum.EasingStyle.Quad or Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, delay or 0)
		end
		for _, ch in fadedBody do
			if ch.Parent then pcall(_G._nv_frameFade, ch, hiding and 1 or 0, ti) end
		end
		if not hiding and not ti then table.clear(fadedBody) end
	end

	local function settleBody()
		fadeBody(false, 0)
		unpinBody()
	end

	local fadeRest = setmetatable({}, { __mode = "k" })

	local function findMinFade()
		for _, ch in pnl:GetChildren() do
			if ch:IsA("GuiObject") and ch:GetAttribute("_nvMinFade") then
				return ch
			end
		end
		return nil
	end

	local function cacheFadeTargets(root)
		if fadeRest[root] then return fadeRest[root] end
		local entries = {}
		local function add(obj, prop)
			if obj and prop then
				entries[#entries + 1] = { obj = obj, prop = prop, rest = obj[prop] }
			end
		end
		add(root, "BackgroundTransparency")
		for _, d in root:GetDescendants() do
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				add(d, "TextTransparency")
				if d.BackgroundTransparency < 0.99 then add(d, "BackgroundTransparency") end
			elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
				add(d, "ImageTransparency")
				if d.BackgroundTransparency < 0.99 then add(d, "BackgroundTransparency") end
			elseif d:IsA("Frame") or d:IsA("ScrollingFrame") then
				if d.BackgroundTransparency < 0.99 then add(d, "BackgroundTransparency") end
			elseif d:IsA("UIStroke") then
				add(d, "Transparency")
			end
		end
		fadeRest[root] = entries
		return entries
	end

	local function setMinFadeChrome(root, hiding)
		if not root then return end
		local function visit(obj)
			if obj:IsA("UIStroke") then
				if hiding then
					if obj:GetAttribute("_nvMinStrokeRest") == nil then
						obj:SetAttribute("_nvMinStrokeRest", obj.Transparency)
						obj:SetAttribute("_nvMinStrokeEn", obj.Enabled and 1 or 0)
					end

					obj.Transparency = 1
					obj.Enabled = false
				else
					local en = obj:GetAttribute("_nvMinStrokeEn")
					local rest = obj:GetAttribute("_nvMinStrokeRest")
					obj.Enabled = en ~= 0
					if typeof(rest) == "number" then
						obj.Transparency = rest
					end
				end
			elseif obj.Name == "BlueCornerGlow" and obj:IsA("GuiObject") then
				if hiding then
					if obj:GetAttribute("_nvMinGlowRest") == nil then
						obj:SetAttribute("_nvMinGlowRest", obj.BackgroundTransparency)
					end
					obj.BackgroundTransparency = 1
					obj.Visible = false
				else
					local rest = obj:GetAttribute("_nvMinGlowRest")
					obj.Visible = _nvL.currentThemeName ~= "Modern"
					if typeof(rest) == "number" then
						obj.BackgroundTransparency = rest
					else
						obj.BackgroundTransparency = 0.78
					end
				end
			end
		end
		visit(root)
		for _, d in root:GetDescendants() do
			visit(d)
		end
	end

	local function fadeExtra(root, hiding, dur)
		if not root then return nil end
		dur = tonumber(dur) or 0.2
		if root:IsA("CanvasGroup") then
			local target = hiding and 1 or 0

			setMinFadeChrome(root, hiding)
			if dur <= 0 then
				root.GroupTransparency = target
				return nil
			end
			local ti = TweenInfo.new(dur, Enum.EasingStyle.Quint, hiding and Enum.EasingDirection.In or Enum.EasingDirection.Out)
			return tween(root, ti, { GroupTransparency = target })
		end
		local entries = cacheFadeTargets(root)
		if dur <= 0 then
			for _, e in entries do
				if e.obj and e.obj.Parent then
					e.obj[e.prop] = hiding and 1 or e.rest
				end
			end
			setMinFadeChrome(root, hiding)
			return nil
		end
		local ti = TweenInfo.new(dur, Enum.EasingStyle.Quint, hiding and Enum.EasingDirection.In or Enum.EasingDirection.Out)
		if hiding then setMinFadeChrome(root, true) end
		local last = nil
		for _, e in entries do
			if e.obj and e.obj.Parent then
				last = tween(e.obj, ti, { [e.prop] = hiding and 1 or e.rest })
			end
		end
		if not hiding then
			task.delay(dur, function()
				if root and root.Parent then setMinFadeChrome(root, false) end
			end)
		end
		return last
	end

	local function resetExtraLayout(extra)
		if not extra then return end
		local gap = tonumber(extra:GetAttribute("_nvMinDockGap")) or 0
		local h = tonumber(extra:GetAttribute("_nvMinDockH")) or extra.Size.Y.Offset
		extra.Size = UDim2.new(1, 0, 0, h)
		extra.Position = UDim2.new(0, 0, 1, gap)
		pnl:SetAttribute("_nvDragPadBottom", h + gap)
	end

	local closing = false
	local minimized = false
	local animating = false
	local expandW, expandH = pnl.Size.X.Offset, pnl.Size.Y.Offset
	local origClips = pnl.ClipsDescendants

	local function syncExpandFromPanel()
		if not minimized then
			expandW = math.max(pnl.Size.X.Offset, 120)
			expandH = math.max(pnl.Size.Y.Offset, BAR_H + 40)
		end
	end

	pnl:GetPropertyChangedSignal("Size"):Connect(function()
		if animating or minimized then return end
		syncExpandFromPanel()
	end)

	local function panelBg()
		return pnl:FindFirstChild("UtilitySurface") and 1 or 0
	end
	minBtn.MouseButton1Click:Connect(function()
		if closing or animating or not pnl.Parent then return end
		animating = true
		local tok = (pnl:GetAttribute("_nvMinTok") or 0) + 1
		pnl:SetAttribute("_nvMinTok", tok)
		pnl.BackgroundTransparency = panelBg()

		local extra = findMinFade()

		local function alive()
			return (pnl:GetAttribute("_nvMinTok") or 0) == tok and pnl.Parent ~= nil
		end

		if not minimized then
			syncExpandFromPanel()
			pnl:SetAttribute("_nvMinimized", true)
			pnl:SetAttribute("_nvMinAnim", true)
			setResizeVisible(false)
			pinBody(expandW, expandH)
			fadeBody(true, 0.22)

			local shutW, shutH = expandW, HEAD_H
			local fadeDur = 0.2
			local shutTi = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

			local function beginCollapse()
				if not alive() then animating = false ; pnl:SetAttribute("_nvMinAnim", nil) ; return end
				if extra then
					if extra:IsA("CanvasGroup") then extra.GroupTransparency = 1 end
					setMinFadeChrome(extra, true)
					extra.Visible = false
					resetExtraLayout(extra)
				end
				pnl.ClipsDescendants = true

				local shutPos = posKeepingTop(shutW, shutH)
				shutPos = clampPosFor(shutW, shutH, shutPos.X.Offset, shutPos.Y.Offset)
				tween(pnl, shutTi, {
					Size = UDim2.new(0, shutW, 0, shutH),
					Position = shutPos,
				})

				task.delay(0.42, function()
					if not alive() then animating = false ; pnl:SetAttribute("_nvMinAnim", nil) ; return end
					hideBodyForMin(extra)
					pnl.BackgroundTransparency = panelBg()
					minimized = true
					animating = false
					pnl:SetAttribute("_nvMinAnim", nil)
				end)
			end

			if extra then
				extra.Visible = true
				resetExtraLayout(extra)
				if extra:IsA("CanvasGroup") then extra.GroupTransparency = 0 end
				local fadeTw = fadeExtra(extra, true, fadeDur)
				if fadeTw then
					fadeTw.Completed:Connect(beginCollapse)
				else
					beginCollapse()
				end
			else
				beginCollapse()
			end
		else
			pnl:SetAttribute("_nvMinAnim", true)
			local openW, openH = expandW, expandH
			local keepPos = posKeepingTop(openW, openH)
			local finalPos = clampPosFor(openW, openH, keepPos.X.Offset, keepPos.Y.Offset)
			pnl.ClipsDescendants = true
			pnl.BackgroundTransparency = panelBg()
			pinBody(openW, openH)
			restoreBodyAfterMin()
			fadeBody(false, 0.36, 0.08)
			if extra then
				extra.Visible = false
				if extra:IsA("CanvasGroup") then extra.GroupTransparency = 1 end
			end

			local openTi = TweenInfo.new(0.44, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local fadeDur = 0.32
			tween(pnl, openTi, {
				Size = UDim2.new(0, openW, 0, openH),
				Position = finalPos,
			})

			task.delay(0.45, function()
				if not alive() then animating = false ; pnl:SetAttribute("_nvMinAnim", nil) ; return end
				minimized = false
				pnl:SetAttribute("_nvMinimized", false)
				pnl:SetAttribute("_nvMinAnim", nil)
				pnl.BackgroundTransparency = panelBg()
				unpinBody()
				pnl.ClipsDescendants = origClips
				setResizeVisible(true)

				if extra then
					resetExtraLayout(extra)
					extra.Visible = true
					if extra:IsA("CanvasGroup") then extra.GroupTransparency = 1 end
					setMinFadeChrome(extra, false)
					fadeExtra(extra, false, fadeDur)
				end

				local c = clampPosFor(pnl.Size.X.Offset, pnl.Size.Y.Offset, rawPos())
				local px, py = rawPos()
				if c.X.Offset ~= px or c.Y.Offset ~= py then
					tween(pnl, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = c })
				end
				task.delay(fadeDur, function()
					if alive() then animating = false end
				end)
				if not extra then animating = false end
			end)
		end
	end)

	pnl:GetPropertyChangedSignal("Visible"):Connect(function()
		if pnl.Visible then return end
		if not (minimized or pnl:GetAttribute("_nvMinimized")) then return end
		animating = false
		minimized = false
		pnl:SetAttribute("_nvMinimized", false)
		pcall(restoreBodyAfterMin)
		pcall(settleBody)
		pcall(function() setResizeVisible(true) end)
		pnl.ClipsDescendants = origClips
		if expandW and expandH then
			local keep = posKeepingTop(expandW, expandH)
			pnl.Size = UDim2.new(0, expandW, 0, expandH)
			pnl.Position = clampPosFor(expandW, expandH, keep.X.Offset, keep.Y.Offset)
		end
	end)

	minBtn.MouseEnter:Connect(function()
		if closing then return end
		tween(minIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quint), { ImageTransparency = 0 })
	end)
	minBtn.MouseLeave:Connect(function()
		if closing then return end
		tween(minIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { ImageTransparency = 0.35 })
	end)
	closeBtn.MouseEnter:Connect(function()
		if closing then return end
		tween(closeIcon, TweenInfo.new(0.15), { ImageTransparency = 0 })
	end)
	closeBtn.MouseLeave:Connect(function()
		if closing then return end
		tween(closeIcon, TweenInfo.new(0.2), { ImageTransparency = 0.35 })
	end)

	local function doClose()
		if closing or animating then return end
		closing = true
		pnl:SetAttribute("_nvClosing", true)
		tween(closeIcon, TweenInfo.new(0), {ImageTransparency = closeIcon.ImageTransparency})
		tween(minIcon, TweenInfo.new(0), {ImageTransparency = minIcon.ImageTransparency})

		local CLOSE_DUR = 0.5
		local ti = TweenInfo.new(CLOSE_DUR, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local restPos = pnl.Position
		local restAnchor = pnl.AnchorPoint
		local panelScale = pnl:FindFirstChildOfClass("UIScale")
		local restScale = panelScale and panelScale.Scale or nil
		local wasMinimized = minimized

		local tok = (pnl:GetAttribute("_nvCloseTok") or 0) + 1
		pnl:SetAttribute("_nvCloseTok", tok)
		_nvFloatCloseRest[pnl] = restPos
		pnl:SetAttribute("_nvCloseAx", restAnchor.X)
		pnl:SetAttribute("_nvCloseAy", restAnchor.Y)

		local sc = (panelScale and panelScale.Scale) or 1
		if sc <= 0 then sc = 1 end
		local vp = viewport()
		local px = restPos.X.Offset + restPos.X.Scale * vp.X
		local py = restPos.Y.Offset + restPos.Y.Scale * vp.Y
		local cx = px + (0.5 - restAnchor.X) * pnl.Size.X.Offset * sc
		local cy = py + (0.5 - restAnchor.Y) * pnl.Size.Y.Offset * sc
		pnl.AnchorPoint = Vector2.new(0.5, 0.5)
		pnl.Position = UDim2.fromOffset(cx, cy)

		pnl:SetAttribute("NvFade", true)
		tween(pnl, ti, { GroupTransparency = 1 })
		tween(pnl, ti, { Position = UDim2.fromOffset(cx, cy + 14) })

		task.delay(CLOSE_DUR + 0.02, function()
			if (pnl:GetAttribute("_nvCloseTok") or 0) ~= tok then
				closing = false
				pnl:SetAttribute("_nvClosing", nil)
				return
			end
			if onClose then onClose() end

		if pnl.Parent then
			pnl.AnchorPoint = restAnchor
			pnl:SetAttribute("_nvCloseAx", nil)
			pnl:SetAttribute("_nvCloseAy", nil)
			pnl.Position = restPos
			if _G._nv_frameFade then _G._nv_frameFade(pnl, 0) end
			if panelScale and restScale then
				tween(panelScale, TweenInfo.new(0), {Scale = restScale})
			end
			local glow = pnl:FindFirstChild("DarkGlow")
			if glow then pcall(function() glow.Transparency = 0.45 end) end
			if wasMinimized then
					minimized = false
					pnl:SetAttribute("_nvMinimized", false)
					local openPos = posKeepingTop(expandW, expandH)
					openPos = clampPosFor(expandW, expandH, openPos.X.Offset, openPos.Y.Offset)
					pnl.Size = UDim2.new(0, expandW, 0, expandH)
					pnl.Position = openPos
					pnl.ClipsDescendants = origClips
					setResizeVisible(true)
					restoreBodyAfterMin()
					settleBody()
					local extra = findMinFade()
					if extra then
						resetExtraLayout(extra)
						extra.Visible = true
						if extra:IsA("CanvasGroup") then extra.GroupTransparency = 0 end
						fadeExtra(extra, false, 0)
					end
				end
			end
			_nvFloatCloseRest[pnl] = nil
			if closeIcon.Parent then
				closeIcon.Rotation = 0
				closeIcon.ImageTransparency = 0.45
			end
			if minIcon.Parent then
				minIcon.ImageTransparency = 0.45
			end
			pnl:SetAttribute("_nvClosing", nil)
			closing = false
		end)
	end
	closeBtn.MouseButton1Click:Connect(doClose)
	_G._nv_panelClosers = _G._nv_panelClosers or setmetatable({}, {__mode = "k"})
	_G._nv_panelClosers[pnl] = doClose
	closeBtn.MouseEnter:Connect(function()
		if closing then return end
		tween(closeIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 0})
	end)
	closeBtn.MouseLeave:Connect(function()
		if closing then return end
		tween(closeIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {ImageTransparency = 0.45})
	end)

	return bar
end
