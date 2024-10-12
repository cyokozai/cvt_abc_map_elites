#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Import library                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("config.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#  

objective_function = if OBJ_F == "sphere"
    x::Vector{Float64} -> sum(x .^ 2)
elseif OBJ_F == "rosenbrock"
    x::Vector{Float64} -> sum(100 .* (x[2:end] .- x[1:end-1].^2).^2 + (1 .- x[1:end-1]).^2)
elseif OBJ_F == "rastrigin"
    x::Vector{Float64} -> sum(x .^ 2 - 10 * cos.(2 * pi * x) .+ 10)
elseif OBJ_F == "griewank"
    x::Vector{Float64} -> sum(x .^ 2 / 4000) - prod(cos.(x ./ sqrt.(1:length(x)))) + 1
else
    logger("ERROR", "Objective function is invalid")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#  

if OBJ_F == "sphere"
    SOLUTION = zeros(D)  # Number of solution
    UPP =  100.0         # Upper bound
    LOW = -100.0         # Lower bound
elseif OBJ_F == "rosenbrock"
    SOLUTION = ones(D)   # Number of solution
    UPP =  30.0          # Upper bound
    LOW = -30.0          # Lower bound
elseif OBJ_F == "rastrigin"
    SOLUTION = zeros(D)  # Number of solution
    UPP =  5.12          # Upper bound
    LOW = -5.12          # Lower bound
elseif OBJ_F == "griewank"
    SOLUTION = zeros(D)  # Number of solution
    UPP =  600.0         # Upper bound
    LOW = -600.0         # Lower bound
else
    logger("ERROR", "Objective parameter is invalid")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#