local clsc = require "lib.classic"
local lume = require "lib.lume"

local World = require "world"
local Lemon = require "lemon"

local Strawberry = clsc:extend()
Strawberry.class = 'Strawberry'
local stawberryImage

--[[
Initializing a new Strawberry object.
]]
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

--[[
Getting the current position of the strawberry.
]]
function Strawberry:getPos()
    return self.body:getX(), self.body:getY()
end

--[[
Upgrading the strawberry when it collides with another strawberry.
]]
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

--[[
Loading the strawberry sprite.
]]
function Strawberry:loadSprites()
    stawberryImage = love.graphics.newImage('assets/sprites/strawberry.png')
end

--[[
Drawing the strawberry on the screen.
]]
function Strawberry:draw()
    local x, y = self:getPos()
    local scaleFactor = 1.8
    local scale = self.radius * 2 / stawberryImage:getWidth() * scaleFactor
    love.graphics.draw(stawberryImage, x, y, 0, scale, scale, stawberryImage:getWidth() / 2,
        stawberryImage:getHeight() / 2)
end

--[[
Setting the type of the strawberry's body.
]]
function Strawberry:SetType(type)
    if self.body and not self.body:isDestroyed() then
        self.body:setType(type)
    end
end

--[[
Moving the strawberry horizontally towards the target X position.
]]
function Strawberry:moveXTo(targetX, dt)
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
