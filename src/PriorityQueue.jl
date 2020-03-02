export PriorityQueue
export push!, pop!, top, height

mutable struct PriorityQueue{T}
    values::Vector{T}
    select

    size::Int64

    function PriorityQueue{T}(select, capacity::Int64 = 0) where {T}
        local pq = new()

        pq.values = zeros(T, 0)
        sizehint!(pq.values, capacity)
        pq.select = select
        pq.size = 0

        return pq
    end
end

function Base.:push!(pq::PriorityQueue{T}, value::T) where {T}
    local index = 1 + pq.size

    if length(pq.values) < index
        push!(pq.values, value)
    else
        pq.values[index] = value
    end

    pq.size += 1

    promote!(pq, index)
end

function Base.:pop!(pq::PriorityQueue{T}) where {T}
    @assert pq.size > 0

    local t = top(pq)

    if 1 == pq.size
        pq.size = 0
    else
        local last = pq.values[pq.size]
        pq.values[1] = last
        pq.size -= 1

        demote!(pq, 1)
    end

    return t
end

function top(pq::PriorityQueue{T}) where {T}
    @assert pq.size > 0

    return pq.values[1]
end

function height(pq::PriorityQueue{T}) where {T}
    return 1 + Int64(floor(log2(pq.size)))
end

function promote!(pq::PriorityQueue{T}, index::Int64) where {T}
    @assert index > 0 && index <= pq.size

    if 1 == index
        return
    end

    index -= 1
    local parent = Int64(floor(index / 2))

    while index > 0
        local t = pq.values[1+index]

        if t != pq.select(t, pq.values[1+parent])
            break
        end

        pq.values[1+index] = pq.values[1+parent]
        pq.values[1+parent] = t

        local next = parent
        parent = Int64(floor(index / 2))
        index = next
    end
end

function demote!(pq::PriorityQueue{T}, index::Int64) where {T}
    @assert index > 0 && index <= pq.size

    if pq.size == index
        return
    end

    local value = pq.values[index]

    index -= 1
    while index < pq.size
        local rv
        local right = (1 + index) * 2
        if right < pq.size
            rv = pq.values[1+right]
        end

        local lv
        local left = right - 1
        if left < pq.size
            lv = pq.values[1+left]
        end

        local child = -1
        if right < pq.size && left < pq.size && lv == pq.select(lv, rv)
            child = left
        elseif right < pq.size
            child = right
        elseif left < pq.size
            child = left
        end

        if child < 0 || value == pq.select(value, pq.values[1+child])
            break
        else
            pq.values[1+index] = pq.values[1+child]
            pq.values[1+child] = value
            index = child
        end
    end
end
