local NamelessVoid = {}
NamelessVoid.__index = NamelessVoid
NamelessVoid.id = 'namelessvoid'

function NamelessVoid.new(world) -- ::NamelessVoid
	local self = setmetatable({},NamelessVoid)
	local meter_width = 16 -- TODO read value
	local meter_height = 9 -- TODO read value
	self.body = love.physics.newBody( world,
		meter_width / 2,
		meter_height / 2, "static" )
	self.shape = love.physics.newRectangleShape( 
		2 * meter_width , 2 * meter_height )
	self.fixture = love.physics.newFixture( self.body, self.shape )
	self.fixture:setSensor( true )
	self.fixture:setUserData( self )
	self.alive = true
	return self
end

function NamelessVoid:free()
	self.fixture:setUserData( nil )
	self.fixture:destroy()
	self.fixture = nil
--	self.shape:destroy()
	self.shape = nil
	self.body:destroy()
	self.body = nil
end

function NamelessVoid:update( dt ) -- ::void!
end

function NamelessVoid:draw() -- ::void!
end

function NamelessVoid:input( act, val ) -- ::void!
end

function NamelessVoid:collide( other, collision )
	if Collisions.debug and collision == false and other then
		print( collision, other.id )
		other.alive = false
	end
end

return NamelessVoid
