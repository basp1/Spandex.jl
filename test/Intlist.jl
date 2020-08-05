using Test
using Spandex

@testset "push!" begin
    local il = Intlist(10)
    push!(il, 1)
    push!(il, 7)
    push!(il, 3)
    push!(il, 2)

    @test 10 == il.capacity
    @test 4 == il.size
end

@testset "contains" begin
    local il = Intlist(10)
    push!(il, 1)
    push!(il, 7)
    push!(il, 3)
    push!(il, 2)

    @test contains(il, 1)
    @test contains(il, 2)
    @test contains(il, 3)
    @test contains(il, 7)

    @test !contains(il, 0)
    @test !contains(il, 4)
end

@testset "pop!" begin
    local il = Intlist(10)
    push!(il, 1)
    push!(il, 7)
    push!(il, 3)
    push!(il, 2)

    @test 2 == pop!(il)
    @test 3 == pop!(il)
    @test 7 == pop!(il)
    @test 1 == pop!(il)
end

@testset "pop_all!" begin
    local il = Intlist(10)
    push!(il, 1)
    push!(il, 7)
    push!(il, 3)
    push!(il, 2)

    local values = pop_all!(il)

    @test 0 == il.size

    @test 2 == values[1]
    @test 3 == values[2]
    @test 7 == values[3]
    @test 1 == values[4]
end
