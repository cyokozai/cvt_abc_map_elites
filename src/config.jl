#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Config                                                                                       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using StableRNGs
using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Parameter
SEED      = Int(Dates.now().instant.periods.value)
RNG       = StableRNG(SEED)

D         = if length(ARGS) > 0 parse(Int64, ARGS[1]) else 2 end # Number of dimensions.
N         = 64     # Number of population size.
BD        = 2      # Dumber of behavior dimensions | No need to change because it isn't available.
MAXTIME   = 10 # Number of max time.
MUT_RATE  = 0.10   # Number of mutation rate.
ε         = 1.0e-6 # Number of epsilon.
CONV_FLAG = false  # Convergence flag | 'true' is available when you want to check the convergence.

#----------------------------------------------------------------------------------------------------#
# Map parameter
GRID_SIZE = 158   # Number of grid size.
k_max     = 25000 # Number of max k.

#----------------------------------------------------------------------------------------------------#
# DE parameter
CR = 0.80 # The crossover probability (default: 0.8).
F  = 0.90 # The differentiation (mutation) scale factor (default: 0.9).

#----------------------------------------------------------------------------------------------------#
# ABC parameter
ABC_LIMIT = N * D # Limit number that scout bee can search.

#----------------------------------------------------------------------------------------------------#
# Method
OBJ_F      = if length(ARGS) > 3 ARGS[4] else "sphere" end  # Objective function: sphere, rosenbrock, rastrigin, griewank, schwefel
MAP_METHOD = if length(ARGS) > 2 ARGS[3] else "cvt" end    # Method: grid, cvt
METHOD     = if length(ARGS) > 1 ARGS[2] else "de" end # Method: default, abc, de, cvt, cvt-de

#----------------------------------------------------------------------------------------------------#
# Result file
DATE    = Dates.format(now(), "yyyy-mm-dd-HH-MM")
LOGDATE = Dates.format(now(), "yyyy-mm-dd")
F_RESULT   = "result-$DATE-$METHOD-$OBJ_F-$D.dat"
F_FITNESS  = "fitness-$DATE-$METHOD-$OBJ_F-$D.dat"
F_BEHAVIOR = "behavior-$DATE-$METHOD-$OBJ_F-$D.dat"
F_LOGFILE  = "log-$LOGDATE-$METHOD-$OBJ_F.log"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#