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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

trial = zeros(Int, N)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function greedySelection(f::Vector{Float64}, v::Vector{Float64}, i::Int)
    global trial

    if fitness(f) < fitness(v)
        return v
    else
        trial[i] += 1

        return f
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function roulleteSelection(q::Float64)
    index = 1

    for i in 1:N
        if rand() <= q
            index = i
            break
        end
    end

    return index
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function employed_bee(population::Population, archive::Archive)
    ind = population.individuals
    k = 0
    v = zeros(Float64, N, D)

    for i in 1:N
        for j in 1:D
            while true
                k = rand(1:N)

                if k != i break end
            end

            v[i, j] = ind[i].genes[j] + (rand() * 2 - 1.0) * (ind[i].genes[j] - ind[k].genes[j])
        end

        ind[i].genes = greedySelection(ind[i].genes, v[i, :], i)
    end

    return population, archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

onlooker_bee = if CVT_METHOD == "grid" 
    (population::Population, archive::Archive) -> begin
        global trial

        cum_p = 0.0
        ind = population.individuals
        p = [ind[i].fitness / sum(ind[i].fitness for i = 1 : N) for i = 1 : N]
        k = 0

        new_archive = zeros(Float64, N, D)
        v = zeros(Float64, N, D)

        for i in 1:N
            cum_p += p[i]
            new_archive[i, :] = ind[roulleteSelection(cum_p)].genes

            for j = 1 : D
                while true
                    k = rand(1 : N)

                    if k != i break end
                end

                v[i, j] = new_archive[i, j] + (rand() * 2 - 1.0) * (new_archive[i, j] - new_archive[k, j])
            end
            
            ind[i].genes = greedySelection(ind[i].genes, v[i, :], i)
        end

        return population, archive
    end
elseif CVT_METHOD == "cvt"
    (population::Population, archive::Archive) -> begin
        global trial

        cum_p = 0.0
        ind = population.individuals
        p = [ind[i].fitness / sum(ind[i].fitness for i = 1 : N) for i = 1 : N]
        k = 0

        new_archive = zeros(Float64, N, D)
        v = zeros(Float64, N, D)

        for i in 1:N
            cum_p += p[i]
            new_archive[i, :] = ind[roulleteSelection(cum_p)].genes

            for j = 1 : D
                while true
                    k = rand(1 : N)

                    if k != i break end
                end

                v[i, j] = new_archive[i, j] + (rand() * 2 - 1.0) * (new_archive[i, j] - new_archive[k, j])
            end
            
            ind[i].genes = greedySelection(ind[i].genes, v[i, :], i)
        end

        return population, archive
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function scout_bee(population::Population, archive::Archive)
    global trial
    
    ind = population.individuals

    for i in 1:N
        if trial[i] >= ABC_LIMIT
            ind[i].genes = rand(Float64, D) .* (UPP - LOW) .+ LOW
            trial[i] = 0

            logger("INFO", "Scout bee found a new food source")

            if METHOD == "cvt"
                new_archive = Archive(nothing, Dict{Int64, Int64}(i => 0 for i in keys(init_CVT())))
                archive = cvt_mapping(population, new_archive)

                logger("INFO", "CVT is initialized")
            end
        end
    end

    return population, archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function ABC(population::Population, archive::Archive)
    # Employee bee phase
    population, archive = employed_bee(population, archive)

    # Onlooker bee phase
    population, archive = onlooker_bee(population, archive)

    # Scout bee phase
    population, archive = scout_bee(population, archive)

    return population
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#