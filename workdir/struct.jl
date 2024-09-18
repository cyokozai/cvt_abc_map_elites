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
