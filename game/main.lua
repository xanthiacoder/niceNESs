-- https = nil
-- local runtimeLoader = require("runtime.loader")

--[[
screen resolution = 1280 x 720 px
screen chars = 160 x 45 (font)
screen chars = 160 x 90 (font2x)

ansicanvas dimensions:
should be variable to allow making UI assets
- set max as 160x90 ? (max resolution 1280x720)
4x4 ?
8x8 ?
16x16
24x24
32x32
48x48
64x64
]]

love.filesystem.setIdentity("niceNESs") -- for R36S file system compatibility
love.mouse.setVisible( true ) -- make mouse cursor invis, use bitmap cursor
love.graphics.setDefaultFilter("nearest", "nearest") -- for nearest neighbour, pixelart style

local json = require("lib.json")
local ansi = require("lib.ansi")

-- music libraries from Marc2o https://marc2o.github.io
require("lib.Music")
require("lib.WriteAiff")

local game = {}

-- game meta
game.name = "niceNESs"
game.version = "0.0.1"
game.edition = "(LÖVEJAM 2025 B-side)"

-- game flags
game.textEntry = "" -- when true, open textEntry interface

-- game variables
game.statusBar = ""

-- detect system OS
game.os = love.system.getOS() -- "OS X", "Windows", "Linux", "Android" or "iOS", "Web"
if love.filesystem.getUserDirectory( ) == "/home/ark/" then
	game.os = "R36S"
elseif love.system.getOS() == "OS X" then
  game.os = "Mac"
end
print("systemOS: "..game.os)


-- check / create file directories
if love.filesystem.getInfo("autosave") == nil then
  if game.os == "R36S" then
    os.execute("mkdir " .. love.filesystem.getSaveDirectory()) -- OS creation
    os.execute("mkdir " .. love.filesystem.getSaveDirectory() .. "//autosave")
    print("R36S: created directory - autosave")
  else
    love.filesystem.createDirectory("autosave")
    print("Created directory - autosave")
  end
end
local success = love.filesystem.remove( "autosave/.DS_Store" ) -- cleanup for Mac
if success then
  print("DS_Store removed from autosave")
else
  print("No files removed from autosave")
end

-- game data
local MML = {}
MML.title      = "< click (title)      to change >"
MML.composer   = "< click (composer)   to change >"
MML.programmer = "< click (programmer) to change >"
MML.copyright  = "< click (copyright)  to change >"
MML.sequence   = "< click (sequence) to change >" -- string of alphabets denoting the song sequence

MML.data = {}


function love.load()
  -- https = runtimeLoader.loadHTTPS()
  -- Your game load here
  monoFont = love.graphics.newFont("fonts/"..FONT, FONT_SIZE)
  monoFont2x = love.graphics.newFont("fonts/"..FONT2X, FONT2X_SIZE)
  love.graphics.setFont( monoFont )
  print(monoFont:getWidth("█"))
  print(monoFont:getHeight())
  love.graphics.setFont( monoFont2x )
  print(monoFont2x:getWidth("█"))
  print(monoFont2x:getHeight())

  -- xtui screens using monoFont
  nicenessLogo     = json.decode(love.filesystem.read("xtui/0-niceness-logo.xtui"))
  metaSections     = json.decode(love.filesystem.read("xtui/0-metadata-sections.xtui"))
  functionKeys     = json.decode(love.filesystem.read("xtui/0-function-keys.xtui"))
  instrumentsPanel = json.decode(love.filesystem.read("xtui/0-instruments.xtui"))
  musicBars        = json.decode(love.filesystem.read("xtui/0-musicbars.xtui"))
  rollMarkers      = json.decode(love.filesystem.read("xtui/0-rollmarkers.xtui"))
  dividerWalkthru  = json.decode(love.filesystem.read("xtui/0-divider-walkthru.xtui"))
  dividerMML       = json.decode(love.filesystem.read("xtui/0-divider-mml.xtui"))
  textWindowBlank  = json.decode(love.filesystem.read("xtui/0-textwindow-blank.xtui"))
end

function love.draw()
  -- Your game draw here

  -- convert mouse position to ansi text coordinates
  local mouse = {
    x = math.floor(love.mouse.getX()/8),
    y = math.floor(love.mouse.getY()/16)
  }

  -- draw xtui stuff
    love.graphics.setFont(monoFont)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(color.white)
--    love.graphics.print(nicenessLogo,FONT_WIDTH*80,FONT_HEIGHT*32) -- test drawing logo from xtui
    love.graphics.print(metaSections,0,0) -- instruments panel
    love.graphics.print(instrumentsPanel,1280/2,0) -- instruments panel
    love.graphics.print(functionKeys,1280/2,0) -- function keys help
    love.graphics.print(rollMarkers,FONT_WIDTH*29,FONT_HEIGHT*11) -- piano roll note markers
    love.graphics.print(musicBars,FONT_WIDTH*32,FONT_HEIGHT*11) -- 1st music bar
    love.graphics.print(musicBars,FONT_WIDTH*64,FONT_HEIGHT*11) -- 2nd music bar
    love.graphics.print(musicBars,FONT_WIDTH*96,FONT_HEIGHT*11) -- 3rd music bar
    love.graphics.print(musicBars,FONT_WIDTH*128,FONT_HEIGHT*11) -- 4th music bar
    love.graphics.print(dividerWalkthru,0,FONT_HEIGHT*30) -- divider : walkthru
    love.graphics.print(dividerMML,FONT_WIDTH*80,FONT_HEIGHT*30) -- divider : MML
    love.graphics.print(textWindowBlank,0,FONT_HEIGHT*31) -- text window left : blank
    love.graphics.print(textWindowBlank,FONT_WIDTH*80,FONT_HEIGHT*31) -- text window right : blank

  -- draw meta data
  love.graphics.setFont(monoFont)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(color.white)
  love.graphics.print(MML.title,FONT_WIDTH*12,FONT_HEIGHT*0)
  love.graphics.print(MML.composer,FONT_WIDTH*12,FONT_HEIGHT*1)
  love.graphics.print(MML.programmer,FONT_WIDTH*12,FONT_HEIGHT*2)
  love.graphics.print(MML.copyright,FONT_WIDTH*12,FONT_HEIGHT*3)
  love.graphics.print(MML.sequence,FONT_WIDTH*12,FONT_HEIGHT*10)

  -- status bar
  game.statusBar = game.name .. " " .. game.version .. " " .. game.edition .. " | "
  game.statusBar = game.statusBar .. mouse.x .. "," .. mouse.y .. " | "
  love.graphics.print(game.statusBar, FONT_WIDTH*1, FONT_HEIGHT*44)

end

function love.update(dt)
  -- Your game update here
end

function love.keypressed(key, scancode, isrepeat)
  print("key:"..key.." scancode:"..scancode.." isrepeat:"..tostring(isrepeat))
  if key == "f10" and love.system.getOS() ~= "Web" then
    love.event.quit()
  else
    -- stuff
  end
  if key == "f12" then
    -- toggle fullscreen
      fullscreen = not fullscreen
			love.window.setFullscreen(fullscreen, "exclusive")
  end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
end
