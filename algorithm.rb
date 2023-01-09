require './algorithm_table'

t = AlgorithmTable.new

t.add("o28", "4/216", "LF'LF2R'FRF2L2")
t.add("o44", "4/216", "FURU'R'F'")
t.add("o43", "4/216", "F'U'L'ULF")
t.add("o32", "4/216", "LUF'U'L'ULFL'")
t.add("o31", "4/216", "R'U'FURU'R'F'R")

t.add("p1",  "16/288", "R2F2R'B'RF2R'BR'")
t.add("p2",  "16/288", "RB'RF2R'BRF2R2")
t.add("p3",  "8/288",  "R'URU'R2'F'U'FURU'R2B'R'B")
t.add("p4",  "8/288",  "U2M2UM2UM'U2M2U2M'")

t.generate_html("index.html")
