require './cube'
require './cube_png'

class AlgorithmTable
  N_COLUMN = 5
  attr_accessor :rows, :cols
  def initialize
    @rows = []
    @cols = []
  end
  def add(name, occurs, algorithm)
    return if algorithm == ""

    cube = Cube.new
    # find cube rotation of algorithm
    cube.apply(cube.inverse(algorithm))
    reorienter = cube.reorient
    # undo rotation beforehand
    cube.solved
    cube.apply(reorienter)
    cube.apply(cube.inverse(algorithm))
    cube.reorient

    cube.check_f2l or raise "Not an LL algorithm: #{name}"
    pll = /^[U; ]+$/ =~ cube.inspect
    png = pll ? cube.pll_png : cube.oll_png
    filename = "imgs/#{name}.png"
    png.save_png(filename)
    width = png.image.columns
    height = png.image.rows

    len = cube.parse(algorithm).size

    @cols << <<EOL
        <td width="18%">
         <img width="#{width}" height="#{height}" align="left" src="#{filename}">
         <p class="extra">code: #{name}<br>occurs: #{occurs}</p>
         <p class="algorithm">#{algorithm} (#{len})</p>
        </td>
EOL
    if @cols.size == N_COLUMN
      @rows << @cols
      @cols = []
    end
  end
  def generate_html(filename)
    @rows << @cols
    File.open(filename, "w") do |f|
      f.puts header
      @rows.each do |row|
        f.puts "    <tr>"
        f.puts row
        f.puts "    </tr>"
      end
      f.puts trailer
    end
  end
  def header
    <<EOL
<head>
<title>Rubik's Cube: Final layer algorithms (printable page)</title>

<style>
p.extra {
 font-family: arial, helvetica;
 font-style: normal;
 font-size: 6pt;
 color: green;
 text-align: right;
 clear: none;
}

p.algorithm {
 font-family: arial, helvetica;
 font-style: normal;
 font-size: 6pt;
 color: blue;
 text-align: left;
 clear: left;
}

td {
 vertical-align: top;
}
</style>

</head>

<body bgcolor="#ffffff">

<table frame="border" rules="all" cellpadding="2" cellspacing="0">
EOL
  end
  def trailer
    <<EOL
 </table>
</body>

</html>
EOL
  end
end
