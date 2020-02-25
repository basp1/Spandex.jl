using Test
using Spandex

@testset "Intlist" begin
    include("Intlist.jl")
end

@testset "Graph" begin
    include("Graph.jl")
end

@testset "SparseArray" begin
    include("SparseArray.jl")
end

@testset "SparseMatrix" begin
    include("SparseMatrix.jl")
end

@testset "SparseArithmetic" begin
    include("SparseArithmetic.jl")
end

@testset "SegmentTree" begin
    include("SegmentTree.jl")
end

@testset "PermuteTable" begin
    include("PermuteTable.jl")
end

@testset "CholeskySolver" begin
    include("CholeskySolver.jl")
end

@testset "Normalization" begin
    include("Normalization.jl")
end
