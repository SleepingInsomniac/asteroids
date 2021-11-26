require "pixelfaucet/sprite"
require "pixelfaucet/sprite/circle_collision"
require "pixelfaucet/sprite/vector_sprite"

class Asteroid < PF::Sprite
  include PF::CircleCollision
  include PF::VectorSprite

  property size : Float64 = 1.0
  property color = PF::Pixel.new(128, 128, 128, 255)

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
