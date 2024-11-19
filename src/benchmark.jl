#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Benchmark                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("config.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

objective_function = if OBJ_F == "sphere"
    x::Vector{Float64} -> sum((x .- 0) .^ 2)
elseif OBJ_F == "rosenbrock"
    x::Vector{Float64} -> sum(100 .* (x[2:end] .- x[1:end-1].^2).^2 + (1 .- x[1:end-1]).^2)
elseif OBJ_F == "rastrigin"
    x::Vector{Float64} -> sum(x .^ 2 - 10 * cos.(2 * pi * x) .+ 10)
elseif OBJ_F == "griewank"
    x::Vector{Float64} -> sum(x .^ 2 / 4000) - prod(cos.(x ./ sqrt.(1:length(x)))) + 1
elseif OBJ_F == "ackley"
    x::Vector{Float64} -> -20 * exp(-0.2 * sqrt(sum(x .^ 2) / length(x))) - exp(sum(cos.(2 * pi * x)) / length(x)) + 20 + exp(1)
elseif OBJ_F == "schwefel"
    x::Vector{Float64} -> 418.9829 * length(x) - sum(x .* sin.(sqrt.(abs.(x))))
elseif OBJ_F == "michalewicz"
    x::Vector{Float64} -> -sum(sin.(x) .* sin.((1:length(x)) .* x .^ 2 / pi) .^ 20)
else
    logger("ERROR", "Objective function is invalid")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Number of solution and bounds
SOLUTION, UPP, LOW = if OBJ_F == "sphere"
    [zeros(D), 100.0, -100.0]
elseif OBJ_F == "rosenbrock"
    [ones(D), 30.0, -30.0]
elseif OBJ_F == "rastrigin"
    [zeros(D), 5.12, -5.12]
elseif OBJ_F == "griewank"
    [zeros(D), 600.0, -600.0]
elseif OBJ_F == "ackley"
    [zeros(D), 32.0, -32.0]
elseif OBJ_F == "schwefel"
    [zeros(D), 500.0, -500.0]
elseif OBJ_F == "michalewicz"
    [zeros(D), pi, 0.0]
else
    logger("ERROR", "Objective parameter is invalid")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#