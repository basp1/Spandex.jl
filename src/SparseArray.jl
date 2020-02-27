export SparseArray
export contains, clear!, getindex, setindex!, equals

mutable struct SparseArray{T}
    size::Int64
    nnz::Int64

    indices::Vector{Int64}
    values::Vector{T}

    function SparseArray{T}(size::Int64) where {T}
        return new{T}(size, 0, Vector{Int64}(), Vector{T}())
    end
end

function equals(sa::SparseArray{T}, ta::SparseArray{T}) where {T}
    return sa.size == ta.size && sa.nnz == ta.nnz &&
           sa.indices == ta.indices && sa.values == ta.values
end

function Base.:setindex!(sa::SparseArray{T}, value::T, index::Int64) where {T}
    @assert index <= sa.size

    local n = length(sa.indices)
    local it = lower_bound(sa.indices, index)

    if it <= n && index == sa.indices[it]
        sa.values[it] = value
    elseif it > 0
        insert!(sa.indices, it, index)
        insert!(sa.values, it, value)
        sa.nnz += 1
    end
end

function contains(sa::SparseArray{T}, index::Int64) where {T}
    @assert index <= sa.size

    return find(sa, index) > 0
end

function clear!(sa::SparseArray{T}) where {T}
    sa.nnz = 0
    empty!(sa.indices)
    empty!(sa.values)
end

function Base.:getindex(sa::SparseArray{T}, index::Int64) where {T}
    @assert index <= sa.size

    local it = find(sa, index)

    if it < 1
        return missing
    else
        return sa.values[it]
    end
end

function find(sa::SparseArray{T}, index::Int64) where {T}
    local it = lower_bound(sa.indices, index)

    if it <= length(sa.indices) && index == sa.indices[it]
        return it
    end

    return 0
end

function lower_bound(array::Vector{T}, item::T) where {T}
    local n = length(array)
    local l::Int64 = 1
    local r::Int64 = n

    while l <= r
        local m::Int64 = floor(l + (r - l) / 2)

        if item == array[m]
            return m
        end

        if item < array[m]
            r = m - 1
        else
            l = m + 1
        end
    end

    return l
end
