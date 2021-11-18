require "./lx_game/sprite/age"

class Bullet < Sprite
  include LxGame::SpriteAge

  def update(dt)
    super
    update_position(dt)
  end

  def draw(renderer)
    brightness = ((4.0 - self.age) / 4.0) * 255
    renderer.draw_color = SDL::Color[brightness, brightness, 0]
    renderer.draw_point(@position.x.to_i, @position.y.to_i)
  end

  def collides_with?(other : VectorSprite)
    @position.distance(other.position) < other.radius
  end
end
