export PermuteTable
export push!, equals

import Base.resize!, Base.push!, Base.getindex, Base.setindex!

mutable struct PermuteTable
    size::Int64
    primary::Vector{Int64}
    permuted::Vector{Int64}

    function PermuteTable(n::Int64)
        local pt = new()

        pt.size = n
        pt.primary = collect(1:n)
        pt.permuted = collect(1:n)

        return pt
    end

    function PermuteTable(a::SparseMatrix)
        local n = a.column_count

        local pt = new()
        pt.size = n
        pt.primary = zeros(Int64, n)
        pt.permuted = zeros(Int64, n)

        local eg = EliminationGraph(a)

        local init = Vector{Tuple{Int64,Int64}}()
        for i = 1:n
            push!(init, (i, eg.size[i]))
        end

        local select = (a, b) -> return a[2] < b[2] ? a : b
        local st =
            SegmentTree{Tuple{Int64,Int64}}(init, select, (0, typemax(Int64)))

        for i = 1:n
            local min = top(st)[1]

            push!(pt, i, min)

            local vertices = eg[min]

            eliminate!(eg, min)

            for j = 1:length(vertices)
                local jj = vertices[j]
                st[jj] = (jj, eg.size[jj])
            end

            st[min] = (0, typemax(Int64))
        end

        return pt
    end
end

function Base.:push!(pt::PermuteTable, prime::Int64, perm::Int64)
    @assert prime <= pt.size
    @assert perm <= pt.size
    @assert 0 == pt.primary[perm] && 0 == pt.permuted[prime]

    pt.primary[perm] = prime
    pt.permuted[prime] = perm
end

function equals(pt::PermuteTable, tt::PermuteTable)
    return pt.primary == tt.primary && pt.permuted == tt.permuted
end
