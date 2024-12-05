#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Import struct                                                                                #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Individual
mutable struct Individual
    genes::Vector{Float64}           # N dimension vector
    fitness::Tuple{Float64, Float64} # Fitness value (1: with noise, 2: without noise)
    behavior::Vector{Float64}        # Behavior space
end

#----------------------------------------------------------------------------------------------------#
# Population
mutable struct Population
    individuals::Vector{Individual} # Group of individuals
end

#----------------------------------------------------------------------------------------------------#
# Archive
mutable struct Archive
    grid::Matrix{Int64}                  # Grid map
    grid_update_counts::Vector{Int64}    # Grid update counts
    individuals::Dict{Int64, Individual} # Individuals
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#