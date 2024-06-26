local clsc = require "lib.classic"
local lume = require "lib.lume"

local World = require "world"
local Orange = require "orange"

local Apple = clsc:extend()
Apple.class = 'Apple'
local appleImage

--[[
Initialize a new Apple object.
]]
function Apple:new(world, x, y, type)
    type = type or 'static'
    local radius = 35
    local res = 0.5
    self.world = world
    self.body = world:newCircleCollider(x, y, radius)
    self.body:setType(type)
    self.body:setRestitution(res)
    self.body:setCollisionClass(Apple.class)
    self.body:setObject(self)
    self.radius = radius
    self.fell = false
end

--[[
Get the current position of the apple.
]]
function Apple:getPos()
    return self.body:getX(), self.body:getY()
end

--[[
Upgrade the apple when it collides with another apple.
]]
function Apple:upgrade()
    if self.body:enter(Apple.class) then
        local colData = self.body:getEnterCollisionData(Apple.class)
        local otherFruit = colData.collider:getObject()
        if otherFruit and otherFruit:is(Apple) then
            local x1, y1 = self:getPos()
            local x2, y2 = otherFruit:getPos()
            self.body:destroy()
            otherFruit.body:destroy()
            local newX = (x1 + x2) / 2
            local newY = (y1 + y2) / 2
            local newFruit = Orange(self.world, newX, newY, 'dynamic')
            table.insert(self.world.objects, newFruit)
        end
    end
end

--[[
Load the apple sprite.
]]
function Apple:loadSprites()
    appleImage = love.graphics.newImage('assets/sprites/apple.png')
end

--[[
Set the type of the apple's body.
]]
function Apple:SetType(type)
    if self.body and not self.body:isDestroyed() then
        self.body:setType(type)
    end
end

--[[
Draw the apple on the screen.
]]
function Apple:draw()
    local x, y = self:getPos()
    local scaleFactor = 1.8
    local scale = self.radius * 2 / appleImage:getWidth() * scaleFactor
    love.graphics.draw(appleImage, x, y, 0, scale, scale, appleImage:getWidth() / 2, appleImage:getHeight() / 2)
end

--[[
Move the apple horizontally towards the target X position.
]]
function Apple:moveXTo(targetX, dt)
    if not self.fell then
        local x, y = self:getPos()
        local wL, wR = World.wall_left_x + 80, World.wall_right_x - 20
        if wL and wR then
            targetX = lume.clamp(targetX, wL, wR)
            local newX = lume.lerp(x, targetX, dt * 5)
            if newX and newX ~= x then
                self.body:setPosition(newX, y)
                if math.abs(newX - targetX) < 1 then
                    self.fell = true
                end
            end
        end
    end
end

return Apple
