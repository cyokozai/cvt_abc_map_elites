#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       ME: Map Elites                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using StableRNGs

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("abc.jl")
include("de.jl")
include("struct.jl")
include("config.jl")
include("benchmark.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Fitness: 目的関数の定義
function fitness(x::Vector{Float64})::Float64
    sum_val = objective_function(x)

    return sum_val >= 0 ? 1.0 / (1.0 + sum_val) : abs(1.0 + sum_val)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Evaluator: 評価関数と行動識別子の生成
function evaluator(individual::Individual)::Individual
    global best_solution

    # 評価関数を定義
    individual.fitness = fitness(individual.genes)

    # 行動識別子の生成
    g_len = length(individual.genes)
    b1    = sum(individual.genes[1:Int(g_len/2)])
    b2    = sum(individual.genes[Int(g_len/2+1):end])
    
    # 行動識別子を個体に保存
    individual.behavior = [b1, b2]

    # 最良解の更新
    if individual.fitness > best_solution.fitness
        best_solution.genes    = copy(individual.genes)
        best_solution.fitness  = copy(individual.fitness)
        best_solution.behavior = copy(individual.behavior)
    end
    
    return individual
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Mapping: 個体を行動空間にプロット
mapping = if MAP_METHOD == "grid"
    (population::Population, archive::Archive)::Archive -> begin
        # 行動識別子(b1, b2)をもとにグリッドのインデックスを計算
        ind = population.individuals
        len = (UPP - LOW) / GRID_SIZE

        # グリッドに現在の個体を保存
        for (index, individual) in enumerate(ind)
            idx = clamp.(individual.behavior, LOW, UPP)

            for i in 1:GRID_SIZE
                for j in 1:GRID_SIZE
                    # グリッドのインデックスを計算
                    if LOW + len * (i - 1) <= idx[1] && idx[1] < LOW + len * i && LOW + len * (j - 1) <= idx[2] && idx[2] < LOW + len * j
                        # グリッドに個体を保存
                        if archive.grid[i, j] !== nothing
                            # すでに個体が存在する場合、評価関数の値が高い方をグリッドに保存 | >= と > で性能に変化がある
                            if individual.fitness >= ind[archive.grid[i, j]].fitness archive.grid[i, j] = index end
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
    (population::Population, archive::Archive)::Archive -> begin
    end
else
    error("Invalid MAP method")

    logger("ERROR", "Invalid MAP method")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Reproduction: 突然変異を伴う個体生成
mutate(individual::Individual) = rand() > MUT_RATE ? individual : Individual(individual.genes .+ 0.1randn(RNG, length(individual.genes)), 0.0, [])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function select_random_elite(population::Population, grid::Matrix{Int64})
    while true
        i = rand(RNG, 1:GRID_SIZE)
        j = rand(RNG, 1:GRID_SIZE)
        
        if grid[i, j] != 1 return population.individuals[grid[i, j]] end
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

Reproduction = if METHOD == "default"
    (population::Population, archive::Archive) -> Population([evaluator(mutate(select_random_elite(population, archive.grid))) for _ in 1:N])
elseif METHOD == "abc"
    (population::Population, archive::Archive) -> ABC(population, archive)
elseif METHOD == "de"
    # (population::Population, archive::Archive) -> DE(population, archive)
else
    error("Invalid method")

    logger("ERROR", "Invalid method")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Best solution: 最良解の初期化
init_gene = rand(RNG, D) .* (UPP - LOW) .+ LOW
global best_solution::Individual = Individual(init_gene, fitness(init_gene), [sum(init_gene[1:Int(D/2)]), sum(init_gene[Int(D/2+1):end])])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Main loop: アルゴリズムのメインループ
function map_elites()
    # Initialize
    logger("INFO", "Initialize")
    
    global best_solution
    population::Population = Population([evaluator(Individual(rand(RNG, D) .* (UPP - LOW) .+ LOW, 0.0, [])) for _ in 1:N])
    if MAP_METHOD == "grid"
        archive::Archive = Archive(ones(Int64, GRID_SIZE, GRID_SIZE), _)
    elseif MAP_METHOD == "cvt"
        archive::Archive = Archive(_, Dict{Int64, Individual}())
    end

    # Main loop
    logger("INFO", "Start Iteration")

    open("result/$FILENAME", "a") do f
        for iter in 1:MAXTIME
            println("Generation: ", iter)
            println(f, "Generation: ", iter)

            # Evaluator
            population = Population([evaluator(population.individuals[i]) for i in 1:N])

            # Mapping
            archive = mapping(population, archive)

            # Reproduction
            population = Reproduction(population, archive)
            
            println("Now best: ", best_solution.genes)
            println(f, "Now best: ", best_solution.genes)
            println("Now best fitness: ", best_solution.fitness)
            println(f, "Now best fitness: ", best_solution.fitness)
            println("Now best behavior: ", best_solution.behavior)
            println(f, "Now best behavior: ", best_solution.behavior)
            
            # 終了条件の確認
            if sum(abs.(best_solution.genes .- SOLUTION)) < ε || best_solution.fitness >= 1.0 || CONV_FLAG == true
                logger("INFO", "Convergence")

                break
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