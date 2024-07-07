module Fourier
    include("core.jl")
    include("constants.jl")
    include("control.jl")
    using Printf

    export factor, inwards, outwards, matrix

    fourier(N::Int) = (row::Int, column::Int) -> exp(im * row * column * 2pi / N)
    inwards(func::Function) = (row::Int, column::Int) -> conj(func(row, column))
    outwards(func::Function) = func

    # Berechnet die Komponenten für eine diskrete Fourier Transformation.
    #
    # Beispiel: 1/3 * matrix(3, Fourier.outwards) * matrix(3, Fourier.inwards) == I
    matrix(N::Int, manipulate::Function=inwards) = begin
        mat = zeros(Complex, (N, N))
        func = manipulate(fourier(N))

        for row in 0:(N-1)
            for column in 0:(N-1)
                mat[row+1,column+1] = func(row, column)
            end
        end

        return mat
    end

    QFT(n::Int, l::Int) = begin
        N = 2^n
        ω = exp(2*π/N*im)
        comp = [1/sqrt(N)]
        mult = N

        for _ in 1:n
            mult /= 2
            comp = comp ⊗ (k0 + (ω^(l*mult)*k1))
        end

        return comp
    end

    QFT(n::Int, vec::Vector) = begin
        res = []

        for i in 1:length(vec)
            append!(res, sum(QFT(n, i-1) .* vec))
        end

        return res
    end

    Rd(d) = [1 0; 0 exp(2*π*im/(2^d))]

    GateQFT(n::Int) = begin
        state = Control.SWAP(n)

        for i in n:-1:1
            h = ones(ComplexF64, (1, 1))

            for j in 1:n
                if j == i
                    h = h ⊗ H
                else
                    h = h ⊗ [1 0; 0 1]
                end
            end

            for j in (i-1):-1:1
                # Control.cntl(n, i, j, Rd(k)) == Control.cntl(n, j, i, Rd(k))
                h = Control.cntl(n, i, j, Rd(i-j+1)) * h
            end

            state = h * state
        end

        return state
    end
end