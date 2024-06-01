local clsc = require "lib.classic"
local lume = require "lib.lume"

local World = require "world"
local Pear = require "pear"

local Lemon = clsc:extend()

Lemon.class = 'Lemon'
local lemonImage

function Lemon:new(world, x, y, type)
    type = type or 'static'
    local radius = 25
    local res = 0.5
    self.world = world
    self.body = world:newCircleCollider(x, y, radius)
    self.body:setType(type)
    self.body:setRestitution(res)
    self.body:setCollisionClass(Lemon.class)
    self.body:setObject(self)
    self.radius = radius
    self.fell = false
end

function Lemon:getPos()
    return self.body:getX(), self.body:getY()
end

function Lemon:upgrade()
    if self.body:enter(Lemon.class) then
        local colData = self.body:getEnterCollisionData(Lemon.class)
        local otherFruit = colData.collider:getObject()
        if otherFruit and otherFruit:is(Lemon) then
            local x1, y1 = self:getPos()
            local x2, y2 = otherFruit:getPos()

            self.body:destroy()
            otherFruit.body:destroy()

            local newX = (x1 + x2) / 2
            local newY = (y1 + y2) / 2
            local newFruit = Pear(self.world, newX, newY, 'dynamic')

            table.insert(self.world.objects, newFruit)
        end
    end
end

function Lemon:loadSprites()
    lemonImage = love.graphics.newImage('assets/sprites/lemon.png')
end

function Lemon:draw()
    local x, y = self:getPos()
    local scaleFactor = 1.8
    local scale = self.radius * 2 / lemonImage:getWidth() * scaleFactor
    love.graphics.draw(lemonImage, x, y, 0, scale, scale, lemonImage:getWidth() / 2,
        lemonImage:getHeight() / 2)
end

function Lemon:SetType(type)
    if self.body and not self.body:isDestroyed() then
        self.body:setType(type)
    end
end

function Lemon:moveXTo(targetX, dt)
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

function Lemon:startMoving()
    self.moving = true
end

function Lemon:stopMoving()
    self.moving = false
end

return Lemon
