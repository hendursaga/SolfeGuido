

local Entity = require('src.entity')

---@class Note : Object
---@field public area PlayState
local Note = Entity:extend()


function Note:new(area, id, options)
    Note.super.new(self, area, id, options)
    self.y = self:noteToPosition(self.note)
    self.image = assets.images.note
    self.color = {0, 0, 0, 1}
    self.name = nil
end


--- The total width of a note
---@return number
function Note.width()
    local scale = assets.config.note.height / assets.images.note:getHeight()
    return assets.config.note.padding * 2 + scale * assets.images.note:getWidth()
end

---@param note number
---@return number
function Note:noteToPosition(note)
    local base = self.area:getBaseLine()
    return base - (note - 6) * (assets.config.lineHeight / 2)
end

function Note:correct()
    self.color = {0, 0.5, 0, 1}
    local totalTime = assets.config.note.fadeAway
    self.area.timer:tween(totalTime, self, {color = {0, 0.5, 0, 0}})
    self.area.timer:after(totalTime, function() self:dispose() end)
end

function Note:wrong()
    self.color = {0.5, 0, 0, 1}
    local totalTime = assets.config.note.fadeAway
    self.area.timer:tween(totalTime, self, {color = {0.5, 0, 0, 0}})
    self.area.timer:after(totalTime, function() self:dispose() end)
    self.name = self.area.key:getNoteName(self.note)
end

function Note:draw()
    love.graphics.setColor(0, 0, 0, self.color[4])
    local scale = assets.config.note.height / self.image:getHeight()
    local xOrig = assets.config.note.xOrigin
    local yOrig = assets.config.note.yOrigin
    local actualWidth = scale * self.image:getWidth()
    local padding = assets.config.note.padding
    if self.note <= 4 then
        for i = 6, self.note, -2 do
            love.graphics.line(self.x, self:noteToPosition(i), self.x + actualWidth + padding * 2, self:noteToPosition((i)))
        end
    elseif self.note >= 15 then
        for i = 16, self.note, 2 do
            love.graphics.line(self.x, self:noteToPosition(i), self.x +  actualWidth + padding * 2, self:noteToPosition((i)))
        end
    end

    if self.note >= 10 then scale = -scale end
    love.graphics.setColor(unpack(self.color))
    love.graphics.draw(self.image, self.x +  padding + actualWidth / 2, self.y, 0, scale, scale, xOrig, yOrig)

    if self.name then
        love.graphics.print(self.name, self.x - 15, self.y + 5)
    end
end

---@param dt number
function Note:update(dt)
    self.x = self.x - self.area:getMove()
    if self.x < 0 then
        self.dispose(self)
    end
end

return Note