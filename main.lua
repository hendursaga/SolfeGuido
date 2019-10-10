_G['assets'] = require('lib.cargo').init('res')

require "lib.tesound"
local i18n = require('lib.i18n')
local ScreenManager = require('lib.ScreenManager')
local Config = require('src.utils.Config')
local ScoreManager = require('src.utils.ScoreManager')
local Color = require('src.utils.Color')

--- BEGIN DEBUG
local debugGraph = require('lib.debugGraph')
local fpsGraph = nil
local memoryGraph = nil
--- END DEBUG


function love.load()
    math.randomseed(os.time())
    Config.parse()
    ScoreManager.init()
    ScoreManager.save()
    i18n.load(assets.lang)
    i18n.setLocale(Config.lang or 'en')

    _G['tr'] = function(data)
        return i18n.translate(string.lower(data), {default = data})
    end

    local screens = {
        PlayState = require('src.states.PlayState'),
        MenuState = require('src.states.MenuState'),
        PauseState = require('src.states.PauseState'),
        OptionsState  = require('src.states.OptionsState'),
        ScoreState = require('src.states.ScoreState'),
        CreditsState = require('src.states.CreditsState'),
        EndGameState = require('src.states.EndGameState'),
        HelpState = require('src.states.HelpState')
    }
    ScreenManager.init(screens, 'MenuState')

--- BEGIN DEBUG
    fpsGraph = debugGraph:new('fps', love.graphics.getWidth() - 200, 0 , 200);
    memoryGraph = debugGraph:new('mem', love.graphics.getWidth() - 200, 50, 200)
--- END DEBUG
end

function love.draw()
    ScreenManager.draw()
--- BEGIN DEBUG
    love.graphics.setColor(Color.black)
    fpsGraph:draw()
    memoryGraph:draw()
--- END DEBUG
end

function love.update(dt)
    TEsound.cleanup()
    ScreenManager.update(dt)
--- BEGIN DEBUG
    --require('lib.lurker').update()
    fpsGraph:update(dt)
    memoryGraph:update(dt)
--- END DEBUG
end

function love.mousemoved(x,y, _, _, istouch)
    if not istouch then
        ScreenManager.mousemoved(x, y)
    end
end

function love.mousepressed(x, y, button, istouch)
    if not istouch then
        ScreenManager.mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button, istouch)
    if not istouch then
        ScreenManager.mousereleased(x, y, button)
    end
end
love.keypressed = ScreenManager.keypressed
love.touchpressed = ScreenManager.touchpressed
love.touchmoved = ScreenManager.touchmoved
love.touchreleased = ScreenManager.touchreleased