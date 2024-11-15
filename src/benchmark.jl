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

if OBJ_F == "sphere"
    SOLUTION = zeros(D) # Number of solution
    UPP =  100.0        # Upper bound
    LOW = -100.0        # Lower bound

    if METHOD == "DE"
        CR  = 0.01          # Crossover rate
        F   = 0.50          # Scaling factor
    end
elseif OBJ_F == "rosenbrock"
    SOLUTION = ones(D) # Number of solution
    UPP =  30.0        # Upper bound
    LOW = -30.0        # Lower bound

    if METHOD == "DE"
        CR  = 0.75          # Crossover rate
        F   = 0.70          # Scaling factor
    end
elseif OBJ_F == "rastrigin"
    SOLUTION = zeros(D) # Number of solution
    UPP =  5.12         # Upper bound
    LOW = -5.12         # Lower bound

    if METHOD == "DE"
        CR  = 0.001         # Crossover rate
        F   = 0.50          # Scaling factor
    end
elseif OBJ_F == "griewank"
    SOLUTION = zeros(D) # Number of solution
    UPP =  600.0        # Upper bound
    LOW = -600.0        # Lower bound
    
    if METHOD == "DE"
        CR  = 0.20          # Crossover rate
        F   = 0.50          # Scaling factor
    end
elseif OBJ_F == "ackley"
    SOLUTION = zeros(D) # Number of solution
    UPP =  32.0         # Upper bound
    LOW = -32.0         # Lower bound

    if METHOD == "DE"
        CR  = 0.20          # Crossover rate
        F   = 0.50          # Scaling factor
    end
elseif OBJ_F == "schwefel"
    SOLUTION = zeros(D) # Number of solution
    UPP =  500.0        # Upper bound
    LOW = -500.0        # Lower bound

    if METHOD == "DE"
        CR  = 0.20          # Crossover rate
        F   = 0.50          # Scaling factor
    end
elseif OBJ_F == "michalewicz"
    SOLUTION = zeros(D) # Number of solution
    UPP = 3.0           # Upper bound
    LOW = 0.0           # Lower bound

    if METHOD == "DE"
        CR  = 0.20          # Crossover rate
        F   = 0.50          # Scaling factor
    end
else
    logger("ERROR", "Objective parameter is invalid")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#