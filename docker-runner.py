from jinja2 import Environment, FileSystemLoader
import subprocess

FILENAME = 'docker-compose-run.yaml'

FUNCTION = [ "sphere", "rastrigin", "rosenbrock", "griewank" ]
METHOD = [ "default", "abc" ]

container_combinations = len(FUNCTION) * len(METHOD)

def generate_yaml(function, method):
    # Jinja2環境を設定
    env = Environment(loader=FileSystemLoader('.'))
    
    # テンプレートファイルをロード
    template = env.get_template('./template/docker-comp.yaml.temp')
    
    # テンプレートに値を埋め込み
    output = template.render(function=function, method=method)
    
    # 結果をファイルに保存
    with open(FILENAME, 'w') as file:
        file.write(output)

if __name__ == '__main__':
    generate_yaml(FUNCTION, METHOD)
    subprocess.run(['docker', 'compose', '-f', FILENAME, 'up', '-d', '--build'])