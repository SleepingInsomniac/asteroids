class Asteroid < VectorSprite
  def initialize
    super
    @frame = VectorSprite.generate_circle(12, size: 10.0, jitter: 3.0)
  end

  def draw(renderer)
    frame = project_points(@frame)
    renderer.draw_color = SDL::Color[128, 128, 128, 255]
    draw_frame(renderer, frame)
  end
end
