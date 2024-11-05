#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Import struct                                                                                #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

mutable struct Individual
    genes::Vector{Float64}     # N次元の遺伝子
    fitness::Float64           # 評価値
    behavior::Vector{Float64}  # 行動識別子
end

#----------------------------------------------------------------------------------------------------#

mutable struct Population
    individuals::Vector{Individual}  # 個体群
end

#----------------------------------------------------------------------------------------------------#

mutable struct Archive
    grid::Matrix{Int64}       # グリッドマップ　各セルに個体の要素番号を保存
    area::Dict{Int64, Int64}  # CVTのセルに個体の要素番号を保存
    individuals::Dict{Int64, Individual}  # 個体の要素番号に対応する個体を保存
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#