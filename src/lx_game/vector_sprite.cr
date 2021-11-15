module LxGame
  abstract class VectorSprite < Sprite
    property mass : Float64 = 10.0
    property frame = [] of Vector2
    @average_radius : Float64? = nil

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

    def average_radius
      @average_radius ||= begin
        # calculate length from center for all points
        lengths = frame.map do |vec|
          Math.sqrt(vec.x ** 2 + vec.y ** 2)
        end

        # get the average of the lengths
        lengths.reduce { |t, p| t + p } / frame.size.to_f
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

    def draw_radius(renderer : SDL::Renderer, points = 30)
      circle = self.class.generate_circle(points, average_radius).map do |point|
        point + @position
      end
      draw_frame(renderer, frame: circle)
    end

    def distance_between(other)
      @position.distance(other.position)
    end

    def collides_with?(other : VectorSprite)
      distance_between(other) < average_radius + other.average_radius
    end

    # Move objects so that they don't overlap
    def offset_position(other : VectorSprite)
      distance = distance_between(other)
      overlap = distance - average_radius - other.average_radius
      offset = ((@position - other.position) * (overlap / 2)) / distance

      @position -= offset
      other.position += offset
    end

    def resolve_collision(other : VectorSprite)
      offset_position(other)
      distance = distance_between(other)

      # Calculate the new velocities
      normal_vec = (@position - other.position) / distance
      tangental_vec = Vector2.new(-normal_vec.y, normal_vec.x)

      # Dot product of velocity with the tangent
      # (the direction in which to bounce towards)
      dp_tangent_a = velocity.dot(tangental_vec)
      dp_tangent_b = other.velocity.dot(tangental_vec)

      # Dot product of the normal
      dp_normal_a = velocity.dot(normal_vec)
      dp_normal_b = other.velocity.dot(normal_vec)

      # conservation of momentum
      ma = (dp_normal_a * (mass - other.mass) + 2.0 * other.mass * dp_normal_b) / (mass + other.mass)
      mb = (dp_normal_b * (other.mass - mass) + 2.0 * mass * dp_normal_a) / (mass + other.mass)

      # Set the new velocities
      @velocity = (tangental_vec * dp_tangent_a) + (normal_vec * ma)
      other.velocity = (tangental_vec * dp_tangent_b) + (normal_vec * mb)
    end
  end
end
