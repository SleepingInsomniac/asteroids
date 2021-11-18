module LxGame
  module SpriteAge
    property age : Float64 = 0.0

    def update(dt : Float64)
      self.age += dt
    end
  end
end
