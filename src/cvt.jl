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
include("fitness.jl")
include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Initialize the CVT
function init_cvt()
    global vorn

    vorn = centroidal_smooth(voronoi(triangulate([rand(RNG, D) .* (UPP - LOW) .+ LOW for _ in 1:k_max]; RNG), clip = false); maxiters = 1000, rng = RNG)
    serialize("result/CVT-F_RESULT.dat", vorn)

    return DelaunayTriangulation.get_generators(vorn)::Dict{Int64, Tuple{Float64, Float64}}
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function cvt_mapping(population::Population, archive::Archive)
    global vorn
    ind = population.individuals
    Centroidal_polygon_list = DelaunayTriangulation.get_generators(vorn)

    for (index, behavior) in enumerate(ind.behavior)
        distances = [norm([behavior[1] - centroid[1], behavior[2] - centroid[2]], 2) for centroid in values(Centroidal_polygon_list)]
        closest_centroid_index = argmin(distances)
        archive[closest_centroid_index] = index
    end

    return archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

vorn::VoronoiTessellation = init_cvt()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#