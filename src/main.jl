#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Import library                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Printf
using Dates

#----------------------------------------------------------------------------------------------------#

include("config.jl")
include("savedata.jl")
include("me.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Main                                                                                         #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function main()
    # Make result directory and log file
    MakeFiles()
    
    # Dimension check
    if D == 2
        logger("WARN", "Dimension is default value \"2\"")
    elseif D <= 0
        logger("ERROR", "Dimension is invalid")
        
        exit(1)
    else
        logger("INFO", "Dimension is $D")
    end
    
    # Convergence mode check
    if CONV_FLAG
        logger("INFO", "Convergence flag is true")
    else
        logger("INFO", "Convergence flag is false")
    end
    
    println("Method: ", METHOD)
    println("Map: ", MAP_METHOD)
    println("Objective function: ", OBJ_F)
    println("Dimension: ", D)
    println("===================================================================================")

    #------MAP ELITES ALGORITHM------------------------------#

    begin_time = time()

    popn, arch, iter_time = map_elites()
    
    finish_time = time()

    #------MAP ELITES ALGORITHM------------------------------#

    elapsed_time = finish_time - begin_time
    
    println("===================================================================================")
    println("End of Iteration.\n")
    println("Time of iteration: ", iter_time, " [sec]")
    println("Time:              ", elapsed_time, " [sec]")

    SaveResult(arch, iter_time, elapsed_time)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Run                                                                                          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# try
    global exit_code = 0

    logger("INFO", "Start")
    println("Start")
    
    main()

#     logger("INFO", "Success! :)")
#     println("Success! :)")
# catch e
#     global exit_code = 1

#     logger("ERROR", "An error occurred! :(\n$e")
#     println("An error occurred! :(\n$e")
# finally
#     logger("INFO", "Finish")
#     println("Finish")

#     exit(exit_code)
# end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#