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
    j_rand = rand(RNG, 1:D)
    
    return [rand(RNG) < CR || j == j_rand ? v[j] : x[j] for j in 1:D]
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Differential Evolution algorithm
function DE(population::Population, archive::Archive)
    I = archive.individuals
    r1, r2, r3 = 1, 1, 1
    v, tv = zeros(Float64, D, 2)
    
    for i in I.keys
        while r1 == i || r2 == i || r3 == i || r1 == r2 || r1 == r3 || r2 == r3 || !haskey(I, r1) || !haskey(I, r2) || !haskey(I, r3)
            r1, r2, r3 = rand(RNG, 1:k_max, 3)
        end
        
        v  = clamp.(I[r1].genes .+ F .* (I[r2].genes .- I[r3].genes), LOW, UPP)
        tv = crossover(I[i].genes, v)
        
        y    = objective_function(tv)
        tv_b = (y + (rand(RNG) * 2 * NOIZE_R - NOIZE_R), y)
        
        if fitness(tv_b[fit_index]) > fitness(I[i].benchmark[fit_index])
            archive.individuals[i] = Individual(deepcopy(tv), deepcopy(tv_b), devide_gene(tv))
        end
    end
    
    return population, archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#