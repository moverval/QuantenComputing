⊗ = tp = tensorproduct(x::Matrix, y::Matrix) = tp(Float64, x, y)
⊗ = tp = tensorproduct(::Type{T}, x::Matrix, y::Matrix) where {T <: Number} = begin
    mat = zeros(T, size(x, 1) * size(y, 1), size(x, 2) * size(y, 2))

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

import Base.abs

Base.abs(x::Vector) = sqrt(sum(x .^ 2))

RY(α) = [cos(α) -sin(α); sin(α) cos(α)] 

C(x::Vector) = 2 * abs(x[1] * x[4] - x[2] * x[3])

cv(x::Matrix) = convert(Matrix{ComplexF64}, x)
cv(x::Vector) = convert(Vector{ComplexF64}, x)
cv(x::Number) = convert(ComplexF64, x)