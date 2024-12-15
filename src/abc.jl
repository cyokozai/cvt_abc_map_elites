#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       ABC: Artificial Bee Colony                                                                   #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Statistics

using Random

#----------------------------------------------------------------------------------------------------#

include("config.jl")

include("struct.jl")

include("fitness.jl")

include("logger.jl")

#----------------------------------------------------------------------------------------------------#
# ABC Trial
trial = zeros(Int, FOOD_SOURCE)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Greedy selection
function greedySelection(f::Vector{Float64}, v::Vector{Float64}, i::Int)
    global trial

    v_f, f_f = objective_function(v), objective_function(f)
    v_b, f_b = (v_f + (rand(RNG) * 2 * NOIZE_R - NOIZE_R), v_f), (f_f + (rand(RNG) * 2 * NOIZE_R - NOIZE_R), f_f)

    if fitness(v_b[fit_index]) > fitness(f_b[fit_index])
        trial[i] = 0
        
        return v
    else
        trial[i] += 1
        
        return f
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Roulette selection
function roulleteSelection(q::Float64)
    index = 1

    for i in 1:FOOD_SOURCE
        if rand(RNG) <= q
            index = i

            break
        end
    end

    return index
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Employed bee phase
function employed_bee(population::Population)
    I = population.individuals
    k, v = 0, zeros(Float64, FOOD_SOURCE, D)

    for i in 1:FOOD_SOURCE
        for j in 1:D
            while true
                k = rand(RNG, 1:FOOD_SOURCE)

                if k != i break end
            end
            
            v[i, j] = I[i].genes[j] + (rand(RNG) * 2.0 - 1.0) * (I[i].genes[j] - I[k].genes[j])
        end

        population.individuals[i].genes = deepcopy(greedySelection(I[i].genes, v[i, :], i))
    end
    
    return population
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Onlooker bee phase
function onlooker_bee(population::Population)
    global trial

    I = population.individuals
    new_gene_archive = zeros(Float64, FOOD_SOURCE, D)
    k, v = 0, zeros(Float64, FOOD_SOURCE, D)
    p, cum_p = [fitness(I[i].benchmark[fit_index]) / sum(fitness(I[i].benchmark[fit_index]) for i = 1 : FOOD_SOURCE) for i = 1 : FOOD_SOURCE], 0.0
    
    for i in 1:FOOD_SOURCE
        cum_p += p[i]
        new_gene_archive[i, :] = deepcopy(I[roulleteSelection(cum_p)].genes)
        
        for j = 1 : D
            while true
                k = rand(RNG, 1:FOOD_SOURCE)
                
                if k != i break end
            end
            
            v[i, j] = new_gene_archive[i, j] + (rand(RNG) * 2.0 - 1.0) * (new_gene_archive[i, j] - new_gene_archive[k, j])
        end
        
        population.individuals[i].genes = deepcopy(greedySelection(I[i].genes, v[i, :], i))
    end
    
    return population
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Scout bee phase
function scout_bee(population::Population, archive::Archive)
    global trial
    
    if maximum(trial) > TC_LIMIT
        for (i, I) in enumerate(population.individuals)
            if trial[i] > TC_LIMIT
                gene = rand(Float64, D) .* (UPP - LOW) .+ LOW
                population.individuals[i] = Individual(deepcopy(gene), fitness(gene), devide_gene(gene))
                trial[i] = 0
                
                if MAP_METHOD == "cvt"
                    if cvt_vorn_data_update < cvt_vorn_data_update_limit
                        init_CVT(population)
                        
                        new_archive = Archive(zeros(Int64, 0, 0), zeros(Int64, k_max), Dict{Int64, Individual}())
                        archive = deepcopy(cvt_mapping(population, new_archive))
                        
                        logger("INFO", "Recreate Voronoi diagram")
                    end
                end
                
                logger("INFO", "Scout bee found a new food source")
            end
        end
    end
    
    return population, archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# ABC algorithm
function ABC(population::Population, archive::Archive)
    # Employee bee phase
    population = employed_bee(population)
    
    # Onlooker bee phase
    population = onlooker_bee(population)

    # Scout bee phase
    population, archive = scout_bee(population, archive)
    
    return population
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#