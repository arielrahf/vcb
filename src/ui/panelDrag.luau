return function(env, pnl, bar, onMove, onDragStart, onDragEnd)
local _cs = env._cs
local runService = env.runService
local userInputService = env.userInputService
	if not pnl or not bar then return end
	local dragging = false
	local touchInput = nil
	local dragStartM = Vector2.zero
	local dragStartPos = UDim2.new()
	local dragSize = Vector2.zero
	local dragPadBottom = 0
	local dragVp = Vector2.new(1280, 720)
	local dragAnchor = Vector2.zero
	local dragConn, endConn, focusConn, glideConn
	local goalPos
	local dragTop = 8

	local function pointerPos()
		if touchInput then
			return Vector2.new(touchInput.Position.X, touchInput.Position.Y)
		end
		return userInputService:GetMouseLocation()
	end
	local function stopDrag()
		if not dragging then return end
		dragging = false
		touchInput = nil
		if dragConn then dragConn:Disconnect()  dragConn = nil end
		if endConn then endConn:Disconnect()  endConn = nil end
		if focusConn then focusConn:Disconnect()  focusConn = nil end
		if _cs._nvDragOwner == pnl then _cs._nvDragOwner = nil end
		if onDragEnd then pcall(onDragEnd) end
	end
	local function onChrome(pos)
		local m = pos or userInputService:GetMouseLocation()
		local inset = game:GetService("GuiService"):GetGuiInset()
		local function covers(gui, x, y)
			if not (gui and gui.Visible) then return false end
			local p, s = gui.AbsolutePosition, gui.AbsoluteSize
			return x >= p.X and y >= p.Y and x <= p.X + s.X and y <= p.Y + s.Y
		end
		local closeBtn = bar:FindFirstChild("CloseBtn")
		local minBtn = bar:FindFirstChild("MinimizeBtn")
		return covers(closeBtn, m.X, m.Y) or covers(closeBtn, m.X - inset.X, m.Y - inset.Y) or covers(closeBtn, m.X + inset.X, m.Y + inset.Y)
			or covers(minBtn, m.X, m.Y) or covers(minBtn, m.X - inset.X, m.Y - inset.Y) or covers(minBtn, m.X + inset.X, m.Y + inset.Y)
	end
	local function updateDrag()
		if pnl:GetAttribute("_nvClosing") or pnl:GetAttribute("_nvMinAnim") then stopDrag() return end
		if not dragging or not pnl.Parent then return end
		local d = pointerPos() - dragStartM
		local vp, ps = dragVp, dragSize
		local curPxX = dragStartPos.X.Offset + dragStartPos.X.Scale * vp.X
		local curPxY = dragStartPos.Y.Offset + dragStartPos.Y.Scale * vp.Y
		local anchorOffX = dragAnchor.X * ps.X
		local anchorOffY = dragAnchor.Y * ps.Y
		local minX, maxX = 8 + anchorOffX, vp.X - 8 - ps.X + anchorOffX
		local minY, maxY = dragTop + anchorOffY, vp.Y - 8 - ps.Y - dragPadBottom + anchorOffY
		local newX = minX > maxX and minX or math.clamp(curPxX + d.X, minX, maxX)
		local newY = minY > maxY and minY or math.clamp(curPxY + d.Y, minY, maxY)
		goalPos = Vector2.new(newX, newY)
		if glideConn then return end
		glideConn = runService.RenderStepped:Connect(function(dt)
			if pnl:GetAttribute("_nvClosing") or pnl:GetAttribute("_nvMinAnim") then
				glideConn:Disconnect()
				glideConn = nil
				stopDrag()
				return
			end
			if not pnl.Parent or not goalPos then
				glideConn:Disconnect()
				glideConn = nil
				return
			end
			local p, vp = pnl.Position, dragVp
			local x = p.X.Offset + p.X.Scale * vp.X
			local y = p.Y.Offset + p.Y.Scale * vp.Y
			local a = 1 - math.exp(-dt * 22)
			x, y = x + (goalPos.X - x) * a, y + (goalPos.Y - y) * a
			if not dragging and math.abs(goalPos.X - x) < 0.5 and math.abs(goalPos.Y - y) < 0.5 then
				x, y = goalPos.X, goalPos.Y
				glideConn:Disconnect()
				glideConn = nil
			end
			local newPos = UDim2.new(0, x, 0, y)
			pnl.Position = newPos
			if onMove then onMove(newPos) end
		end)
	end
	local function beginDrag(startM, startPos)

		local cam = workspace.CurrentCamera
		dragVp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		dragStartM = startM
		dragStartPos = startPos
		dragSize = pnl.AbsoluteSize
		dragAnchor = pnl.AnchorPoint
		local pad = tonumber(pnl:GetAttribute("_nvDragPadBottom")) or 0
		local us = pnl:FindFirstChildOfClass("UIScale")
		dragPadBottom = pad * ((us and us.Scale) or 1)
		dragTop = 8
		local host = pnl.Parent
		if host and host:IsA("ScreenGui") and host.IgnoreGuiInset then
			local ok, inset = pcall(function() return game:GetService("GuiService"):GetGuiInset() end)
			if ok and typeof(inset) == "Vector2" then dragTop = math.max(8, inset.Y) end
		end
		dragging = true
		_cs._nvDragOwner = pnl
		if onDragStart then pcall(onDragStart) end

		dragConn = userInputService.InputChanged:Connect(function(changed)
			if not dragging then return end
			if changed.UserInputType == Enum.UserInputType.MouseMovement
				or changed.UserInputType == Enum.UserInputType.Touch
				or changed == touchInput then
				updateDrag()
			end
		end)
		endConn = userInputService.InputEnded:Connect(function(ended)
			if ended == touchInput or ended.UserInputType == Enum.UserInputType.MouseButton1 then stopDrag() end
		end)
		focusConn = userInputService.WindowFocusReleased:Connect(stopDrag)
	end

	bar.InputBegan:Connect(function(i)
		if pnl:GetAttribute("_nvClosing") or pnl:GetAttribute("_nvMinAnim") or onChrome(i.UserInputType == Enum.UserInputType.Touch and Vector2.new(i.Position.X, i.Position.Y) or nil) then return end
		if dragging or (_cs._nvDragOwner ~= nil and _cs._nvDragOwner ~= pnl) then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			touchInput = nil
			beginDrag(userInputService:GetMouseLocation(), pnl.Position)
		elseif i.UserInputType == Enum.UserInputType.Touch then
			touchInput = i
			beginDrag(Vector2.new(i.Position.X, i.Position.Y), pnl.Position)
		end
	end)
	pnl.AncestryChanged:Connect(function(_, parent)
		if not parent then stopDrag() end
	end)
end
