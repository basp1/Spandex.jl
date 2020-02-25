export norm!

function norm!(a::SparseMatrix{T}) where {T}
    local zero = T(0)
    local one = T(1)
    local norm = ones(T, a.column_count)

    for j = 1:a.column_count
        if a.columns[j] == a.columns[j+1]
            error("matrix should be positive defined")
        end

        local k = a.columns[j]

        if a.values[k] == zero
            a.values[k] = one
        end

        norm[j] = one / sqrt(a.values[k])

        a.values[k] = one
    end

    for j = 1:a.column_count
        local column_norm = norm[j]

        for i = (a.columns[j]+1):(a.columns[j+1]-1)
            local row_norm = norm[a.columns_rows[i]]
            a.values[i] *= column_norm * row_norm
        end
    end

    return norm
end
