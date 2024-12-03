#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Config                                                                                       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using StableRNGs

using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Parameter
# EXIT CODE: 0 = Success, 1 = Failure
exit_code = 0

# Random seed
SEED      = Int(Dates.now().instant.periods.value)

# Random number generator
RNG       = StableRNG(SEED)

# Number of dimensions
D         = if length(ARGS) > 0 && ARGS[1] != "test" parse(Int64, ARGS[1]) else 2 end

# Number of population size
N         = 64

# Dumber of behavior dimensions | No need to change because it isn't available.
BD        = 2

# Number of max time
MAXTIME   = 100000

# Number of mutation rate
MUTANT_R  = 0.10

# Convergence flag | 'true' is available when you want to check the convergence.
CONV_FLAG = true

# Fitness noise | 'true' is available when you want to add the noise to the fitness.
FIT_NOISE = true

# Noise rate (ε = rand(RNG, -NOIZE_R:NOIZE_R)) | 0.0 < NOIZE_R < 1.0 | Default: 0.10
NOIZE_R   = 0.10

#----------------------------------------------------------------------------------------------------#
# Map parameter
# Number of grid size.
GRID_SIZE = 158

# Number of max k.
k_max     = 25000

#----------------------------------------------------------------------------------------------------#
# Method
# Objective function: sphere, rosenbrock, rastrigin, griewank, schwefel
OBJ_F      = if length(ARGS) > 3 ARGS[4] else "sphere" end

# MAP Method: grid, cvt
MAP_METHOD = if length(ARGS) > 2 ARGS[3] else "cvt" end

# Method: default, abc, de
METHOD     = if length(ARGS) > 1 ARGS[2] else "default" end

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
# Voronoi diagram
vorn = nothing

# Voronoi data update
cvt_vorn_data_update = 0

# Voronoi data update limit
cvt_vorn_data_update_limit = 3

#----------------------------------------------------------------------------------------------------#
# DE parameter
# The crossover probability (default: 0.8).
# The differentiation (mutation) scaling factor (default: 0.9).
CR, F = if OBJ_F == "sphere"
    [0.10, 0.30]
elseif OBJ_F == "rosenbrock"
    [0.75, 0.70]
elseif OBJ_F == "rastrigin"
    [0.01, 0.50]
elseif OBJ_F == "griewank"
    [0.20, 0.50]
elseif OBJ_F == "ackley"
    [0.20, 0.50]
elseif OBJ_F == "schwefel"
    [0.20, 0.50]
elseif OBJ_F == "michalewicz"
    [0.20, 0.50]
else
    [0.8, 0.9]
end

#----------------------------------------------------------------------------------------------------#
# ABC parameter
# Limit number: The number of limit trials that the scout bee can't find the better solution.
TC_LIMIT = floor(Int, k_max / N)

# ABC Trial
trial    = zeros(Int, N)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#