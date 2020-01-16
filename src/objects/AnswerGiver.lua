
local Entity = require('src.Entity')
local Config = require('src.data.Config')
local PianoKey = require('src.objects.PianoKey')
local Theme = require('src.utils.Theme')

local MobileButton = require('src.objects.MobileButton')

---@class AnswerGiver : Entity
local AnswerGiver = Entity:extend()

function AnswerGiver:new(area, options)
    Entity.new(self, area, options)
    self.buttons = {}
    self:addFunction(Config.answerType)
end

function AnswerGiver:hide()
    if self.buttons then
        for _, button in ipairs(self.buttons) do
            self.timer:tween(Vars.transition.tween, button, {y = love.graphics.getHeight() + 20}, 'out-expo')
        end
    end
end

function AnswerGiver:addFunction(config)
    if config == "piano" then
        self:addPianoKeys(false)
    elseif config == "pianoWithNotes" then
        self:addPianoKeys(true)
    elseif config == "buttons" then
        self:addButtons()
    end
end

function AnswerGiver:addPianoKeys(showNote)
    local totalWidth = love.graphics.getWidth()
    local whiteKeyWidth = totalWidth / 7
    local height = Vars.pianoHeight
    local yPos = love.graphics.getHeight() - height

    local font = assets.fonts.Oswald(Vars.mobileButton.fontSize)
    for i = 1, 7 do
        self.buttons[#self.buttons+1] =  self.area:addentity(PianoKey, {
            x = (i-1) * whiteKeyWidth,
            y = yPos,
            height = height,
            width = whiteKeyWidth,
            callback = function(btn)
                btn.consumed = false
                if self.callback then self.callback( Vars.englishNotes[i]) end
            end,
            text = showNote and love.graphics.newText(font,Vars[Config.noteStyle][i]) or nil
        })
    end
    local blackKeys = {
        3 *whiteKeyWidth / 4,
        7 * whiteKeyWidth / 4,
        15 * whiteKeyWidth / 4,
        19 * whiteKeyWidth / 4,
        23 * whiteKeyWidth / 4
    }
    for _,v in ipairs(blackKeys) do
        self.buttons[#self.buttons+1] =  self.area:addentity(PianoKey, {
            x = v,
            y = yPos,
            height = 3 * height / 4,
            width = whiteKeyWidth / 2,
            backgroundColor = Theme.font:clone()
        })
    end
end

function AnswerGiver:addButtons()
    self.buttons = {}
    local size = Vars.mobileButton.fontSize
    local font = assets.fonts.Oswald(size)
    local letters = Vars[Config.noteStyle]

    local padding = Vars.mobileButton.padding
    local widths = math.floor((love.graphics.getWidth() / #letters) - padding)
    local totalSize = 0
    for i,v in ipairs(letters) do
        local text = love.graphics.newText(font, v)
        totalSize = totalSize + text:getWidth() + padding * 3
        local y = love.graphics.getHeight() - text:getHeight() - padding * 3
        self.buttons[#self.buttons+1] = self.area:addentity(MobileButton, {
            x = 5 + (widths + padding) * (i-1),
            y = y,
            width = widths,
            text = text,
            callback = function() if self.callback then self.callback( Vars.englishNotes[i]) end end
        })
    end
end

return AnswerGiver