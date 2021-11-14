module LxGame
  # Draw a line using Bresenham’s Algorithm
  def draw_line(renderer : SDL::Renderer, p1 : Vector2, p2 : Vector2, draw_points = false, point_color = SDL::Color[255, 0, 0, 255])
    return draw_line(renderer, p2, p1) if p1.x > p2.x
    x1, y1, x2, y2 = p1.x.to_i, p1.y.to_i, p2.x.to_i, p2.y.to_i

    dx = (x2 - x1).abs
    dy = -(y2 - y1).abs

    sx = x1 < x2 ? 1 : -1
    sy = y1 < y2 ? 1 : -1

    d = dx + dy
    x, y = x1, y1

    loop do
      draw_point(renderer, x, y)
      break if x == x2 && y == y2

      d2 = d + d

      if d2 >= dy
        d += dy
        x += sx
      end

      if d2 <= dx
        d += dx
        y += sy
      end
    end

    if draw_points
      renderer.draw_color = point_color
      draw_point(renderer, x1, y1)
      draw_point(renderer, x2, y2)
    end
  end

  def draw_point(renderer, x1, y1)
    renderer.draw_point(x1, y1)
  end
end
