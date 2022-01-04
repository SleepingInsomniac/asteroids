class Entity < PF::Entity
  private def project(points : Enumerable(PF::Point), origin = PF::Point.new(0.0, 0.0), rotation : Float64 = @rotation, translation : PF::Point(Float64) = @position, scale = 1.0)
    rc = Math.cos(rotation)
    rs = Math.sin(rotation)
    points.map do |point|
      # Rotate and translate
      point = point + origin
      PF::Point.new(point.x * rc - point.y * rs, point.y * rc + point.x * rs) * scale + translation
    end
  end

  private def project(*points : Enumerable(PF::Point), origin = PF::Point.new(0.0, 0.0), rotation : Float64 = @rotation, translation : PF::Point(Float64) = @position, scale = 1.0)
    project(points, origin, rotation, translation, scale)
  end
end
