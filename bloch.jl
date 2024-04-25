module Bloch
    export state

    state(ϑ, φ) = [cos(ϑ / 2), exp(im * φ) * sin(ϑ / 2)]
end