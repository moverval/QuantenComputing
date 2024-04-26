include("core.jl")
include("constants.jl")
include("notation.jl")
include("separate.jl")
include("control.jl")
include("bloch.jl")
include("latex.jl")

import .Separate.separable, .Separate.separate, .Separate.findlambda, .Separate.rs
import .Control.control, .Control.cntl
import .Notation.ket

# Ein normales CNOT ist das gleiche wie ein kontrolliertes rX Gatter
CNOT = cntl(2, 1, 2, Px)

# Ein CNOT Gatter welches Q-Bit 2 für die Aktivierung und 1 für die Manipulation nutzt.
CNOT2to1 = cntl(2, 2, 1, Px)

S = [
    1 0 0 0;
    0 0 1 0;
    0 1 0 0;
    0 0 0 1
]
