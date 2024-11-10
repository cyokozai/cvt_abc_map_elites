#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Make plot                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Printf
using Dates
using Plots
using StatsPlots
using UnicodePlots
using PyCall
using PyPlot
using LaTeXStrings

#----------------------------------------------------------------------------------------------------#

include("config.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function MakeFigure()
    # Load data
    data = readdlm("result/$METHOD/$OBJ_F/$F_FITNESS", ',', Float64, '\n', header=false)

    # Make plot
    p = plot(data, xlabel="Iteration", ylabel="Fitness", title="Fitness of $METHOD", label="Fitness", lw=2)

    # Save plot
    savefig(p, "result/$METHOD/$OBJ_F/$F_FITNESS.png")
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function SavePDF()
    # Load data
    data = readdlm("result/$METHOD/$OBJ_F/$F_FITNESS", ',', Float64, '\n', header=false)

    # Make plot
    p = plot(data, xlabel="Iteration", ylabel="Fitness", title="Fitness of $METHOD", label="Fitness", lw=2)

    # Save plot
    savefig(p, "result/$METHOD/$OBJ_F/$F_FITNESS.pdf")
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function parse_fitness_data(filename::String)
    open(filename, "r") do io
        reading_data = false # ボーダーライン検出用フラグ
        generation = 1       # 世代数
        fitness_data = []    # 出力用の配列
        
        # ファイルを1行ずつ読み込む
        for line in eachline(io)
            # ボーダーラインを検出
            if occursin("=", line)
                # データ読み取り開始
                if !reading_data
                    reading_data = true
                    
                    continue
                else
                    # 2つ目のボーダーラインに到達したら終了
                    break
                end
            end

            # データ読み取り中の場合
            if reading_data
                # 行をFloat64としてパースして格納
                fitness_value = tryparse(Float64, line)
                if fitness_value !== nothing
                    push!(fitness_data, (generation, fitness_value))
                    generation += 1
                end
            end
        end

        return fitness_data
    end
end

# データファイルから読み込んで結果を表示
filename = "result/fitness-2024-11-08-05-17-abc-cvt-rastrigin-50.dat"
fitness_data = parse_fitness_data(filename)

# 結果の確認
for (gen, value) in fitness_data
    println("Generation $gen: $value")
end
