require "sdl"
require "crystaledge"
include CrystalEdge
require "./lx_game/*"
include LxGame
require "./ship"
require "./asteroid"
require "./bullet"

WIDTH  = 600
HEIGHT = 400
SCALE  =   3

module LxGame
  def draw_point(renderer, x, y)
    x = x % WIDTH
    y = y % HEIGHT

    x = WIDTH + x if x < 0
    y = HEIGHT + y if y < 0

    renderer.draw_point(x, y)
  end
end

class Asteroids < Game
  @ship : Ship
  @asteroids = [] of Asteroid
  @controller : Controller(LibSDL::Keycode)

  def initialize(*args)
    super

    @ship = Ship.build do |ship|
      ship.position = Vector2.new(x: width / 2.0, y: height / 2.0)
    end

    8.times do
      @asteroids << Asteroid.build do |a|
        a.position = Vector2.new(x: rand(0.0..width.to_f), y: rand(0.0..height.to_f))
        v_max = 30.0
        a.velocity = Vector2.new(x: rand(-v_max..v_max), y: rand(-v_max..v_max))
        a.rotation_speed = rand(-5.0..5.0)

        size = rand(5.0..30.0)
        a.mass = size
        a.frame = VectorSprite.generate_circle(size.to_i, size: size, jitter: 3.0)
      end
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
    @asteroids.each do |a|
      a.update(dt)
      a.position = wrap(a.position)
    end

    collission_pairs = [] of Tuple(Asteroid, Asteroid)
    @asteroids.each do |a|
      @asteroids.each do |b|
        next if a == b
        next if collission_pairs.includes?({a, b})

        if a.collides_with?(b)
          collission_pairs << {a, b}
          a.resolve_collision(b)
          puts "#{a} collided with #{b}"
        end
      end
    end

    @bullets.each do |bullet|
      @asteroids.each do |asteroid|
        if bullet.collides_with?(asteroid)
          if asteroid.mass > 3.0
            2.times do
              @asteroids << Asteroid.build do |a|
                a.position = asteroid.position + Vector2.new(rand(-1.0..1.0), rand(-1.0..1.0))
                v_max = 30.0
                a.velocity = Vector2.new(x: rand(-v_max..v_max), y: rand(-v_max..v_max))
                a.rotation_speed = rand(-5.0..5.0)
                size = asteroid.average_radius / 2
                a.mass = size
                points = size < 6 ? 6 : size.to_i
                a.frame = VectorSprite.generate_circle(points, size: size, jitter: 3.0)
              end
            end
          end

          @asteroids.delete(asteroid)
          @bullets.delete(bullet)
        end
      end
    end
  end

  def draw
    @renderer.draw_color = SDL::Color[0, 0, 0, 255]
    @renderer.clear
    @ship.draw(@renderer)
    @bullets.each { |b| b.draw(@renderer) }
    @asteroids.each { |a| a.draw(@renderer) }
  end
end

game = Asteroids.new(WIDTH, HEIGHT, SCALE)
game.run!
