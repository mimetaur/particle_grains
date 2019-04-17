-- Particle Grains
-- Particle system mapped to simple grains

engine.name = "SimpleGrain"

local v2d = include("particle_grains/lib/vectorial2")

local ParticlePool = include("particle_grains/lib/particle_pool")
local pp = {}

local PlayHead = include("particle_grains/lib/playhead")
local play_head = {}

local Billboard = include("billboard/lib/billboard")
local billboard = Billboard.new()

local clock = {}
local redraw_clock = {}
local spawn_rate = 10
local spawn_ticks = 0

local wind = 0.02
local spawn_amount = 0
local lower_bound = 0
local upper_bound = 64

-- arc
local Arcify = include("arcify/lib/arcify")
local my_arc = arc.connect()
local arcify = Arcify.new(my_arc, false)

local function spawn_particles()
    for i = 1, spawn_amount do
        pp:spawn_particles()
    end
end

local function update()
    if spawn_ticks > spawn_rate then
        pp:spawn_particles()
        spawn_ticks = 0
    end
    pp:update(play_head)

    spawn_ticks = spawn_ticks + 1
end

function init()
    math.randomseed(os.time())

    play_head = PlayHead.new()
    pp = ParticlePool.new()

    clock = metro.init(update, 0.01, -1)
    clock:start()

    local function draw_particles()
        redraw()
    end
    draw_clock = metro.init(draw_particles, 1 / 25, -1)
    draw_clock:start()

    local cloud_lower_bound_cs = controlspec.new(0, 64, "lin", 1, 0, "px") -- minval, maxval, warp, step, default, units
    params:add {
        type = "control",
        id = "cloud_lower_bound",
        name = "cloud lower bound",
        controlspec = cloud_lower_bound_cs,
        action = function(val)
            billboard:display_param("cloud top", val)
            lower_bound = val
            pp:set_cloud_top(val)
            arcify:redraw()
        end
    }

    local cloud_upper_bound_cs = controlspec.new(0, 64, "lin", 1, 64, "px") -- minval, maxval, warp, step, default, units
    params:add {
        type = "control",
        id = "cloud_upper_bound",
        name = "cloud upper bound",
        controlspec = cloud_upper_bound_cs,
        action = function(val)
            billboard:display_param("cloud bottom", val)

            upper_bound = val
            pp:set_cloud_bottom(val)
            arcify:redraw()
        end
    }

    local wind_cs = controlspec.new(0, 20, "lin", 1, 5) -- minval, maxval, warp, step, default
    params:add {
        type = "control",
        id = "wind",
        name = "wind amount",
        controlspec = wind_cs,
        action = function(val)
            if val == 0 then
                wind = 0
            else
                wind = val / 500
            end
            pp:set_wind(wind)
            billboard:display_param("wind", val)
            arcify:redraw()
        end
    }

    params:add {
        type = "control",
        id = "spawn_rate",
        name = "spawn rate",
        controlspec = controlspec.new(100, 1000, "lin", 10, 200, "ms"), -- minval, maxval, warp, step, default, units
        action = function(val_in_ms)
            spawn_rate = math.ceil(val_in_ms / 10)
            billboard:display_param("spawn rate", val_in_ms)
            arcify:redraw()
        end
    }

    spawn_amount = 4
    params:add {
        type = "number",
        id = "spawn_amount",
        name = "spawn amount",
        min = 0,
        max = 4,
        default = 1,
        action = function(val)
            local v = math.ceil(val)
            billboard:display_param("spawn amount", v)
            spawn_amount = v
            arcify:redraw()
        end
    }

    params:add {
        type = "control",
        id = "mass",
        name = "grain mass",
        controlspec = controlspec.new(0, 1, "lin", 0.01, 0.2, "g"),
        action = function(val)
            billboard:display_param("mass", val .. " g")
            arcify:redraw()
        end
    }

    arcify:register("wind", 0.25)
    arcify:register("mass", 0.01)
    arcify:register("cloud_lower_bound", 1)
    arcify:register("cloud_upper_bound", 1)
    arcify:register("spawn_amount", 1)
    arcify:register("spawn_rate", 10)

    arcify:add_params()

    params:default()

    spawn_particles()

    arcify:redraw()
end

function redraw()
    screen.clear()

    pp:draw()
    play_head:draw()
    billboard:draw()

    screen.update()
end
