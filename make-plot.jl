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
    
    if ARGS[5] == "fitness" || ARGS[1] == "test"
        ax = Axis(
            fig[1, 1],
            limits = ((0, MAXTIME), (0.0, 1.0)),
            xlabel=L"\mathrm{Generation\,} (\times 10^4)",
            ylabel=L"\mathrm{Fitness\,}",
            title="Method: $METHOD, Problem: $(ARGS[4]), Dimension: $(ARGS[1])",
            xticks=(2*10^4:2*10^4:MAXTIME, string.([2, 4, 6, 8, 10])),
            yminorticks = IntervalsBetween(1*10^4),
        )
    elseif ARGS[5] == "fitness-noise"
        ax = Axis(
            fig[1, 1],
            limits = ((0, MAXTIME), (0.0, 1.0)),
            xlabel=L"\mathrm{Generation\,} (\times 10^4)",
            ylabel=L"\mathrm{Noised Fitness\,}",
            title="Method: $METHOD, Problem: $(ARGS[4]), Dimension: $(ARGS[1])",
            xticks=(2*10^4:2*10^4:MAXTIME, string.([2, 4, 6, 8, 10])),
            yminorticks = IntervalsBetween(1*10^4),
        )
    else
        error("No such data type: $(ARGS[5])")

        exit(1)
    end
    
    resize_to_layout!(fig)
    
    return fig, ax
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function ReadData(dir::String)
    filepath = [path for path in readdir(dir) if occursin("-$(ARGS[1]).", path) && occursin("-$(ARGS[2])-", path) && occursin("-$(ARGS[3])-", path) && occursin("-$(ARGS[4])-", path) && occursin("$(ARGS[5])-2", path)]

    if length(filepath) == 0
        println("No such file: $ARGS[5]")
        
        return nothing
    else
        if ARGS[5] == "fitness"
            Data = Matrix{Float64}(undef, length(filepath), MAXTIME)
            
            for (i, f) in enumerate(filepath)
                if occursin(".dat", f)
                    j, reading_data = 1, false
                    
                    open("$dir$f", "r") do io # ファイルを開く
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
            end
        elseif ARGS[5] == "fitness-noise"
        end

        return Data
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function PlotData(data, fig, axis)
    if ARGS[5] == "fitness" || ARGS[5] == "fitness-noise" || ARGS[1] == "test"
        sum_data = zeros(length(data[1, :]))

        for i in 1:length(data[:, 1])
            d = data[i, :]
            
            lines!(axis, 1:MAXTIME, d, linestyle=:solid, linewidth=1.0, color=:blue)
            
            sum_data[i] .+= d # Sum data
        end
        
        average_data = sum_data ./ Float64(length(data[1, :])) # Calculate average data
        
        lines!(axis, 1:MAXTIME, average_data, linestyle=:solid, linewidth=1.0, color=:red)
    else
        error("No such data type: $(ARGS[5])")

        exit(1)
    end

    resize_to_layout!(fig)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function SavePDF(fig)
    println("Saved: result/$(ARGS[2])/$(ARGS[4])/pdf/$(ARGS[2])-$(ARGS[4])-$(ARGS[1])-$(ARGS[5]).pdf")
    save("result/$(ARGS[2])/$(ARGS[4])/pdf/$(ARGS[2])-$(ARGS[4])-$(ARGS[1])-$(ARGS[5]).pdf", fig)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function main()
    data = if ARGS[5] == "fitness" || ARGS[5] == "fitness-noise"
        ReadData("./result/$(ARGS[2])/$(ARGS[4])/")
    elseif ARGS[1] == "test"
        ReadData("./result/.testdata/")x
    end
    
    figure, axis = MakeFigure()

    PlotData(data, figure, axis)

    SavePDF(figure)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# try
    mkpath("./result/$(ARGS[2])/$(ARGS[4])/pdf/")

    main()
# catch e
#     logger("ERROR", e)

#     global exit_code = 1
# finally
#     logger("INFO", "Finish the plotting process")

#     exit(exit_code)
# end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#