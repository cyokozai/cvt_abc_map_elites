import numpy as np

def generate_increasing_fitness(total_length=100000):
    fitness = 0.0
    
    # フォーマットされた出力を生成
    output = "=" * 83 + "\n"
    
    
    for _ in range(total_length):
        random_values = np.random.uniform(0.0, 1.0, 10)
        
        if min(random_values) > fitness and np.random.random() < 0.001:
            fitness += min(random_values) / (max(random_values) + fitness)
        elif max(random_values) < fitness and np.random.random() < 0.001:
            fitness += min(random_values) / (max(random_values) + fitness)
        
        if fitness >= 1.0:
            fitness = 1.0
        
        output += f"{fitness}\n"
    
    output += "=" * 83 + "\n"
    output += "End of Iteration.\n"
    
    return output


# ダミーデータ生成
fitness_output = generate_increasing_fitness()

# 結果をファイルに保存（任意）
with open("./src/result/.testdata/fitness-test-0.dat", "w") as file:
    file.write(fitness_output)

# コンソールに一部表示
print(fitness_output[:100])  # 最初の1000文字のみ表示
