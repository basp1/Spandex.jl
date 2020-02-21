using Test
using Spandex

@testset "are_connected 1" begin
    local a = Graph{Char}(10)

    a[1, 1] = '-'
    a[2, 1] = '-'

    @test are_connected(a, 1, 1)
    @test are_connected(a, 2, 1)

    @test !are_connected(a, 1, 2)
    @test !are_connected(a, 2, 2)
    @test !are_connected(a, 3, 1)
    @test !are_connected(a, 3, 2)
end

@testset "are_connected 2" begin
    local a = Graph{Char}(10)

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[2, 1] = '-'

    @test 3 == a.size

    a[2, 2] = '-'
    @test 4 == a.size

    @test are_connected(a, 1, 2)
    disconnect!(a, 1, 2)

    @test !are_connected(a, 1, 2)

    a[3, 1] = '-'
    a[3, 2] = '-'

    @test are_connected(a, 1, 1)
    @test are_connected(a, 2, 1)
    @test are_connected(a, 2, 2)
    @test are_connected(a, 3, 1)
    @test are_connected(a, 3, 2)
    @test !are_connected(a, 1, 2)

    @test !ismissing(a[1, 1])
    @test !ismissing(a[2, 1])
    @test !ismissing(a[2, 2])
    @test !ismissing(a[3, 1])
    @test !ismissing(a[3, 2])
    @test ismissing(a[1, 2])
end

@testset "disconnect 1" begin
    local a = Graph{Char}(10)

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[2, 1] = '-'
    a[2, 2] = '-'
    a[3, 1] = '-'
    a[3, 2] = '-'

    disconnect!(a, 1, 2)
    disconnect!(a, 2, 2)
    disconnect!(a, 3, 1)
    disconnect!(a, 3, 2)

    local e = Graph{Char}(10)
    e[1, 1] = '-'
    e[2, 1] = '-'

    sort!(a)
    sort!(e)

    @test equals(a, e)
end

@testset "disconnect 2" begin
    local a = Graph{Char}(10)

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[2, 1] = '-'
    a[2, 2] = '-'
    a[3, 1] = '-'
    a[3, 2] = '-'

    disconnect!(a, 1, 2)
    disconnect!(a, 2, 2)
    disconnect!(a, 3, 1)
    disconnect!(a, 3, 2)

    disconnect!(a, 1, 1)
    a[1, 1] = '-'

    local e = Graph{Char}(10)
    e[1, 1] = '-'
    e[2, 1] = '-'

    sort!(a)
    sort!(e)

    @test equals(a, e)
end

@testset "disconnect 3" begin
    local a = Graph{Char}(10)

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[2, 1] = '-'
    a[2, 2] = '-'
    a[3, 1] = '-'
    a[3, 2] = '-'

    @test 6 == a.size

    local e = copy(a)

    disconnect!(a, 1, 1)
    disconnect!(a, 1, 2)
    disconnect!(a, 2, 1)
    disconnect!(a, 2, 2)
    disconnect!(a, 3, 1)
    disconnect!(a, 3, 2)

    @test 0 == a.size

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[2, 1] = '-'
    a[2, 2] = '-'
    a[3, 1] = '-'
    a[3, 2] = '-'

    sort!(a)
    sort!(e)

    @test equals(a, e)
end

@testset "disconnect 4" begin
    local a = Graph{Char}(10)

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[2, 1] = '-'
    a[2, 2] = '-'
    a[3, 1] = '-'
    a[3, 2] = '-'

    @test 6 == a.size

    local e = copy(a)

    disconnect!(a, 1)
    disconnect!(a, 2)
    disconnect!(a, 3)

    @test 0 == a.size

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[2, 1] = '-'
    a[2, 2] = '-'
    a[3, 1] = '-'
    a[3, 2] = '-'

    sort!(a)
    sort!(e)

    @test equals(a, e)
end

@testset "sort 1" begin
    local a = Graph{Char}(10)

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[2, 1] = '-'
    a[2, 2] = '-'
    a[3, 1] = '-'
    a[3, 2] = '-'

    local b = copy(a)
    @test equals(a, b)

    sort!(a)
    sort!(b)

    @test equals(a, b)

    sort!(a)

    @test equals(a, b)
end

@testset "sort 2" begin
    local a = Graph{Char}(10)

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[1, 3] = '-'

    local b = copy(a)
    @test equals(a, b)

    disconnect!(a, 1, 1)
    disconnect!(a, 1, 2)
    disconnect!(a, 1, 3)

    a[1, 3] = '-'
    a[1, 2] = '-'
    a[1, 1] = '-'

    sort!(a)
    sort!(b)

    @test equals(a, b)

    disconnect!(a, 1, 1)
    disconnect!(a, 1, 2)
    disconnect!(a, 1, 3)

    a[1, 1] = '-'
    a[1, 2] = '-'
    a[1, 3] = '-'

    sort!(a)
    sort!(b)

    @test equals(a, b)
end
