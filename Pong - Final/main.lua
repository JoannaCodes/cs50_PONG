--With Sound, Function Fixes, Resize

push = require 'push'
Class = require 'class'

require 'Ball'
require 'Paddle'

WIDTH = 1280
HEIGHT = 720

VIRTUAL_WIDTH = 432 -- %34 0f 1280
VIRTUAL_HEIGHT = 243 -- %34 of 720

PADDLE_SPEED = 200

function love.load()
--Filter for virtual resolution
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    love.window.setTitle('Pong')

--Fonts
TitleFont = love.graphics.newFont('NightmareCodehack-lrA5.ttf', 25)
ScoreFont = love.graphics.newFont('font.ttf', 40)
InstructionFont = love.graphics.newFont('font.ttf', 8)

--Sounds (NEW!)
    Sounds = {
        ['Paddle_hit'] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
        ['Wall_hit'] = love.audio.newSource("sounds/wall_hit.wav", "static"),
        ['Score'] = love.audio.newSource("sounds/score.wav", "static")
    }

--Windows look
push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WIDTH, HEIGHT, { 
    fullscreen = false,
    resizable = true,
    vsync = true
})

--Paddles Update
    Player1 = Paddle(10, 40, 5, 30) --LEFT
    Player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT / 3, 5, 30) --RIGHT

--Scores
    P1Score = 0 --LEFT
    P2Score = 0 --RIGHT

--Ball Update
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 50)

--GameState
    servingPlayer = 1
    gamestate = 'start'
end

-->>NEW!
function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gamestate == 'start' then
            gamestate = 'serve'

        elseif gamestate == 'serve' then
            gamestate = 'play'

        elseif gamestate == 'done' then
            gamestate = 'serve'

            --Reset when game is done
            ball:reset()

            P1Score = 0
            P2Score = 0

        --Switches serving player to the loser
            if winner == 2 then
                servingPlayer = 1
            else
                servingPlayer = 2
            end
        end
    end
end

function love.update(dt)
--Gives direction to the ball which player to move
    if gamestate == 'serve' then
        ball.dy = math.random(-50, 50)

        if servingPlayer == 1 then
            ball.dx = -math.random(100,150)
        else
            ball.dx = math.random(100,150)
        end

--Ball movement and collision
    elseif gamestate == 'play' then
        --Ball movement Update
        ball:update(dt)

        if ball:collision(Player1) then
            Sounds['Paddle_hit']:play() -->>NEW!

            ball.dx = -ball.dx * 1.05 --once collision is detedcted, direction of the ball will change
            ball.x = Player1.x + 5 --if collision is detected, this code will shift the ball to the paddle edge so it won't repeat the collision detection

            if ball.dy < 0 then
                ball.dy = -math.random(100,150)
            else
                ball.dy = math.random(100,150)
            end
        end

        if ball:collision(Player2) then
            love.audio.play(Sounds['Paddle_hit']) --or Sounds['Paddle_hit']:play()

            ball.dx = -ball.dx * 1.05 -- * 1.05 adds speed to the ball
            ball.x = Player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(100,150)
            else
                ball.dy = math.random(100, 150)
            end
        end

        --Ball upper anf lower boundary limitation
        if ball.y <= 0  then
            Sounds['Wall_hit']:play() -->>NEW!

            ball.y = 0 --position of the ball now exceeding the boundary
            ball.dy = -ball.dy --bounce effect

        elseif ball.y >= VIRTUAL_HEIGHT - 4  then
            Sounds['Wall_hit']:play() -->>NEW!

            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end

        --Scoring and passing on to another player
        if ball.x < 0 then
            Sounds['Score']:play()  -->>NEW!

            servingPlayer = 1 --passing on to player 1
            P2Score = P2Score + 1

            if P2Score == 10 then
                winner = 2
                gamestate = 'done'
            else
                gamestate = 'serve'
                ball:reset()
            end

        elseif ball.x > VIRTUAL_WIDTH then
            Sounds['Score']:play()  -->>NEW!

            servingPlayer = 2
            P1Score = P1Score + 1

            if P1Score == 10 then
                winner = 1
                gamestate = 'done'
            else
                gamestate = 'serve'
                ball:reset()
            end
        end
    end

--Player 1 movement (Left); with limitation within the screen Update
    if love.keyboard.isDown('w') then
        Player1.dy = -PADDLE_SPEED

    elseif love.keyboard.isDown('s') then
        Player1.dy = PADDLE_SPEED

    else
        Player1.dy = 0 --no movement
    end

--Player 2 movement (right); with limitation within the screen Update
    if love.keyboard.isDown('up') then
        Player2.dy = -PADDLE_SPEED

    elseif love.keyboard.isDown('down') then
        Player2.dy = PADDLE_SPEED

    else
        Player2.dy = 0 --no movement
    end

    -- AI Implementation
    if gamestate == 'play' then
        --player 1 AI with decceleration
        if ball.dx < 0 then
            if Player1.y + 10 <= ball.y + 2 then
                Player1.dy = PADDLE_SPEED
                if ball.x < VIRTUAL_WIDTH / 4 then
                    Player1.dy = PADDLE_SPEED * 0.5
                    if Player1.dy < 20 then
                        Player1.dy = 20
                    end
                end
            else
                Player1.dy = -PADDLE_SPEED
                if ball.x < VIRTUAL_WIDTH / 4 then
                    Player1.dy = -PADDLE_SPEED * 0.5
                    if Player1.dy > -20 then
                        Player1.dy = -20
                    end
                end
            end
        end
        
        --player 2 AI
        if ball.dx > 0 then
            if Player2.y + 10 <= ball.y + 2 then
                Player2.dy = PADDLE_SPEED
            else
                Player2.dy = -PADDLE_SPEED
            end
        end

    end

    Player1:update(dt)
    Player2:update(dt)
end

function love.draw()
--Start rendering into virtual resolution
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    DisplayFPS() --Displays FPS

    DisplayScore() --Displays Score

    if gamestate == 'start' then
        love.graphics.setFont(TitleFont)
        love.graphics.printf('PONG', 0, 5, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(InstructionFont)
        love.graphics.printf('Press Enter to Start', 0, 35, VIRTUAL_WIDTH, 'center')

    elseif gamestate == 'serve' then
        love.graphics.setFont(InstructionFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve", 0, 15, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Serve', 0, 25, VIRTUAL_WIDTH, 'center')

    elseif gamestate == 'play' then
        love.graphics.setFont(TitleFont)
        love.graphics.printf('PONG', 0, 5, VIRTUAL_WIDTH, 'center')

    elseif gamestate == 'done' then
        love.graphics.setFont(TitleFont)
        love.graphics.printf('Player ' .. tostring(winner) .. ' wins!',0, 5, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(InstructionFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

--Paddles Output Update
    Player1:render()
    Player2:render()
    
--Ball Output Update
    ball:render()

    push:apply('end')
--End of rendering
end

function DisplayFPS()
    love.graphics.setFont(InstructionFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function DisplayScore()
--Scores
    love.graphics.setFont(ScoreFont)
    --Player 1 (left)
    love.graphics.print(tostring(P1Score), VIRTUAL_WIDTH / 2 - 70, VIRTUAL_HEIGHT / 3)
    --Player 2 (right)
    love.graphics.print(tostring(P2Score), VIRTUAL_WIDTH / 2 + 50, VIRTUAL_HEIGHT / 3)
end