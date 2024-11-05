using Pkg

#-----Plotting-------------------#

Pkg.add("LaTeXStrings")
Pkg.add("PyCall")
Pkg.add("PyPlot")
Pkg.add("UnicodePlots")
Pkg.add("Plots")
Pkg.add("StatsPlots")

#-----Data-----------------------#

# Pkg.add("ProtoBuf")

#-----Math & Stat----------------#

Pkg.add("DelaunayTriangulation")
Pkg.add("CairoMakie")
Pkg.add("StableRNGs")

#-----Precompilation ------------#

Pkg.precompile()