require "pixelfaucet/entity"
require "pixelfaucet/shape"
require "pixelfaucet/emitter"
require "./entity"

class Ship < Entity
  @fire_cooldown : Float64 = 0.0
  @fire_rate : Float64 = 0.2
  @fire_speed = 125.0
  @fire_recoil = 3.0
  @emitter : PF::Emitter
  @l_emitter : PF::Emitter
  @r_emitter : PF::Emitter
  @projected_points : Array(PF::Point(Float64))? = nil
  property blew_up : Bool = false
  @color = PF::Pixel.new
  @frame = [] of PF::Point(Float64)

  def initialize
    @r_engine = 10.0
    @t_engine = 50.0

    @frame = [
      PF::Point.new(5.0, 0.0),
      PF::Point.new(-3.0, 3.0),
      PF::Point.new(-3.0, -3.0),
    ]

    @emitter = PF::Emitter.new
    @emitter.position = @position
    @emitter.emit_freq = 0.01
    @emitter.emit_angle = 0.5
    @emitter.strength = 50.0
    @emitter.max_age = 0.25

    @l_emitter = PF::Emitter.new
    @l_emitter.position = @position
    @l_emitter.emit_freq = 0.01
    @l_emitter.emit_angle = 0.3
    @l_emitter.strength = 25.0
    @l_emitter.max_age = 0.25

    @r_emitter = PF::Emitter.new
    @r_emitter.position = @position
    @r_emitter.emit_freq = 0.01
    @r_emitter.emit_angle = 0.3
    @r_emitter.strength = 25.0
    @r_emitter.max_age = 0.25
  end

  def can_fire?
    @fire_cooldown <= 0.0
  end

  def fire
    @fire_cooldown = @fire_rate
    @velocity.x -= Math.cos(@rotation) * @fire_recoil
    @velocity.y -= Math.sin(@rotation) * @fire_recoil
    b = Bullet.new
    b.position = project({@frame[0]}).first
    b.velocity = @velocity + PF::Point.new(Math.cos(@rotation), Math.sin(@rotation)) * @fire_speed
    b
  end

  def rotate_right(dt : Float64, amount = @r_engine)
    @l_emitter.emitting = true
    @rotation_speed += amount * dt
  end

  def rotate_left(dt : Float64, amount = @r_engine)
    @r_emitter.emitting = true
    @rotation_speed -= amount * dt
  end

  def thrust(dt : Float64)
    @emitter.emitting = true
    @velocity.x += Math.cos(@rotation) * dt * @t_engine
    @velocity.y += Math.sin(@rotation) * dt * @t_engine
  end

  def projected_points
    @projected_points ||= project(@frame)
  end

  def collides_with?(asteroid : Asteroid)
    return false if @blew_up
    projected_points.any? do |point|
      asteroid.position.distance(point) < asteroid.radius
    end
  end

  def update(dt : Float64)
    return if @blew_up
    @projected_points = nil
    super(dt)

    @fire_cooldown -= dt unless can_fire?

    @emitter.update(dt)
    @emitter.position = project({PF::Point.new(-3.0, 0.0)}).first
    @emitter.velocity = @velocity
    @emitter.rotation = @rotation - Math::PI

    @l_emitter.update(dt)
    @l_emitter.position = project({PF::Point.new(3.0, -1.0)}).first
    @l_emitter.velocity = @velocity
    @l_emitter.rotation = @rotation - 1.5

    @r_emitter.update(dt)
    @r_emitter.position = project({PF::Point.new(3.0, 1.0)}).first
    @r_emitter.velocity = @velocity
    @r_emitter.rotation = @rotation + 1.5
  end

  def draw(engine)
    return if @blew_up
    @emitter.draw(engine)
    @emitter.emitting = false
    @l_emitter.draw(engine)
    @l_emitter.emitting = false
    @r_emitter.draw(engine)
    @r_emitter.emitting = false

    # renderer.draw_color = SDL::Color[255, 255, 255, 255]
    engine.fill_triangle(projected_points.map(&.to_i32), @color)
  end
end
