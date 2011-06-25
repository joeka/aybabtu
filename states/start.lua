local start = Gamestate.new()

function start:init()
	font_big = love.graphics.newFont(24)
	font_bigger = love.graphics.newFont(48)

	joysticks = {}
	for i = 0, love.joystick.getNumJoysticks() - 1 do
		if love.joystick.isOpen(i) then
			joysticks[#joysticks + 1] = i
		end
	end

end	

function start:draw()
	love.graphics.setFont(font_bigger)
	love.graphics.setColor(255,255,255)
	love.graphics.print("hello", 100, 300)

	local texts = {
		{"this game is called AYBABTU", 100, 500},
		{"or All your balls are belong to us", 200, 200 },
		{"have fun", 400, 300},
		{"press any key", 50, 550 }
	}
	for i, text in pairs(texts) do
		love.graphics.setFont(font_bigger)
		love.graphics.setColor(255,255,255)
		love.graphics.print(text[1], text[2], text[3])
	end
	drawPowerups()
end

function drawPowerups()
	local x,y = 100, 100
	
	love.graphics.setFont(font_bigger)
	love.graphics.setColor(0,255,0)
	love.graphics.print('powerups', 50 , 50 )
	local powerups = {}
	powerups["M"] = "get a magnet"
	powerups["G"] = "gravity in your direction"
	powerups["P"] = "more power!"
	
	for key, text in pairs(powerups) do
		love.graphics.setColor(255,255,255)
		love.graphics.circle("fill", x, y, 15, 15)
		love.graphics.setColor(0,255,0)
		love.graphics.circle("line", x, y, 15, 15)
		love.graphics.setFont(font_big)
		love.graphics.print(key, x-10, y-11)
		love.graphics.setColor(0,0,0)
		love.graphics.print(key, x-10, y-11)
		
		love.graphics.setColor(255,255,255)
		love.graphics.print(text, x + 30, y - 11)

		y = y + 50
	end
end


function start:enter(previous)
end

function start:update(dt)
	for _, joystick in pairs(joysticks) do
		if love.joystick.isDown( joystick, 1,2,3,4 ) then
			Gamestate.switch(states.game)
		end
	end
end

function start:keyreleased(key)
	if key == "escape" then
		love.event.push('q')
	else
		Gamestate.switch(states.game)
	end
end
return start
