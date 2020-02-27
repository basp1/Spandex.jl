export SparseMatrix

import Base.resize!, Base.insert!, Base.getindex, Base.setindex!

export from_csr, from_graph, resize!, sort!
export equals, contains, diag, transpose
export get_row,
    get_column, get_rowwise, set_rowwise!, get_columnwise, set_columnwise!

@enum Layout default_layout lower_triangle upper_triangle lower_symmetric upper_symmetric

mutable struct SparseMatrix{T}
    columns::Vector{Int64}
    columns_rows::Vector{Int64}
    values::Vector{T}

    rows::Vector{Int64}
    rows_columns::Vector{Int64}
    positions::Vector{Int64}

    layout::Layout
    nnz::Int64
    row_count::Int64
    column_count::Int64

    list::Intlist

    function SparseMatrix{T}(
        row_count::Int64,
        column_count::Int64,
        capacity::Int64,
    ) where {T}
        local sm = new()

        resize!(sm, row_count, column_count, capacity)

        return sm
    end
end

function resize!(
    sm::SparseMatrix{T},
    row_count::Int64,
    column_count::Int64,
    capacity::Int64,
) where {T}
    sm.list = Intlist(max(row_count, column_count))
    sm.layout = default_layout

    sm.nnz = 0
    sm.row_count = row_count
    sm.column_count = column_count

    sm.columns = zeros(Int64, 1 + column_count)
    sm.columns_rows = zeros(Int64, capacity)
    sm.values = zeros(T, capacity)

    sm.rows = zeros(Int64, 1 + row_count)
    sm.rows_columns = zeros(Int64, capacity)
    sm.positions = zeros(Int64, capacity)
end

function from_csr(
    row_count::Int64,
    column_count::Int64,
    rows::Vector{Int64},
    columns::Vector{Int64},
    values::Vector{T},
) where {T}
    @assert row_count == (length(rows) - 1)
    @assert length(values) == length(columns)
    @assert length(values) == rows[end] - 1

    local sm = SparseMatrix{T}(row_count, column_count, length(values))
    sm.nnz = length(values)
    sm.rows = copy(rows)

    for i = 1:row_count
        for j = rows[i]:(rows[i+1]-1)
            sm.columns[columns[j]+1] += 1
        end
    end

    sm.columns[1] = 1
    for j = 2:(1+column_count)
        sm.columns[j] += sm.columns[j-1]
    end

    local cc = copy(sm.columns)
    local rr = copy(sm.rows)
    for i = 1:row_count
        for j = rows[i]:(rows[i+1]-1)
            local c = cc[columns[j]]
            sm.columns_rows[c] = i
            sm.values[c] = values[j]

            sm.rows_columns[rr[i]] = columns[j]
            sm.positions[rr[i]] = c

            cc[columns[j]] += 1
            rr[i] += 1
        end
    end

    sort!(sm)

    return sm
end

function from_graph(g::Graph{T}, row_count, column_count::Int64) where {T}
    local sm = SparseMatrix{T}(row_count, column_count, g.size)
    sm.nnz = g.size

    sm.rows[1] = 1

    local n = 1
    local values = zeros(T, sm.nnz)
    for i = 1:row_count
        local j = g.start[i]
        while NIL != j
            values[n] = g.edges[j]
            sm.rows_columns[n] = g.vertices[j]
            sm.columns[g.vertices[j]] += 1
            j = g.next[j]
            n += 1
        end
        sm.rows[i+1] = n
    end

    n = 1
    for i = 1:(column_count+1)
        local t = n
        n += sm.columns[i]
        sm.columns[i] = t
    end

    local col_index = copy(sm.columns)
    n = 1
    for i = 1:row_count
        local j = sm.rows[i]
        for j = sm.rows[i]:(sm.rows[i+1]-1)
            local col = sm.rows_columns[j]
            sm.positions[j] = col_index[col]
            sm.values[col_index[col]] = values[j]
            sm.columns_rows[col_index[col]] = i
            col_index[col] += 1
        end
    end

    sort!(sm)

    return sm
end

function equals(sm, tm::SparseMatrix{T}) where {T}
    if sm.nnz != tm.nnz
        return false
    end
    if sm.row_count != tm.row_count
        return false
    end
    if sm.column_count != tm.column_count
        return false
    end
    if sm.columns != tm.columns
        return false
    end
    if sm.columns_rows != tm.columns_rows
        return false
    end
    if sm.positions != tm.positions
        return false
    end
    if sm.values != tm.values
        return false
    end

    return true
end

function Base.:transpose(sm::SparseMatrix{T}) where {T}
    local tm = SparseMatrix{T}(sm.column_count, sm.row_count, sm.nnz)

    tm.nnz = sm.nnz
    tm.columns[:] = sm.rows[:]
    tm.columns_rows[:] = sm.rows_columns[:]
    tm.rows[:] = sm.columns[:]
    tm.rows_columns[:] = sm.columns_rows[:]

    local k = 1
    for j = 1:sm.column_count
        for i = sm.columns[j]:(sm.columns[j+1]-1)
            tm.positions[sm.positions[i]] = k
            tm.values[k] = sm.values[sm.positions[i]]
            k = k + 1
        end
    end

    return tm
end

function contains(sm::SparseMatrix{T}, row::Int64, column::Int64) where {T}
    @assert column > 0 && column <= sm.column_count
    @assert row > 0 && row <= sm.row_count

    for j = sm.columns[column]:(sm.columns[column+1]-1)
        if row == sm.columns_rows[j]
            return true
        end
    end
    return false
end

function diag(sm::SparseMatrix{T}) where {T}
    @assert sm.column_count == sm.row_count

    local values = Vector{T}()
    for i = 1:sm.row_count
        push!(values, get_columnwise(sm, i, i))
    end

    return values
end

function get_row(sm::SparseMatrix{T}, row::Int64) where {T}
    @assert row > 0 && row <= sm.row_count

    local values = SparseArray{T}(sm.column_count)
    for i = sm.rows[row]:(sm.rows[row+1]-1)
        values[sm.rows_columns[i]] = sm.values[sm.positions[i]]
    end

    return values
end

function get_column(sm::SparseMatrix{T}, column::Int64) where {T}
    @assert column > 0 && column <= sm.column_count

    local values = SparseArray{T}(sm.row_count)

    for j = sm.columns[column]:(sm.columns[column+1]-1)
        values[sm.columns_rows[j]] = sm.values[j]
    end

    return values
end

function get_rowwise(sm::SparseMatrix{T}, row::Int64, column::Int64) where {T}
    @assert column > 0 && column <= sm.column_count
    @assert row > 0 && row <= sm.row_count

    for i = sm.rows[row]:(sm.rows[row+1]-1)
        if column == sm.rows_columns[i]
            return sm.values[sm.positions[i]]
        end
    end

    return missing
end

function set_rowwise!(
    sm::SparseMatrix{T},
    row::Int64,
    column::Int64,
    value::T,
) where {T}
    @assert column > 0 && column <= sm.column_count
    @assert row > 0 && row <= sm.row_count

    for i = sm.rows[row]:(sm.rows[row+1]-1)
        if column == sm.rows_columns[i]
            sm.values[sm.positions[i]] = value
            return
        end
    end

    error("out of range")
end

function get_columnwise(
    sm::SparseMatrix{T},
    row::Int64,
    column::Int64,
) where {T}
    @assert column > 0 && column <= sm.column_count
    @assert row > 0 && row <= sm.row_count

    for i = sm.columns[column]:(sm.columns[column+1]-1)
        if row == sm.columns_rows[i]
            return sm.values[i]
        end
    end

    return T(0)
end

function set_columnwise!(
    sm::SparseMatrix{T},
    row::Int64,
    column::Int64,
    value::T,
) where {T}
    @assert column > 0 && column <= sm.column_count
    @assert row > 0 && row <= sm.row_count

    for i = sm.columns[column]:(sm.columns[column+1]-1)
        if row == sm.columns_rows[i]
            sm.values[i] = value
            return
        end
    end

    error("out of range")
end

function Base.:sort!(sm::SparseMatrix{T}) where {T}
    local old_indices = collect(Int64, 1:sm.nnz)
    local new_indices = copy(old_indices)

    for j = 1:sm.column_count
        local range = sm.columns[j]:sm.columns[j+1]-1
        local perm = (sm.columns[j] - 1) .+ sortperm(sm.columns_rows[range])
        sm.columns_rows[range] = sm.columns_rows[perm]
        new_indices[range] = new_indices[perm]
    end

    sm.values[old_indices] = sm.values[new_indices]

    for j = 1:sm.row_count
        local range = sm.rows[j]:sm.rows[j+1]-1
        local perm = (sm.rows[j] - 1) .+ sortperm(sm.rows_columns[range])
        sm.rows_columns[range] = sm.rows_columns[perm]
        sm.positions[range] = sm.positions[perm]
    end

    for i = 1:sm.nnz
        sm.positions[i] = new_indices[sm.positions[i]]
    end
end
