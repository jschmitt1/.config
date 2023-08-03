spaces = require("hs.spaces")
window = require("hs.window")
screen = require("hs.screen")

function redrawBorder()
    win = hs.window.focusedWindow()
    if win ~= nil then
        top_left = win:topLeft()
        size = win:size()
        if global_border ~= nil then
            global_border:delete()
        end
        global_border = hs.drawing.rectangle(hs.geometry.rect(top_left['x'], top_left['y'], size['w'], size['h']))
        global_border:setStrokeColor({["red"]=1,["blue"]=1,["green"]=1,["alpha"]=0.8})
        global_border:setFill(false)
        global_border:setStrokeWidth(6)
        global_border:show()
    end
end

function focus_left()
    local win = hs.window.filter.new():setCurrentSpace(true)
    -- local win = hs.window.focusedWindow()
    if win == nil then
        return
    end
    win:focusWindowWest(nil, false, true)
    -- win:focusWindowWest(nil, nil, True)
end

function focus_right()
    local win = hs.window.filter.new():setCurrentSpace(true)
    if win == nil then
        return
    end
    win:focusWindowEast(nil, false, true)
end

function focus_north()
    local win = hs.window.filter.new():setCurrentSpace(true)
    if win == nil then
        return
    end
    win:focusWindowNorth(nil, false, true)
end

function focus_south()
    local win = hs.window.filter.new():setCurrentSpace(true)
    if win == nil then
        return
    end
    win:focusWindowSouth(nil, false, true)
end

function focus_clockwise()
	local win = window.focusedWindow()      -- current window
	local wins = hs.window.filter.new():setCurrentSpace(true):getWindows()
	local wasFound = false
	local firstVal = nil
	print(dump(wins))
	for k,v in pairs(wins) do
		print(v)
		if firstVal == nil then
			firstVal = v
		end
		if wasFound == true then
			print("switching to")
			print(v)
			v:focus()
			return
		end
		if v == win then
			if next(wins,k) == nil then
				print("switching to1")
				print(firstVal)
				firstVal:focus()
				return
			else
				wasFound = true
			end
		end
	end
end

-- Return the first index with the given value (or nil if not found).
function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

-- prints table
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function slack_search()
	hs.eventtap.keyStroke({'cmd','shift'}, "3")
  wait(.4)
	hs.eventtap.keyStroke({'cmd'}, "g")
	hs.eventtap.keyStroke({'cmd'}, "a")
	hs.eventtap.keyStroke({'cmd'}, "v")
  hs.eventtap.keyStroke({}, "return")
end

function find_zoom()
	local win = window.focusedWindow()      -- current window
    	local uuid = win:screen()
	local cur_screen_id = uuid:getUUID()
	local target_screen = #spaces.allSpaces()[cur_screen_id] - 1
	hs.eventtap.keyStroke({'cmd','shift'}, tostring(target_screen))
	wait(.7)
	hs.eventtap.keyStroke({'cmd','shift'}, 'r')
end

function full_size()
  local win = window.focusedWindow()      -- current window
	local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + 50
  f.y = max.y + 50
  f.w = max.w - 100
  f.h = max.h - 100
  win:setFrame(f)
  
end
function auto_resize()
  print("in auto")
	local wins = hs.window.filter.new():setCurrentSpace(true):getWindows()
	local screen = hs.screen.mainScreen():currentMode()
	local rect = hs.geometry(50, 50, screen['w']-100, screen['h']-100)
	hs.window.animationDuration = 0
	hs.window.tiling.tileWindows(wins, rect)

end

function sendToSpace(x)
	local win = window.focusedWindow()      -- current window
    	local uuid = win:screen()
	local cur_screen_id = uuid:getUUID()
	local target_screen = spaces.allSpaces()[cur_screen_id][x]
	spaces.moveWindowToSpace(win, target_screen)
	hs.eventtap.keyStroke({'cmd','shift'}, tostring(x))
	wait(.3)
	-- auto_resize()
end

function wait(seconds)
	local start = os.time()
	repeat until os.time() > start + seconds
end

redrawBorder()
auto_resize()

allwindows = hs.window.filter.new(nil)
allwindows:subscribe(hs.window.filter.windowCreated, function () redrawBorder() end)
allwindows:subscribe(hs.window.filter.windowFocused, function () redrawBorder() end)
allwindows:subscribe(hs.window.filter.windowMoved, function () redrawBorder() end)
allwindows:subscribe(hs.window.filter.windowDestroyed, function () redrawBorder() end)
allwindows:subscribe(hs.window.filter.windowUnfocused, function () redrawBorder() end)

-- allwindows:subscribe(hs.window.filter.windowCreated, function () auto_resize() end)
-- allwindows:subscribe(hs.window.filter.windowFocused, function () auto_resize() end)
-- allwindows:subscribe(hs.window.filter.windowMoved, function () auto_resize() end)
-- allwindows:subscribe(hs.window.filter.windowDestroyed, function () auto_resize() end)
-- allwindows:subscribe(hs.window.filter.windowUnfocused, function () auto_resize() end)

hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, "1",function() sendToSpace(1) end)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, "2",function() sendToSpace(2) end)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, "3",function() sendToSpace(3) end)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, "4",function() sendToSpace(4) end)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, "5",function() sendToSpace(5) end)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, "6",function() sendToSpace(6) end)

hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, 'h', focus_left)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, 'l', focus_right)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, 'j', focus_south)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, 'k', focus_north)

hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, 'r', auto_resize)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, 'f', full_size)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, 's', slack_search)
hs.hotkey.bind({"cmd", "ctrl","alt","shift"}, 'd', find_zoom)
-- hs.hotkey.bind({"cmd"}, '0', focus_clockwise)
--
