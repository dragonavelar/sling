local ScreenManager = {}
ScreenManager.__index = ScreenManager
ScreenManager.layers = {}
ScreenManager.layers.HUD = 0
ScreenManager.layers.FOREGROUND = 1
ScreenManager.layers.FRONT = 2
ScreenManager.layers.MIDDLE = 3
ScreenManager.layers.BACK = 4
ScreenManager.layers.BACKGROUND = 5

function ScreenManager.new() -- ::ScreenManager
	local self = setmetatable({},ScreenManager)
	self.world_x = 0
	self.world_y = 0

	self.meter_w = 16
	self.meter_h = 9
	self.arw = self.meter_w / self.meter_h -- Aspect ratio w/h
	self.screen_w = love.graphics.getWidth()
	self.screen_h = love.graphics.getHeight()
	self.screen_arw = self.screen_w / self.screen_h
	self.filling_w = 0
	self.filling_h = 0
	self.screen_x = 0
	self.screen_y = 0
	self.pxpm = 64 -- Pixel per meter
	self.px_w = self.pxpm * self.meter_w
	self.px_h = self.pxpm * self.meter_h
	self:adjust()
	return self
end

function ScreenManager:adjust()
	self.meter_w = 16
	self.meter_h = 9
	self.arw = self.meter_w / self.meter_h -- Aspect ratio w/h
	self.screen_w = love.graphics.getWidth()
	self.screen_h = love.graphics.getHeight()
	self.screen_arw = self.screen_w / self.screen_h
	if self.arw <= self.screen_arw then
		self.filling_h = 0
		self.screen_y = 0
		self.pxpm = self.screen_h / self.meter_h
		self.px_w = self.pxpm * self.meter_w
		self.px_h = self.pxpm * self.meter_h
		self.filling_w = math.floor(
			( self.screen_w - self.px_w ) / 2 )
		self.screen_x = self.filling_w
	else
		self.filling_w = 0
		self.screen_x = 0
		self.pxpm = self.screen_w / self.meter_w
		self.px_w = self.pxpm * self.meter_w
		self.px_h = self.pxpm * self.meter_h
		self.filling_h = math.floor(
			( self.screen_h - self.px_h ) / 2 )
		self.screen_y = self.filling_h
	end
	-- TODO ASSERTS ON SCREEN SIZE
end

function ScreenManager:getScreenPos( mx, my )
	local px, py
	px = self.screen_x + ( ( mx - self.world_x ) * self.pxpm )
	py = self.screen_y + ( ( my - self.world_y ) * self.pxpm )
	return px, py
end

function ScreenManager:getWorldPos( px, py )
	local mx, my
	mx = ( ( px - self.screen_x ) / self.pxpm ) + self.world_x
	my = ( ( py - self.screen_y ) / self.pxpm ) + self.world_y
	if mx < self.world_x then
		mx = self.world_x
	elseif mx > self.world_x + self.meter_w then
		mx = self.world_x + self.meter_w
	end
	if my < self.world_y then
		my = self.world_y
	elseif my > self.world_y + self.meter_h then
		my = self.world_y + self.meter_h
	end
	return mx, my
end

function ScreenManager:getLength( m )
	return self.pxpm * m
end

function ScreenManager:getScaleFactor( px, m )
	return self.pxpm * m / px
end

function ScreenManager:update(dt) -- ::void!
	local sw, sh
	sw = love.graphics.getWidth()
	sh = love.graphics.getHeight()
	if sw ~= self.screen_w or sh ~= self.screen_h then
		print( "RECOMPUTING SCALE FACTORS" )
		self:adjust()
	end
end

function ScreenManager:draw() -- ::void!
	love.graphics.setColor( 0, 0, 0 )
	local x = 0
	local w = self.screen_w
	local y = 0
	local h = self.screen_h
	if self.filling_w > 0 then
		x = self.screen_w - self.filling_w
		w = self.filling_w
	end
	if self.filling_h > 0 then
		y = self.screen_h - self.filling_h
		h = self.filling_h
	end
	if self.filling_w == 0 and self.filling_h == 0 then
		w = 0
		h = 0
		x = 0
		y = 0
	end
	love.graphics.rectangle( 'fill',
		0, 0, w, h )
	love.graphics.rectangle( 'fill',
		x, y, w, h )
end

function ScreenManager:input(act,val) -- ::void!
	print( "RECOMPUTING SCALE FACTORS" )
	self:adjust()
end

return ScreenManager
