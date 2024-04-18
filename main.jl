⊗ = tp = tensorproduct(x::Matrix, y::Matrix) = begin
    mat = zeros(size(x, 1) * size(y, 1), size(x, 2) * size(y, 2))

    for row in axes(x, 1), column in axes(x, 2)
        mat[size(y, 1)*(row-1)+1:size(y,1)*row, size(y, 2)*(column-1)+1:size(y, 2)*column] = x[row, column] * y
    end

    return mat
end

⊗ = tp = tensorproduct(x::Vector, y::Vector) = begin
    vec = []

    for i in eachindex(x)
        append!(vec, x[i] * y)
    end

    return vec
end

CNOT = [
    1 0 0 0;
    0 1 0 0;
    0 0 0 1;
    0 0 1 0
]

CNOT2to1 = [1 0 0 0; 0 0 0 1; 0 0 1 0; 0 1 0 0]

H = 1/sqrt(2) * [1 1; 1 -1]

k0 = [1, 0]

k1 = [0, 1]

bell = 1/sqrt(2) * ((k0 ⊗ k0) + (k1 ⊗ k1))

RY(α) = [cos(α) -sin(α); sin(α) cos(α)] 