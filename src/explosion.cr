require "pixelfaucet/emitter"
require "pixelfaucet/sprite/age"

class Explosion < PF::Emitter
  include PF::SpriteAge

  def update(dt)
    update_age(dt)
    super
  end
end
