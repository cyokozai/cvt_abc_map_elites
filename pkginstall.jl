using Pkg

ENV["PYTHON"] = ""

#-----Dev Env--------------------#

Pkg.add("Atom")
Pkg.add("Juno")
Pkg.add("IJulia")
Pkg.add("CxxWrap")

#-----Plotting-------------------#

Pkg.add("LaTeXStrings")
Pkg.add("PyCall")
Pkg.add("PyPlot")
Pkg.add("UnicodePlots")
Pkg.add("Plots")
Pkg.add("StatsPlots")

#-----Math & Stat----------------#

Pkg.add("StatsKit")
Pkg.add("StatsBase")
Pkg.add("StatsModels")
Pkg.add("DataFrames")
Pkg.add("Distributions")
Pkg.add("MultivariateStats")
Pkg.add("HypothesisTests")
Pkg.add("MLBase")
Pkg.add("Distances")
Pkg.add("KernelDensity")
Pkg.add("Clustering")
Pkg.add("GLM")
Pkg.add("NMF")
Pkg.add("Lasso")
Pkg.add("TimeSeries")
Pkg.add("Bootstrap")
Pkg.add("Loess")
Pkg.add("MultipleTesting")
Pkg.add("CategoricalArrays")
Pkg.add("CSV")

Pkg.add("RCall")
Pkg.add("RDatasets")

#Pkg.add("JuliaDB")

Pkg.add("Calculus")
Pkg.add("DifferentialEquations")

Pkg.add("Primes")
Pkg.add("SymPy")

# Pkg.add("MixedModels")
# Pkg.add("ANOVA")
# Pkg.add("BayesNets")
# Pkg.add("CmdStan")
# Pkg.add("MCMCChain")

# Pkg.add("Turing")
# Pkg.add("Flux")
# Pkg.add("https://github.com/probcomp/Gen")
# Pkg.add("MLJ")
# Pkg.add("MLJModels")

#-----Precompilation ------------#

Pkg.precompile()