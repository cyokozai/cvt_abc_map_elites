#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Save data to the result directory                                                            #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using Printf

using Dates

#----------------------------------------------------------------------------------------------------#

include("config.jl")

include("struct.jl")

include("fitness.jl")

include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Make result directory and log file
function MakeFiles()
    open("result/$METHOD/$OBJ_F/$F_RESULT", "w") do fr
        println(fr, "Date: ", DATE)
        println(fr, "Method: ", METHOD)
        if METHOD == "de"
            println(fr, "F: ", F)
            println(fr, "CR: ", CR)
        elseif METHOD == "abc"
            println(fr, "Trial count limit: ", TC_LIMIT)
        end
        println(fr, "Map: ", MAP_METHOD)
        if MAP_METHOD == "grid"
            println(fr, "Grid size: ", GRID_SIZE)
        elseif MAP_METHOD == "cvt"
            println(fr, "Voronoi point: ", k_max)
        end
        println(fr, "Benchmark: ", OBJ_F)
        println(fr, "Dimension: ", D)
        println(fr, "Population size: ", N)
        println(fr, "===================================================================================")
    end

    open("result/$METHOD/$OBJ_F/$F_FITNESS", "w") do ff
        println(ff, "Date: ", DATE)
        println(ff, "Method: ", METHOD)
        if METHOD == "de"
            println(ff, "F: ", F)
            println(ff, "CR: ", CR)
        elseif METHOD == "abc"
            println(ff, "Trial count limit: ", TC_LIMIT)
        end
        println(ff, "Map: ", MAP_METHOD)
        if MAP_METHOD == "grid"
            println(ff, "Grid size: ", GRID_SIZE)
        elseif MAP_METHOD == "cvt"
            println(ff, "Voronoi point: ", k_max)
        end
        println(ff, "Benchmark: ", OBJ_F)
        println(ff, "Dimension: ", D)
        println(ff, "Population size: ", N)
        println(ff, "===================================================================================")
    end

    open("result/$METHOD/$OBJ_F/$F_BEHAVIOR", "w") do fb
        println(fb, "Date: ", DATE)
        println(fb, "Method: ", METHOD)
        if METHOD == "DE"
            println(fb, "F: ", F)
            println(fb, "CR: ", CR)
        elseif METHOD == "ABC"
            println(fb, "Trial count limit: ", TC_LIMIT)
        end
        println(fb, "Map: ", MAP_METHOD)
        if MAP_METHOD == "grid"
            println(fb, "Grid size: ", GRID_SIZE)
        elseif MAP_METHOD == "cvt"
            println(fb, "Voronoi point: ", k_max)
        end
        println(fb, "Benchmark: ", OBJ_F)
        println(fb, "Dimension: ", D)
        println(fb, "Population size: ", N)
        println(fb, "===================================================================================")
    end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Save result
function SaveResult(archive::Archive, iter_time::Float64, run_time::Float64)
    # Log file
    logger("INFO", "Time of iteration: $iter_time [sec]")
    logger("INFO", "Time: $run_time [sec]")

    # Open file
    fr = open("result/$METHOD/$OBJ_F/$F_RESULT", "a")
    ff = open("result/$METHOD/$OBJ_F/$F_FITNESS", "a")
    fb = open("result/$METHOD/$OBJ_F/$F_BEHAVIOR", "a")

    # Write result
    println(ff, "===================================================================================")
    println(ff, "End of Iteration.\n")
    println(fb, "===================================================================================")
    println(fb, "End of Iteration.\n")

    if MAP_METHOD == "grid"
        for i in 1:GRID_SIZE
            for j in 1:GRID_SIZE
                if archive.grid[i, j] > 0
                    println(ff, archive.individuals[archive.grid[i, j]].fitness)
                    println(fb, archive.individuals[archive.grid[i, j]].behavior)
                end
            end
        end
    elseif MAP_METHOD == "cvt"
        for k in keys(archive.individuals)
            if k > 0
                println(ff, archive.individuals[k].fitness)
                println(fb, archive.individuals[k].behavior)
            end
        end
    else
        logger("ERROR", "Map method is invalid")

        exit(1)
    end

    # Close file
    close(fr)
    close(ff)
    close(fb)
    
    logger("INFO", "End of Iteration")

    # Make result list
    arch_list = []
    
    if MAP_METHOD == "grid"
        for i in 1:GRID_SIZE
            for j in 1:GRID_SIZE
                if archive.grid[i, j] > 0
                    push!(arch_list, archive.individuals[archive.grid[i, j]])
                end
            end
        end
    elseif MAP_METHOD == "cvt"
        for k in keys(archive.individuals)
            if k > 0
                push!(arch_list, archive.individuals[k])
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
        println(fr, "Time:              ", run_time, " [sec]")
        println(fr, "The number of solutions: ", length(arch_list))
        println(fr, "The number of regenerated CVT Map: ", cvt_vorn_data_index)
        println(fr, "===================================================================================")
        println(fr, "Top 10 suboptimal solutions:")

        for i in 1:10
            println(fr, "-----------------------------------------------------------------------------------")
            println(fr, "Rank ", i, ": ")
            println(fr, "├── Solution:     ", arch_list[i].genes)
            println(fr, "├── Fitness:      ", arch_list[i].fitness)
            println(fr, "├── True fitness: ", fitness(arch_list[i].genes))
            println(fr, "└── Behavior:     ", arch_list[i].behavior)
        end

        println(fr, "===================================================================================")
        println(fr, "Best solution:     ", best_solution.genes)
        println(fr, "Best fitness:      ", best_solution.fitness)
        println(fr, "True best fitness: ", fitness(best_solution.genes))
        println(fr, "Best behavior:     ", best_solution.behavior)
        println(fr, "===================================================================================")
    end

    println("===================================================================================")
    println("Best solution:     ", best_solution.genes)
    println("Best fitness:      ", best_solution.fitness)
    println("True best fitness: ", fitness(best_solution.genes))
    println("Best behavior:     ", best_solution.behavior)
    println("===================================================================================")
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#