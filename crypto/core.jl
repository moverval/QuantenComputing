ff = finite_field(F, x) = begin
    return (F+(x%F))%F
end

lendre_symbol(a, p) = powermod(a, div(p-1, 2), p)
