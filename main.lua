Class = require "hump.class"
Gamestate = require "hump.gamestate"
Vector = require "hump.vector"
Timer = require "hump.timer"

function love.load()
	states = {}
	states.game = require "states.game"
	states.result = require "states.result"

	Gamestate.registerEvents()
	Gamestate.switch(states.game)
end
