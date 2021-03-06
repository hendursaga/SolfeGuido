local Entity = require('src.Entity')
local class = require('lib.class')
local UIFactory = require('src.utils.UIFactory')
local lume = require('lib.lume')
local Theme = require('src.utils.Theme')

local BLOCKS = {
    ICONBUTTON = {'icon', 'size', 'x', 'y', 'height', 'color', 'callback', 'circled',
        'framed', 'centered', 'anchor', 'padding', 'name'},
    RADIOBUTTON = {'icon', 'image', 'text', 'x', 'y', 'value', 'isChecked', 'color',
        'callback', 'framed', 'padding', 'width', 'minWidth', 'centerImage'},
    TITLE = {'x', 'y', 'color', 'text', 'centered', 'framed', 'fontName', 'fontSize', 'font'},
    TEXTBUTTON = {'font', 'fontSize', 'icon', 'text', 'x', 'y', 'padding', 'color', 'callback', 'framed', 'centerText'},
    IMAGE = {'image', 'size', 'x', 'y', 'color'}
}

local ORIGINS = {
    left = function(options) return {x = options.fromPosition or -Vars.titleSize * 2}, 'x' end,
    right = function(options) return {x = options.fromPosition or love.graphics.getWidth()}, 'x' end,
    bottom = function(options) return {y = options.fromPosition or love.graphics.getHeight()}, 'y' end,
    top = function(options) return {y = options.fromPosition or -Vars.titleSize * 2}, 'y' end
}

local HIDING = {
    left = {x = -Vars.titleSize * 2, color = Theme.transparent},
    right = {x = love.graphics.getWidth() + 10, color = Theme.transparent},
    top = {y = -Vars.titleSize * 2, color = Theme.transparent},
    bottom = {y = love.graphics.getHeight(), color = Theme.transparent}
}

--- Used to create an object to describe
--- an transition
---@class TransitionBuilder
---@field private _elements table
local TransitionBuilder = class:extend()

function TransitionBuilder:new(uibuilder)
    self.uibuilder = uibuilder
    self._elements = {}
end

---@param name string
---@param options table
function TransitionBuilder:add(name, options)
    local optionsName = BLOCKS[name:upper()]
    local widgetOptions, key = ORIGINS[options.from](options)
    for _, v in ipairs(optionsName) do
        if not widgetOptions[v] then
            widgetOptions[v] = options[v] or self.uibuilder:getOption(v)
        end
    end
    local element = UIFactory['create' .. name](self.uibuilder.container, widgetOptions)
    local targetPosition = options.to
    if lume.isCallable(targetPosition) then
        targetPosition = targetPosition(element)
    end
    local widgetTarget = {[key] = targetPosition, color = options.toColor or Theme.font}
    self._elements[#self._elements+1] = {element = element, target = widgetTarget}
    self.uibuilder:addChild(options.from, element)
    return self
end

--- Creates the object describing the
--- transition and returns it
---@return TransitionBuilder
function TransitionBuilder:build()
    local ret = self._elements
    self._elements = nil
    return ret
end

---@class UIBuilder : Entity
---@field private _options table
---@field private _children table
local UIBuilder = Entity:extend()

--- Constructor
---@param container EntityContainer
---@param options table
function UIBuilder:new(container, options)
    Entity.new(self, container)
    self._options = options or {}
    self._children = {left = {}, right = {}, bottom = {}, top = {}}
end

--- Accessor to the given option
---if the option is a function, calls
--- the function and returns its return value
---@param key string
---@return any
function UIBuilder:getOption(key)
    local val = self._options[key]
    if lume.isCallable(val) then return val() end
    return val
end

--- Adds a child to the list of children of
--- the UIBuilder
---@param origin string
---@param child Entity
function UIBuilder:addChild(origin, child)
    local t = self._children[origin]
    t[#t+1] = child
    return child
end

--- Disposing of everything
function UIBuilder:dispose()
    self._children = nil
end

--- Starts to build an object
--- to represent a transition
---@return TransitionBuilder
function UIBuilder:createTransition()
    return TransitionBuilder(self)
end

--- Generates the object to transition
--- out all the widgets of the scene
---@return table
function UIBuilder:transitionOut()
    local result = {}
    for k, v in pairs(self._children) do
        local target = HIDING[k]
        for _, child in ipairs(v) do
            result[#result+1] = { element = child, target = target }
        end
    end
    return result
end

return UIBuilder