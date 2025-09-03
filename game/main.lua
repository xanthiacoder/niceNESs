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
love.keyboard.setKeyRepeat(true) -- allows held down key to repeat

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
game.dataEntry = false -- flag for when data is being captured from the keyboard

-- game variables
game.statusBar = "" -- content string for status Bar at the bottom
game.selectBar = {  -- coordinates for selection background box
  ["x"]     = 161, -- set to off screen when nothing selected
  ["y"]     = 46, -- set to off screen when nothing selected
  ["width"] = 0,
}
game.selected = {
  ["pattern"] = "a", -- current selected pattern : a..z
}
game.inputData = "" -- string to cache data captured from keyboard
game.inputPrompt = "" -- prompt for data entry
game.dataType = "" -- can be "int" "str"
game.dataLength = 0 -- max length of data input


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
MML.title      = "< click (   title    ) to change >"
MML.composer   = "< click (  composer  ) to change >"
MML.programmer = "< click ( programmer ) to change >"
MML.copyright  = "< click ( copyright  ) to change >"
MML.sequence   = "< click (  sequence  ) to change >" -- string of alphabets denoting the song sequence

MML.data = {}


local SML = {}
SML.patternName = {
  ["a"] = "name pattern",
  ["b"] = "name pattern",
  ["c"] = "name pattern",
  ["d"] = "name pattern",
  ["e"] = "name pattern",
  ["f"] = "name pattern",
  ["g"] = "name pattern",
  ["h"] = "name pattern",
  ["i"] = "name pattern",
  ["j"] = "name pattern",
  ["k"] = "name pattern",
  ["l"] = "name pattern",
  ["m"] = "name pattern",
  ["n"] = "name pattern",
  ["o"] = "name pattern",
  ["p"] = "name pattern",
  ["q"] = "name pattern",
  ["r"] = "name pattern",
  ["s"] = "name pattern",
  ["t"] = "name pattern",
  ["u"] = "name pattern",
  ["v"] = "name pattern",
  ["w"] = "name pattern",
  ["x"] = "name pattern",
  ["y"] = "name pattern",
  ["z"] = "name pattern",
}
SML.volume = {
  ["a"] = {0,0,0,0,0},
  ["b"] = {0,0,0,0,0},
  ["c"] = {0,0,0,0,0},
  ["d"] = {0,0,0,0,0},
  ["e"] = {0,0,0,0,0},
  ["f"] = {0,0,0,0,0},
  ["g"] = {0,0,0,0,0},
  ["h"] = {0,0,0,0,0},
  ["i"] = {0,0,0,0,0},
  ["j"] = {0,0,0,0,0},
  ["k"] = {0,0,0,0,0},
  ["l"] = {0,0,0,0,0},
  ["m"] = {0,0,0,0,0},
  ["n"] = {0,0,0,0,0},
  ["o"] = {0,0,0,0,0},
  ["p"] = {0,0,0,0,0},
  ["q"] = {0,0,0,0,0},
  ["r"] = {0,0,0,0,0},
  ["s"] = {0,0,0,0,0},
  ["t"] = {0,0,0,0,0},
  ["u"] = {0,0,0,0,0},
  ["v"] = {0,0,0,0,0},
  ["w"] = {0,0,0,0,0},
  ["x"] = {0,0,0,0,0},
  ["y"] = {0,0,0,0,0},
  ["z"] = {0,0,0,0,0},
}

SML.tempo = {
  ["a"] = 120,
  ["b"] = 120,
  ["c"] = 120,
  ["d"] = 120,
  ["e"] = 120,
  ["f"] = 120,
  ["g"] = 120,
  ["h"] = 120,
  ["i"] = 120,
  ["j"] = 120,
  ["k"] = 120,
  ["l"] = 120,
  ["m"] = 120,
  ["n"] = 120,
  ["o"] = 120,
  ["p"] = 120,
  ["q"] = 120,
  ["r"] = 120,
  ["s"] = 120,
  ["t"] = 120,
  ["u"] = 120,
  ["v"] = 120,
  ["w"] = 120,
  ["x"] = 120,
  ["y"] = 120,
  ["z"] = 120,
}

SML.envelope = {
  ["a"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["b"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["c"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["d"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["e"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["f"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["g"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["h"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["i"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["j"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["k"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["l"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["m"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["n"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["o"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["p"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["q"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["r"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["s"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["t"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["u"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["v"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["w"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["x"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["y"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
  ["z"] = {["A"] = {0,0,0,0}, ["B"] = {0,0,0,0}, ["C"] = {0,0,0,0}, ["D"] = {0,0,0,0}, ["E"] = {0,0,0,0}},
}

---Use when requiring text data from user
---@param type string "int" "str"
---@param prompt string
---@param length integer
function startDataEntry(type,prompt,length)
  game.dataType = type
  game.inputPrompt = prompt
  game.dataLength = length
  game.inputData = "" -- clear text data cache for data entry
  game.dataEntry = true -- must set this first before setting selectBar, start capturing data from keyboard
end

function stopDataEntry()
  game.inputData = "" -- clear data cache
  game.inputPrompt = "" -- clear text prompt
  game.dataLength = "" -- clear max text length
  game.dataType = "" -- clear input data type
  game.selectBar["x"] = 161 -- out of screen
  game.selectBar["y"] = 46 -- out of screen
end

function love.textinput(t) -- called for every instance of text entry
  if game.dataEntry == true and #game.inputData < game.dataLength then
    game.inputData = game.inputData .. t
  end
end

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
    x = math.floor(love.mouse.getX()/8)+1,
    y = math.floor(love.mouse.getY()/16)+1
  }

  -- draw select bar first so that it will be in the bottom layer
  love.graphics.setColor(color.blue)
  love.graphics.rectangle("fill",FONT_WIDTH*game.selectBar["x"],FONT_HEIGHT*game.selectBar["y"],FONT_WIDTH*game.selectBar["width"],FONT_HEIGHT)

  -- draw xtui stuff
    love.graphics.setFont(monoFont)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(color.white)
--    love.graphics.print(nicenessLogo,FONT_WIDTH*80,FONT_HEIGHT*32) -- test drawing logo from xtui
    love.graphics.print(metaSections,0,0) -- instruments panel

    -- manual draw for new function Name Patterns
    love.graphics.setColor(color.cyan)
    love.graphics.print("(name pattern)",FONT_WIDTH*65,FONT_HEIGHT*9)

    love.graphics.setColor(color.white)
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


  -- draw current pattern's tempo
  love.graphics.setColor(color.brightcyan)
  love.graphics.print(SML.tempo[game.selected["pattern"]],FONT_WIDTH*32,FONT_HEIGHT*8)

  -- draw current pattern's volume levels
  love.graphics.setColor(color.brightcyan)
  love.graphics.rectangle("fill",FONT_WIDTH*94,(FONT_HEIGHT*4)+4,FONT_WIDTH*(SML.volume[game.selected["pattern"]][1]/8),FONT_HEIGHT/2)
  love.graphics.rectangle("fill",FONT_WIDTH*94,(FONT_HEIGHT*5)+4,FONT_WIDTH*(SML.volume[game.selected["pattern"]][2]/8),FONT_HEIGHT/2)
  love.graphics.rectangle("fill",FONT_WIDTH*94,(FONT_HEIGHT*7)+4,FONT_WIDTH*(SML.volume[game.selected["pattern"]][4]/8),FONT_HEIGHT/2)
  love.graphics.rectangle("fill",FONT_WIDTH*94,(FONT_HEIGHT*8)+4,FONT_WIDTH*(SML.volume[game.selected["pattern"]][5]/8),FONT_HEIGHT/2)

  -- status bar
  love.graphics.setColor(color.white)
  game.statusBar = game.name .. " " .. game.version .. " " .. game.edition .. " | "
  game.statusBar = game.statusBar .. mouse.x .. "," .. mouse.y .. " | "
  game.statusBar = game.statusBar .. game.inputPrompt .. ": " .. game.inputData
  love.graphics.print(game.statusBar, FONT_WIDTH*1, FONT_HEIGHT*44)

end

function love.update(dt)
  -- Your game update here

  -- title selected
  if (game.selectBar["x"] == 0 and game.selectBar["y"] == 0) and game.dataEntry == false then
    MML.title = game.inputData
    stopDataEntry()
  end

  -- composer selected
  if (game.selectBar["x"] == 0 and game.selectBar["y"] == 1) and game.dataEntry == false then
    MML.composer = game.inputData
    stopDataEntry()
  end

  -- programmer selected
  if (game.selectBar["x"] == 0 and game.selectBar["y"] == 2) and game.dataEntry == false then
    MML.programmer = game.inputData
    stopDataEntry()
  end

  -- copyright selected
  if (game.selectBar["x"] == 0 and game.selectBar["y"] == 3) and game.dataEntry == false then
    MML.copyright = game.inputData
    stopDataEntry()
  end


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

  -- user entered backspace to edit data entry
  if key == "backspace" and game.dataEntry == true then
    game.inputData = string.sub(game.inputData,1,#game.inputData-1)
  end

  -- user entered RETURN to end data entry
  if key == "return" and game.dataEntry == true then
    game.dataEntry = false
  end

end


function love.mousepressed( x, y, button, istouch, presses )

  -- convert mouse position to ansi text coordinates
  local mouse = {
    x = math.floor(love.mouse.getX()/8)+1,
    y = math.floor(love.mouse.getY()/16)+1
  }

  -- Melody Instrument
  if mouse.x >= 13 and mouse.x <= 19 and mouse.y == 5 then
    if mouse.x == 13 then -- A clicked
      game.selectBar["x"] = 11
      game.selectBar["y"] = 4
      game.selectBar["width"] = 3
    end
    if mouse.x == 15 then -- B clicked
      game.selectBar["x"] = 13
      game.selectBar["y"] = 4
      game.selectBar["width"] = 3
    end
    if mouse.x == 17 then -- C clicked
      game.selectBar["x"] = 15
      game.selectBar["y"] = 4
      game.selectBar["width"] = 3
    end
    if mouse.x == 19 then -- D clicked
      game.selectBar["x"] = 17
      game.selectBar["y"] = 4
      game.selectBar["width"] = 3
    end
  end

  -- Harmony 1 Instrument
  if mouse.x >= 13 and mouse.x <= 19 and mouse.y == 6 then
    if mouse.x == 13 then -- A clicked
      game.selectBar["x"] = 11
      game.selectBar["y"] = 5
      game.selectBar["width"] = 3
    end
    if mouse.x == 15 then -- B clicked
      game.selectBar["x"] = 13
      game.selectBar["y"] = 5
      game.selectBar["width"] = 3
    end
    if mouse.x == 17 then -- C clicked
      game.selectBar["x"] = 15
      game.selectBar["y"] = 5
      game.selectBar["width"] = 3
    end
    if mouse.x == 19 then -- D clicked
      game.selectBar["x"] = 17
      game.selectBar["y"] = 5
      game.selectBar["width"] = 3
    end
  end

  -- Harmony 2 Instrument
  if mouse.x >= 13 and mouse.x <= 19 and mouse.y == 7 then
    if mouse.x == 13 then -- A clicked
      game.selectBar["x"] = 11
      game.selectBar["y"] = 6
      game.selectBar["width"] = 3
    end
    if mouse.x == 15 then -- B clicked
      game.selectBar["x"] = 13
      game.selectBar["y"] = 6
      game.selectBar["width"] = 3
    end
    if mouse.x == 17 then -- C clicked
      game.selectBar["x"] = 15
      game.selectBar["y"] = 6
      game.selectBar["width"] = 3
    end
    if mouse.x == 19 then -- D clicked
      game.selectBar["x"] = 17
      game.selectBar["y"] = 6
      game.selectBar["width"] = 3
    end
  end

  -- Bass Instrument
  if mouse.x >= 13 and mouse.x <= 19 and mouse.y == 8 then
    if mouse.x == 13 then -- A clicked
      game.selectBar["x"] = 11
      game.selectBar["y"] = 7
      game.selectBar["width"] = 3
    end
    if mouse.x == 15 then -- B clicked
      game.selectBar["x"] = 13
      game.selectBar["y"] = 7
      game.selectBar["width"] = 3
    end
    if mouse.x == 17 then -- C clicked
      game.selectBar["x"] = 15
      game.selectBar["y"] = 7
      game.selectBar["width"] = 3
    end
    if mouse.x == 19 then -- D clicked
      game.selectBar["x"] = 17
      game.selectBar["y"] = 7
      game.selectBar["width"] = 3
    end
  end



  -- Patterns 13,10 - 78,10
  if mouse.x >= 13 and mouse.x <= 78 and mouse.y == 10 then
    if mouse.x == 13 then -- a clicked
      game.selectBar["x"] = 11
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "a"
    end
    if mouse.x == 15 then -- b clicked
      game.selectBar["x"] = 13
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "b"
    end
    if mouse.x == 17 then -- c clicked
      game.selectBar["x"] = 15
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "c"
    end
    if mouse.x == 19 then -- d clicked
      game.selectBar["x"] = 17
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "d"
    end
    if mouse.x == 21 then -- e clicked
      game.selectBar["x"] = 19
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "e"
    end
    if mouse.x == 23 then -- f clicked
      game.selectBar["x"] = 21
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "f"
    end
    if mouse.x == 25 then -- g clicked
      game.selectBar["x"] = 23
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "g"
    end
    if mouse.x == 27 then -- h clicked
      game.selectBar["x"] = 25
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "h"
    end
    if mouse.x == 29 then -- i clicked
      game.selectBar["x"] = 27
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "i"
    end
    if mouse.x == 31 then -- j clicked
      game.selectBar["x"] = 29
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "j"
    end
    if mouse.x == 33 then -- k clicked
      game.selectBar["x"] = 31
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "k"
    end
    if mouse.x == 35 then -- l clicked
      game.selectBar["x"] = 33
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "l"
    end
    if mouse.x == 37 then -- m clicked
      game.selectBar["x"] = 35
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "m"
    end
    if mouse.x == 39 then -- n clicked
      game.selectBar["x"] = 37
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "n"
    end
    if mouse.x == 41 then -- o clicked
      game.selectBar["x"] = 39
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "o"
    end
    if mouse.x == 43 then -- p clicked
      game.selectBar["x"] = 41
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "p"
    end
    if mouse.x == 45 then -- q clicked
      game.selectBar["x"] = 43
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "q"
    end
    if mouse.x == 47 then -- r clicked
      game.selectBar["x"] = 45
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "r"
    end
    if mouse.x == 49 then -- s clicked
      game.selectBar["x"] = 47
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "s"
    end
    if mouse.x == 51 then -- t clicked
      game.selectBar["x"] = 49
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "t"
    end
    if mouse.x == 53 then -- u clicked
      game.selectBar["x"] = 51
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "u"
    end
    if mouse.x == 55 then -- v clicked
      game.selectBar["x"] = 53
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "v"
    end
    if mouse.x == 57 then -- w clicked
      game.selectBar["x"] = 55
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "w"
    end
    if mouse.x == 59 then -- x clicked
      game.selectBar["x"] = 57
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "x"
    end
    if mouse.x == 61 then -- y clicked
      game.selectBar["x"] = 59
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "y"
    end
    if mouse.x == 63 then -- z clicked
      game.selectBar["x"] = 61
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      game.selected["pattern"] = "z"
    end
    if mouse.x >= 66 and mouse.x <= 79 then
      game.selectBar["x"] = 64
      game.selectBar["y"] = 9
      game.selectBar["width"] = 16
      end
  end

  -- A Envelope
  if mouse.x >= 136 and mouse.x <= 155 and mouse.y == 5 then
    if mouse.x >=136 and mouse.x <= 138 then -- atk clicked
      game.selectBar["x"] = 134
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      game.selectBar["x"] = 138
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      game.selectBar["x"] = 142
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      game.selectBar["x"] = 146
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
    end
    if mouse.x ==152 then -- * clicked for reset
      game.selectBar["x"] = 150
      game.selectBar["y"] = 4
      game.selectBar["width"] = 3
    end
    if mouse.x ==155 then -- % clicked for random
      game.selectBar["x"] = 153
      game.selectBar["y"] = 4
      game.selectBar["width"] = 3
    end
  end

  -- B Envelope
  if mouse.x >= 136 and mouse.x <= 155 and mouse.y == 6 then
    if mouse.x >=136 and mouse.x <= 138 then -- atk clicked
      game.selectBar["x"] = 134
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      game.selectBar["x"] = 138
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      game.selectBar["x"] = 142
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      game.selectBar["x"] = 146
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
    end
    if mouse.x ==152 then -- * clicked for reset
      game.selectBar["x"] = 150
      game.selectBar["y"] = 5
      game.selectBar["width"] = 3
    end
    if mouse.x ==155 then -- % clicked for random
      game.selectBar["x"] = 153
      game.selectBar["y"] = 5
      game.selectBar["width"] = 3
    end
  end

  -- C Envelope
  if mouse.x >= 136 and mouse.x <= 155 and mouse.y == 7 then
    if mouse.x >=136 and mouse.x <= 138 then -- atk clicked
      game.selectBar["x"] = 134
      game.selectBar["y"] = 6
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      game.selectBar["x"] = 138
      game.selectBar["y"] = 6
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      game.selectBar["x"] = 142
      game.selectBar["y"] = 6
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      game.selectBar["x"] = 146
      game.selectBar["y"] = 6
      game.selectBar["width"] = 5
    end
    if mouse.x ==152 then -- * clicked for reset
      game.selectBar["x"] = 150
      game.selectBar["y"] = 6
      game.selectBar["width"] = 3
    end
    if mouse.x ==155 then -- % clicked for random
      game.selectBar["x"] = 153
      game.selectBar["y"] = 6
      game.selectBar["width"] = 3
    end
  end

  -- D Envelope
  if mouse.x >= 136 and mouse.x <= 155 and mouse.y == 8 then
    if mouse.x >=136 and mouse.x <= 138 then -- atk clicked
      game.selectBar["x"] = 134
      game.selectBar["y"] = 7
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      game.selectBar["x"] = 138
      game.selectBar["y"] = 7
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      game.selectBar["x"] = 142
      game.selectBar["y"] = 7
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      game.selectBar["x"] = 146
      game.selectBar["y"] = 7
      game.selectBar["width"] = 5
    end
    if mouse.x ==152 then -- * clicked for reset
      game.selectBar["x"] = 150
      game.selectBar["y"] = 7
      game.selectBar["width"] = 3
    end
    if mouse.x ==155 then -- % clicked for random
      game.selectBar["x"] = 153
      game.selectBar["y"] = 7
      game.selectBar["width"] = 3
    end
  end

  -- E Envelope
  if mouse.x >= 136 and mouse.x <= 155 and mouse.y == 9 then
    if mouse.x >=136 and mouse.x <= 138 then -- atk clicked
      game.selectBar["x"] = 134
      game.selectBar["y"] = 8
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      game.selectBar["x"] = 138
      game.selectBar["y"] = 8
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      game.selectBar["x"] = 142
      game.selectBar["y"] = 8
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      game.selectBar["x"] = 146
      game.selectBar["y"] = 8
      game.selectBar["width"] = 5
    end
    if mouse.x ==152 then -- * clicked for reset
      game.selectBar["x"] = 150
      game.selectBar["y"] = 8
      game.selectBar["width"] = 3
    end
    if mouse.x ==155 then -- % clicked for random
      game.selectBar["x"] = 153
      game.selectBar["y"] = 8
      game.selectBar["width"] = 3
    end
  end


  -- A Volume
  if mouse.x >= 94 and mouse.x <= 110 and mouse.y == 5 then
      game.selectBar["x"] = 92
      game.selectBar["y"] = 4
      game.selectBar["width"] = 19
      SML.volume[game.selected["pattern"]][1] = (mouse.x-94)*8
  end

  -- B Volume
  if mouse.x >= 94 and mouse.x <= 110 and mouse.y == 6 then
      game.selectBar["x"] = 92
      game.selectBar["y"] = 5
      game.selectBar["width"] = 19
      SML.volume[game.selected["pattern"]][2] = (mouse.x-94)*8
  end

  -- C Volume
  if mouse.x >= 94 and mouse.x <= 110 and mouse.y == 7 then
      game.selectBar["x"] = 92
      game.selectBar["y"] = 6
      game.selectBar["width"] = 19
  end

  -- D Volume
  if mouse.x >= 94 and mouse.x <= 110 and mouse.y == 8 then
      game.selectBar["x"] = 92
      game.selectBar["y"] = 7
      game.selectBar["width"] = 19
      SML.volume[game.selected["pattern"]][4] = (mouse.x-94)*8
  end

  -- E Volume
  if mouse.x >= 94 and mouse.x <= 110 and mouse.y == 9 then
      game.selectBar["x"] = 92
      game.selectBar["y"] = 8
      game.selectBar["width"] = 19
      SML.volume[game.selected["pattern"]][5] = (mouse.x-94)*8
  end


  -- A Tone setting
  if mouse.x >= 114 and mouse.x <= 132 and mouse.y == 5 then
    if mouse.x >= 114 and mouse.x <= 117 then -- thin clicked
      game.selectBar["x"] = 112
      game.selectBar["y"] = 4
      game.selectBar["width"] = 6
    end
    if mouse.x >= 119 and mouse.x <= 121 then -- fat clicked
      game.selectBar["x"] = 117
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
    end
    if mouse.x >= 123 and mouse.x <= 128 then -- smooth clicked
      game.selectBar["x"] = 121
      game.selectBar["y"] = 4
      game.selectBar["width"] = 8
    end
    if mouse.x >= 130 and mouse.x <= 132 then -- taf clicked
      game.selectBar["x"] = 128
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
    end
  end

  -- B Tone setting
  if mouse.x >= 114 and mouse.x <= 132 and mouse.y == 6 then
    if mouse.x >= 114 and mouse.x <= 117 then -- thin clicked
      game.selectBar["x"] = 112
      game.selectBar["y"] = 5
      game.selectBar["width"] = 6
    end
    if mouse.x >= 119 and mouse.x <= 121 then -- fat clicked
      game.selectBar["x"] = 117
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
    end
    if mouse.x >= 123 and mouse.x <= 128 then -- smooth clicked
      game.selectBar["x"] = 121
      game.selectBar["y"] = 5
      game.selectBar["width"] = 8
    end
    if mouse.x >= 130 and mouse.x <= 132 then -- taf clicked
      game.selectBar["x"] = 128
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
    end
  end

  -- tempo setting
  if mouse.x >= 33 and mouse.x <= 35 and mouse.y == 9 then
      game.selectBar["x"] = 31
      game.selectBar["y"] = 8
      game.selectBar["width"] = 5
  end

  -- meta area detection
  if mouse.x <= 10 and mouse.y <= 11 then -- top left corner
    if mouse.y == 1 then -- Title clicked
      startDataEntry("str","Enter title of music", 66)
      game.selectBar["x"] = 0
      game.selectBar["y"] = 0
      game.selectBar["width"] = 10
    end
    if mouse.y == 2 then -- Composer clicked
      startDataEntry("str","Enter composer of music", 66)
      game.selectBar["x"] = 0
      game.selectBar["y"] = 1
      game.selectBar["width"] = 10
    end
    if mouse.y == 3 then -- Programmer clicked
      startDataEntry("str","Enter programmer of music", 66)
      game.selectBar["x"] = 0
      game.selectBar["y"] = 2
      game.selectBar["width"] = 10
    end
    if mouse.y == 4 then -- Copyright clicked
      startDataEntry("str","Enter copyright of music", 66)
      game.selectBar["x"] = 0
      game.selectBar["y"] = 3
      game.selectBar["width"] = 10
    end
    if mouse.y == 5 then -- Melody clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 4
      game.selectBar["width"] = 10
    end
    if mouse.y == 6 then -- Harmony 1 clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 5
      game.selectBar["width"] = 10
    end
    if mouse.y == 7 then -- Harmony 2 clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 6
      game.selectBar["width"] = 10
    end
    if mouse.y == 8 then -- Bass clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 7
      game.selectBar["width"] = 10
    end
    if mouse.y == 9 then  -- Rhythnm clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 8
      game.selectBar["width"] = 10
    end
    if mouse.y == 11 then -- Sequence clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 10
      game.selectBar["width"] = 10
    end
  end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
end

