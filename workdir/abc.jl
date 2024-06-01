#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Import library                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
using Printf
using Dates
include("config.jl")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Declare variables                                                                            #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
fu =  5.0
fl = -5.0
trial = zeros(Int, FOODSORCE)
global best_solution = randn(Float64, DIMENSION)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Define module and functions                                                                  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function Formulation(x::Vector{Float64})
    # Rosenbrock function
    return Float64(sum(100.0 * (x[j+1] - x[j]^2)^2 + (x[j] - 1.0)^2 for j = 1 : length(x)-1))
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function fitness(v::Vector{Float64})
    return Float64(1.0 / (Formulation(v) + 0.001))
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function init(flowers::Matrix{Float64})
    for i = 1 : FOODSORCE
        for j = 1 : DIMENSION
            flowers[i, j] = fl + rand()*(fu - fl)
        end 
    end

    return flowers
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function employedBee(flowers::Matrix{Float64})
    k = 0
    v = zeros(Float64, FOODSORCE, DIMENSION)

    for i = 1 : FOODSORCE
        for j = 1 : DIMENSION
            while true
                k = rand(1 : FOODSORCE)

                if k != i
                    break
                end
            end

            v[i, j] = flowers[i, j] + (rand() * 2 - 1.0) * (flowers[i, j] - flowers[k, j])
        end
        flowers[i, :], trial[i] = greedySelection(flowers[i, :], v[i, :], trial[i])
    end

    return flowers
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function onlookerBee(flowers::Matrix{Float64})
    Fsum = sum(fitness(flowers[i, :]) for i = 1 : FOODSORCE)
    p = [fitness(flowers[i, :])/Fsum for i = 1 : FOODSORCE]
    cum_p = 0.0
    k = 0

    new_flowers = zeros(Float64, FOODSORCE, DIMENSION)
    v = zeros(Float64, FOODSORCE, DIMENSION)

    for i = 1 : FOODSORCE
        cum_p += p[i]
        index = roulleteSelection(cum_p)
        new_flowers[i, : ] = flowers[index, :]

        for j = 1 : DIMENSION
            while true
                k = rand(1 : FOODSORCE)

                if k != i
                    break
                end
            end

            v[i, j] = new_flowers[i, j] + (rand() * 2 - 1.0) * (new_flowers[i, j] - new_flowers[k, j])
        end
        flowers[i, :], trial[i] = greedySelection(flowers[i, :], v[i, :], trial[i])
    end

    return flowers
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function scoutBee(flowers::Matrix{Float64})
    if maximum(trial) >= LIMIT
        return init(flowers)
    end

    return flowers
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function greedySelection(f::Vector{Float64}, v::Vector{Float64}, t::Int)
    if fitness(f) < fitness(v)
        if fitness(best_solution) < fitness(v)
            best_solution .= v
        end

        return v, t
    else
        return f, t + 1
    end
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function roulleteSelection(q::Float64)
    index = 1
    r = rand()

    for i = 1 : FOODSORCE
        if r <= q
            index = i
            break
        end
    end

    return index
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function lookScore(g::Int, t::Float64)
    saveData(g, best_solution, fitness(best_solution), t)
    
    println("Generation: ", g)
    @printf("Run Time: %3.03f sec\n", t)
    println("Best solution: ", best_solution)
    @printf("Fitness: %3.03f\n", fitness(best_solution))
    println("===================================================================================")
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function ABC(flowers::Matrix{Float64})
    println("===================================================================================")
    flowers = init(flowers)
    lookScore(0, 0.0)

    for g = 1 : MAXTIME
        start_time = now()

        print("Employed Bee ... ")
        flowers = employedBee(flowers)
        println("OK.")
        print("Onlooker Bee ... ")
        flowers = onlookerBee(flowers)
        println("OK.")
        print("Scout Bee ... ")
        flowers = scoutBee(flowers)
        println("OK.")

        end_time = now()
        
        println("-----------------------------------------------------------------------------------")
        lookScore(g, Dates.value(end_time - start_time) / 1000)

        if abs(fitness(best_solution) - SOLUTION) < ε
            return g
        end
    end

    return MAXTIME
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function saveData(g::Int, val::Vector{Float64}, fit::Float64, t::Float64)
    open(FILENAME, "a") do f
        println(f, "Generation: ", g)
        @printf(f, "Run Time: %5.05f sec\n", t)
        println(f, "Best solution: ", val)
        @printf(f, "Fitness: %5.05f\n", fit)
        println(f, "===================================================================================")
    end
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#