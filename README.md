# Spandex
Fast and simple sparse matrix library

```julia
using Spandex

n = 3
a = from_csr(
    n,
    n,
    [1, 3, 6, 8],
    [2, 3, 1, 2, 3, 2, 3],
    [1.0, 1.0, 2.0, 4.0, -2.0, 3.0, 15.0],
)

solver = CholeskySolver{Float64}(n, n)
solve_sym(solver, a)
x = solve(solver, a, [17.0, 2.89, -3.3])

m = SparseArray{Float64}(n)
m[1] = 7.0
m[2] = -5.0
m[3] = 1.0

u = update!(solver, m, 9.0)

v = downdate!(solver, m, 9.0)

@assert sum(abs.(x - v)) < 1e-8
```
