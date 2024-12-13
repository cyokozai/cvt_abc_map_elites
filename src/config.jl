#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Config                                                                                       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using StableRNGs

using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Parameter
# Random seed
SEED      = Int(Dates.now().instant.periods.value)

# Random number generator
RNG       = StableRNG(SEED)

# Number of dimensions
D         = length(ARGS) > 0 && ARGS[1] == "test" ? 2 : parse(Int64, ARGS[1])

# Number of population size
N         = 64

# Dumber of behavior dimensions | No need to change because it isn't available.
BD        = 2

# Number of max time
MAXTIME   = length(ARGS) > 0 && ARGS[1] == "test" ? 100 : 100000

# Number of mutation rate
MUTANT_R  = 0.10

# Convergence flag | 'true' is available when you want to check the convergence.
CONV_FLAG = false

# Epsiron | Default: 1e-6
EPS = 1e-6

# Fitness noise | 'true' is available when you want to add the noise to the fitness.
FIT_NOISE = true

# Noise rate (ε = rand(RNG, -NOIZE_R:NOIZE_R)) | 0.0 < NOIZE_R < 1.0 | Default: 0.20
NOIZE_R   = 0.05

#----------------------------------------------------------------------------------------------------#
# Map parameter
# MAP_METHOD == grid: Number of grid size.
GRID_SIZE = 158

# MAP_METHOD == cvt: Number of max k.
k_max     = 25000

#----------------------------------------------------------------------------------------------------#
# Method
# Objective function: sphere, rosenbrock, rastrigin, griewank, schwefel
OBJ_F      = length(ARGS) > 3 ? ARGS[4] : "griewank"

# MAP Method: grid, cvt
MAP_METHOD = length(ARGS) > 2 ? ARGS[3] : "cvt"

# Method: default, abc, de
METHOD     = length(ARGS) > 1 ? ARGS[2] : "abc"

#----------------------------------------------------------------------------------------------------#
# Voronoi parameter
# Voronoi data update limit
cvt_vorn_data_update_limit = 3

#----------------------------------------------------------------------------------------------------#
# DE parameter
# The crossover probability (default: 0.8).
# The differentiation (mutation) scaling factor (default: 0.9).
CR, F = if OBJ_F == "sphere"
    [0.20, 0.40]
elseif OBJ_F == "rosenbrock"
    [0.70, 0.80]
elseif OBJ_F == "rastrigin"
    [0.50, 0.60]
elseif OBJ_F == "griewank"
    [0.40, 0.50]
elseif OBJ_F == "ackley"
    [0.20, 0.50]
elseif OBJ_F == "schwefel"
    [0.20, 0.50]
elseif OBJ_F == "michalewicz"
    [0.20, 0.50]
else
    [0.80, 0.90]
end

#----------------------------------------------------------------------------------------------------#
# ABC parameter
# Limit number: The number of limit trials that the scout bee can't find the better solution.
TC_LIMIT = floor(Int, k_max / (10 * N)) * D

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Result file
mkpath("./result/$METHOD/$OBJ_F/")
mkpath("./log/")

DATE       = Dates.format(now(), "yyyy-mm-dd-HH-MM")
LOGDATE    = Dates.format(now(), "yyyy-mm-dd")

FILENAME   = length(ARGS) > 0 && ARGS[1] == "test" ? "$DATE-test" : "$DATE-$METHOD-$MAP_METHOD-$OBJ_F-$D"
F_RESULT   = "result-$FILENAME.dat"
F_FITNESS  = "fitness-$FILENAME.dat"
F_FIT_N    = "fitness-noise-$FILENAME.dat"
F_BEHAVIOR = "behavior-$FILENAME.dat"
F_LOGFILE  = "log-$LOGDATE-$METHOD-$OBJ_F.log"

# EXIT CODE: 0: Success, 1: Failure
exit_code = 0

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#