function love.load()
    math.randomseed(os.time())
    require("code/player")
    require("code/ai")
    require("code/game")
    game.init()
    player.init()
    ai.init()
end

function love.update(dt)
    if player.death == false or player.won == false then
        game.update(dt)
        food.update(dt)
        player.update(dt)
        orbs.update(dt)
        ai.update(dt)
    end
end

function love.draw()
    if not player.death and not player.won then
        bg.draw()
        food.draw()
        player.draw()
        orb.draw()
        ai.draw()
        hud.draw()
    
    elseif player.won then
        game.drawwinscreen()
    else
        game.drawdeathscreen()
    end
end