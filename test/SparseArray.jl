using Test
using Spandex

@testset "setindex! 1" begin
    local a = SparseArray{Char}(10)

    a[1] = 'a'
    a[5] = 'e'
    a[3] = 'c'

    @test 3 == a.nnz

    a[2] = 'b'
    a[4] = 'd'

    @test 5 == a.nnz
end

@testset "setindex! 2" begin
    local a = SparseArray{Char}(10)

    a[1] = 'a'
    @test 1 == a.nnz

    a[1] = 'a'
    @test 1 == a.nnz

    a[1] = 'b'
    @test 1 == a.nnz
end

@testset "contains 1" begin
    local a = SparseArray{Char}(10)

    a[1] = 'a'
    a[5] = 'e'
    a[3] = 'c'

    @test contains(a, 1)
    @test contains(a, 3)
    @test contains(a, 5)
    @test !contains(a, 2)
    @test !contains(a, 4)
    @test !contains(a, 6)

    a[2] = 'b'
    a[4] = 'd'

    @test contains(a, 1)
    @test contains(a, 2)
    @test contains(a, 3)
    @test contains(a, 4)
    @test contains(a, 5)
    @test !contains(a, 6)
end

@testset "contains 2" begin
    local a = SparseArray{Char}(10)

    a[1] = 'a'
    @test contains(a, 1)
    @test !contains(a, 9)

    a[1] = 'a'
    @test contains(a, 1)
    @test !contains(a, 9)

    a[1] = 'b'
    @test contains(a, 1)
    @test !contains(a, 9)
end

@testset "getindex 1" begin
    local a = SparseArray{Char}(10)

    a[1] = 'a'
    a[5] = 'e'
    a[3] = 'c'

    @test 'a' == a[1]
    @test 'c' == a[3]
    @test 'e' == a[5]

    a[2] = 'b'
    a[4] = 'd'

    @test 'a' == a[1]
    @test 'b' == a[2]
    @test 'c' == a[3]
    @test 'd' == a[4]
    @test 'e' == a[5]
end

@testset "getindex 2" begin
    local a = SparseArray{Char}(10)

    a[1] = 'a'
    @test 'a' == a[1]

    a[1] = 'a'
    @test 'a' == a[1]

    a[1] = 'b'
    @test 'b' == a[1]
end

@testset "equals 1" begin
    local a = SparseArray{Char}(10)
    a[1] = 'a'
    a[2] = 'b'
    a[3] = 'c'
    a[4] = 'd'
    a[5] = 'e'

    local b = SparseArray{Char}(10)
    b[1] = 'a'
    b[5] = 'e'
    b[3] = 'c'
    b[2] = 'b'
    b[4] = 'd'

    @test equals(a, b)
end

@testset "equals 2" begin
    local a = SparseArray{Char}(20)
    a[1] = 'a'
    a[2] = 'b'
    a[3] = 'c'
    a[4] = 'd'
    a[5] = 'e'

    local b = SparseArray{Char}(10)
    b[1] = 'a'
    b[5] = 'e'
    b[3] = 'c'
    b[2] = 'b'
    b[4] = 'd'

    @test !equals(b, a)
end

@testset "equals 3" begin
    local a = SparseArray{Char}(20)
    a[1] = 'a'

    local b = SparseArray{Char}(10)
    b[1] = 'b'

    @test !equals(a, b)
end
