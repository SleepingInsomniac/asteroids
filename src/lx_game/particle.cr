require "./sprite"
require "./sprite/age"

module LxGame
  class Particle < Sprite
    include SpriteAge

    def update(dt : Float64)
      update_age(dt)
      return if dead?
      update_position(dt)
    end

    def draw(renderer : SDL::Renderer)
      return if dead?
      brightness = ((@lifespan - @age) / @lifespan) * 255
      renderer.draw_color = SDL::Color[brightness / 2, brightness / 2, brightness / 2]
      renderer.draw_point(@position.x.to_i, @position.y.to_i)
    end
  end
end
