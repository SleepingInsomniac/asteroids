require "sdl"
require "crystaledge"
include CrystalEdge
require "./lx_game/*"
include LxGame
require "./ship"
require "./bullet"

class Asteroids < Game
  @ship : Ship
  @controller : Controller(LibSDL::Keycode)

  def initialize(*args)
    super

    @ship = Ship.build do |ship|
      ship.position = Vector2.new(x: width / 2.0, y: height / 2.0)
    end

    @controller = Controller(LibSDL::Keycode).new({
      LibSDL::Keycode::UP    => "Thrust",
      LibSDL::Keycode::RIGHT => "Rotate Right",
      LibSDL::Keycode::LEFT  => "Rotate Left",
      LibSDL::Keycode::SPACE => "Fire",
    })

    @bullets = [] of Bullet
  end

  def wrap(position : Vector2)
    position.x = 0.0 if position.x > @width
    position.x = @width.to_f64 if position.x < 0.0

    position.y = 0.0 if position.y > @height
    position.y = @height.to_f64 if position.y < 0.0

    position
  end

  def update(dt : Float64)
    @ship.rotate_right(dt) if @controller.action?("Rotate Right")
    @ship.rotate_left(dt) if @controller.action?("Rotate Left")
    @ship.thrust(dt) if @controller.action?("Thrust")
    @ship.update(dt)

    @ship.position = wrap(@ship.position)

    if @controller.action?("Fire") && @ship.can_fire?
      @bullets << @ship.fire
    end

    @bullets.each do |bullet|
      bullet.update(dt)
    end

    @bullets = @bullets.reject { |b| b.age >= 4.0 }
  end

  def draw
    @renderer.draw_color = SDL::Color[0, 0, 0, 255]
    @renderer.clear
    @ship.draw(@renderer)
    @bullets.each { |b| b.draw(@renderer) }
  end
end

game = Asteroids.new(200, 120, 4)
game.run!
