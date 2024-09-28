#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Import library                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Printf
using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("config.jl")
include("benchmark.jl")
include("me.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Main                                                                                         #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function main()
    open("result/$FILENAME", "w") do f
        println(f, "Date: ", DATE)
        println(f, "Method: ", METHOD)
        println(f, "Objective function: ", OBJ_F)
        println(f, "===================================================================================")
    end
    
    println("Method: ", METHOD)
    println("Objective function: ", OBJ_F)

    begin_time = time()

    popn, arch = map_elites()

    finish_time = time()

    println("===================================================================================")
    println("Finish!")
    println("Time: ", finish_time - begin_time, " sec")
    
    logger("INFO", "$(finish_time - begin_time) sec")

    arch_list = []

    for i in 1:GRID_SIZE
        for j in 1:GRID_SIZE
            if arch.grid[i, j] !== nothing
                push!(arch_list, popn.individuals[arch.grid[i, j]])
            end
        end
    end

    arch_list = sort(arch_list, by = x -> x.fitness, rev = true)

    open("result/$FILENAME", "a") do f
        println(f, "===================================================================================")
        println(f, "Finish!")
        println(f, "Time: ", finish_time - begin_time, " sec")
        println(f, "===================================================================================")
        println(f, "Top 10 solutions:")

        for i in 1:10
            println(f, "-----------------------------------------------------------------------------------")
            println(f, "Rank ", i, ": ")
            println(f, "├── Solution: ", arch_list[i].genes)
            println(f, "├── Fitness:  ", arch_list[i].fitness)
            println(f, "└── Behavior: ", arch_list[i].behavior)
        end

        println(f, "===================================================================================")
        println(f, "Best solution: ", best_solution.genes)
        println(f, "Best fitness:  ", best_solution.fitness)
        println(f, "Best behavior: ", best_solution.behavior)
        println(f, "===================================================================================")
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Run                                                                                          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# try
    logger("INFO", "Start")

    main()

    logger("INFO", "Finish")
# catch
#     logger("ERROR", "An error occurred! :(")
# end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#