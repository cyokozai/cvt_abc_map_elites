# ME: Map Elites
using LinearAlgebra
using Statistics
using Random

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("config.jl")
include("benchmark/benchmark.jl")
include("struct.jl")
include("abc.jl")

# include("cvt-me.jl")
# include("de-me.jl")
# include("cvt-de-me.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

global best_solution = Individual(randn(N), 0.0, [])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Fitness: 目的関数の定義
function fitness(x::Vector{Float64})::Float64
    sum_val = sum(objective_function(x))

    if sum_val >= 0
        return  1.0 / (sum_val + 1.0)
    else
        return -1.0 / (sum_val - 1.0)
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Evaluator: 評価関数と行動識別子の生成
function evaluator(individual::Individual)
    global best_solution

    # 評価関数を定義
    individual.fitness = fitness(individual.genes)

    # 行動識別子の生成
    g_len = length(individual.genes)
    b1    = sum(individual.genes[1:Int(g_len/2)])
    b2    = sum(individual.genes[Int(g_len/2+1):end])
    
    individual.behavior = [b1, b2]

    if individual.fitness > best_solution.fitness
        best_solution = individual
    end
    
    return individual
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Mapping: 個体を行動空間にプロット
function map_to_grid(population::Population, archive::Archive)
    # 行動識別子(b1, b2)をもとにグリッドのインデックスを計算
    ind = population.individuals
    len = (UPP - LOW) / GRID_SIZE

    # グリッドに現在の個体を保存
    for individual in ind
        idx = clamp.(individual.behavior, LOW, UPP)

        for i in 1:GRID_SIZE
            for j in 1:GRID_SIZE
                if LOW + len * (i - 1) <= idx[1] && idx[1] < LOW + len * i && LOW + len * (j - 1) <= idx[2] && idx[2] < LOW + len * j
                    if archive.grid[i, j] !== nothing
                        if individual.fitness > archive.grid[i, j].fitness
                            archive.grid[i, j] = individual
                        end

                        break
                    end

                    archive.grid[i, j] = individual
                    break
                end
            end
        end
    end

    return archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Reproduction: 突然変異を伴う個体生成
function mutate(individual::Individual)
    if rand() > MUT_RATE
        return individual
    else
        mutated_genes = individual.genes .+ 0.1 * randn(length(individual.genes))

        return Individual(mutated_genes, 0.0, [])
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function select_random_elite(archive::Archive)
    while true
        i = rand(1:GRID_SIZE)
        j = rand(1:GRID_SIZE)
        
        if archive.grid[i, j] !== nothing return archive.grid[i, j] end
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

Reproduction = if METHOD == "default"
    archive::Archive -> Population([evaluator(mutate(select_random_elite(archive))) for _ in 1:POP_SIZE])
elseif METHOD == "abc"
    # archive = ABC(archive)
    # (archive::Archive) -> Population([evaluator(select_random_elite(archive)) for _ in 1:POP_SIZE])
elseif METHOD == "de"
elseif METHOD == "cvt"
elseif METHOD == "cvt-de"
else
    error("Invalid method")
    
    exit(1)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Main loop: アルゴリズムのメインループ
function map_elites()
    # initialize
    population = Population([evaluator(Individual(randn(N), 0.0, [])) for _ in 1:POP_SIZE])
    archive = Archive(Matrix{Union{Nothing, Individual}}(nothing, GRID_SIZE, GRID_SIZE), GRID_SIZE)

    # Main loop
    open("result/$FILENAME", "a") do f
        println("Method: ", METHOD)
        println(f, "Method: ", METHOD)

        for iter in 1:MAXTIME
            println("Generation: ", iter)
            println(f, "Generation: ", iter)

            # Evaluator
            population = Population([evaluator(population.individuals[i]) for i in 1:POP_SIZE])

            # Archive
            archive = map_to_grid(population, archive)
            
            # Reproduction
            population = Reproduction(archive)
            
            println("Now best: ", best_solution.genes)
            println(f, "Now best: ", best_solution.genes)
            println("Now best fitness: ", best_solution.fitness)
            println(f, "Now best fitness: ", best_solution.fitness)
            println("Now best behavior: ", best_solution.behavior)
            println(f, "Now best behavior: ", best_solution.behavior)
            
            # 終了条件の確認
            if sum(abs.(best_solution.genes .- SOLUTION)) < ε
                break
            end

            println(f, "-----------------------------------------------------------------------------------")
        end
    end

    return population, archive
end
