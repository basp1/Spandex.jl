export CholeskySolver
export cholesky_sym,
    cholesky_to!, solve_sym, solve, solve_to!, update!, downdate!

mutable struct CholeskySolver{T}
    list::Intlist

    ata::SparseMatrix{T}
    ld::SparseMatrix{T}
    y::Vector{T}

    perm::PermuteTable
    norm::Vector{T}

    row_count::Int64
    column_count::Int64

    tolerance::Float64
    use_permutation::Bool
    use_normalization::Bool

    function CholeskySolver{T}(row_count, column_count::Int64) where {T}
        local cs = new()

        cs.row_count = row_count
        cs.column_count = column_count

        cs.list = Intlist(column_count)

        cs.tolerance = 1e-10

        cs.use_permutation = true
        cs.use_normalization = true

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

function mul_transposed_to!(a::SparseMatrix{T}, b, c::Vector{T}) where {T}
    @assert a.row_count == length(b)
    @assert a.column_count == length(c)

    fill!(c, T(0))

    @inbounds begin
        for i = 1:a.row_count
            for j = a.rows[i]:(a.rows[i+1]-1)
                c[a.rows_columns[j]] += b[i] * a.values[a.positions[j]]
            end
        end
    end
end

function solve_sym(cs::CholeskySolver{T}, a::SparseMatrix{T}) where {T}
    if cs.use_permutation
        cs.perm = PermuteTable(a)
    else
        cs.perm = PermuteTable(a.column_count)
    end

    cs.ata = sqr_sym(a, cs.perm)
    cs.ld = cholesky_sym(cs.ata)
    cs.y = zeros(T, a.column_count)
end

function solve(
    cs::CholeskySolver{T},
    a::SparseMatrix{T},
    b::Vector{T},
) where {T}
    sqr_to!(a, cs.ata, cs.perm)

    if cs.use_normalization
        cs.norm = norm!(cs.ata)
    else
        cs.norm = ones(T, cs.ata.column_count)
    end

    cholesky_to!(cs.ata, cs.ld)

    mul_transposed_to!(a, b, cs.y)
    cs.y[:] = cs.y[cs.perm.permuted]

    if cs.use_normalization
        cs.y .*= cs.norm
    end

    local x = zeros(T, cs.ld.row_count)
    solve_to!(cs.ld, cs.y, x)

    if cs.use_normalization
        x .*= cs.norm
    end

    x[:] = x[cs.perm.primary]

    return x
end

function update!(
    ld::SparseMatrix{T},
    u::SparseArray{T},
    pt::PermuteTable,
) where {T}
    @assert lower_triangle == ld.layout
    @assert ld.row_count == u.size

    local zero = T(0)
    local a = T(1)
    local b = zero
    local c = zero

    local vals = zeros(T, u.size)
    for i = 1:u.nnz
        vals[pt.primary[u.indices[i]]] = u.values[i]
    end

    for j = 1:u.size
        if zero == vals[j]
            continue
        end

        local jj = ld.columns[j]

        local diag = ld.values[jj]
        local x = vals[j]
        b = a + x * x / diag
        ld.values[jj] = diag * b / a
        c = x / (diag * b)
        a = b

        for i = (jj+1):(ld.columns[j+1]-1)
            local ii = ld.columns_rows[i]

            vals[ii] -= x * ld.values[i]
            ld.values[i] += c * vals[ii]
        end
    end
end

function downdate!(
    ld::SparseMatrix{T},
    u::SparseArray{T},
    tolerance::T,
    pt::PermuteTable,
) where {T}
    @assert lower_triangle == ld.layout
    @assert ld.row_count == u.size

    local zero = T(0)
    local one = T(1)

    local vals = zeros(T, u.size)
    for i = 1:u.nnz
        vals[pt.primary[u.indices[i]]] = u.values[i]
    end

    local d = diag(ld)
    for i = 1:u.size
        set_columnwise!(ld, i, i, one)
    end

    local p = solve_lower(ld, vals)

    for i = 1:u.size
        set_columnwise!(ld, i, i, d[i])
    end

    local sum = zero
    for i = 1:u.size
        sum += p[i] / get_columnwise(ld, i, i) * p[i]
    end

    local a = one - sum

    if a <= tolerance
        a = tolerance
    end

    for j = u.size:-1:1
        local jj = ld.columns[j]
        local d = ld.values[jj]

        local b = a + p[j] * p[j] / d
        ld.values[jj] = d * a / b
        local c = -p[j] / (d * a)
        vals[j] = p[j]

        a = b

        for i = (jj+1):(ld.columns[j+1]-1)
            local ii = ld.columns_rows[i]

            local v = vals[ii]
            vals[ii] += p[j] * ld.values[i]
            ld.values[i] += c * v
        end
    end
end

function update!(cs::CholeskySolver{T}, u::SparseArray{T}, v::T) where {T}
    @assert cs.ld.row_count == u.size

    local zero = T(0)
    for i = 1:u.nnz
        if zero != u.values[i]
            local ii = cs.perm.primary[u.indices[i]]
            cs.y[ii] += v * u.values[i] * cs.norm[ii]
        end
    end

    update!(cs.ld, u, cs.perm)

    local x = zeros(T, cs.ld.row_count)
    solve_to!(cs.ld, cs.y, x)

    if cs.use_normalization
        x .*= cs.norm
    end

    if cs.use_permutation
        x[:] = x[cs.perm.primary]
    end

    return x
end

function downdate!(cs::CholeskySolver{T}, u::SparseArray{T}, v::T) where {T}
    @assert cs.ld.row_count == u.size

    local zero = T(0)
    for i = 1:u.nnz
        if zero != u.values[i]
            local ii = cs.perm.primary[u.indices[i]]
            cs.y[ii] -= v * u.values[i] * cs.norm[ii]
        end
    end

    downdate!(cs.ld, u, cs.tolerance, cs.perm)

    local x = zeros(T, cs.ld.row_count)
    solve_to!(cs.ld, cs.y, x)

    if cs.use_normalization
        x .*= cs.norm
    end

    if cs.use_permutation
        x[:] = x[cs.perm.primary]
    end

    return x
end
