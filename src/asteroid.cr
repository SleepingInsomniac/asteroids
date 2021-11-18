require "./lx_game/sprite/circle_collision"
require "./lx_game/sprite/vector_sprite"

class Asteroid < Sprite
  include LxGame::CircleCollision
  include LxGame::VectorSprite

  property size : Float64 = 1.0

  def initialize
    super
    @frame = [] of Vector2
  end

  def update(dt)
    update_position(dt)
  end

  def draw(renderer)
    # renderer.draw_color = SDL::Color[0, 100, 100, 255]
    # draw_radius(renderer)
    frame = project_points(points: @frame, scale: Vector2.new(@size, @size))
    renderer.draw_color = SDL::Color[128, 128, 128, 255]
    draw_frame(renderer, frame)
  end
end
