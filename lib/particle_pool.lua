--- ParticlePool class.

local ParticlePool = {}
ParticlePool.__index = ParticlePool

local FREE_PARTICLES = 100
local RELOAD_LIBS = true

local v2d = require "grains/lib/vectorial2"

local libs = {
    particle_path = "grains/lib/particle"
}
local Particle = require(libs.particle_path)

if RELOAD_LIBS then
    local reload_libraries = require "grains/lib/reload_libraries"
    reload_libraries.with_table(libs)
end

function ParticlePool.new(num_particles)
    math.randomseed(os.time())

    local newpp = {}
    newpp.particles_ = {}
    newpp.free_ = {}
    newpp.wind_ = 0
    newpp.cloud_top_ = 0
    newpp.cloud_bottom_ = 64

    local num = num_particles or FREE_PARTICLES

    for i = 1, num do
        local p = Particle.new()
        table.insert(newpp.free_, p)
    end

    setmetatable(newpp, ParticlePool)
    return newpp
end

function ParticlePool:spawn_particles()
    if #self.free_ then
        local p = table.remove(self.free_)
        table.insert(self.particles_, p)
    else
        print("No more free particles")
    end
end

function ParticlePool:update(play_head)
    local wind_force = v2d.Vector2D(-1 * self.wind_, 0)
    local idxs_to_remove = {}
    for i, p in ipairs(self.particles_) do
        p:apply_force(wind_force)
        p:update()
        if play_head:did_collide(p) then
            play_head:brighten()
            p:emit()
            p:die()
        end
        if p:is_dead() then
            local x = 130
            local y = math.random(self.cloud_top_, self.cloud_bottom_)
            p:reset(x, y)
            table.insert(self.free_, p)
            table.insert(idxs_to_remove, i)
        end
    end
    -- because we can't directly screw around with
    -- the number of items in an array while iterating
    -- thru it. queues up particles to remove
    for _, idx in ipairs(idxs_to_remove) do
        table.remove(self.particles_, idx)
    end
end

function ParticlePool:draw()
    for _, p in ipairs(self.particles_) do
        p:draw()
    end
end

function ParticlePool:set_wind(new_wind)
    self.wind_ = new_wind
end

function ParticlePool:set_cloud_top(new_ct)
    self.cloud_top_ = new_ct
end

function ParticlePool:set_cloud_bottom(new_cb)
    self.cloud_bottom_ = new_cb
end

function ParticlePool:num_particles()
    return #self.particles_, #self.free_
end

return ParticlePool
