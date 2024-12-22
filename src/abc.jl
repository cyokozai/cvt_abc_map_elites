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
    v_b, f_b = (noise(v_f), v_f), (noise(f_f), f_f)

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
function roulleteSelection(cum_probs::Vector{Float64}, I::Dict{Int64, Individual})
    keys_array = collect(keys(I))
    r = rand()
    
    for (i, cum_p) in enumerate(cum_probs)
        if r <= cum_p
            return keys_array[i]
        end
    end

    return keys_array[end]
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Employed bee phase
function employed_bee(population::Population, archive::Archive)
    I_p, I_a = population.individuals, archive.individuals
    v = zeros(Float64, FOOD_SOURCE, D)
    
    for i in 1:FOOD_SOURCE
        for j in 1:D
            while true
                k = rand(RNG, keys(I_a))
                
                if I_p[i].genes[j] != I_a[k].genes[j] break end
            end
            
            v[i, j] = I_p[i].genes[j] + (rand(RNG) * 2.0 - 1.0) * (I_p[i].genes[j] - I_a[k].genes[j])
        end
        
        population.individuals[i].genes = deepcopy(greedySelection(I_p[i].genes, v[i, :], i))
    end
    
    return population, archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Onlooker bee phase
function onlooker_bee(population::Population, archive::Archive)
    I_p, I_a = population.individuals, archive.individuals
    v, u  = zeros(Float64, FOOD_SOURCE, D, 2)

    Σ_fit = sum(fitness(I_a[i].benchmark[fit_index]) for i in keys(I_a))
    cum_p = cumsum([fitness(I_a[i].benchmark[fit_index]) / Σ_fit for i in keys(I_a)])
    
    for i in 1:FOOD_SOURCE
        u[i, :] = deepcopy(I_a[roulleteSelection(cum_p, I_a)].genes)
        
        for j in 1:D
            while true
                k, l = rand(RNG, 1:FOOD_SOURCE), rand(RNG, keys(I_a))
                
                if i != k && I_p[i].genes[j] != I_a[l].genes[j] break end
            end
            
            v[i, j] = u[i, j] + (rand(RNG) * 2.0 - 1.0) * (u[i, j] - u[k, j])
        end
        
        population.individuals[i].genes = deepcopy(greedySelection(I_p[i].genes, v[i, :], i))
    end
    
    return population, archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Scout bee phase
function scout_bee(population::Population, archive::Archive)
    global trial
    
    if maximum(trial) > TC_LIMIT
        for i in 1:FOOD_SOURCE
            if trial[i] > TC_LIMIT
                gene = rand(Float64, D) .* (UPP - LOW) .+ LOW
                y    = objective_function(gene)
                population.individuals[i] = Individual(deepcopy(gene), (noise(y), y), devide_gene(gene))
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
    print("Employed bee phase")
    # Employee bee phase
    population, archive = employed_bee(population, archive)
    println("... Done")
    print("Onlooker bee phase")
    # Onlooker bee phase
    population, archive = onlooker_bee(population, archive)
    println("... Done")
    print("Scout bee phase")
    # Scout bee phase
    population, archive = scout_bee(population, archive)
    println("... Done")
    
    return population, archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#