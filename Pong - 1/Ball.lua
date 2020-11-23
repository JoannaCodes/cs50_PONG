Ball = Class{} --NEW!

--Initialization
function Ball:init(x, y, radius, segments)
    self.x = x
    self.y = y
    self.radius = radius
    self.segments = segments

    --Ball's velocity
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)
end

--Reset
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 -2
    
    --Ball's velocity
    self.dx = math.random(2) * 1.5 == 1 and -100 or 100
    self.dy = math.random(-50, 50)
end

--Movement
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

--Ball Collision --NEW!
function Ball:collision(paddle)
    --No collision
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.radius then
        return false
    end

    --No collision
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.radius then
        return false
    end

    --There is collision
    return true
end

--Output
function Ball:render()
    love.graphics.circle('fill', self.x, self.y, self.radius, self.segments)
end