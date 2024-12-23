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
    I_p, I_a = population.individuals, archive.individuals
    r1, r2, r3 = zeros(Int, 3)
    
    print("DE")

    for i in 1:N
        while r1 == r2 || r1 == r3 || r2 == r3 || I_a[r1].genes == I_p[i].genes || I_a[r2].genes == I_p[i].genes || I_a[r3].genes == I_p[i].genes
            r1, r2, r3 = rand(RNG, keys(I_a), 3)
        end
        
        v = clamp.(I_a[r1].genes .+ F .* (I_a[r2].genes .- I_a[r3].genes), LOW, UPP)
        u = crossover(I_p[i].genes, v)
        y = objective_function(u)
        
        if fitness((noise(y), y)[fit_index]) > fitness(I_a[r1].benchmark[fit_index])
            archive.individuals[r1] = Individual(deepcopy(u), (noise(y), y), devide_gene(u))
        end

        if fitness((noise(y), y)[fit_index]) > fitness(I_a[r2].benchmark[fit_index])
            archive.individuals[r2] = Individual(deepcopy(u), (noise(y), y), devide_gene(u))
        end
        
        if fitness((noise(y), y)[fit_index]) > fitness(I_a[r3].benchmark[fit_index])
            archive.individuals[r3] = Individual(deepcopy(u), (noise(y), y), devide_gene(u))
        end

        if fitness((noise(y), y)[fit_index]) > fitness(I_p[i].benchmark[fit_index])
            population.individuals[i] = Individual(deepcopy(u), (noise(y), y), devide_gene(u))
        end

        if i % 10 == 0
            print(".")
        end
    end

    println("done")
    
    return population, archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#