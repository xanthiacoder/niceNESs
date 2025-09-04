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
  ["a"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["b"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["c"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["d"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["e"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["f"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["g"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["h"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["i"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["j"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["k"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["l"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["m"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["n"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["o"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["p"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["q"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["r"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["s"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["t"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["u"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["v"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["w"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["x"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["y"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
  ["z"] = {["A"] = {2,16,64,48}, ["B"] = {2,32,72,50}, ["C"] = {2,32,72,50}, ["D"] = {8,32,72,64}, ["E"] = {1,4,4,2}},
}

-- valid values are 0..3
SML.tone = {
  ["a"] = {["A"] = 0,["B"] = 0},
  ["b"] = {["A"] = 0,["B"] = 0},
  ["c"] = {["A"] = 0,["B"] = 0},
  ["d"] = {["A"] = 0,["B"] = 0},
  ["e"] = {["A"] = 0,["B"] = 0},
  ["f"] = {["A"] = 0,["B"] = 0},
  ["g"] = {["A"] = 0,["B"] = 0},
  ["h"] = {["A"] = 0,["B"] = 0},
  ["i"] = {["A"] = 0,["B"] = 0},
  ["j"] = {["A"] = 0,["B"] = 0},
  ["k"] = {["A"] = 0,["B"] = 0},
  ["l"] = {["A"] = 0,["B"] = 0},
  ["m"] = {["A"] = 0,["B"] = 0},
  ["n"] = {["A"] = 0,["B"] = 0},
  ["o"] = {["A"] = 0,["B"] = 0},
  ["p"] = {["A"] = 0,["B"] = 0},
  ["q"] = {["A"] = 0,["B"] = 0},
  ["r"] = {["A"] = 0,["B"] = 0},
  ["s"] = {["A"] = 0,["B"] = 0},
  ["t"] = {["A"] = 0,["B"] = 0},
  ["u"] = {["A"] = 0,["B"] = 0},
  ["v"] = {["A"] = 0,["B"] = 0},
  ["w"] = {["A"] = 0,["B"] = 0},
  ["x"] = {["A"] = 0,["B"] = 0},
  ["y"] = {["A"] = 0,["B"] = 0},
  ["z"] = {["A"] = 0,["B"] = 0},
}
-- Melody Instrument
SML.melody = {
  ["a"] = "A",
  ["b"] = "A",
  ["c"] = "A",
  ["d"] = "A",
  ["e"] = "A",
  ["f"] = "A",
  ["g"] = "A",
  ["h"] = "A",
  ["i"] = "A",
  ["j"] = "A",
  ["k"] = "A",
  ["l"] = "A",
  ["m"] = "A",
  ["n"] = "A",
  ["o"] = "A",
  ["p"] = "A",
  ["q"] = "A",
  ["r"] = "A",
  ["s"] = "A",
  ["t"] = "A",
  ["u"] = "A",
  ["v"] = "A",
  ["w"] = "A",
  ["x"] = "A",
  ["y"] = "A",
  ["z"] = "A",
}
-- Harmony 1 Instrument
SML.harmony1 = {
  ["a"] = "B",
  ["b"] = "B",
  ["c"] = "B",
  ["d"] = "B",
  ["e"] = "B",
  ["f"] = "B",
  ["g"] = "B",
  ["h"] = "B",
  ["i"] = "B",
  ["j"] = "B",
  ["k"] = "B",
  ["l"] = "B",
  ["m"] = "B",
  ["n"] = "B",
  ["o"] = "B",
  ["p"] = "B",
  ["q"] = "B",
  ["r"] = "B",
  ["s"] = "B",
  ["t"] = "B",
  ["u"] = "B",
  ["v"] = "B",
  ["w"] = "B",
  ["x"] = "B",
  ["y"] = "B",
  ["z"] = "B",
}
-- Harmony 2 Instrument
SML.harmony2 = {
  ["a"] = "C",
  ["b"] = "C",
  ["c"] = "C",
  ["d"] = "C",
  ["e"] = "C",
  ["f"] = "C",
  ["g"] = "C",
  ["h"] = "C",
  ["i"] = "C",
  ["j"] = "C",
  ["k"] = "C",
  ["l"] = "C",
  ["m"] = "C",
  ["n"] = "C",
  ["o"] = "C",
  ["p"] = "C",
  ["q"] = "C",
  ["r"] = "C",
  ["s"] = "C",
  ["t"] = "C",
  ["u"] = "C",
  ["v"] = "C",
  ["w"] = "C",
  ["x"] = "C",
  ["y"] = "C",
  ["z"] = "C",
}
-- Bass Instrument
SML.bass = {
  ["a"] = "D",
  ["b"] = "D",
  ["c"] = "D",
  ["d"] = "D",
  ["e"] = "D",
  ["f"] = "D",
  ["g"] = "D",
  ["h"] = "D",
  ["i"] = "D",
  ["j"] = "D",
  ["k"] = "D",
  ["l"] = "D",
  ["m"] = "D",
  ["n"] = "D",
  ["o"] = "D",
  ["p"] = "D",
  ["q"] = "D",
  ["r"] = "D",
  ["s"] = "D",
  ["t"] = "D",
  ["u"] = "D",
  ["v"] = "D",
  ["w"] = "D",
  ["x"] = "D",
  ["y"] = "D",
  ["z"] = "D",
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

  -- highlight current selected pattern
  love.graphics.setColor(color.blue)
  local patternX = 11 + ((string.byte(game.selected["pattern"])-97)*2)
  love.graphics.rectangle("fill",FONT_WIDTH*patternX,FONT_HEIGHT*9,FONT_WIDTH*3,FONT_HEIGHT)

  -- draw xtui stuff
    love.graphics.setFont(monoFont)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(color.white)
--    love.graphics.print(nicenessLogo,FONT_WIDTH*80,FONT_HEIGHT*32) -- test drawing logo from xtui
    love.graphics.print(metaSections,0,0) -- instruments panel

    -- manual draw for new function Name Patterns
    love.graphics.setColor(color.cyan)
    love.graphics.print("(".. SML.patternName[game.selected["pattern"]] ..")",FONT_WIDTH*65,FONT_HEIGHT*9)

    -- manual draw for [copy previous pattern's settings] 92,10 (only for patterns after [a])
    if string.byte(game.selected["pattern"]) >97 then
      love.graphics.setColor(color.cyan)
      love.graphics.print("[copy previous pattern settings]",FONT_WIDTH*91,FONT_HEIGHT*9)
    end

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


  -- draw current pattern's Instrument assignments
  -- A = 65, B = 66, C = 67, D = 68
  local melodyX = (string.byte(SML.melody[game.selected["pattern"]])-64)+(string.byte(SML.melody[game.selected["pattern"]])-65)
  local harmony1X = (string.byte(SML.harmony1[game.selected["pattern"]])-64)+(string.byte(SML.harmony1[game.selected["pattern"]])-65)
  local harmony2X = (string.byte(SML.harmony2[game.selected["pattern"]])-64)+(string.byte(SML.harmony2[game.selected["pattern"]])-65)
  local bassX = (string.byte(SML.bass[game.selected["pattern"]])-64)+(string.byte(SML.bass[game.selected["pattern"]])-65)

  love.graphics.setColor(color.brightcyan)
  love.graphics.print(SML.melody[game.selected["pattern"]],FONT_WIDTH*(11+melodyX),FONT_HEIGHT*4)
  love.graphics.print(SML.harmony1[game.selected["pattern"]],FONT_WIDTH*(11+harmony1X),FONT_HEIGHT*5)
  love.graphics.print(SML.harmony2[game.selected["pattern"]],FONT_WIDTH*(11+harmony2X),FONT_HEIGHT*6)
  love.graphics.print(SML.bass[game.selected["pattern"]],FONT_WIDTH*(11+bassX),FONT_HEIGHT*7)


  -- draw current pattern's tempo
  love.graphics.setColor(color.brightcyan)
  love.graphics.print(SML.tempo[game.selected["pattern"]],FONT_WIDTH*32,FONT_HEIGHT*8)

  -- draw current pattern's volume levels
  love.graphics.setColor(color.brightcyan)
  love.graphics.rectangle("fill",FONT_WIDTH*94,(FONT_HEIGHT*4)+4,FONT_WIDTH*(SML.volume[game.selected["pattern"]][1]/8),FONT_HEIGHT/2)
  love.graphics.rectangle("fill",FONT_WIDTH*94,(FONT_HEIGHT*5)+4,FONT_WIDTH*(SML.volume[game.selected["pattern"]][2]/8),FONT_HEIGHT/2)
  love.graphics.rectangle("fill",FONT_WIDTH*94,(FONT_HEIGHT*7)+4,FONT_WIDTH*(SML.volume[game.selected["pattern"]][4]/8),FONT_HEIGHT/2)
  love.graphics.rectangle("fill",FONT_WIDTH*94,(FONT_HEIGHT*8)+4,FONT_WIDTH*(SML.volume[game.selected["pattern"]][5]/8),FONT_HEIGHT/2)
  if SML.volume[game.selected["pattern"]][3] == 1 then
    love.graphics.print("on",FONT_WIDTH*103,FONT_HEIGHT*6)
  else
    love.graphics.print("off",FONT_WIDTH*97,FONT_HEIGHT*6)
  end

  -- draw current pattern's instrument tones (0..3, thin fat smooth taf)
  love.graphics.setColor(color.brightcyan)
  if SML.tone[game.selected["pattern"]]["A"] == 0 then
    love.graphics.print("thin",FONT_WIDTH*113,FONT_HEIGHT*4)
  elseif SML.tone[game.selected["pattern"]]["A"] == 1 then
    love.graphics.print("fat",FONT_WIDTH*118,FONT_HEIGHT*4)
  elseif SML.tone[game.selected["pattern"]]["A"] == 2 then
    love.graphics.print("smooth",FONT_WIDTH*122,FONT_HEIGHT*4)
  elseif SML.tone[game.selected["pattern"]]["A"] == 3 then
    love.graphics.print("taf",FONT_WIDTH*129,FONT_HEIGHT*4)
  end
  if SML.tone[game.selected["pattern"]]["B"] == 0 then
    love.graphics.print("thin",FONT_WIDTH*113,FONT_HEIGHT*5)
  elseif SML.tone[game.selected["pattern"]]["B"] == 1 then
    love.graphics.print("fat",FONT_WIDTH*118,FONT_HEIGHT*5)
  elseif SML.tone[game.selected["pattern"]]["B"] == 2 then
    love.graphics.print("smooth",FONT_WIDTH*122,FONT_HEIGHT*5)
  elseif SML.tone[game.selected["pattern"]]["B"] == 3 then
    love.graphics.print("taf",FONT_WIDTH*129,FONT_HEIGHT*5)
  end


  -- draw current instrument envelopes
  love.graphics.setColor(color.brightcyan)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["A"][1],FONT_WIDTH*135,FONT_HEIGHT*4)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["A"][2],FONT_WIDTH*139,FONT_HEIGHT*4)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["A"][3],FONT_WIDTH*143,FONT_HEIGHT*4)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["A"][4],FONT_WIDTH*147,FONT_HEIGHT*4)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["B"][1],FONT_WIDTH*135,FONT_HEIGHT*5)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["B"][2],FONT_WIDTH*139,FONT_HEIGHT*5)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["B"][3],FONT_WIDTH*143,FONT_HEIGHT*5)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["B"][4],FONT_WIDTH*147,FONT_HEIGHT*5)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["C"][1],FONT_WIDTH*135,FONT_HEIGHT*6)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["C"][2],FONT_WIDTH*139,FONT_HEIGHT*6)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["C"][3],FONT_WIDTH*143,FONT_HEIGHT*6)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["C"][4],FONT_WIDTH*147,FONT_HEIGHT*6)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["D"][1],FONT_WIDTH*135,FONT_HEIGHT*7)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["D"][2],FONT_WIDTH*139,FONT_HEIGHT*7)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["D"][3],FONT_WIDTH*143,FONT_HEIGHT*7)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["D"][4],FONT_WIDTH*147,FONT_HEIGHT*7)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["E"][1],FONT_WIDTH*135,FONT_HEIGHT*8)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["E"][2],FONT_WIDTH*139,FONT_HEIGHT*8)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["E"][3],FONT_WIDTH*143,FONT_HEIGHT*8)
  love.graphics.print(SML.envelope[game.selected["pattern"]]["E"][4],FONT_WIDTH*147,FONT_HEIGHT*8)


  -- status bar
  love.graphics.setColor(color.white)
  game.statusBar = game.name .. " " .. game.version .. " " .. game.edition .. " | "
  game.statusBar = game.statusBar .. mouse.x .. "," .. mouse.y .. " | "
  game.statusBar = game.statusBar .. game.inputPrompt .. ": " .. game.inputData .. " | "
  love.graphics.print(game.statusBar, FONT_WIDTH*1, FONT_HEIGHT*44)

end

function love.update(dt)
  -- Your game update here

  -- A instrument : envelope 1 (atk) selected
  if (game.selectBar["x"] == 134 and game.selectBar["y"] == 4) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["A"][1] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- A instrument : envelope 2 (dec) selected
  if (game.selectBar["x"] == 138 and game.selectBar["y"] == 4) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["A"][2] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- A instrument : envelope 3 (sus) selected
  if (game.selectBar["x"] == 142 and game.selectBar["y"] == 4) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["A"][3] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- A instrument : envelope 4 (rel) selected
  if (game.selectBar["x"] == 146 and game.selectBar["y"] == 4) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["A"][4] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- B instrument : envelope 1 (atk) selected
  if (game.selectBar["x"] == 134 and game.selectBar["y"] == 5) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["B"][1] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- B instrument : envelope 2 (dec) selected
  if (game.selectBar["x"] == 138 and game.selectBar["y"] == 5) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["B"][2] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- B instrument : envelope 3 (sus) selected
  if (game.selectBar["x"] == 142 and game.selectBar["y"] == 5) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["B"][3] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- B instrument : envelope 4 (rel) selected
  if (game.selectBar["x"] == 146 and game.selectBar["y"] == 5) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["B"][4] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- C instrument : envelope 1 (atk) selected
  if (game.selectBar["x"] == 134 and game.selectBar["y"] == 6) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["C"][1] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- C instrument : envelope 2 (dec) selected
  if (game.selectBar["x"] == 138 and game.selectBar["y"] == 6) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["C"][2] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- C instrument : envelope 3 (sus) selected
  if (game.selectBar["x"] == 142 and game.selectBar["y"] == 6) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["C"][3] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- C instrument : envelope 4 (rel) selected
  if (game.selectBar["x"] == 146 and game.selectBar["y"] == 6) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["C"][4] = tonumber(game.inputData)
    end
    stopDataEntry()
  end


  -- D instrument : envelope 1 (atk) selected
  if (game.selectBar["x"] == 134 and game.selectBar["y"] == 7) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["D"][1] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- D instrument : envelope 2 (dec) selected
  if (game.selectBar["x"] == 138 and game.selectBar["y"] == 7) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["D"][2] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- D instrument : envelope 3 (sus) selected
  if (game.selectBar["x"] == 142 and game.selectBar["y"] == 7) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["D"][3] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- D instrument : envelope 4 (rel) selected
  if (game.selectBar["x"] == 146 and game.selectBar["y"] == 7) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["D"][4] = tonumber(game.inputData)
    end
    stopDataEntry()
  end


  -- E instrument : envelope 1 (atk) selected
  if (game.selectBar["x"] == 134 and game.selectBar["y"] == 8) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["E"][1] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- E instrument : envelope 2 (dec) selected
  if (game.selectBar["x"] == 138 and game.selectBar["y"] == 8) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["E"][2] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- E instrument : envelope 3 (sus) selected
  if (game.selectBar["x"] == 142 and game.selectBar["y"] == 8) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["E"][3] = tonumber(game.inputData)
    end
    stopDataEntry()
  end

  -- E instrument : envelope 4 (rel) selected
  if (game.selectBar["x"] == 146 and game.selectBar["y"] == 8) and game.dataEntry == false then
    if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
      SML.envelope[game.selected["pattern"]]["E"][4] = tonumber(game.inputData)
    end
    stopDataEntry()
  end


  -- name pattern selected
    if (game.selectBar["x"] == 64 and game.selectBar["y"] == 9) and game.dataEntry == false then
      SML.patternName[game.selected["pattern"]] = game.inputData
      stopDataEntry()
    end

  -- tempo selected
  if (game.selectBar["x"] == 31 and game.selectBar["y"] == 8) and game.dataEntry == false then
  if tonumber(game.inputData) ~= nil and tonumber(game.inputData) > 0 then
    SML.tempo[game.selected["pattern"]] = tonumber(game.inputData)
  end
    stopDataEntry()
  end

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
      startDataEntry("str","Enter a name for this pattern",12)
      game.selectBar["x"] = 64
      game.selectBar["y"] = 9
      game.selectBar["width"] = 16
      end
  end

  -- A Envelope
  if mouse.x >= 136 and mouse.x <= 155 and mouse.y == 5 then
    if mouse.x >=136 and mouse.x <= 138 then -- atk clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 134
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 138
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 142
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
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
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 134
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 138
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 142
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
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
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 134
      game.selectBar["y"] = 6
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 138
      game.selectBar["y"] = 6
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 142
      game.selectBar["y"] = 6
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
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
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 134
      game.selectBar["y"] = 7
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 138
      game.selectBar["y"] = 7
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 142
      game.selectBar["y"] = 7
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
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
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 134
      game.selectBar["y"] = 8
      game.selectBar["width"] = 5
    end
    if mouse.x >=140 and mouse.x <= 142 then -- dec clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 138
      game.selectBar["y"] = 8
      game.selectBar["width"] = 5
    end
    if mouse.x >=144 and mouse.x <= 146 then -- sus clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
      game.selectBar["x"] = 142
      game.selectBar["y"] = 8
      game.selectBar["width"] = 5
    end
    if mouse.x >=148 and mouse.x <= 150 then -- rel clicked
      startDataEntry("int","Enter a number from 1 to 999",3)
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

  -- C Volume : triangle volume can only be 0 or 1
  if mouse.x >= 94 and mouse.x <= 110 and mouse.y == 7 then
      game.selectBar["x"] = 92
      game.selectBar["y"] = 6
      game.selectBar["width"] = 19
      if mouse.x < 102 then
        SML.volume[game.selected["pattern"]][3] = 0
      else
        SML.volume[game.selected["pattern"]][3] = 1
      end
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

  -- [copy previous pattern settings] 92-123, 10, only pattern b..z
  if string.byte(game.selected["pattern"]) > 97 then
    if mouse.x >= 92 and mouse.x <= 123 and mouse.y == 10 then

      local i = 0

      local previousPattern = string.char(string.byte(game.selected["pattern"])-1)

      SML.tempo[game.selected["pattern"]] = SML.tempo[previousPattern]

      SML.volume[game.selected["pattern"]][1] = SML.volume[previousPattern][1]
      SML.volume[game.selected["pattern"]][2] = SML.volume[previousPattern][2]
      SML.volume[game.selected["pattern"]][3] = SML.volume[previousPattern][3]
      SML.volume[game.selected["pattern"]][4] = SML.volume[previousPattern][4]
      SML.volume[game.selected["pattern"]][5] = SML.volume[previousPattern][5]

      SML.tone[game.selected["pattern"]]["A"] = SML.tone[previousPattern]["A"]
      SML.tone[game.selected["pattern"]]["B"] = SML.tone[previousPattern]["B"]

      for i = 1,4 do
        SML.envelope[game.selected["pattern"]]["A"][i] = SML.envelope[previousPattern]["A"][i]
        SML.envelope[game.selected["pattern"]]["B"][i] = SML.envelope[previousPattern]["B"][i]
        SML.envelope[game.selected["pattern"]]["C"][i] = SML.envelope[previousPattern]["C"][i]
        SML.envelope[game.selected["pattern"]]["D"][i] = SML.envelope[previousPattern]["D"][i]
        SML.envelope[game.selected["pattern"]]["E"][i] = SML.envelope[previousPattern]["E"][i]
      end

    end
  end


  -- A Tone setting
  if mouse.x >= 114 and mouse.x <= 132 and mouse.y == 5 then
    if mouse.x >= 114 and mouse.x <= 117 then -- thin clicked
      game.selectBar["x"] = 112
      game.selectBar["y"] = 4
      game.selectBar["width"] = 6
      SML.tone[game.selected["pattern"]]["A"] = 0
    end
    if mouse.x >= 119 and mouse.x <= 121 then -- fat clicked
      game.selectBar["x"] = 117
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
      SML.tone[game.selected["pattern"]]["A"] = 1
    end
    if mouse.x >= 123 and mouse.x <= 128 then -- smooth clicked
      game.selectBar["x"] = 121
      game.selectBar["y"] = 4
      game.selectBar["width"] = 8
      SML.tone[game.selected["pattern"]]["A"] = 2
    end
    if mouse.x >= 130 and mouse.x <= 132 then -- taf clicked
      game.selectBar["x"] = 128
      game.selectBar["y"] = 4
      game.selectBar["width"] = 5
      SML.tone[game.selected["pattern"]]["A"] = 3
    end
  end

  -- B Tone setting
  if mouse.x >= 114 and mouse.x <= 132 and mouse.y == 6 then
    if mouse.x >= 114 and mouse.x <= 117 then -- thin clicked
      game.selectBar["x"] = 112
      game.selectBar["y"] = 5
      game.selectBar["width"] = 6
      SML.tone[game.selected["pattern"]]["B"] = 0
    end
    if mouse.x >= 119 and mouse.x <= 121 then -- fat clicked
      game.selectBar["x"] = 117
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
      SML.tone[game.selected["pattern"]]["B"] = 1
    end
    if mouse.x >= 123 and mouse.x <= 128 then -- smooth clicked
      game.selectBar["x"] = 121
      game.selectBar["y"] = 5
      game.selectBar["width"] = 8
      SML.tone[game.selected["pattern"]]["B"] = 2
    end
    if mouse.x >= 130 and mouse.x <= 132 then -- taf clicked
      game.selectBar["x"] = 128
      game.selectBar["y"] = 5
      game.selectBar["width"] = 5
      SML.tone[game.selected["pattern"]]["B"] = 3
    end
  end

  -- tempo setting
  if mouse.x >= 33 and mouse.x <= 35 and mouse.y == 9 then
      startDataEntry("int","Enter a number (eg 60 is slow, 120 is mid, 180 is fast)",3)
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

