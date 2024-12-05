#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Import library                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

from jinja2 import Environment, FileSystemLoader

import subprocess

import sys

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Config                                                                                       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#------ Edit config ------------------------------#
# docker-compose file name
COMPOSEFILE = "docker-compose-run.yaml"

# sphere rosenbrock rastrigin griewank schwefel ackley michalewicz
FUNCTION    = "sphere rosenbrock rastrigin"

# grep or cvt
MAP_METHOD  = "cvt"

# default de abc
METHOD      = ["default", "de", "abc"]

# 2 10 50 100 500 1000
DIMENSION   = "10 50 100 500 1000"

# Loop count
LOOP       = 20

#------ Edit config ------------------------------#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Main                                                                                         #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

def generate_yaml(function, method, map, dimention, loop):
    # Setting Jinja2
    env = Environment(loader=FileSystemLoader('.'))
    
    # Load template
    template = env.get_template('./template/docker-comp.yaml.temp')
    
    for i in range(1, loop + 1):
        LOOP = f"{i} "
    
    print(f"LOOP: {LOOP}")
    
    # Render template
    output = template.render(function=function, method=method, map=map, dimention=dimention, loop=LOOP)
    
    # Write to file
    with open(COMPOSEFILE, 'w') as file:
        file.write(output)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Run                                                                                          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

if __name__ == '__main__':
    try:
        args = sys.argv
        
        if len(args) > 1 and args[1] == "test":
            DIMENSION = "2"
        else:
            print("Invalid arguments")
            
            exit(1)

        # generate yaml
        generate_yaml(FUNCTION, METHOD, MAP_METHOD, DIMENSION, LOOP)
        
        # docker compose up
        subprocess.run(['docker', 'compose', '-f', COMPOSEFILE, 'up', '-d', '--build'])
    except Exception as e:
        print(e)
        
        exit(1)