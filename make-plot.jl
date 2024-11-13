#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Make plot                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Printf
using LaTeXStrings
using Dates
using FileIO
using JLD2
using DelaunayTriangulation
using CairoMakie

#----------------------------------------------------------------------------------------------------#

include("config.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function MakeFigure()
    fig = CairoMakie.Figure()

    if ARGS[5] == "fitness"
        ax = Axis(
            fig[1, 1],
            limits = ((0, MAXTIME), (0.0, 1.0)),
            xlabel="Generation",
            ylabel="Fitness",
            title="Fitness: $METHOD"
        )
    elseif ARGS[5] == "cvt"
        load_path = [path for path in readdir("result/$(ARGS[2])/$(ARGS[4])/") if occursin("CVT-", path) && occursin("-$(ARGS[3])-", path) && occursin("-$(ARGS[4])-$(ARGS[1])-", path)]

        load_vorn = load(load_path[end], "voronoi")
        
        ax = Axis(
            fig[1, 1],
            limits = ((LOW, UPP), (LOW, UPP)),
            xlabel = L"b_1",
            ylabel = L"b_2",
            title="CVT Map and plotted behavior: $METHOD",
            width = 400,
            height = 400
        )

        voronoiplot!(ax, load_vorn, colormap = :matter, strokewidth = 0.1, show_generators = false)
    end
    
    resize_to_layout!(fig)

    return fig, ax
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function ReadData(dir::String)
    filepath = [path for path in readdir(dir) if occursin("-$(ARGS[1]).", path) && occursin("-$(ARGS[2])-", path) && occursin("-$(ARGS[3])-", path) && occursin("-$(ARGS[4])-", path) && occursin("$(ARGS[5])-", path)]

    if length(filepath) == 0
        println("No such file: $ARGS[5]")

        return nothing
    else
        if ARGS[5] == "fitness"
            Data = Matrix{Float64}(undef, length(filepath), MAXTIME)

            for (i, f) in enumerate(filepath)
                j = 1
                reading_data = false # ボーダーライン検出用フラグ

                open("$dir$f", "r") do io
                    for line in eachline(io) # ファイルを1行ずつ読み込む
                        if occursin("=", line) # ボーダーラインを検出
                            if !reading_data # データ読み取り開始
                                reading_data = true
                                
                                continue
                            else # 2つ目のボーダーラインに到達したら終了
                                break
                            end
                        end
                        
                        if reading_data
                            Data[i, j] = tryparse(Float64, line)
                            j += 1
                        end
                    end
                end
            end
        elseif ARGS[5] == "cvt"
            Data = Vector{Tuple{Float64, Float64}}[]

            open(filepath[end], "r") do io
                reading_data = false # ボーダーライン検出用フラグ
                
                for (k, line) in enumerate(eachline(io)) # ファイルを1行ずつ読み込む
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
                            push!(Data[k], line_value)
                        end
                    end
                end
            end
        end

        return Data
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function PlotData(data, axis)
    if ARGS[5] == "fitness"
        sum_data = zeros(size(data, 2))

        for i in eachindex(data)
            d = data[i, axes(data, 2)]
            
            scatterlines!(axis, 1:size(d, 1), d, marker=nothing, linestyle=:solid, linewidth=0.5, color=:blue)

            sum_data .+= d # Sum data
        end

        average_data = sum_data ./ size(data, 1) # Calculate average data
        
        scatterlines!(axis, 1:size(average_data, 1), average_data, marker=nothing, linestyle=:solid, linewidth=1.0, color=:red)
    # elseif ARGS[5] == "cvt"
    #     scatter!(axis, data, marker = 'x', markersize = 14, color = :green) # Plot behavior points
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function SavePDF(fig)
    resize_to_layout!(fig) # Resize to layout
    println("result/$(ARGS[2])/$(ARGS[4])/pdf/$(ARGS[2])-$(ARGS[4])-$(ARGS[1])-$(ARGS[5]).pdf")
    save("result/$(ARGS[2])/$(ARGS[4])/pdf/$(ARGS[2])-$(ARGS[4])-$(ARGS[1])-$(ARGS[5]).pdf", fig) # Save plot
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function main()
    data = ReadData("result/$(ARGS[2])/$(ARGS[4])/")

    figure, axis = MakeFigure()

    PlotData(data, axis)

    SavePDF(figure)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# try
    mkpath("result/$(ARGS[2])/$(ARGS[4])/pdf/") # Make directory

    main()
# catch e
#     logger("ERROR", e)

#     global exit_code = 1
# finally
#     logger("INFO", "Finish the plotting process")
    
#     exit(exit_code)
# end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#