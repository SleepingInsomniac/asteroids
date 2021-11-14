class Asteroid < VectorSprite
  property size : Float64 = 1.0

  def initialize
    super
    @frame = VectorSprite.generate_circle(15, size: 10.0, jitter: 3.0)
  end

  def draw(renderer)
    frame = project_points(points: @frame, scale: Vector2.new(@size, @size))
    renderer.draw_color = SDL::Color[128, 128, 128, 255]
    draw_frame(renderer, frame)
  end
end
