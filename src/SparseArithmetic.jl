export add, add_sym, add_to!, mul, mul_sym, mul_to!, sqr, sqr_sym, sqr_to!

function add(a::SparseMatrix{T}, b::SparseMatrix{T}) where {T}
    @assert a.row_count == b.row_count
    @assert a.column_count == b.column_count

    local c = add_sym(a, b)
    add_to!(a, b, c)
    return c
end

function add_sym(a::SparseMatrix{T}, b::SparseMatrix{T}) where {T}
    @assert a.row_count == b.row_count
    @assert a.column_count == b.column_count

    local c = DirectedGraph{T}(a.row_count)

    clear!(a.list)

    for j = 1:a.column_count
        for i = a.columns[j]:(a.columns[j+1]-1)
            push!(a.list, a.columns_rows[i])
        end
        for i = b.columns[j]:(b.columns[j+1]-1)
            push!(a.list, b.columns_rows[i])
        end
        while !is_empty(a.list)
            connect!(c, T(0), pop!(a.list), j)
        end
    end

    return from_graph(c, a.row_count, a.column_count)
end

function add_to!(
    a::SparseMatrix{T},
    b::SparseMatrix{T},
    c::SparseMatrix{T},
) where {T}
    @assert a.row_count == b.row_count
    @assert a.column_count == b.column_count
    @assert a.row_count == c.row_count
    @assert a.column_count == c.column_count

    @inbounds begin
        local acc = zeros(T, a.column_count)

        for i = 1:a.row_count
            for j = a.columns[i]:(a.columns[i+1]-1)
                acc[a.columns_rows[j]] = a.values[j]
            end

            for j = b.columns[i]:(b.columns[i+1]-1)
                acc[b.columns_rows[j]] += b.values[j]
            end

            for j = c.columns[i]:(c.columns[i+1]-1)
                local jj = c.columns_rows[j]
                c.values[j] = acc[jj]
                acc[jj] = T(0)
            end
        end
    end
end

function mul(a::SparseMatrix{T}, b::SparseMatrix{T}) where {T}
    @assert a.column_count == b.row_count

    local c = mul_sym(a, b)
    mul_to!(a, b, c)
    return c
end

function mul_sym(a::SparseMatrix{T}, b::SparseMatrix{T}) where {T}
    @assert a.column_count == b.row_count

    clear!(a.list)

    local c = DirectedGraph{T}(a.row_count)

    for j = 1:b.column_count
        for i = b.columns[j]:(b.columns[j+1]-1)
            local ii = b.columns_rows[i]
            for k = a.columns[ii]:(a.columns[ii+1]-1)
                push!(a.list, a.columns_rows[k])
            end
        end

        while !is_empty(a.list)
            connect!(c, T(0), pop!(a.list), j)
        end
    end

    return from_graph(c, a.row_count, b.column_count)
end

function mul_to!(
    a::SparseMatrix{T},
    b::SparseMatrix{T},
    c::SparseMatrix{T},
) where {T}
    @assert a.row_count == c.row_count
    @assert a.column_count == b.row_count
    @assert b.column_count == c.column_count

    @inbounds begin
        local acc = zeros(T, c.row_count)

        for j = 1:b.column_count
            for i = b.columns[j]:(b.columns[j+1]-1)
                local ii = b.columns_rows[i]
                for k = a.columns[ii]:(a.columns[ii+1]-1)
                    acc[a.columns_rows[k]] += b.values[i] * a.values[k]
                end
            end

            for i = c.columns[j]:(c.columns[j+1]-1)
                local jj = c.columns_rows[i]
                c.values[i] = acc[jj]
                acc[jj] = T(0)
            end
        end
    end
end

function mul(a::SparseMatrix{T}, b::Vector{T}) where {T}
    local c = zeros(T, a.row_count)
    mul_to!(a, b, c)
    return c
end

function mul_to!(a::SparseMatrix{T}, b::Vector{T}, c::Vector{T}) where {T}
    @assert a.column_count == length(b)
    @assert a.row_count == length(c)

    for i = 1:a.row_count
        for j = a.rows[i]:(a.rows[i+1]-1)
            c[i] += b[a.rows_columns[j]] * a.values[a.positions[j]]
        end
    end
end

function mul(a::SparseMatrix{T}, b::SparseArray{T}) where {T}
    local c = SparseArray{T}(a.row_count)
    mul_to!(a, b, c)
    return c
end

function mul_to!(
    a::SparseMatrix{T},
    b::SparseArray{T},
    c::SparseArray{T},
) where {T}
    @assert a.column_count == b.size
    @assert a.row_count == c.size

    local zero = T(0)
    for i = 1:a.row_count
        if a.rows[i+1] == a.rows[i]
            continue
        end

        local x = zero

        for j = a.rows[i]:(a.rows[i+1]-1)
            local r = a.rows_columns[j]
            if !ismissing(b[r])
                x += b[r] * a.values[a.positions[j]]
            end
        end

        if zero != x
            c[i] = x
        end
    end
end

function sqr(a::SparseMatrix{T}) where {T}
    local s = sqr_sym(a)
    sqr_to!(a, s)
    return s
end

function sqr_sym(a::SparseMatrix{T}) where {T}
    local g = DirectedGraph{T}(a.column_count)
    clear!(a.list)

    for j = 1:a.column_count
        for i = a.columns[j]:(a.columns[j+1]-1)
            local ii = a.columns_rows[i]
            for k = a.rows[ii]:(a.rows[ii+1]-1)
                local r = a.rows_columns[k]
                push!(a.list, r)
            end
        end

        push!(a.list, j)

        while !is_empty(a.list)
            connect!(g, T(0), pop!(a.list), j)
        end
    end

    local ata = from_graph(g, a.column_count, a.column_count)

    return ata
end

function sqr_to!(a::SparseMatrix{T}, ata::SparseMatrix{T}) where {T}
    @assert default_layout == ata.layout

    @inbounds begin
        local acc = zeros(T, a.column_count)

        for j = 1:a.column_count
            for i = a.columns[j]:(a.columns[j+1]-1)
                local ii = a.columns_rows[i]

                for k = a.rows[ii]:(a.rows[ii+1]-1)
                    local r = a.rows_columns[k]

                    acc[r] += a.values[i] * a.values[a.positions[k]]
                end
            end

            for i = ata.columns[j]:(ata.columns[j+1]-1)
                local r = ata.columns_rows[i]
                ata.values[i] = acc[r]
                acc[r] = T(0)
            end
        end
    end
end

function sqr_sym(a::SparseMatrix{T}, pt::PermuteTable) where {T}
    @assert default_layout == a.layout

    local g = DirectedGraph{T}(a.column_count)
    clear!(a.list)

    for j = 1:a.column_count
        local jj = pt.permuted[j]

        for i = a.columns[jj]:(a.columns[jj+1]-1)
            local ii = a.columns_rows[i]
            for k = a.rows[ii]:(a.rows[ii+1]-1)
                local r = pt.primary[a.rows_columns[k]]

                if r < j
                    continue
                end

                push!(a.list, r)
            end
        end

        push!(a.list, j)

        while !is_empty(a.list)
            connect!(g, T(0), pop!(a.list), j)
        end
    end

    local ata = from_graph(g, a.column_count, a.column_count)
    ata.layout = lower_symmetric

    return ata
end

function sqr_to!(
    a::SparseMatrix{T},
    ata::SparseMatrix{T},
    pt::PermuteTable,
) where {T}
    @assert default_layout == a.layout
    @assert lower_symmetric == ata.layout

    @inbounds begin
        local acc = zeros(T, a.column_count)

        for j = 1:a.column_count
            local jj = pt.permuted[j]

            for i = a.columns[jj]:(a.columns[jj+1]-1)
                local ii = a.columns_rows[i]

                for k = a.rows[ii]:(a.rows[ii+1]-1)
                    local r = pt.primary[a.rows_columns[k]]

                    if r < j
                        continue
                    end

                    acc[r] += a.values[i] * a.values[a.positions[k]]
                end
            end

            for i = ata.columns[j]:(ata.columns[j+1]-1)
                local r = ata.columns_rows[i]
                ata.values[i] = acc[r]
                acc[r] = T(0)
            end
        end
    end
end
