require "./lx_game/sprite/circle_collision"
require "./lx_game/sprite/vector_sprite"

class Asteroid < Sprite
  include LxGame::CircleCollision
  include LxGame::VectorSprite

  property size : Float64 = 1.0
  property color : Pixel = Pixel.new(128, 128, 128, 255)

  def initialize
    super
    @frame = [] of Vector2
  end

  def update(dt)
    update_position(dt)
  end

  def draw(engine)
    frame = project_points(points: @frame, scale: Vector2.new(@size, @size))
    draw_frame(engine, frame, color)
  end
end
