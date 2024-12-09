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
    [path for path in readdir(dir) if occursin("test-", path) && occursin("CVT-", path)]
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

loadpath = joinpath(dir, load_path[end])
println(loadpath)
load_vorn = load(loadpath, "voronoi")

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

filepath = if ARGS[1] == "test"
    dir = "./result/testdata/"
    if !isdir(dir)
        error("Directory $dir does not exist.")
    end
    [path for path in readdir(dir) if occursin("test-", path) && occursin("behavior-", path)]
else
    dir = "./result/$(ARGS[2])/$(ARGS[4])/"
    if !isdir(dir)
        error("Directory $dir does not exist.")
    end
    [path for path in readdir(dir) if occursin("behavior-", path) && occursin("-$(ARGS[3])-", path) && occursin("-$(ARGS[4])-$(ARGS[1])-", path)]
end

Data = Vector{Tuple{Float64, Float64}}()  # Change the type to Vector{Tuple{Float64, Float64}}

for (i, f) in enumerate(filepath) # Change this line to iterate over readdir(dir) directly
    if occursin(".dat", f)
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
                    match = match(r"\[(-?\d+\.\d+),\s*(-?\d+\.\d+)\]", line)  # Use regex to extract two floats
                    if match !== nothing
                        x = parse(Float64, match.captures[1])
                        y = parse(Float64, match.captures[2])
                        push!(Data, (x, y))  # Push the tuple (x, y)
                    end
                end
            end
        end
    end
end

for d in Data  # Change this line to iterate over Data
    scatter!(ax, [d[1]], [d[2]], marker = 'x', markersize = 14, color = :blue)
end

# # JLD2ファイルからデータを読み込む
# function load_voronoi_data(filepath::String)
#     data = load(filepath)

#     return data["voronoi"]
# end

# # Voronoi図を生成する関数
# function plot_voronoi(voronoi_data, output_path::String)
#     fig = Figure()
#     ax = Axis(fig[1, 1], limits = ((LOW, UPP), (LOW, UPP)), xlabel = L"b_1", ylabel = L"b_2", title = "Voronoi Diagram", width = 500, height = 500)
#     voronoiplot!(ax, voronoi_data, colormap = :matter, strokewidth = 0.1, show_generators = false)
#     resize_to_layout!(fig)
#     save(output_path, fig)
# end

# # メイン処理
# function main()
#     if length(ARGS) < 2
#         println("Usage: julia make-vorn.jl <input_file> <output_file>")

#         return 1
#     end

#     input_file = ARGS[1]
#     output_file = ARGS[2]

#     voronoi_data = load_voronoi_data(input_file)
#     plot_voronoi(voronoi_data, output_file)
# end

# main()