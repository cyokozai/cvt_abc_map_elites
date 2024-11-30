#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Fitness function                                                                             #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("benchmark.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# 目的関数の定義
fitness = FIT_NOISE ?
    (x::Vector{Float64}) -> begin
        sum_val = objective_function(x)
        
        sum_val >= 0 ? [1.0 / (1.0 + sum_val + rand(RNG, -NOIZE_R:NOIZE_R)), 1.0 / (1.0 + sum_val)] : [abs(1.0 + sum_val + rand(RNG, -NOIZE_R:NOIZE_R)), abs(1.0 + sum_val)]
    end : 
    (x::Vector{Float64}) -> begin
        sum_val = objective_function(x)
        
        sum_val >= 0 ? [1.0 / (1.0 + sum_val), nothing] : [abs(1.0 + sum_val), nothing]
    end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#