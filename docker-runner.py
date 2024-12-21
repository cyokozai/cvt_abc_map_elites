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
FUNCTION    = ["sphere", "rosenbrock", "rastrigin"]

# grep or cvt
MAP_METHOD  = "cvt"

# default de abc
METHOD      = ["abc"]

# 2 10 50 100 500 1000
DIMENSION   = "10 50 100"

# Loop count
LOOP        = 2

#------ Edit config ------------------------------#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Main                                                                                         #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

def generate_yaml(function, method, map, dimention, loop):
    # Setting Jinja2
    env = Environment(loader=FileSystemLoader('.'))
    
    # Load template
    template = env.get_template('./template/docker-comp.yaml.temp')
    
    loopstr = " ".join(str(i) for i in range(1, loop + 1))
    
    # Render template
    output = template.render(looprange=loopstr, function=function, method=method, map=map, dimention=dimention)
    
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
            DIMENSION = "test"
            FUNCTION = "sphere"
            METHOD = ["default", "de", "abc"]
            MAP_METHOD = "cvt"
            LOOP = 1
            
            print(f"COMPOSEFILE: {COMPOSEFILE}")
            print("==================== TEST MODE ====================")
        else:
            print(f"COMPOSEFILE: {COMPOSEFILE}")
            print(f"FUNCTION: {FUNCTION}")
            print(f"METHOD: {METHOD}")
            print(f"MAP_METHOD: {MAP_METHOD}")
            print(f"LOOP: {LOOP}")

        # generate yaml
        generate_yaml(FUNCTION, METHOD, MAP_METHOD, DIMENSION, LOOP)
        
        # docker compose up
        subprocess.run(['docker', 'compose', '-f', COMPOSEFILE, 'up', '-d', '--build'])
    except Exception as e:
        print(e)
        
        exit(1)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#