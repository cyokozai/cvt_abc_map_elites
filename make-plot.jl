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

global MAXTIME = 100000

function MakeFigure()
    fig = CairoMakie.Figure()
    
    ax = if ARGS[1] == "test"
        Axis(
            fig[1, 1],
            limits = ((0, MAXTIME), (1.0e-6, 1.0e+4)),
            xlabel=L"\mathrm{Generation\,} (\times 10^4)",
            ylabel=L"\mathrm{Fitness\,}",
            title="Test data",
            xticks=(0:2*10^4:MAXTIME, string.([0, 2, 4, 6, 8, 10])),
            xminorticks = IntervalsBetween(2),
            yscale=log10,
            yticks=(10.0 .^ (-6.0:2.0:6.0), string.(["1.0e-06", "1.0e-04", "1.0e-02", "1.0e+00", "1.0e+02", "1.0e+04", "1.0e+06"])),
            yminorticks = IntervalsBetween(5),
        )
    elseif ARGS[5] == "fitness"
        Axis(
            fig[1, 1],
            limits = ((0, MAXTIME), (0.0, 1.0)),
            xlabel=L"\mathrm{Generation\,} (\times 10^4)",
            ylabel=L"\mathrm{Fitness\,}",
            title="Method: $METHOD, Problem: $(ARGS[4]), Dimension: $(ARGS[1])",
            xticks=(0:2*10^4:MAXTIME, string.([0, 2, 4, 6, 8, 10])),
            xminorticks = IntervalsBetween(2),
            yscale=log10,
            yticks=(10.0 .^ (-6.0:2.0:6.0), string.(["1.0e-06", "1.0e-04", "1.0e-02", "1.0e+00", "1.0e+02", "1.0e+04", "1.0e+06"])),
            yminorticks = IntervalsBetween(5),
        )
    elseif ARGS[5] == "fitness-noise"
        Axis(
            fig[1, 1],
            limits = ((0, MAXTIME), (0.0, 1.0)),
            xlabel=L"\mathrm{Generation\,} (\times 10^4)",
            ylabel=L"\mathrm{Noised Fitness\,}",
            title="Method: $METHOD, Problem: $(ARGS[4]), Dimension: $(ARGS[1])",
            xticks=(0:2*10^4:MAXTIME, string.([0, 2, 4, 6, 8, 10])),
            xminorticks = IntervalsBetween(2),
            yscale=log10,
            yticks=(10.0 .^ (-6.0:2.0:6.0), string.(["1.0e-06", "1.0e-04", "1.0e-02", "1.0e+00", "1.0e+02", "1.0e+04", "1.0e+06"])),
            yminorticks = IntervalsBetween(5),
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
    println("Read data: $dir")
    filepath = if ARGS[1] == "test"
        [path for path in readdir(dir) if occursin("$(ARGS[1])", path) && occursin("fitness", path)]
    elseif ARGS[5] == "fitness" || ARGS[5] == "fitness-noise"
        [path for path in readdir(dir) if occursin("-$(ARGS[1]).", path) && occursin("-$(ARGS[2])-", path) && occursin("-$(ARGS[3])-", path) && occursin("-$(ARGS[4])-", path) && occursin("$(ARGS[5])-2", path)]
    end
    
    if length(filepath) == 0
        println("No such file: $ARGS")
        
        return nothing
    else
        if ARGS[1] == "test" || ARGS[5] == "fitness" || ARGS[5] == "fitness-noise"
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
                                parsed_value = tryparse(Float64, line)

                                if parsed_value !== nothing
                                    if parsed_value == 0.0
                                        Data[i, j] = 1.0e+2
                                    else
                                        Data[i, j] = 1.0/parsed_value - 1.0
                                    end

                                    j += 1
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return Data
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function PlotData(data, fig, axis)
    if ARGS[1] == "test" || ARGS[5] == "fitness" || ARGS[5] == "fitness-noise"
        sum_data = zeros(size(data, 2))
        
        for i in 1:size(data, 1)
            d = data[i, :]
            
            lines!(axis, 1:MAXTIME, d, linestyle=:solid, linewidth=1.0, color=:blue)
            
            sum_data .+= d # Sum data
        end
        
        average_data = sum_data ./ Float64(size(data, 1)) # Calculate average data
        
        lines!(axis, 1:MAXTIME, average_data, linestyle=:solid, linewidth=1.0, color=:red)
    else
        error("No such data type: $(ARGS[5])")

        exit(1)
    end
    
    resize_to_layout!(fig)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function SavePDF(fig)
    if ARGS[1] == "test"
        println("Saved: result/testdata/pdf/testdata.pdf")
        save("result/testdata/pdf/fitness-testdata.pdf", fig)
    elseif ARGS[5] == "fitness" || ARGS[5] == "fitness-noise"
        println("Saved: result/$(ARGS[2])/$(ARGS[4])/pdf/$(ARGS[2])-$(ARGS[4])-$(ARGS[1])-$(ARGS[5]).pdf")
        save("result/$(ARGS[2])/$(ARGS[4])/pdf/$(ARGS[2])-$(ARGS[4])-$(ARGS[1])-$(ARGS[5]).pdf", fig)
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function main()
    println("Start the plotting process")
    data = if ARGS[1] == "test"
        mkpath("./result/testdata/pdf/")
        ReadData("./result/testdata/")
    elseif ARGS[5] == "fitness" || ARGS[5] == "fitness-noise"
        mkpath("./result/$(ARGS[2])/$(ARGS[4])/pdf/")
        ReadData("./result/$(ARGS[2])/$(ARGS[4])/")
    end
    
    println("Read data")
    if data == ""
        println("No data to plot. Exiting.")
        
        return
    end
    
    println("Make figure")
    figure, axis = MakeFigure()

    println("Plot data")
    PlotData(data, figure, axis)
    
    println("Save PDF")
    SavePDF(figure)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# try
#     main()
# catch e
#     logger("ERROR", e)

#     global exit_code = 1
# finally
#     logger("INFO", "Finish the plotting process")

#     exit(exit_code)
# end
main()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#