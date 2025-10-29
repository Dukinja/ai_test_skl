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
    game.update(dt)
    food.update(dt)
    player.update(dt)
    orbs.update(dt)
    ai.update(dt)
end

function love.draw()
    if player.death == false then
        bg.draw()
        food.draw()
        player.draw()
        orb.draw()
        ai.draw()
        hud.draw()
    else
        game.drawdeathscreen()
    end
end