local Enemy = {}
Enemy.__index = Enemy
Enemy.id = 'enemy'
Enemy.oscillation_period = 1.0
Enemy.oscillation_amplitude = 0.5

Enemy.raycast_period_max = 0.5
Enemy.raycast_period_min = 0.1
Enemy.raycast_probability_max = 0.9
Enemy.raycast_probability_min = 0.8

Enemy.raycast_cooldown_period = 1.0

Enemy.attacking_period = 1.0
Enemy.attacking_cooldown_period = 1.0

Enemy.abducting_period = 0.3

function Enemy.new( world, right ) -- ::Enemy
	local _right = right or false
	local self = setmetatable({},Enemy)

	if _right then
		self.dir = -1
	else
		self.dir = 1
	end

	local meter_width = 16 -- TODO get from value
	local meter_height = 9 -- TODO get from value

	local spawn_x, spawn_y
	if _right then
		spawn_x = meter_width + 2
		spawn_y =  1
	else
		spawn_x = -2
		spawn_y =  3
	end

	self.body = love.physics.newBody( world,
		spawn_x, spawn_y, "dynamic" )
	self.shape = love.physics.newRectangleShape( 1.5 , 1.5 ) -- TODO
	self.fixture = love.physics.newFixture( self.body, self.shape )
	self.fixture:setUserData( self )
	self.alive = true

	self.layer = ScreenManager.layers.FRONT

	self.oscillation_period = self.oscillation_period + self.oscillation_period * ( math.random() - 0.5 ) * 0.2
	self.oscillation_amplitude = self.oscillation_period + self.oscillation_amplitude * ( math.random() - 0.5 ) * 0.2
	self.oscillation_time = math.random() * self.oscillation_period

	self.attacking = false
	self.attacking_time = 0.0
	self.abducting = false
	self.aducting_time = 0.0
	self.cooling = false
	self.attacking_cooldown = 0.0

	self.raycast_period = ( self.raycast_period_max - self.raycast_period_min ) * ( math.random() ) + self.raycast_period_min
	self.raycast_time = math.random() * self.oscillation_period
	self.raycast_probability = ( self.raycast_probability_max - self.raycast_probability_min ) * ( math.random() ) + self.raycast_probability_min
	self.raycasted = false
	self.raycast_cooldown_time = 0.0
	self.raycast_ground = nil
	-- Raycast function
	self.raycast_callback = function( fixture, x, y, xn, yn, fraction )
		if fixture:getUserData() and fixture:getUserData().id then
			if fixture:getUserData().id == Player.id then
				print( fixture:getUserData().id )
				if math.random() < self.raycast_probability and not fixture:getUserData():is_hidden() then
					self.attacking = true
				end
				self.raycasted = true
			elseif fixture:getUserData().id == Ground.id then
				self.raycast_ground = y
			end
		end
		return -1
	end

	return self
end

function Enemy:free()
	self.raycast_callback = nil
	self.fixture:setUserData( nil )
	self.fixture:destroy()
	self.fixture = nil
--	self.shape:destroy()
	self.shape = nil
	self.body:destroy()
	self.body = nil
end

function Enemy:update(dt) -- ::void!
	self.oscillation_time = self.oscillation_time + dt
	-- TODO: take difference and round
	while self.oscillation_time > self.oscillation_period do
		self.oscillation_time = self.oscillation_time - self.oscillation_period
	end
	
	self.body:setLinearVelocity( 0, 0 )
	self.body:setAngularVelocity( 0 )
	if self.attacking then
		self.attacking_time = self.attacking_time + dt
		if self.attacking_time > self.attacking_period then
			self.attacking = false
			self.abducting = true
			self.abducting_time = self.abducting_period
		end
	elseif self.abducting then
		if self.abducting_time > 0 then
			self.abducting_time = self.abducting_time - dt
		else
			self.abducting = false
			self.abducting_time = 0
			self.cooling = true
			self.attacking_cooldown = self.attacking_cooldown_period
		end
	elseif self.cooling then
		if self.attacking_cooldown > 0 then
			self.attacking_cooldown = self.attacking_cooldown - dt
		else
			self.cooling = false
			self.attacking_cooldown = 0
		end
	else
		self.body:setLinearVelocity( self.dir * ( 1 + math.random() ), self.oscillation_amplitude * math.cos( 2 * math.pi * self.oscillation_time / self.oscillation_period ) )
		self.body:setAngularVelocity( 0 )

		self.raycast_time = self.raycast_time + dt
		while self.raycast_time > self.raycast_period do
			local sx1, sy1, 
				sx2, sy2,
				sx3, sy3,
				sx4, sy4 = self.body:getWorldPoints( self.shape:getPoints() )
			local sx, sy
			sx = ( sx1 + sx2 + sx3 + sx4 ) / 4.0
			sy = ( sy1 + sy2 + sy3 + sy4 ) / 4.0
			if not self.raycasted then
				self.body:getWorld():rayCast( sx, sy, sx, sy + 100.0, self.raycast_callback ) -- TODO remove magic number
			else
				self.raycast_cooldown_time = self.raycast_cooldown_time + dt
				while self.raycast_cooldown_time > self.raycast_cooldown_period do
					self.raycasted = false
					self.raycast_cooldown_time = self.raycast_cooldown_time - self.raycast_cooldown_period
				end
			end
			self.raycast_time = self.raycast_time - self.raycast_period
		end
	end
end

function Enemy:draw( screenmanager ) -- ::void!
	local sm = screenmanager
	if self.attacking or self.abducting then
		love.graphics.setColor( 255, 0, 0 )
	elseif self.cooling then
		love.graphics.setColor( 0, 0, 255 )
	else
		love.graphics.setColor( 222, 23, 222 )
	end
	local x1, y1, 
		x2, y2,
		x3, y3,
		x4, y4 = self.body:getWorldPoints( self.shape:getPoints() )
	local dx1,dy1 = sm:getScreenPos( x1, y1 )
	local dx2,dy2 = sm:getScreenPos( x2, y2 )
	local dx3,dy3 = sm:getScreenPos( x3, y3 )
	local dx4,dy4 = sm:getScreenPos( x4, y4 )
	love.graphics.polygon( 'fill', dx1, dy1, dx2, dy2, dx3, dy3, dx4, dy4 )
	if self.abducting then
		local xr, yr
		xr = ( x1 + x2 + x3 + x4 ) / 4.0
		-- Bottom of ship
		yr = math.max( y1, y2, y3, y4 )
		local rw = 0.1
		
		local xr1, yr1, xr2, yr2, xr3, yr3, xr4, yr4
		love.graphics.setColor( 255, 255, 255 )
		xr1,yr1 = sm:getScreenPos( xr - rw, yr )
		xr2,yr2 = sm:getScreenPos( xr + rw, yr )
		xr3,yr3 = sm:getScreenPos( xr + rw, self.raycast_ground )
		xr4,yr4 = sm:getScreenPos( xr - rw, self.raycast_ground )
		--print( xr1, yr1, xr2, yr2, xr3, yr3, xr4, yr4 )
		love.graphics.polygon( 'fill', xr1, yr1, xr2, yr2, xr3, yr3, xr4, yr4 )

	end
end

function Enemy:input(act,val) -- ::void!
end

function Enemy:collide( other, collision )
	if collision then
		if other.id == Pellet.id then
			self.alive = false
		end
	end
end


return Enemy
