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

    unless cube.check_f2l
      puts "Not an LL algorithm: #{name}"
      return
    end
    pll = /^[U; ]+$/ =~ cube.inspect
    png = pll ? cube.pll_png : cube.oll_png
    filename = "imgs/#{name}.png"
    png.save_png(filename)
    width = png.image.columns
    height = png.image.rows

    len = cube.parse(algorithm).find_all do |m|
      m !~ /[xyz]/ &&
        !(Config::LOWERCASE_MOVE == :rotate && m =~ /[udfbrl]/)
    end.size

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
<title>Final layer algorithms</title>

<style>
p.extra {
 font-family: arial, helvetica;
 font-style: normal;
 font-size: 8pt;
 color: green;
 text-align: right;
 clear: none;
}

p.algorithm {
 font-family: arial, helvetica;
 font-style: normal;
 font-size: 8pt;
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
  <tbody>
EOL
  end
  def trailer
    <<EOL
  </tbody>
</table>
</body>
</html>
EOL
  end
end
