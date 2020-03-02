using Test
using Spandex

@testset "push! 1" begin
    local pq = PriorityQueue{Int64}(min)

    push!(pq, 3)
    @test 3 == top(pq)
    @test 1 == height(pq)

    push!(pq, 4)
    @test 3 == top(pq)
    @test 2 == height(pq)

    push!(pq, 5)
    @test 3 == top(pq)
    @test 2 == height(pq)

    push!(pq, 2)
    @test 2 == top(pq)
    @test 3 == height(pq)

    push!(pq, 1)
    @test 1 == top(pq)
    @test 3 == height(pq)
end

@testset "push! 2" begin
    local pq = PriorityQueue{Int64}(min)

    for i = 9:-1:1
        push!(pq, i)
    end

    @test 1 == top(pq)
    @test 4 == height(pq)

    push!(pq, 9)
    @test 1 == top(pq)
    @test 4 == height(pq)
end

@testset "push! 3" begin
    local pq = PriorityQueue{Int64}(min, 5)

    for i = 9:-1:1
        push!(pq, i)
    end

    @test 1 == top(pq)
    @test 4 == height(pq)

    push!(pq, 9)
    @test 1 == top(pq)
    @test 4 == height(pq)
end

@testset "pop! 1" begin
    local pq = PriorityQueue{Int64}(min)

    push!(pq, 18)
    push!(pq, 19)
    push!(pq, 20)
    @test 18 == top(pq)

    pop!(pq)
    @test 19 == top(pq)

    pop!(pq)
    @test 20 == top(pq)

    pop!(pq)
    @test 0 == pq.size
end

@testset "pop! 2" begin
    local pq = PriorityQueue{Int64}(min)

    for i = 9:-1:1
        push!(pq, i)
    end

    @test 1 == top(pq)
    @test 4 == height(pq)

    pop!(pq)
    @test 2 == top(pq)
    @test 4 == height(pq)

    pop!(pq)
    @test 3 == top(pq)
    @test 3 == height(pq)

    pop!(pq)
    @test 4 == top(pq)
    @test 3 == height(pq)

    pop!(pq)
    @test 5 == top(pq)
    @test 3 == height(pq)
end

@testset "pop! 3" begin
    local N = 20
    local pq = PriorityQueue{Int64}(min)

    for i = (N+1):-1:1
        push!(pq, i)
    end

    @test 1 == top(pq)

    for i = 1:Int64(N / 2)
        pop!(pq)
    end
    @test (1 + N / 2) == top(pq)

    for i = 1:Int64((N / 2) - 1)
        pop!(pq)
    end

    @test N == top(pq)
end
