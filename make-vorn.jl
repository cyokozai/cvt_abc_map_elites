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
    global LOW, UPP = -5.12, 5.12
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

    [path for path in readdir(dir) if occursin("CVT-", path) && occursin("$(ARGS[5])", path) && occursin("-$(ARGS[3])-", path) && occursin("-$(ARGS[4])-", path)]
end

if isempty(load_path)
    error("No files found matching the criteria.")
end

loadpath = joinpath(dir, load_path[end])
println(loadpath)

load_vorn = load(loadpath, "voronoi")
Centroidal_polygon_list = DelaunayTriangulation.get_generators(load_vorn)

filepath = if ARGS[1] == "test"
    dir = "./result/testdata/"
    if !isdir(dir)
        error("Directory $dir does not exist.")
    end
    
    [path for path in readdir(dir) if occursin("test-", path) && occursin("result-", path)]
else
    dir = "./result/$(ARGS[2])/$(ARGS[4])/"
    if !isdir(dir)
        error("Directory $dir does not exist.")
    end

    [path for path in readdir(dir) if occursin("result-", path) && occursin("$(ARGS[5])", path)]
end

Data = Vector{Int64}()  # Change the type to Vector{Int64}
BestPoint = Vector{Tuple{Float64, Float64}}()  # Change the type to Vector{Tuple{Float64, Float64}}

for f in filepath
    if occursin(".dat", f)
        open(joinpath(dir, f), "r") do io  # Use joinpath to construct the full path
            reading_data = false # ボーダーライン検出用フラグ
            border_count = 0  # ボーダーラインのカウント
            
            for (k, line) in enumerate(eachline(io)) # ファイルを1行ずつ読み込む
                if occursin("=", line) # ボーダーラインを検出
                    border_count += 1
                    if border_count == 1 # 1つ目のボーダーラインに到達したらデータ読み取り開始
                        reading_data = true
                        continue
                    elseif border_count == 2
                        reading_data = false
                        continue
                    end
                end
                
                if reading_data
                    parsed_value = tryparse(Int64, line)
                    
                    if parsed_value !== nothing && parsed_value >= 0
                        push!(Data, parsed_value)  # Use push! to add elements to Data
                    end
                elseif occursin("Best behavior:", line)
                    m = Base.match(r"\[(-?\d+\.\d+),\s*(-?\d+\.\d+)\]", line)  # Use regex to extract two floats
                    if m !== nothing
                        x, y = parse(Float64, m.captures[1]), parse(Float64, m.captures[2])
                        push!(BestPoint, (x, y))
                        break
                    end
                end
            end
        end
    end
end       

fig = Figure()  # Add this line to define fig

ax = [Axis(
    fig[1, 1],
    limits = ((LOW, UPP), (LOW, UPP)),
    xlabel = L"b_1",
    ylabel = L"b_2",
    width=500,
    height=500
),
Axis(
    fig[1, 3],
    limits = ((LOW * 0.2, UPP * 0.2), (LOW * 0.2, UPP * 0.2)),
    xlabel = L"b_1",
    ylabel = L"b_2",
    width=500,
    height=500
)]

if !isempty(Data)
    colormap = cgrad(:heat)
    colors = [colormap[round(Int, (d - minimum(Data)) / (maximum(Data) - minimum(Data)) * (length(colormap) - 1) + 1)] for d in Data]  # Normalize Data values to colormap indices

    Colorbar(
        fig[1, 2],
        limits = (0, maximum(Data)),
        ticks=(0:maximum(Data)/4:maximum(Data), string.([0, "", "", "", maximum(Data)])),
        colormap = :heat,
        highclip = :red,
        lowclip = :white,
        label = "Update frequency"
    )
    Colorbar(
        fig[1, 4],
        limits = (0, maximum(Data)),
        ticks=(0:maximum(Data)/4:maximum(Data), string.([0, "", "", "", maximum(Data)])),
        colormap = :heat,
        highclip = :red,
        lowclip = :white,
        label = "Update frequency"
    )

    voronoiplot!(
        ax[1],
        load_vorn,
        color = colors,
        strokewidth = 0.01,
        show_generators = false,
        clip = (LOW, UPP, LOW, UPP)
    )
    voronoiplot!(
        ax[2],
        load_vorn,
        color = colors,
        strokewidth = 0.06,
        show_generators = false,
        clip = (LOW * 0.2, UPP * 0.2, LOW * 0.2, UPP * 0.2)
    )
else
    println("Data is empty. Skipping color mapping and plotting.")

    exit(1)
end

resize_to_layout!(fig)

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

    [path for path in readdir(dir) if occursin("behavior-", path) && occursin("$(ARGS[5])", path)]
end

Data = Vector{Tuple{Float64, Float64}}()  # Change the type to Vector{Tuple{Float64, Float64}}

for (i, f) in enumerate(filepath) # Change this line to iterate over readdir(dir) directly
    if occursin(".dat", f)
        open(joinpath(dir, f), "r") do io  # Use joinpath to construct the full path
            reading_data = false # ボーダーライン検出用フラグ
            border_count = 0  # ボーダーラインのカウント
            
            for (k, line) in enumerate(eachline(io)) # ファイルを1行ずつ読み込む
                if occursin("=", line) # ボーダーラインを検出
                    border_count += 1
                    if border_count == 2 # 2つ目のボーダーラインに到達したらデータ読み取り開始
                        reading_data = true
                        continue
                    end
                end
                
                if reading_data
                    m = Base.match(r"\[(-?\d+\.\d+),\s*(-?\d+\.\d+)\]", line)  # Use regex to extract two floats
                    if m !== nothing
                        x, y = parse(Float64, m.captures[1]), parse(Float64, m.captures[2])

                        push!(Data, (x, y))
                    end
                end
            end
        end
    end
end

for d in Data  # Change this line to iterate over Data
    scatter!(ax[1], [d[1]], [d[2]], marker = :circle, markersize = 7, color = (:blue, 0.6))
    scatter!(ax[2], [d[1]], [d[2]], marker = :circle, markersize = 14, color = (:blue, 0.6))
end

scatter!(ax[1], BestPoint, marker = :star5, markersize = 20, color = :green)
scatter!(ax[2], BestPoint, marker = :star5, markersize = 50, color = :green)

resize_to_layout!(fig)

if ARGS[1] == "test"
    println("Saved: result/testdata/pdf/testdata.pdf")
    save("result/testdata/pdf/behavior-testdata.pdf", fig)
else
    println("Saved: result/$(ARGS[2])/$(ARGS[4])/pdf/$(ARGS[2])-$(ARGS[4])-$(ARGS[1])-$(ARGS[5]).pdf")
    save("result/$(ARGS[2])/$(ARGS[4])/pdf/$(ARGS[2])-$(ARGS[4])-$(ARGS[1])-$(ARGS[5]).pdf", fig)
end

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