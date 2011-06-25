local result = Gamestate.new()

function result:enter(previous)
	result.keyreleased = states.game.keyreleased

	score = previous.score

	love.graphics.setFont(font_big)

	if score[1] > score[2] then
		winner = "The left player"
		love.graphics.setColor(0,0,255)
		align = "left"
	elseif score[1] < score[2] then
		winner = "The right player"
		love.graphics.setColor(255,0,0)
		align = "right"
	else
		winner = "Nobody"
		align = "center"
	end
end

function result:draw()
	love.graphics.printf(winner.." has won the game.", 50, 250, 700, align)
end

return result
