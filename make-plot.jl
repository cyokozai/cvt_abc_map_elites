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
        [Axis(
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
            width = 480,
        )]
    else
        [Axis(
            fig[1, 1],
            limits = ((0, MAXTIME), (1.0e-6, 1.0e+4)),
            xlabel=L"\text{Generation} \quad (\times 10^4)",
            ylabel=L"\text{Fitness}",
            xticks=(0:2*10^4:MAXTIME, string.([0, 2, 4, 6, 8, 10])),
            xminorticks = IntervalsBetween(2),
            yscale=log10,
            yticks=(10.0 .^ (-6.0:2.0:6.0), string.(["1.0e-06", "1.0e-04", "1.0e-02", "1.0e+00", "1.0e+02", "1.0e+04", "1.0e+06"])),
            yminorticks = IntervalsBetween(5),
            width = 480,
        ),
        Axis(
            fig[1, 2],
            limits = ((0, MAXTIME), (1.0e-6, 1.0e+4)),
            xlabel=L"\text{Generation} \quad (\times 10^4)",
            ylabel=L"\text{Noised Fitness}",
            xticks=(0:2*10^4:MAXTIME, string.([0, 2, 4, 6, 8, 10])),
            xminorticks = IntervalsBetween(2),
            yscale=log10,
            yticks=(10.0 .^ (-6.0:2.0:6.0), string.(["1.0e-06", "1.0e-04", "1.0e-02", "1.0e+00", "1.0e+02", "1.0e+04", "1.0e+06"])),
            yminorticks = IntervalsBetween(5),
            width = 480,
        )]
    end
    
    resize_to_layout!(fig)
    
    return fig, ax
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function ReadData(dir::String)
    println("Read data: $dir")
    mlist = ["default", "de", "abc", "default", "de", "abc"]
    Data = Dict{String, Array{Float64, 2}}()
    if ARGS[1] == "test"
        filepath = [path for path in readdir(dir) if occursin("$(ARGS[1])", path) && occursin("fitness", path)]
        data = Array{Float64, 2}(undef, length(filepath), MAXTIME)

        if length(filepath) == 0
            println("No such file: $ARGS")
            
            return nothing
        else            
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
                                        data[i, j] = 1.0e+2
                                    else
                                        data[i, j] = 1.0/parsed_value - 1.0
                                    end
                                    
                                    j += 1
                                end
                            end
                        end
                    end
                end
            end
        end

        Data["test"] = data
    else
        for (m, method) in enumerate(mlist)
            filepath = if m <= 3
                [path for path in readdir("$(dir)$(method)/$(ARGS[2])/") if occursin("-$(ARGS[1])", path) && occursin("$(ARGS[2])", path) && occursin("fitness-2", path)]
            else
                [path for path in readdir("$(dir)$(method)/$(ARGS[2])/") if occursin("-$(ARGS[1])", path) && occursin("$(ARGS[2])", path) && occursin("fitness-noise-2", path)]
            end
            data = Array{Float64, 2}(undef, length(filepath), MAXTIME)

            if length(filepath) == 0
                println("No such file: $ARGS")
                
                return nothing
            else
                for (i, f) in enumerate(filepath)
                    if occursin(".dat", f)
                        j, reading_data = 1, false
                        
                        open("$(dir)$(method)/$(ARGS[2])/$f", "r") do io # ファイルを開く
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
                                            data[i, j] = 1.0e+2
                                        else
                                            data[i, j] = 1.0/parsed_value - 1.0
                                        end
                                        
                                        j += 1
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if m <= 3
                Data["$(method)"] = data
            else
                Data["$(method)-noised"] = data
            end
        end
    end
    
    return Data
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function PlotData(Data, fig, axis)
    for (key, data) in Data
        sum_data = zeros(size(data, 2))
        
        for j in 1:size(data, 1)
            sum_data .+= data[j, :] # Sum data
            println("$(key) $(j)")
        end
        
        average_data = sum_data ./ Float64(size(data, 1)) # Calculate average data
        
        # 負の値をフィルタリング
        average_data = filter(x -> x > 0, average_data)
        
        if key == "test" || key == "default"
            lines!(axis[1], 1:length(average_data), average_data, linestyle=:solid, linewidth=1.2, color=:red)
        elseif key == "de"
            lines!(axis[1], 1:length(average_data), average_data, linestyle=:solid, linewidth=1.2, color=:blue)
        elseif key == "abc"
            lines!(axis[1], 1:length(average_data), average_data, linestyle=:solid, linewidth=1.2, color=:green)
        elseif key == "default-noised"
            lines!(axis[2], 1:length(average_data), average_data, linestyle=:dash,  linewidth=1.0, color=:red)
        elseif key == "de-noised"
            lines!(axis[2], 1:length(average_data), average_data, linestyle=:dash,  linewidth=1.0, color=:blue)
        elseif key == "abc-noised"
            lines!(axis[2], 1:length(average_data), average_data, linestyle=:dash,  linewidth=1.0, color=:green)
        end
    end

    resize_to_layout!(fig)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function SavePDF(fig)
    if ARGS[1] == "test"
        println("Saved: result/testdata/pdf/testdata.pdf")
        save("result/testdata/pdf/fitness-testdata.pdf", fig)
    else
        println("Saved: result/pdf/$(ARGS[2])-$(ARGS[1]).pdf")
        save("result/pdf/$(ARGS[2])-$(ARGS[1]).pdf", fig)
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function main()
    println("Start the plotting process")
    data = if ARGS[1] == "test"
        mkpath("./result/testdata/pdf/")
        ReadData("./result/testdata/")
    else
        mkpath("./result/pdf/")
        ReadData("./result/")
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