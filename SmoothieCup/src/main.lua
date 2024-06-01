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

function love.load()
    --[[
    Initializes the game, setting up the world and loading sprites and collision classes.
    ]]
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Create game world and load necessary components
    world = createWorld()
    World.createStaticBodies(world)
    World.loadSprites()
    loadSprites()
    collisionClass()

    -- Define fruit types
    fruitTypes = {
        Strawberry,
        Lemon,
        Pear,
        Apple,
        Orange,
        Watermelon,
    }

    -- Spawn the first fruit
    world.objects = {}
    table.insert(world.objects, fruitTypes[love.math.random(1, 3)](world, spawnX, spawnY))
    activeFruit = world.objects[#world.objects]
end

function love.update(dt)
    --[[
    Updates the game state every frame, including world updates, fruit updates, and spawning logic.
    ]]
    world:update(dt)

    -- Update each fruit
    for _, fruit in ipairs(world.objects) do
        fruit:upgrade()
    end

    -- Remove destroyed fruits
    for i = #world.objects, 1, -1 do
        if world.objects[i].body == nil or world.objects[i].body:isDestroyed() then
            table.remove(world.objects, i)
        end
    end

    -- Move active fruit towards target position
    if activeFruit and not activeFruit.fell then
        activeFruit:moveXTo(targetX, dt)
    end

    -- Handle spawning delay
    if spawnTimer > 0 then
        spawnTimer = spawnTimer - dt
        if spawnTimer <= 0 then
            table.insert(world.objects, fruitTypes[love.math.random(1, 3)](world, spawnX, spawnY))
            activeFruit = world.objects[#world.objects]
        end
    end
end

function love.draw()
    --[[
    Renders the world and fruits on the screen.
    ]]
    World.draw()

    -- Draw each fruit
    for _, fruit in ipairs(world.objects) do
        fruit:draw()
    end

    -- Draw the world
    world:draw()
end

function love.mousepressed(x, y, button)
    --[[
    Handles mouse press events to update target positions and trigger fruit spawning.
    ]]
    if button == 1 then
        targetX = x
        for i = #world.objects, 1, -1 do
            if not world.objects[i].fell and activeFruit then
                world.objects[i]:SetType('dynamic')
                break
            end
        end
        spawnTimer = spawnDelay
    end
end

function createWorld()
    --[[
    Creates and returns a new game world with specified gravity.
    ]]
    local world = wf.newWorld(0, 0, true)
    world:setGravity(0, 512)
    return world
end

function loadSprites()
    --[[
    Loads sprites for all fruit types.
    ]]
    Orange:loadSprites()
    Strawberry:loadSprites()
    Lemon:loadSprites()
    Pear:loadSprites()
    Apple:loadSprites()
    Watermelon:loadSprites()
end

function collisionClass()
    --[[
    Adds collision classes for all fruit types in the world.
    ]]
    world:addCollisionClass(Orange.class)
    world:addCollisionClass(Strawberry.class)
    world:addCollisionClass(Lemon.class)
    world:addCollisionClass(Pear.class)
    world:addCollisionClass(Apple.class)
    world:addCollisionClass(Watermelon.class)
end
