# Represent cube state
# Has methods about moves

require 'debug'
require './cube_png'

class Cube

  # Face colors
  U = 0; D = 1; F = 2; B = 3; R = 4; L = 5
  U_COLOR = '#ffff00'   # U: yellow
  D_COLOR = '#dddddd'   # D: white
  F_COLOR = '#ff8000'   # F: orange
  B_COLOR = '#ff0000'   # B: red
  R_COLOR = '#009900'   # L: blue
  L_COLOR = '#000099'   # R: green

  FACE_NAMES = %w[U D F B R L]
  FACE_COLORS = {
    "U" => U_COLOR,
    "D" => D_COLOR,
    "F" => F_COLOR,
    "B" => B_COLOR,
    "R" => R_COLOR,
    "L" => L_COLOR,
  }

  # Cube topologies
  NEIGHBORS = [
    "FLBR", # U's neibors in clockwise order
    "FRBL",
    "URDL",
    "ULDR",
    "UBDF",
    "UFDB",
  ]

  # Translations: Hash[String]: String
  #   key: move name: eg. "U'", "x"
  #   value: Hash[String]: String
  #     key: from sticker name: eg. "UFL", "FLU", "U"
  #     value: to sticker name
  TRANS = {}

  # Name of all stickers
  STICKERS = []

  # setup TRANS and STICKERS
  def self.init_trans
    # Face turns
    FACE_NAMES.each.with_index do |f, i|
      trans = {} # single layer turns
      trans2 = {} # double layer turns
      neibors = NEIGHBORS[i]
      4.times do |j|
        k = (j+1) % 4
        l = (j+2) % 4
        # f face corners
        corner_from = [f, neibors[j], neibors[k]]
        corner_to   = [f, neibors[k], neibors[l]]
        3.times do |m|
          sticker_from = corner_from[m] + corner_from[(m+1)%3] + corner_from[(m+2)%3]
          sticker_to   = corner_to  [m] + corner_to  [(m+1)%3] + corner_to  [(m+2)%3]
          trans[sticker_from] = sticker_to
          trans2[sticker_from] = sticker_to
        end
        # f face edges
        edge_from = [f, neibors[j]]
        edge_to   = [f, neibors[k]]
        2.times do |m|
          sticker_from = edge_from[m] + edge_from[(m+1)%2]
          sticker_to   = edge_to  [m] + edge_to  [(m+1)%2]
          trans[sticker_from] = sticker_to
          trans2[sticker_from] = sticker_to
        end
        # side edges
        side_edge_from = [neibors[j], neibors[k]]
        side_edge_to   = [neibors[k], neibors[l]]
        2.times do |m|
          sticker_from = side_edge_from[m] + side_edge_from[(m+1)%2]
          sticker_to   = side_edge_to  [m] + side_edge_to  [(m+1)%2]
          trans2[sticker_from] = sticker_to
        end
        # side centers
        side_center_from = neibors[j]
        side_center_to   = neibors[k]
        trans2[side_center_from] = side_center_to
      end
      # single layer turns
      TRANS[f] = trans
      TRANS[f + "'"] = trans.invert
      TRANS[f + "2"] = trans.keys.map{|st| [st, trans[trans[st]]]}.to_h
      # double layer turns
      TRANS[f + "w"] = trans2
      TRANS[f + "w'"] = trans2.invert
      TRANS[f + "w2"] = trans2.keys.map{|st| [st, trans2[trans2[st]]]}.to_h
    end

    # Slice moves, Rotations
    # M = Lw L'
    # x = Rw L'
    %w[M Lw L'  E Dw D'  S Fw F'
       x Rw L'  y Uw D'  z Fw B'].each_slice(3) do |m, f, s|
      stickers = TRANS[f].keys + TRANS[s].keys # two sets are disjoint
      trans = stickers.map do |st|
        dest = TRANS[f][st] || st
        dest = TRANS[s][dest] || dest
        if dest != st
          [st, dest]
        else
          nil
        end
      end.compact.to_h
      TRANS[m] = trans
      TRANS[m + "'"] = trans.invert
      TRANS[m + "2"] = trans.keys.map{|st| [st, trans[trans[st]]]}.to_h
    end

    STICKERS.clear
    STICKERS.append(*(TRANS["x"].keys + TRANS["y"].keys).uniq)
  end
  self.init_trans # do it now!

  # sticker: Hash[String]: String
  # key: sticker name: eg. "BFU", "FU", "U"
  # value: color name: eg. "U", "D"
  attr_accessor :sticker

  def initialize
    @sticker = {}
    solved
  end
  def solved
    STICKERS.each do |st|
      @sticker[st] = st[0]
    end
    self
  end
  def parse(move)
    move.scan(/[UDFBRLMESxyz]w?2?'?/)
  end
  def inverse(move)
    parse(move).reverse.map do |m|
      case m
      when /(.*)'/
        $1
      when /(.*)2/
        m
      else
        "#{m}'"
      end
    end.join
  end
  def apply(move)
    result = @sticker.dup
    parse(move).each do |m|
      tmp = result.dup
      trans = TRANS[m] or throw "Unknown move #{m}"
      STICKERS.each do |st|
        to = trans[st] || st
        tmp[to] = result[st]
      end
      result = tmp
    end
    @sticker = result
    self
  end
  def reorient
    apply("x2") if sticker["D"] == "U"
    apply("x")  if sticker["F"] == "U"
    apply("x'") if sticker["B"] == "U"
    apply("z'") if sticker["R"] == "U"
    apply("z")  if sticker["L"] == "U"

    apply("y2") if sticker["B"] == "F"
    apply("y'") if sticker["L"] == "F"
    apply("y")  if sticker["R"] == "F"
  end
  def layout(template)
    template.split(/([UDFBRL][UDFBRL ][UDFBRL ]?)/).map do |st|
      case st
      when /[UDFBRL]/
        sticker[st.strip]
      else
        st.gsub(/---/, ' ')
      end
    end.join
  end
  def table
    layout(<<EOL)
--- --- ---   BLD BD  BDR
--- --- ---   BL  B   BR
--- --- ---   BUL BU  BRU

LDB LB  LBU   ULB UB  UBR   RUB RB  RBD   DRB DB  DBL
LD  L   LU    UL  U   UR    RU  R   RD    DR  D   DL
LFD LF  LUF   UFL UF  URF   RFU RF  RDF   DFR DF  DLF

--- --- ---   FLU FU  FUR
--- --- ---   FL  F   FR
--- --- ---   FDL FD  FRD
EOL
  end
  def u_face
    layout(<<EOL)
ULB UB  UBR
UL  U   UR
UFL UF  URF
EOL
  end
  def ll
    layout(<<EOL)
---  BUL BU  BRU

LBU  ULB UB  UBR  RUB
LU   UL  U   UR   RU
LUF  UFL UF  URF  RFU

---  FLU FU  FUR
EOL
  end
  def inspect
    layout("ULB UB  UBR; UL  U   UR; UFL UF  URF")
  end
  def positions(pos)
    case pos.size
    when 2
      [pos, pos.reverse]
    when 3
      [pos, pos[1,2] + pos[0], pos[2,1] + pos[0,2]]
    end
  end
  def cubie(pos)
    positions(pos).map{|p| sticker[p]}.join
  end
  def permutation(start)
    perm = []
    pos = start
    while true
      perm << pos
      pos = cubie(pos)
      break if pos == start
      if perm.size > 12
        debugger
      end
    end
    perm
  end
  def pll_permutations
    cp = []
    %w[ULB UBR URF UFL].each do |pos|
      next if cp.any?{|p| p.include?(pos)}
      p = permutation(pos)
      next if p.size == 1
      cp << p
    end
    ep = []
    %w[UL UB UR UF].each do |pos|
      next if ep.any?{|p| p.include?(pos)}
      p = permutation(pos)
      next if p.size == 1
      ep << p
    end
    if (cp + ep).any?{|p| p.any?{|c| c[0] != "U"}}
      raise 'Not a PLL'
    end
    [cp, ep]
  end
  def oll_png
    edges = %w[BUL BU BRU LBU LU LUF RUB RU RFU FLU FU FUR]
    faces = %w[ULB UB UBR UL U UR UFL UF URF]
    png = CubePng.new
    png.draw_frame
    edges.each.with_index do |en, i|
      if sticker[en] == "U"
        png.fill_edge(i, U_COLOR, true)
      end
    end
    faces.each.with_index do |fc, i|
      png.fill_face(i, FACE_COLORS[sticker[fc]])
    end
    png
  end
  def pll_png
    faces = %w[ULB UB UBR UL U UR UFL UF URF]
    edges = %w[BUL BU BRU LBU LU LUF RUB RU RFU FLU FU FUR]
    png = CubePng.new
    png.draw_frame

    cp, ep = pll_permutations

    faces.each.with_index do |fn, i|
      case fn.size
      when 1
        # nop
      when 2
        next if ep.any?{|p| p.include? fn}
      when 3
        next if cp.any?{|p| p.include? fn}
      end
      png.fill_face(i, U_COLOR)
    end

    # show edge color if not solved
    edges.each.with_index do |en, i|
      if sticker[en] != en[0]
        png.fill_edge(i, FACE_COLORS[sticker[en]])
      end
    end

    # draw permutation lines
    co = nil
    eo = nil
    if !cp.empty? && !ep.empty?
      co = :outer
      eo = :inner
    end

    cp.each do |p|
      p.each.with_index do |f, i|
        st = faces.index(f)
        en = faces.index(p[(i + 1) % p.size])
        png.draw_perm_line(st, en, co)
      end
    end

    ep.each do |p|
      p.each.with_index do |f, i|
        st = faces.index(f)
        en = faces.index(p[(i + 1) % p.size])
        png.draw_perm_line(st, en, eo)
      end
    end

    png
  end
end
