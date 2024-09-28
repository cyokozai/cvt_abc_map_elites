#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#  

objective_function = if OBJ_F == "sphere"
    x::Vector{Float64} -> sum(x .^ 2)
elseif OBJ_F == "rosenbrock"
    x::Vector{Float64} -> sum(100 * (x[2:end] - x[1:end-1].^2).^2 + (1 - x[1:end-1]).^2)
else
    logger("ERROR", "Objective function is invalid")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#  

if OBJ_F == "sphere"
    SOLUTION = zeros(D)  # Number of solution
    UPP =  5.0           # Upper bound
    LOW = -5.0           # Lower bound
elseif OBJ_F == "rosenbrock"
    SOLUTION = zeros(D)  # Number of solution
    UPP =  5.0           # Upper bound
    LOW = -5.0           # Lower bound
else
    logger("ERROR", "Objective parameter is invalid")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#