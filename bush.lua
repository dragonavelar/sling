local Bush = {}
Bush.__index = Bush
Bush.id = 'bush'

function Bush.new(world,x,y,width,height) -- ::Bush
	local self = setmetatable({},Bush)
	self.body = love.physics.newBody( world,
		x, y, "static" )
	self.shape = love.physics.newRectangleShape( width, height )
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setUserData(self)
	self.alive = true
	self.player_reference = nil
	self.toggle = false
	self.layer = ScreenManager.layers.MIDDLE
	return self
end

function Bush:free()
	self.fixture:setUserData(nil)
	self.fixture:destroy()
	self.fixture = nil
--	self.shape:destroy()
	self.shape = nil
	self.body:destroy()
	self.body = nil
end

function Bush:update(dt, screenmanager) -- ::void!
	local sm = screenmanager
	if self.player_reference then
		local up
		if not ANDROID_CONTROLS then
			up =
				love.keyboard.isDown( 'w' )
				or love.keyboard.isDown( 'up' )
		else
			up = false -- TODO add button to hide
		end
		
		if self.toggle and not up then
			self.toggle = false
		elseif up and not self.toggle then
			self.toggle = true
			if self.player_reference:is_hidden() then
				self.player_reference:set_hidden(false)
				local x1, y1 = self.player_reference.body:getWorldPoints( self.player_reference.shape:getPoints() )
				x1,y1 = sm:getScreenPos( x1, y1 )
				print("SEALs", self.player_reference, x1, y1)
			else
				self.player_reference:set_hidden(true)
				local x1, y1 = self.player_reference.body:getWorldPoints( self.player_reference.shape:getPoints() )
				x1,y1 = sm:getScreenPos( x1, y1 )
				print("OBLaden", self.player_reference, x1, y1)
			end
		end
	end
end

function Bush:draw(screenmanager) -- ::void!
	local sm = screenmanager
	love.graphics.setColor(0,100,0)
	local x1, y1, 
		x2, y2,
		x3, y3,
		x4, y4 = self.body:getWorldPoints( self.shape:getPoints() )
	x1,y1 = sm:getScreenPos( x1, y1 )
	x2,y2 = sm:getScreenPos( x2, y2 )
	x3,y3 = sm:getScreenPos( x3, y3 )
	x4,y4 = sm:getScreenPos( x4, y4 )
	love.graphics.polygon( 'fill', x1, y1, x2, y2, x3, y3, x4, y4 )
	-- TODO draw show size and collider size separately
end

function Bush:input(act,val) -- ::void!
end

function Bush:collide( other, collision )
	if other.id == Player.id then
		if collision then
			self.player_reference = other
			print("GWBush", self.player_reference)
		else
			self.player_reference:set_hidden(false)
			self.player_reference = nil
			print("BObama")
		end
	end
	
end

return Bush
