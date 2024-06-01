local World = {}

local wallImage
local barImage


function World.createStaticBodies(world)
    local window_width, window_height = 1024, 768
    local ground_width, ground_height = 400, 50
    local wall_width, wall_height = 50, 450
    local offset = 100

    -- centered positions
    local ground_x = (window_width - ground_width) / 2
    local ground_y = window_height - ground_height - offset

    wall_left_x = ((window_width - ground_width - wall_width * 2) / 2)
    wall_right_x = (wall_left_x + ground_width + wall_width)

    local wall_y = (window_height - wall_height) / 2

    -- colliders
    local ground = world:newRectangleCollider(ground_x, ground_y + 50, ground_width, ground_height)
    local wall_left = world:newRectangleCollider(wall_left_x, wall_y + 50, wall_width, wall_height)
    local wall_right = world:newRectangleCollider(wall_right_x, wall_y + 50, wall_width, wall_height)

    -- colliders mode
    ground:setType('static')
    wall_left:setType('static')
    wall_right:setType('static')

    World.walls = {
        { x = wall_left_x,  y = wall_y, width = wall_width, height = wall_height },
        { x = wall_right_x, y = wall_y, width = wall_width, height = wall_height }
    }

    World.wall_left_x = wall_left_x
    World.wall_right_x = wall_right_x

    World.ground = { x = ground_x, y = ground_y, width = ground_width, height = ground_height }
end

function World.loadSprites()
    wallImage = love.graphics.newImage("assets/sprites/cup.png")
    barImage = love.graphics.newImage("assets/sprites/bar.jpg")
end

function World.drawCup()
    -- Get the dimensions of the sprite
    local spriteWidth = wallImage:getWidth()
    local spriteHeight = wallImage:getHeight()

    -- Set the desired scale factor
    local scaleFactorx = 20
    local scaleFactory = 20

    -- Calculate the scaled dimensions of the sprite
    local scaledWidth = spriteWidth * scaleFactorx
    local scaledHeight = spriteHeight * scaleFactory

    -- Set the desired offsets
    local offsetX = 0  -- Adjust as needed
    local offsetY = 70 -- Adjust as needed

    -- Calculate the position to center the scaled sprite with offsets
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local spriteX = (screenWidth - scaledWidth) / 2 + offsetX
    local spriteY = (screenHeight - scaledHeight) / 2 + offsetY

    -- Draw the scaled sprite at the centered position with offsets
    love.graphics.draw(wallImage, spriteX, spriteY, nil, scaleFactorx, scaleFactory)
end

function World.drawEnv()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local backgroundWidth = barImage:getWidth()
    local backgroundHeight = barImage:getHeight()

    -- Calculate the scale factors for the background image
    local scaleX = screenWidth / backgroundWidth
    local scaleY = screenHeight / backgroundHeight

    -- Choose the smaller scale factor to maintain aspect ratio
    local scaleFactor = math.min(scaleX, scaleY)

    -- Calculate the scaled dimensions of the background image
    local scaledWidth = backgroundWidth * scaleFactor
    local scaledHeight = backgroundHeight * scaleFactor

    -- Calculate the position to center the scaled background image
    local backgroundX = (screenWidth - scaledWidth) / 2
    local backgroundY = (screenHeight - scaledHeight) / 2

    -- Draw the scaled background image at the centered position
    love.graphics.draw(barImage, backgroundX, backgroundY, nil, scaleFactor, scaleFactor)
end

function World.draw()
    World.drawEnv()
    World.drawCup()
end

return World
