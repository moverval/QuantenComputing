module Notation
    include("core.jl")
    include("constants.jl")

    export bitchain, ket

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

        return reverse(input)
    end

    ket(x, bits) = begin
        result = [1]

        for (_, x) in enumerate(bitchain(zeros(bits), x))
            if x
                result = result ⊗ k1
            else
                result = result ⊗ k0
            end
        end

        return result
    end

    ket(x::Matrix) = begin
        result = [1]

        for i in axes(x, 2)
            result = result ⊗ x[:, i]
        end

        return result
    end

    ket(constraint::Bool) = begin
        if constraint
            return k1
        else
            return k0
        end
    end
end