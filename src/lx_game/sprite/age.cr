module LxGame
  module SpriteAge
    getter age : Float64 = 0.0

    def update(dt : Float64)
      super
      @age += dt
    end
  end
end
