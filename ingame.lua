local Ingame = {}
Ingame.__index = Ingame

function Ingame.new() -- ::Ingame
	local self = setmetatable({},Ingame)
	self:load()
	return self
end

function Ingame:load()
	self.enter_pressed = true
	self.world = nil
	self.score = 0

	love.graphics.setBackgroundColor( 240, 108, 21 )

	love.physics.setMeter( 1 )
	self.world = love.physics.newWorld( 0, 9.8 )
	self.world:setCallbacks(
		Collisions.beginContact,
		Collisions.endContact,
		Collisions.preSolve,
		Collisions.postSolve
	)

	self.namelessvoid = NamelessVoid.new(self.world)
	self.player = Player.new(self.world)
	self.ground = Ground.new(self.world)
	self.pellets = {}
	self.enemies = {}
	self.enemy_spawn_threshold = 2
	self.enemy_spawn_acc = 0.0
	table.insert( self.enemies, Enemy.new(self.world) )
	local meter_width = 16 -- TODO get value
	local meter_height = 9 -- TODO get value
	local bush_height = 1.2
	local bushl_width = 1.4
	local bushr_width = 2.2
	local bush_x_offset = 1.2
	local bush_y = meter_height - 1 - ( bush_height / 2 )
	self.bushl = Bush.new( self.world, bush_x_offset + bushl_width, bush_y, bushl_width, bush_height )
	self.bushr = Bush.new( self.world, meter_width - bush_x_offset - bushr_width, bush_y, bushr_width, bush_height )
end

function Ingame:transition(new_state)
	-- TODO: Clean up and transition
	return new_state.new()
end

function Ingame:free()
end

function Ingame:update(dt, screenmanager) -- ::void!
	self.player:update( dt, screenmanager, self.pellets )
	self.world:update( dt )
	for k, v in pairs( self.pellets ) do
		if v.alive then
			v:update( dt )
		else
			v:free()
			self.pellets[ k ] = nil
		end
	end
	for k, v in pairs( self.enemies ) do
		if v.alive then
			v:update( dt )
		else
			v:free()
			self.enemies[ k ] = nil
			-- TODO gain based on aggro
			self.score = self.score + 1
		end
	end
	self.enemy_spawn_acc = self.enemy_spawn_acc + dt
	if self.enemy_spawn_acc > self.enemy_spawn_threshold then
		self.enemy_spawn_acc = self.enemy_spawn_acc - self.enemy_spawn_threshold
		local spawn_right = false
		if math.random() > 0.5 then spawn_right = true end
		table.insert( self.enemies, Enemy.new( self.world, spawn_right ) )
	end

	self.bushl:update( dt, screenmanager )
	self.bushr:update( dt, screenmanager )

	if not love.keyboard.isDown( 'return' ) then
		self.enter_pressed = false
	end

	if love.keyboard.isDown( 'esc' ) then
		return false
	elseif love.keyboard.isDown( 'return' ) and not self.enter_pressed then
		return Menu
	else
		return nil
	end
end

function Ingame:draw(screenmanager) -- ::void!
	local layers = {}
	for kl, vl in pairs( ScreenManager.layers ) do
		layers[vl] = {}
		if self.bushl.layer ~= nil and self.bushl.layer == vl then
			table.insert( layers[vl], self.bushl )
		end
		if self.bushr.layer ~= nil  and self.bushr.layer == vl then
			table.insert( layers[vl], self.bushr )
		end
		if self.player.layer ~= nil  and self.player.layer == vl then
			table.insert( layers[vl], self.player )
		end
		if self.ground.layer ~= nil  and self.ground.layer == vl then
			table.insert( layers[vl], self.ground )
		end
		for kp, vp in pairs( self.pellets ) do
			if vp.layer ~= nil  and vp.layer == vl then
				table.insert( layers[vl], vp )
			end
		end
		for ke, ve in pairs( self.enemies ) do
			if ve.layer ~= nil  and ve.layer == vl then
				table.insert( layers[vl], ve )
			end
		end
	end
	
	for i = #layers, 1, -1 do
		for ko, vo in pairs( layers[i] ) do
			vo:draw( screenmanager )
		end
	end
	-- Garbage collect?
	for i = #layers, 1, -1 do
		for ko, vo in pairs( layers[i] ) do
			layers[i][vo] = nil
		end
		layers[i] = nil
	end
	layers = nil

	self:draw_score( screenmanager )
end

function Ingame:input(act,val) -- ::void!
end

function Ingame:draw_score( screenmanager )
	love.graphics.setColor( 255, 255, 255 )
	local draw_x, draw_y  = screenmanager:getScreenPos( screenmanager.meter_w / 2, 0 )
	love.graphics.printf( string.format( "%d", self.score),
		0, draw_y, screenmanager.screen_w, 'center' )
end

return Ingame