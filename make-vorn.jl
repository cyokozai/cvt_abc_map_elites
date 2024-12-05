load_path = [path for path in readdir("result/$(ARGS[2])/$(ARGS[4])/") if occursin("CVT-", path) && occursin("-$(ARGS[3])-", path) && occursin("-$(ARGS[4])-$(ARGS[1])-", path)]
println("$dir$load_path[end]")
load_vorn = load("$dir$load_path[end]", "voronoi")

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

for (i, f) in enumerate((filepath[end:-1:1]))
    if occursin(".jld2", f)
        open("$dir$f", "r") do io
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
end

for d in data
    scatter!(axis, [d[1]], [d[2]], marker = 'x', markersize = 14, color = :blue)
end