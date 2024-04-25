module Separability
    # Implementation nach Übung 4, Aufgabe 2
    # Es gilt
    # $$(\forall(n\in{\mathbb{N}_0}|2^n<2^3)\exists\lambda\in{\mathbb{R}}\forall(x\in{\mathbb{N}_0}|x\lt(2^3-2^n)\land(2^{n}>(x\mod{2^{n+1}}))|(\ket{x}_3=\lambda\ket{x+2^n}_3))$$
    export separable
    floateq(x, y) = abs(x - y) <= 1e-4

    # Das richtige Lambda für die Separabilität zu finden ist nicht so trivial wie man
    # vorerst denkt. Hier wird in immer weniger Information kaskadiert bis letztendlich 0 zurückgegeben wird.
    findlambda(vec::Vector, n::Int) = begin
        ex = round(log(length(vec))/log(2))

        for (x, _) in enumerate(vec)
            if x-1 < convert(Int, round(2^ex - 2^n)) && partofportion(x, n)
                other = convert(Int, round(x + 2 ^ n))
                if !floateq(vec[x], 0) && !floateq(vec[other], 0)
                    return vec[other]/vec[x]
                end
            end
        end

        for (x, _) in enumerate(vec)
            if x-1 < convert(Int, round(2^ex - 2^n)) && partofportion(x, n)
                other = convert(Int, round(x + 2 ^ n))
                if !floateq(vec[x], 0)
                    return 0
                end

                if !floateq(vec[other], 0)
                    if vec[other] > 0
                        return Inf
                    else
                        return -Inf
                    end
                end
            end
        end

        return 0
    end

    # Gibt zurück ob überhaupt das daraufliegende x mit einem Lambda verglichen werden darf
    partofportion(x::Int, n::Int) = begin
        return 2^n > ((x-1) % 2^(n+1))
    end

    separable(vec::Vector) = begin
        ex = round(log(length(vec))/log(2))
        result = []

        for n in 0:(ex-1)
            n = convert(Int, n)
            lambda = findlambda(vec, convert(Int, n))
            sep = true
            for (x, _) in enumerate(vec)
                if x-1 < convert(Int, round(2^ex - 2^n)) && partofportion(x, n)
                    other = convert(Int, round(x + 2^n))
                    if lambda == Inf || lambda == -Inf
                        if !floateq(0, vec[x])
                            # println("[I$x] $(vec[x]) not separable with [I$(convert(Int, round(x + 2^n)))] $(vec[convert(Int, round(x + 2^n))]) with lambda $(lambda)")
                            sep = false
                            break
                        end
                    elseif !floateq(lambda * vec[x], vec[other])
                        # println("[I$x] $(vec[x]) not separable with [I$(convert(Int, round(x + 2^n)))] $(vec[convert(Int, round(x + 2^n))]) with lambda $(lambda)")
                        sep = false
                        break
                    end
                end
            end

            if sep
                append!(result, true)
            else
                append!(result, false)
            end
        end

        return reverse(result)
    end
end