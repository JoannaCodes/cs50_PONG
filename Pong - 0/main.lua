push = require 'push'

WIDTH = 1280
HEIGHT = 720

VIRTUAL_WIDTH = 432 -- %34 0f 1280
VIRTUAL_HEIGHT = 243 -- %34 of 720

PADDLE_SPEED = 200

function love.load()
--Filter for virtual resolution
    love.graphics.setDefaultFilter('nearest', 'nearest')

--Random Generator Initializer
    math.randomseed(os.time())

--Paddles
    Paddle1 = 40
    Paddle2 = VIRTUAL_HEIGHT - 60

--Scores
    P1Score = 0
    P2Score = 0

--Ball
    BallX = VIRTUAL_WIDTH / 2 - 2
    BallY = VIRTUAL_HEIGHT / 2 - 2

--Ball Velocity
    BallSpeedX = math.random(2) == 1 and 100 or -100 -- same as math.random(2) == 1 ? 100 : -100
    BallSpeedY = math.random(-50, 50)

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

--GameState
    gamestate = 'start'
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        Message = "Play State"
        if gamestate == 'start' then
            gamestate = 'play'
        else
            Message = "Start State"
            gamestate = 'start'

            --Re-initialize (Reset)
            BallX = VIRTUAL_WIDTH / 2 - 2
            BallY = VIRTUAL_HEIGHT / 2 - 2

            BallSpeedX = math.random(2) == 1 and 100 or -100
            BallSpeedY = math.random(-50, 50) * 1.05
        end
    end
end

function love.update(dt)
--Player 1 movement; with limitation within the screen
    if love.keyboard.isDown('w') then
        Paddle1 = math.max(1, Paddle1 - PADDLE_SPEED * dt)

    elseif love.keyboard.isDown('s') then
        Paddle1 = math.min(VIRTUAL_HEIGHT - 31, Paddle1 + PADDLE_SPEED * dt)
    end

--Player 2 movement; with limitation within the screen
    if love.keyboard.isDown('up') then
        Paddle2 = math.max(1, Paddle2 - PADDLE_SPEED * dt)

    elseif love.keyboard.isDown('down') then
        Paddle2 = math.min(VIRTUAL_HEIGHT - 31, Paddle2 + PADDLE_SPEED * dt)
    end

--Ball movement
    if gamestate == 'play' then
        BallX = BallX + BallSpeedX * dt
        BallY = BallY + BallSpeedY * dt
    end
end

function love.draw()
--Start rendering into virtual resolution
    push:apply('start')

--Sets Background Color
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

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

--Paddles
    --Paddle1 (left)
    love.graphics.rectangle('fill', 10, Paddle1, 5, 30)
    --Paddle2 (right)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 15, Paddle2, 5, 30)
    
--Ball
    love.graphics.circle('fill', BallX, BallY, 4, 50)

    push:apply('end')
--End of rendering
end