using Test
using Spandex

@testset "norm!" begin
    local a = from_csr(
        10,
        10,
        [1, 2, 3, 6, 7, 9, 10, 11, 12, 16, 19],
        [1, 2, 1, 2, 3, 4, 4, 5, 6, 7, 8, 6, 7, 8, 9, 8, 9, 10],
        [
            0.32502429653806530,
            0.68646720167973219,
            0.20664713231230356,
            0.80911717430065078,
            1.0850649558194219,
            0.37484683221445758,
            0.29211785639326571,
            0.56725008142048217,
            0.30569332800228499,
            0.12993461529471456,
            0.48493422490889138,
            0.22043327522151054,
            0.056305455607475616,
            0.33290016729588462,
            0.70740209966807233,
            0.45713455373057488,
            0.73539821745905609,
            1.5818072373358281,
        ],
    )

    local norm = Spandex.norm!(a)
    local e = [
        1.7540504746792074,
        1.2069522923516747,
        0.96000198563023442,
        1.6333267599804464,
        1.3277390136750080,
        1.8086603584984466,
        2.7741987233555063,
        1.4360136957244634,
        1.1889588605089314,
        0.79510268651896931,
    ]

    norm = round.(norm, digits = 16)
    e = round.(e, digits = 16)

    @test e == norm
end
