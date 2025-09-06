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

-- to-da
-- test using png images to store music data
-- https://love2d.org/wiki/ImageData:getPixel
-- https://love2d.org/wiki/ImageData:setPixel

love.filesystem.setIdentity("niceNESs") -- for R36S file system compatibility
love.mouse.setVisible( true ) -- make mouse cursor invis, use bitmap cursor
love.graphics.setDefaultFilter("nearest", "nearest") -- for nearest neighbour, pixelart style
love.keyboard.setKeyRepeat(false) -- disallows held down key to repeat

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
  ["x"]     = 161,  -- set to off screen when nothing selected
  ["y"]     = 46,   -- set to off screen when nothing selected
  ["width"] = 0,
}
game.selected = {
  ["pattern"] = "a",  -- current selected pattern : a..z
  ["section"] = "about", -- "about", "melody", "harmony1", "harmony2", "bass", "rhythm", "pattern", "sequence"
  ["noteNum"] = 0, -- 0 = nil, normal range 1..19 , middle = 8, when 1 y=30, when 19 y=12, =32-y
}
game.inputData = ""   -- string to cache data captured from keyboard
game.inputPrompt = "" -- prompt for data entry
game.dataType = ""    -- can be "int" "str"
game.dataLength = 0   -- max length of data input

-- game secrets
game.debug1 = ""
game.debug2 = ""
game.debug3 = ""
game.debug4 = ""

-- detect system OS
game.os = love.system.getOS() -- "OS X", "Windows", "Linux", "Android" or "iOS", "Web"
if love.filesystem.getUserDirectory( ) == "/home/ark/" then
	game.os = "R36S"
elseif love.system.getOS() == "OS X" then
  game.os = "Mac"
end
print("systemOS: "..game.os)


-- check / create file directories

---function for savedata directories
---@param dirname string
function mkdir(dirname)
  if love.filesystem.getInfo(dirname) == nil then
    if game.os == "R36S" then
      os.execute("mkdir " .. love.filesystem.getSaveDirectory()) -- OS creation
      os.execute("mkdir " .. love.filesystem.getSaveDirectory() .. "//" .. dirname)
      print("R36S: created directory - " .. dirname)
    elseif game.os ~= "Web" then
      love.filesystem.createDirectory(dirname)
      print("Created directory - " .. dirname)
      local success = love.filesystem.remove( dirname .. "/.DS_Store" ) -- cleanup for Mac
      if success then
        print("DS_Store removed from " .. dirname)
      else
        print("No files removed from " .. dirname)
      end
    end
  end
end

mkdir("mmldata")
mkdir("music")
mkdir("smldata")
mkdir("cache")
mkdir("autosave")


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

-- Bass 4 numbers
SML.bass4num = {
  ["a"] = {0,0,0,0},
  ["b"] = {0,0,0,0},
  ["c"] = {0,0,0,0},
  ["d"] = {0,0,0,0},
  ["e"] = {0,0,0,0},
  ["f"] = {0,0,0,0},
  ["g"] = {0,0,0,0},
  ["h"] = {0,0,0,0},
  ["i"] = {0,0,0,0},
  ["j"] = {0,0,0,0},
  ["k"] = {0,0,0,0},
  ["l"] = {0,0,0,0},
  ["m"] = {0,0,0,0},
  ["n"] = {0,0,0,0},
  ["o"] = {0,0,0,0},
  ["p"] = {0,0,0,0},
  ["q"] = {0,0,0,0},
  ["r"] = {0,0,0,0},
  ["s"] = {0,0,0,0},
  ["t"] = {0,0,0,0},
  ["u"] = {0,0,0,0},
  ["v"] = {0,0,0,0},
  ["w"] = {0,0,0,0},
  ["x"] = {0,0,0,0},
  ["y"] = {0,0,0,0},
  ["z"] = {0,0,0,0},
}

-- tables to store monophonic noteNum entries by mouse
SML.melodyTrack = {}
SML.harmony1Track = {}
SML.harmony2Track = {}
SML.bassTrack = {}
for i = 1,128 do
  SML.melodyTrack[i]   = 0 -- set to nil equivalent
  SML.harmony1Track[i] = 0 -- set to nil equivalent
  SML.harmony2Track[i] = 0 -- set to nil equivalent
end
for i = 1,32 do
  SML.bassTrack[i] = 0 -- set to nil equivalent
end

SML.melodyTrackString = {
  ["a"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["b"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["c"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["d"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["e"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["f"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["g"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["h"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["i"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["j"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["k"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["l"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["m"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["n"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["o"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["p"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["q"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["r"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["s"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["t"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["u"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["v"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["w"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["x"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["y"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["z"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
}

SML.harmony1TrackString = {
  ["a"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["b"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["c"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["d"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["e"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["f"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["g"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["h"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["i"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["j"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["k"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["l"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["m"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["n"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["o"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["p"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["q"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["r"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["s"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["t"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["u"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["v"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["w"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["x"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["y"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["z"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
}

SML.harmony2TrackString = {
  ["a"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["b"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["c"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["d"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["e"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["f"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["g"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["h"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["i"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["j"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["k"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["l"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["m"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["n"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["o"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["p"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["q"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["r"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["s"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["t"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["u"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["v"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["w"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["x"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["y"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["z"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
}

SML.bassTrackString = {
  ["a"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["b"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["c"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["d"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["e"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["f"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["g"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["h"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["i"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["j"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["k"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["l"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["m"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["n"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["o"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["p"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["q"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["r"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["s"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["t"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["u"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["v"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["w"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["x"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["y"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
  ["z"] = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
}


--[[
Create a 32x1 pixel transparent-to-white gradient drawable image.

ImageData:setPixel( x, y, r, g, b, a )
r, g, b, a = ImageData:getPixel( x, y )


data = love.image.newImageData(32,1)
for i=0, 31 do   -- remember: start at 0
   data:setPixel(i, 0, 1, 1, 1, i / 31)
end
img = love.graphics.newImage(data)


local imgData = love.image.newImageData(128,19) -- 4 bars of 32, 19 notes
for i = 0,18 do -- columns
  for j = 0,127 do -- rows
    imgData:setPixel(j, i, 1, 1, 1, 1) -- rows, columns, r, g, b, a
  end
end
SML.melodyData = {
  ["a"] = love.graphics.newImage(imgData),
}

]]



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

---update all tracks with selected pattern data
---@param fromPattern char alphabet of pattern to copy data from
function updateTracks(fromPattern)
  for i = 1,128 do
    SML.melodyTrack[i] = string.byte(string.sub(SML.melodyTrackString[fromPattern],i,i))-64 -- convert from char to noteNum
    SML.harmony1Track[i] = string.byte(string.sub(SML.harmony1TrackString[fromPattern],i,i))-64 -- convert from char to noteNum
    SML.harmony2Track[i] = string.byte(string.sub(SML.harmony2TrackString[fromPattern],i,i))-64 -- convert from char to noteNum
  end
  for i = 1,32 do
    SML.bassTrack[i] = string.byte(string.sub(SML.bassTrackString[fromPattern],i,i))-64 -- convert from char to noteNum
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
  bassLeftPanel    = json.decode(love.filesystem.read("xtui/0-bass-leftpanel.xtui"))

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

  -- highlight current selected pattern (bottom layer)
  love.graphics.setColor(color.blue)
  local patternX = 11 + ((string.byte(game.selected["pattern"])-97)*2)
  love.graphics.rectangle("fill",FONT_WIDTH*patternX,FONT_HEIGHT*9,FONT_WIDTH*3,FONT_HEIGHT)

  -- draw note number highlight if 33,12 .. 160,30
  -- for sections: melody harmony1 harmony2
  if (mouse.x >= 33 and mouse.x <= 160) and (mouse.y >= 12 and mouse.y <= 30) then
    if game.selected["section"]=="melody" or game.selected["section"]=="harmony1" or
    game.selected["section"]=="harmony2" then
      love.graphics.setColor(color.brightblue)
      love.graphics.rectangle("fill",FONT_WIDTH*29,FONT_HEIGHT*(mouse.y-1),FONT_WIDTH*3,FONT_HEIGHT)
      game.selected["noteNum"]=31-mouse.y
    end
  end
  -- draw note number highlight if 33,12 .. 64,30
  -- for sections: bass
  if (mouse.x >= 33 and mouse.x <= 64) and (mouse.y >= 12 and mouse.y <= 30) then
    if game.selected["section"]=="bass" then
      love.graphics.setColor(color.brightblue)
      love.graphics.rectangle("fill",FONT_WIDTH*29,FONT_HEIGHT*(mouse.y-1),FONT_WIDTH*3,FONT_HEIGHT)
      game.selected["noteNum"]=31-mouse.y
    end
  end


  -- draw xtui stuff
  love.graphics.setFont(monoFont)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(color.white)
  love.graphics.print(metaSections,0,0) -- instruments panel

  -- manual draw for new function Name Patterns
  love.graphics.setColor(color.cyan)
  love.graphics.print("(".. SML.patternName[game.selected["pattern"]] ..")",FONT_WIDTH*65,FONT_HEIGHT*9)

  -- manual draw for [copy previous pattern's settings] 92,10 (only for patterns after [a])
  if string.byte(game.selected["pattern"]) >97 then
    love.graphics.setColor(color.cyan)
    love.graphics.print("[copy previous pattern settings]",FONT_WIDTH*91,FONT_HEIGHT*9)
  end

  -- draw for all sections
  love.graphics.setColor(color.white)
  love.graphics.print(instrumentsPanel,1280/2,0) -- instruments panel
  love.graphics.print(functionKeys,1280/2,0) -- function keys help
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


  -- draw for "about" section
  if game.selected["section"] == "about" then
    love.graphics.setColor(color.white)
    love.graphics.print(nicenessLogo,FONT_WIDTH*(80/2),FONT_HEIGHT*13) -- niceNESs logo
  end

  -- update data for music notes
  SML.melodyTrackString[game.selected["pattern"]] = ""
  SML.harmony1TrackString[game.selected["pattern"]] = ""
  SML.harmony2TrackString[game.selected["pattern"]] = ""
  SML.bassTrackString[game.selected["pattern"]] = ""
  for i = 1,128 do
    -- add 64 to noteNum to make it a printable char: A..Z
    SML.melodyTrackString[game.selected["pattern"]] = SML.melodyTrackString[game.selected["pattern"]] .. string.char(64+SML.melodyTrack[i])
    SML.harmony1TrackString[game.selected["pattern"]] = SML.harmony1TrackString[game.selected["pattern"]] .. string.char(64+SML.harmony1Track[i])
    SML.harmony2TrackString[game.selected["pattern"]] = SML.harmony2TrackString[game.selected["pattern"]] .. string.char(64+SML.harmony2Track[i])
  end
  for i = 1,32 do
    -- add 64 to noteNum to make it a printable char: A..Z
    SML.bassTrackString[game.selected["pattern"]] = SML.bassTrackString[game.selected["pattern"]] .. string.char(64+SML.bassTrack[i])
  end

  -- draw for "melody" section
  if game.selected["section"] == "melody" then
    love.graphics.setColor(color.white)
    love.graphics.print(rollMarkers,FONT_WIDTH*29,FONT_HEIGHT*11) -- piano roll note markers
    love.graphics.print(musicBars,FONT_WIDTH*32,FONT_HEIGHT*11) -- 1st music bar
    love.graphics.print(musicBars,FONT_WIDTH*64,FONT_HEIGHT*11) -- 2nd music bar
    love.graphics.print(musicBars,FONT_WIDTH*96,FONT_HEIGHT*11) -- 3rd music bar
    love.graphics.print(musicBars,FONT_WIDTH*128,FONT_HEIGHT*11) -- 4th music bar

    -- draw melodyTrack notes
    love.graphics.setColor(color.brightgreen)
    for i = 1,128 do
      local charNum = string.byte(string.sub(SML.melodyTrackString[game.selected["pattern"]],i,i))
      if charNum > 64 then
        love.graphics.print("█",FONT_WIDTH*(31+i),FONT_HEIGHT*(94-charNum))
      end
    end
  end

  -- draw for "harmony1" section
  if game.selected["section"] == "harmony1" then
    love.graphics.setColor(color.white)
    love.graphics.print(rollMarkers,FONT_WIDTH*29,FONT_HEIGHT*11) -- piano roll note markers
    love.graphics.print(musicBars,FONT_WIDTH*32,FONT_HEIGHT*11) -- 1st music bar
    love.graphics.print(musicBars,FONT_WIDTH*64,FONT_HEIGHT*11) -- 2nd music bar
    love.graphics.print(musicBars,FONT_WIDTH*96,FONT_HEIGHT*11) -- 3rd music bar
    love.graphics.print(musicBars,FONT_WIDTH*128,FONT_HEIGHT*11) -- 4th music bar

    -- draw harmony1Track notes
    love.graphics.setColor(color.brightyellow)
    for i = 1,128 do
      local charNum = string.byte(string.sub(SML.harmony1TrackString[game.selected["pattern"]],i,i))
      if charNum > 64 then
        love.graphics.print("█",FONT_WIDTH*(31+i),FONT_HEIGHT*(94-charNum))
      end
    end
  end

  -- draw for "harmony2" section
  if game.selected["section"] == "harmony2" then
    love.graphics.setColor(color.white)
    love.graphics.print(rollMarkers,FONT_WIDTH*29,FONT_HEIGHT*11) -- piano roll note markers
    love.graphics.print(musicBars,FONT_WIDTH*32,FONT_HEIGHT*11) -- 1st music bar
    love.graphics.print(musicBars,FONT_WIDTH*64,FONT_HEIGHT*11) -- 2nd music bar
    love.graphics.print(musicBars,FONT_WIDTH*96,FONT_HEIGHT*11) -- 3rd music bar
    love.graphics.print(musicBars,FONT_WIDTH*128,FONT_HEIGHT*11) -- 4th music bar

    -- draw harmony2Track notes
    love.graphics.setColor(color.brightred)
    for i = 1,128 do
      local charNum = string.byte(string.sub(SML.harmony2TrackString[game.selected["pattern"]],i,i))
      if charNum > 64 then
        love.graphics.print("█",FONT_WIDTH*(31+i),FONT_HEIGHT*(94-charNum))
      end
    end
  end

  -- draw for "bass" section
  if game.selected["section"] == "bass" then
    love.graphics.setColor(color.white)
    love.graphics.print(rollMarkers,FONT_WIDTH*29,FONT_HEIGHT*11) -- piano roll note markers
    love.graphics.print(musicBars,FONT_WIDTH*32,FONT_HEIGHT*11) -- 1st music bar
    love.graphics.print(bassLeftPanel,FONT_WIDTH*0,FONT_HEIGHT*11)
    -- manual patching of xtui
    love.graphics.setColor(color.green)
    love.graphics.print("maller number, lower note",FONT_WIDTH*1,FONT_HEIGHT*27)

    -- draw bassTrack notes
    love.graphics.setColor(color.brightmagenta)
    for i = 1,32 do
      local charNum = string.byte(string.sub(SML.bassTrackString[game.selected["pattern"]],i,i))
      if charNum > 64 then
        love.graphics.print("█",FONT_WIDTH*(31+i),FONT_HEIGHT*(94-charNum))
      end
    end
  end

  -- draw for "rhythm" section
  if game.selected["section"] == "rhythm" then
    love.graphics.setColor(color.white)
    love.graphics.print(rollMarkers,FONT_WIDTH*29,FONT_HEIGHT*11) -- piano roll note markers
    love.graphics.print(musicBars,FONT_WIDTH*32,FONT_HEIGHT*11) -- 1st music bar
  end

  -- draw for "sequence" section
  if game.selected["section"] == "sequence" then
    love.graphics.setColor(color.white)
  end

  -- draw status bar
  love.graphics.setColor(color.white)
  game.statusBar = game.name .. " " .. game.version .. " " .. game.edition .. " " .. game.os .. " | "
  love.graphics.print(game.statusBar, FONT_WIDTH*1, FONT_HEIGHT*44)


  -- debug window (viewable only on fullscreen, tested on 1440x900)
  -- debug prints from FONT_HEIGHT*46 to 49
  love.graphics.setColor(color.red)
  love.graphics.print("--[ Debug Section ]-",FONT_WIDTH*0,FONT_HEIGHT*45)
  for i = 20,159 do
    love.graphics.print("-",FONT_WIDTH*i,FONT_HEIGHT*45)
  end
  -- update debug info
  game.debug1 = "mouse: "
  game.debug1 = game.debug1 .. string.format("%3d",mouse.x) .. "," .. string.format("%2d",mouse.y) .. " | "
  game.debug1 = game.debug1 .. "select XY: "
  game.debug1 = game.debug1 .. string.format("%3d",game.selectBar["x"]) .. "," .. string.format("%2d",game.selectBar["y"]) .. " | "
  game.debug1 = game.debug1 .. "section: "
  game.debug1 = game.debug1 .. string.format("%-8s",game.selected["section"]) .. " | "
  game.debug1 = game.debug1 .. "pattern: " .. game.selected["pattern"] .. " | "
  game.debug1 = game.debug1 .. "notenum: " .. string.format("%2d",game.selected["noteNum"]) .. " | "
  game.debug2 = game.inputPrompt .. ": " .. game.inputData .. " | "
  if game.selected["section"] == "melody" then
    game.debug3 = "melodyTrack :" .. SML.melodyTrackString[game.selected["pattern"]]
  elseif game.selected["section"] == "harmony1" then
    game.debug3 = "harmony1Track :" .. SML.harmony1TrackString[game.selected["pattern"]]
  elseif game.selected["section"] == "harmony2" then
    game.debug3 = "harmony2Track :" .. SML.harmony2TrackString[game.selected["pattern"]]
  elseif game.selected["section"] == "bass" then
    game.debug3 = "bassTrack :" .. SML.bassTrackString[game.selected["pattern"]]
  else
    game.debug3 = ""
  end
  game.debug4 = ""
  -- draw debug info
  love.graphics.setColor(color.yellow)
  love.graphics.print(game.debug1,FONT_WIDTH*0,FONT_HEIGHT*46)
  love.graphics.print(game.debug2,FONT_WIDTH*0,FONT_HEIGHT*47)
  love.graphics.print(game.debug3,FONT_WIDTH*0,FONT_HEIGHT*48)
  love.graphics.print(game.debug4,FONT_WIDTH*0,FONT_HEIGHT*49)

end

function love.update(dt)
  -- Your game update here

  -- convert mouse position to ansi text coordinates
  local mouse = {
    x = math.floor(love.mouse.getX()/8)+1,
    y = math.floor(love.mouse.getY()/16)+1
  }

  -- music notes data entry section [start]
  if love.mouse.isDown(1) then -- primary button down to enter notes
    -- Drawing notes in melody harmony1 harmony2 section
    if (mouse.x >= 33 and mouse.x <= 160) and (mouse.y >= 12 and mouse.y <= 30) then
      if game.selected["section"]=="melody" then
        SML.melodyTrack[mouse.x-32] = game.selected["noteNum"]
      end
      if game.selected["section"]=="harmony1" then
        SML.harmony1Track[mouse.x-32] = game.selected["noteNum"]
      end
      if game.selected["section"]=="harmony2" then
        SML.harmony2Track[mouse.x-32] = game.selected["noteNum"]
      end
    end

    -- Drawing notes in bass section
    if (mouse.x >= 33 and mouse.x <= 64) and (mouse.y >= 12 and mouse.y <= 30) then
      if game.selected["section"]=="bass" then
        SML.bassTrack[mouse.x-32] = game.selected["noteNum"]
      end
    end
  end

    if love.mouse.isDown(2) then -- secondary button down to erase notes
    -- Erasing notes in melody harmony1 harmony2 section
    if (mouse.x >= 33 and mouse.x <= 160) and (mouse.y >= 12 and mouse.y <= 30) then
      if game.selected["section"]=="melody" then
        SML.melodyTrack[mouse.x-32] = 0
      end
      if game.selected["section"]=="harmony1" then
        SML.harmony1Track[mouse.x-32] = 0
      end
      if game.selected["section"]=="harmony2" then
        SML.harmony2Track[mouse.x-32] = 0
      end
    end

    -- Erasing notes in bass section
    if (mouse.x >= 33 and mouse.x <= 64) and (mouse.y >= 12 and mouse.y <= 30) then
      if game.selected["section"]=="bass" then
        SML.bassTrack[mouse.x-32] = 0
      end
    end
  end

  -- music notes data entry section [end]


  -- Data Entry section [start]
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
  -- Data Entry section [end]

end

function love.keypressed(key, scancode, isrepeat)
  print("key:"..key.." scancode:"..scancode.." isrepeat:"..tostring(isrepeat))
  if key == "f10" and love.system.getOS() ~= "Web" then
    love.event.quit()
  end

  if key == "f1" then
    -- change section to "about" : the welcome screen
    game.selected["section"] = "about"
    game.selectBar["x"] = 161 -- out of screen
    game.selectBar["y"] = 46 -- out of screen
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
      updateTracks("a")
      game.selected["pattern"] = "a"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 15 then -- b clicked
      game.selectBar["x"] = 13
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("b")
      game.selected["pattern"] = "b"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 17 then -- c clicked
      game.selectBar["x"] = 15
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("c")
      game.selected["pattern"] = "c"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 19 then -- d clicked
      game.selectBar["x"] = 17
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("d")
      game.selected["pattern"] = "d"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 21 then -- e clicked
      game.selectBar["x"] = 19
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("e")
    game.selected["pattern"] = "e"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 23 then -- f clicked
      game.selectBar["x"] = 21
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("f")
      game.selected["pattern"] = "f"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 25 then -- g clicked
      game.selectBar["x"] = 23
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("g")
      game.selected["pattern"] = "g"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 27 then -- h clicked
      game.selectBar["x"] = 25
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("h")
      game.selected["pattern"] = "h"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 29 then -- i clicked
      game.selectBar["x"] = 27
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("i")
      game.selected["pattern"] = "i"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 31 then -- j clicked
      game.selectBar["x"] = 29
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("j")
      game.selected["pattern"] = "j"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 33 then -- k clicked
      game.selectBar["x"] = 31
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("k")
      game.selected["pattern"] = "k"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 35 then -- l clicked
      game.selectBar["x"] = 33
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("l")
      game.selected["pattern"] = "l"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 37 then -- m clicked
      game.selectBar["x"] = 35
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("m")
      game.selected["pattern"] = "m"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 39 then -- n clicked
      game.selectBar["x"] = 37
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("n")
      game.selected["pattern"] = "n"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 41 then -- o clicked
      game.selectBar["x"] = 39
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("o")
      game.selected["pattern"] = "o"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 43 then -- p clicked
      game.selectBar["x"] = 41
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("p")
      game.selected["pattern"] = "p"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 45 then -- q clicked
      game.selectBar["x"] = 43
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("q")
      game.selected["pattern"] = "q"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 47 then -- r clicked
      game.selectBar["x"] = 45
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("r")
      game.selected["pattern"] = "r"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 49 then -- s clicked
      game.selectBar["x"] = 47
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("s")
      game.selected["pattern"] = "s"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 51 then -- t clicked
      game.selectBar["x"] = 49
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("t")
      game.selected["pattern"] = "t"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 53 then -- u clicked
      game.selectBar["x"] = 51
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("u")
      game.selected["pattern"] = "u"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 55 then -- v clicked
      game.selectBar["x"] = 53
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("v")
      game.selected["pattern"] = "v"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 57 then -- w clicked
      game.selectBar["x"] = 55
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("w")
      game.selected["pattern"] = "w"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 59 then -- x clicked
      game.selectBar["x"] = 57
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("x")
      game.selected["pattern"] = "x"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 61 then -- y clicked
      game.selectBar["x"] = 59
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("y")
      game.selected["pattern"] = "y"
      game.selected["section"] = "pattern"
    end
    if mouse.x == 63 then -- z clicked
      game.selectBar["x"] = 61
      game.selectBar["y"] = 9
      game.selectBar["width"] = 3
      updateTracks("z")
      game.selected["pattern"] = "z"
      game.selected["section"] = "pattern"
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
      game.selected["section"] = "melody"
    end
    if mouse.y == 6 then -- Harmony 1 clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 5
      game.selectBar["width"] = 10
      game.selected["section"] = "harmony1"
    end
    if mouse.y == 7 then -- Harmony 2 clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 6
      game.selectBar["width"] = 10
      game.selected["section"] = "harmony2"
    end
    if mouse.y == 8 then -- Bass clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 7
      game.selectBar["width"] = 10
      game.selected["section"] = "bass"
    end
    if mouse.y == 9 then  -- Rhythnm clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 8
      game.selectBar["width"] = 10
      game.selected["section"] = "rhythm"
    end
    if mouse.y == 11 then -- Sequence clicked
      game.selectBar["x"] = 0
      game.selectBar["y"] = 10
      game.selectBar["width"] = 10
      game.selected["section"] = "sequence"
    end
  end

end

function love.touchpressed(id, x, y, dx, dy, pressure)
end

