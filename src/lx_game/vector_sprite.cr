module LxGame
  abstract class VectorSprite < Sprite
    getter frame = [] of Vector2

    def self.generate_circle(num_points : Int, size = 1.0, jitter = 0.0) : Array(Vector2)
      0.upto(num_points).map do |n|
        angle = (2 * Math::PI) * (n / num_points)

        x = size + rand(-jitter..jitter)

        rc = Math.cos(angle)
        rs = Math.sin(angle)
        Vector2.new(0.0 * rc - x * rs, x * rc + 0.0 * rs)
      end.to_a
    end

    def project_points(points : Array(Vector2), rotation = @rotation, translate : Vector2? = nil, scale : Vector2? = nil)
      rc = Math.cos(rotation)
      rs = Math.sin(rotation)

      translation =
        if t = translate
          @position + t
        else
          @position
        end

      points.map do |point|
        rotated = Vector2.new(point.x * rc - point.y * rs, point.y * rc + point.x * rs)

        scale.try do |scale|
          rotated = rotated * scale
        end

        translation + rotated
      end
    end

    def update(dt : Float64)
      update_position(dt)
    end

    def draw_frame(renderer : SDL::Renderer, frame = @frame)
      0.upto(frame.size - 1) do |n|
        draw_line(renderer, frame[n], frame[(n + 1) % frame.size])
      end
    end
  end
end
