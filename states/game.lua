local game = Gamestate.new()

function game:init()
	math.randomseed(os.time())

	--love.graphics.setBlendMode('additive')
	love.graphics.setLineWidth(2)

	font_small = love.graphics.newFont(12)
	font_big = love.graphics.newFont(24)

	background = love.graphics.newFramebuffer()
	tmp_buffer = love.graphics.newFramebuffer()
	background:renderTo(drawBackground)

	objects = {}
	players = {}
	powerup = nil

	dead_powerup = nil 

	world = love.physics.newWorld(0,0,800,900)
	world:setMeter(32)
	world:setCallbacks(collisionAdd)--, collisionPersist, collisionRem, collisionResult)

	createBorders()

	-- Create Players
	players[1] = {}
	players[1][1] = love.physics.newBody(world, 600, 300, 5, 0)
	players[1][2] = love.physics.newCircleShape(players[1][1], 0, 0, 15)
	players[1][2]:setData(players[1])
	players[2] = {}
	players[2][1] = love.physics.newBody(world, 200, 300, 5, 0)
	players[2][2] = love.physics.newCircleShape(players[2][1], 0, 0, 15)
	players[2][2]:setData(players[2])

	players[1].power_multiplier, players[2].power_multiplier = 1,1

	players[1].controls = {
		left="left",
		right="right",
		up="up",
		down="down",
		joystick=0
	}
	players[2].controls = {
		left="a",
		right="d",
		up="w",
		down="s",
		joystick=1
	}
	movement_force = 50
	range = 170

	powerup_timeout = 5

	number_of_objects = 13
	timelimit = 180
	
	createObjects()

	bar = {}
	bar[1] = love.physics.newBody(world, 400, 900, 0, 0)
	bar[2] = love.physics.newRectangleShape(bar[1], 0, 0, 20, 600)
	bar[2]:setMask(2)

	powerup_delay = 30

	Timer.add( math.random(powerup_delay, powerup_delay * 1.5), spawnPowerup )

	Timer.add( 2, function() buildTree(10, math.floor(800 / timelimit)) end )
	tree = {}
	
	powerups = {}
	createPowerups()
end

function activatePowerup( player_num, powerup_key )
	players[player_num].powerup = powerup_key
	if powerup_key == "M" then
		local x,y = players[player_num][1]:getPosition()
		x = x - math.pow(-1, player_num) * 200
		players[player_num].magnet = {}
		players[player_num].magnet[1] = love.physics.newBody(world, x, y, 0, 0)
		players[player_num].magnet[2] = love.physics.newCircleShape(
			players[player_num].magnet[1], 0, 0, 15)
	elseif powerup_key == "G" then
		world:setGravity( -10 * math.pow(-1, player_num) ,0)
	elseif powerup_key == "P" then
		players[player_num].power_multiplier = 2
	end
	Timer.add( powerup_timeout, function() deactivatePowerup(player_num) end)
end

function deactivatePowerup( player_num )
	if players[player_num].powerup == "M" then
		players[player_num].magnet[1]:destroy()
		players[player_num].magnet[2]:destroy()
		players[player_num].magnet = nil
	elseif players[player_num].powerup == "G" then
		world:setGravity(0,0)
	elseif players[player_num].powerup == "P" then
		players[player_num].power_multiplier = 1
	end

	players[player_num].powerup = nil
end

function collisionAdd( a, b, coll )
	if powerup then
		if a == powerup then
			if b == players[1] then
				activatePowerup(1, powerup[3])
				destroyPowerup(nil, 1)
			elseif b == players[2] then
				activatePowerup(2, powerup[3])
				destroyPowerup(nil, 1)
			end

		elseif b == powerup then
			if a == players[1] then
				activatePowerup(1, powerup[3])
				destroyPowerup(nil, 1)
			elseif a == players[2] then
				activatePowerup(2, powerup[3])
				destroyPowerup(nil, 1)
			end
		end
	end
end
--[[function collisionPersist( a, b, coll )

end
function collisionRem( a, b, coll )

end
function collisionResult( a, b, coll )

end]]--

function createPowerups()
	for _, key in pairs({"M","G","P"}) do
		powerups[key] = love.graphics.newFramebuffer( 30, 30 )
	end
	for key, buffer in pairs(powerups) do
		buffer:renderTo( function ()
			love.graphics.setColor(255,255,255)
			love.graphics.circle("fill", 15, 15, 15, 15)
			love.graphics.setColor(0,255,0)
			love.graphics.circle("line", 15, 15, 15, 15)
			love.graphics.setFont(font_big)
			love.graphics.print(key, 6, 3)
			love.graphics.setColor(0,0,0)
			love.graphics.print(key, 5, 2)
		end)
	end
end

function spawnPowerup()
	local num = math.random(1,3)
	local key = ({"M","G","P"})[num]

	powerup = {}
	powerup[1] = love.physics.newBody(world, 400, (bar[1]:getY()-300)*2/5)
	powerup[2] = love.physics.newCircleShape(powerup[1] , 0, 0, 15)
	powerup[3] = key
	powerup[2]:setSensor( true )
	powerup[2]:setData(powerup)

	Timer.add( math.random(3, 10), destroyPowerup)
end

function destroyPowerup( _, mode )
	if powerup then
		local x,y = powerup[1]:getPosition()
		local mode = mode or -1
		dead_powerup = { x, y+15, 15, mode }

		powerup[1]:destroy()
		powerup[2]:destroy()
		powerup = nil
		powerup_delay = powerup_delay * 0.9
		Timer.add( math.random(powerup_delay, powerup_delay * 1.5), spawnPowerup )
	end
end

function drawBackground()
	love.graphics.setColor(255,255,255)

	love.graphics.line( 400, 0, 400, 600 )

	love.graphics.rectangle("fill",0,0,800,4)
	love.graphics.rectangle("fill",0,596,800,4)
	love.graphics.rectangle("fill",0,0,4,600)
	love.graphics.rectangle("fill",796,0,4,600)
end

function createObjects()
	for i = 1,2 do
		for j = 1, number_of_objects do
			k =  #objects + 1
			local x = math.random( 5 + 400 * (i-1), 395 + 400 * (i-1) )
			local y = math.random( 5, 595 )
			objects[k] = {}
			objects[k][1] = love.physics.newBody(world, x, y, 5, 0)
			objects[k][2] = love.physics.newCircleShape(objects[k][1], 0, 0, 10)
			
			-- wie? objects[k][1]:setInertia(0.1)
		end
	end
end

function createBorders()
	borders = {{},{},{},{}}
	borders[1][1] = love.physics.newBody(world, 400, 0, 0, 0)
	borders[1][2] = love.physics.newRectangleShape(borders[1][1], 0, 0, 800, 8)
	borders[2][1] = love.physics.newBody(world, 400, 600, 0, 0)
	borders[2][2] = love.physics.newRectangleShape(borders[2][1], 0, 0, 800, 8)
	borders[3][1] = love.physics.newBody(world, 0, 300, 0, 0)
	borders[3][2] = love.physics.newRectangleShape(borders[3][1], 0, 0, 8, 600)
	borders[4][1] = love.physics.newBody(world, 800, 300, 0, 0)
	borders[4][2] = love.physics.newRectangleShape(borders[4][1], 0, 0, 8, 600)
	for _, border in pairs(borders) do
		border[2]:setCategory(2)
	end
end

function game:enter(previous)
end

function game:update(dt)
	playerMovement(players[1])
	playerMovement(players[2])

	pushPlayers()
	attractObjects()
	
	local bar_y = bar[1]:getY()
	bar[1]:setPosition(400, bar_y - (800 / timelimit)  * dt)
	
	if bar_y < 300 then
		Gamestate.switch(states.result)
	end

	if dead_powerup then
		powerupAnimation(dt)
	end

	world:update(dt)
	Timer.update(dt)
end

function attractObjects()
	for i, player in pairs(players) do
		local p_vec = Vector(player[1]:getPosition())
		local m_vec = nil
		if player.magnet then
			m_vec = Vector(player.magnet[1]:getPosition())
		end
		for j, object in pairs(objects) do
			local o_vec = Vector(object[1]:getPosition())
			local dir = p_vec - o_vec
			if dir:len() <= range then
				local force_vector = (dir:normalized() * range - dir) * 0.05
				object[1]:applyForce(
					(force_vector*player.power_multiplier):unpack())
				player[1]:applyForce((force_vector * -0.86):unpack())
			end
			if m_vec then
				local dir = m_vec - o_vec
				if dir:len() <= range then
					local force_vector = (dir:normalized() * range - dir) * 0.05
					object[1]:applyForce(force_vector:unpack())
				end
			end
		end
	end
end

function pushPlayers()
	local dir = Vector(players[1][1]:getPosition()) - Vector(players[2][1]:getPosition())
	
	if dir:len() <= range then
		local force_vector = dir:normalized() * range - dir
		players[1][1]:applyForce(
			(force_vector*players[2].power_multiplier):unpack())
		players[2][1]:applyForce(
			(force_vector*players[1].power_multiplier * -1):unpack())
	end
	for i = 1,2 do
		if players[i].magnet then
			for j = 1,2 do
				local dir = Vector(players[j][1]:getPosition()) - Vector(players[i].magnet[1]:getPosition())
				
				if dir:len() <= range then
					local force_vector = dir:normalized() * range - dir
					players[j][1]:applyForce(force_vector:unpack())
				end
			end
		end
	end
end

function playerMovement(player)
	local dir = {0, 0}
	
	local joy_axes = {0, 0}

	if player.controls.joystick and love.joystick.isOpen(player.controls.joystick) then
		joy_axes = { love.joystick.getAxes(player.controls.joystick) }
	end

	if love.keyboard.isDown(player.controls.left) or joy_axes[1] < 0 then
		dir[1] = dir[1] - movement_force
	end
	if love.keyboard.isDown(player.controls.right) or joy_axes[1] > 0 then
		dir[1] = dir[1] + movement_force
	end
	if love.keyboard.isDown(player.controls.up) or joy_axes[2] < 0 then
		dir[2] = dir[2] - movement_force
	end
	if love.keyboard.isDown(player.controls.down) or joy_axes[2] > 0 then
		dir[2] = dir[2] + movement_force
	end
	
	if dir[1] ~= 0 or dir[2] ~= 0 then
		player[1]:applyForce(dir[1], dir[2])
	end
end

function drawMagnet( player_num )
	local key = "M"
	local x,y = players[player_num].magnet[1]:getPosition()
	love.graphics.setColor(255,255,255)
	love.graphics.circle("fill", x, y, 15, 15)
	if player_num == 1 then
		love.graphics.setColor(255,0,0)
	else
		love.graphics.setColor(0,0,255)
	end
	love.graphics.circle("line", x, y, 15, 15)
	love.graphics.setFont(font_big)
	love.graphics.print(key, x-10, y-12)
end

function drawPowerups()
	if powerup then
		love.graphics.draw(powerups[powerup[3]], powerup[1]:getX()-15, powerup[1]:getY())
	end
	if dead_powerup and dead_powerup[3] > 0 then
		love.graphics.setColor(0,255,0)
		love.graphics.circle("line", dead_powerup[1], dead_powerup[2],
				dead_powerup[3], 15)
	end
	if players[1].powerup then
		love.graphics.draw(powerups[players[1].powerup], 630, 10, 0, 0.5, 0.5)
		if players[1].powerup == "M" then
			drawMagnet( 1 )
		end
	end
	if players[2].powerup then
		love.graphics.draw(powerups[players[2].powerup], 170, 10, 0, 0.5, 0.5)
		if players[2].powerup == "M" then
			drawMagnet( 2 )
		end
	end
end

function powerupAnimation(dt)
	if dead_powerup[3] <= 0 or dead_powerup[3] >= 30 then
		dead_powerup = nil
	else
		dead_powerup[3] = dead_powerup[3] + dead_powerup[4] * dt * 40
	end
end

function game:draw()
	if #tree > 0 then
		tmp_buffer:renderTo(drawTree)
		background:renderTo(function()
			love.graphics.setColor(255,255,255)
			love.graphics.draw(tmp_buffer)
		end)
	end
	love.graphics.draw(background)
	
	love.graphics.setColor(255,255,255)
	
	drawObjects()

	drawPlayers()

	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", bar[1]:getX() - 10,
					bar[1]:getY() - 300
					,20 ,600)
	
	drawPowerups()
	
	score()
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(font_small)
	love.graphics.print( love.timer.getFPS(), 10,10)
end

function score()
	local left = 0
	local right = 0
	
	for _, object in pairs(objects) do
		if object[1]:getX() < 400 then
			left = left + 1
		else
			right = right + 1
		end
	end
	love.graphics.setFont(font_big)
	love.graphics.setColor(0,0,255)
	love.graphics.print(left, 195, 10)
	love.graphics.setColor(255,0,0)
	love.graphics.print(right, 595, 10)
	
	game.score = {left, right}
end

function drawObjects()
	for _, object in pairs(objects) do
		love.graphics.circle("fill", object[1]:getX(), object[1]:getY(),
		                object[2]:getRadius(), 15)
	end
end

function drawPlayers()
	-- Player 1
	love.graphics.setColor(255,0,0)
	love.graphics.circle("fill", players[1][1]:getX(), players[1][1]:getY(),
		players[1][2]:getRadius(), 15)
	-- Player 2
	love.graphics.setColor(0,0,255)
	love.graphics.circle("fill", players[2][1]:getX(), players[2][1]:getY(),
		players[2][2]:getRadius(), 15)
end

function game:keyreleased(key)
	if key == "escape" then
		love.event.push('q')
	elseif key == "backspace" then
		states.game = love.filesystem.load("states/game.lua")()
		Gamestate.switch(states.game)
	end
end

function game:mousereleased(x, y, btn)
end

function buildTree(limit, delay, pos, dir)
	if not pos then
		if math.random(0,1) == 0 then
			pos = Vector(bar[1]:getX()-10, bar[1]:getY()-300)
			dir = Vector(-1,0)
		else
			pos = Vector(bar[1]:getX()+10, bar[1]:getY()-300)
			dir = Vector(1,0)
		end
		local new_delay = delay
		if new_delay > 1 then
			new_delay = new_delay -0.1
		end

		Timer.add( math.random(delay/2, delay*2),
			function() buildTree(limit+1, new_delay) end )
	end
	local delay = delay or 4
	local new_limit = math.random(0, (limit or 5) -1)
	if new_limit == 0 then
		local len = math.random(5,10)
		local new_dir = dir:normalized() * len
		local rot = math.random(-6, 6)
		new_dir:rotate_inplace( math.pi * rot / 18 )
		local new_pos = pos + new_dir
		
		local color = {}
		if new_pos.x < 400 then
			color = { 0, 0, 255 }
		else
			color = { 255, 0, 0 }
		end
		tree[#tree + 1] = {pos, new_pos, color}
	else
		local len = math.random(10,20)
		local new_dir = dir:normalized() * len
		local rot = math.random(-6, 6)
		new_dir:rotate_inplace( math.pi * rot / 18 )
		local new_pos = pos + new_dir

		
		tree[#tree + 1] = {pos, new_pos, 
			{math.random(25,255),math.random(25,255),math.random(25,255)}}
		
		Timer.add( math.random(math.floor(delay/2), delay*2),
			function() buildTree(new_limit, delay, new_pos, new_dir) end )
		Timer.add( math.random(math.floor(delay/2), delay*2),
			function() buildTree(new_limit, delay, new_pos, new_dir) end )
	end
end

function drawTree()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(background)
	while #tree > 0 do
		local i = #tree
		local x1, y1 = tree[i][1]:unpack()
		local x2, y2 = tree[i][2]:unpack()
		love.graphics.setColor(tree[i][3][1], tree[i][3][2], tree[i][3][3])
		love.graphics.line(x1, y1, x2, y2)
		table.remove(tree, i)
	end
end

return game
