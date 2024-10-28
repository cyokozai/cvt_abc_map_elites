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
# 行動識別子の生成
function devide_gene(gene::Vector{Float64})
    g_len = length(gene)
    segment_length = div(g_len, BD)
    behavior = Float64[]
    
    for i in 1:BD
        start_idx = (i - 1) * segment_length + 1
        end_idx = i == BD ? g_len : i * segment_length
        push!(behavior, sum(gene[start_idx:end_idx]))
    end
    
    return behavior
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Evaluator: 評価関数と行動識別子の生成
function evaluator(individual::Individual)
    global best_solution

    # 評価関数を定義
    individual.fitness = fitness(individual.genes)

    # 行動識別子を個体に保存
    individual.behavior = devide_gene(individual.genes)

    # 最良解の更新
    if individual.fitness > best_solution.fitness
        best_solution.genes    = deepcopy(individual.genes)
        best_solution.fitness  = individual.fitness
        best_solution.behavior = deepcopy(individual.behavior)
    end
    
    return individual
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Mapping: 個体を行動空間にプロット
Mapping = if MAP_METHOD == "grid"
    (population::Population, archive::Archive) -> begin
        # 行動識別子(b1, b2)をもとにグリッドのインデックスを計算
        I = population.individuals
        len = (UPP - LOW) / GRID_SIZE
        
        # グリッドに現在の個体を保存
        for (index, ind) in enumerate(I)
            idx = clamp.(ind.behavior, LOW, UPP)
            
            for i in 1:GRID_SIZE
                for j in 1:GRID_SIZE
                    # グリッドのインデックスを計算
                    if LOW + len * (i - 1) <= idx[1] && idx[1] < LOW + len * i && LOW + len * (j - 1) <= idx[2] && idx[2] < LOW + len * j
                        # グリッドに個体を保存
                        if archive.grid[i, j] > 0
                            # すでに個体が存在する場合、評価関数の値が高い方をグリッドに保存 | >= と > で性能に変化がある
                            if ind.fitness >= I[archive.grid[i, j]].fitness
                                archive.grid[i, j] = index
                            end
                        else
                            # 個体が存在しない場合、個体をグリッドに保存
                            archive.grid[i, j] = index
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
# Reproduction: 突然変異を伴う個体生成
mutate(individual::Individual) = rand() > MUT_RATE ? individual : Individual(individual.genes .+ 0.1randn(RNG, length(individual.genes)), 0.0, [])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
select_random_elite = if MAP_METHOD == "grid"
    (population::Population, archive::Archive) -> begin
        while true
            i = rand(RNG, 1:GRID_SIZE)
            j = rand(RNG, 1:GRID_SIZE)
            
            if archive.grid[i, j] > 0
                return population.individuals[archive.grid[i, j]]
            end
        end
    end
elseif MAP_METHOD == "cvt"
    (population::Population, archive::Archive) -> begin
        while true
            random_centroid_index = rand(RNG, 1:k_max)
            
            if haskey(archive.area, random_centroid_index) && archive.area[random_centroid_index] > 0
                return population.individuals[archive.area[random_centroid_index]]
            end
        end
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

Reproduction = if METHOD == "default"
    (population::Population, archive::Archive) -> Population([evaluator(mutate(select_random_elite(population, archive))) for _ in 1:N])
elseif METHOD == "abc"
    (population::Population, archive::Archive) -> ABC(population, archive)
elseif METHOD == "de"
    (population::Population, archive::Archive) -> DE(population, archive)
else
    error("Invalid method")

    logger("ERROR", "Invalid method")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Best solution: 最良解の初期化
init_gene = rand(RNG, D) .* (UPP - LOW) .+ LOW
best_solution = Individual(init_gene, fitness(init_gene), devide_gene(init_gene))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Main loop: アルゴリズムのメインループ
function map_elites()
    global best_solution, vorn

    # Initialize
    logger("INFO", "Initialize")
    
    population::Population = Population([evaluator(Individual(rand(RNG, D) .* (UPP - LOW) .+ LOW, 0.0, [])) for _ in 1:N])
    archive::Archive = if MAP_METHOD == "grid"
        Archive(zeros(Int64, GRID_SIZE, GRID_SIZE), Dict{Int64, Int64}())
    elseif MAP_METHOD == "cvt"
        Archive(zeros(Int64, 0, 0), Dict{Int64, Int64}(i => 0 for i in keys(init_CVT(population))))
    end

    # Main loop
    logger("INFO", "Start Iteration")
    
    open("result/$F_RESULT", "a") do f
        for iter in 1:MAXTIME
            println("Generation: ", iter)
            println(f, "Generation: ", iter)

            # Evaluator
            population = Population([evaluator(population.individuals[i]) for i in 1:N])

            # Mapping
            archive = Mapping(population, archive)
            
            # Reproduction
            population = Reproduction(population, archive)
            
            println("Now best: ", best_solution.genes)
            println(f, "Now best: ", best_solution.genes)
            println("Now best fitness: ", best_solution.fitness)
            println(f, "Now best fitness: ", best_solution.fitness)
            println("Now best behavior: ", best_solution.behavior)
            println(f, "Now best behavior: ", best_solution.behavior)
            
            # 終了条件の確認
            if sum(abs.(best_solution.genes .- SOLUTION)) < ε || best_solution.fitness >= 1.0 && CONV_FLAG == true
                logger("INFO", "Convergence")

                CONV_FLAG == false
            elseif iter == MAXTIME
                logger("INFO", "Time out")
                
                break
            end

            println(f, "-----------------------------------------------------------------------------------")
        end
    end
    
    logger("INFO", "End of Iteration")
    
    return population, archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#