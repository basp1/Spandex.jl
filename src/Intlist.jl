export Intlist
export is_empty, top, next, contains, push!, pop!, pop_all!, clear!

const NIL = Int64(-1)
const EMPTY = Int64(0)

mutable struct Intlist
    capacity::Int64
    size::Int64

    values::Vector{Int64}
    ip::Int64

    Intlist(capacity::Int64) = new(capacity, 0, fill(EMPTY, capacity), NIL)
end

function is_empty(il::Intlist)::Bool
    return 0 == il.size
end

function top(il::Intlist)::Int64
    return il.ip
end

@inbounds function next(il::Intlist, key::Int64)
    if NIL == key
        return key
    else
        return il.values[key]
    end
end

@inbounds function contains(il::Intlist, key::Int64)::Bool
    return key > 0 && key <= il.capacity && EMPTY != il.values[key]
end

@inbounds function Base.:push!(il::Intlist, key::Int64)
    @assert key > 0 && key <= il.capacity

    if contains(il, key)
        return
    end

    il.values[key] = il.ip
    il.ip = key

    il.size += 1

    return
end

@inbounds function Base.:pop!(il::Intlist)::Int64
    @assert il.size > 0

    local key = il.ip
    il.ip = il.values[il.ip]
    il.values[key] = EMPTY
    il.size -= 1

    return key
end

@inbounds function pop_all!(il::Intlist)::Vector{Int64}
    local n = il.size
    local values = zeros(Int64, n)

    for i = 1:n
        values[i] = pop!(il)
    end

    return values
end

@inbounds function clear!(il::Intlist)
    while il.size > 0
        pop!(il)
    end

    return
end
