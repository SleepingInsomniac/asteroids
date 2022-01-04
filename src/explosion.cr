require "pixelfaucet/emitter"
require "pixelfaucet/entity/entity_age"

class Explosion < PF::Emitter
  include PF::EntityAge

  def update(dt)
    update_age(dt)
    super
  end
end
