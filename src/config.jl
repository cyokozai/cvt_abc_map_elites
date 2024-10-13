#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# parameter
D         = if length(ARGS) > 2 parse(Int64, ARGS[3]) else 2 end   # Number of dimensions
N         = 64     # Number of population size
GRID_SIZE = 64     # Number of grid size
BD        = 2      # Dumber of behavior dimensions | No need to change because it isn't available.
MAXTIME   = 100000 # Number of max time
MUT_RATE  = 0.10   # Number of mutation rate
ε         = 1.0e-6 # Number of epsilon
CONV_FLAG = false  # Convergence flag | 'true' is available when you want to check the convergence.
RNG       = StableRNG(123) # Random number generator

#----------------------------------------------------------------------------------------------------#
# DE parameter
F = 0.30

#----------------------------------------------------------------------------------------------------#
# ABC parameter
ABC_LIMIT = N * D # Limit number that scout bee can search

#----------------------------------------------------------------------------------------------------#

METHOD = if length(ARGS) > 0 ARGS[1] else "default" end # Method: default, abc, de, cvt, cvt-de
MAP_METHOD = "cvt" # Method: grid, cvt
OBJ_F = if length(ARGS) > 1 ARGS[2] else "sphere" end # Objective function: sphere, rosenbrock, rastrigin, griewank, schwefel

# Result file
DATE    = Dates.format(now(), "yyyy-mm-dd-HH-MM")
LOGDATE = Dates.format(now(), "yyyy-mm-dd")
F_RESULT   = "result-$DATE-$METHOD-$OBJ_F-$D.dat"
F_FITNESS  = "fitness-$DATE-$METHOD-$OBJ_F-$D.dat"
F_BEHAVIOR = "behavior-$DATE-$METHOD-$OBJ_F-$D.dat"
F_LOGFILE  = "log-$LOGDATE-$METHOD-$OBJ_F.log"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#