local Ground = {}
Ground.__index = Ground
Ground.id = 'ground'

function Ground.new(world) -- ::Ground
	local self = setmetatable({},Ground)
	local meter_width = 16 -- TODO read value
	local meter_height = 9 -- TODO read value
	self.body = love.physics.newBody( world,
		meter_width / 2, (meter_height - 1/2), "static" )
	self.shape = love.physics.newRectangleShape( meter_width, 1 )
	self.fixture = love.physics.newFixture( self.body, self.shape )
	self.fixture:setUserData( self )
	self.alive = true
	return self
end

function Ground:free()
	self.fixture:setUserData( nil )
	self.fixture:destroy()
	self.fixture = nil
--	self.shape:destroy()
	self.shape = nil
	self.body:destroy()
	self.body = nil
end

function Ground:update( dt ) -- ::void!
end

function Ground:draw( screenmanager ) -- ::void!
	local sm = screenmanager
	love.graphics.setColor( 100, 0, 0 )
	local x1, y1, 
		x2, y2,
		x3, y3,
		x4, y4 = self.body:getWorldPoints( self.shape:getPoints() )
	x1,y1 = sm:getScreenPos( x1, y1 )
	x2,y2 = sm:getScreenPos( x2, y2 )
	x3,y3 = sm:getScreenPos( x3, y3 )
	x4,y4 = sm:getScreenPos( x4, y4 )
	love.graphics.polygon( 'fill', x1, y1, x2, y2, x3, y3, x4, y4 )
end

function Ground:input( act,val ) -- ::void!
end

function Ground:collide( other, collision )
end

return Ground
