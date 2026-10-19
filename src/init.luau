_cs.vcbPanel = nil

;(function()
return require("./panels/vcBypass")({
	C = C,
	_cs = _cs,
	_isMobile = _isMobile,
	_nvFloatCloseRest = _nvFloatCloseRest,
	_nvL = _nvL,
	createInstance = createInstance,
	makeFloatingPanel = makeFloatingPanel,
	makePanelTitleBar = makePanelTitleBar,
	tween = tween,
})
end)()

_G._nvInlineToggleDeny = {
	vcbypasser = true,
}