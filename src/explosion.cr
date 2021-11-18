require "./lx_game/sprite/age"

class Explosion < LxGame::Emitter
  include LxGame::SpriteAge

  def update(dt)
    update_age(dt)
    super
  end
end
