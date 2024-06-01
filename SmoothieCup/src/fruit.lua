local clsc = require "lib.classic"

local Fruit = clsc:extend()

Fruit.class = 'Fruit'

function Fruit:new(world, x, y, radius, res)
    self.world = world
    self.body = world:newCircleCollider(x, y, radius)
    self.body:setType('dynamic')
    self.body:setRestitution(res)
    self.body:setCollisionClass(Fruit.class)
    self.body:setObject(self)
    self.radius = radius
end

function Fruit:getPos()
    return self.body:getX(), self.body:getY()
end

function Fruit:upgrade()
    if self.body:enter(Fruit.class) then
        local colData = self.body:getEnterCollisionData(Fruit.class)
        local otherFruit = colData.collider:getObject()
        if otherFruit and otherFruit:is(Fruit) then
            local x1, y1 = self:getPos()
            local x2, y2 = otherFruit:getPos()

            -- Get the restitution value before destroying the bodies
            local restitution = self.body:getRestitution()

            self.body:destroy()
            otherFruit.body:destroy()

            local newX = (x1 + x2) / 2
            local newY = (y1 + y2) / 2
            local newFruit = Fruit(self.world, newX, newY, self.radius, restitution)

            table.insert(self.world.objects, newFruit)
        end
    end
end

function Fruit:draw()
    love.graphics.circle('fill', self.body:getX(), self.body:getY(), self.radius)
end

return Fruit
