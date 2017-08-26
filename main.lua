ANDROID_CONTROLS = false
local debug = false

local acc, fps, show_fps, old_time = 0, 0, 0, 0
local enemy_spawn_threshold, enemy_spawn_acc

Bush = require('bush')
Player = require('player')
Ground = require('ground')
Pellet = require('pellet')
Enemy = require('enemy')
Collisions = require('collisions')
NamelessVoid = require('namelessvoid')
ScreenManager = require('screenmanager')

world = nil
screenmanager = nil
score = nil

function love.load()
	love.graphics.setBackgroundColor( 240, 108, 21 )

	love.physics.setMeter( 1 )
	world = love.physics.newWorld( 0, 9.8 )
	world:setCallbacks(
		Collisions.beginContact,
		Collisions.endContact,
		Collisions.preSolve,
		Collisions.postSolve )

	screenmanager = ScreenManager.new()
	score = 0

	namelessvoid = NamelessVoid.new()
	player = Player.new()
	ground = Ground.new()
	pellets = {}
	enemies = {}
	enemy_spawn_threshold = 2
	enemy_spawn_acc = 0.0
	table.insert( enemies, Enemy.new() )
	local meter_width = 16 -- TODO get value
	local meter_height = 9 -- TODO get value
	local bush_height = 1.2
	local bushl_width = 1.4
	local bushr_width = 2.2
	local bush_x_offset = 1.2
	local bush_y = meter_height - 1 - ( bush_height / 2 )
	bushl = Bush.new( bush_x_offset + bushl_width, bush_y, bushl_width, bush_height )
	bushr = Bush.new( meter_width - bush_x_offset - bushr_width, bush_y, bushr_width, bush_height )
end

function love.update( dt )
	if main_debug and dt > 1/1000 then
		print( 'high dt', dt )
	end
	player:update( dt, screenmanager )
	world:update( dt )
	for k, v in pairs( pellets ) do
		if v.alive then
			v:update( dt )
		else
			v:free()
			pellets[ k ] = nil
		end
	end
	for k, v in pairs( enemies ) do
		if v.alive then
			v:update( dt )
		else
			v:free()
			enemies[ k ] = nil
		end
	end
	enemy_spawn_acc = enemy_spawn_acc + dt
	if enemy_spawn_acc > enemy_spawn_threshold then
		enemy_spawn_acc = enemy_spawn_acc - enemy_spawn_threshold
		local spawn_right = false
		if math.random() > 0.5 then spawn_right = true end
		table.insert( enemies, Enemy.new( spawn_right ) )
	end
	
	bushl:update( dt, screenmanager )
	bushr:update( dt, screenmanager )

	update_fps( dt )
end

function update_fps( dt )
	fps = fps + 1
	acc = acc + dt
	if acc > 1 then
		show_fps = fps / acc
		fps = fps - show_fps
		acc = acc - 1.0
	end
end

function love.draw()
	local layers = {}
	for kl, vl in pairs( ScreenManager.layers ) do
		layers[vl] = {}
		if bushl.layer ~= nil and bushl.layer == vl then
			table.insert( layers[vl], bushl )
		end
		if bushr.layer ~= nil  and bushr.layer == vl then
			table.insert( layers[vl], bushr )
		end
		if player.layer ~= nil  and player.layer == vl then
			table.insert( layers[vl], player )
		end
		if player.layer ~= nil  and player.layer == vl then
			table.insert( layers[vl], player )
		end
		if ground.layer ~= nil  and ground.layer == vl then
			table.insert( layers[vl], ground )
		end
		for kp, vp in pairs( pellets ) do
			if vp.layer ~= nil  and vp.layer == vl then
				table.insert( layers[vl], vp )
			end
		end
		for ke, ve in pairs( enemies ) do
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

	screenmanager:update( dt )
	screenmanager:draw()
	draw_fps()
	draw_score()
end

function draw_fps()
	love.graphics.setColor( 255, 255, 255 )
	local show_fps_val, normal_fps_val, draw_fps_val = -1, -1, -1
	if old_time then
		local new_time = love.timer.getTime()
		draw_fps_val = 1 / ( new_time - old_time )
		old_time = new_time
	else
		old_time = love.timer.getTime()
	end
	if show_fps then show_fps_val = show_fps end
	normal_fps_val = fps / acc
	love.graphics.print( string.format( "%.3f ; %.3f ; %.3f", show_fps_val,
		normal_fps_val, draw_fps_val ), 0, 0 )
end


function draw_score()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.print( string.format( "%d", score),
		screenmanager.px_w * 0.5, 0 )
end









-- Altered main function that caps fps at 60 and lets update to run indefinetely

function love.run()
  if love.math then
    love.math.setRandomSeed( os.time() )
  end
  math.randomseed( os.time() )
  math.random(); math.random(); math.random();

  if love.load then love.load( arg ) end

  love.timer.step()
  local dt = 0
  local u_dt = 0
  local acc = 0
  local tbu = 0
  local tau = 0
  local rest_time = 0.001

  -- Main loop
  while true do
    -- Process events.
    if love.event then
      love.event.pump()
      for name, a, b, c, d, e, f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            if love.audio then
              love.audio.stop()
            end
            return a
          end
        end
        love.handlers[ name ]( a, b, c, d, e, f )
      end
    end

    love.timer.step()
    dt = love.timer.getDelta()
    if dt > 1/30 then u_dt = 1/30 else u_dt = dt end

    tbu = love.timer.getTime()
    love.update( u_dt )
    tau = love.timer.getTime()

    -- Update screen, frames capped at 60 fps for drawing
    if love.graphics and love.graphics.isActive() then
      acc = acc + dt
      if acc > 1/60 then
        love.graphics.clear( love.graphics.getBackgroundColor() )
	love.graphics.origin()
        love.draw()
        love.graphics.present()
        while acc > 1/60 do acc = acc - 1/60 end
      end
    end

    -- Rest for a while if we haven't done a lot of processing already
    if tau - tbu < rest_time then
      love.timer.sleep( rest_time - tau + tbu )
    end
  end
end
