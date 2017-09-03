local Menu = {}
Menu.__index = Menu

Menu.options = {[0]="Play",[1]="Highscore",[2]="Quit"}

function Menu.new() -- ::Menu
	local enter_pressed = true
	local self = setmetatable({},Menu)
	self.current_option = 0
	self.cursor = 0
	return self
end

function Menu:load()
end

function Menu:transition( new_state )
	-- TODO: Clean up and transition
	return new_state.new()
end

function Menu:free()
end

function Menu:update( dt, screenmanager ) -- ::void!
	if love.keyboard.isDown( 'down' ) or self.cursor == 1 then
		self.cursor = 1
		if not love.keyboard.isDown( 'down' ) then
			self.current_option = Auxiliary.wrap_values( self.current_option + self.cursor, 0, 3 )
			self.cursor = 0
		end
	elseif love.keyboard.isDown( 'up' ) or self.cursor == -1 then
		self.cursor = -1
		if not love.keyboard.isDown( 'up' ) then
			self.current_option = Auxiliary.wrap_values( self.current_option + self.cursor, 0, 3 )
			self.cursor = 0
		end
	else
		self.cursor = 0
	end

	if not love.keyboard.isDown( 'return' ) then
		self.enter_pressed = false
	end

	if love.keyboard.isDown( 'return' ) and (not self.enter_pressed) then
		if self.current_option == 0 then
			print("Gonna go ingame")
			return Ingame
		elseif self.current_option == 1 then
			print("Gonna go highscore")
			return Highscore
		elseif self.current_option == 2 then
			print("Gonna go apeshit")
			return false
		else
			print( "Main menu cursor out of bounds" )
		end
	end

	return nil
end

function Menu:draw( screenmanager ) -- ::void!
	love.graphics.setColor(255,255,255)
	love.graphics.printf( self.options[self.current_option], 0,screenmanager.screen_h / 2, screenmanager.screen_w, 'center' )
end

function Menu:input( act, val ) -- ::void!
end

return Menu