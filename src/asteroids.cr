require "sdl"
require "crystaledge"
include CrystalEdge
require "./lx_game/*"
include LxGame
require "./ship"
require "./asteroid"
require "./bullet"
require "./explosion"

class Asteroids < Game
  @ship : Ship
  @asteroids = [] of Asteroid
  @bullets = [] of Bullet
  @explosions = [] of Explosion
  @controller : Controller(LibSDL::Keycode)
  @asteroid_count = 3
  @restart_timer = 0.0

  def initialize(*args)
    super

    @ship = Ship.build do |ship|
      ship.position = Vector2.new(x: width / 2.0, y: height / 2.0)
    end

    setup_round

    @controller = Controller(LibSDL::Keycode).new({
      LibSDL::Keycode::UP    => "Thrust",
      LibSDL::Keycode::RIGHT => "Rotate Right",
      LibSDL::Keycode::LEFT  => "Rotate Left",
      LibSDL::Keycode::SPACE => "Fire",
    })
  end

  # override to wrap the coordinates
  def draw_point(x : Int32, y : Int32, pixel : Pixel, surface = @screen)
    x = x % @width
    y = y % @height

    x = @width + x if x < 0
    y = @height + y if y < 0

    super(x, y, pixel, surface)
  end

  def generate_asteroids
    center_size = Vector2.new(50.0, 50.0)
    center_pos = Vector2.new((width.to_f / 2.0) - (center_size.x / 2.0), (height.to_f / 2.0) - (center_size.y / 2.0))

    @asteroid_count.times do
      @asteroids << Asteroid.build do |a|
        loop do
          a.position = Vector2.new(x: rand(0.0..width.to_f), y: rand(0.0..height.to_f))
          break if (a.position.x < center_pos.x || a.position.x > center_pos.x + center_size.x) && (a.position.y < center_pos.y || a.position.y > center_pos.y + center_size.y)
        end
        v_max = 30.0
        a.velocity = Vector2.new(x: rand(-v_max..v_max), y: rand(-v_max..v_max))
        a.rotation_speed = rand(-5.0..5.0)

        size = rand(20.0..35.0)
        a.mass = size
        a.frame = VectorSprite.generate_circle(size.to_i, size: size, jitter: 3.0)
      end
    end
  end

  def setup_round
    @restart_timer = 0.0
    @asteroids = [] of Asteroid
    generate_asteroids
    @bullets = [] of Bullet
    @ship.blew_up = false
    @ship.position = Vector2.new(x: width / 2.0, y: height / 2.0)
    @ship.velocity = Vector2.new(0.0, 0.0)
    @ship.rotation_speed = 0.0
  end

  def wrap(position : Vector2)
    position.x = 0.0 if position.x > @width
    position.x = @width.to_f64 if position.x < 0.0

    position.y = 0.0 if position.y > @height
    position.y = @height.to_f64 if position.y < 0.0

    position
  end

  def update(dt : Float64)
    if @asteroids.size == 0 && !@ship.blew_up
      @asteroid_count += 1
      setup_round
    end

    @restart_timer += dt if @ship.blew_up
    setup_round if @restart_timer > 3.0

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
      bullet.position = wrap(bullet.position)
    end

    @bullets = @bullets.reject(&.dead?)
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
          # puts "#{a} collided with #{b}"
        end
      end
    end

    @bullets.each do |bullet|
      @asteroids.each do |asteroid|
        if bullet.collides_with?(asteroid)
          if asteroid.mass > 7.0
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

          @explosions << Explosion.build do |e|
            e.size = asteroid.average_radius * 2
            e.position = bullet.position
            e.velocity = asteroid.velocity
            e.emit_freq = 0.01
            e.strength = 25
            e.max_age = 1.0
          end

          @asteroids.delete(asteroid)
          @bullets.delete(bullet)
        end
      end
    end

    @explosions.each do |e|
      e.update(dt)
      e.position = wrap(e.position)
      e.emitting = false if e.age > 0.5
    end

    @explosions.reject! { |e| e.emitting == false && e.particles.none? }
    @asteroids.each do |a|
      if @ship.collides_with?(a)
        @ship.blew_up = true
        @explosions << Explosion.build do |e|
          e.size = 10.0
          e.position = @ship.position
          e.velocity = @ship.velocity
          e.emit_freq = 0.01
          e.strength = 30
          e.max_age = 1.0
        end
      end
    end
  end

  def draw(engine)
    engine.clear
    @ship.draw(engine)
    @bullets.each { |b| b.draw(engine) }
    @asteroids.each { |a| a.draw(engine) }
    @explosions.each { |e| e.draw(engine) }
  end
end

game = Asteroids.new(500, 400, 2)
game.run!
