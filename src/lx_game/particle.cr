require "./sprite"

module LxGame
  class Particle < Sprite
    property age : Float64 = 0.0
    property lifespan : Float64 = 4.0
    @dead : Bool = false

    def dead?
      @age >= @lifespan
    end

    def update(dt : Float64)
      return if dead?
      update_position(dt)
      @age += dt
    end

    def draw(renderer : SDL::Renderer)
      return if dead?
      brightness = ((@lifespan - @age) / @lifespan) * 255
      renderer.draw_color = SDL::Color[brightness / 2, brightness / 2, brightness / 2]
      renderer.draw_point(@position.x.to_i, @position.y.to_i)
    end
  end
end
