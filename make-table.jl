using CSV
using DataFrames
using Statistics

METHOD = ["default", "de", "abc"]

MAP = "cvt"

FUNCTION = ["sphere", "rosenbrock", "rastrigin"]

DIMENSION = ["10", "50", "100"]

function process_dat_files(input_dir::String, method::String, func::String, dim::String)
    # Initialize accumulators for storing fitness values for each rank
    noisy_fitness = Dict(i => [] for i in 1:10)
    true_fitness = Dict(i => [] for i in 1:10)

    # Read all .dat files in the input directory
    for file in filter(x -> endswith(x, ".dat"), [path for path in readdir(input_dir) if occursin("result-", path) && occursin("$(method)-$(MAP)-$(func)-$(dim)", path)]) 
        filepath = joinpath(input_dir, file)
        
        # Open and read the .dat file
        open(filepath, "r") do io
            current_rank = 0
            while !eof(io)
                line = readline(io)
                
                if occursin("Rank", line)
                    current_rank = parse(Int, match(r"Rank (\d+):", line).captures[1])
                elseif occursin("Noisy Fitness", line) && current_rank > 0
                    noisy_value = parse(Float64, split(line, ":")[2])
                    push!(noisy_fitness[current_rank], noisy_value)
                elseif occursin("True Fitness", line) && current_rank > 0
                    true_value = parse(Float64, split(line, ":")[2])
                    push!(true_fitness[current_rank], true_value)
                end
            end
        end
    end

    # Calculate averages for each rank
    results = DataFrame(Rank = 1:3, 
                        Avg_Noisy_Fitness = [mean(noisy_fitness[i]) for i in 1:3],
                        Avg_True_Fitness = [mean(true_fitness[i]) for i in 1:3])

    # Create output directory if it doesn't exist
    output_dir = joinpath(input_dir, "csv")
    if !isdir(output_dir)
        mkpath(output_dir)
    end

    # Write results to a CSV file
    output_file = "output-$(method)-$(func)-$(dim).csv"
    CSV.write(joinpath(output_dir, output_file), results)
end

function make_table(input_file::String, output_file::String, method::String, func::String, dim::String)
    # CSVデータをDataFrameに読み込む
    df = CSV.read(input_file, DataFrame)

    # LaTeXテーブルのヘッダー部分を作成
    header = """
    \\begin{table}[h]
    \\centering
    \\begin{tabular}{r|D{.}{.}{2.4}D{.}{.}{2.4}}
    \\multicolumn{1}{c|}{Rank} & \\multicolumn{1}{c}{Avg\\_Noisy\\_Fitness} & \\multicolumn{1}{c}{Avg\\_True\\_Fitness} \\\\
    \\hline
    \\hline
    """

    # テーブルの行を作成
    rows = join(["$(row.Rank) & $(row.Avg_Noisy_Fitness) & $(row.Avg_True_Fitness) \\\\" for row in eachrow(df)], "\n")

    # LaTeXテーブルのフッター部分を作成
    footer = """
    \\hline
    \\end{tabular}
    \\caption{Rank of $(method) on $(func) (D=$(dim))} 
    \\label{tab:rank-$(method)-$(func)-$(dim)}
    \\end{table}
    """

    # 完全なLaTeXコードを組み立てる
    latex_code = header * rows * footer

    # テキストファイルに書き込む
    if !isdir(output_dir)
        mkpath(output_dir)
    end
    open(output_file, "w") do file
        write(file, latex_code)
    end

    println("LaTeX table has been written to $output_file.")
end

# Example usage:
for method in METHOD
    for func in FUNCTION
        for dim in DIMENSION
            process_dat_files("./result", method, func, dim)
            make_table("./result/csv/output-$(method)-$(func)-$(dim).csv", "./result/latex/table-$(method)-$(func)-$(dim).tex", method, func, dim)
        end
    end
end
