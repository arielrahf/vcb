return function(env)
local C = env.C
local _genv = env._genv
local _nvL = env._nvL
local createInstance = env.createInstance
local tween = env.tween
 local kit = _G._nv_kit
 if not kit or not _G._nv_decks then return end
 local function build()
 local hs = game:GetService("HttpService")
 local textService = game:GetService("TextService")
 local tweenService = game:GetService("TweenService")
 local Cx = type(C) == "table" and C or {TEXT = Color3.fromRGB(244, 244, 244), SUB = Color3.fromRGB(205, 205, 205)}
 local tw = type(tween) == "function" and tween or function(o, i, g) local t = tweenService:Create(o, i, g); t:Play(); return t end
 local function toast(title, text, d) if type(_nvL.notify) == "function" then pcall(_nvL.notify, title, text, d) end end
 local SUBTLE, TEXT, SUB = kit.SUBTLE, Cx.TEXT, Cx.SUB
 local K = {
  PILL = Color3.fromRGB(242, 242, 244), INK = Color3.fromRGB(18, 18, 20),
  RED = Color3.fromRGB(255, 96, 96), RED_BG = Color3.fromRGB(62, 20, 24),
  BLUE = Color3.fromRGB(64, 186, 255),
  YELLOW = Color3.fromRGB(245, 197, 66), YELLOW_BG = Color3.fromRGB(56, 46, 12),
  PURPLE = Color3.fromRGB(168, 120, 255), PURPLE_BG = Color3.fromRGB(38, 28, 62),
  TRACK = Color3.fromRGB(58, 58, 62),
  ROW_H = 60, ROW_RIGHT = 116, LIST_Y = 88,
  SHELF_W = 520, SHELF_H = 360, DETAIL_W = 330, DETAIL_H = 360,
  quick = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
 }
 local S = {
  provider = "scriptblox", scope = "universal", keyless = false,
  committed = nil, serial = 0, typing = 0, detailSerial = 0, hoverSerial = 0,
  selected = nil, shownKey = nil, shownRich = false, started = false, alive = true,
  hearts = {}, favs = {}, favList = {}, gameName = nil, count = 0,
  shelfW = 520, listW = 500,
 }
 local deck = {}
 _G._nv_decks[5] = deck

 local U = {}
 function U.trim(s) return (s or ""):match("^%s*(.-)%s*$") end
 function U.width(text, size, font) return textService:GetTextSize(text, size, font, Vector2.new(1000, 40)).X end
 function U.short(n)
  n = tonumber(n)
  if not n then return nil end
  if n >= 1e6 then return (string.format("%.1f", n / 1e6):gsub("%.0$", "")) .. "M" end
  if n >= 1e3 then return (string.format("%.1f", n / 1e3):gsub("%.0$", "")) .. "K" end
  return tostring(math.floor(n))
 end
 function U.ago(iso)
  if type(iso) ~= "string" then return nil end
  local ok, dt = pcall(DateTime.fromIsoDate, iso)
  if not ok or not dt then return nil end
  local s = math.max(0, os.time() - dt.UnixTimestamp)
  if s < 3600 then return math.max(1, math.floor(s / 60)) .. "m ago" end
  if s < 86400 then return math.floor(s / 3600) .. "h ago" end
  if s < 604800 then return math.floor(s / 86400) .. "d ago" end
  if s < 2592000 then return math.floor(s / 604800) .. "w ago" end
  if s < 31536000 then return math.floor(s / 2592000) .. "mo ago" end
  return math.floor(s / 31536000) .. "y ago"
 end
 function U.text(parent, value, font, size, color, x, y, w, h, align)
  local l = kit.text(parent, value, font, size, color, x, y, w, h, align)
  l.ZIndex = 22
  return l
 end
 function U.icon(parent, name, size, x, y, color)
  local i = kit.icon(parent, name, size, x, y, color)
  i.ZIndex = 23
  return i
 end
 function U.centerIcon(parent, name, size, color, cy)
  local i = U.icon(parent, name, size, 0, 0, color)
  i.AnchorPoint = Vector2.new(0.5, 0.5); i.Position = UDim2.fromScale(0.5, cy or 0.5)
  return i
 end
 function U.restSize(c)
  return c:GetAttribute("RestW") or c.Size.X.Offset, c:GetAttribute("RestH") or c.Size.Y.Offset
 end
 function U.round(o, r) local c = o:FindFirstChildOfClass("UICorner") or createInstance("UICorner", { Parent = o }); c.CornerRadius = r and UDim.new(0, r) or UDim.new(1, 0) end
 function U.fade(keys)
  local seq = {}
  for _, k in keys do seq[#seq + 1] = NumberSequenceKeypoint.new(k[1], k[2]) end
  return NumberSequence.new(seq)
 end
 function U.paintChip(button, label, on, iconImg)
  button.BackgroundColor3 = on and K.PILL or Color3.new(1, 1, 1)
  local g = button:FindFirstChildOfClass("UIGradient"); if g then g.Enabled = not on end
  if label then label.TextColor3 = on and K.INK or TEXT end
  if iconImg then iconImg.ImageColor3 = on and K.INK or TEXT end
 end
 function U.chip(parent, text, iconName, x, y, h, onClick, tint)
  local tw0 = U.width(text, 12, Enum.Font.GothamBold)
  local w = tw0 + 24 + (iconName and 20 or 0)
  local b = kit.softButton(parent, x, y, w, h, onClick, tint, math.floor(h / 2))
  local ink = tint and K.INK or TEXT
  local img
  if iconName then img = U.icon(b, iconName, 14, 12, math.floor((h - 14) / 2), ink) end
  local l = U.text(b, text, Enum.Font.GothamBold, 12, ink, iconName and 32 or 12, 0, tw0 + 2, h)
  return b, l, img, w
 end
 function U.confirm(img, name)
  if not img then return end
  _G._nv_setIcon(img, "check")
  task.delay(1.4, function() if img.Parent then _G._nv_setIcon(img, name) end end)
 end
 function U.thumb(parent, x, y, w, h, url, fallback, radius, iconSize)
  local tile = createInstance("Frame", {
    Parent = parent,
    Name = "Thumb",
    Position = UDim2.fromOffset(x, y),
    Size = UDim2.fromOffset(w, h),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 22,
  })
  U.round(tile, radius)
  local g = createInstance("UIGradient", {
    Parent = tile,
    Rotation = 90,
    Color = ColorSequence.new(Color3.fromRGB(46, 46, 49), Color3.fromRGB(32, 32, 35)),
  })
  local mark = U.centerIcon(tile, "code", iconSize, SUBTLE)
  local img = createInstance("ImageLabel", {
    Parent = tile,
    Name = "Picture",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    ScaleType = Enum.ScaleType.Crop,
    Image = "",
    ZIndex = 24,
  })
  U.round(img, radius)
  img:GetPropertyChangedSignal("Image"):Connect(function() mark.Visible = img.Image == "" end)
  return tile, img
 end

 local D = {}
 D.httpReq = (function()
  local g = type(_genv) == "table" and _genv or {}
  for _, k in {"request", "http_request", "Request"} do
   if type(g[k]) == "function" then return g[k] end
  end
  if type(request) == "function" then return request end
  if type(http_request) == "function" then return http_request end
  if type(syn) == "table" and type(syn.request) == "function" then return syn.request end
 return end)()
 D.clipboard = type(setclipboard) == "function" and setclipboard or (type(toclipboard) == "function" and toclipboard) or nil
 function D.absolute(url, base)
  if type(url) ~= "string" or url == "" then return nil end
  if url:sub(1, 1) == "/" then return base .. url end
  return url
 end
 function D.normalize(e, provider)
  local ro = provider == "roscripts"
  local base = ro and "https://roscripts.io" or "https://scriptblox.com"
  local g = type(e.game) == "table" and e.game or nil
  local o = type(e.owner) == "table" and e.owner or {}
  local code
  if ro then
   code = type(e.loadstring) == "string" and e.loadstring ~= "" and ('loadstring(game:HttpGet("' .. e.loadstring .. '"))()') or nil
  else
   code = type(e.script) == "string" and e.script ~= "" and e.script or nil
  end
  local about = e.body or e.features or e.description
  local universal = e.universal == true or e.isUniversal == true or g == nil
  local gid = g and tonumber(g.gameId or g.placeId) or tonumber(e.placeId)
  return {
   provider = provider, id = e.id or e._id, slug = e.slug,
   title = type(e.title) == "string" and e.title or "Untitled",
   about = type(about) == "string" and U.trim(about:gsub("\r", "")) or "",
   author = type(o.username) == "string" and o.username or nil,
   authorVerified = o.verified == true,
   avatar = D.absolute(o.avatar or o.profilePicture, base),
   game = (not universal and g and type(g.name) == "string") and g.name or "Universal",
   updated = e.updatedAt or e.lastBump or e.createdAt,
   views = ro and (e.viewsTotal or e.views) or e.views,
   executions = e.executes, likes = e.likeCount, saves = e.saveCount,
   tags = type(e.tags) == "table" and e.tags or {},
   ui = type(e.ui) == "string" and e.ui or nil,
   key = e.key == true, keyLink = type(e.keyLink) == "string" and e.keyLink or nil,
   patched = e.patched == true or e.isPatched == true,
   verified = e.verified == true,
   universal = universal,
   code = code,
   discord = type(e.discordUrl) == "string" and e.discordUrl or nil,
   url = (ro and "https://roscripts.io/s/" or "https://scriptblox.com/script/") .. (e.slug or ""),
   image = D.absolute(e.image or e.thumbnail or (g and (g.imageUrl or g.image)), base),
   fallback = gid and gid > 0 and ("rbxthumb://type=GameIcon&id=" .. gid .. "&w=150&h=150") or nil,
  }
 end
 function D.getJson(url)
  if not D.httpReq then return nil end
  local ok, data = pcall(function()
   local r = D.httpReq({Url = url, Method = "GET"})
   if type(r) ~= "table" or type(r.Body) ~= "string" then error("empty response") end
   return hs:JSONDecode(r.Body)
  end)
  return ok and type(data) == "table" and data or nil
 end
 function D.fetch(provider, query, scope, keyless)
  local q = {}
  local url
  if provider == "roscripts" then
   url = query == "" and "https://api.roscripts.io/v1/scripts?sort=updatedAt&" or ("https://api.roscripts.io/v1/scripts/search?q=" .. hs:UrlEncode(query) .. "&")
   q[#q + 1] = "max=" .. ((query == "" and scope ~= "all") and 40 or 20)
   if scope == "universal" then q[#q + 1] = "universal=true" elseif scope == "game" then q[#q + 1] = "placeId=" .. game.PlaceId end
   if keyless then q[#q + 1] = "key=false" end
  else
   url = query == "" and "https://scriptblox.com/api/script/fetch?" or ("https://scriptblox.com/api/script/search?q=" .. hs:UrlEncode(query) .. "&mode=free&page=1&")
   q[#q + 1] = "max=20"
   if scope == "universal" then q[#q + 1] = "universal=1" elseif scope == "game" then q[#q + 1] = "placeId=" .. game.PlaceId end
   if keyless then q[#q + 1] = "key=0" end
   if query == "" and scope ~= "all" then q[#q + 1] = "sortBy=views&order=desc" end
  end
  local data = D.getJson(url .. table.concat(q, "&"))
  if not data or type(data.result) ~= "table" or type(data.result.scripts) ~= "table" then return nil end
  local out = {}
  for _, e in data.result.scripts do
   if type(e) == "table" then out[#out + 1] = D.normalize(e, provider) end
  end
  if query == "" and scope ~= "all" then
   table.sort(out, function(a, b) return (tonumber(a.views) or 0) > (tonumber(b.views) or 0) end)
   for i = #out, 21, -1 do out[i] = nil end
  end
  return out
 end
 function D.detail(info)
  if info.provider == "roscripts" then
   local data = D.getJson("https://api.roscripts.io/v1/scripts/" .. hs:UrlEncode(info.id or info.slug or ""))
   local r = data and data.result
   if type(r) ~= "table" or type(r.script) ~= "table" then return nil end
   return D.normalize(r.script, "roscripts")
  end
  local data = D.getJson("https://scriptblox.com/api/script/" .. hs:UrlEncode(info.slug or ""))
  if not data or type(data.script) ~= "table" then return nil end
  return D.normalize(data.script, "scriptblox")
 end
 D.detailCache = {}
 D.imageCache, D.imagePending = {}, {}
 function D.loadImage(img, url, fallback)
  if url and D.imageCache[url] then img.Image = D.imageCache[url]; return end
  if not (url and D.httpReq and writefile and getcustomasset) then
   if fallback then img.Image = fallback end
   return
  end
  if D.imagePending[url] then table.insert(D.imagePending[url], {img, fallback}); return end
  D.imagePending[url] = {{img, fallback}}
  task.spawn(function()
   local asset
   pcall(function()
    if isfolder and not isfolder("Novoline") then makefolder("Novoline") end
    if isfolder and not isfolder("Novoline/Thumbs") then makefolder("Novoline/Thumbs") end
    local ext = url:lower():match("%.(%a+)$") or url:lower():match("%.(%a+)%?")
    ext = (ext == "jpg" or ext == "jpeg" or ext == "png" or ext == "webp") and ext or "png"
    local file = "Novoline/Thumbs/" .. url:gsub("[^%w]", ""):sub(-60) .. "." .. ext
    if not (isfile and isfile(file)) then
     local r = D.httpReq({Url = url, Method = "GET"})
     if type(r) ~= "table" or type(r.Body) ~= "string" or #r.Body < 64 then return end
     writefile(file, r.Body)
    end
    asset = getcustomasset(file)
   end)
   local ok = type(asset) == "string" and asset ~= ""
   if ok then D.imageCache[url] = asset end
   for _, waiting in D.imagePending[url] do
    local target, fb = waiting[1], waiting[2]
    if target.Parent then
     if ok then target.Image = asset elseif fb then target.Image = fb end
    end
   end
   D.imagePending[url] = nil
  end)
 end

 local A = {}
 function A.copy(text, what)
  if not D.clipboard or not text then toast("Scripts", "Your executor can't copy to the clipboard.", 3); return false end
  pcall(D.clipboard, text)
  toast("Scripts", what .. " copied", 2)
  return true
 end
 function A.run(info)
  if not info.code then toast("Scripts", "This script has no source to run.", 3); return end
  toast("Scripts", "Running " .. info.title, 3)
  task.spawn(function()
   local fn, err = loadstring(info.code)
   if not fn then toast("Scripts", "Couldn't load " .. info.title .. ": " .. tostring(err), 5); return end
   local ok, runErr = pcall(fn)
   if not ok then toast("Scripts", info.title .. " errored: " .. tostring(runErr), 5) end
  end)
 end
 function A.save(info)
  if not info.code or type(writefile) ~= "function" then toast("Scripts", "Saving isn't available here.", 3); return false end
  local name = U.trim(info.title:gsub("[^%w%s%-_]", ""):gsub("%s+", " ")):sub(1, 40)
  if name == "" then name = "Script" end
  local ok = pcall(function()
   if isfolder and not isfolder("Novoline") then makefolder("Novoline") end
   if isfolder and not isfolder("Novoline/Scripts") then makefolder("Novoline/Scripts") end
   writefile("Novoline/Scripts/" .. name .. ".lua", info.code)
  end)
  toast("Scripts", ok and ("Saved to Novoline/Scripts/" .. name .. ".lua") or "Couldn't save this script.", 3)
  return ok
 end

 local F = {file = "Novoline/script_favorites.json"}
 function F.key(info) return tostring(info.provider) .. ":" .. tostring(info.id or info.slug or info.title) end
 function F.load()
  pcall(function()
   if not (isfile and readfile and isfile(F.file)) then return end
   local list = hs:JSONDecode(readfile(F.file))
   if type(list) ~= "table" then return end
   for _, info in list do
    if type(info) == "table" and info.title then
     info.tags = type(info.tags) == "table" and info.tags or {}
     info.about = type(info.about) == "string" and info.about or ""
     S.favList[#S.favList + 1] = info
     S.favs[F.key(info)] = true
    end
   end
  end)
 end
 function F.save()
  if type(writefile) ~= "function" then return end
  pcall(function()
   if isfolder and not isfolder("Novoline") then makefolder("Novoline") end
   writefile(F.file, hs:JSONEncode(S.favList))
  end)
 end
 F.onPaint = nil
 function F.paint()
  local live = {}
  for _, h in S.hearts do
   if h.icon.Parent then
    tw(h.icon, K.quick, {ImageColor3 = S.favs[h.key] and K.RED or SUBTLE})
    live[#live + 1] = h
   end
  end
  S.hearts = live
  if F.onPaint then F.onPaint() end
 end
 function F.track(info, img) S.hearts[#S.hearts + 1] = {key = F.key(info), icon = img}; img.ImageColor3 = S.favs[F.key(info)] and K.RED or SUBTLE end
 F.load()

 kit.title(deck, "Scripts", "Discover something for your game")
 local H = {}
 local R = {parts = setmetatable({}, {__mode = "k"})}
 local M = {}
 local Dt = {}
 local doSearch

 local searchCard = kit.card(deck, "ScriptSearch", "tr", 170 + 10, 0, 300, 44)
 local searchIcon = U.icon(searchCard, "search", 18, 16, 13, SUBTLE)
 local box = createInstance("TextBox", {
   Parent = searchCard,
   BackgroundTransparency = 1,
   BorderSizePixel = 0,
   Font = Enum.Font.GothamMedium,
   TextSize = 14,
   TextColor3 = TEXT,
   PlaceholderColor3 = Color3.fromRGB(118, 118, 124),
   PlaceholderText = "Search scripts or games",
   Text = "",
   ClearTextOnFocus = false,
   TextXAlignment = Enum.TextXAlignment.Left,
   TextTruncate = Enum.TextTruncate.AtEnd,
   Position = UDim2.fromOffset(44, 0),
   Size = UDim2.fromOffset(300 - 44 - 44, 44),
   ZIndex = 20,
 })
 local clearBtn = kit.softButton(searchCard, 300 - 8 - 28, 8, 28, 28, nil, nil, 14)
 U.centerIcon(clearBtn, "clear", 12, TEXT)
 clearBtn.Visible = false
 for _, o in {searchIcon, box, clearBtn} do o:SetAttribute("NoFlex", true) end
 if kit.onResize then
  kit.onResize(searchCard, function(w, h)
   searchIcon.Position = UDim2.fromOffset(16, math.floor((h - 18) / 2))
   box.Size = UDim2.fromOffset(math.max(w - 88, 40), h)
   clearBtn.Position = UDim2.fromOffset(w - 36, math.floor((h - 28) / 2))
  end)
 end

 local sourceCard = kit.card(deck, "ScriptSource", "tr", 0, 0, 170, 44)
 local sourceButtons = {}
 for n, src in {{"roscripts", "RoScripts"}, {"scriptblox", "ScriptBlox"}} do
  local b = kit.softButton(sourceCard, 6 + (n - 1) * 81, 6, 77, 32, nil, nil, 16)
  b:SetAttribute("NoFlex", true)
  local l = U.text(b, src[2], Enum.Font.GothamBold, 12, TEXT, 0, 0, 77, 32, Enum.TextXAlignment.Center)
  l.Size = UDim2.fromScale(1, 1)
  sourceButtons[src[1]] = {button = b, label = l, n = n}
 end
 if kit.onResize then
  kit.onResize(sourceCard, function(w, h)
   local bw = math.floor((w - 16) / 2)
   for _, s in sourceButtons do
    s.button.Position = UDim2.fromOffset(6 + (s.n - 1) * (bw + 4), 6)
    s.button.Size = UDim2.fromOffset(bw, math.max(h - 12, 20))
   end
  end)
 end
 local function paintSources()
  for key, s in sourceButtons do U.paintChip(s.button, s.label, key == S.provider) end
 end
 paintSources()

 local shelf = kit.card(deck, "ScriptShelf", "bl", 0, 0, K.SHELF_W, K.SHELF_H)
 H.title = U.text(shelf, "Trending", Enum.Font.GothamBold, 14, TEXT, 18, 16, 300, 18)
 H.title.TextTruncate = Enum.TextTruncate.AtEnd
 H.count = U.text(shelf, "", Enum.Font.GothamMedium, 12, SUBTLE, 0, 16, 120, 18)
 H.title:SetAttribute("NoFlex", true); H.count:SetAttribute("NoFlex", true)
 do
  local lw = math.ceil(U.width("Keyless", 12, Enum.Font.GothamMedium)) + 2
  local w = lw + 8 + 52
  local sw = createInstance("TextButton", {
    Parent = shelf,
    Name = "Keyless",
    Text = "",
    AutoButtonColor = false,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(K.SHELF_W - 18 - w, 13),
    Size = UDim2.fromOffset(w, 24),
    ZIndex = 20,
  })
  sw:SetAttribute("NoFlex", true)
  U.text(sw, "Keyless", Enum.Font.GothamMedium, 12, SUB, 0, 0, lw, 24)
  local set = _G._nv_switch(sw, S.keyless, {anchor = Vector2.new(1, 0.5), position = UDim2.new(1, 0, 0.5, 0), z = 21})
  H.keyless = {set = set, row = sw, w = w}
  sw.Activated:Connect(function()
   S.keyless = not S.keyless
   H.paintFilters()
   doSearch(box.Text, true)
  end)
 end
 H.seg = {items = {}, w = 0}
 do
  local track = createInstance("Frame", {
    Parent = shelf,
    Name = "Scope",
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    ZIndex = 20,
    Position = UDim2.fromOffset(18, 46),
    Size = UDim2.fromOffset(K.SHELF_W - 36, 32),
  })
  track:SetAttribute("NoFlex", true)
  U.round(track)
  local cap = createInstance("Frame", {
    Parent = track,
    Name = "Capsule",
    BackgroundColor3 = K.PILL,
    BorderSizePixel = 0,
    ZIndex = 21,
    Position = UDim2.fromOffset(3, 3),
    Size = UDim2.fromOffset(100, 26),
  })
  U.round(cap)
  H.seg.track, H.seg.cap = track, cap
  for n, sc in {{"all", "All"}, {"universal", "Universal"}, {"game", "This game"}, {"favorites", "Favorites"}} do
   local b = createInstance("TextButton", {
     Parent = track,
     Name = sc[2],
     Text = "",
     AutoButtonColor = false,
     BackgroundTransparency = 1,
     BorderSizePixel = 0,
     ZIndex = 22,
   })
   local l = U.text(b, sc[2], Enum.Font.GothamBold, 12, SUB, 0, 0, 10, 26, Enum.TextXAlignment.Center)
   l.Size = UDim2.fromScale(1, 1)
   H.seg.items[sc[1]] = {button = b, label = l, n = n}
   b.Activated:Connect(function()
    if S.scope == sc[1] then return end
    S.scope = sc[1]
    H.paintFilters()
    doSearch(box.Text, true)
   end)
  end
 end
 function H.placeSegments(w, animate)
  local inner = w - 36 - 6
  local sw = inner / 4
  H.seg.w = sw
  H.seg.track.Size = UDim2.fromOffset(w - 36, 32)
  for _, s in H.seg.items do
   s.button.Position = UDim2.fromOffset(math.floor(3 + (s.n - 1) * sw), 3)
   s.button.Size = UDim2.fromOffset(math.floor(sw), 26)
  end
  local cur = H.seg.items[S.scope]
  local goal = {Position = UDim2.fromOffset(math.floor(3 + (cur.n - 1) * sw), 3), Size = UDim2.fromOffset(math.floor(sw), 26)}
  if animate then
   tw(H.seg.cap, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goal)
  else
   H.seg.cap.Position, H.seg.cap.Size = goal.Position, goal.Size
  end
 end
 function H.paintFilters(instant)
  for key, s in H.seg.items do
   tw(s.label, K.quick, {TextColor3 = key == S.scope and K.INK or SUB})
  end
  H.placeSegments(S.shelfW, not instant)
  local on = S.keyless
  H.keyless.set(on, not instant)
 end
 H.paintFilters(true)

 function H.layout()
  local cw = H.count.Text == "" and 0 or math.ceil(U.width(H.count.Text, 12, Enum.Font.GothamMedium)) + 2
  local room = S.shelfW - 36 - H.keyless.w - 16 - (cw > 0 and cw + 8 or 0)
  local lw = math.max(math.min(math.ceil(U.width(H.title.Text, 14, Enum.Font.GothamBold)) + 2, room), 40)
  H.title.Size = UDim2.fromOffset(lw, 18)
  H.count.Position = UDim2.fromOffset(18 + lw + 8, 16); H.count.Size = UDim2.fromOffset(cw, 18)
 end
 H.suggest = createInstance("Frame", {
   Parent = shelf,
   BackgroundTransparency = 1,
   BorderSizePixel = 0,
   ClipsDescendants = true,
   ZIndex = 21,
   Position = UDim2.fromOffset(18, 12),
   Size = UDim2.fromOffset(300, 26),
 })
 H.suggest:SetAttribute("NoFlex", true)
 H.suggestChips = {}

 local row = createInstance("ScrollingFrame", {
   Parent = shelf,
   Name = "ScriptList",
   BackgroundTransparency = 1,
   BorderSizePixel = 0,
   Position = UDim2.fromOffset(10, K.LIST_Y),
   Size = UDim2.fromOffset(K.SHELF_W - 20, K.SHELF_H - K.LIST_Y - 10),
   ScrollingDirection = Enum.ScrollingDirection.Y,
   ScrollBarThickness = 0,
   CanvasSize = UDim2.new(),
   AutomaticCanvasSize = Enum.AutomaticSize.Y,
   ZIndex = 20,
 })
 local rowList = createInstance("UIListLayout", {
   Parent = row,
   FillDirection = Enum.FillDirection.Vertical,
   Padding = UDim.new(0, 2),
   SortOrder = Enum.SortOrder.LayoutOrder,
 })
 if _G._nv_scrollFade then pcall(_G._nv_scrollFade, row) end
 H.rowBox = row.Parent ~= shelf and row.Parent or row
 H.rowBox:SetAttribute("NoFlex", true)

 M.frame = createInstance("Frame", {
   Parent = shelf,
   BackgroundTransparency = 1,
   BorderSizePixel = 0,
   Visible = false,
   ZIndex = 21,
   Position = UDim2.fromOffset(18, K.LIST_Y),
   Size = UDim2.fromOffset(K.SHELF_W - 36, K.SHELF_H - K.LIST_Y - 10),
 })
 M.frame:SetAttribute("NoFlex", true)
 do
  local mark = U.icon(M.frame, "compass", 28, 0, 0, SUBTLE)
  mark.AnchorPoint = Vector2.new(0.5, 0); mark.Position = UDim2.new(0.5, 0, 0.5, -76)
  M.title = U.text(M.frame, "", Enum.Font.GothamBold, 14, TEXT, 0, 0, 10, 20, Enum.TextXAlignment.Center)
  M.title.Position = UDim2.new(0, 0, 0.5, -38); M.title.Size = UDim2.new(1, 0, 0, 20)
  M.body = U.text(M.frame, "", Enum.Font.GothamMedium, 12, SUBTLE, 0, 0, 10, 34, Enum.TextXAlignment.Center)
  M.body.Position = UDim2.new(0, 60, 0.5, -14); M.body.Size = UDim2.new(1, -120, 0, 34)
  M.body.TextWrapped = true; M.body.TextYAlignment = Enum.TextYAlignment.Top
  local b = U.chip(M.frame, "Try again", nil, 0, 0, 30, function() doSearch(box.Text, true) end)
  b.AnchorPoint = Vector2.new(0.5, 0); b.Position = UDim2.new(0.5, 0, 0.5, 30)
  M.retry = b
 end
 function M.show(title, body, canRetry)
  M.frame.Visible = title ~= nil
  M.title.Text = title or ""; M.body.Text = body or ""
  M.retry.Visible = canRetry == true
 end

 function H.placeSuggestions()
  local x, room = 0, S.shelfW - 36 - H.keyless.w - 16
  H.suggest.Size = UDim2.fromOffset(room, 26)
  for _, c in H.suggestChips do
   local fit = math.min(c.w, room - x)
   if c.b.Parent then
    c.b.Visible = fit >= 72
    c.b.Position = UDim2.fromOffset(x, 0); c.b.Size = UDim2.fromOffset(math.max(fit, 0), 26)
    c.l.Size = UDim2.fromOffset(math.max(fit - 42, 0), 26)
   end
   x += c.w + 6
  end
 end
 function H.layoutShelf(w, h)
  w, h = math.floor(w + 0.5), math.floor(h + 0.5)
  S.shelfW, S.listW = w, w - 20
  local lh = h - K.LIST_Y - 10
  H.keyless.row.Position = UDim2.fromOffset(w - 18 - H.keyless.w, 13)
  H.placeSegments(w, false)
  H.layout()
  H.placeSuggestions()
  H.rowBox.Position = UDim2.fromOffset(10, K.LIST_Y); H.rowBox.Size = UDim2.fromOffset(S.listW, lh)
  for _, child in row:GetChildren() do
   if R.parts[child] then R.fit(child) end
  end
  M.frame.Position = UDim2.fromOffset(18, K.LIST_Y); M.frame.Size = UDim2.fromOffset(w - 36, lh)
 end
 if kit.onResize then kit.onResize(shelf, H.layoutShelf) end

 function R.meta(info)
  local parts = {info.game or "Universal", info.patched and "Patched" or (info.key and "Key" or "Keyless")}
  local v = U.short(info.views)
  if v then parts[#parts + 1] = v .. " views" end
  return table.concat(parts, ", ")
 end
 function R.clear()
  for _, child in row:GetChildren() do
   if child:IsA("GuiObject") then child:Destroy() end
  end
  S.count = 0
  row.CanvasPosition = Vector2.zero
 end
 function R.fit(item)
  local p = R.parts[item]
  local room = S.listW - 62 - K.ROW_RIGHT - (p.badge and 18 or 0)
  local tw1 = math.max(math.min(p.tw, room), 20)
  p.title.Size = UDim2.fromOffset(tw1 + 2, 18)
  if p.badge then p.badge.Position = UDim2.fromOffset(62 + tw1 + 5, 13) end
 end
 function R.tint(item, hover)
  local p = R.parts[item]
  if not p then return end
  local on = S.selected ~= nil and F.key(S.selected) == p.key
  tw(item, K.quick, {BackgroundTransparency = on and 0.93 or (hover and 0.96 or 1)})
 end
 function R.paintSel()
  for _, child in row:GetChildren() do
   if R.parts[child] then R.tint(child, false) end
  end
 end
 function R.select(info)
  Dt.show(info, true)
  R.paintSel()
 end
 function R.card(info, order)
  local item = createInstance("TextButton", {
    Parent = row,
    Name = "Script_" .. order,
    LayoutOrder = order,
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 20,
    Size = UDim2.new(1, 0, 0, K.ROW_H),
  })
  U.round(item, 14)
  local _, img = U.thumb(item, 8, 8, 44, 44, info.image, info.fallback, 12, 18)
  D.loadImage(img, info.image, info.fallback)
  local p = {key = F.key(info), tw = math.ceil(U.width(info.title, 13, Enum.Font.GothamBold))}
  p.title = U.text(item, info.title, Enum.Font.GothamBold, 13, info.patched and SUBTLE or TEXT, 62, 11, 200, 18)
  p.title.TextTruncate = Enum.TextTruncate.AtEnd
  if info.verified then p.badge = U.icon(item, "verified", 13, 62, 13, K.BLUE) end
  local meta = U.text(item, R.meta(info), Enum.Font.GothamMedium, 11, info.patched and K.RED or SUBTLE, 62, 31, 10, 16)
  meta.Size = UDim2.new(1, -(62 + K.ROW_RIGHT), 0, 16); meta.TextTruncate = Enum.TextTruncate.AtEnd
  R.parts[item] = p
  local run = kit.softButton(item, 0, 0, 62, 28, nil, K.PILL, 14)
  run.ZIndex = 22; run.AnchorPoint = Vector2.new(1, 0.5); run.Position = UDim2.new(1, -10, 0.5, 0)
  local playIcon = U.icon(run, "play", 12, 13, 8, K.INK)
  U.text(run, "Run", Enum.Font.GothamBold, 12, K.INK, 29, 0, 28, 28)
  run.Activated:Connect(function()
   A.run(info)
   if info.code then U.confirm(playIcon, "play") end
  end)
  local heart = kit.softButton(item, 0, 0, 28, 28, nil, nil, 14)
  heart.ZIndex = 22; heart.AnchorPoint = Vector2.new(1, 0.5); heart.Position = UDim2.new(1, -78, 0.5, 0)
  F.track(info, U.centerIcon(heart, "heart", 13, SUBTLE))
  heart.Activated:Connect(function() H.toggleFav(info) end)
  R.fit(item)
  item.MouseEnter:Connect(function()
   R.tint(item, true)
   S.hoverSerial += 1
   local mine = S.hoverSerial
   task.delay(0.1, function() if S.alive and mine == S.hoverSerial then Dt.show(info, false) end end)
  end)
  item.MouseLeave:Connect(function() R.tint(item, false); S.hoverSerial += 1 end)
  item.Activated:Connect(function() R.select(info) end)
  return item
 end
 function R.skeletons()
  R.clear()
  local breathe = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
  for n = 1, 6 do
   local f = createInstance("Frame", {
     Parent = row,
     Name = "Skeleton",
     LayoutOrder = n,
     Size = UDim2.new(1, 0, 0, K.ROW_H),
     BackgroundColor3 = Color3.new(1, 1, 1),
     BackgroundTransparency = 0.97,
     BorderSizePixel = 0,
     ZIndex = 20,
   })
   U.round(f, 14)
   for _, b in {{8, 8, 44, 44, 12}, {62, 15, 150, 10, 5}, {62, 35, 96, 8, 4}} do
    local bar = createInstance("Frame", {
      Parent = f,
      Position = UDim2.fromOffset(b[1], b[2]),
      Size = UDim2.fromOffset(b[3], b[4]),
      BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 0.94,
      BorderSizePixel = 0,
      ZIndex = 21,
    })
    U.round(bar, b[5])
    task.delay((n - 1) * 0.08, function() if bar.Parent then tw(bar, breathe, {BackgroundTransparency = 0.89}) end end)
   end
  end
 end
 function R.render(list, emptyTitle, emptyBody)
  R.clear()
  S.hearts = {}
  for n, info in list do
   local item = R.card(info, n)
   S.count = n
   if _G._nv_reveal then _G._nv_reveal(item, math.min((n - 1) * 0.03, 0.3), 0) end
  end
  H.count.Text = #list == 1 and "1 script" or (#list .. " scripts")
  H.layout()
  if #list == 0 then
   M.show(emptyTitle or "No scripts found", emptyBody)
   Dt.empty()
  else
   M.show(nil)
   local keep = list[1]
   if S.selected then for _, i in list do if F.key(i) == F.key(S.selected) then keep = i; break end end end
   R.select(keep)
  end
  F.paint()
 end
 row.MouseLeave:Connect(function()
  S.hoverSerial += 1
  if S.selected then Dt.show(S.selected, false) end
 end)
 function H.toggleFav(info)
  local key = F.key(info)
  if S.favs[key] then
   S.favs[key] = nil
   for n = #S.favList, 1, -1 do if F.key(S.favList[n]) == key then table.remove(S.favList, n) end end
  else
   S.favs[key] = true
   local copy = {}
   for k, v in info do copy[k] = v end
   copy.about = (copy.about or ""):sub(1, 1200)
   table.insert(S.favList, 1, copy)
  end
  F.save()
  F.paint()
  if S.scope == "favorites" then doSearch(box.Text, true) end
 end

 S.shownSuggestions = ""
 function H.renderSuggestions(query, list)
  local names, seen, q = {}, {[query:lower()] = true}, query:lower()
  for _, info in list or {} do
   local name = info.game
   if #names < 3 and name ~= "Universal" and not seen[name:lower()] and name:lower():find(q, 1, true) then
    seen[name:lower()] = true
    names[#names + 1] = name
   end
  end
  local show = query ~= "" and query ~= S.committed and #names > 0
  local key = show and table.concat(names, "\n") or ""
  if key == S.shownSuggestions then return end
  S.shownSuggestions = key
  for _, child in H.suggest:GetChildren() do
   if child:IsA("GuiObject") then child:Destroy() end
  end
  H.suggestChips = {}
  H.title.Visible = not show; H.count.Visible = not show
  if not show then return end
  for _, name in names do
   local b, l, _, w = U.chip(H.suggest, name:sub(1, 24), "search", 0, 0, 26, function()
    S.committed = name
    box.Text = name
    box:ReleaseFocus()
    doSearch(name, true)
   end)
   H.suggestChips[#H.suggestChips + 1] = {b = b, l = l, w = w}
  end
  H.placeSuggestions()
  for _, c in H.suggestChips do
   if _G._nv_reveal and c.b.Visible then _G._nv_reveal(c.b, 0, 0) end
  end
 end

 function H.sectionText(query)
  if S.scope == "favorites" then return query == "" and "Favorites" or ("Favorites matching " .. query) end
  if query ~= "" then return "Results for " .. query end
  if S.scope == "universal" then return "Trending" end
  if S.scope == "game" then return "Top in " .. (S.gameName or "this game") end
  return "Recent uploads"
 end
 function H.favoriteResults(query)
  local q, out = query:lower(), {}
  for _, info in S.favList do
   local hit = q == "" or info.title:lower():find(q, 1, true) or tostring(info.game):lower():find(q, 1, true)
   if hit and not (S.keyless and info.key) then out[#out + 1] = info end
  end
  return out
 end
 doSearch = function(query, commit, live)
  query = U.trim(query)
  S.serial += 1
  local mine, provider, scope, keyless = S.serial, S.provider, S.scope, S.keyless
  if commit then S.committed = query end
  if commit or query == "" then H.renderSuggestions(query, nil) end
  H.title.Text = H.sectionText(query)
  H.count.Text = ""
  H.layout()
  if scope == "favorites" then
   R.render(H.favoriteResults(query), query == "" and "No favorites yet" or "No favorites match that",
    query == "" and "Use the heart on any script to keep it here." or "Try another name, or clear the search.")
   return
  end
  if not D.httpReq then
   R.clear()
   M.show("Search unavailable", "Your executor does not provide an HTTP request function.")
   Dt.empty()
   return
  end
  M.show(nil)
  R.skeletons()
  H.count.Text = "Loading"
  H.layout()
  task.spawn(function()
   local list = D.fetch(provider, query, scope, keyless)
   if not S.alive or mine ~= S.serial then return end
   if live then H.renderSuggestions(query, list) end
   if not list then
    R.clear()
    H.count.Text = ""
    H.layout()
    M.show("Couldn't load scripts", "Try again, or switch the source at the top right.", true)
    Dt.empty()
    return
   end
   R.render(list, "No scripts found", query == "" and "Nothing here from this source yet. Try the other one at the top right."
    or "Try a different script or game name, another filter, or switch source.")
  end)
 end

 for key, s in sourceButtons do
  s.button.Activated:Connect(function()
   if S.provider == key then return end
   S.provider = key
   paintSources()
   doSearch(box.Text, true)
  end)
 end
 box:GetPropertyChangedSignal("Text"):Connect(function()
  local query = U.trim(box.Text)
  clearBtn.Visible = box.Text ~= ""
  if query == S.committed then return end
  S.typing += 1
  local mine = S.typing
  task.delay(0.3, function()
   if S.alive and mine == S.typing and U.trim(box.Text) == query then
    if query == "" then doSearch("", true) else doSearch(query, false, true) end
   end
  end)
 end)
 box.FocusLost:Connect(function(enter)
  if enter then
   S.typing += 1
   doSearch(box.Text, true)
  end
 end)
 clearBtn.Activated:Connect(function()
  S.typing += 1
  S.committed = ""
  box.Text = ""
  doSearch("", true)
 end)

 Dt.card = kit.card(deck, "ScriptDetail", "br", 0, 0, K.DETAIL_W, K.DETAIL_H)
 Dt.body = createInstance("Frame", {
   Parent = Dt.card,
   Name = "Body",
   BackgroundTransparency = 1,
   BorderSizePixel = 0,
   Size = UDim2.fromScale(1, 1),
   ZIndex = 20,
 })
 Dt.body:SetAttribute("NoFlex", true)
 Dt.LINE = 15
 Dt.OUT = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
 Dt.KEN = TweenInfo.new(18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
 Dt.TINTS = {
  {Color3.fromRGB(13, 40, 51), Color3.fromRGB(64, 186, 255)}, {Color3.fromRGB(38, 28, 62), Color3.fromRGB(168, 120, 255)},
  {Color3.fromRGB(14, 46, 40), Color3.fromRGB(56, 224, 186)}, {Color3.fromRGB(62, 36, 16), Color3.fromRGB(255, 150, 50)},
 }
 do
  local rim = createInstance("Frame", {
    Parent = Dt.body,
    Name = "HeroRim",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 40,
  })
  U.round(rim, 28)
  local st = createInstance("UIStroke", {
    Parent = rim,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.new(1, 1, 1),
    Thickness = 1,
  })
  pcall(function() st.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
  local g = createInstance("UIGradient", { Parent = st, Rotation = 90, Transparency = U.fade({{0, 0.84}, {0.22, 0.95}, {0.4, 1}, {1, 1}}) })
 end

 function Dt.geo(w, h)
  w, h = math.floor(w + 0.5), math.floor(h + 0.5)
  local g = {w = w, h = h, P = 18, cw = w - 36}
  g.heroH = math.max(120, math.min(math.floor(132 + (w - 330) * 0.5625 + 0.5), h - 228))
  g.titleY, g.authorY, g.metaY = g.heroH - 52, g.heroH - 24, g.heroH - 2
  g.statsY, g.tagsY, g.descY = g.heroH + 24, g.heroH + 70, g.heroH + 100
  g.actY = h - 54
  g.descH = math.max(Dt.LINE * 2, math.floor((g.actY - 10 - g.descY) / Dt.LINE) * Dt.LINE)
  return g
 end
 function Dt.heroFallback(info)
  local id = type(info.fallback) == "string" and info.fallback:match("id=(%d+)")
  return id and ("rbxthumb://type=Asset&id=" .. id .. "&w=768&h=432") or info.fallback
 end

 function Dt.hero(page, info)
  local E = {}
  local clip = createInstance("CanvasGroup", {
    Parent = page,
    Name = "Hero",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 21,
    Size = UDim2.fromOffset(K.DETAIL_W, 132),
  })
  E.clip = clip
  local melt = createInstance("UIGradient", { Parent = clip, Rotation = 90, Transparency = U.fade({{0, 0}, {0.36, 0}, {0.62, 0.3}, {0.82, 0.7}, {1, 1}}) })
  local tint = Dt.TINTS[(#(info and info.title or "") % #Dt.TINTS) + 1]
  local wash = createInstance("Frame", {
    Parent = clip,
    Name = "Placeholder",
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 21,
  })
  local washFill = createInstance("UIGradient", { Parent = wash, Rotation = 35, Color = ColorSequence.new(tint[1], Color3.fromRGB(18, 18, 20)) })
  U.centerIcon(wash, "code", 30, tint[2], 0.4).ImageTransparency = 0.3
  local pic = createInstance("ImageLabel", {
    Parent = clip,
    Name = "Picture",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 22,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(1, 1),
    Image = "",
    ImageTransparency = 1,
  })
  local shade = createInstance("Frame", {
    Parent = clip,
    Name = "Shade",
    BackgroundColor3 = Color3.new(0, 0, 0),
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 23,
  })
  local shadeFade = createInstance("UIGradient", { Parent = shade, Rotation = 90, Transparency = U.fade({{0, 1}, {0.4, 1}, {1, 0.45}}) })
  if info then D.loadImage(pic, info.image, Dt.heroFallback(info)) end
  if pic.Image ~= "" then pic.ImageTransparency = 0 end
  pic:GetPropertyChangedSignal("Image"):Connect(function()
   if pic.Image ~= "" then tw(pic, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}) end
  end)
  local text = info and info.title or "Nothing selected"
  E.title = U.text(page, text, Enum.Font.GothamBold, 19, (info and info.patched) and SUBTLE or TEXT, 18, 80, 10, 24)
  E.title.ZIndex = 24
  E.titleW = math.ceil(U.width(text, 19, Enum.Font.GothamBold))
  if info and info.verified then
   E.badge = U.icon(page, "verified", 16, 0, 0, K.BLUE); E.badge.ZIndex = 24
  end
  if info then
   local link = kit.softButton(page, 0, 12, 32, 32, nil, Color3.fromRGB(10, 10, 12), 16)
   link.BackgroundTransparency = 0.35; link.ZIndex = 26
   local linkIcon = U.centerIcon(link, "link", 14, TEXT)
   link.Activated:Connect(function() if A.copy(info.url, "Link") then U.confirm(linkIcon, "link") end end)
   E.link = link
  end
  return E
 end
 function Dt.layHero(E, g)
  E.clip.Size = UDim2.fromOffset(g.w, g.heroH)
  local tw1 = math.min(E.titleW + 2, g.cw - (E.badge and 22 or 0))
  E.title.Position = UDim2.fromOffset(g.P, g.titleY)
  E.title.Size = UDim2.fromOffset(E.badge and tw1 or g.cw, 24)
  if E.badge then E.badge.Position = UDim2.fromOffset(g.P + tw1 + 5, g.titleY + 4) end
  if E.link then E.link.Position = UDim2.fromOffset(g.w - 12 - 32, 12) end
 end

 function Dt.author(E, cg, info)
  if info.author then
   local avatar = createInstance("ImageLabel", {
     Parent = cg,
     BackgroundColor3 = Color3.fromRGB(40, 40, 44),
     BorderSizePixel = 0,
     Size = UDim2.fromOffset(18, 18),
     ScaleType = Enum.ScaleType.Crop,
     ZIndex = 22,
   })
   U.round(avatar)
   D.loadImage(avatar, info.avatar, nil)
   E.avatar, E.avatarInset = avatar, 0
   E.name = U.text(cg, info.author, Enum.Font.GothamBold, 12, TEXT, 0, 0, 10, 18)
   if info.authorVerified then E.nameBadge = U.icon(cg, "verified", 13, 0, 0, K.BLUE) end
  else
   E.avatar, E.avatarInset = U.icon(cg, "person", 16, 0, 0, SUBTLE), 1
   E.name = U.text(cg, "Unknown author", Enum.Font.GothamMedium, 12, SUBTLE, 0, 0, 10, 18)
  end
  E.nameW = math.ceil(U.width(E.name.Text, 12, E.name.Font)) + 2
  local when = U.ago(info.updated)
  E.meta = U.text(cg, info.game .. (when and (", updated " .. when) or ""), Enum.Font.GothamMedium, 12, SUBTLE, 0, 0, 10, 16)
 end
 function Dt.stats(E, cg, info)
  E.stats, E.seps = {}, {}
  for _, st in {{info.views, "Views"}, {info.likes, "Likes"}, {info.executions, "Runs"}, {info.saves, "Saves"}} do
   local n = U.short(st[1])
   if n and #E.stats < 3 then
    E.stats[#E.stats + 1] = {
     U.text(cg, n, Enum.Font.GothamBold, 17, TEXT, 0, 0, 10, 20, Enum.TextXAlignment.Center),
     U.text(cg, st[2], Enum.Font.GothamMedium, 11, SUBTLE, 0, 0, 10, 14, Enum.TextXAlignment.Center),
    }
   end
  end
  for _ = 2, #E.stats do
   local sep = createInstance("Frame", {
     Parent = cg,
     BackgroundColor3 = Color3.new(1, 1, 1),
     BackgroundTransparency = 0.92,
     BorderSizePixel = 0,
     ZIndex = 22,
   })
   E.seps[#E.seps + 1] = sep
  end
  if #E.stats == 0 then E.noStats = U.text(cg, "No stats yet", Enum.Font.GothamMedium, 12, SUBTLE, 0, 0, 10, 20, Enum.TextXAlignment.Center) end
 end
 function Dt.tag(parent, text, color)
  local w = math.ceil(U.width(text, 11, Enum.Font.GothamBold)) + 20
  local f = createInstance("Frame", {
    Parent = parent,
    BackgroundColor3 = color or Color3.new(1, 1, 1),
    BackgroundTransparency = color and 0.82 or 0.9,
    BorderSizePixel = 0,
    Size = UDim2.fromOffset(w, 22),
    ZIndex = 21,
  })
  U.round(f)
  U.text(f, text, Enum.Font.GothamBold, 11, color or SUB, 0, 0, w, 22, Enum.TextXAlignment.Center)
  return {f = f, w = w}
 end
 function Dt.tags(E, cg, info)
  local tagRow = createInstance("Frame", {
    Parent = cg,
    Name = "Tags",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 21,
  })
  E.tagRow, E.chips = tagRow, {}
  local list = {}
  if info.patched then list[#list + 1] = {"Patched", K.RED} end
  if info.verified then list[#list + 1] = {"Verified", K.BLUE} end
  list[#list + 1] = {info.key and "Key system" or "Keyless"}
  if info.ui then list[#list + 1] = {info.ui .. " UI"} end
  for _, t in info.tags or {} do
   if type(t) == "string" and t ~= "" and #list < 14 then list[#list + 1] = {"#" .. t} end
  end
  for _, t in list do E.chips[#E.chips + 1] = Dt.tag(tagRow, t[1], t[2]) end
 end
 function Dt.about(E, cg, info)
  local scroll = createInstance("ScrollingFrame", {
    Parent = cg,
    Name = "About",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromOffset(K.DETAIL_W - 36, 200),
    ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 21,
  })
  local has = info.about ~= ""
  local about = U.text(scroll, has and info.about or "No description yet.", Enum.Font.GothamMedium, 12, has and SUB or SUBTLE, 0, 0, 10, 10)
  about.Size = UDim2.new(1, -4, 0, 0); about.AutomaticSize = Enum.AutomaticSize.Y; about.LineHeight = 1.25
  about.TextWrapped = true; about.TextTruncate = Enum.TextTruncate.None; about.TextYAlignment = Enum.TextYAlignment.Top
  if _G._nv_scrollFade then pcall(_G._nv_scrollFade, scroll) end
  E.descBox = scroll.Parent ~= cg and scroll.Parent or scroll
 end
 function Dt.tile(E, cg, iconName, action, bg, ink)
  local b = kit.softButton(cg, 0, 0, 40, 40, nil, bg, 20)
  b.ZIndex = 22
  local img = U.centerIcon(b, iconName, 16, ink or TEXT)
  b.Activated:Connect(function() if action() then U.confirm(img, iconName) end end)
  local t = {button = b, icon = img}
  E.tiles[#E.tiles + 1] = t
  return t
 end
 function Dt.actions(E, cg, info)
  local run = kit.softButton(cg, 0, 0, 120, 40, nil, K.PILL, 20)
  run.ZIndex = 22
  local inner = createInstance("Frame", {
    Parent = run,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(48, 40),
    ZIndex = 22,
  })
  local playIcon = U.icon(inner, "play", 14, 0, 13, K.INK)
  U.text(inner, "Run", Enum.Font.GothamBold, 13, K.INK, 21, 0, 28, 40)
  run.Activated:Connect(function()
   A.run(info)
   if info.code then U.confirm(playIcon, "play") end
  end)
  E.run, E.tiles = run, {}
  Dt.tile(E, cg, "copy", function() return A.copy(info.code, "Loadstring") end)
  Dt.tile(E, cg, "download", function() return A.save(info) end)
  local heart = Dt.tile(E, cg, "heart", function() H.toggleFav(info); return false end)
  local wash = createInstance("Frame", {
    Parent = heart.button,
    Name = "Kept",
    BackgroundColor3 = K.RED_BG,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 22,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, -2, 1, -2),
  })
  U.round(wash)
  Dt.heart = {wash = wash, icon = heart.icon, key = F.key(info)}
  Dt.paintHeart(true)
  if info.key and info.keyLink then
   Dt.tile(E, cg, "key", function() return A.copy(info.keyLink, "Key link") end, K.YELLOW_BG, K.YELLOW)
  end
  if info.discord then
   Dt.tile(E, cg, "discord", function() return A.copy(info.discord, "Discord invite") end, K.PURPLE_BG, K.PURPLE)
  end
 end
 function Dt.paintHeart(instant)
  local h = Dt.heart
  if not h or not h.icon.Parent then return end
  local on = S.favs[h.key] == true
  if instant == true then
   h.wash.BackgroundTransparency = on and 0 or 1; h.icon.ImageColor3 = on and K.RED or TEXT
   return
  end
  tw(h.wash, K.quick, {BackgroundTransparency = on and 0 or 1})
  tw(h.icon, K.quick, {ImageColor3 = on and K.RED or TEXT})
 end
 F.onPaint = Dt.paintHeart
 function Dt.lower(page, info)
  local E = {}
  local cg = createInstance("CanvasGroup", {
    Parent = page,
    Name = "Lower",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 23,
  })
  E.frame = cg
  if not info then
   Dt.heart = nil
   E.hint = U.text(cg, "Hover a script on the left to preview it here. Click one to keep it.", Enum.Font.GothamMedium, 12, SUBTLE, 0, 0, 10, 34)
   E.hint.TextWrapped = true; E.hint.TextTruncate = Enum.TextTruncate.None; E.hint.TextYAlignment = Enum.TextYAlignment.Top
   return E
  end
  Dt.author(E, cg, info)
  Dt.stats(E, cg, info)
  Dt.tags(E, cg, info)
  Dt.about(E, cg, info)
  Dt.actions(E, cg, info)
  return E
 end
 function Dt.layStats(E, g)
  local n = #E.stats
  if E.noStats then
   E.noStats.Position = UDim2.fromOffset(g.P, g.statsY + 7); E.noStats.Size = UDim2.fromOffset(g.cw, 20)
   return
  end
  local colW = g.cw / n
  for i, st in E.stats do
   local x0, x1 = math.floor(g.P + (i - 1) * colW + 0.5), math.floor(g.P + i * colW + 0.5)
   st[1].Position = UDim2.fromOffset(x0, g.statsY); st[1].Size = UDim2.fromOffset(x1 - x0, 20)
   st[2].Position = UDim2.fromOffset(x0, g.statsY + 21); st[2].Size = UDim2.fromOffset(x1 - x0, 14)
   local sep = E.seps[i]
   if sep then sep.Position = UDim2.fromOffset(x1, g.statsY + 3); sep.Size = UDim2.fromOffset(1, 30) end
  end
 end
 function Dt.layActions(E, g)
  local n = #E.tiles
  local tile, gap = 40, 8
  if g.cw - n * (tile + gap) < 84 then tile, gap = 36, 6 end
  local runW = g.cw - n * (tile + gap)
  E.run.Position = UDim2.fromOffset(g.P, g.actY); E.run.Size = UDim2.fromOffset(runW, 40)
  local x, y = g.P + runW + gap, g.actY + (40 - tile) / 2
  for _, t in E.tiles do
   t.button.Position = UDim2.fromOffset(x, y); t.button.Size = UDim2.fromOffset(tile, tile)
   x += tile + gap
  end
 end
 function Dt.layLower(E, g)
  if E.hint then
   E.hint.Position = UDim2.fromOffset(g.P, g.authorY); E.hint.Size = UDim2.fromOffset(g.cw, 34)
   return
  end
  local nw = math.min(E.nameW, g.cw - 26 - (E.nameBadge and 18 or 0))
  E.avatar.Position = UDim2.fromOffset(g.P + E.avatarInset, g.authorY + E.avatarInset)
  E.name.Position = UDim2.fromOffset(g.P + 26, g.authorY); E.name.Size = UDim2.fromOffset(nw, 18)
  if E.nameBadge then E.nameBadge.Position = UDim2.fromOffset(g.P + 26 + nw + 4, g.authorY + 2) end
  E.meta.Position = UDim2.fromOffset(g.P, g.metaY); E.meta.Size = UDim2.fromOffset(g.cw, 16)
  Dt.layStats(E, g)
  E.tagRow.Position = UDim2.fromOffset(g.P, g.tagsY); E.tagRow.Size = UDim2.fromOffset(g.cw, 22)
  local x, full = 0, false
  for _, c in E.chips do
   full = full or x + c.w > g.cw
   c.f.Visible = not full
   c.f.Position = UDim2.fromOffset(x, 0)
   x += c.w + 6
  end
  E.descBox.Position = UDim2.fromOffset(g.P, g.descY); E.descBox.Size = UDim2.fromOffset(g.cw, g.descH)
  Dt.layActions(E, g)
 end
 function Dt.layout(w, h)
  local page = Dt.page
  if not (page and page.frame.Parent) then return end
  local g = Dt.geo(w, h)
  Dt.layHero(page.hero, g)
  Dt.layLower(page.lower, g)
 end
 if kit.onResize then kit.onResize(Dt.card, Dt.layout) end

 function Dt.leave(cg, z)
  if not (cg and cg.Parent) then return end
  cg.Name = "Leaving"; cg.ZIndex = z
  pcall(function() cg.Interactable = false end)
  tw(cg, Dt.OUT, {GroupTransparency = 1, Position = UDim2.fromOffset(0, cg.Position.Y.Offset - 6)})
  task.delay(0.16, function() _nvL.discard(cg) end)
 end
 function Dt.enter(cg, delay)
  cg.GroupTransparency = 1; cg.Position = UDim2.fromOffset(0, 8)
  tw(cg, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, delay or 0),
   {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)})
 end
 function Dt.render(info, lowerOnly)
  local page = Dt.page
  if lowerOnly and page and page.frame.Parent then
   local old = page.lower
   page.lower = Dt.lower(page.frame, info)
   Dt.layout(U.restSize(Dt.card))
   if os.clock() - page.born < 0.5 then old.frame:Destroy(); return end
   Dt.leave(old.frame, 22)
   Dt.enter(page.lower.frame, 0.03)
   return
  end
  local frame = createInstance("CanvasGroup", {
    Parent = Dt.body,
    Name = "Page",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20,
  })
  U.round(frame, 28)
  local old = Dt.page
  Dt.page = {frame = frame, empty = info == nil, born = os.clock()}
  Dt.page.hero = Dt.hero(frame, info)
  Dt.page.lower = Dt.lower(frame, info)
  Dt.layout(U.restSize(Dt.card))
  if old then Dt.leave(old.frame, 19) end
  Dt.enter(frame, old and 0.04 or 0)
 end
 function Dt.empty()
  S.shownKey, S.shownRich, S.selected = nil, false, nil
  if Dt.page and Dt.page.empty and Dt.page.frame.Parent then return end
  Dt.render(nil, false)
 end
 function Dt.show(info, select)
  if select then S.selected = info end
  local key = F.key(info)
  local rich = D.detailCache[key]
  if S.shownKey ~= key then
   Dt.render(rich or info, false)
   S.shownKey, S.shownRich = key, rich ~= nil
  elseif rich and not S.shownRich then
   Dt.render(rich, true)
   S.shownRich = true
  end
  if not select or rich then return end
  S.detailSerial += 1
  local mine = S.detailSerial
  task.spawn(function()
   local full = D.detail(info)
   if not full or not S.alive then return end
   for k, v in info do if full[k] == nil then full[k] = v end end
   if full.about == "" then full.about = info.about end
   D.detailCache[key] = full
   if mine ~= S.detailSerial or S.shownKey ~= key or S.shownRich then return end
   Dt.render(full, true)
   S.shownRich = true
  end)
 end
 Dt.empty()

 task.spawn(function()
  local ok, product = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
  if ok and type(product) == "table" and type(product.Name) == "string" and product.Name ~= "" then
   S.gameName = product.Name
   if S.scope == "game" and U.trim(box.Text) == "" then H.title.Text = H.sectionText(""); H.layout() end
  end
 end)
 _G._nv_deckRefresh[5] = function()
  F.paint()
  H.layoutShelf(U.restSize(shelf))
  Dt.layout(U.restSize(Dt.card))
  if not S.started then
   S.started = true
   doSearch("", true)
  end
 end
 task.spawn(function()
  local gui = _G._nv_stageGui
  while gui and gui.Parent do task.wait(1) end
  S.alive = false
 end)
 end
 _G._nv_queueTab(5, build)
end
