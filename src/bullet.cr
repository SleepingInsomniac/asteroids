require "pixelfaucet/entity"
require "pixelfaucet/entity/entity_age"

class Bullet < PF::Entity
  include PF::EntityAge

  @lifespan = 2.5

  def update(dt)
    update_age(dt)
    return if dead?
    super(dt)
  end

  def draw(engine)
    brightness = (((4.0 - self.age) / 4.0) * 255).to_u8
    color = PF::RGBA.new(brightness, brightness, 0_u8)
    engine.draw_point(@position.x.to_i, @position.y.to_i, color)
  end

  def collides_with?(asteroid : Asteroid)
    @position.distance(asteroid.position) < asteroid.radius
  end
end
