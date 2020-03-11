using Test
using Spandex

@testset "from_csr 1" begin
    local a = from_csr(
        3,
        4,
        [1, 5, 8, 12],
        [1, 2, 3, 4, 1, 2, 4, 1, 2, 3, 4],
        [10, 11, 12, 13, 20, 21, 23, 30, 31, 32, 33],
    )

    @test 3 == a.row_count
    @test 4 == a.column_count
    @test 11 == a.nnz

    @test 10 == get_rowwise(a, 1, 1)
    @test 11 == get_rowwise(a, 1, 2)
    @test 12 == get_rowwise(a, 1, 3)
    @test 13 == get_rowwise(a, 1, 4)
    @test 23 == get_rowwise(a, 2, 4)
    @test 20 == get_rowwise(a, 2, 1)
    @test 21 == get_rowwise(a, 2, 2)
    @test 33 == get_rowwise(a, 3, 4)
    @test 32 == get_rowwise(a, 3, 3)
    @test 31 == get_rowwise(a, 3, 2)
    @test 30 == get_rowwise(a, 3, 1)
end

@testset "from_graph 1" begin
    local a = from_csr(
        3,
        4,
        [1, 5, 8, 12],
        [1, 2, 3, 4, 1, 2, 4, 1, 2, 3, 4],
        [10, 11, 12, 13, 20, 21, 23, 30, 31, 32, 33],
    )

    local graph = DirectedGraph{Int64}(3)
    graph[1, 1] = 10
    graph[1, 2] = 11
    graph[1, 3] = 12
    graph[1, 4] = 13
    graph[2, 4] = 23
    graph[2, 1] = 20
    graph[2, 2] = 21
    graph[3, 4] = 33
    graph[3, 3] = 32
    graph[3, 2] = 31
    graph[3, 1] = 30

    local b = from_graph(graph, 3, 4)

    @test equals(a, b)
    @test equals(b, a)
end

@testset "transpose 1" begin
    local a = from_csr(
        3,
        4,
        [1, 5, 8, 12],
        [1, 2, 3, 4, 1, 2, 4, 1, 2, 3, 4],
        [10, 11, 12, 13, 20, 21, 23, 30, 31, 32, 33],
    )

    local at = transpose(a)
    local att = transpose(at)
    local attt = transpose(att)

    @test equals(a, att)
    @test equals(at, attt)
    @test !equals(a, at)
end

@testset "get_row 1" begin
    local a = from_csr(
        4,
        4,
        [1, 5, 8, 12, 12],
        [1, 2, 3, 4, 1, 2, 4, 1, 2, 3, 4],
        [10, 11, 12, 13, 20, 21, 23, 30, 31, 32, 33],
    )

    local row = get_row(a, 1)
    @test 4 == row.size
    @test 4 == row.nnz
    @test 10 == row[1]
    @test 11 == row[2]
    @test 12 == row[3]
    @test 13 == row[4]

    row = get_row(a, 2)
    @test 4 == row.size
    @test 3 == row.nnz
    @test 20 == row[1]
    @test 21 == row[2]
    @test 23 == row[4]

    row = get_row(a, 3)
    @test 4 == row.size
    @test 4 == row.nnz
    @test 30 == row[1]
    @test 31 == row[2]
    @test 32 == row[3]
    @test 33 == row[4]

    row = get_row(a, 4)
    @test 4 == row.size
    @test 0 == row.nnz
end

@testset "get_column 1" begin
    local a = from_csr(
        3,
        5,
        [1, 5, 8, 12],
        [1, 2, 3, 4, 1, 2, 4, 1, 2, 3, 4],
        [10, 11, 12, 13, 20, 21, 23, 30, 31, 32, 33],
    )

    local column = get_column(a, 1)
    @test 3 == column.size
    @test 3 == column.nnz
    @test 10 == column[1]
    @test 20 == column[2]
    @test 30 == column[3]

    column = get_column(a, 2)
    @test 3 == column.size
    @test 3 == column.nnz
    @test 11 == column[1]
    @test 21 == column[2]
    @test 31 == column[3]

    column = get_column(a, 3)
    @test 3 == column.size
    @test 2 == column.nnz
    @test 12 == column[1]
    @test 32 == column[3]

    column = get_column(a, 4)
    @test 3 == column.size
    @test 3 == column.nnz
    @test 13 == column[1]
    @test 23 == column[2]
    @test 33 == column[3]

    column = get_column(a, 5)
    @test 3 == column.size
    @test 0 == column.nnz
end

@testset "get 1" begin
    local a = from_csr(
        3,
        4,
        [1, 5, 8, 12],
        [1, 2, 3, 4, 1, 2, 4, 1, 2, 3, 4],
        [10, 11, 12, 13, 20, 21, 23, 30, 31, 32, 33],
    )

    @test 10 == get_rowwise(a, 1, 1)
    @test 11 == get_rowwise(a, 1, 2)
    @test 12 == get_rowwise(a, 1, 3)
    @test 13 == get_rowwise(a, 1, 4)
    @test 23 == get_rowwise(a, 2, 4)
    @test 20 == get_rowwise(a, 2, 1)
    @test 21 == get_rowwise(a, 2, 2)
    @test 33 == get_rowwise(a, 3, 4)
    @test 32 == get_rowwise(a, 3, 3)
    @test 31 == get_rowwise(a, 3, 2)
    @test 30 == get_rowwise(a, 3, 1)

    @test get_columnwise(a, 1, 1) == get_rowwise(a, 1, 1)
    @test get_columnwise(a, 1, 2) == get_rowwise(a, 1, 2)
    @test get_columnwise(a, 1, 3) == get_rowwise(a, 1, 3)
    @test get_columnwise(a, 1, 4) == get_rowwise(a, 1, 4)
    @test get_columnwise(a, 2, 4) == get_rowwise(a, 2, 4)
    @test get_columnwise(a, 2, 1) == get_rowwise(a, 2, 1)
    @test get_columnwise(a, 2, 2) == get_rowwise(a, 2, 2)
    @test get_columnwise(a, 3, 4) == get_rowwise(a, 3, 4)
    @test get_columnwise(a, 3, 3) == get_rowwise(a, 3, 3)
    @test get_columnwise(a, 3, 2) == get_rowwise(a, 3, 2)
    @test get_columnwise(a, 3, 1) == get_rowwise(a, 3, 1)
end

@testset "set! 1" begin
    local a = from_csr(
        3,
        4,
        [1, 5, 8, 12],
        [1, 2, 3, 4, 1, 2, 4, 1, 2, 3, 4],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    )

    set_rowwise!(a, 1, 1, 10)
    set_rowwise!(a, 1, 2, 11)
    set_rowwise!(a, 1, 3, 12)
    set_rowwise!(a, 1, 4, 13)
    set_rowwise!(a, 2, 4, 23)
    set_rowwise!(a, 2, 1, 20)
    set_rowwise!(a, 2, 2, 21)
    set_rowwise!(a, 3, 4, 33)
    set_rowwise!(a, 3, 3, 32)
    set_rowwise!(a, 3, 2, 31)
    set_rowwise!(a, 3, 1, 30)

    @test 10 == get_rowwise(a, 1, 1)
    @test 11 == get_rowwise(a, 1, 2)
    @test 12 == get_rowwise(a, 1, 3)
    @test 13 == get_rowwise(a, 1, 4)
    @test 23 == get_rowwise(a, 2, 4)
    @test 20 == get_rowwise(a, 2, 1)
    @test 21 == get_rowwise(a, 2, 2)
    @test 33 == get_rowwise(a, 3, 4)
    @test 32 == get_rowwise(a, 3, 3)
    @test 31 == get_rowwise(a, 3, 2)
    @test 30 == get_rowwise(a, 3, 1)

    set_columnwise!(a, 1, 1, 100)
    set_columnwise!(a, 1, 2, 110)
    set_columnwise!(a, 1, 3, 120)
    set_columnwise!(a, 1, 4, 130)
    set_columnwise!(a, 2, 4, 230)
    set_columnwise!(a, 2, 1, 200)
    set_columnwise!(a, 2, 2, 210)
    set_columnwise!(a, 3, 4, 330)
    set_columnwise!(a, 3, 3, 320)
    set_columnwise!(a, 3, 2, 310)
    set_columnwise!(a, 3, 1, 300)

    @test 100 == get_rowwise(a, 1, 1)
    @test 110 == get_rowwise(a, 1, 2)
    @test 120 == get_rowwise(a, 1, 3)
    @test 130 == get_rowwise(a, 1, 4)
    @test 230 == get_rowwise(a, 2, 4)
    @test 200 == get_rowwise(a, 2, 1)
    @test 210 == get_rowwise(a, 2, 2)
    @test 330 == get_rowwise(a, 3, 4)
    @test 320 == get_rowwise(a, 3, 3)
    @test 310 == get_rowwise(a, 3, 2)
    @test 300 == get_rowwise(a, 3, 1)
end

@testset "contains 1" begin
    local a = from_csr(4, 3, [1, 2, 3, 5, 5], [2, 1, 2, 3], [1, 1, 1, 1])

    @test contains(a, 1, 2)
    @test contains(a, 2, 1)
    @test contains(a, 3, 2)
    @test contains(a, 3, 3)

    @test !contains(a, 1, 1)
    @test !contains(a, 1, 3)
    @test !contains(a, 2, 2)
    @test !contains(a, 2, 3)
    @test !contains(a, 3, 1)
    @test !contains(a, 4, 1)
    @test !contains(a, 4, 2)
    @test !contains(a, 4, 3)
end
