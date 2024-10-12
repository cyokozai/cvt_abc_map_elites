from jinja2 import Environment, FileSystemLoader
import subprocess
import sys

args = sys.argv

FILENAME = 'docker-compose-run.yaml'

FUNCTION = [ "sphere", "rosenbrock"] #  "sphere", "rastrigin", "rosenbrock", "griewank" 
METHOD = [ "default", "abc" ]
DIMENSION = "2"

container_combinations = len(FUNCTION) * len(METHOD)

def generate_yaml(function, method, dimention):
    # Jinja2環境を設定
    env = Environment(loader=FileSystemLoader('.'))
    
    # テンプレートファイルをロード
    template = env.get_template('./template/docker-comp.yaml.temp')
    
    # テンプレートに値を埋め込み
    output = template.render(function=function, method=method, dimention=dimention)
    
    # 結果をファイルに保存
    with open(FILENAME, 'w') as file:
        file.write(output)

if __name__ == '__main__':
    if len(args) == 1:
        DIMENSION = "'10' '20' '50' '100' '200' '500' '1000'"
    elif len(args) > 1 and args[1] == "test":
        DIMENSION = "2"
    else:
        print("Invalid arguments")
        exit(1)
    
    generate_yaml(FUNCTION, METHOD, DIMENSION)
    subprocess.run(['docker', 'compose', '-f', FILENAME, 'up', '-d', '--build'])