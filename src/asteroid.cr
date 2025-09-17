require "pixelfaucet/entity"
require "pixelfaucet/entity/circle_collision"
require "pixelfaucet/shape"
require "./entity"

class Asteroid < Entity
  include PF::CircleCollision

  property size : Float64 = 1.0
  property color = PF::Pixel.new(128, 128, 128, 255)
  property frame : Array(PF2d::Vec2(Float64)) = [] of PF2d::Vec2(Float64)
  @radius : Float64? = nil

  def update(dt)
    super(dt)
  end

  def draw(engine)
    frame = project(points: @frame, scale: PF2d::Vec2(Float64).new(@size, @size))
    frame.each_cons_pair do |p1, p2|
      engine.draw_line(p1.x, p1.y, p2.x, p2.y, color)
    end
    engine.draw_line(frame.last.x, frame.last.y, frame.first.x, frame.first.y, color)
  end

  def radius
    @radius ||= PF::Shape.average_radius(@frame)
  end
end
