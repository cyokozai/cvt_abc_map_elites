#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       CVT: Centroidal Voronoi Tessellations                                                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using DelaunayTriangulation
using CairoMakie
using StableRNGs
using LinearAlgebra
using Dates

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
UPP =  100.0
LOW = -100.0
D = 2

seed = Int(Dates.now().instant.periods.value)
rng = StableRNG(seed)
points = [rand(rng, D) .* (UPP - LOW) .+ LOW for _ in 1:25000]
append!(points, [[UPP, UPP], [UPP, LOW], [LOW, UPP], [LOW, LOW]])

println(points)

tri = triangulate(points; rng)
vorn = voronoi(tri, clip = true)
smooth_vorn = centroidal_smooth(vorn; maxiters = 1000, rng = rng)

# ここに既存のグラフ生成コード
fig = Figure()
ax = Axis(fig[1, 1], xlabel = L"b_1", ylabel = L"b_2", title = "Smoothed", width = 400, height = 400)
voronoiplot!(ax, smooth_vorn, colormap = :matter, strokewidth = 1)
xlims!(ax, LOW, UPP)
ylims!(ax, LOW, UPP)
resize_to_layout!(fig)

# PDFに保存するコード
save("output_graph.pdf", fig)

Centroidal_point_list = DelaunayTriangulation.get_polygon_points(smooth_vorn)
Centroidal_polygon_list = DelaunayTriangulation.get_generators(smooth_vorn)
println(Centroidal_point_list)
println(Centroidal_polygon_list)
println(typeof(Centroidal_point_list))
println(typeof(Centroidal_polygon_list))

instance = rand(rng, D) .* (UPP - LOW) .+ LOW
println(instance)

distances = [norm([instance[1] - centroid[1], instance[2] - centroid[2]], 2) for centroid in Centroidal_point_list]
closest_centroid_index = argmin(distances)
closest_centroid = Centroidal_point_list[closest_centroid_index]

println("The point $instance is closest to the centroid at $closest_centroid, which corresponds to polygon index $closest_centroid_index.")
