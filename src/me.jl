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
        
        push!(behavior, 2.0*sum(gene[start_idx:end_idx])/Float64(g_len))
    end
    
    return behavior
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Initialize the best solution
function init_solution()
    gene = rand(RNG, D) .* (UPP - LOW) .+ LOW
    
    return Individual(deepcopy(gene), fitness(gene), devide_gene(gene))
end

#----------------------------------------------------------------------------------------------------#
# Best solution
best_solution = init_solution()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Evaluator: Evaluation of the individual
function evaluator(individual::Individual)
    # 評価関数を定義
    individual.fitness = fitness(individual.genes)
    
    # 行動識別子を個体に保存
    individual.behavior = deepcopy(devide_gene(individual.genes))

    # 最良解の更新
    if individual.fitness >= best_solution.fitness
        global best_solution = Individual(deepcopy(individual.genes), individual.fitness, deepcopy(individual.behavior))
    end
    
    return individual
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Mapping: Mapping the individual to the archive
Mapping = if MAP_METHOD == "grid"
    (population::Population, archive::Archive) -> begin
        # 行動識別子(b1, b2)をもとにグリッドのインデックスを計算
        len = (UPP - LOW) / GRID_SIZE
        
        # グリッドに現在の個体を保存
        for (index, ind) in enumerate(population.individuals)
            idx = clamp.(ind.behavior, LOW, UPP)
            
            for i in 1:GRID_SIZE
                for j in 1:GRID_SIZE
                    # グリッドのインデックスを計算
                    if LOW + len * (i - 1) <= idx[1] && idx[1] < LOW + len * i && LOW + len * (j - 1) <= idx[2] && idx[2] < LOW + len * j
                        # グリッドに個体を保存
                        if archive.grid[i, j] > 0
                            # すでに個体が存在する場合、評価関数の値が高い方をグリッドに保存 | >= と > で性能に変化がある
                            if ind.fitness > archive.individuals[archive.grid[i, j]].fitness
                                archive.grid[i, j] = index
                                archive.individuals[index] = Individual(deepcopy(ind.genes), ind.fitness, deepcopy(ind.behavior))
                                archive.grid_update_counts[index] += 1
                            end
                        else
                            # 個体が存在しない場合、個体をグリッドに保存
                            archive.grid[i, j] = index
                            archive.individuals[index] = Individual(deepcopy(ind.genes), ind.fitness, deepcopy(ind.behavior))
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
mutate(individual::Individual) = rand() > MUTANT_R ? individual : init_solution()

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
    
    # Initialize
    logger("INFO", "Initialize")
    
    population::Population = Population([evaluator(init_solution()) for _ in 1:N])
    archive::Archive = if MAP_METHOD == "grid"
        Archive(zeros(Int64, GRID_SIZE, GRID_SIZE), grid_update_counts = zeros(Int64, GRID_SIZE, GRID_SIZE), Dict{Int64, Individual}())
    elseif MAP_METHOD == "cvt"
        init_CVT(population)
        Archive(zeros(Int64, 0, 0), grid_update_counts = zeros(Int64, k_max), Dict{Int64, Individual}())
    end
    
    # Open file
    ff = open("result/$METHOD/$OBJ_F/$F_FITNESS", "a")
    fb = open("result/$METHOD/$OBJ_F/$F_BEHAVIOR", "a")
    
    # Main loop
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
        
        println("Now best: ", best_solution.genes)
        if FIT_NOISE
            println("Now best fitness: ", best_solution.fitness[1])
        else
            println("Now noised best fitness: ", best_solution.fitness[1])
            println("Now corrected best fitness: ", best_solution.fitness[2])
        end
        println("Now best behavior: ", best_solution.behavior)

        if FIT_NOISE
            println(ff, best_solution.fitness[1])
        else
            println(ff
            , best_solution.fitness[1])
            println("Now corrected best fitness: ", best_solution.fitness[2])
        end
        println(fb, best_solution.behavior)
        
        # 終了条件の確認
        if best_solution.fitness >= 1.0
            if CONV_FLAG == true
                logger("INFO", "Convergence")

                global CONV_FLAG = false
            end

            # break
        elseif iter == MAXTIME
            logger("INFO", "Time out")
            
            break
        elseif best_solution.fitness < 0.0
            logger("ERROR", "Invalid fitness value")
            
            exit(1)
        end
    end

    finish_time = time()

    close(ff)
    close(fb)

    return population, archive, (finish_time - begin_time)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#