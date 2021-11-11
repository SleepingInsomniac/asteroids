module LxGame
  abstract class Sprite
    def self.build
      sprite = new
      yield sprite
      sprite
    end

    property rotation : Float64
    property position : Vector2
    property velocity : Vector2
    property rotation_speed : Float64

    def initialize
      @position = Vector2.new(0.0, 0.0)
      @velocity = Vector2.new(0.0, 0.0)
      @rotation = 0.0
      @rotation_speed = 0.0
    end

    abstract def draw(renderer : SDL::Renderer)
  end
end
