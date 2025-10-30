ai = {}

function ai.init()
    ai.img = love.graphics.newImage("images/bot.png")
    ai.scale = 0.4
    ai.w = ai.img:getWidth() * ai.scale
    ai.h = ai.img:getHeight() * ai.scale

    rrrr = false

    ai.orbs = {}
    ai.shootCooldown = 1.5

    ai.populationSize = 2
    ai.maxPopulation = 7
    ai.simTime = 6

    ai.population = {}
    ai.timer = 0
    ai.initPopulation()
end

function ai.initPopulation() 
    population = {} 
    for i = 1, ai.populationSize do 
        table.insert(population, { 
            x = math.random(1, screenW),
            y = math.random(1, screenH),
            vx = math.random(50, 200), 
            vy = math.random(50, 200),
            fitness = 0,
            shootTimer = math.random() * ai.shootCooldown
        }) 
    end 
end

function ai.update(dt)

    if ai.timer < ai.simTime then
        for _, creature in ipairs(population) do
            local nearestFood = game.findNearest(creature, foods)
            local nearestOrb = game.findNearest(creature, orbs)
            
            local dxF = nearestFood.x - creature.x
            local dyF = nearestFood.y - creature.y
            local distF = math.sqrt(dxF * dxF + dyF * dyF)
            
            local dxO = nearestOrb.x - creature.x
            local dyO = nearestOrb.y - creature.y
            local distO = math.sqrt(dxO * dxO + dyO * dyO)

            local speed = math.sqrt(creature.vx^2 + creature.vy^2)
            if speed == 0 then
                speed = 200
            end

            if distF > 0 and #population < ai.maxPopulation then
                creature.x = creature.x + (dxF / distF) * speed * dt
                creature.y = creature.y + (dyF / distF) * speed * dt
            else
                local len = math.sqrt(creature.vx^2 + creature.vy^2)
                if len > 0 then
                    creature.x = creature.x + (creature.vx / len) * speed * dt
                    creature.y = creature.y + (creature.vy / len) * speed * dt
                end
            end

            if creature.x < 0 then
                creature.x = 0
                creature.vx = -creature.vx
            elseif creature.x + ai.w > screenW then
                creature.x = screenW - ai.w
                creature.vx = -creature.vx
            end
            
            if creature.y < 0 then
                creature.y = 0
                creature.vy = -creature.vy
            elseif creature.y + ai.h > screenH then
                creature.y = screenH - ai.h
                creature.vy = -creature.vy
            end

            creature.shootTimer = creature.shootTimer - dt
            if math.random(1, 1800) == 1800 and creature.shootTimer <= 0 then
                creature.shootTimer = ai.shootCooldown

                local dx = player.x - creature.x
                local dy = player.y - creature.y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist > 0 then
                    local speed = 700
                    table.insert(ai.orbs, {
                        x = creature.x + ai.w / 2,
                        y = creature.y + ai.h / 2,
                        vx = (dx / dist) * speed,
                        vy = (dy / dist) * speed
                    })
                    aifire:play()
                end
            end
        end
    else
    end

    for i = #foods, 1, -1 do
        local f = foods[i]
            for _, bot in ipairs(population) do
                local dx = bot.x - f.x
                local dy = bot.y - f.y
                local dist = math.sqrt(dx * dx + dy * dy)
        
                local botRadius  = ai.w / 2
                local foodRadius = food.w / 2
        
                if dist < botRadius + foodRadius then
                    table.remove(foods, i)
                    if #population < ai.maxPopulation and rrrr == false then
                        bot.fitness = bot.fitness + 1
                            table.insert(population, {
                                x = math.random(1, screenW),
                                y = math.random(1, screenH),
                                vx = math.random(50, 200), 
                                vy = math.random(50, 200),
                                fitness = 0,
                                shootTimer = math.random() * ai.shootCooldown
                            })
                        if #population == ai.maxPopulation then
                            rrrr = true
                        end
                    end
                break
            end
        end
    end
    
    for i = #orbs, 1, -1 do
        local o = orbs[i]
        for j = #population, 1, -1 do
            local bot = population[j]
            local dx = bot.x - o.x
            local dy = bot.y - o.y
            local dist = math.sqrt(dx * dx + dy * dy)
    
            local botRadius = ai.w / 2
            local orbRadius = orb.w / 2
    
            if dist < botRadius + orbRadius then
                table.remove(population, j)
                aidie:play()
                table.remove(orbs, i)
                break
            end
        end
    end

    for i = #ai.orbs, 1, -1 do
        local o = ai.orbs[i]
        o.x = o.x + o.vx * dt
        o.y = o.y + o.vy * dt
    
        if o.x < 0 or o.y < 0 or o.x > screenW or o.y > screenH then
            table.remove(ai.orbs, i)
        else
            local px = player.x - (player.w * player.scale) / 2
            local py = player.y - (player.h * player.scale) / 2
            local pw = player.w * player.scale
            local ph = player.h * player.scale
            
            local ox = o.x - (orb.w * orb.scale) / 2
            local oy = o.y - (orb.h * orb.scale) / 2
            local ow = orb.w * orb.scale
            local oh = orb.h * orb.scale
            
            if px < ox + ow and
               px + pw > ox and
               py < oy + oh and
               py + ph > oy then
                table.remove(ai.orbs, i)
                table.remove(player.health, 1)
                pldie:play()
            end
        end
    end
end

function ai.draw()
    for _, bots in ipairs(population) do
        love.graphics.draw(ai.img, bots.x, bots.y, nil, ai.scale)
        if debug == true then
            love.graphics.setFont(nfont)
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("line", bots.x, bots.y, ai.w, ai.h)
            love.graphics.print(string.format("%.1f", bots.x) .. "," .. string.format("%.1f", bots.y), bots.x, bots.y)
            love.graphics.setColor(1, 1, 1)
        end
    end

    for _, o in ipairs(ai.orbs) do
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