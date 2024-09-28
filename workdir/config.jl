#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# parameter
D         = 1000   # Number of dimensions
BD        = 2      # Dumber of behavior dimensions
N         = 1000   # Number of population size
GRID_SIZE = 32     # Number of grid size
MAXTIME   = 1000   # Number of max time
MUT_RATE  = 0.10   # Number of mutation rate
ε         = 1.0e-6 # Number of epsilon

#----------------------------------------------------------------------------------------------------#
# DE parameter
F = 0.3 # DE parameter

#----------------------------------------------------------------------------------------------------#
# ABC parameter
ABC_LIMIT = N * D # Limit number that scout bee can search

#----------------------------------------------------------------------------------------------------#
# Method: default, abc, de, cvt, cvt-de
METHOD = if length(ARGS) > 0 ARGS[1] else "default" end

# Objective function: sphere, rosenbrock, rastrigin, griewank, schwefel
OBJ_F = if length(ARGS) > 1 ARGS[2] else "sphere" end

# Result file
DATE     = Dates.format(now(), "yyyy.mm.dd.HH.MM.SS")
FILENAME = "result-$DATE-$METHOD-$OBJ_F.dat"
LOGDATE  = Dates.format(now(), "yyyy-mm-dd")
LOGFILE  = "log-$LOGDATE-$METHOD-$OBJ_F.log"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#