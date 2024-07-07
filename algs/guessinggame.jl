module GuessingGame
    include("../core.jl")
    include("../notation.jl")
    include("../measure.jl")
    include("../local.jl")

    using .Notation
    using .Measure

    black = c = 0
    red = d = 1

    export round, rounds, RuleSets, red, black, c, d, RuleSet, chsh
    export rs_just_c, rs_alice_c_bob_choosing, rs_complementary, rs_random, rs_quantum, rs_quantum_with_eve

    struct RuleSet
        ruleA::Function
        ruleB::Function

        RuleSet(ruleA::Function, ruleB::Function) = new(ruleA, ruleB)
    end

    ruleset_func(ruleset::RuleSet)::Function = begin
        return (colorA::Int, colorB::Int) -> (ruleset.ruleA(colorA), ruleset.ruleB(colorB))
    end

    round(func::Function)::Vector = begin
        result = [0, 0, 0, 0]

        colorA = rand((red, black))
        colorB = rand((red, black))

        (res1, res2) = func(colorA, colorB)

        response = (res1 == res2 ? 1 : -1)

        index = (colorA == black ? 2 : 0) + (colorB == black ? 1 : 0) + 1

        result[index] = response

        return result
    end

    round(ruleset::RuleSet)::Vector = begin
        func = ruleset_func(ruleset)
        return round(func)
    end

    rounds(func::Function, rounds::Int)::Tuple{Vector, Vector} = begin
        sum = [0, 0, 0, 0]
        len = [0, 0, 0, 0]
        for i in 1:rounds
            result = round(func)
            sum = sum + result
            len = len + abs.(result)
        end

        return (sum, len)
    end

    rounds(ruleset::RuleSet, r::Int)::Tuple{Vector, Vector} = begin
        func = ruleset_func(ruleset)
        return rounds(func, r)
    end

    chsh(result::Tuple{Vector, Vector})::Float64 = begin
        (sum, len) = result
        avg = sum ./ len

        return avg[1] + avg[2] + avg[3] - avg[4]
    end

    chsh(func::Function, r::Int)::Float64 = begin
        result = rounds(func, r)
        return chsh(result)
    end

    chsh(ruleset::RuleSet, r::Int)::Float64 = begin
        result = rounds(ruleset, r)
        return chsh(result)
    end

    rs_just_c = RuleSet(col -> c, col -> c)
    rs_alice_c_bob_choosing = RuleSet(col -> c, col -> col == red ? c : d)
    rs_random = RuleSet(col -> rand((c, d)), col -> rand((c, d)))
    rs_complementary = RuleSet(col -> (col == black ? c : rand((c, d))), col -> (col == black ? d : rand((c, d))))
    rs_weight_random = RuleSet(col -> rand((c, c, c, d)), col -> rand((c, c, c, d)))

    rs_quantum(colorA::Int, colorB::Int) = begin
        bell = 1/sqrt(2) * (ket(0, 2) + ket(3, 2))

        # Alice stellt Basis ein
        if colorA == black
            bell = (Local.rfm(π/4) ⊗ [1 0; 0 1]) * bell
        end

        # Bob stellt Basis ein
        if colorB == red
            bell = ([1 0; 0 1] ⊗ Local.rfm(π/8)) * bell
        else
            bell = ([1 0; 0 1] ⊗ Local.rfm(-π/8)) * bell
        end

        # Beide messen
        res = Measure.measure(bell)

        # Alice nimmt erstes Bit
        alice = convert(Int, res == 2 || res == 3)

        # Bob nimmt zweites Bit
        bob = convert(Int, res == 1 || res == 3)

        # Bits sind bereits richtig auf c und d kodiert
        return (alice, bob)
    end

    rs_quantum_with_eve(colorA::Int, colorB::Int) = begin
        bell = 1/sqrt(2) * (ket(0, 3) + ket(7, 3))

        # Alice stellt Basis ein
        if colorA == black
            bell = (Local.rfm(π/4) ⊗ [1 0; 0 1] ⊗ [1 0; 0 1]) * bell
        end

        # Bob stellt Basis ein
        if colorB == red
            bell = ([1 0; 0 1] ⊗ Local.rfm(π/8) ⊗ [1 0; 0 1]) * bell
        else
            bell = ([1 0; 0 1] ⊗ Local.rfm(-π/8) ⊗ [1 0; 0 1]) * bell
        end

        # Beide messen
        res = Measure.measure(bell)

        # Alice nimmt erstes Bit
        alice = convert(Int, res > 3)

        # Bob nimmt zweites Bit
        bob = convert(Int, div(res, 2) == 1 || div(res, 2) == 3)

        # Bits sind bereits richtig auf c und d kodiert
        return (alice, bob)
    end
end