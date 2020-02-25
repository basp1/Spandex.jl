export EliminationGraph

export eliminate!, is_leaf, getindex

mutable struct EliminationGraph
    adj::Graph{Bool}
    list::Intlist
    size::Vector{Int64}

    function EliminationGraph(a::SparseMatrix)
        @assert default_layout == a.layout

        local eg = new()

        local n = a.column_count
        eg.list = Intlist(n)
        eg.adj = Graph{Bool}(a.column_count)
        eg.size = zeros(Int64, n)

        for j = 1:n
            for i = a.columns[j]:(a.columns[j+1]-1)
                local ii = a.columns_rows[i]
                for k = a.rows[ii]:(a.rows[ii+1]-1)
                    local r = a.rows_columns[k]

                    if (r <= j)
                        continue
                    end

                    push!(eg.list, r)
                end
            end

            while !is_empty(eg.list)
                local i = pop!(eg.list)

                connect!(eg.adj, true, i, j)
                connect!(eg.adj, true, j, i)

                eg.size[i] += 1
                eg.size[j] += 1
            end
        end

        return eg
    end
end

function eliminate!(eg::EliminationGraph, vertex::Int64)
    local p = eg.adj.start[vertex]
    while NIL != p
        local i = eg.adj.vertices[p]

        local q = eg.adj.start[i]
        while NIL != q
            local j = eg.adj.vertices[q]

            if j != i && j != vertex
                push!(eg.list, j)
            end

            q = eg.adj.next[q]
        end

        q = eg.adj.start[vertex]
        while NIL != q
            local j = eg.adj.vertices[q]

            if j != i && j != vertex
                push!(eg.list, j)
            end

            q = eg.adj.next[q]
        end

        eg.size[i] = eg.list.size
        disconnect!(eg.adj, i)

        while !is_empty(eg.list)
            connect!(eg.adj, true, i, pop!(eg.list))
        end

        p = eg.adj.next[p]
    end

    eg.size[vertex] = 0
    disconnect!(eg.adj, vertex)
end

function is_leaf(eg::EliminationGraph, vertex::Int64)
    return is_leaf(eg.adj, vertex)
end

function getindex(eg::EliminationGraph, vertex::Int64)
    local vertices = Vector{Int64}()
    local i = eg.adj.start[vertex]

    while NIL != i
        push!(vertices, eg.adj.vertices[i])
        i = eg.adj.next[i]
    end

    return vertices
end
