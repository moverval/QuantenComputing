# Author: Moritz Naumann

# Implementation nach Übung 4, Aufgabe 2
# Es gilt
# $$(\forall(n\in{\mathbb{N}_0}|2^n<2^3)\exists\lambda\in{\mathbb{R}}\forall(x\in{\mathbb{N}_0}|x\lt(2^3-2^n)\land(2^{n}>(x\mod{2^{n+1}}))|(\ket{x}_3=\lambda\ket{x+2^n}_3))$$
module Separate
    include("core.jl")

    export State, QBit, separable, separate, findlambda, resolve

    floateq(x, y) = abs(x - y) <= 1e-4

    # Diagnostik zu dem Vektor welcher analysiert wird
    struct State
        vector::Vector
        ex::Int

        State(vector::Vector) = new(vector, convert(Int, round(log(2, length(vector)))))
    end

    # Diagnostik zu dem n-ten Q-Bit
    struct QBit
        state::State
        n::Int
        lambda::Float64

        QBit(state::State, index::Int) = begin
            n = state.ex - index
            return new(state, n, findlambda(state, n))
        end
    end

    # Das richtige Lambda für die Separabilität zu finden ist nicht so trivial wie man
    # vorerst denkt. Hier wird in immer weniger Information kaskadiert bis letztendlich 0 zurückgegeben wird
    # Wichtig: Nachdem die Wahrscheinlichkeiten zusammen tensoriert wurden ist es unmöglich den einzelnen globalen Status
    # von einem Q-Bit wiederherzustellen. Aus diesem Grund ist das Lambda bei verlorener Information immer positiv
    findlambda(state::State, n::Int) = begin
        vec = state.vector;
        ex = state.ex;

        # Suche nach 2 Zahlen welche nicht 0 sind, da wenn
        # sie existieren sich das Lambda hieran anpassen muss
        for (x, _) in enumerate(vec)
            if x-1 < 2^ex - 2^n
                if partofportion(x, n)
                    other = x + 2 ^ n
                    if !floateq(vec[x], 0) && !floateq(vec[other], 0)
                        return vec[other]/vec[x]
                    end
                end
            else
                break
            end
        end

        # Es scheinen keine zwei Nummern (in einem paar) zu existieren,
        # möglicherweise gibt es aber noch eine nummer welche nun entscheidet ob nun
        # der Vektor [0, 1] oder [1, 0] tensoriert wurde
        for (x, _) in enumerate(vec)
            if x-1 < 2^ex - 2^n
                if partofportion(x, n)
                    other = x + 2 ^ n
                    if !floateq(vec[x], 0)
                        return 0
                    end

                    if !floateq(vec[other], 0)
                        return Inf
                    end
                end
            else
                break
            end
        end

        # Das lambda scheint keine Auswirkung zu haben
        # Wir geben als Standard 0 zurück
        return 0
    end

    # Gibt zurück ob überhaupt das daraufliegende x mit einem Lambda verglichen werden darf
    partofportion(x::Int, n::Int) = begin
        return 2^n > ((x-1) % 2^(n+1))
    end

    # Gibt zurück welche Q-Bits separierbar sind
    # Beispiel: separable(bell ⊗ k1) == [false, false, true]
    #
    # Wenn bereits ein Zustand eines Vektors existiert ist es günstiger
    # die Funktion mit diesem aufzurufen
    separable(vec::Vector) = begin
        return separable(State(vec))
    end

    # Gibt zurück welche Q-Bits separierbar sind
    # Beispiel: separable(State(bell ⊗ k1)) == [false, false, true]
    #
    # Wenn bereits ein Zustand über eine Dimension existiert, ist es günstiger
    # die Funktion mit dieser aufzurufen
    separable(state::State) = begin
        ex = state.ex;

        result = []

        for n in 1:ex
            append!(result, separable(QBit(state, n)))
        end

        return result
    end

    # Gibt zurück ob die Dimension separierbar ist
    # Beispiel: separable(QBit(State(k0 ⊗ bell), 1)) == true
    # Beispiel: separable(QBit(State(k0 ⊗ bell), 2)) == false
    # Beispiel: separable(QBit(State(k0 ⊗ bell), 3)) == false
    separable(qbit::QBit) = begin
        vec = qbit.state.vector;
        ex = qbit.state.ex;
        n = qbit.n;
        lambda = qbit.lambda;

        for (x, _) in enumerate(vec)
            if x-1 < 2^ex - 2^n
                if partofportion(x, n)
                    other = x + 2^n
                    if lambda == Inf || lambda == -Inf
                        if !floateq(0, vec[x])
                            return false
                        end
                    elseif !floateq(lambda * vec[x], vec[other])
                        return false
                    end
                end
            else
                break
            end
        end

        return true
    end

    # Separiert den Gesamtzustand in Einzelteile
    # Beispiel: separate(a ⊗ b) == hcat(a, b)
    #
    # Wenn seperable(a) auf dem xten index wahr zurück gibt
    # ist der Rückgabewert von separate auf Spalte x korrekt
    #
    # Wenn die Rückgabewerte immer korrekt sein müssen, nutze resolve
    #
    # Wenn ein Zustand bereits existiert, ist es günstiger mit diesem zu arbeiten
    separate(vec::Vector)::Matrix = begin
        return separate(State(vec))
    end

    # Separiert den Gesamtzustand in Einzelteile
    # Beispiel: separate(State(a ⊗ b)) == hcat(a, b)
    #
    # Wenn seperable(a) auf dem xten index wahr zurück gibt
    # ist der Rückgabewert von separate auf Spalte x korrekt
    #
    # Wenn die Rückgabewerte immer korrekt sein müssen, nutze resolve
    #
    # Falls ein Q-Bit schon berechnet wurde ist es günstiger hiermit zu arbeiten
    separate(state::State)::Matrix = begin
        ex = state.ex;

        mat = zeros((2, ex))

        for n in 1:ex
            mat[:, n] = separate(QBit(state, n))
        end

        return mat
    end

    # Separiert den Gesamtzustand in Einzelteile
    # Beispiel: separate(QBit(State(a ⊗ b), 1)) == a
    # Beispiel: separate(QBit(State(a ⊗ b), 2)) == b
    #
    # Wenn seperable(a) auf dem xten index wahr zurück gibt
    # ist der Rückgabewert von separate(a, x) korrekt
    separate(qbit::QBit)::Vector = begin
        lambda = qbit.lambda;
        vec = [0, 1]

        if lambda != Inf && lambda != -Inf
            vec = [1, lambda]
        elseif lambda == -Inf
            vec = [0, -1]
        end

        return vec / abs(vec)
    end

    # Führt eine Kontrolle und eine Zerteilung gleichzeitig durch
    # Falls ein nicht separabler Zustand vorkommt wird dieser durch den
    # 0-Vektor ersetzt
    #
    # Beispiel: resolve(k0 ⊗ k1) == hcat(k0, k1)
    # Beispiel: resolve(km ⊗ bell ⊗ kp) == hcat(km, [0, 0], [0, 0], kp)
    rs = resolve(input::Vector) = begin
        return resolve(State(input))
    end

    # Führt eine Kontrolle und eine Zerteilung gleichzeitig durch
    # Falls ein nicht separabler Zustand vorkommt wird dieser durch den
    # 0-Vektor ersetzt
    #
    # Beispiel: resolve(State(k0 ⊗ k1)) == hcat(k0, k1)
    # Beispiel: resolve(State(km ⊗ bell ⊗ kp)) == hcat(km, [0, 0], [0, 0], kp)
    rs = resolve(state::State) = begin
        result = zeros((2, state.ex))
        for i in 1:state.ex
            bit = QBit(state, i)
            result[:, i] = resolve(bit)
        end

        return result
    end

    # Führt eine Kontrolle und eine Zerteilung gleichzeitig durch
    # Falls ein nicht separabler Zustand vorkommt wird dieser durch den
    # 0-Vektor ersetzt
    #
    # Beispiel: resolve(QBit(State(k0 ⊗ k1), 1)) == k0
    # Beispiel: resolve(QBit(State(km ⊗ bell ⊗ kp), 2)) == [0, 0]
    rs = resolve(qbit::QBit) = begin
        if separable(qbit)
            return separate(qbit)
        else
            return [0, 0]
        end
    end
end