#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Import library                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Printf
using Dates
using ProtoBuf

#----------------------------------------------------------------------------------------------------#

include("config.jl")
include("me.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Main                                                                                         #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function main()
    # Make 
    open("result/$METHOD/$OBJ_F/$F_RESULT", "w") do fr
        println(fr, "Date: ", DATE)
        println(fr, "Method: ", METHOD)
        println(fr, "Map: ", MAP_METHOD)
        println(fr, "Objective function: ", OBJ_F)
        println(fr, "Dimension: ", D)
        println(fr, "===================================================================================")
    end

    open("result/$METHOD/$OBJ_F/$F_FITNESS", "w") do ff
        println(ff, "Date: ", DATE)
        println(ff, "Method: ", METHOD)
        println(ff, "Map: ", MAP_METHOD)
        println(ff, "Objective function: ", OBJ_F)
        println(ff, "Dimension: ", D)
        println(ff, "===================================================================================")
    end

    open("result/$METHOD/$OBJ_F/$F_BEHAVIOR", "w") do fb
        println(fb, "Date: ", DATE)
        println(fb, "Method: ", METHOD)
        println(fb, "Map: ", MAP_METHOD)
        println(fb, "Objective function: ", OBJ_F)
        println(fb, "Dimension: ", D)
        println(fb, "===================================================================================")
    end
    
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
    
    #------MAP ELITES ALGORITHM------------------------------#
    
    println("Method: ", METHOD)
    println("Map: ", MAP_METHOD)
    println("Objective function: ", OBJ_F)
    println("Dimension: ", D)
    println("===================================================================================")

    begin_time = time()

    popn, arch, iter_time = map_elites()

    finish_time = time()

    println("===================================================================================")
    println("End of Iteration.\n")
    println("Time of iteration: ", iter_time, " [sec]")
    println("Time:              ", (finish_time - begin_time), " [sec]")
    
    #------MAP ELITES ALGORITHM------------------------------#
    
    logger("INFO", "Time of iteration: $iter_time sec")
    logger("INFO", "Time: $(finish_time - begin_time) sec")

    # Make result list
    arch_list = []
    if MAP_METHOD == "grid"
        for i in 1:GRID_SIZE
            for j in 1:GRID_SIZE
                if arch.grid[i, j] !== nothing
                    push!(arch_list, popn.individuals[arch.grid[i, j]])
                end
            end
        end
    elseif MAP_METHOD == "cvt"
        for v in values(arch.area)
            if v > 0
                push!(arch_list, popn.individuals[v])
            end
        end
    else
        logger("ERROR", "Map method is invalid")

        exit(1)
    end

    sort!(arch_list, by = x -> x.fitness, rev = true)

    open("result/$METHOD/$OBJ_F/$F_RESULT", "a") do fr
        println(fr, "End of Iteration.\n")
        println(fr, "Time of iteration: ", iter_time, " [sec]")
        println(fr, "Time:              ", (finish_time - begin_time), " [sec]")
        println(fr, "===================================================================================")
        println(fr, "Top 10 solutions:")

        for i in 1:10
            println(fr, "-----------------------------------------------------------------------------------")
            println(fr, "Rank ", i, ": ")
            println(fr, "├── Solution: ", arch_list[i].genes)
            println(fr, "├── Fitness:  ", arch_list[i].fitness)
            println(fr, "└── Behavior: ", arch_list[i].behavior)
        end

        println(fr, "===================================================================================")
        println(fr, "Best solution: ", best_solution.genes)
        println(fr, "Best fitness:  ", best_solution.fitness)
        println(fr, "Best behavior: ", best_solution.behavior)
        println(fr, "===================================================================================")
    end

    println("===================================================================================")
    println("Best solution: ", best_solution.genes)
    println("Best fitness:  ", best_solution.fitness)
    println("Best behavior: ", best_solution.behavior)
    println("===================================================================================")
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Run                                                                                          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

try
    logger("INFO", "Start")
    println("Start")

    main()

    logger("INFO", "Success! :)")
    println("Success! :)")
catch e
    global exit_code = 1

    logger("ERROR", "An error occurred! :(\n$e")
    println("An error occurred! :(")
    println(e)
finally
    logger("INFO", "Finish")
    println("Finish")

    exit(exit_code)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#