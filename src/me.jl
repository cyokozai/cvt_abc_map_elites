#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       ME: Map Elites                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using LinearAlgebra
using Statistics
using Random

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("config.jl")
include("benchmark.jl")
include("struct.jl")
include("logger.jl")
include("abc.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Fitness: 目的関数の定義
function fitness(x::Vector{Float64})::Float64
    sum_val = objective_function(x)

    if sum_val >= 0
        return  1.0 / (sum_val + 1.0)
    else
        return -1.0 / (sum_val - 1.0)
    end
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
function map_to_grid(population::Population, archive::Archive)::Archive
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
                        # すでに個体が存在する場合、評価関数の値が高い方をグリッドに保存
                        if individual.fitness > ind[archive.grid[i, j]].fitness
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Reproduction: 突然変異を伴う個体生成
function mutate(individual::Individual)::Individual
    if rand() > MUT_RATE
        return individual
    else
        mutated_genes = individual.genes .+ 0.1 * randn(length(individual.genes))

        return Individual(mutated_genes, 0.0, [])
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function select_random_elite(population::Population, archive::Archive)
    while true
        i = rand(1:GRID_SIZE)
        j = rand(1:GRID_SIZE)
        
        if archive.grid[i, j] != 1 return population.individuals[archive.grid[i, j]] end
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

Reproduction = if METHOD == "default"
    (population::Population, archive::Archive) -> Population([evaluator(mutate(select_random_elite(population, archive))) for _ in 1:N])
elseif METHOD == "abc"
    (population::Population, archive::Archive) -> ABC(population, archive)
elseif METHOD == "de"
elseif METHOD == "cvt"
else
    error("Invalid method")

    logger("ERROR", "Invalid method")

    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Best solution: 最良解の初期化
init_gene = rand(Float64, D) .* (UPP - LOW) .+ LOW
global best_solution = Individual(init_gene, fitness(init_gene), [sum(init_gene[1:Int(D/2)]), sum(init_gene[Int(D/2+1):end])])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Main loop: アルゴリズムのメインループ
function map_elites()
    # Initialize
    logger("INFO", "Initialize")
    
    global best_solution
    population = Population([evaluator(Individual(rand(Float64, D) .* (UPP - LOW) .+ LOW, 0.0, [])) for _ in 1:N])
    archive = Archive(ones(Int64, GRID_SIZE, GRID_SIZE))

    # Main loop
    logger("INFO", "Start Iteration")

    open("result/$FILENAME", "a") do f
        for iter in 1:MAXTIME
            println("Generation: ", iter)
            println(f, "Generation: ", iter)

            # Evaluator
            population = Population([evaluator(population.individuals[i]) for i in 1:N])

            # Mapping
            archive = map_to_grid(population, archive)

            # Reproduction
            population = Reproduction(population, archive)
            
            println("Now best: ", best_solution.genes)
            println(f, "Now best: ", best_solution.genes)
            println("Now best fitness: ", best_solution.fitness)
            println(f, "Now best fitness: ", best_solution.fitness)
            println("Now best behavior: ", best_solution.behavior)
            println(f, "Now best behavior: ", best_solution.behavior)
            
            # 終了条件の確認
            if sum(abs.(best_solution.genes .- SOLUTION)) < ε || best_solution.fitness >= 1.0
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