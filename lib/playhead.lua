--- PlayHead class.

local PlayHead = {}
PlayHead.__index = PlayHead

local function contains(self, x, y)
    local does_contain = false
    if x >= self.x_ and y >= self.y_ and x <= self.x_ + self.w_ and y <= self.y_ + self.h_ then
        does_contain = true
    end
    return does_contain
end

function PlayHead.new(x, y, w, h, thickness, brightness)
    local ph = {}
    ph.x_ = x or 0
    ph.y_ = y or 0
    ph.w_ = w or 24
    ph.h_ = h or 64
    ph.thickness_ = thickness or 2
    ph.brightness_ = brightness or 4
    ph.is_bright_ = false

    local function brighten_callback()
        ph.is_bright_ = false
    end
    ph.on_brighten_ = metro.init(brighten_callback, 0.1, 1)

    setmetatable(ph, PlayHead)
    return ph
end

function PlayHead:draw()
    local level_bright = self.brightness_
    if self.is_bright_ then
        level_bright = 14
    end
    screen.level(0)
    screen.rect(self.x_, self.y_, self.w_, self.h_)
    screen.fill()
    screen.level(level_bright)
    local border_x = (self.x_ + self.w_) - self.thickness_
    local border_y = self.y_
    screen.rect(border_x, border_y, self.thickness_, self.h_)
    screen.fill()
end

function PlayHead:did_collide(particle)
    local collided = false
    if contains(self, particle:x(), particle:y()) then
        collided = true
    end
    return collided
end

function PlayHead:brighten()
    self.is_bright_ = true
    self.on_brighten_:start()
end

return PlayHead
