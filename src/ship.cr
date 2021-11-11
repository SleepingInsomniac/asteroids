class Ship < VectorSprite
  getter frame : Array(Vector2)
  @last_fired : Float64

  def initialize
    super

    @r_engine = 0.03
    @t_engine = 0.1

    @frame = [
      Vector2.new(5.0, 0.0),
      Vector2.new(-3.0, 3.0),
      Vector2.new(-3.0, -3.0),
    ]

    @jet_left = [Vector2.new(2.0, -5.0), Vector2.new(2.0, -3.5)]
    @jet_right = [Vector2.new(2.0, 3.5), Vector2.new(2.0, 5.0)]
    @jet_rear = [Vector2.new(-7.0, 0.0), Vector2.new(-3.0, 0.0)]

    @thrusting_left = false
    @thrusting_right = false
    @thrusting_forward = false

    @last_fired = Time.monotonic.total_milliseconds
  end

  def can_fire?
    now = Time.monotonic.total_milliseconds
    now - @last_fired > 100.0
  end

  def fire
    @last_fired = Time.monotonic.total_milliseconds
    Bullet.build do |bullet|
      bullet.position = project_points([@frame[0]]).first
      bullet.velocity = @velocity + Vector2.new(Math.cos(@rotation), Math.sin(@rotation)) * 0.1
    end
  end

  def rotate_right(dt : Float64, amount = @r_engine)
    @thrusting_left = true
    @rotation_speed += amount * dt
  end

  def rotate_left(dt : Float64, amount = @r_engine)
    @thrusting_right = true
    @rotation_speed -= amount * dt
  end

  def thrust(dt : Float64)
    @thrusting_forward = true
    @velocity.x += Math.cos(@rotation) * dt * @t_engine
    @velocity.y += Math.sin(@rotation) * dt * @t_engine
  end

  def update(dt : Float64)
    @rotation += @rotation_speed
    @position += @velocity

    # @rotation_speed = 0.0 if @rotation_speed < 0.001 && @rotation_speed > -0.001
    # rotate_left(dt, 0.01) if @rotation_speed >= 0.01
    # rotate_right(dt, 0.01) if @rotation_speed <= -0.01
  end

  def draw(renderer)
    frame = project_points(@frame)

    renderer.draw_color = SDL::Color[128, 128, 128, 255]

    if @thrusting_left
      @thrusting_left = false
      jet_left = project_points(@jet_left, @rotation + rand(-0.5..0.5))
      draw_line(renderer, jet_left[0], jet_left[1])
    end

    if @thrusting_right
      @thrusting_right = false
      jet_right = project_points(@jet_right, @rotation + rand(-0.5..0.5))
      draw_line(renderer, jet_right[0], jet_right[1])
    end

    if @thrusting_forward
      @thrusting_forward = false
      jet_rear = project_points(@jet_rear, @rotation + rand(-0.5..0.5))
      draw_line(renderer, jet_rear[0], jet_rear[1])
    end

    renderer.draw_color = SDL::Color[255, 255, 255, 255]

    draw_line(renderer, frame[0], frame[1])
    draw_line(renderer, frame[1], frame[2])
    draw_line(renderer, frame[2], frame[0])

    # renderer.draw_color = SDL::Color[255, 255, 0, 255]
    # renderer.draw_point(@position.x.to_i, @position.y.to_i)
  end
end
