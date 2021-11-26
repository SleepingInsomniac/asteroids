require "pixelfaucet/sprite"
require "pixelfaucet/sprite/age"

class Bullet < PF::Sprite
  include PF::SpriteAge

  @lifespan = 2.5

  def update(dt)
    update_age(dt)
    return if dead?
    update_position(dt)
  end

  def draw(engine)
    brightness = (((4.0 - self.age) / 4.0) * 255).to_u8
    color = PF::Pixel.new(r: brightness, g: brightness, b: 0_u8)
    engine.draw_point(@position.x.to_i, @position.y.to_i, color)
  end

  def collides_with?(other : PF::VectorSprite)
    @position.distance(other.position) < other.radius
  end
end
