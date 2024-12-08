#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Make vorn                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using JLD2

using DelaunayTriangulation

using CairoMakie

#----------------------------------------------------------------------------------------------------#

include("config.jl")

include("benchmark.jl")

include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

load_path = if ARGS[1] == "test"
    dir = "./result/testdata/"
    if !isdir(dir)
        error("Directory $dir does not exist.")
    end
    [path for path in readdir(dir) if occursin("CVT", path) && occursin("test", path)]
else
    dir = "./result/$(ARGS[2])/$(ARGS[4])/"
    if !isdir(dir)
        error("Directory $dir does not exist.")
    end
    [path for path in readdir(dir) if occursin("CVT-", path) && occursin("-$(ARGS[3])-", path) && occursin("-$(ARGS[4])-$(ARGS[1])-", path)]
end

if isempty(load_path)
    error("No files found matching the criteria.")
end

filepath = joinpath(dir, load_path[end])
println(filepath)
load_vorn = load(filepath, "voronoi")

fig = Figure()  # Add this line to define fig

ax = Axis(
    fig[1, 1],
    limits = ((LOW, UPP), (LOW, UPP)),
    xlabel = L"b_1",
    ylabel = L"b_2",
    title="CVT Map and plotted behavior: $METHOD",
    width = 500,
    height = 500
)

voronoiplot!(ax, load_vorn, colormap = :matter, strokewidth = 0.1, show_generators = false)

Data = Vector{Tuple{Float64, Float64}}[]

for f in readdir(dir)  # Change this line to iterate over readdir(dir) directly
    if occursin(".jld2", f)
        open(joinpath(dir, f), "r") do io  # Use joinpath to construct the full path
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
                        push!(Data, (k, line_value))  # Change to push a tuple (k, line_value)
                    end
                end
            end
        end
    end
end

for d in Data  # Change this line to iterate over Data
    scatter!(ax, [d[1]], [d[2]], marker = 'x', markersize = 14, color = :blue)
end

# JLD2ファイルからデータを読み込む
function load_voronoi_data(filepath::String)
    data = load(filepath)

    return data["voronoi"]
end

# Voronoi図を生成する関数
function plot_voronoi(voronoi_data, output_path::String)
    fig = Figure()
    ax = Axis(fig[1, 1], limits = ((LOW, UPP), (LOW, UPP)), xlabel = L"b_1", ylabel = L"b_2", title = "Voronoi Diagram", width = 500, height = 500)
    voronoiplot!(ax, voronoi_data, colormap = :matter, strokewidth = 0.1, show_generators = false)
    resize_to_layout!(fig)
    save(output_path, fig)
end

# メイン処理
function main()
    if length(ARGS) < 2
        println("Usage: julia make-vorn.jl <input_file> <output_file>")

        return 1
    end

    input_file = ARGS[1]
    output_file = ARGS[2]

    voronoi_data = load_voronoi_data(input_file)
    plot_voronoi(voronoi_data, output_file)
end

main()