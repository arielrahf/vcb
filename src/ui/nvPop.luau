return function(env)
local C = env.C
local createInstance = env.createInstance
local tween = env.tween
	local P = {}
	local WHITE, INK = Color3.fromRGB(242, 242, 244), Color3.fromRGB(18, 18, 20)
	local SUBTLE = Color3.fromRGB(150, 150, 156)
	local QUICK = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	P.WHITE, P.INK, P.SUBTLE, P.QUICK, P.PAD = WHITE, INK, SUBTLE, QUICK, 18
	P.TINT = {
		blue = {Color3.fromRGB(13, 40, 51), Color3.fromRGB(64, 186, 255)},
		purple = {Color3.fromRGB(38, 28, 62), Color3.fromRGB(168, 120, 255)},
		teal = {Color3.fromRGB(14, 46, 40), Color3.fromRGB(56, 224, 186)},
		orange = {Color3.fromRGB(62, 36, 16), Color3.fromRGB(255, 150, 50)},
		red = {Color3.fromRGB(62, 20, 24), Color3.fromRGB(255, 96, 96)},
		yellow = {Color3.fromRGB(56, 46, 12), Color3.fromRGB(245, 197, 66)},
		gray = {Color3.fromRGB(46, 46, 49), C.TEXT},
	}
	local function round(o, r)
		local c = o:FindFirstChildOfClass("UICorner") or createInstance("UICorner", { Parent = o })
		c.CornerRadius = r and UDim.new(0, r) or UDim.new(1, 0)
		return c
	end
	P.round = round
	function P.text(parent, value, font, size, color, x, y, w, h, align)
		local l = createInstance("TextLabel", {
			Parent = parent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = font,
			TextSize = size,
			TextColor3 = color,
			Text = value,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			ZIndex = 156,
			TextXAlignment = align or Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		return l
	end
	function P.icon(parent, name, size, x, y, color)
		local i = createInstance("ImageLabel", {
			Parent = parent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(size, size),
			Position = UDim2.fromOffset(x, y),
			ImageColor3 = color or SUBTLE,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 157,
		})
		if _G._nv_lazyFluent then pcall(_G._nv_lazyFluent, i, name) end
		return i
	end
	function P.group(parent, x, y, w, h)
		local g = createInstance("Frame", {
			Parent = parent,
			Name = "Group",
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.955,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			ZIndex = 152,
		})
		round(g, 14)
		return g
	end
	function P.line(parent, x, y, w)
		local l = createInstance("Frame", {
			Parent = parent,
			Name = "Rule",
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.94,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, 1),
			ZIndex = 153,
		})
		return l
	end
	function P.tile(parent, name, x, y, tint)
		tint = tint or P.TINT.gray
		local t = createInstance("Frame", {
			Parent = parent,
			Name = "Tile",
			BackgroundColor3 = tint[1],
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(30, 30),
			ZIndex = 155,
		})
		round(t, 10)
		P.icon(t, name, 16, 7, 7, tint[2])
		return t
	end
	function P.lift(btn, radius)
		local lift = createInstance("Frame", {
			Parent = btn,
			Name = "Lift",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 156,
		})
		round(lift, radius)
		btn.MouseEnter:Connect(function() tween(lift, TweenInfo.new(0.18), {BackgroundTransparency = 0.95}) end)
		btn.MouseLeave:Connect(function() tween(lift, TweenInfo.new(0.18), {BackgroundTransparency = 1}) end)
		return lift
	end
	function P.press(btn)
		if _G._nv_pressable then pcall(_G._nv_pressable, btn) end
	end
	function P.switch(parent, on)
		local set, track = _G._nv_switch(parent, on, {z = 157})
		return function(v, animate) set(v, animate ~= false) end, track
	end
	function P.rowButton(btn, x, y, w, h)
		btn.Position = UDim2.fromOffset(x, y); btn.Size = UDim2.fromOffset(w, h)
		btn.BackgroundTransparency = 1; btn.TextTransparency = 1; btn.AutoButtonColor = false; btn.BorderSizePixel = 0
		btn.ZIndex = 154
		local hover = createInstance("Frame", {
			Parent = btn,
			Name = "Lift",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 154,
		})
		round(hover, 14)
		btn.MouseEnter:Connect(function() tween(hover, TweenInfo.new(0.15), {BackgroundTransparency = 0.97}) end)
		btn.MouseLeave:Connect(function() tween(hover, TweenInfo.new(0.15), {BackgroundTransparency = 1}) end)
		return btn
	end
	local function sentence(s)
		s = tostring(s or "")
		if s:match("%a") and s == s:upper() then s = s:sub(1, 1) .. s:sub(2):lower() end
		return s
	end
	P.sentence = sentence
	function P.cta(btn, x, y, w, h, tintFor)
		h = h or 36
		btn.Position = UDim2.fromOffset(x, y); btn.Size = UDim2.fromOffset(w, h); btn.AnchorPoint = Vector2.zero
		btn.BackgroundTransparency = 1; btn.TextTransparency = 1; btn.AutoButtonColor = false; btn.BorderSizePixel = 0
		round(btn, h / 2)
		local face = createInstance("Frame", {
			Parent = btn,
			Name = "Face",
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			ZIndex = 155,
			BackgroundColor3 = WHITE,
		})
		round(face, h / 2)
		local label = createInstance("TextLabel", {
			Parent = btn,
			Name = "FaceText",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 157,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = INK,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		local first = true
		local function paint()
			label.Text = sentence(btn.Text)
			local t = tintFor and tintFor(btn.Text)
			local bg, fg = t and t[1] or WHITE, t and t[2] or INK
			if first then
				face.BackgroundColor3 = bg; label.TextColor3 = fg; first = false
			else
				tween(face, QUICK, {BackgroundColor3 = bg}); tween(label, QUICK, {TextColor3 = fg})
			end
		end
		paint()
		btn:GetPropertyChangedSignal("Text"):Connect(paint)
		P.lift(btn, h / 2)
		P.press(btn)
		return face, label
	end
	function P.slider(parent, x, y, w, label, initial, minimum, maximum, onChange)
		local h = _G._nv_utilitySlider(parent, label, initial, minimum, maximum, onChange)
		local card = h.card
		card.Position = UDim2.fromOffset(x, y); card.Size = UDim2.fromOffset(w, 52); card.ZIndex = 153
		h.titleLbl.Position = UDim2.fromOffset(0, 9); h.titleLbl.Size = UDim2.new(1, -64, 0, 18)
		h.titleLbl.Font = Enum.Font.GothamBold; h.titleLbl.TextSize = 13; h.titleLbl.TextColor3 = C.TEXT
		h.info.AnchorPoint = Vector2.new(1, 0); h.info.Position = UDim2.new(1, 0, 0, 9); h.info.Size = UDim2.fromOffset(60, 18)
		h.info.Font = Enum.Font.GothamBold; h.info.TextSize = 12; h.info.TextColor3 = C.TEXT
		h.info.TextXAlignment = Enum.TextXAlignment.Right
		h.track.AnchorPoint = Vector2.new(0, 0.5); h.track.Position = UDim2.new(0, 0, 0, 38); h.track.Size = UDim2.new(1, 0, 0, h.track.Size.Y.Offset)
		return h
	end
	function P.sliderGroup(parent, x, y, w, specs)
		local g = P.group(parent, x, y, w, #specs * 52)
		local handles = {}
		for n, s in specs do
			handles[n] = P.slider(g, 14, (n - 1) * 52, w - 28, s[1], s[2], s[3], s[4], s[5])
			if n < #specs then P.line(g, 14, n * 52, w - 28) end
		end
		return g, handles
	end
	function P.field(parent, x, y, w, h)
		local f = createInstance("Frame", {
			Parent = parent,
			Name = "Field",
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.93,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h or 36),
			ZIndex = 152,
		})
		round(f, math.floor((h or 36) / 2))
		return f
	end
	function P.styleBox(box)
		box.Font = Enum.Font.GothamMedium; box.TextSize = 13; box.TextColor3 = C.TEXT
		box.PlaceholderColor3 = Color3.fromRGB(118, 118, 124)
	end
	function P.stopTint(text)
		if tostring(text):lower() == "stop" then return P.TINT.red end
	return end
	return P
end
