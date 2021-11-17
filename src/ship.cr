class Ship < VectorSprite
  @fire_cooldown : Float64 = 0.0
  @fire_rate : Float64 = 0.2
  @emitter : Emitter
  @l_emitter : Emitter
  @r_emitter : Emitter

  def initialize
    super

    @r_engine = 10.0
    @t_engine = 50.0

    @frame = [
      Vector2.new(5.0, 0.0),
      Vector2.new(-3.0, 3.0),
      Vector2.new(-3.0, -3.0),
    ]

    @emitter = Emitter.build do |e|
      e.position = @position
      e.emit_freq = 0.01
      e.emit_angle = 0.5
      e.strength = 50.0
      e.max_age = 0.25
    end

    @l_emitter = Emitter.build do |e|
      e.position = @position
      e.emit_freq = 0.01
      e.emit_angle = 0.3
      e.strength = 25.0
      e.max_age = 0.25
    end

    @r_emitter = Emitter.build do |e|
      e.position = @position
      e.emit_freq = 0.01
      e.emit_angle = 0.3
      e.strength = 25.0
      e.max_age = 0.25
    end
  end

  def can_fire?
    @fire_cooldown <= 0.0
  end

  def fire
    @fire_cooldown = @fire_rate
    @velocity.x -= Math.cos(@rotation) * 3.0
    @velocity.y -= Math.sin(@rotation) * 3.0
    Bullet.build do |bullet|
      bullet.position = project_points([@frame[0]]).first
      bullet.velocity = @velocity + Vector2.new(Math.cos(@rotation), Math.sin(@rotation)) * 100.0
    end
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

  def update(dt : Float64)
    super

    @fire_cooldown -= dt unless can_fire?

    @emitter.update(dt)
    @emitter.position = project_points([Vector2.new(-3.0, 0.0)]).first
    @emitter.velocity = @velocity
    @emitter.rotation = @rotation - Math::PI

    @l_emitter.update(dt)
    @l_emitter.position = project_points([Vector2.new(3.0, -1.0)]).first
    @l_emitter.velocity = @velocity
    @l_emitter.rotation = @rotation - 1.5

    @r_emitter.update(dt)
    @r_emitter.position = project_points([Vector2.new(3.0, 1.0)]).first
    @r_emitter.velocity = @velocity
    @r_emitter.rotation = @rotation + 1.5
  end

  def draw(renderer)
    @emitter.draw(renderer)
    @emitter.emitting = false
    @l_emitter.draw(renderer)
    @l_emitter.emitting = false
    @r_emitter.draw(renderer)
    @r_emitter.emitting = false

    frame = project_points(@frame)
    renderer.draw_color = SDL::Color[255, 255, 255, 255]
    draw_frame(renderer, frame)
  end
end
