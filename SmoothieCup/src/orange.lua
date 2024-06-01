local clsc = require "lib.classic"
local lume = require "lib.lume"

local World = require "world"
local Watermelon = require "watermelon"

local Orange = clsc:extend()

Orange.class = 'Orange'
local orangeImage

function Orange:new(world, x, y, type)
    type = type or 'static'
    local radius = 40
    local res = 0.5
    self.world = world
    self.body = world:newCircleCollider(x, y, radius)
    self.body:setType(type)
    self.body:setRestitution(res)
    self.body:setCollisionClass(Orange.class)
    self.body:setObject(self)
    self.radius = radius
    self.fell = false
end

function Orange:getPos()
    return self.body:getX(), self.body:getY()
end

function Orange:upgrade()
    if self.body:enter(Orange.class) then
        local colData = self.body:getEnterCollisionData(Orange.class)
        local otherFruit = colData.collider:getObject()
        if otherFruit and otherFruit:is(Orange) then
            local x1, y1 = self:getPos()
            local x2, y2 = otherFruit:getPos()

            self.body:destroy()
            otherFruit.body:destroy()

            local newX = (x1 + x2) / 2
            local newY = (y1 + y2) / 2
            local newFruit = Watermelon(self.world, newX, newY, 'dynamic')

            table.insert(self.world.objects, newFruit)
        end
    end
end

function Orange:loadSprites()
    orangeImage = love.graphics.newImage('assets/sprites/orange.png')
end

function Orange:draw()
    local x, y = self:getPos()
    local scaleFactor = 1.8
    local scale = self.radius * 2 / orangeImage:getWidth() * scaleFactor
    love.graphics.draw(orangeImage, x, y, 0, scale, scale, orangeImage:getWidth() / 2, orangeImage:getHeight() / 2)
end

function Orange:SetType(type)
    self.body:setType(type)
end

function Orange:moveXTo(targetX, dt)
    if not self.fell then
        local x, y = self:getPos()

        local wL, wR = World.wall_left_x + 80, World.wall_right_x - 20
        if wL and wR then
            targetX = lume.clamp(targetX, wL, wR)
            local newX = lume.lerp(x, targetX, dt * 5)

            -- Ensure newX is valid before setting the position
            if newX and newX ~= x then
                self.body:setPosition(newX, y)

                -- Check if the fruit has reached the target position
                if math.abs(newX - targetX) < 1 then
                    self.fell = true
                end
            end
        end
    end
end

function Orange:startMoving()
    self.moving = true
end

function Orange:stopMoving()
    self.moving = false
end

return Orange
