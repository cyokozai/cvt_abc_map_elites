#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Make plot                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Printf
using LaTeXStrings
using Dates
using FileIO
using JLD2
using Plots
using StatsPlots
using UnicodePlots
using PyCall
using PyPlot
using DelaunayTriangulation
using CairoMakie

#----------------------------------------------------------------------------------------------------#

include("config.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function MakeFigure(yl="fitness")
    fig = CairoMakie.Figure()
    
    return Axis(fig[1, 1], limits = ((1, 0.0), (MAXTIME, 1.0)), xlabel="Generation", ylabel=yl, title="Fitness: $METHOD", lw=2, height = 400) # Make plot
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function MakeFigure()
    fig = CairoMakie.Figure()

    return Axis(fig[1, 1], limits = ((LOW, UPP), (LOW, UPP)), xlabel = L"b_1", ylabel = L"b_2", title="CVT Map and plotted behavior: $METHOD", lw=2, width = 400, height = 400) # Make plot
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function ReadData(dir::String, item::String)::Dict{Int64, Float64}
    filepath = [path for path in readdir(dir) if occursin(item, path)]

    if length(filepath) == 0
        println("No such file: $item")

        return nothing, nothing
    else
        average_data = Dict{Int64, Float64}()
        datas = Matrix{Any}[]

        for (i, f) in enumerate(filepath)
            open(f, "r") do io
                reading_data = false # ボーダーライン検出用フラグ
                
                for (j, line) in enumerate(eachline(io)) # ファイルを1行ずつ読み込む
                    if occursin("=", line) # ボーダーラインを検出
                        if !reading_data # データ読み取り開始
                            reading_data = true
                            
                            continue
                        else # 2つ目のボーダーラインに到達したら終了
                            break
                        end
                    end
                    
                    if reading_data
                        line_value = tryparse(Float64, line) # 行をFloat64としてパースして格納

                        if line_value !== nothing
                            push!(datas[i][j], line_value)
                        end
                    end
                end

            end
        end

        for (g, data) in enumerate(datas)
            average_data = push(g => mean(data))
        end
    end

    return average_data
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function PlotData(data::Dict{Int64, Float64}, fig::Plots.Plot, yl="fitness")
    return plot!(fig, data, ) # Plot data
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function PlotData(data::Dict{Int64, Float64}, fig::Plots.Plot, yl="behavior")
    return plot(data)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function SavePDF(p::Plots.Plot)
    save("result/$METHOD/$OBJ_F/pdf/$F_FITNESS.pdf", p) # Save plot
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function main()
    filedir = "result/$METHOD/$OBJ_F/"

    data::Dict{Int64, Float64} = ReadData(filedir, ARGS[1])

    if data !== nothing
        figure = MakeFigure(ARGS[1])

        plot = PlotData(data, figure, ARGS[1])

        SavePDF(plot)
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

try
    main()
catch e
    logger("ERROR", e)

    exit_code = 1
finally
    logger("INFO", "Finish the plotting process")

    exit(exit_code)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#