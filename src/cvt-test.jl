#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       CVT: Centroidal Voronoi Tessellations                                                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

using DelaunayTriangulation
using CairoMakie
# using StableRNGs

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# rng = StableRNG(123)
# points = 25randn(rng, 2, 500)
points = 5randn(Float64, 2, 64)
# push!(points, [5.0 5.0])
# push!(points, [-5.0 -5.0])
# push!(points, [5.0 -5.0])
# push!(points, [-5.0 5.0])
println(points)

tri = triangulate(points)
vorn = voronoi(tri, clip = true)
smooth_vorn = centroidal_smooth(vorn)

# ここに既存のグラフ生成コード
fig = Figure()
ax1 = Axis(fig[1, 1], title = "Original", width = 400, height = 400)
ax2 = Axis(fig[1, 2], title = "Smoothed", width = 400, height = 400)
voronoiplot!(ax1, vorn, colormap = :matter, strokewidth = 2)
voronoiplot!(ax2, smooth_vorn, colormap = :matter, strokewidth = 2)
resize_to_layout!(fig)

# PDFに保存するコード
save("output_graph.pdf", fig)

println(ax1)
println(ax2)