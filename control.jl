module Control
    include("core.jl")
    include("constants.jl")
    include("notation.jl")

    import .Notation.bitchain
    export cntl, control

    # qb: Q-Bits
    # from: Index der Aktivierung
    # to: Index der Mutation
    # mat: Transformation auf das zu mutierende Q-Bit
    #
    # Führt eine kontrollierte Transformation auf ein Q-Bit aus
    #
    # Beispiel: cntl(2, 1, 2, pX) == CNOT
    # Beispiel: cntl(2, 1, 2, RY(pi/2)) * (k0 ⊗ k1) == k0 ⊗ k1
    cntl = control(qb, from, to, mat) = begin
        result = zeros(2 ^ qb, 2 ^ qb)

        for i in 0:(2^qb-1)
            chain = bitchain(zeros(qb), i)
            vec = [1]

            for (x, c) in enumerate(chain)
                if chain[from] && to == x
                    if c
                        vec = vec ⊗ (mat * k1)
                    else
                        vec = vec ⊗ (mat * k0)
                    end
                else
                    if c
                        vec = vec ⊗ k1
                    else
                        vec = vec ⊗ k0
                    end
                end
            end

            result[1:2^qb, i+1] = vec
        end

        return result
    end

    import Base.xor

    Base.xor(x::Vector, y::Vector)::Vector = begin
        n = (abs(x - k1) < 1e-4 && abs(y - k1) < 1e-4) || (abs(x - k0) < 1e-4 && abs(y - k0) < 1e-4)

        if n
            return k0
        else
            return k1
        end
    end
end