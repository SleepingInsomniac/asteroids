require "./sprite"
require "./particle"

module LxGame
  class Emitter < Sprite
    property emitting : Bool = true
    property particles = [] of Particle
    property max_age : Float64 = 1.0
    property emit_freq : Float64 = 0.05
    property strength : Float64 = 50.0
    @last_emitted : Float64 = 0.0
    property emit_angle : Float64 = 1.0

    def generate_particle
      Particle.build do |particle|
        particle.position = @position
        direction = rand((@rotation - @emit_angle)..(@rotation + @emit_angle))
        particle.velocity = @velocity + Vector2.new(Math.cos(direction), Math.sin(direction)) * @strength
        particle.lifespan = @max_age
      end
    end

    def update(dt : Float64)
      update_position(dt)

      @last_emitted += dt

      if @emitting && @last_emitted >= @emit_freq
        @last_emitted = 0.0
        @particles << generate_particle
      end

      @particles.each { |particle| particle.update(dt) }
      @particles.reject! { |particle| particle.dead? }
    end

    def draw(renderer : SDL::Renderer)
      renderer.draw_color = SDL::Color[255, 255, 0, 255]

      @particles.each do |particle|
        particle.draw(renderer)
      end
    end
  end
end
