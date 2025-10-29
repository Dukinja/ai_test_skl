anim8 = require 'code/anim8'

player = {}

function player.init()

    walk = love.audio.newSource("audio/walk.mp3", "static")

    player.fireRate = 1
    player.fireTimer = 0

    player.x = 1920/2
    player.y = 1080/2
    player.speed = 3
    player.w = 12
    player.h = 18
    player.scale = 6
    player.speeda = 350

    player.death = false

    player.isMoving = false
    player.direction = "left"

    player.spriteSheet = love.graphics.newImage('images/player-sheet.png')
    player.grid = anim8.newGrid( player.w, player.h, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.health = {
        "1", "1"
    }

    player.animations = {}
    player.animations.down = anim8.newAnimation( player.grid('1-4', 1), 0.2 )
    player.animations.left = anim8.newAnimation( player.grid('1-4', 2), 0.2 )
    player.animations.right = anim8.newAnimation( player.grid('1-4', 3), 0.2 )
    player.animations.up = anim8.newAnimation( player.grid('1-4', 4), 0.2 )

    player.anim = player.animations.left
end

function player.draw()
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, player.scale)
    if debug == true then
        love.graphics.setFont(nfont)
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("line", player.x, player.y, player.w, player.h)
        love.graphics.print(player.x .. "," .. player.y .. "," .. player.direction, player.x+15, player.y-10)
        love.graphics.setColor(1, 1, 1)
    end
end

function player.die()
    gameover:play()
    function love.keypressed(key)
        if key == "r" then
            love.event.quit("restart")
        end
    end
end

function player.update(dt)
    if player.isAI == true then


        local nearestFood = game.findNearest(player, foods)
        local nearestOrb = game.findNearest(player, orbs)
        
        local dxF = nearestFood.x - player.x
        local dyF = nearestFood.y - player.y
        local distF = math.sqrt(dxF * dxF + dyF * dyF)
        
        local dxO = nearestOrb.x - player.x
        local dyO = nearestOrb.y - player.y
        local distO = math.sqrt(dxO * dxO + dyO * dyO)

        local moveX, moveY = 0, 0

        if distF > 0 then
            moveX = (dxF / distF) * player.speeda * dt
            moveY = (dyF / distF) * player.speeda * dt
        else
            moveX = player.speeda * dt
            moveY = player.speeda * dt
        end
        
        player.x = player.x + moveX
        player.y = player.y + moveY

        if math.abs(moveX) > math.abs(moveY) then
            if moveX > 0 then dir = "right"
            else dir = "left" end
        else
            if moveY > 0 then dir = "down"
            else dir = "up" end
        end

        player.isMoving = true

        if player.direction ~= dir then
            player.direction = dir
            player.anim = player.animations[dir]
        end

        player.fireTimer = player.fireTimer - dt

        for _, creature in ipairs(population) do

            local nearest = game.findNearest(player, creature)
            if not nearest then return end
        
            local dx = nearest.x - player.x
            local dy = nearest.y - player.y
            local dist = math.sqrt(dx * dx + dy * dy)
        
            local range = 300
            if dist > range then return end
        
            if math.random(0, 6000) == 6000 and player.fireTimer <= 0 then
                orb.fire(player.x, player.y, dx, dy)
                player.fireTimer = player.fireRate
            end

        end

    end

    if player.isAI == false then
        player.isMoving = false
    end

    for i, f in ipairs(foods) do
        local playerW = player.w * player.scale
        local playerH = player.h * player.scale
    
        if player.x < f.x + food.w and
           player.x + playerW > f.x and
           player.y < f.y + food.h and
           player.y + playerH > f.y then
            table.remove(foods, i)
            table.insert(player.health, "health")
            break
        end
    end

    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed
        player.anim = player.animations.right
        player.isMoving = true
        player.direction = "right"
    end

    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
        player.anim = player.animations.left
        player.isMoving = true
        player.direction = "left"
    end

    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed
        player.anim = player.animations.down
        player.isMoving = true
        player.direction = "down"
    end

    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed
        player.anim = player.animations.up
        player.isMoving = true
        player.direction = "up"
    end

    if love.keyboard.isDown("f") and orb.cooldown <= 0 then
        orb.fire()
    end

    if player.isMoving == false then
        player.anim:gotoFrame(2)
    end

    if player.x < 0 then
        player.x = 0
    elseif player.x + player.w * player.scale > screenW then
        player.x = screenW - player.w * player.scale
    end

    if player.y < 0 then
        player.y = 0
    elseif player.y + player.h * player.scale > screenH then
        player.y = screenH - player.h * player.scale
    end

    if player.isMoving then

        if not walk:isPlaying() then

            walk:play()

        end

    end

    player.anim:update(dt)
end