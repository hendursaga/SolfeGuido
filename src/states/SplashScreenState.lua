
local State = require('src.State')
local Config = require('src.data.Config')
local ScoreManager = require('src.data.ScoreManager')
local StatisticsManager = require('src.data.StatisticsManager')
local i18n = require('lib.i18n')
local ScreeManager = require('lib.ScreenManager')
local Theme = require('src.utils.Theme')
local Logger = require('lib.logger')
local lume = require('lib.lume')
local JinglePlayer = require('src.utils.JinglePlayer')

local StartupConfigState = require('src.states.StartupConfigState')
local Line = require('src.objects.Line')

--- Screen shown when first launching the app
--- loads all the assets in memory, then switches
--- to the menu
---@class SplashScreenState : State
---@field private coroutine number
---@field private totalLoading number
---@field private color Color
local SplashScreenState = State:extend()

local allStates = {
    PlayState = require('src.states.PlayState'),
    MenuState = require('src.states.MenuState'),
    PauseState = require('src.states.PauseState'),
    OptionsState  = require('src.states.OptionsState'),
    ScoreboardState = require('src.states.ScoreboardState'),
    CreditsState = require('src.states.CreditsState'),
    EndGameState = require('src.states.EndGameState'),
    PlaySelectState = require('src.states.PlaySelectState'),
    GamePrepareState = require('src.states.GamePrepareState'),
    CircleCloseState = require('src.states.CircleCloseState'),
    StatisticsState = require('src.states.StatisticsState'),
    NewVersionState = require('src.states.NewVersionState'),
    StartupConfigState = StartupConfigState
}

--- Constructor
function SplashScreenState:new()
    State.new(self)
    self.coroutine = nil
    self.totalLoading = 0
    self.color = Theme.font:clone()
end

--- Inherited method
function SplashScreenState:draw()
    State.draw(self)
    local middle = Vars.baseLine + Vars.lineHeight * 3
    local progress = love.graphics.getWidth() * (self.totalLoading / 100)

    love.graphics.setBackgroundColor(Theme.background)
    local font = love.graphics.getFont()
    local text = tostring(math.floor(self.totalLoading)) .. " %"
    local width = font:getWidth(text)
    local height = font:getHeight(text)
    local txtX = (love.graphics.getWidth() - width) / 2

    love.graphics.setColor(self.color)
    love.graphics.print(text, txtX, middle - height)

    love.graphics.setColor(Theme.font)
    love.graphics.setLineWidth(1)
    love.graphics.line(0, middle , progress, middle)
end

--- Create the coroutine that will load all the assets
--- the coroutine allows to load sequentially the assets
--- and avoid a freeze of the app
---@return number
function SplashScreenState:createCoroutine()
    return coroutine.create(function()
        math.randomseed(os.time())
        Logger.init(Vars.logs)
        _G['assets'] = require('lib.cargo').init('res', 98)
        ScoreManager.init()
        StatisticsManager.init()
        coroutine.yield(1)
        i18n.load(assets.lang)
        i18n.setLocale(Config.lang or 'en')
        -- Create the two main fonts
        assets.fonts.MarckScript(Vars.lineHeight)
        assets.fonts.MarckScript(Vars.titleSize)
        coroutine.yield(1)
        Config.updateSound()
    end)
end

--- Updates the current coroutine, if any
--- when the coroutine is finished, will trigger
--- the animation to enter the menu state,
--- this part can be quite critical as any problem
--- occuring will crash the app and is not solvable
function SplashScreenState:updateCoroutine()
    local success, progress = coroutine.resume(self.coroutine)
    if success then
        self.totalLoading = self.totalLoading + (progress or 0)
    else
        Logger.fatal('Failed to boot up :' .. progress)
        error("Loading failed, reason : " .. progress)
    end
    if coroutine.status(self.coroutine) == "dead" then
        self.coroutine = "done"
        JinglePlayer.play(assets.jingles.startup, self.timer)
        _G['tr'] = function(data, options)
            local vals = lume.merge(options or {default = data},{default = data})
            return i18n.translate(string.lower(data), vals)
        end
        self:displayLines()
    end
end

--- Updates the coroutine, or create it for the first time
---@param dt number
function SplashScreenState:update(dt)
    State.update(self, dt)
    if not self.coroutine then
        self.coroutine = self:createCoroutine()
    elseif self.coroutine ~= "done" then
        self:updateCoroutine()
    end
end

--- Starts the animation to show the lines
--- before going to the menu
function SplashScreenState:displayLines()
    local time = Vars.transition.tween * 4
    self.timer:tween(time, self, {color = Theme.transparent}, 'linear')
    local middle = Vars.baseLine
    for i = 1,5 do
        local ypos = middle + Vars.lineHeight * i
        local line = self:addEntity(Line, {
            x = 0,
            y = ypos,
            width = 0,
        })
        self.timer:tween(time, line, {width = love.graphics.getWidth()}, 'out-sine')
    end

    local line = self:addEntity(Line, {
        x = Vars.limitLine,
        y = middle + Vars.lineHeight,
        height = 0,
    })
    local hTarget = Vars.lineHeight * 4
    self.timer:tween(time, line, {height = hTarget}, 'out-sine', function()
        -- Load all states this time
        ScreeManager.init(allStates, 'MenuState')
        if Config.needsUserHelp() then
            local options = StartupConfigState.createOptions()
            for i = #options, 1, -1 do
                ScreeManager.push('StartupConfigState', i, 'right')
            end
        elseif StatisticsManager.newVersionAvailable then
            ScreeManager.push('NewVersionState')
            -- Save the new version to avoid showing the pop-up another time
            StatisticsManager.save()
        end
    end)
end

return SplashScreenState