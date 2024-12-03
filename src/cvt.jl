#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       CVT: Centroidal Voronoi Tessellations                                                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using DelaunayTriangulation

using LinearAlgebra

using StableRNGs

using FileIO

using JLD2

using Dates

#----------------------------------------------------------------------------------------------------#

include("config.jl")

include("struct.jl")

include("logger.jl")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Initialize the CVT
function init_CVT(population::Population)
    global vorn, cvt_vorn_data_update
    
    points = [rand(RNG, BD) .* (UPP - LOW) .+ LOW for _ in 1:k_max-N]
    behavior = [population.individuals[i].behavior for i in 1:N]
    append!(points, behavior)

    vorn = centroidal_smooth(voronoi(triangulate(points; rng = RNG), clip = false); maxiters = 1000, rng = RNG)
    
    save("result/$METHOD/$OBJ_F/CVT-$FILENAME-$cvt_vorn_data_update.jld2", "voronoi", vorn)
    
    cvt_vorn_data_update += 1
    
    logger("INFO", "CVT is initialized")
    return DelaunayTriangulation.get_generators(vorn)::Dict{Int64, Tuple{Float64, Float64}}
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# CVT mapping
function cvt_mapping(population::Population, archive::Archive)
    global vorn
    
    Centroidal_polygon_list = DelaunayTriangulation.get_generators(vorn)
    
    for ind in population.individuals
        distances = [norm([ind.behavior[1] - centroid[1], ind.behavior[2] - centroid[2]], 2) for centroid in values(Centroidal_polygon_list)]
        closest_centroid_index = argmin(distances)

        if haskey(archive.individuals, closest_centroid_index)
            if ind.fitness > archive.individuals[closest_centroid_index].fitness
                archive.individuals[closest_centroid_index] = Individual(deepcopy(ind.genes), ind.fitness, deepcopy(ind.behavior))
                archive.grid_update_counts[closest_centroid_index] += 1
            end
        else
            archive.individuals[closest_centroid_index] = Individual(deepcopy(ind.genes), ind.fitness, deepcopy(ind.behavior))
            archive.grid_update_counts[closest_centroid_index] += 1
        end
    end
    
    return archive
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#