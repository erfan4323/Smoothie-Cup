local clsc = require "lib.classic"
local lume = require "lib.lume"

local World = require "world"
local Lemon = require "lemon"

local Strawberry = clsc:extend()
Strawberry.class = 'Strawberry'
local stawberryImage

function Strawberry:new(world, x, y, type)
    --[[
    Initializing a new Strawberry object.
    ]]
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
    --[[
    Getting the current position of the strawberry.
    ]]
    return self.body:getX(), self.body:getY()
end

function Strawberry:upgrade()
    --[[
    Upgrading the strawberry when it collides with another strawberry.
    ]]
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
    --[[
    Loading the strawberry sprite.
    ]]
    stawberryImage = love.graphics.newImage('assets/sprites/strawberry.png')
end

function Strawberry:draw()
    --[[
    Drawing the strawberry on the screen.
    ]]
    local x, y = self:getPos()
    local scaleFactor = 1.8
    local scale = self.radius * 2 / stawberryImage:getWidth() * scaleFactor
    love.graphics.draw(stawberryImage, x, y, 0, scale, scale, stawberryImage:getWidth() / 2,
        stawberryImage:getHeight() / 2)
end

function Strawberry:SetType(type)
    --[[
    Setting the type of the strawberry's body.
    ]]
    if self.body and not self.body:isDestroyed() then
        self.body:setType(type)
    end
end

function Strawberry:moveXTo(targetX, dt)
    --[[
    Moving the strawberry horizontally towards the target X position.
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

return Strawberry
