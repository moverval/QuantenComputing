module Latex
    # Löscht redundante Informationen
    refine(mat::Matrix) = begin
        for row in axes(mat, 1), col in axes(mat, 2)
            if mat[row, col] == -0
                mat[row, col] = 0
            end
        end

        return mat
    end
end