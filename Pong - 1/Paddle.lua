Paddle = Class{}

--Initialization
function Paddle:init(x,y,width,height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    self.dy = 0
end

--Movement with limitation
function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(1, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - 31, self.y + self.dy * dt)
    end
end

--Output
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end