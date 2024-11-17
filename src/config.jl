#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Config                                                                                       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using StableRNGs
using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Parameter
exit_code = 0
SEED      = Int(Dates.now().instant.periods.value)
RNG       = StableRNG(SEED)

D         = if length(ARGS) > 0 parse(Int64, ARGS[1]) else 2 end # Number of dimensions.
N         = 64     # Number of population size.
BD        = 2      # Dumber of behavior dimensions | No need to change because it isn't available.
MAXTIME   = 100000 # Number of max time.
MUTANT_R  = 0.10   # Number of mutation rate.
ε         = 1.0e-6 # Number of epsilon.

CONV_FLAG = true # Convergence flag | 'true' is available when you want to check the convergence.
FIT_NOISE = true # Fitness noise | 'true' is available when you want to add the noise to the fitness.
NOIZE_R   = 0.10 # Noise rate. | 0.0 < NOIZE_R < 1.0

#----------------------------------------------------------------------------------------------------#
# Map parameter
GRID_SIZE = 158   # Number of grid size.
k_max     = 25000 # Number of max k.

#----------------------------------------------------------------------------------------------------#
# Method
OBJ_F      = if length(ARGS) > 3 ARGS[4] else "sphere" end  # Objective function: sphere, rosenbrock, rastrigin, griewank, schwefel
MAP_METHOD = if length(ARGS) > 2 ARGS[3] else "grid" end    # Method: grid, cvt
METHOD     = if length(ARGS) > 1 ARGS[2] else "default" end # Method: default, abc, de

#----------------------------------------------------------------------------------------------------#
# Result file
mkpath("./result/$METHOD/$OBJ_F/")
mkpath("./log/")

DATE       = Dates.format(now(), "yyyy-mm-dd-HH-MM")
LOGDATE    = Dates.format(now(), "yyyy-mm-dd")
FILENAME   = "$DATE-$METHOD-$MAP_METHOD-$OBJ_F-$D"
F_RESULT   = "result-$FILENAME.dat"
F_FITNESS  = "fitness-$FILENAME.dat"
F_BEHAVIOR = "behavior-$FILENAME.dat"
F_LOGFILE  = "log-$LOGDATE-$METHOD-$OBJ_F.log"

#----------------------------------------------------------------------------------------------------#
# Voronoi parameter
vorn = nothing
cvt_vorn_data_index = 0

#----------------------------------------------------------------------------------------------------#
# DE parameter
# The crossover probability (default: 0.8).
# The differentiation (mutation) scaling factor (default: 0.9).
CR, F = if OBJ_F == "sphere" && METHOD == "DE"
    [0.01, 0.50]
elseif OBJ_F == "rosenbrock" && METHOD == "DE"
    [0.75, 0.70]
elseif OBJ_F == "rastrigin" && METHOD == "DE"
    [0.001, 0.50]
elseif OBJ_F == "griewank" && METHOD == "DE"
    [0.20, 0.50]
elseif OBJ_F == "ackley" && METHOD == "DE"
    [0.20, 0.50]
elseif OBJ_F == "schwefel" && METHOD == "DE"
    [0.20, 0.50]
elseif OBJ_F == "michalewicz" && METHOD == "DE"
    [0.20, 0.50]
else
    [0.8, 0.9]
end

#----------------------------------------------------------------------------------------------------#
# ABC parameter
TC_LIMIT = N * D      # Limit number that scout bee can search.
trial = zeros(Int, N) # ABC Trial

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#