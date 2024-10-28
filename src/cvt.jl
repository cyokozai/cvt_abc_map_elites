#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       CVT: Centroidal Voronoi Tessellations                                                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using DelaunayTriangulation
using LinearAlgebra
using StableRNGs
using Serialization
using Dates

#----------------------------------------------------------------------------------------------------#

include("config.jl")
include("struct.jl")
include("fitness.jl"
)
include("logger.jl")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Voronoi tessellation
vorn = nothing

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Initialize the CVT
function init_CVT(population::Population)
    global vorn

    I = population.individuals

    points = [rand(RNG, BD) .* (UPP - LOW) .+ LOW for _ in 1:k_max-N]
    behavior = [I[i].behavior for i in 1:N]
    append!(points, behavior)

    vorn = centroidal_smooth(voronoi(triangulate(points; rng = RNG), clip = false); maxiters = 1000, rng = RNG)
    serialize("result/CVT-$F_RESULT.dat", vorn)

    logger("INFO", "CVT is initialized")
    return DelaunayTriangulation.get_generators(vorn)::Dict{Int64, Tuple{Float64, Float64}}
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function cvt_mapping(population::Population, archive::Archive)
    global vorn

    I = population.individuals
    Centroidal_polygon_list = DelaunayTriangulation.get_generators(vorn)
    
    for (index, ind) in enumerate(I)
        distances = [norm([ind.behavior[1] - centroid[1], ind.behavior[2] - centroid[2]], 2) for centroid in values(Centroidal_polygon_list)]
        closest_centroid_index = argmin(distances)
        
        if haskey(archive.area, closest_centroid_index)
            if archive.area[closest_centroid_index] == 0
                archive.area[closest_centroid_index] = index
            elseif ind.fitness >= I[archive.area[closest_centroid_index]].fitness
                archive.area[closest_centroid_index] = index
            end
        end
    end

    return archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#