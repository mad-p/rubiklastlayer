require 'rmagick'

class CubePng

  attr_accessor :canvas, :image
  SIDE = 3
  RECT = 7
  EDGE = 3
  OFFSET = 3
  BG_COLOR = 'white'
  FRAME_COLOR = 'black'

  def initialize
    size = RECT * 3 + 4 + SIDE * 2
    @canvas = Magick::ImageList.new
    @image = @canvas.new_image(size, size, Magick::SolidFill.new(BG_COLOR))
  end
  def draw_line(sx, sy, ex, ey, color)
    draw = Magick::Draw.new
    draw.stroke(color)
    draw.stroke_width(1)
    draw.stroke_antialias(false)
    draw.line(sx, sy, ex, ey)
    draw.draw(@canvas)
  end
  def draw_rectangle(sx, sy, ex, ey, color)
    draw = Magick::Draw.new
    draw.fill(color)
    draw.rectangle(sx, sy, ex, ey)
    draw.draw(@canvas)
  end
  def draw_frame
    e = SIDE + (RECT + 1) * 3
    4.times do |i|
      x = SIDE + (RECT + 1) * i
      draw_line(SIDE, x, e, x, FRAME_COLOR)
      draw_line(x, SIDE, x, e, FRAME_COLOR)
    end
  end
  # face
  #   0 1 2
  #   3 4 5
  #   6 7 8
  def fill_face(n, color)
    x = n % 3
    y = n / 3
    sx = x * (RECT + 1) + OFFSET + 1
    sy = y * (RECT + 1) + OFFSET + 1
    ex = sx + RECT - 1
    ey = sy + RECT - 1
    draw_rectangle(sx, sy, ex, ey, color)
  end
  # edge
  #   0 1 2
  # 3 . . . 6
  # 4 . . . 7
  # 5 . . . 8
  #   91011
  def fill_edge(n, color, marker = false)
    edge_config = [
      #bx,by,x_eoff, y_eoff, wd,   ht,   xm,  ym
      [0, 0, 0,      -1,     RECT, EDGE, 0,   0],
      [1, 0, 0,      -1,     RECT, EDGE, 0,   0],
      [2, 0, 0,      -1,     RECT, EDGE, 0,   0],
      [0, 0, -1,     0,      EDGE, RECT, 0,  0],
      [0, 1, -1,     0,      EDGE, RECT, 0,  0],
      [0, 2, -1,     0,      EDGE, RECT, 0,  0],
      [3, 0, 0,      0,      EDGE, RECT, 1,  0],
      [3, 1, 0,      0,      EDGE, RECT, 1,  0],
      [3, 2, 0,      0,      EDGE, RECT, 1,  0],
      [0, 3, 0,      0,      RECT, EDGE, 0,   1],
      [1, 3, 0,      0,      RECT, EDGE, 0,   1],
      [2, 3, 0,      0,      RECT, EDGE, 0,   1],
    ]
    bx, by, x_eoff, y_eoff, wd, ht, xm, ym = edge_config[n]
    sx = bx * (RECT + 1) + OFFSET + 1 + x_eoff * (EDGE + 1)
    sy = by * (RECT + 1) + OFFSET + 1 + y_eoff * (EDGE + 1)
    ex = sx + wd - 1
    ey = sy + ht - 1
    draw_rectangle(sx, sy, ex, ey, color)
    if marker
      if wd == RECT
        draw_line(sx, sy + ym * (EDGE - 1), ex, sy + ym * (EDGE - 1), FRAME_COLOR)
      else
        draw_line(sx + xm * (EDGE - 1), sy, sx + xm * (EDGE - 1), ey, FRAME_COLOR)
      end
    end
  end
  def draw_perm_line(st, en, offset)
    scx = st % 3
    scy = st / 3
    ecx = en % 3
    ecy = en / 3
    sx = scx * (RECT + 1) + OFFSET + 1 + (RECT / 2)
    sy = scy * (RECT + 1) + OFFSET + 1 + (RECT / 2)
    ex = ecx * (RECT + 1) + OFFSET + 1 + (RECT / 2)
    ey = ecy * (RECT + 1) + OFFSET + 1 + (RECT / 2)
    center = (RECT + 1) + OFFSET + 1 + (RECT / 2)
    case offset
    when :outer
      sx += (sx <=> center)
      sy += (sy <=> center)
      ex += (ex <=> center)
      ey += (ey <=> center)
    when :inner
      sx -= (sx <=> center)
      sy -= (sy <=> center)
      ex -= (ex <=> center)
      ey -= (ey <=> center)
    end
    draw_line(sx, sy, ex, ey, FRAME_COLOR)
  end
  def save_png(filename)
    @canvas.write(filename)
  end
end
