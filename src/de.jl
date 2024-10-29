#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       DE: Differential Evolution                                                                   #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Statistics
using Random

#----------------------------------------------------------------------------------------------------#

include("config.jl")
include("struct.jl")
include("benchmark.jl")
include("fitness.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Binomial crossover
function crossover(x::Vector{Float64}, v::Vector{Float64})
    return [rand(RNG) <= CR || j == rand(RNG, 1:D) ? v[j] : x[j] for j in 1:D]
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function DE(population::Population)
    I = population.individuals
    r1, r2, r3 = 1, 1, 1
    v, trial = zeros(Float64, D, 2)

    for i in 1:N
        while r1 == i || r2 == i || r3 == i
            r1, r2, r3 = rand(RNG, 1:N, 3)
        end

        v = I[r1].genes .+ F .* (I[r2].genes .- I[r3].genes)
        v = clamp.(v, LOW, UPP)

        trial = crossover(I[i].genes, v)
        
        if fitness(trial) > I[i].fitness
            I[i].genes = deepcopy(trial)
            I[i].fitness = fitness(trial)
            I[i].behavior = devide_gene(trial)
        end
    end

    population.individuals = I
    
    return population
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#