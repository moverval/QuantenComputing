module Measure
    measure(qbit::Vector)::Int = begin
        random = rand(Float64)
        probs = qbit .^ 2

        for (i, prob) in enumerate(probs)
            random -= prob
            if random <= 0 || abs(random) < 1e-4
                return i - 1
            end
        end

        return -1
    end
end