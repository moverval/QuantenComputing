include("core.jl")
include("constants.jl")
include("separability.jl")
include("control.jl")

import .Separability.separable
import .Control.control, .Control.cntl

# Ein normales CNOT ist das gleiche wie ein kontrolliertes rX Gatter
CNOT = cntl(2, 1, 2, rX)

# Ein CNOT Gatter welches Q-Bit 2 für die Aktivierung und 1 für die Manipulation nutzt.
CNOT2to1 = cntl(2, 2, 1, rX)
