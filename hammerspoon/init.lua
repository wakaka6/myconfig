local englishInputSource = "com.apple.keylayout.ABC"

local terminalApps = {
  ["iTerm2"] = true,
  ["iTerm"] = true,
  ["Terminal"] = true,
}

local function focusChrome()
  local app = hs.application.get("Google Chrome")

  if not app then
    hs.application.launchOrFocus("Google Chrome")
    return
  end

  app:activate(true)

  local target = nil
  for _, win in ipairs(app:allWindows()) do
    if win:isStandard() then
      target = win
      if not win:isMinimized() then
        break
      end
    end
  end

  if target then
    if target:isMinimized() then
      target:unminimize()
    end
    target:focus()
    return
  end

  hs.osascript.applescript([[
    tell application id "com.google.Chrome"
      make new window
      activate
    end tell
  ]])
end

local function quitFrontmostApplication()
  local app = hs.application.frontmostApplication()

  if not app then
    return
  end

  local name = app:name()
  if name == "Finder" or name == "Hammerspoon" then
    hs.eventtap.keyStroke({ "cmd" }, "w")
    return
  end

  app:kill()
end

local function switchToEnglishForTerminal(appName, eventType)
  if eventType ~= hs.application.watcher.activated then
    return
  end

  if terminalApps[appName] then
    hs.keycodes.currentSourceID(englishInputSource)
  end
end

terminalInputWatcher = hs.application.watcher.new(switchToEnglishForTerminal)
terminalInputWatcher:start()

chromeHotkey = hs.hotkey.bind({ "alt" }, "c", function()
  focusChrome()
end)

closeWindowHotkey = hs.hotkey.bind({ "alt", "shift" }, "q", function()
  quitFrontmostApplication()
end)

chromeEventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  local flags = event:getFlags()
  local keyCode = event:getKeyCode()
  local isOnlyAlt = flags.alt and not flags.cmd and not flags.ctrl and not flags.shift and not flags.fn
  local isAltShift = flags.alt and flags.shift and not flags.cmd and not flags.ctrl and not flags.fn

  if isOnlyAlt and keyCode == 8 then
    focusChrome()
    return true
  end

  if isAltShift and keyCode == 12 then
    quitFrontmostApplication()
    return true
  end

  return false
end)
chromeEventTap:start()

hs.alert.show("Hammerspoon config loaded")
