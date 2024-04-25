module Separability
    include("core.jl")
    # Implementation nach Übung 4, Aufgabe 2
    # Es gilt
    # $$(\forall(n\in{\mathbb{N}_0}|2^n<2^3)\exists\lambda\in{\mathbb{R}}\forall(x\in{\mathbb{N}_0}|x\lt(2^3-2^n)\land(2^{n}>(x\mod{2^{n+1}}))|(\ket{x}_3=\lambda\ket{x+2^n}_3))$$
    export separable, separate, findlambda
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

    # Gibt zurück welche Q-Bits separierbar sind
    # Beispiel: separable(bell ⊗ k1) == [false, false, true]
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
                            sep = false
                            break
                        end
                    elseif !floateq(lambda * vec[x], vec[other])
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

    # Separiert den Gesamtzustand in Einzelteile
    # Beispiel: separate(a ⊗ b, 1) = a
    # Beispiel: separate(a ⊗ b, 2) = b
    #
    # Wenn seperable(a) auf dem xten index ein true zurück gibt
    # ist der Rückgabewert von separate(a, x) korrekt
    separate(input::Vector, n::Int) = begin
        ex = convert(Int, round(log(length(input))/log(2)))
        vec = [0, 1]
        lambda = findlambda(input, ex - n)

        if lambda != Inf && lambda != -Inf
            vec = [1, lambda]
        elseif lambda == -Inf
            vec = [0, -1]
        end

        return vec / abs(vec)
    end
end