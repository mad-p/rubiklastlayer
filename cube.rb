# Represent cube state
# Has methods about moves

class Cube
  # Face colors
  U = 0; D = 1; F = 2; B = 3; R = 4; L = 5
  U_COLOR = '#ffff00',   # U: yellow
  D_COLOR = '#dddddd',   # D: white
  F_COLOR = '#ff8000',   # F: orange
  B_COLOR = '#ff0000',   # B: red
  R_COLOR = '#000099',   # R: blue
  L_COLOR = '#009900',   # L: green

  FACE_NAMES = %w[U D F B R L]
  FACE_COLORS = [
    U_COLOR, D_COLOR, F_COLOR,
    B_COLOR, R_COLOR, L_COLOR,
  ]

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

  # setup TRANS
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
      puts "#{m} = #{f} #{s}"
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

  # sticker: Hash[String]: int
  # key: sticker name: eg. "BFU", "FU", "U"
  # value: color index: 0-5
  attr_accessor :sticker

end
