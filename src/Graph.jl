export Graph

import Base.resize!, Base.insert!, Base.getindex, Base.setindex!

export resize!,
    clear!,
    add_vertex!,
    has_connections,
    are_connected,
    connect!,
    disconnect!,
    sort!,
    is_leaf,
    equals,
    getindex,
    setindex!

const NIL = -1

mutable struct Graph{T}
    start::Vector{Int64}
    next::Vector{Int64}
    vertices::Vector{Int64}
    edges::Vector{T}

    size::Int64
    free::Int64

    function Graph{T}(vertex_count::Int64) where {T}
        return new(
            fill(NIL, (vertex_count)),
            Vector{Int64}(),
            Vector{Int64}(),
            Vector{T}(),
            0,
            NIL,
        )
    end
end

function Base.:copy(g::Graph{T}) where {T}
    local h = Graph{T}(0)

    h.start = copy(g.start)
    h.next = copy(g.next)
    h.vertices = copy(g.vertices)
    h.edges = copy(g.edges)

    h.size = g.size
    h.free = g.free

    return h
end

function Base.:resize!(g::Graph{T}, vertex_count::Int64) where {T}
    resize!(g.start, vertex_count)
    clear!(g)
end

function clear!(g::Graph{T}) where {T}
    g.size = 0
    g.free = NIL

    fill!(g.start, NIL)

    resize!(g.next, 0)
    resize!(g.vertices, 0)
    resize!(g.edges, 0)
end

function add_vertex!(g::Graph{T}) where {T}
    push!(g.start, NIL)
end

function has_connections(g::Graph{T}, vertex::Int64) where {T}
    @assert vertex > 0 && vertex <= length(g.start)

    return NIL != g.start[vertex]
end

function are_connected(g::Graph{T}, from::Int64, to::Int64) where {T}
    @assert from > 0 && from <= length(g.start)
    @assert to > 0

    if !has_connections(g, from)
        return false
    end

    return !ismissing(g[from, to])
end

function equals(g::Graph{T}, h::Graph{T}) where {T}
    if g.size != h.size
        return false
    end

    local n = length(g.start)
    for i = 1:n
        local j = g.start[i]
        local k = h.start[i]

        while NIL != j && NIL != k
            if g.vertices[j] != h.vertices[k]
                return false
            end
            if g.edges[j] != h.edges[k]
                return false
            end

            j = g.next[j]
            k = h.next[k]
        end

        if NIL != j || NIL != k
            return false
        end
    end

    return true
end

function connect!(g::Graph{T}, edge::T, from::Int64, to::Int64) where {T}
    @assert from > 0 && from <= length(g.start)
    @assert to > 0

    local n = 0
    if g.free > 0
        n = g.free
        g.vertices[g.free] = to
        g.edges[g.free] = edge
        g.free = g.next[g.free]
    else
        n = g.size + 1
        push!(g.next, NIL)
        push!(g.vertices, to)
        push!(g.edges, edge)
    end

    if NIL == g.start[from]
        g.start[from] = NIL
    end

    g.next[n] = g.start[from]
    g.start[from] = n

    g.size += 1
end

function Base.:setindex!(g::Graph{T}, edge::T, from::Int64, to::Int64) where {T}
    if !are_connected(g, from, to)
        connect!(g, edge, from, to)
    else
        local j = g.start[from]
        while NIL != j
            if to == g.vertices[j]
                g.edges[j] = edge
                break
            end
            j = g.next[j]
        end
    end
end

function Base.:getindex(g::Graph{T}, from::Int64, to::Int64) where {T}
    @assert from > 0 && from <= length(g.start)
    @assert to > 0

    local j = g.start[from]
    while NIL != j
        if to == g.vertices[j]
            return g.edges[j]
        end
        j = g.next[j]
    end

    return missing
end

function disconnect!(g::Graph{T}, from::Int64, to::Int64) where {T}
    @assert from > 0 && from <= length(g.start)
    @assert to > 0

    if !has_connections(g, from)
        return
    end

    local k = NIL
    local p = NIL
    local j = g.start[from]

    while NIL != j
        if to == g.vertices[j]
            k = j
            break
        end
        p = j
        j = g.next[j]
    end

    if NIL == k
        return
    end

    if g.start[from] == k
        g.start[from] = g.next[k]
        g.next[k] = g.free
        g.free = k
    else
        g.next[p] = g.next[k]
        g.next[k] = g.free
        g.free = k
    end

    g.size -= 1
end

function disconnect!(g::Graph{T}, vertex::Int64) where {T}
    @assert vertex > 0 && vertex <= length(g.start)

    if !has_connections(g, vertex)
        return
    end

    local n = 1
    local p = g.start[vertex]

    while NIL != g.next[p]
        p = g.next[p]
        n += 1
    end

    g.next[p] = g.free
    g.free = g.start[vertex]
    g.start[vertex] = NIL
    g.size -= n
end

function is_leaf(g::Graph{T}, vertex::Int64) where {T}
    @assert vertex > 0 && vertex <= length(g.start)

    if !has_connections(g, vertex)
        return true
    end

    local first_neighbor = vertex

    local i = g.start[vertex]
    while NIL != i
        if vertex != g.vertices[i]
            first_neighbor = g.vertices[i]
            break
        end
        i = g.next[i]
    end

    if vertex == first_neighbor
        return true
    end

    i = g.start[vertex]
    while NIL != i
        if first_neighbor != g.vertices[i] && vertex != g.vertices[i]
            return false
        end
        i = g.next[i]
    end

    return true
end

function Base.:sort!(g::Graph{T}) where {T}
    local sorted = zeros(Int64, 0)
    local indices = zeros(Int64, 0)

    local n = length(g.start)
    for i = 1:n
        resize!(sorted, 0)
        resize!(indices, 0)

        local j = g.start[i]
        while NIL != j
            push!(sorted, g.vertices[j])
            push!(indices, j)
            j = g.next[j]
        end

        local count = length(indices)

        if count < 2
            continue
        end

        indices[:] = indices[sortperm(sorted)]

        for j = 2:count
            g.next[indices[j-1]] = indices[j]
        end

        g.start[i] = indices[1]
        g.next[indices[end]] = NIL
    end
end
