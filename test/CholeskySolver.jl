using Test
using Spandex

@testset "cholesky 1" begin
    local g = Graph{Int64}(3)
    g[1, 1] = 6
    g[2, 1] = 8
    g[2, 2] = 27
    g[3, 1] = 14
    g[3, 2] = 27
    g[3, 3] = 41
    local ata = from_graph(g, 3, 3)
    ata.layout = Spandex.lower_symmetric

    local solver = CholeskySolver{Int64}(3, 3)
    local b = cholesky_sym(solver, ata)

    @test 6 == b.nnz

    @test contains(b, 1, 1)
    @test contains(b, 2, 1)
    @test contains(b, 2, 2)
    @test contains(b, 3, 1)
    @test contains(b, 3, 2)
    @test contains(b, 3, 3)
end

@testset "cholesky 2" begin
    local g = Graph{Int64}(11)
    g[1, 1] = 1
    g[2, 2] = 2
    g[3, 2] = 3
    g[3, 3] = 3
    g[4, 4] = 4
    g[5, 5] = 5
    g[6, 1] = 6
    g[6, 4] = 6
    g[6, 6] = 6
    g[7, 1] = 7
    g[7, 7] = 7
    g[8, 2] = 8
    g[8, 5] = 8
    g[8, 8] = 8
    g[9, 6] = 9
    g[9, 9] = 9
    g[10, 3] = 10
    g[10, 4] = 10
    g[10, 6] = 10
    g[10, 8] = 10
    g[10, 10] = 10
    g[11, 3] = 11
    g[11, 5] = 11
    g[11, 7] = 11
    g[11, 8] = 11
    g[11, 10] = 11
    g[11, 11] = 11
    local ata = from_graph(g, 11, 11)
    ata.layout = Spandex.lower_symmetric

    local solver = CholeskySolver{Int64}(11, 11)
    local b = cholesky_sym(solver, ata)

    @test 33 == b.nnz

    @test contains(b, 7, 6)
    @test contains(b, 8, 3)
    @test contains(b, 9, 7)
    @test contains(b, 10, 7)
    @test contains(b, 10, 9)
    @test contains(b, 11, 9)
end
