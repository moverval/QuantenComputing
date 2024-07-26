module Latex
    using Latexify

    # Löscht redundante Informationen
    refine(mat::Matrix) = begin
        for row in axes(mat, 1), col in axes(mat, 2)
            if mat[row, col] == -0
                mat[row, col] = 0
            else
                mat[row, col] = round(mat[row, col] * 1e2)*1e-2
            end
        end

        return mat
    end

    refine(vec::Vector) = begin
        for (i, _) in enumerate(vec)
            if vec[i] == -0
                vec[i] = 0
            else
                vec[i] = round(vec[i]*1e2)*1e-2
            end
        end

        return vec
    end

    render(mat::Matrix) = latexify(refine(mat))
    render(vec::Vector) = latexify(refine(vec))
end