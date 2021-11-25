require "./lx_game/sprite/age"

class Bullet < Sprite
  include LxGame::SpriteAge

  @lifespan = 4.0

  def update(dt)
    update_age(dt)
    return if dead?
    update_position(dt)
  end

  def draw(engine)
    brightness = (((4.0 - self.age) / 4.0) * 255).to_u8
    color = Pixel.new(r: brightness, g: brightness, b: 0_u8)
    engine.draw_point(@position.x.to_i, @position.y.to_i, color)
  end

  def collides_with?(other : VectorSprite)
    @position.distance(other.position) < other.radius
  end
end
