local englishInputSource = "com.apple.keylayout.ABC"

local terminalApps = {
  ["iTerm2"] = true,
  ["iTerm"] = true,
  ["Terminal"] = true,
}

local keyStrokeDelay = 20000
local configRoot = hs.execute("/bin/zsh -lc 'cd -P ~/.hammerspoon/.. && pwd'", true):gsub("%s+$", "")
local amethystFloatingScript = configRoot .. "/amethyst/scripts/floating.rb"

local function shellQuote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function openTerminal()
  hs.execute("/usr/bin/open -na /Applications/iTerm.app || /usr/bin/open -na /Applications/Utilities/Terminal.app", true)
end

local function openApps()
  hs.execute("/usr/bin/open /System/Applications/Apps.app", true)
end

local function sleepDisplay()
  hs.execute("/usr/bin/pmset displaysleepnow", true)
end

local function restartAmethyst()
  hs.osascript.applescript('tell application "Amethyst" to quit')
  hs.timer.doAfter(0.5, function()
    hs.application.launchOrFocus("Amethyst")
    hs.reload()
  end)
end

local function sendOptionShiftK()
  hs.eventtap.keyStroke({ "alt", "shift" }, "k", keyStrokeDelay)
end

local function toggleFrontmostApplicationFloating()
  local app = hs.application.frontmostApplication()

  if not app then
    return
  end

  local bundleID = app:bundleID()
  if not bundleID then
    hs.alert.show("Frontmost app has no bundle id")
    return
  end

  local appName = app:name() or bundleID
  local command = shellQuote(amethystFloatingScript) ..
    " toggle " .. shellQuote(bundleID) ..
    " " .. shellQuote(appName) ..
    " --restart"
  local output, ok = hs.execute(command, true)

  if ok then
    hs.alert.show(output:gsub("%s+$", ""))
  else
    hs.alert.show("Failed to update Amethyst floating")
  end
end

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

globalHotkeyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  local flags = event:getFlags()
  local keyCode = event:getKeyCode()
  local isOnlyAlt = flags.alt and not flags.cmd and not flags.ctrl and not flags.shift and not flags.fn
  local isAltShift = flags.alt and flags.shift and not flags.cmd and not flags.ctrl and not flags.fn

  if isOnlyAlt and (keyCode == 36 or keyCode == 76) then
    openTerminal()
    return true
  end

  if isOnlyAlt and keyCode == 2 then
    openApps()
    return true
  end

  if isOnlyAlt and keyCode == 8 then
    focusChrome()
    return true
  end

  if isOnlyAlt and keyCode == 50 then
    sendOptionShiftK()
    return true
  end

  if isOnlyAlt and keyCode == 53 then
    sleepDisplay()
    return true
  end

  if isAltShift and keyCode == 8 then
    hs.reload()
    return true
  end

  if isAltShift and keyCode == 3 then
    toggleFrontmostApplicationFloating()
    return true
  end

  if isAltShift and keyCode == 12 then
    quitFrontmostApplication()
    return true
  end

  if isAltShift and keyCode == 15 then
    restartAmethyst()
    return true
  end

  return false
end)
globalHotkeyTap:start()

hs.alert.show("Hammerspoon config loaded")
