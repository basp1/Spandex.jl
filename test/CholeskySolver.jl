using Test
using Spandex

@testset "cholesky_sym 1" begin
    local g = Graph{Int64}(3)
    g[1, 1] = 6
    g[2, 1] = 8
    g[2, 2] = 27
    g[3, 1] = 14
    g[3, 2] = 27
    g[3, 3] = 41
    local ata = from_graph(g, 3, 3)
    ata.layout = Spandex.lower_symmetric

    local b = cholesky_sym(ata)

    @test 6 == b.nnz

    @test contains(b, 1, 1)
    @test contains(b, 2, 1)
    @test contains(b, 2, 2)
    @test contains(b, 3, 1)
    @test contains(b, 3, 2)
    @test contains(b, 3, 3)
end

@testset "cholesky_sym 2" begin
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

    local b = cholesky_sym(ata)

    @test 33 == b.nnz

    @test contains(b, 7, 6)
    @test contains(b, 8, 3)
    @test contains(b, 9, 7)
    @test contains(b, 10, 7)
    @test contains(b, 10, 9)
    @test contains(b, 11, 9)
end

@testset "cholesky_to! 1" begin
    local g = Graph{Float64}(3)
    g[1, 1] = 6.0
    g[2, 1] = 8.0
    g[2, 2] = 27.0
    g[3, 1] = 14.0
    g[3, 2] = 27.0
    g[3, 3] = 41.0
    local ata = from_graph(g, 3, 3)
    ata.layout = Spandex.lower_symmetric

    clear!(g)
    g[1, 1] = 6.0
    g[2, 1] = 1.0 + 1.0 / 3.0
    g[2, 2] = 16.0 + 1.0 / 3.0
    g[3, 1] = 2.0 + 1.0 / 3.0
    g[3, 2] = 0.510204081632653
    g[3, 3] = 4.08163265306122
    local e = from_graph(g, 3, 3)
    e.layout = Spandex.lower_symmetric

    local ld = cholesky_sym(ata)
    cholesky_to!(ata, ld)

    ld.values = round.(ld.values, digits = 8)
    e.values = round.(e.values, digits = 8)

    @test equals(ld, e)
end

@testset "cholesky_to! 2" begin
    local g = Graph{Float64}(5)
    g[1, 1] = 0.454154210872255
    g[2, 1] = 0.493313382040145
    g[2, 2] = 0.673117517240105
    g[3, 1] = 0.0
    g[3, 2] = 0.267770063806461
    g[3, 3] = 0.753202118586013
    g[4, 1] = 0.597779567627811
    g[4, 2] = 0.650049443659237
    g[4, 3] = 0.337426886372401
    g[4, 4] = 1.72955430012221
    g[5, 1] = 0.0939734363675742
    g[5, 2] = 0.0200830025404996
    g[5, 3] = 0.0
    g[5, 4] = 0.25140727798654
    g[5, 5] = 0.527264476708613
    local ata = from_graph(g, 5, 5)
    ata.layout = Spandex.lower_symmetric

    clear!(g)
    g[1, 1] = 0.454154210872255
    g[2, 1] = 1.08622439301549
    g[2, 2] = 0.137268488267129
    g[3, 1] = 0.0
    g[3, 2] = 1.95070308697049
    g[3, 3] = 0.230862228520464
    g[4, 1] = 1.31624799091856
    g[4, 2] = 0.00529397289085283
    g[4, 3] = 1.45545384824111
    g[4, 4] = 0.453678241855123
    g[5, 1] = 0.206919663228681
    g[5, 2] = -0.597320167013766
    g[5, 3] = 0.692813459608376
    g[5, 4] = -0.2306541683174
    g[5, 5] = 0.323895344304452
    local e = from_graph(g, 5, 5)
    e.layout = Spandex.lower_symmetric

    local ld = cholesky_sym(ata)
    cholesky_to!(ata, ld)

    ld.values = round.(ld.values, digits = 8)
    e.values = round.(e.values, digits = 8)

    @test equals(ld, e)
end

@testset "solve_to! 1" begin
    local g = Graph{Float64}(3)
    g[1, 1] = 38.0
    g[2, 1] = 22.0
    g[2, 2] = 17.0
    g[3, 1] = 14.0
    g[3, 2] = 13.0
    g[3, 3] = 11.0
    local ata = from_graph(g, 3, 3)
    ata.layout = Spandex.lower_symmetric

    local b = [1.0, 10.0, 5.0]

    local ld = cholesky_sym(ata)
    cholesky_to!(ata, ld)
    local x = zeros(Float64, 3)
    solve_to!(ld, b, x)

    @test 3 == length(x)

    @test abs(-9.5 - x[1]) < 1e-10
    @test abs(34.166666666666 - x[2]) < 1e-10
    @test abs(-27.833333333333 - x[3]) < 1e-10
end

@testset "solve_to! 2" begin
    local g = Graph{Float64}(5)
    g[1, 1] = 0.339721892599889
    g[2, 1] = -0.117511897064494
    g[2, 2] = 0.61348986691309
    g[3, 1] = 0.0221940137659884
    g[3, 2] = 0.27504299861335
    g[3, 3] = 0.355516636030647
    g[4, 1] = -0.26882517335515
    g[4, 2] = 0.0684899239330446
    g[4, 3] = 0.0333434870019433
    g[4, 4] = 0.412101013254036
    g[5, 1] = -0.159648639043336
    g[5, 2] = 0.0401190234458681
    g[5, 3] = -0.0318276646882203
    g[5, 4] = -0.0108046250911296
    g[5, 5] = 0.399329937547505
    local ata = from_graph(g, 5, 5)
    ata.layout = Spandex.lower_symmetric

    local b = [4.0, -1.0, -3.0, 4.0, -2.0]

    local ld = cholesky_sym(ata)
    cholesky_to!(ata, ld)
    local x = zeros(Float64, 5)
    solve_to!(ld, b, x)

    @test 5 == length(x)

    @test abs(84.3926371078906 - x[1]) < 1e-10
    @test abs(20.6069097491701 - x[2]) < 1e-10
    @test abs(-33.4133473479173 - x[3]) < 1e-10
    @test abs(64.7118533875248 - x[4]) < 1e-10
    @test abs(25.7485304673898 - x[5]) < 1e-10
end
