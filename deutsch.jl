module Deutsch
    include("core.jl")
    include("constants.jl")
    include("control.jl")
    include("notation.jl")
    include("separate.jl")

    import .Notation.ket

    export oracle, alg

    # Erstellt die Transformation zu der Funktion welche überprüft werden soll.
    # Leider befinden wir uns hier in einer makroskopischen Welt, aus diesem Grund
    # müssen wir deswegen die Funktion statt 1 mal mindestens 2 mal aufrufen um alle
    # Zustände zu erhalten. Aus simplizität wird sie hier für jeden Schleifendurchlauf
    # neu aufgerufen. Mit einer Münze in der Quantenwelt könnte dies jedoch instantan ablaufen.
    #
    # Beispiel: oracle(x -> true)
    oracle(func::Function, qbits::Int=2)::Matrix = begin
        result = zeros((2^qbits, 2^qbits))
        for i in 0:(2^qbits-1)
            x = div(i, 2)
            y = i % 2

            res = ket(x, qbits-1) ⊗ xor(ket(y != 0), ket(func(x)))
            result[:, i + 1] = res
        end

        return result
    end

    # Deutsch Algorithmus
    # Erfordert ein Orakel welches mit `oracle` generiert werden kann.
    # Für Verständnis, siehe Skript Seite 42 bis 43.
    alg(oracle::Matrix)::Vector = begin
        return alg(oracle, convert(Int, log(2, size(oracle, 1))))
    end

    # Deutsch Algorithmus
    # Erfordert ein Orakel welches mit `oracle` generiert werden kann.
    # Für Verständnis, siehe Skript Seite 42 bis 43.
    alg(oracle::Matrix, qbits::Int)::Vector = begin
        Hm = H
        Pv = kp

        for _ in 1:(qbits-2)
            Hm = Hm ⊗ H
            Pv = Pv ⊗ kp
        end

        result = (Hm ⊗ I) * oracle * (Pv ⊗ km)
        return ket(Separate.separate(result)[:, 1:end-1])
    end
end