Bush = require('bush')
Player = require('player')
Ground = require('ground')
Pellet = require('pellet')
Enemy = require('enemy')
Collisions = require('collisions')
NamelessVoid = require('namelessvoid')
ScreenManager = require('screenmanager')
Auxiliary = require('auxiliary')
Menu = require('menu')
Ingame = require('ingame')

ANDROID_CONTROLS = false

local acc, fps, show_fps, old_time = 0, 0, 0, 0
local main_debug = true

local screenmanager = nil

function love.load()
	love.graphics.setBackgroundColor( 240, 108, 21 )
	love.physics.setMeter( 1 )
	screenmanager = ScreenManager.new()
	screenmanager:update( dt )
	state = Menu.new()
end

function love.update( dt )
	if main_debug and dt > 1/1000 then
		print( 'high dt', dt )
	end
	local new_state = state:update( dt, screenmanager )
	if new_state ~= nil and new_state then
		s = state:transition( new_state )
		state = nil
		state = s
  elseif new_state == false then
    state:free()
    state = nil
    love.event.push('quit')
	end
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
	state:draw( screenmanager )
	screenmanager:update( dt )
	screenmanager:draw()
	draw_fps()
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
