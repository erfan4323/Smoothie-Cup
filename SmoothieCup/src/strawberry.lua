local clsc = require "lib.classic"
local lume = require "lib.lume"

local World = require "world"
local Lemon = require "lemon"

local Strawberry = clsc:extend()

Strawberry.class = 'Strawberry'
local stawberryImage

function Strawberry:new(world, x, y, type)
    type = type or 'static'
    local radius = 20
    local res = 0.5
    self.world = world
    self.body = world:newCircleCollider(x, y, radius)
    self.body:setType(type)
    self.body:setRestitution(res)
    self.body:setCollisionClass(Strawberry.class)
    self.body:setObject(self)
    self.radius = radius
    self.targetX = x
    self.fell = false
    self.moved = false
end

function Strawberry:getPos()
    return self.body:getX(), self.body:getY()
end

function Strawberry:upgrade()
    if self.body:enter(Strawberry.class) then
        local colData = self.body:getEnterCollisionData(Strawberry.class)
        local otherFruit = colData.collider:getObject()
        if otherFruit and otherFruit:is(Strawberry) then
            local x1, y1 = self:getPos()
            local x2, y2 = otherFruit:getPos()

            self.body:destroy()
            otherFruit.body:destroy()

            local newX = (x1 + x2) / 2
            local newY = (y1 + y2) / 2
            local newFruit = Lemon(self.world, newX, newY, 'dynamic')

            table.insert(self.world.objects, newFruit)
        end
    end
end

function Strawberry:loadSprites()
    stawberryImage = love.graphics.newImage('assets/sprites/strawberry.png')
end

function Strawberry:draw()
    local x, y = self:getPos()
    local scaleFactor = 1.8
    local scale = self.radius * 2 / stawberryImage:getWidth() * scaleFactor
    love.graphics.draw(stawberryImage, x, y, 0, scale, scale, stawberryImage:getWidth() / 2,
        stawberryImage:getHeight() / 2)
end

function Strawberry:SetType(type)
    self.body:setType(type)
end

function Strawberry:moveXTo(targetX, dt)
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

return Strawberry
