using LinearAlgebra
using Statistics
using Random

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("config.jl")
include("benchmark/benchmark.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

mutable struct Individual
    genes::Vector{Float64}  # N次元の遺伝子
    fitness::Float64  # 評価値
    behavior::Vector{Float64}  # 行動識別子

    best_solution_gene::Vector{Float64}
    best_solution_fitness::Float64
    best_solution_behavior::Vector{Float64}
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

struct Population
    individuals::Vector{Individual}  # 個体群
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

struct Archive
    grid::Matrix{Union{Nothing, Individual}}  # グリッドマップ、各セルに個体を保存
    grid_size::Int  # グリッドのサイズ
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

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
    # 評価関数を定義
    individual.fitness = fitness(individual.genes)

    # 行動識別子の生成
    mid = div(length(individual.genes), 2)
    b1  = sum(individual.genes[1:mid])
    b2  = sum(individual.genes[mid+1:end])

    individual.behavior = [b1, b2]
    
    # ベストソリューションの更新
    if individual.best_solution_gene === nothing || individual.fitness > individual.best_solution_fitness
        individual.best_solution_gene = individual.genes
        individual.best_solution_fitness = individual.fitness
        individual.best_solution_behavior = individual.behavior
    end
    
    return individual
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Mapping: 個体を行動空間にプロット
function map_to_grid(individual::Individual, archive::Archive)
    # 行動識別子(b1, b2)をもとにグリッドのインデックスを計算
    len  = (UPP - LOW) / archive.grid_size
    idx1 = clamp(individual.behavior[1], LOW, UPP)
    idx2 = clamp(individual.behavior[2], LOW, UPP)

    # グリッドに現在の個体を保存
    for i in 1:archive.grid_size
        for j in 1:archive.grid_size
            if LOW + len * (i - 1) <= idx1 < LOW + len * i && LOW + len * (j - 1) <= idx2 < LOW + len * j
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Reproduction: 突然変異を伴う個体生成
function mutate(individual::Individual)
    mutated_genes = individual.genes .+ 0.1 * randn(length(individual.genes))
    new_individual = Individual(mutated_genes, 0.0, [], individual.best_solution_gene, individual.best_solution_fitness, individual.best_solution_behavior)
    return new_individual
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function select_random_elite(archive::Archive)
    # アーカイブ内からランダムにエリート個体を選択
    while true
        i = rand(1:archive.grid_size)
        j = rand(1:archive.grid_size)
        
        if archive.grid[i, j] !== nothing
            return archive.grid[i, j]
        end
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Main loop: アルゴリズムのメインループ
function map_elites(pop_size::Int, grid_size::Int)
    # 初期個体群の生成
    population = Population([evaluator(Individual(randn(N), 0.0, [], randn(N), 0.0, [])) for _ in 1:pop_size])
    archive = Archive(Matrix{Union{Nothing, Individual}}(nothing, grid_size, grid_size), grid_size)
    best_solution = evaluator(Individual(randn(N), 0.0, [], randn(N), 0.0, []))
    
    # Main loop
    for iter in 1:MAXTIME
        println("Generation: ", iter)

        for individual in population.individuals
            map_to_grid(individual, archive)
        end
        
        # Reproduction
        population = Population([evaluator(mutate(select_random_elite(archive))) for _ in 1:pop_size])
        
        # 全体最良個体の取得
        for individual in population.individuals
            if individual.fitness > best_solution.fitness
                best_solution = individual
            end
        end
        
        println("Now best: ", best_solution.genes)
        println("Now best fitness: ", best_solution.fitness)
        println("Now best behavior: ", best_solution.behavior)
        
        # 終了条件の確認
        if sum(abs.(best_solution.genes .- SOLUTION)) < ε
            break
        end
    end
    
    return best_solution, archive
end
