# Behavior function: odd and even
using LinearAlgebra
using Statistics
using Random

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("config.jl")
include("benchmark/benchmark.jl")

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
    g_len = length(individual.genes)
    mid   = rand(1:g_len)
    b1    = sum(individual.genes[1:mid]) * (1/mid)
    b2    = sum(individual.genes[mid+1:end]) * (1/(g_len - mid))

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
    idx = clamp.(individual.behavior, LOW, UPP)

    # グリッドに現在の個体を保存
    for i in 1:archive.grid_size
        for j in 1:archive.grid_size
            if LOW + len * (i - 1) <= idx[1] < LOW + len * i && LOW + len * (j - 1) <= idx[2] < LOW + len * j
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
