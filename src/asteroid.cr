require "pixelfaucet/entity"
require "pixelfaucet/entity/circle_collision"
require "pixelfaucet/shape"
require "./entity"

class Asteroid < Entity
  include PF::CircleCollision

  property size : Float64 = 1.0
  property color = PF::Pixel.new(128, 128, 128, 255)
  property frame : Array(PF::Point(Float64)) = [] of PF::Point(Float64)
  @radius : Float64? = nil

  def update(dt)
    super(dt)
  end

  def draw(engine)
    frame = project(points: @frame, scale: PF::Point(Float64).new(@size, @size))
    engine.draw_shape(frame, color)
  end

  def radius
    @radius ||= PF::Shape.average_radius(@frame)
  end
end
