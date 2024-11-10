using Pkg

Pkg.add("StableRNGs")

if ARGS[1] == "figure"
    Pkg.add("LaTeXStrings")
    Pkg.add("PyCall")
    Pkg.add("PyPlot")
    Pkg.add("UnicodePlots")
    Pkg.add("Plots")
    Pkg.add("StatsPlots")
elseif ARGS[1] == "run"
    Pkg.add("DelaunayTriangulation")
    Pkg.add("CairoMakie")
end

Pkg.precompile()