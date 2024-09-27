#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Import library                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Printf
using Dates

include("config.jl")
include("me.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Main                                                                                         #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function main()
    open("result/$FILENAME", "w") do f
        println(f, "Date: ", DATE)
        println(f, "Config")
        println(f, "===================================================================================")
    end

    begin_time = time()

    popn, arch = map_elites()

    finish_time = time()

    println("===================================================================================")
    println("Finish!")
    println("Time: ", (finish_time - begin_time), " sec")
    
    arch_list = []
    for i in 1:GRID_SIZE
        for j in 1:GRID_SIZE
            if arch.grid[i, j] !== nothing
                push!(arch_list, arch.grid[i, j])
            end
        end
    end
    arch_list = sort(arch_list, by = x -> x.fitness, rev = true)

    open("result/$FILENAME", "a") do f
        println(f, "===================================================================================")
        println(f, "Finish!")
        println(f, "Time: ", (finish_time - begin_time), " sec")
        println(f, "===================================================================================")
        println(f, "Top 10 solutions:")
        
        for i in 1:10
            println(f, "Rank ", i, ": ")
            println(f, " Solution: ", arch_list[i].genes)
            println(f, " Fitness:  ", arch_list[i].fitness)
            println(f, " Behavior: ", arch_list[i].behavior)
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

main()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#