--- Particle class.

local Particle = {}
Particle.__index = Particle

local v2d = include("particle_grains/lib/vectorial2")

local function contains_point(x1, y1, x2, y2, x, y)
    local contains = false
    if (x > x1 and x < x2 and y > y1 and y < y2) then
        contains = true
    end
    return contains
end

function Particle.new(x, y)
    local p = {}
    x = x or 0
    y = y or 0
    p.position_ = v2d.Vector2D(x, y)

    local vx = (0.5 - math.random()) * 0.25
    local vy = (0.5 - math.random()) * 0.25
    p.velocity_ = v2d.Vector2D(vx, vy)
    p.acceleration_ = v2d.Vector2D(0, 0)

    p.is_dead_ = false
    p.age_ = 15
    p.aging_speed_ = math.random() * 0.075

    setmetatable(p, Particle)
    return p
end

function Particle:reset(x, y)
    x = x or 130
    y = y or math.random(0, 64)
    self.position_:setX(x)
    self.position_:setY(y)
    local vx = (0.5 - math.random()) * 0.25
    local vy = (0.5 - math.random()) * 0.25
    self.velocity_:setX(vx)
    self.velocity_:setY(vy)
    self.acceleration_:setX(0)
    self.acceleration_:setY(0)
    self.is_dead_ = false
    self.age_ = 15
    self.aging_speed_ = math.random() * 0.075
end

function Particle:apply_force(force)
    local m = params:get("mass")
    local fx = force:getX() * (1 - m)
    local fy = force:getY() * (1 - m)
    local adj_force = v2d.Vector2D(fx, fy)
    self.acceleration_ = self.acceleration_ + adj_force
end

function Particle:update()
    self.velocity_ = self.velocity_ + self.acceleration_
    self.position_ = self.position_ + self.velocity_
    self.acceleration_:setX(0)
    self.acceleration_:setY(0)

    self.age_ = self.age_ - self.aging_speed_
    if (self.age_ < 1) then
        self:die()
    end
end

function Particle:draw()
    local x = math.ceil(self:x())
    local y = math.ceil(self:y())
    screen.level(math.ceil(self.age_))
    local m = math.ceil(10 * params:get("mass"))
    screen.pixel(x, y)
    for i = 1, m do
        screen.pixel(x + i, y)
    end
    screen.fill()
end

function Particle:emit()
    local mag = math.sqrt(self:x() * self:y())
    local nmag = util.linlin(0, 36, 0, 1, mag)
    nmag = util.clamp(nmag, 0, 1)
    local reduce = 0.5
    engine.amp(nmag * reduce)

    local mass = params:get("mass")
    local dur = math.ceil(util.linlin(0, 1, 20, 500, mass))

    local high = dur + 100
    local low = dur
    engine.dur(math.random(low, high))

    local pan = util.linlin(0, 64, -1, 1, self:y())
    engine.pan(pan)

    local freq = util.linlin(0, 64, 200, 1100, 64 - self:y())
    engine.hz(freq)
end

function Particle:die()
    self.is_dead_ = true
end

function Particle:is_dead()
    return self.is_dead_
end

function Particle:position()
    return self.position_
end

function Particle:x()
    return self.position_:getX()
end

function Particle:y()
    return self.position_:getY()
end

return Particle
