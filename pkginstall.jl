using Pkg

Pkg.add("JLD2")
Pkg.add("FileIO")

Pkg.add("StableRNGs")
Pkg.add("DelaunayTriangulation")
Pkg.add("CairoMakie")

if ARGS[1] == "figure"
    Pkg.add("LaTeXStrings")
    Pkg.add("PyCall")
    Pkg.add("PyPlot")
    Pkg.add("UnicodePlots")
    Pkg.add("Plots")
    Pkg.add("StatsPlots")
end

Pkg.precompile()