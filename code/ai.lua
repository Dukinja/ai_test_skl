ai = {}

function ai.init()
    ai.img = love.graphics.newImage("images/bot.png")
    ai.scale = 0.4
    ai.w = ai.img:getWidth() * ai.scale
    ai.h = ai.img:getHeight() * ai.scale


    ai.populationSize = 15
    ai.maxPopulation = 18
    ai.simTime = 6

    ai.population = {}
    ai.timer = 0
    ai.generation = 1
    ai.initPopulation()
end

function ai.initPopulation() 
    population = {} 
    for i = 1, ai.populationSize do 
        table.insert(population, { x = screenW/2, y = screenH/2, vx = math.random(-10, 10), vy = math.random(-10, 10), fitness = 0 }) 
    end 
end

function ai.update(dt)
    if ai.timer < ai.simTime then
        for _, creature in ipairs(population) do
            creature.x = creature.x + creature.vx * dt * 10
            creature.y = creature.y + creature.vy * dt * 10

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
                bot.fitness = bot.fitness + 1
                table.insert(population, {
                    x = screenW / 2,
                    y = screenH / 2,
                    vx = math.random(-10, 10),
                    vy = math.random(-10, 10),
                    fitness = 0
                })
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
                table.remove(orbs, i)
                break
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
end