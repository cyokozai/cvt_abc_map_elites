#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       CVT: Centroidal Voronoi Tessellations                                                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using DelaunayTriangulation
using LinearAlgebra
using CairoMakie
using StableRNGs
using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
UPP =  100.0
LOW = -100.0
D   = 2
kmax= 100

seed = Int(Dates.now().instant.periods.value)
rng = StableRNG(seed)
points = [rand(rng, D) .* (UPP - LOW) .+ LOW for _ in 1:kmax]
append!(points, [[UPP, UPP], [UPP, LOW], [LOW, UPP], [LOW, LOW]])

smooth_vorn = centroidal_smooth(voronoi(triangulate(points; rng), clip = false); maxiters = 1000, rng = rng)

# println(typeof(smooth_vorn))

Centroidal_point_list = DelaunayTriangulation.get_polygon_points(smooth_vorn)
Centroidal_polygon_list = DelaunayTriangulation.get_generators(smooth_vorn)

# println(typeof(Centroidal_point_list))
# println(typeof(Centroidal_polygon_list))

# println(Centroidal_polygon_list)

# ここに既存のグラフ生成コード
fig = Figure()

# ax1 = Axis(fig[1, 1], limits = ((LOW, UPP), (LOW, UPP)), xlabel = L"b_1", ylabel = L"b_2", width = 400, height = 400)
# voronoiplot!(ax1, smooth_vorn, color = :white, strokewidth = 0.1, show_generators = false)
# resize_to_layout!(fig)

ax2 = Axis(fig[1, 1], limits = ((LOW+10, UPP-10), (LOW+10, UPP-10)), xlabel = L"b_1", ylabel = L"b_2", width = 400, height = 400)
voronoiplot!(ax2, smooth_vorn, color = :white, strokewidth = 1.0, show_generators = true)
resize_to_layout!(fig)

# for _ in 1:50
#     instance = rand(rng, D) .* (UPP - LOW) .+ LOW
#     println(instance)

#     distances = [norm([instance[1] - centroid[1], instance[2] - centroid[2]], 2) for centroid in Centroidal_point_list]
#     closest_centroid_index = argmin(distances)
#     closest_centroid = Centroidal_point_list[closest_centroid_index]

#     println("The point $instance is closest to the centroid at $closest_centroid, which corresponds to polygon index $closest_centroid_index.")

#     scatter!(ax2, [instance[1]], [instance[2]], markersize = 20, color = :black)
# end

resize_to_layout!(fig)

# PDFに保存するコード
save("/root/src/result/testdata/pdf/output_graph.svg", fig)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#