local Pellet = {}
Pellet.__index = Pellet
Pellet.id = 'pellet'
Pellet.player_collisions_threshold = 2 -- Number of times it has to collide with a player to destroy itself

function Pellet.new( _x, _y, _dx, _dy, _r ) -- ::Pellet
	local self = setmetatable( {}, Pellet )
	local meter_width = 16 -- TODO read value
	local meter_height = 9 -- TODO read value
	local x = _x or meter_width / 2
	local y = _y or meter_height / 2
	local dx = _dx or love.math.random( -1.0, 1.0 )
	local dy = _dy or -world:getGravity()
	local r = _r or 0.1
	self.body = love.physics.newBody( world, x, y, "dynamic" )
	self.shape = love.physics.newCircleShape( r )
	self.fixture = love.physics.newFixture( self.body, self.shape )
	self.fixture:setUserData( self )
	self.body:setLinearVelocity( dx, dy )
	self.alive = true

	self.layer = ScreenManager.layers.FRONT

	self.player_collisions = 0
	return self
end

function Pellet:free()
	self.fixture:setUserData( nil )
	self.fixture:destroy()
	self.fixture = nil
--	self.shape:destroy()
	self.shape = nil
	self.body:destroy()
	self.body = nil
end
function Pellet:update(dt) -- ::void!
end

function Pellet:draw( screenmanager ) -- ::void!
	local sm = screenmanager
	love.graphics.setColor( 92, 84, 75 )
	local x, y, r
	x = self.body:getX()
	y = self.body:getY()
	r = self.shape:getRadius()

	x,y = sm:getScreenPos( x, y )
	r = sm:getLength( r )
	love.graphics.circle('fill', x, y, r )
end

function Pellet:input( act,val ) -- ::void!
end

function Pellet:collide( other, collision )
	if collision then
		if other.id == Pellet.id
		or other.id == NamelessVoid.id then
			self.alive = true
		elseif other.id == Player.id then
			self.player_collisions = self.player_collisions + 1
			if self.player_collisions >= self.player_collisions_threshold then
				self.alive = false
			end
		else
			self.alive = false
			-- TODO spawn debris
		end
	end
end

return Pellet
