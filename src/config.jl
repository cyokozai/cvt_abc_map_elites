#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# parameter
D         = if length(ARGS) > 2 parse(Int64, ARGS[3]) else 2 end   # Number of dimensions
N         = 64     # Number of population size
GRID_SIZE = 64     # Number of grid size
BD        = 2      # Dumber of behavior dimensions
MAXTIME   = 100000 # Number of max time
MUT_RATE  = 0.10   # Number of mutation rate
ε         = 1.0e-6 # Number of epsilon

#----------------------------------------------------------------------------------------------------#
# DE parameter
F = 0.30

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