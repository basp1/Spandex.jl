using Test
using Spandex

@testset "range 1" begin
    local u = SegmentTree{Int64}([1], max, typemin(Int64))

    @test 1 == top(u)
    @test 1 == range(u, 1, 1)
    @test 1 == u[1]
end

@testset "range 2" begin
    local u =
        SegmentTree{Int64}([3, 8, 6, 4, 2, 5, 9, 0, 7, 1], max, typemin(Int64))

    @test 9 == top(u)
    @test 9 == range(u, 6, 10)
    @test 9 == range(u, 1, 10)
    @test 8 == range(u, 1, 5)
    @test 8 == range(u, 2, 2)
    @test 8 == range(u, 2, 5)
    @test 7 == range(u, 8, 9)
    @test 5 == range(u, 5, 6)
    @test 6 == range(u, 3, 6)
end

@testset "range 3" begin
    local u = SegmentTree{Int64}([5, 4, 3, 2, 1], max, typemin(Int64))

    @test 5 == top(u)
    @test 3 == range(u, 3, 5)
    @test 5 == u[1]
    @test 4 == u[2]
    @test 3 == u[3]
end

@testset "set 1" begin
    local values = [3, 8, 6, 4, 2, 5, 9, 0, 7, 1]
    local u = SegmentTree{Int64}(values, max, typemin(Int64))
    local v = SegmentTree{Int64}(10, max, typemin(Int64))

    @test !equals(u, v)

    for i = 1:10
        v[i] = values[i]
    end

    @test equals(u, v)
end

@testset "set 2" begin
    local u =
        SegmentTree{Int64}([3, 8, 6, 4, 2, 5, 9, 0, 7, 1], max, typemin(Int64))

    u[7] = 0

    @test 8 == top(u)
    @test 8 == range(u, 1, 10)
    @test 7 == range(u, 6, 10)
    @test 8 == range(u, 1, 5)
    @test 8 == u[2]
    @test 8 == range(u, 2, 5)
    @test 7 == range(u, 8, 9)
    @test 5 == range(u, 5, 6)
    @test 6 == range(u, 3, 6)
end
