local wf = require "lib.windfield"
local World = require "world"
local Strawberry = require "strawberry"
local Lemon = require "lemon"
local Pear = require "pear"
local Apple = require "apple"
local Orange = require "orange"
local Watermelon = require "watermelon"

-- Initialize spawn parameters
local spawnX, spawnY = love.graphics.getWidth() / 2, 100
local spawnDelay = 2
local spawnTimer = 0
local targetX = love.graphics.getWidth() / 2
local activeFruit = nil

-- Define fruit types
local fruitTypes = {
    Strawberry,
    Lemon,
    Pear,
    Apple,
    Orange,
    Watermelon,
}

--[[
Initializes the game, setting up the world and loading sprites and collision classes.
]]
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Create game world and load necessary components
    world = createWorld()
    World.createStaticBodies(world)
    World.loadSprites()
    loadSprites()
    collisionClass()

    -- Spawn the first fruit
    world.objects = {}
    spawnFruit()
end

--[[
Updates the game state every frame, including world updates, fruit updates, and spawning logic.
]]
function love.update(dt)
    world:update(dt)

    -- Update each fruit
    for _, fruit in ipairs(world.objects) do
        fruit:upgrade()
    end

    -- Remove destroyed fruits
    removeDestroyedFruits()

    -- Move active fruit towards target position
    if activeFruit and not activeFruit.fell then
        activeFruit:moveXTo(targetX, dt)
    end

    -- Handle spawning delay
    if spawnTimer > 0 then
        spawnTimer = spawnTimer - dt
        if spawnTimer <= 0 then
            spawnFruit()
        end
    end
end

--[[
Renders the world and fruits on the screen.
]]
function love.draw()
    World.draw()

    -- Draw each fruit
    for _, fruit in ipairs(world.objects) do
        fruit:draw()
    end

    -- Draw the world
    --world:draw()
end

--[[
Handles mouse press events to update target positions and trigger fruit spawning.
]]
function love.mousepressed(x, y, button)
    if button == 1 then
        targetX = x
        for i = #world.objects, 1, -1 do
            if not world.objects[i].fell and activeFruit then
                world.objects[i]:SetType('dynamic')
                break
            end
        end
        spawnTimer = spawnDelay
        activeFruit:SetType('dynamic')
    end
end

--[[
Creates and returns a new game world with specified gravity.
]]
function createWorld()
    local world = wf.newWorld(0, 0, true)
    world:setGravity(0, 512)
    return world
end

--[[
Loads sprites for all fruit types.
]]
function loadSprites()
    for _, fruit in ipairs(fruitTypes) do
        fruit:loadSprites()
    end
end

--[[
Adds collision classes for all fruit types in the world.
]]
function collisionClass()
    for _, fruit in pairs(fruitTypes) do
        world:addCollisionClass(fruit.class)
    end
end

function spawnFruit()
    local fruitType = fruitTypes[love.math.random(1, 3)]
    table.insert(world.objects, fruitType(world, spawnX, spawnY))
    activeFruit = world.objects[#world.objects]
end

function removeDestroyedFruits()
    for i = #world.objects, 1, -1 do
        if world.objects[i].body == nil or world.objects[i].body:isDestroyed() then
            table.remove(world.objects, i)
        end
    end
end
