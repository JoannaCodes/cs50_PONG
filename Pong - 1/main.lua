--With Ball Collision, Paddle Limitation, FPS, Ball & Paddle Class, Gamestates (start & play), Window Title

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

--Random Generator
    math.randomseed(os.time())

-->>NEW!
    love.window.setTitle('Pong')

--Fonts
Message = "Start State"
TitleFont = love.graphics.newFont('NightmareCodehack-lrA5.ttf', 25)
ScoreFont = love.graphics.newFont('font.ttf', 40)
InstructionFont = love.graphics.newFont('font.ttf', 8)

--Windows look
push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WIDTH, HEIGHT, { 
    fullscreen = false,
    resizable = false,
    vsync = true
})

--Paddles NEW!
    Player1 = Paddle(10, 40, 5, 30) --LEFT
    Player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT / 3, 5, 30) --RIGHT

--Scores
    P1Score = 0 --LEFT
    P2Score = 0 --RIGHT

--Ball NEW!
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 100)

--GameState NEW!
    gamestate = 'start'
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    --NEW!
    elseif key == 'enter' or key == 'return' then
        Message = "Play State"

        if gamestate == 'start' then
            gamestate = 'play' --Game starts

        else
            Message = "Start State" --if the user pressed Enter again it will reset
            gamestate = 'start'

            --Reset Update
            ball:reset()
        end
    end
end

function love.update(dt)
--->>>NEW!
    --Player 1 movement (Left); with limitation within the screen Update
    if love.keyboard.isDown('w') then
        Player1.dy = -PADDLE_SPEED --sets self.dy since it has no value in the Paddle class

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
        Player2.dy = 0
    end

    Player1:update(dt)
    Player2:update(dt)

  --Ball movement NEW!
    if gamestate == 'play' then

        ball:update(dt)

        --Ball collision to left paddle
        if ball:collision(Player1) then
            ball.dx = -ball.dx * 1.05 --once collision is detedcted, direction of the ball will change (Bounce)
            ball.x = Player1.x + 5 --if collision is detected, this code will shift the ball to the paddle edge so it wont repeat the collision detection

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150) --sets a random direction once it bounce up
            else
                ball.dy = math.random(10, 150) --sets a random direction once it bounce down
            end
        end

        --Ball collision to right paddle
        if ball:collision(Player2) then
            ball.dx = -ball.dx * 1.05 -- * 1.05 adds speed to the ball
            ball.x = Player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        --Ball upper anf lower boundary limitation
        if ball.y <= 0  then
            ball.y = 0 --ball limitation
            ball.dy = -ball.dy --Bounce down from the upper wall
        end

        if ball.y >= VIRTUAL_HEIGHT - 4  then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy --Bounce up from the lower wall
        end
    end
end

function love.draw()
--Start rendering into virtual resolution
    push:apply('start')

--Sets BA
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

--Displays FPS
    DisplayFPS()

--Title
    love.graphics.setFont(TitleFont)
    love.graphics.printf('PONG', 0, 5, VIRTUAL_WIDTH, 'center')
    
--Instruction
    love.graphics.setFont(InstructionFont)
    love.graphics.printf(Message, 0, 30, VIRTUAL_WIDTH, 'center')

--Scores
    love.graphics.setFont(ScoreFont)
    --Player 1 (left)
    love.graphics.print(tostring(P1Score), VIRTUAL_WIDTH / 2 - 70, VIRTUAL_HEIGHT / 3)
    --Player 2 (right)
    love.graphics.print(tostring(P2Score), VIRTUAL_WIDTH / 2 + 50, VIRTUAL_HEIGHT / 3)

--Paddles Output Update
    Player1:render()
    Player2:render()
    
--Ball Output Update
    ball:render()

    push:apply('end')
--End of rendering
end

--NEW!
function DisplayFPS()
    love.graphics.setFont(InstructionFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end