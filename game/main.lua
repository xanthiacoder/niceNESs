https = nil
local overlayStats = require("lib.overlayStats")
local runtimeLoader = require("runtime.loader")

local json = require("lib.json")
local ansi = require("lib.ansi")


function love.load()
  https = runtimeLoader.loadHTTPS()
  -- Your game load here
  monoFont = love.graphics.newFont("fonts/"..FONT, FONT_SIZE)
  monoFont2x = love.graphics.newFont("fonts/"..FONT2X, FONT2X_SIZE)
  love.graphics.setFont( monoFont )
  print(monoFont:getWidth("█"))
  print(monoFont:getHeight())
  love.graphics.setFont( monoFont2x )
  print(monoFont2x:getWidth("█"))
  print(monoFont2x:getHeight())
  overlayStats.load() -- Should always be called last
end

function love.draw()
  -- Your game draw here
  overlayStats.draw() -- Should always be called last
  love.graphics.print("123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789|", monoFont, 0,0)
  love.graphics.print("1\n2\n3\n4\n5\n6\n7\n8\n9\n-\n1\n2\n3\n4\n5\n6\n7\n8\n9\n-\n1\n2\n3\n4\n5\n6\n7\n8\n9\n-", monoFont, 0,0)
--  love.graphics.print("1\n2\n3\n4\n5\n6\n7\n8\n9\n-\n1\n2\n3\n4\n5\n6\n7\n8\n9\n-\n1\n2\n3\n4\n5\n6\n7\n8\n9\n-", monoFont2x, 0,240)
  love.graphics.printf("This text is in monoFont.", monoFont, 10*FONT_WIDTH, 1*FONT_HEIGHT, 240, "left")
  love.graphics.printf("This text is in monoFont2x.", monoFont2x, 10*FONT2X_WIDTH, 4*FONT2X_HEIGHT, 240, "left")

  love.graphics.print("░▒▓█▓▒░", monoFont2x, 2*FONT2X_WIDTH, 3*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░", monoFont2x, 2*FONT2X_WIDTH, 4*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░", monoFont2x, 2*FONT2X_WIDTH, 5*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░", monoFont2x, 2*FONT2X_WIDTH, 6*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░", monoFont2x, 2*FONT2X_WIDTH, 7*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░", monoFont2x, 2*FONT2X_WIDTH, 8*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░", monoFont2x, 2*FONT2X_WIDTH, 9*FONT2X_HEIGHT)
  love.graphics.print("▄ █ ▀ ▌ ▐ ░ ▒ ▓", monoFont2x, 2*FONT2X_WIDTH, 11*FONT2X_HEIGHT)
  love.graphics.print("○", monoFont2x, 2*FONT2X_WIDTH, 12*FONT2X_HEIGHT)
  love.graphics.print("■", monoFont2x, 2*FONT2X_WIDTH, 13*FONT2X_HEIGHT)
  love.graphics.print("▲ ▼ ► ◄", monoFont2x, 2*FONT2X_WIDTH, 14*FONT2X_HEIGHT)
  love.graphics.print("╦ ╗ ╔ ═ ╩ ╝ ╚ ║ ╬ ╣ ╠ ╥ ╖ ╓ ╤ ╕ ╒ ┬ ┐ ┌ ─ ┴ ┘ └", monoFont2x, 2*FONT2X_WIDTH, 15*FONT2X_HEIGHT)
  love.graphics.print("│ ┼ ┤ ├ ╨ ╜ ╙ ╧ ╛ ╘ ╫ ╢ ╟ ╪ ╡ ╞", monoFont2x, 2*FONT2X_WIDTH, 16*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 3*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 4*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 5*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 6*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 7*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 8*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 9*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 10*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 11*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 12*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 13*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 14*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 15*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 16*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 17*FONT2X_HEIGHT)
  love.graphics.print("░▒▓█▓▒░░░▒▓█▓▒░░", monoFont2x, 51*FONT2X_WIDTH, 18*FONT2X_HEIGHT)
end

function love.update(dt)
  -- Your game update here
  overlayStats.update(dt) -- Should always be called last
end

function love.keypressed(key, scancode, isrepeat)
  print("key:"..key.." scancode:"..scancode.." isrepeat:"..tostring(isrepeat))
  if key == "escape" and love.system.getOS() ~= "Web" then
    love.event.quit()
  else
    overlayStats.handleKeyboard(key) -- Should always be called last
  end
  if key == "f12" then
    -- toggle fullscreen
      fullscreen = not fullscreen
			love.window.setFullscreen(fullscreen, "exclusive")

  end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  overlayStats.handleTouch(id, x, y, dx, dy, pressure) -- Should always be called last
end
