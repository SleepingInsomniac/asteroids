class Entity < PF::Entity
  private def project(points : Enumerable(PF2d::Vec2), origin = PF2d::Vec[0.0, 0.0], rotation : Float64 = @rotation, translation : PF2d::Vec2(Float64) = @position, scale = 1.0)
    rc = Math.cos(rotation)
    rs = Math.sin(rotation)
    points.map do |point|
      # Rotate and translate
      point = point + origin
      PF2d::Vec2.new(point.x * rc - point.y * rs, point.y * rc + point.x * rs) * scale + translation
    end
  end

  private def project(*points : Enumerable(PF2d::Vec2), origin = PF2d::Vec2[0.0, 0.0], rotation : Float64 = @rotation, translation : PF2d::Vec2(Float64) = @position, scale = 1.0)
    project(points, origin, rotation, translation, scale)
  end
end
