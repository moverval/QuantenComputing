module Grover
    include("../core.jl")
    include("../constants.jl")
    include("../separate.jl")

    export mm, mean_mirror, iteration

    mm = mean_mirror(v::Vector) = begin
        return 2 * (sum(v) / length(v)) .- v
    end

    iteration(U::Matrix, v::Vector) = begin
        # Eine Spiegelung kann mit H^(⊗n) * (-D) * H^(⊗n) realisiert werden
        # Die Matrix Multiplikationen können sich aber hier einfach gespart werden
        return mean_mirror(Separate.ignore_last(U * v)) ⊗ km
    end

    iteration_angle(N::Int, r::Int) = begin
        return acos(1 - 2 * r / N)
    end

    simulation(N::Int) = begin
        r = convert(Int, round(rand()*(N-1))+1)
        iterations = convert(Int, round(rand()*(sqrt(N)-1))+1)
        angle = iteration_angle(N, r)

        return rand() > sin(angle * (iterations + 1/2))^2
    end

    simulation_static_k(N::Int, k::Int) = begin
        r = convert(Int, round(rand()*(N-1))+1)
        angle = iteration_angle(N, r)

        return rand() > sin(angle * (k + 1/2))^2
    end

    simulate_iterations(N::Int, iters::Int) = begin
        stats = [0, 0]
        for i in 1:iters
            if simulation(N)
                stats[1] += 1
            else
                stats[2] += 1
            end
        end

        return stats
    end

    simulate_iterations_static_k(N::Int, iters::Int, k::Int) = begin
        stats = [0, 0]
        for i in 1:iters
            if simulation_static_k(N, k)
                stats[1] += 1
            else
                stats[2] += 1
            end
        end

        return stats
    end
end