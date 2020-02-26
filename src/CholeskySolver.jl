export CholeskySolver
export cholesky_sym, cholesky_to!, solve_to!

mutable struct CholeskySolver{T}
    list::Intlist

    ata::SparseMatrix{T}
    ld::SparseMatrix{T}
    y::Vector{T}

    perm::PermuteTable

    row_count::Int64
    column_count::Int64

    tolerance::Float64

    function CholeskySolver{T}(row_count, column_count::Int64) where {T}
        local cs = new()

        cs.row_count = row_count
        cs.column_count = column_count

        cs.list = Intlist(column_count)

        cs.tolerance = 1e-10

        return cs
    end
end

function cholesky_sym(sym::SparseMatrix{T}) where {T}
    @assert lower_symmetric == sym.layout

    local n = sym.row_count

    local g = Graph{T}(n)

    local columns = Vector{Int64}()
    clear!(sym.list)

    for i = 1:n
        for j = sym.rows[i]:(sym.rows[i+1]-1)
            local jj = sym.rows_columns[j]
            push!(sym.list, jj)
            push!(columns, jj)
        end

        while length(columns) > 0
            local jj = pop!(columns)

            if !has_connections(g, jj)
                continue
            end

            local p = g.start[jj]
            while NIL != p
                local r = g.vertices[p]
                p = g.next[p]

                if jj == r
                    continue
                end

                if !contains(sym.list, r)
                    push!(sym.list, r)
                    push!(columns, r)
                end
            end
        end

        while !is_empty(sym.list)
            connect!(g, T(0), pop!(sym.list), i)
        end
    end

    local c = from_graph(g, n, n)
    local ct = transpose(c)
    ct.layout = lower_triangle

    return ct
end

function cholesky_to!(sym, ld::SparseMatrix{T}) where {T}
    @assert lower_symmetric == sym.layout
    @assert lower_triangle == ld.layout

    local n = sym.row_count
    local zero = T(0)

    local acc = zeros(T, n)

    @inbounds begin
        for j = 1:n
            for i = sym.columns[j]:(sym.columns[j+1]-1)
                acc[sym.columns_rows[i]] = sym.values[i]
            end

            for k = ld.rows[j]:(ld.rows[j+1]-1)
                if ld.rows_columns[k] >= j
                    break
                end

                local r = ld.rows_columns[k]
                local a = ld.values[ld.positions[k]] * ld.values[ld.columns[r]]

                for i = ld.positions[k]:(ld.columns[r+1]-1)
                    acc[ld.columns_rows[i]] -= a * ld.values[i]
                end
            end

            local d = ld.values[ld.columns[j]] = acc[j]
            if d <= zero
                d = tolerance
            end

            for k = ld.columns[j]+1:(ld.columns[j+1]-1)
                ld.values[k] = acc[ld.columns_rows[k]] / d
                acc[ld.columns_rows[k]] = T(0)
            end
        end
    end
end

function solve_to!(ld::SparseMatrix{T}, b, result::Vector{T}) where {T}
    @assert lower_triangle == ld.layout
    @assert length(b) == ld.row_count

    local y = solve_lower(ld, b)

    local z = solve_diag(ld, y)

    local x = solve_upper(ld, z)

    result[:] = x[:]
end

function solve_lower(ld::SparseMatrix{T}, b::Vector{T}) where {T}
    @assert lower_triangle == ld.layout
    @assert length(b) == ld.row_count

    local n = ld.row_count
    local y = zeros(T, n)

    @inbounds begin
        for i = 1:n
            local sum = T(0)

            for j = ld.rows[i]:(ld.rows[i+1]-2)
                sum += ld.values[ld.positions[j]] * y[ld.rows_columns[j]]
            end

            y[i] = b[i] - sum
        end
    end

    return y
end

function solve_diag(ld::SparseMatrix{T}, y::Vector{T}) where {T}
    @assert lower_triangle == ld.layout
    @assert length(y) == ld.row_count

    local n = ld.row_count
    local x = zeros(T, n)

    @inbounds begin
        for j = n:-1:1
            x[j] = y[j] / ld.values[ld.columns[j]]
        end
    end

    return x
end

function solve_upper(ld::SparseMatrix{T}, z::Vector{T}) where {T}
    @assert lower_triangle == ld.layout
    @assert length(z) == ld.row_count

    local n = ld.row_count
    local x = zeros(T, n)

    @inbounds begin
        for j = n:-1:1
            local sum = T(0)

            for i = (ld.columns[j]+1):(ld.columns[j+1]-1)
                sum += ld.values[i] * x[ld.columns_rows[i]]
            end

            x[j] = z[j] - sum
        end
    end

    return x
end
