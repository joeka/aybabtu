Class = require "hump.class"
Gamestate = require "hump.gamestate"
Vector = require "hump.vector"
Timer = require "hump.timer"

function love.load()
	states = {}
	states.game = require "states.game"
	states.result = require "states.result"
	states.start = require "states.start"

	Gamestate.registerEvents()
	Gamestate.switch(states.start)
end
