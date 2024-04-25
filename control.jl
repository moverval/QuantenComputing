module Control
    include("core.jl")
    include("constants.jl")
    export cntl, control

    bitchain(input::Vector, x::Int)::Vector{Bool} = begin
        ex = floor(log(x)/log(2))

        if ex == -Inf
            return input
        end

        ex = convert(Int, ex)

        for e in ex:-1:0
            num = convert(Int, 2^e)
            if x - num >= 0
                x -= num
                input[e + 1] = true
            else
                input[e + 1] = false
            end
        end

        return input
    end

    # qb: Q-Bits
    # from: Index der Aktivierung
    # to: Index der Mutation
    # mat: Transformation auf das zu mutierende Q-Bit
    #
    # Führt eine kontrollierte Transformation auf ein Q-Bit aus
    #
    # Beispiel: cntl(2, 1, 2, pX) == CNOT
    # Beispiel: cntl(2, 1, 2, RY(pi/2)) * (k0 ⊗ k1) == k0 ⊗ k1
    # Beispiel: cntl(2, 1, 2, RY(pi/2)) * (k1 ⊗ k1) == k1 ⊗ (RY(pi/2)*k1)
    cntl = control(qb, from, to, mat) = begin
        result = zeros(2 ^ qb, 2 ^ qb)

        for i in 0:(2^qb-1)
            chain = bitchain(zeros(qb), i)
            chain = reverse(chain)
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
end