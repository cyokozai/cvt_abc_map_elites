#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       ME: Map Elites                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using StableRNGs

using Random

#----------------------------------------------------------------------------------------------------#

include("struct.jl")

include("config.jl")

include("benchmark.jl")

include("fitness.jl")

include("cvt.jl")

include("abc.jl")

include("de.jl")

include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Devide gene
function devide_gene(gene::Vector{Float64})
    g_len = length(gene)
    segment_length = div(g_len, BD)
    behavior = Float64[]
    
    for i in 1:BD
        start_idx = (i - 1) * segment_length + 1
        end_idx = i == BD ? g_len : i * segment_length
        
        push!(behavior, BD*sum(gene[start_idx:end_idx])/Float64(g_len))
    end
    
    return behavior
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Initialize the best solution
function init_solution()
    gene = rand(RNG, D) .* (UPP - LOW) .+ LOW

    y, ε = objective_function(gene), rand(RNG) * 2 * NOIZE_R - NOIZE_R

    return Individual(deepcopy(gene), (y + ε, y), devide_gene(gene))
end

#----------------------------------------------------------------------------------------------------#
# Best solution
best_solution = init_solution()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Evaluator: Evaluation of the individual
function evaluator(individual::Individual)
    # Objective function
    y, ε = objective_function(individual.genes), rand(RNG) * 2 * NOIZE_R - NOIZE_R
    individual.benchmark = (y + ε, y)
    
    # Evaluate the behavior
    individual.behavior = deepcopy(devide_gene(individual.genes))

    # Update the best solution
    if fitness(individual.benchmark[fit_index]) >= fitness(best_solution.benchmark[fit_index])
        global best_solution = Individual(deepcopy(individual.genes), individual.benchmark, deepcopy(individual.behavior))
    end
    
    return individual
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Mapping: Mapping the individual to the archive
Mapping = if MAP_METHOD == "grid"
    (population::Population, archive::Archive) -> begin
        # The length of the grid
        len = (UPP - LOW) / GRID_SIZE
        
        # Mapping the individual to the archive
        for (index, ind) in enumerate(population.individuals)
            idx = clamp.(ind.behavior, LOW, UPP)
            
            for i in 1:GRID_SIZE
                for j in 1:GRID_SIZE
                    if LOW + len * (i - 1) <= idx[1] && idx[1] < LOW + len * i && LOW + len * (j - 1) <= idx[2] && idx[2] < LOW + len * j # Save the individual to the grid
                        # Check the grid
                        if archive.grid[i, j] > 0
                            if fitness(ind.benchmark[fit_index]) > fitness(archive.individuals[archive.grid[i, j]].benchmark[fit_index])
                                archive.grid[i, j] = index
                                archive.individuals[index] = Individual(deepcopy(ind.genes), ind.benchmark, deepcopy(ind.behavior))
                                archive.grid_update_counts[index] += 1
                            end
                        else
                            archive.grid[i, j] = index
                            archive.individuals[index] = Individual(deepcopy(ind.genes), ind.benchmark, deepcopy(ind.behavior))
                            archive.grid_update_counts[index] += 1
                        end
                        
                        break
                    end
                end
            end
        end

        return archive
    end
elseif MAP_METHOD == "cvt"
    (population::Population, archive::Archive) -> cvt_mapping(population, archive)
else
    error("Invalid MAP method")

    logger("ERROR", "Invalid MAP method")
    
    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Mutate: Mutation of the individual
mutate(individual::Individual) = rand() < MUTANT_R ? individual : init_solution()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Select random elite
select_random_elite = if MAP_METHOD == "grid"
    (population::Population, archive::Archive) -> begin
        while true
            i, j = rand(RNG, 1:GRID_SIZE, 2)
            
            if archive.grid[i, j] > 0
                return archive.individuals[archive.grid[i, j]]
            end
        end
    end
elseif MAP_METHOD == "cvt"
    (population::Population, archive::Archive) -> begin
        while true
            random_centroid_index = rand(RNG, 1:k_max)
            
            if haskey(archive.individuals, random_centroid_index)
                return archive.individuals[random_centroid_index]
            end
        end
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Reproduction: Generate new individuals
Reproduction = if METHOD == "default"
    (population::Population, archive::Archive) -> Population([evaluator(mutate(select_random_elite(population, archive))) for _ in 1:N])
elseif METHOD == "abc"
    (population::Population, archive::Archive) -> ABC(population, archive)
elseif METHOD == "de"
    (population::Population, archive::Archive) -> DE(population)
else
    error("Invalid method")

    logger("ERROR", "Invalid method")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Map Elites algorithm
function map_elites()
    global best_solution, vorn

    # Print the solutions
    indPrint = if FIT_NOISE
        (ffn, ff, fb) -> begin
            println("Now best: ", best_solution.genes)
            println("Now noised best fitness: ", fitness(best_solution.benchmark[1]))
            println("Now corrected best fitness: ", fitness(best_solution.benchmark[2]))
            println("Now best behavior: ", best_solution.behavior)
            
            println(ffn, fitness(best_solution.benchmark[1]))
            println(ff, fitness(best_solution.benchmark[2]))
            println(fb, best_solution.behavior)
        end
    else
        (ff, fb) -> begin
            println("Now best: ", best_solution.genes)
            println("Now best fitness: ", fitness(best_solution.benchmark[2]))
            println("Now best behavior: ", best_solution.behavior)
            
            println(ff, fitness(best_solution.benchmark[2]))
            println(fb, best_solution.behavior)
        end
    end
    
    # Initialize
    logger("INFO", "Initialize")
    
    population::Population = Population([evaluator(init_solution()) for _ in 1:N])
    archive::Archive = if MAP_METHOD == "grid"
        Archive(zeros(Int64, GRID_SIZE, GRID_SIZE), zeros(Int64, GRID_SIZE, GRID_SIZE), Dict{Int64, Individual}())
    elseif MAP_METHOD == "cvt"
        init_CVT(population)
        Archive(zeros(Int64, 0, 0), zeros(Int64, k_max), Dict{Int64, Individual}())
    end
    
    # Open file
    if FIT_NOISE
        ffn = open("result/$METHOD/$OBJ_F/$F_FIT_N", "a")
        ff  = open("result/$METHOD/$OBJ_F/$F_FITNESS", "a")
        fb  = open("result/$METHOD/$OBJ_F/$F_BEHAVIOR", "a")
    else
        ff = open("result/$METHOD/$OBJ_F/$F_FITNESS", "a")
        fb = open("result/$METHOD/$OBJ_F/$F_BEHAVIOR", "a")
    end

    #------ Main loop ------------------------------#

    logger("INFO", "Start Iteration")

    begin_time = time()

    for iter in 1:MAXTIME
        println("Generation: ", iter)
        
        # Evaluator
        population = Population([evaluator(ind) for ind in population.individuals])
        
        # Mapping
        archive = Mapping(population, archive)
        
        # Reproduction
        population = Reproduction(population, archive)
        
        # Print the solutions
        indPrint(ffn, ff, fb)
        
        # Confirm the convergence
        if CONV_FLAG
            if fitness(best_solution.benchmark[fit_index]) >= 1.0 || abs(sum(SOLUTION .- best_solution.genes)) < EPS
                logger("INFO", "Convergence")
                
                break
            elseif fitness(best_solution.benchmark[fit_index]) < 0.0
                logger("ERROR", "Invalid fitness value")
            end
        end
    end
    
    finish_time = time()

    logger("INFO", "Time out")

    #------ Main loop ------------------------------#

    # Close file
    if FIT_NOISE
        close(ffn)
        close(ff)
        close(fb)
    else
        close(ff)
        close(fb)
    end

    return population, archive, (finish_time - begin_time)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#