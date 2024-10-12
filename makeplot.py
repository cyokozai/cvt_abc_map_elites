import matplotlib.pyplot as plt
import sys

ARGS = sys.argv

# datファイルを読み込む関数
def read_dat_file(filename):
    with open(filename, "r") as file:
        return file.readlines()

# 世代数と評価値を抽出する関数
def extract_generation_and_fitness(data_lines):
    generations = []
    fitness_values = []
    
    for line in data_lines:
        if "Generation:" in line:
            generations.append(int(line.split()[1]))  # 世代数を抽出
        if "Now best fitness:" in line:
            fitness_values.append(float(line.split()[3]))  # 評価値を抽出
    
    return generations, fitness_values

# ファイル名からグラフのタイトルを抽出する関数
def extract_title_from_filename(filename):
    # ファイル名を分割して、必要な部分を抽出
    parts = filename.split("-")
    # "default", "rosenbrock", "10" を結合してタイトルに
    return f"{parts[2]} {parts[3]} {parts[4].split('.')[0]}"

# datファイルを読み込んでプロットを作成する
def plot_fitness_over_generations(filename):
    # データを読み込む
    data_lines = read_dat_file(filename)
    
    # 世代数と評価値を抽出
    generations, fitness_values = extract_generation_and_fitness(data_lines)
    
    TITLE = extract_title_from_filename(filename)
    
    # プロットを作成
    plt.plot(generations, fitness_values)
    plt.xlabel("Generation")
    plt.ylabel("Best Fitness")
    plt.title(TITLE)
    
    # プロットをPDFに保存
    plt.savefig(filename.replace(".dat", ".pdf"))
    plt.close()

if __name__ == '__main__':
    if len(ARGS) != 2:
        raise ValueError("Invalid arguments")
    elif ARGS[1].split(".")[-1] != "dat":
        raise ValueError("Invalid file format")
    else:
        # datファイルを使ってプロット
        plot_fitness_over_generations(ARGS[1])
