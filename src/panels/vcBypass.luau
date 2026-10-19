return function(env)
local C = env.C
local _cs = env._cs
local _isMobile = env._isMobile
local _nvFloatCloseRest = env._nvFloatCloseRest
local _nvL = env._nvL
local createInstance = env.createInstance
local makeFloatingPanel = env.makeFloatingPanel
local makePanelTitleBar = env.makePanelTitleBar
local tween = env.tween
local VCB_W = _isMobile and 280 or 260
local VCB_H = 170
_cs.vcbPanel = makeFloatingPanel(VCB_W, VCB_H, 0.5, 0)
_cs.vcbPanel.Name = "VCBypassPanel"
_G._vcbPanel = _cs.vcbPanel


local vcbBar = makePanelTitleBar(_cs.vcbPanel, "VC BYPASSER", function() _cs.vcbPanel.Visible = false end)
_cs.makePanelDraggable(_cs.vcbPanel, vcbBar)

local vcbContent = createInstance("Frame", {
  Parent = _cs.vcbPanel,
  Name = "Content",
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Position = UDim2.new(0, 0, 0, 34),
  Size = UDim2.new(1, 0, 1, -34),
  ZIndex = 151,
})

local VCB_BTN_H = 36
local VCB_MIC_W = VCB_BTN_H
local VCB_PAD = 18
local VCB_SEG_H = 32
local VCB_SEG_Y = 14
local VCB_BTN_Y = VCB_SEG_Y + VCB_SEG_H + 10
local VCB_NOTE_Y = VCB_BTN_Y + VCB_BTN_H + 12
local vcbVersion = 1

local vcbSeg = createInstance("Frame", {
  Parent = vcbContent,
  Name = "Versions",
  Position = UDim2.new(0, VCB_PAD, 0, VCB_SEG_Y),
  Size = UDim2.new(1, -VCB_PAD * 2, 0, VCB_SEG_H),
  BackgroundColor3 = _cs.nvPop.TINT.gray[1],
  BorderSizePixel = 0,
  ZIndex = 152,
})
_cs.nvPop.round(vcbSeg)
createInstance("UIStroke", {
  Parent = vcbSeg,
  ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
  Color = Color3.new(1, 1, 1),
  Transparency = 0.9,
  Thickness = 1,
})
local vcbSegThumb = createInstance("Frame", {
  Parent = vcbSeg,
  Name = "Thumb",
  Position = UDim2.new(0, 3, 0, 3),
  Size = UDim2.new(0.5, -4, 1, -6),
  BackgroundColor3 = _cs.nvPop.WHITE,
  BorderSizePixel = 0,
  ZIndex = 153,
})
_cs.nvPop.round(vcbSegThumb)
local vcbSegBtns = {}
for i, label in { "Bypass V1", "Bypass V2" } do
	vcbSegBtns[i] = createInstance("TextButton", {
	  Parent = vcbSeg,
	  Name = "V" .. i,
	  Position = UDim2.new((i - 1) * 0.5, 0, 0, 0),
	  Size = UDim2.new(0.5, 0, 1, 0),
	  BackgroundTransparency = 1,
	  AutoButtonColor = false,
	  Font = Enum.Font.GothamBold,
	  TextSize = 12,
	  Text = label,
	  TextColor3 = i == 1 and _cs.nvPop.INK or C.TEXT,
	  ZIndex = 154,
	})
end

local vcbExecBtn = createInstance("TextButton", {
  Parent = vcbContent,
  Font = Enum.Font.GothamBold,
  TextSize = 13,
  TextColor3 = C.TEXT,
  Text = "Execute Bypass",
  ZIndex = 152,
})
_cs.nvPop.cta(vcbExecBtn, VCB_PAD, VCB_BTN_Y, VCB_W - VCB_PAD * 2 - VCB_MIC_W - 8, VCB_BTN_H, function(text)
	local t = tostring(text):lower()
	if t == "bypassed" then return _cs.nvPop.TINT.teal end
	if t:find("bypassing", 1, true) then return _cs.nvPop.TINT.gray end
return end)
vcbExecBtn.Size = UDim2.new(1, -(VCB_PAD * 2 + VCB_MIC_W + 8), 0, VCB_BTN_H)

local VCB_NOTES = { "Not supported on Xeno or Solara", "Second VCB" }
local vcbNote = _cs.nvPop.text(vcbContent, VCB_NOTES[1], Enum.Font.GothamMedium, 11, _cs.nvPop.SUBTLE, VCB_PAD, VCB_NOTE_Y, VCB_W - VCB_PAD * 2, 14)
vcbNote.Size = UDim2.new(1, -VCB_PAD * 2, 0, 14)

local vcbMicBtn = createInstance("TextButton", {
  Parent = _cs.vcbPanel,
  Size = UDim2.new(0, VCB_MIC_W, 0, VCB_BTN_H),
  Position = UDim2.new(1, -(VCB_PAD + VCB_MIC_W), 0, 34 + VCB_BTN_Y),
  BackgroundTransparency = 1,
  Text = "",
  AutoButtonColor = false,
  BorderSizePixel = 0,
  ZIndex = 152,
})
createInstance("UICorner", { Parent = vcbMicBtn, CornerRadius = UDim.new(1, 0) })
local vcbMicFace = createInstance("Frame", {
  Parent = vcbMicBtn,
  Name = "Face",
  Size = UDim2.fromScale(1, 1),
  BorderSizePixel = 0,
  BackgroundColor3 = _cs.nvPop.TINT.gray[1],
  ZIndex = 152,
})
createInstance("UICorner", { Parent = vcbMicFace, CornerRadius = UDim.new(1, 0) })
do
	local rim = createInstance("UIStroke", {
		Parent = vcbMicFace,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.new(1, 1, 1),
		Transparency = 0.9,
		Thickness = 1,
	})
end
local vcbMicIcon = createInstance("ImageLabel", {
  Parent = vcbMicBtn,
  Size = UDim2.new(0, 18, 0, 18),
  AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.new(0.5, 0, 0.5, 0),
  BackgroundTransparency = 1,
  Icon = "mic",
  ImageColor3 = Color3.new(1, 1, 1),
  ScaleType = Enum.ScaleType.Fit,
  ZIndex = 153,
})
vcbMicIcon:GetAttributeChangedSignal("NvIcon"):Connect(function()
	local muted = vcbMicIcon:GetAttribute("NvIcon") == "micoff"
	local tint = muted and _cs.nvPop.TINT.red or _cs.nvPop.TINT.gray
	tween(vcbMicFace, _cs.nvPop.QUICK, {BackgroundColor3 = tint[1]})
	vcbMicIcon.ImageColor3 = muted and tint[2] or Color3.new(1, 1, 1)
end)
_cs.nvPop.lift(vcbMicBtn)
_cs.nvPop.press(vcbMicBtn)

local function placeVcbTop()
	local pnl = _cs.vcbPanel
	if not pnl then return end
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize
	local vpX = tonumber(vp and vp.X) or 1280
	local vpY = tonumber(vp and vp.Y) or 720
	local vcbW = tonumber(VCB_W) or 220
	local vcbH = tonumber(VCB_H) or 90

	local topInset = 36
	pcall(function()
		local tl = game:GetService("GuiService"):GetGuiInset()
		if typeof(tl) == "Vector2" then
			topInset = math.max(tonumber(tl.Y) or 36, 36)
		end
	end)
	topInset = tonumber(topInset) or 36

	local sideMargin = _isMobile and 12 or 16
	local topGap = _isMobile and 8 or 10
	local maxW = math.max(180, vpX - sideMargin * 2)
	local fitW = math.clamp(vcbW, 180, math.min(300, maxW))
	if vpX < 420 then
		fitW = math.clamp(vpX - sideMargin * 2, 180, 280)
	end
	fitW = tonumber(fitW) or vcbW
	pnl.Size = UDim2.new(0, fitW, 0, vcbH)

	local sc = 1
	local us = pnl:FindFirstChildOfClass("UIScale")
	if us then
		local globalSc = tonumber(_G._getScale and _G._getScale()) or 1
		if globalSc <= 0 then globalSc = 1 end
		local maxFit = math.min((vpX - sideMargin * 2) / fitW, (vpY - topInset - topGap - 16) / vcbH)
		sc = math.clamp(math.min(globalSc, tonumber(maxFit) or 1), 0.45, 1.15)
		us.Scale = sc
	end

	local scaledW, scaledH = fitW * sc, vcbH * sc
	pnl.AnchorPoint = Vector2.new(0.5, 0)
	local px = vpX * 0.5
	local py = topInset + topGap
	px = math.clamp(px, scaledW * 0.5 + sideMargin, math.max(scaledW * 0.5 + sideMargin, vpX - scaledW * 0.5 - sideMargin))
	py = math.clamp(py, topGap, math.max(topGap, vpY - scaledH - sideMargin))
	pnl.Position = UDim2.new(0, px, 0, py)
	pcall(function()
		if _nvFloatCloseRest then _nvFloatCloseRest[pnl] = nil end
	end)
end

_G._nvPlaceVcbTop = placeVcbTop
_G._nvToggleVcbPanel = function(forceOpen)
	local pnl = _G._vcbPanel or _cs.vcbPanel
	if not pnl then return end
	if forceOpen == true then
		pnl.Visible = true
	elseif forceOpen == false then
		pnl.Visible = false
		return
	else
		pnl.Visible = not pnl.Visible
	end
	if pnl.Visible then
		task.defer(placeVcbTop)
		if _nvL.xnotify then
			_nvL.xnotify("VC Bypasser", "Panel UI opened. Execute and mic controls are visual-only.")
		end
	end
end

placeVcbTop()
pcall(function()
	local cam = workspace.CurrentCamera
	if cam then
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if _cs.vcbPanel and _cs.vcbPanel.Visible then
				placeVcbTop()
			end
		end)
	end
end)

local vcbExecuted = false
local vcbMuted = false

local function vcbSelect(i)
    vcbVersion = i
    tween(vcbSegThumb, _cs.nvPop.QUICK, {
        Position = i == 1 and UDim2.new(0, 3, 0, 3) or UDim2.new(0.5, 1, 0, 3)
    })
    for k, b in vcbSegBtns do
        tween(b, _cs.nvPop.QUICK, {TextColor3 = k == i and _cs.nvPop.INK or C.TEXT})
    end
    vcbNote.Text = i == 1 and "V1 selected — UI preview only" or "V2 selected — UI preview only"
end

for i, b in vcbSegBtns do
    b.Activated:Connect(function()
        vcbSelect(i)
    end)
end

local function vcbNotify(message)
    if _nvL and type(_nvL.notify) == "function" then
        pcall(_nvL.notify, "VC Bypasser", message, 3)
    elseif _nvL and type(_nvL.xnotify) == "function" then
        pcall(_nvL.xnotify, "VC Bypasser", message)
    end
end

vcbExecBtn.Text = "Preview UI"
vcbNote.Text = "UI preview only — no voice-chat changes"
vcbExecBtn.Activated:Connect(function()
    vcbExecuted = not vcbExecuted
    vcbExecBtn.Text = vcbExecuted and "PREVIEW ACTIVE" or "Preview UI"
    vcbNote.Text = vcbExecuted
        and ("V" .. tostring(vcbVersion) .. " preview active — UI only")
        or "UI preview only — no voice-chat changes"
    vcbNotify(vcbExecuted and "UI preview activated; voice chat was not modified."
        or "UI preview reset; voice chat was not modified.")
end)

vcbMicBtn.Activated:Connect(function()
    vcbMuted = not vcbMuted
    local tint = vcbMuted and _cs.nvPop.TINT.red or _cs.nvPop.TINT.gray
    tween(vcbMicFace, _cs.nvPop.QUICK, {BackgroundColor3 = tint[1]})
    vcbMicIcon:SetAttribute("NvIcon", vcbMuted and "micoff" or "mic")
    if type(_G._nv_setIcon) == "function" then
        pcall(_G._nv_setIcon, vcbMicIcon, vcbMuted and "micoff" or "mic")
    end
    vcbNotify(vcbMuted and "Visual mic state: muted; voice chat was not changed."
        or "Visual mic state: unmuted; voice chat was not changed.")
end)

return _cs.vcbPanel
end
