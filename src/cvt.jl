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
function init_CVT(population::Population)
    global vorn, cvt_vorn_data_index

    points = [rand(RNG, BD) .* (UPP - LOW) .+ LOW for _ in 1:k_max-N]
    behavior = [population.individuals[i].behavior for i in 1:N]
    append!(points, behavior)

    vorn = centroidal_smooth(voronoi(triangulate(points; rng = RNG), clip = false); maxiters = 1000, rng = RNG)
    
    serialize("result/$METHOD/$OBJ_F/CVT-$FILENAME-$cvt_vorn_data_index", vorn)
    cvt_vorn_data_index += 1
    
    logger("INFO", "CVT is initialized")
    return DelaunayTriangulation.get_generators(vorn)::Dict{Int64, Tuple{Float64, Float64}}
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function cvt_mapping(population::Population, archive::Archive)
    global vorn

    Centroidal_polygon_list = DelaunayTriangulation.get_generators(vorn)
    
    for (index, ind) in enumerate(population.individuals)
        distances = [norm([ind.behavior[1] - centroid[1], ind.behavior[2] - centroid[2]], 2) for centroid in values(Centroidal_polygon_list)]
        closest_centroid_index = argmin(distances)
        
        if haskey(archive.area, closest_centroid_index)
            if ind.fitness >= archive.individuals[archive.area[closest_centroid_index]].fitness || archive.area[closest_centroid_index] == 0
                archive.area[closest_centroid_index] = index
                archive.individuals[index].genes = deepcopy(ind.genes)
                archive.individuals[index].fitness = ind.fitness
                archive.individuals[index].behavior = deepcopy(ind.behavior)
            end
        end
    end

    return archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#