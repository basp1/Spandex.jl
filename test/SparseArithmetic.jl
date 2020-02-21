using Test
using Spandex

@testset "add 1" begin
    local g = Graph{Int64}(3)
    g[1, 2] = 5
    g[1, 3] = 6
    g[2, 1] = 1
    g[2, 2] = 4
    g[2, 3] = 7
    g[3, 1] = 2
    g[3, 2] = 3
    g[3, 3] = 8
    local a = from_graph(g, 3, 3)

    clear!(g)
    g[1, 1] = -1
    g[1, 3] = 1
    g[2, 1] = -1
    g[2, 3] = 1
    g[3, 1] = -1
    g[3, 3] = 1
    local b = from_graph(g, 3, 3)

    clear!(g)
    g[1, 1] = -1
    g[1, 2] = 5
    g[1, 3] = 7
    g[2, 1] = 0
    g[2, 2] = 4
    g[2, 3] = 8
    g[3, 1] = 1
    g[3, 2] = 3
    g[3, 3] = 9
    local e = from_graph(g, 3, 3)

    local c = add(a, b)

    @test !equals(a, c)
    @test !equals(b, c)
    @test equals(e, c)
end

@testset "mul 1" begin
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

    clear!(g)
    g[1, 1] = 6
    g[1, 2] = 3
    g[2, 1] = -1
    g[2, 2] = 4
    g[3, 1] = 8
    g[3, 2] = -3
    local b = from_graph(g, 3, 2)

    clear!(g)
    g[1, 1] = 96
    g[1, 2] = -19
    g[2, 1] = 27
    g[2, 2] = 0
    g[3, 1] = 44
    g[3, 2] = -4
    local e = from_graph(g, 3, 2)

    local c = mul(a, b)

    @test !equals(a, c)
    @test !equals(b, c)
    @test equals(e, c)
end

@testset "mul 2" begin
    local g = Graph{Int64}(3)
    g[1, 1] = 1
    g[1, 3] = 3
    g[2, 2] = 5
    g[3, 2] = 8
    local a = from_graph(g, 3, 3)

    clear!(g)
    g[1, 2] = 2
    g[1, 3] = 3
    g[2, 1] = 4
    g[2, 3] = 6
    g[3, 1] = 7
    g[3, 2] = 8
    local b = from_graph(g, 3, 3)

    clear!(g)
    g[1, 1] = 21
    g[1, 2] = 26
    g[1, 3] = 3
    g[2, 1] = 20
    g[2, 3] = 30
    g[3, 1] = 32
    g[3, 3] = 48
    local e = from_graph(g, 3, 3)

    local c = mul(a, b)

    @test !equals(a, c)
    @test !equals(b, c)
    @test equals(e, c)
end

@testset "mul 3" begin
    local g = Graph{Int64}(3)
    g[1, 1] = 1
    g[1, 3] = 3
    g[2, 2] = 5
    g[3, 2] = 8
    local a = from_graph(g, 3, 3)

    clear!(g)
    g[1, 1] = 6
    g[2, 1] = -1
    g[3, 1] = 8
    local b = from_graph(g, 3, 1)

    clear!(g)
    g[1, 1] = 30
    g[2, 1] = -5
    g[3, 1] = -8
    local e = from_graph(g, 3, 1)

    local c = mul(a, b)

    @test !equals(a, c)
    @test !equals(b, c)
    @test equals(e, c)
end

@testset "sqr 1" begin
    local g = Graph{Int64}(3)
    g[1, 2] = 1
    g[2, 1] = 2
    g[3, 2] = 3
    local a = from_graph(g, 3, 2)

    local ata = sqr_sym(a)

    @test 2 == ata.nnz
    @test contains(ata, 1, 1)
    @test contains(ata, 2, 2)
end

@testset "sqr 2" begin
    local g = Graph{Float64}(4)
    g[2, 5] = 0.02675
    g[3, 1] = 0.78664
    g[4, 1] = 0.26856
    g[4, 4] = 0.51423
    g[4, 6] = 0.46234
    local a = from_graph(g, 4, 6)

    resize!(g, 6)
    g[1, 1] = 0.69094
    g[4, 1] = 0.1381
    g[4, 4] = 0.26444
    g[5, 5] = 0.00072
    g[6, 1] = 0.12417
    g[6, 4] = 0.23775
    g[6, 6] = 0.21376
    local e = from_graph(g, 6, 6)

    local ata = sqr_sym(a)

    @test 12 == ata.nnz
    @test contains(ata, 1, 1)
    @test contains(ata, 2, 2)
    @test contains(ata, 3, 3)
    @test contains(ata, 4, 1)
    @test contains(ata, 4, 4)
    @test contains(ata, 5, 5)
    @test contains(ata, 6, 1)
    @test contains(ata, 6, 4)
    @test contains(ata, 6, 6)
    @test contains(ata, 1, 4)
    @test contains(ata, 1, 6)
    @test contains(ata, 4, 6)
end

@testset "sqr 3" begin
    local g = Graph{Int64}(3)
    g[1, 2] = 1
    g[2, 1] = 2
    g[3, 2] = 3
    local a = from_graph(g, 3, 2)

    clear!(g)
    g[1, 1] = 4
    g[2, 2] = 10
    local e = from_graph(g, 2, 2)

    local ata = sqr(a)

    @test equals(ata, e)

    local e2 = mul(transpose(a), a)

    @test equals(ata, e2)
end

@testset "sqr 4" begin
    local g = Graph{Float64}(4)
    g[2, 5] = 0.02674817948
    g[3, 1] = 0.7866442604
    g[4, 1] = 0.2685635172
    g[4, 4] = 0.5142332896
    g[4, 6] = 0.462339404
    local a = from_graph(g, 4, 6)

    resize!(g, 6)
    g[1, 1] = 0.6909355552
    g[2, 2] = 0.
    g[3, 3] = 0.
    g[4, 1] = 0.13810430091
    g[4, 4] = 0.2644358761
    g[5, 5] = 0.0007154651053
    g[6, 1] = 0.1241674965
    g[6, 4] = 0.2377503126
    g[6, 6] = 0.2137577245
    g[1, 4] = 0.13810430091
    g[1, 6] = 0.1241674965
    g[4, 6] = 0.2377503126
    local e = from_graph(g, 6, 6)

    local ata = sqr(a)

    ata.values = round.(ata.values, digits = 8)
    e.values = round.(ata.values, digits = 8)

    @test equals(ata, e)
end
