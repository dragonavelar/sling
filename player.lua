local Player = {}
Player.__index = Player
Player.id = 'player'
Player.reload_threshold = 1.0 -- seconds
Player.sling_min_speed = 4
Player.sling_max_speed_gain = 8
-- max speed = min speed + max speed gain
Player.sling_charge_window = 0.8 -- seconds

function Player.new(world) -- ::Player
	local self = setmetatable({},Player)
	local meter_height = 9 -- TODO get value
	local body_height = 1.54
	local body_width = 1.8
	self.body = love.physics.newBody( world,
		1.5,
		meter_height - 1 - ( body_height / 2 )
		, "dynamic" )
	self.shape = love.physics.newRectangleShape( body_width , body_height )
	self.fixture = love.physics.newFixture( self.body, self.shape )
	self.fixture:setUserData(self)
	self.body:setLinearVelocity( 3, -3 )
	self.tracking = false
	self.charge_dir = 1
	self.charge_timer = 0
	self.alive = true

	self.layer = ScreenManager.layers.FRONT

	self.sling_speed = 12
	self.reload = self.reload_threshold

	self.hidden = false
	return self
end

function Player:free()
	self.fixture:setUserData( nil )
	self.fixture:destroy()
	self.fixture = nil
--	self.shape:destroy()
	self.shape = nil
	self.body:destroy()
	self.body = nil
end

function Player:update( dt, screenmanager, pellets ) -- ::void!
	local sm = screenmanager
	local left, right = false, false
	if not ANDROID_CONTROLS then
		left =
			love.keyboard.isDown( 'a' )
			or love.keyboard.isDown( 'left' )
		right =
			love.keyboard.isDown( 'd' )
			or love.keyboard.isDown( 'right' )
	end
	self.reload = self.reload + dt

	if not self.hidden and self.tracking then
		-- update charging
		self.charge_timer = self.charge_timer + ( dt * self.charge_dir )
		if self.charge_timer >= self.sling_charge_window
		and self.charge_dir > 0 then
			self.charge_timer = self.sling_charge_window
			self.charge_dir = -1
		elseif self.charge_timer <= 0
		and self.charge_dir < 0 then
			self.charge_timer = 0
			self.charge_dir = 1
		end
		-- release
		if not love.mouse.isDown( 1 ) then
			self.reload = 0.0
			self.tracking = false
			local dx, dy, charge_speed = self:calculate_slingshot( screenmanager )
			self.charge_timer = 0
			self.charge_dir = 1
			table.insert( pellets,
				Pellet.new(
					self.body:getWorld(),
					-- TODO put above player
					self.body:getX(),
					self.body:getY(),
					charge_speed * dx,
					charge_speed * dy
					)
				)
		end
		self.body:setLinearVelocity( 0, 0 )	
	elseif not self.tracking then
		if love.mouse.isDown( 1 ) then
			if ANDROID_CONTROLS then
				if love.mouse.getX() < sm.px_w * 0.2 then
					left = true
				elseif love.mouse.getX() > sm.px_w * 0.8 then
					right = true
				elseif self.reload > self.reload_threshold then
					self.tracking = true
				end
			else
				if self.reload > self.reload_threshold then
					self.tracking = true
				end
			end
		end
		if left and not right then
			self.body:setLinearVelocity( -3, 0 )
		elseif not left and right then
			self.body:setLinearVelocity( 3, 0 )
		else
			self.body:setLinearVelocity( 0, 0 )
		end
	else
		self.tracking = false
	end
end

function Player:draw( screenmanager ) -- ::void!
	local sm = screenmanager
	love.graphics.setColor( 207, 172, 137 )
	local x1, y1, 
		x2, y2,
		x3, y3,
		x4, y4 = self.body:getWorldPoints( self.shape:getPoints() )
	x1,y1 = sm:getScreenPos( x1, y1 )
	x2,y2 = sm:getScreenPos( x2, y2 )
	x3,y3 = sm:getScreenPos( x3, y3 )
	x4,y4 = sm:getScreenPos( x4, y4 )
	love.graphics.polygon( 'fill', x1, y1, x2, y2, x3, y3, x4, y4 )
	if self.tracking then
		love.graphics.setColor( 255, 255, 255 )
		local dx, dy, charge_speed = self:calculate_slingshot( screenmanager )
		-- rotate 90 degrees clockwise
		local cwdx, cwdy = dy, -dx
		-- rotate 90 degrees counter-clockwise
		local ccwdx, ccwdy = -dy, dx
		-- get base center
		local bx, by = self.body:getX(), self.body:getY()
		-- base width and rect length
		local base = 0.1
		local length = 0.1 * charge_speed
		local bxbl, bybl = bx + ccwdx * base, by + ccwdy * base -- base left
		local bxbr, bybr = bx + cwdx * base, by + cwdy * base -- base right
		local bxtl, bytl = bxbl + dx * length, bybl + dy * length -- top left
		local bxtr, bytr = bxbr + dx * length, bybr + dy * length -- top right
		bxbl,bybl = sm:getScreenPos( bxbl, bybl )
		bxbr,bybr = sm:getScreenPos( bxbr, bybr )
		bxtl,bytl = sm:getScreenPos( bxtl, bytl )
		bxtr,bytr = sm:getScreenPos( bxtr, bytr )
		
		love.graphics.polygon( 'fill', bxbl,bybl, bxtl,bytl, bxtr,bytr, bxbr,bybr )
	end
end

function Player:input( act, val ) -- ::void!
end

function Player:collide( other, collision )
end

function Player:calculate_slingshot( screenmanager )
	local sm = screenmanager
	local dx, dy, mod, mouse_x, mouse_y, charge_speed
	mouse_x = love.mouse.getX()
	mouse_y = love.mouse.getY()
	mouse_x, mouse_y = sm:getWorldPos( mouse_x, mouse_y )
	dx = ( mouse_x - self.body:getX() )
	dy = ( mouse_y - self.body:getY() )
	-- Unit vector
	mod = math.sqrt( dy*dy + dx*dx )
	dx = dx / mod
	dy = dy / mod
	-- Limit angle to 120 degrees centered at negative y
	-- TODO optmize with precomputed numbers
	local angle_limitd = 30
	local angle_limit = angle_limitd * math.pi / 180
	local cos_theta, sen_theta = math.cos(angle_limit), -math.sin(angle_limit)
	--cos30 = 0.86602540378443864676372317075294
	--sen30 = -0.5
	if dx < -cos_theta or dx > cos_theta then
		dx = cos_theta * dx / math.abs(dx)
		dy = sen_theta
	end

	if dy > 0 then
		dy = - dy
	end

	charge_speed = self.sling_min_speed
		+ self.sling_max_speed_gain
			* ( self.charge_timer / self.sling_charge_window )
	return dx, dy, charge_speed
end

function Player:is_hidden()
	return self.hidden
end

function Player:set_hidden(val)
	if val then
		self.layer = ScreenManager.layers.BACK
	else
		self.layer = ScreenManager.layers.FRONT
	end
	self.hidden = val
end

return Player
