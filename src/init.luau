-- Inisialisasi helper UI NovoLine
_cs.nvPop = _cs.nvPop or require("./ui/nvPop")({
    C = C,
    createInstance = createInstance,
    tween = tween,
})

-- VCB panel integration
_cs.vcbPanel = _cs.vcbPanel or nil

-- Adapter untuk panelDrag.luau
_cs._nvDragOwner = _cs._nvDragOwner or nil

_G._nv_csRef = _cs

_cs.makePanelDraggable = function(
    pnl,
    bar,
    onMove,
    onDragStart,
    onDragEnd
)
    assert(pnl, "makePanelDraggable: pnl is required")
    assert(bar, "makePanelDraggable: bar is required")

    return require("./ui/panelDrag")({
        _cs = _cs,
        runService = runService,
        userInputService = userInputService,
    }, pnl, bar, onMove, onDragStart, onDragEnd)
end

-- Pertahankan tabel global yang sudah ada
_G._nvInlineToggleDeny =
    _G._nvInlineToggleDeny or {}

_G._nvInlineToggleDeny.vcbypasser = true

-- Inisialisasi panel
-- Modul panel harus menggunakan callback UI yang aman.
do
    local ok, result = pcall(function()
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
    end)

    if not ok then
        warn("[VCB] Panel initialization failed: " .. tostring(result))
    end
end
