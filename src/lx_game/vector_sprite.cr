module LxGame
  abstract class VectorSprite < Sprite
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
  end
end
