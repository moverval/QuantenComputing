include("core.jl")
include("constants.jl")
include("separability.jl")
include("control.jl")
include("bloch.jl")

import .Separability.separable, .Separability.separate, .Separability.findlambda
import .Control.control, .Control.cntl

# Ein normales CNOT ist das gleiche wie ein kontrolliertes rX Gatter
CNOT = cntl(2, 1, 2, Px)

# Ein CNOT Gatter welches Q-Bit 2 für die Aktivierung und 1 für die Manipulation nutzt.
CNOT2to1 = cntl(2, 2, 1, Px)
