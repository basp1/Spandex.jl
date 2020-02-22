export SegmentTree
export getindex, setindex!, top, range, equals

mutable struct SegmentTree{T}
    capacity::Int64
    values::Vector{T}
    select
    limit::T

    function SegmentTree{T}(values::Vector{T}, select, limit::T) where {T}
        local st = SegmentTree{T}(length(values), select, limit)

        for i = 1:length(values)
            st.values[st.capacity-1+i] = values[i]
        end

        for i = st.capacity-2:-1:0
            st.values[i+1] = select(st.values[2+(i<<1)], st.values[3+(i<<1)])
        end

        return st
    end

    function SegmentTree{T}(n::Int64, select, limit::T) where {T}
        local st = new()

        st.limit = limit
        st.select = select
        st.capacity = 1 << Int64(ceil(log2(n)))
        st.values = Vector{T}()
        resize!(st.values, st.capacity << 1)

        fill!(st.values, limit)

        return st
    end
end

function equals(st, tt::SegmentTree{T}) where {T}
    if st.capacity != tt.capacity
        return false
    end

    if st.values != tt.values
        return false
    end

    return true
end

function Base.:setindex!(st::SegmentTree{T}, value::T, index::Int64) where {T}
    @assert index <= st.capacity

    index += st.capacity - 1
    st.values[index] = value

    while index > 1
        local val = st.values[index]
        local neighbor

        if 1 != index % 2
            neighbor = index + 1
            index = index >> 1
        else
            neighbor = index - 1
            index = index >> 1
        end

        value = st.select(val, st.values[neighbor])

        if (st.values[index] != value)
            st.values[index] = value
        else
            break
        end
    end
end

function top(st::SegmentTree{T}) where {T}
    return st.values[1]
end

function Base.:getindex(st::SegmentTree{T}, index::Int64) where {T}
    return range(st, index, index)
end

function Base.:range(st::SegmentTree{T}, left, right::Int64) where {T}
    @assert left <= right
    @assert left <= st.capacity
    @assert right <= st.capacity

    left += (st.capacity - 2)
    right += (st.capacity - 2)
    local left_value = st.limit
    local right_value = st.limit

    while left < right
        if 0 == left % 2
            left_value = st.select(left_value, st.values[left+1])
        end

        left >>= 1

        if 1 == right % 2
            right_value = st.select(st.values[right+1], right_value)
        end
        right = (right >> 1) - 1
    end

    if left == right
        left_value = st.select(left_value, st.values[left+1])
    end

    return st.select(left_value, right_value)
end
