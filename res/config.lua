
local lineHeight = 20
local titleSize = 40

local order = {'C', 'D','E','F','G','A','B'}

local notes = {'A1','B1'}

for i = 2,6 do
    for j = 1, #order do
        notes[#notes+1] = order[j] .. tostring(i)
    end
end


local config = {
    titleSize = titleSize,
    baseLine = titleSize + lineHeight * 2,
    userPreferences = {
        sound = {'on', 'off'},
        lang = {'en', 'fr'},
        noteStyle = {'en', 'it'},
        keySelect = {'gKey', 'fKey'},
        difficulty = {'1', '2', '3', '4', 'all'},
        answerType = {'default', 'letters', 'buttons'}
    },
    configSave = 'config.lua',
    lineSpace = 20,
    lineHeight = lineHeight,
    limitLine = 150,
    maxProgressSpeed = 100,
    letterOrder = {'s', 'd', 'f', 'g', 'h', 'j', 'k'},
    itNotes = {'do', 'ré', 'mi', 'fa', 'sol', 'la', 'si'},
    enNotes = {'c', 'd', 'e', 'f', 'g', 'a', 'b'},
    trialTime = 60,
    timeLoss = 2,
    stopWatch = {
        x = 15,
        y = 15,
        size = 20,
    },
    mobileButton = {
        fontSize = 30,
        padding = 10
    },
    score = {
        dataFormat = 'zlib',
        containerType = 'data',
        fileName = 'scores.bin',
        x = 50,
        y = 5,
        fontSize = 25
    },
    transition = {
        tween = 0.8,
        spacing = 0.01
    },
    gKey = {
        height = lineHeight * 7,
        xOrigin = 32,
        yOrigin = 132,
        x = 40,
        y = 0,
        image = 'GKey',
        lowestNote = 3,
        firstNote = 12,
        difficulties = {
            ['1'] = {4, 10},
            ['2'] = {11, 17},
            ['3'] = {14, 20},
            ['4'] = {0, 6},
            ['all'] = {0, 20}
        }
    },
    fKey = {
        height = lineHeight * 3,
        xOrigin = 21,
        yOrigin = 23,
        x = 30,
        y = lineHeight * 3,
        image = 'FKey',
        lowestNote = 5,
        difficulties = {
            ['1'] = {10, 16},
            ['2'] = {3, 9},
            ['3'] = {0, 6},
            ['4'] = {14, 20},
            ['all'] = {0, 20}
        }
    },
    note = {
        height = lineHeight * 4,
        xOrigin = 28,
        yOrigin = 184,
        image = 'note';
        padding = 10,
        distance = 50,
        fadeAway = 1.5
    }
}

config['notes'] = notes

return config