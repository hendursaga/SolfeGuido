
local State = require('src.State')
local Graphics = require('src.utils.Graphics')
local Theme = require('src.utils.Theme')
local ScreenManager = require('lib.ScreenManager')

--- State to show the different tools used to create the
--- game, to give credit..
---@class CreditsState : State
local CreditsState = State:extend()

--- Capturing escape key to go back
--- to the menu
---@param key string
function CreditsState:keypressed(key)
    if key == "escape" then
        self:slideOut()
    else
        State.keypressed(self, key)
    end
end

--- Drawing the music bars first
function CreditsState:draw()
    Graphics.drawMusicBars()
    State.draw(self)
end

--- Slides back out to the menu state
---@param callback function
function CreditsState:slideOut(callback)
    callback = callback or function() ScreenManager.switch('MenuState') end
    self:transition(self.ui:transitionOut(), callback)
end

--- Create the UI
function CreditsState:init()
    local elements = self:startUI({
        fontSize = 2 * Vars.lineHeight / 3,
        fontName = 'Oswald',
        color = function() return Theme.transparent:clone() end
    })
        :createTransition()
            :add('Title', {
                from = 'top',
                to = 5,
                x = 0,
                centered = true,
                text = 'Credits',
                fontName = 'MarckScript',
                fontSize = Vars.titleSize
            })
            :add('IconButton', {
                from = 'bottom',
                to = love.graphics.getHeight() -Vars.titleSize - 5,
                x = 5,
                icon = 'Home',
                callback = function() self:slideOut() end
            })
            :add('Title', {
                from = 'left',
                fromPosition = -100,
                to = function(elem) return Vars.limitLine - elem:width() - 5 end,
                y = Vars.baseLine + Vars.lineHeight,
                text = 'made_with'
            })
            :add('Title',{
                from = 'left',
                fromPosition = -100,
                to = function(elem) return Vars.limitLine - elem:width() - 5 end,
                y = Vars.baseLine + Vars.lineHeight * 2,
                text = 'By'
            })
            :add('Title', {
                from = 'left',
                fromPosition = -100,
                to = function(elem) return Vars.limitLine - elem:width() - 5 end,
                y = Vars.baseLine + Vars.lineHeight * 3,
                text = 'Icons'
            })
            :add('Title', {
                from = 'left',
                fromPosition = -100,
                to = function(elem) return Vars.limitLine - elem:width() - 5 end,
                y = Vars.baseLine + Vars.lineHeight * 4,
                text = 'Sounds',
            })
            :add('Title', {
                from = 'right',
                to = Vars.limitLine + 5,
                y =  Vars.baseLine + Vars.lineHeight * 2,
                text = 'Azarias & ' .. tr('contributors')
            })
            :add('Title', {
                from = 'right',
                to = Vars.limitLine + 5,
                y = Vars.baseLine + Vars.lineHeight * 3,
                text = 'IconMoonApp'
            })
            :add('Title', {
                from = 'right',
                to = Vars.limitLine + 5,
                y = Vars.baseLine + Vars.lineHeight * 4,
                text = 'University of Iowa'
            })
            :add('Image', {
                from = 'right',
                to = Vars.limitLine + Vars.lineHeight / 2,
                y = Vars.baseLine + Vars.lineHeight * 1.5,
                size = Vars.lineHeight - 5,
                image = assets.images.loveIcon,
                toColor = Theme.white
            })
            :add('Title', {
                from = 'right',
                to = Vars.limitLine + Vars.lineHeight,
                y = Vars.baseLine + Vars.lineHeight,
                text = 'Löve2D'
            })
        :build()
    self:transition(elements)
end


return CreditsState