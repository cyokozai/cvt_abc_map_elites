from jinja2 import Environment, FileSystemLoader
import subprocess
import sys

args = sys.argv

COMPOSEFILE = "docker-compose-run.yaml"
FUNCTION = "sphere rosenbrock rastrigin griewank schwefel ackley michalewicz"
MAP_METHOD = "cvt" # "grep", "cvt"
METHOD = ["default", "de", "abc"]
DIMENSION = ""

def generate_yaml(function, method, map, dimention):
    # Jinja2環境を設定
    env = Environment(loader=FileSystemLoader('.'))
    
    # テンプレートファイルをロード
    template = env.get_template('./template/docker-comp.yaml.temp')
    
    # テンプレートに値を埋め込み
    output = template.render(function=function, method=method, map=map, dimention=dimention)
    
    # 結果をファイルに保存
    with open(COMPOSEFILE, 'w') as file:
        file.write(output)

if __name__ == '__main__':
    try:
        if len(args) == 1:
            DIMENSION = "10 20 50 100 200 500 1000"
        elif len(args) > 1 and args[1] == "test":
            DIMENSION = "2"
        else:
            print("Invalid arguments")
            
            exit(1)

        generate_yaml(FUNCTION, METHOD, MAP_METHOD, DIMENSION)
        subprocess.run(['docker', 'compose', '-f', COMPOSEFILE, 'up', '-d', '--build'])
    except Exception as e:
        print(e)
        
        exit(1)