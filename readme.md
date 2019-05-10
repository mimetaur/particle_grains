## Particle Grains

Particle Grains uses simple granular synthesis techniques to produce sound. Each particle on the screen is an individual sonic grain, and through adding forces like wind and gravity, you can push grains into the sonic resonator on the left side of the screen at varying rates.

### Notes
* The spawn rate and max number of particles may seem particularly low. This is a limitation of the Norns OS. Because Lua is single threaded, large numbers of particles block the input and menu subsystems among others.