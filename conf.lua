function love.conf( t )
  t.identity = "USPM"
  t.version = "0.10.2"
  t.console = true
  t.accelerometerjoystick = false
  t.externalstorage = false
  t.gammacorrect = false
 
  t.window.title = "USPM"
  t.window.icon = 'pug16.png'
  t.window.width = 256*3
  t.window.height = 200*3
  t.window.borderless = false
  t.window.resizable = true -- false
  t.window.minwidth = 1
  t.window.minheight = 1
  t.window.fullscreen = false
  t.window.fullscreentype = "desktop"
  t.window.vsync = false
  t.window.msaa = 4
  t.window.display = 1
  t.window.highdpi = false
  t.window.x = nil
  t.window.y = nil
 
  t.modules.audio = true
  t.modules.event = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = false
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = true
  t.modules.sound = true
  t.modules.system = true
  t.modules.timer = true
  t.modules.touch = false
  t.modules.video = true
  t.modules.window = true
  t.modules.thread = true
end
