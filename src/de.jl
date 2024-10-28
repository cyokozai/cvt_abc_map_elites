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
    return [rand() <= CR || j == rand(1:D) ? v[j] : x[j] for j in 1:D]
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function DE(population::Population, archive::Archive)
    ind = population.individuals
    r1, r2, r3 = 1, 1, 1
    v, trial = zeros(Float64, D, 2)

    for i in 1:N
        while r1 == i || r2 == i || r3 == i
            r1, r2, r3 = rand(1:N, 3)
        end

        v = ind[r1].genes .+ F .* (ind[r2].genes .- ind[r3].genes)
        v = clamp.(v, LOW, UPP)

        trial = crossover(ind[i].genes, v)
        
        if fitness(trial) > ind[i].fitness
            ind[i].genes = deepcopy(trial)
            ind[i].fitness = fitness(trial)
            ind[i].behavior = devide_gene(trial)
        end
    end

    population.individuals = ind
    
    return population
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#