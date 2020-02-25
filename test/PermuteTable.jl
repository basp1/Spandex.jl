using Test
using Spandex

@testset "amd 1" begin
    local g = Graph{Int64}(3)
    g[1, 1] = 6
    g[1, 2] = -4
    g[1, 3] = 7
    g[2, 1] = 4
    g[2, 2] = -3
    g[2, 3] = 0
    g[3, 1] = 1
    g[3, 2] = 2
    g[3, 3] = 5
    local a = from_graph(g, 3, 3)

    local pt = PermuteTable(a)

    @test 3 == length(pt.permuted)
    @test 3 == pt.permuted[1]
    @test 2 == pt.permuted[2]
    @test 1 == pt.permuted[3]

    @test 3 == length(pt.primary)
    @test 3 == pt.primary[1]
    @test 2 == pt.primary[2]
    @test 1 == pt.primary[3]
end

@testset "amd 2" begin
    local g = Graph{Float64}(5)
    g[1, 1] = 0.44561
    g[1, 2] = 0.92962
    g[4, 2] = 0.87043
    g[5, 2] = 0.47918
    g[1, 3] = 0.10582
    g[4, 3] = 0.060281
    g[1, 4] = 0.87256
    g[2, 4] = 0.41421
    g[5, 4] = 0.42161
    g[3, 5] = 0.58921
    g[5, 5] = 0.15305
    g[4, 6] = 0.63730
    local a = from_graph(g, 5, 6)

    local pt = PermuteTable(a)

    @test 5 == pt.permuted[1] || 6 == pt.permuted[1]
    @test 5 == pt.permuted[2] || 6 == pt.permuted[2]

    local uniques = length(unique(pt.permuted))
    @test 6 == uniques

    uniques = length(unique(pt.primary))
    @test 6 == uniques
end
