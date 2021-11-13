class Bullet < Sprite
  property age : Float64 = 0.0

  def update(dt : Float64)
    update_position(dt)
    @age += dt
  end

  def draw(renderer)
    brightness = ((4.0 - @age) / 4.0) * 255
    renderer.draw_color = SDL::Color[brightness, brightness, 0]
    renderer.draw_point(@position.x.to_i, @position.y.to_i)
  end
end
