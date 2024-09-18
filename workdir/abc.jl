# ABC: Artificial Bee Colony
using LinearAlgebra
using Statistics
using Random

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

include("config.jl")
include("benchmark/benchmark.jl")
include("struct.jl")

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

function employee_bee(archive::Archive)
    k = 0
    v = zeros(Float64, FOODSORCE, N)

    for i = 1 : FOODSORCE
        for j = 1 : N
            while true
                k = rand(1 : FOODSORCE)

                if k != i
                    break
                end
            end

            v[i, j] = archive[i, j] + (rand() * 2 - 1.0) * (archive[i, j] - archive[k, j])
        end

        archive[i, :], trial[i] = greedySelection(archive[i, :], v[i, :], trial[i])
    end

    return archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function onlooker_bee(archive::Archive)
    Fsum = sum(fitness(archive[i, :]) for i = 1 : FOODSORCE)
    p = [fitness(archive[i, :])/Fsum for i = 1 : FOODSORCE]
    cum_p = 0.0
    k = 0

    new_archive = zeros(Float64, FOODSORCE, DIMENSION)
    v = zeros(Float64, FOODSORCE, DIMENSION)

    for i = 1 : FOODSORCE
        cum_p += p[i]
        index = roulleteSelection(cum_p)
        new_archive[i, : ] = archive[index, :]

        for j = 1 : DIMENSION
            while true
                k = rand(1 : FOODSORCE)

                if k != i
                    break
                end
            end

            v[i, j] = new_archive[i, j] + (rand() * 2 - 1.0) * (new_archive[i, j] - new_archive[k, j])
        end
        archive[i, :], trial[i] = greedySelection(archive[i, :], v[i, :], trial[i])
    end

    return archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function ABC(archive::Archive)
    print("Employed Bee ... ")
    archive = employedBee(archive)
    println("OK.")
    print("Onlooker Bee ... ")
    archive = onlookerBee(archive)
    println("OK.")

    return archive
end
