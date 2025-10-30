game = {}
bg = {}
orb = {}
orbs = {}
hud = {}
food = {}
foods = {}
box = {}
shard = {}
walls = {}
shards = {}

function game.init()
    screenW = love.graphics.getWidth()
    screenH = love.graphics.getHeight()
    love.graphics.setDefaultFilter("nearest", "nearest")
    bgi = love.graphics.newImage("images/background.png")
    orbi = love.graphics.newImage("images/orb.png")
    fire = love.audio.newSource("audio/testbolt.wav", "static")
    aifire = love.audio.newSource("audio/woosh2.wav", "static")
    gameover = love.audio.newSource("audio/gameover.mp3", "stream")
    won = love.audio.newSource("audio/won.wav", "stream")
    aidie = love.audio.newSource("audio/ai-die.wav", "static")
    pldie = love.audio.newSource("audio/hurt.wav", "static")
    heart = love.graphics.newImage("images/heart.png")
    food.img = love.graphics.newImage("images/food.png")
    box.img = love.graphics.newImage("images/box.png")
    shard.img = love.graphics.newImage("images/shard.png")
    lfont = love.graphics.newFont(19)
    nfont = love.graphics.newFont(12)
    dfont = love.graphics.newFont(30)
    deathmsg1 = "You Died!"
    wonmsg1 = "You Won!"
    deathmsg2 = "Press R to restart."
    w1 = dfont:getWidth(deathmsg1)
    w2 = dfont:getWidth(deathmsg2)
    h  = dfont:getHeight()
    imgW, imgH = bgi:getDimensions()
    food.scale = 0.1
    food.w = food.img:getWidth() * food.scale
    food.h = food.img:getHeight() * food.scale
    orb.speed = 700
    orb.scale = 1
    orb.w = orbi:getWidth() * orb.scale
    orb.h = orbi:getHeight() * orb.scale
    orb.cooldown = 0
    food.timer = 0
    food.spawntime = .7
end

function food.update(dt)

    food.timer = food.timer + dt
    if food.timer > food.spawntime then
        local screenW = love.graphics.getWidth()
        local screenH = love.graphics.getHeight()

        local fw = food.w * food.scale
        local fh = food.h * food.scale

            local x = math.random(0, screenW - fw - 250)
            local y = math.random(0, screenH - fh - 250)

        local candy = {
            x = x,
            y = y,
        }    
    table.insert(foods, candy)
    food.timer = 0
    end
end

function food.draw()
    for i, f in ipairs(foods) do
        love.graphics.draw(food.img, f.x, f.y, nil, food.scale)
        if debug == true then
            love.graphics.setFont(nfont)
            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("line", f.x, f.y, food.w, food.h)
            love.graphics.print(string.format("%.1f", f.x) .. "," .. string.format("%.1f", f.y), f.x, f.y)
            love.graphics.setColor(1, 1, 1)
        end
    end    
end

function game.update(dt)
    ai.timer = ai.timer + dt

    if ai.timer > ai.simTime then
        table.remove(player.health, 1)
        ai.timer = 0
    end

    if #player.health <= 0 then
        player.death = true
        player.die()
    end

    if #population <= 0 then
        player.won = true
        player.win()
    end

end

function bg.draw()
    love.graphics.draw(bgi, 0, 0, 0,
        screenW / imgW,
        screenH / imgH
    )
end

function game.drawdeathscreen()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(dfont)
    love.graphics.print(deathmsg1, (screenW - w1) / 2, (screenH - h) / 2)
    love.graphics.print(deathmsg2, (screenW - w2) / 2, (screenH - h) / 2 + 80)
end

function game.drawwinscreen()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(dfont)
    love.graphics.print(wonmsg1, (screenW - w1) / 2, (screenH - h) / 2)
    love.graphics.print(deathmsg2, (screenW - w2) / 2, (screenH - h) / 2 + 80)
end

function hud.draw()
    for i, hearts in ipairs(player.health) do
        love.graphics.draw(heart, 10 + (i - 1) * 56, 10, nil, 0.2)
    end    

    if debug == true then
        love.graphics.setFont(lfont)
        love.graphics.print("Debug mode: on", screenW/2, 10)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(lfont)
    love.graphics.print("Time: " .. string.format("%.1f", ai.timer) .. "/" .. ai.simTime, 1780, 40)
    love.graphics.print("Population: " .. #population, 1780, 70)
end

function orb.draw(x, y)
    for i, o in ipairs(orbs) do
        love.graphics.draw(orbi, o.x, o.y, nil, orb.scale)
        if debug == true then
            love.graphics.setFont(nfont)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", o.x, o.y, orb.w, orb.h)
            love.graphics.print(string.format("%.1f", o.x) .. "," .. string.format("%.1f", o.y), o.x, o.y)
            love.graphics.setColor(1, 1, 1)
        end
    end    
end

function orb.fire()
    fire:play()
    local orbX = player.x
    local orbY = player.y

    if player.direction == "up" then
        orbY = orbY - 20
        orbX = orbX + 35
    elseif player.direction == "down" then
        orbY = orbY + 110
        orbX = orbX + 35
    elseif player.direction == "left" then
        orbX = orbX - 10
        orbY = orbY + 60
    elseif player.direction == "right" then
        orbX = orbX + 90
        orbY = orbY + 60
    end

    table.insert(orbs, {x = orbX, y = orbY, dir = player.direction})
    orb.cooldown = 1
end

function orbs.update(dt)
    if orb.cooldown > 0 then
        orb.cooldown = orb.cooldown - dt
    end    

    for i, o in ipairs(orbs) do
        local speed = orb.speed * dt
        if o.dir == "left" then
            o.x = o.x - speed
        elseif o.dir == "right" then
            o.x = o.x + speed
        elseif o.dir == "up" then
            o.y = o.y - speed
        elseif o.dir == "down" then
            o.y = o.y + speed
        end
    
        if o.x < 0 or o.x > love.graphics.getWidth() then
            table.remove(orbs, i)
        end
    end
end

function game.checkRectCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function game.findNearest(object1, object2)
    local nearest, minDist = nil, math.huge
    for _, obj in ipairs(object2) do
        local dx = obj.x - object1.x
        local dy = obj.y - object1.y
        local dist = dx*dx + dy*dy
        if dist < minDist then
            minDist = dist
            nearest = obj
        end
    end
    return nearest or {x = object1.x, y = object1.y}
end