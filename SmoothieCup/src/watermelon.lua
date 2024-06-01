local clsc = require "lib.classic"
local lume = require "lib.lume"

local World = require "world"

local Watermelon = clsc:extend()
Watermelon.class = 'Watermelon'
local watermelonImage

function Watermelon:new(world, x, y, type)
    --[[
    Initializing a new Watermelon object.
    ]]
    type = type or 'static'
    local radius = 45
    local res = 0.5
    self.world = world
    self.body = world:newCircleCollider(x, y, radius)
    self.body:setType(type)
    self.body:setRestitution(res)
    self.body:setCollisionClass(Watermelon.class)
    self.body:setObject(self)
    self.radius = radius
    self.fell = false
end

function Watermelon:getPos()
    --[[
    Getting the current position of the watermelon.
    ]]
    return self.body:getX(), self.body:getY()
end

function Watermelon:upgrade()
    --[[
    Upgrading the watermelon when it collides with another watermelon.
    ]]
    if self.body:enter(Watermelon.class) then
        local colData = self.body:getEnterCollisionData(Watermelon.class)
        local otherFruit = colData.collider:getObject()
        if otherFruit and otherFruit:is(Watermelon) then
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

function Watermelon:loadSprites()
    --[[
    Loading the watermelon sprite.
    ]]
    watermelonImage = love.graphics.newImage('assets/sprites/watermelon.png')
end

function Watermelon:draw()
    --[[
    Drawing the watermelon on the screen.
    ]]
    local x, y = self:getPos()
    local scaleFactor = 1.8
    local scale = self.radius * 2 / watermelonImage:getWidth() * scaleFactor
    love.graphics.draw(watermelonImage, x, y, 0, scale, scale, watermelonImage:getWidth() / 2,
        watermelonImage:getHeight() / 2)
end

function Watermelon:SetType(type)
    --[[
    Setting the type of the watermelon's body.
    ]]
    if self.body and not self.body:isDestroyed() then
        self.body:setType(type)
    end
end

function Watermelon:moveXTo(targetX, dt)
    --[[
    Moving the watermelon horizontally towards the target X position.
    ]]
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

return Watermelon
