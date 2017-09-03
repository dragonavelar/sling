local Obj = {}
Obj.__index = Obj

function Obj.new(world) -- ::Obj
	local self = setmetatable({},Obj)
	local meter_width = love.graphics.getWidth() / onemeter -- TODO
	local meter_height = love.graphics.getHeight() / onemeter -- TODO
	self.body = love.physics.newBody( world,
		meter_width * onemeter / 2, (meter_height - 1/2) * onemeter, "static" )
	self.shape = love.physics.newRectangleShape( meter_width * onemeter, onemeter )
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setUserData(self)
	self.alive = true
	return self
end

function Obj:free()
	self.fixture:setUserData(nil)
	self.fixture:destroy()
	self.fixture = nil
--	self.shape:destroy()
	self.shape = nil
	self.body:destroy()
	self.body = nil
end

function Obj:update(dt) -- ::void!
end

function Obj:draw() -- ::void!
	love.graphics.setColor(100,0,0)
	love.graphics.polygon('fill', self.body:getWorldPoints( self.shape:getPoints() ) )
end

function Obj:input(act,val) -- ::void!
end

function Obj:collide( other, collision )
end

return Obj
