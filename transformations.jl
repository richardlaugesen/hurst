# define the box-cox transform
function boxcox(y, λ)
    if λ == 0
        log.(y)
    else
        (y.^λ .- 1) / λ
    end
end

function boxcox_inverse(z, λ)
    if λ == 0
        exp.(z)
    else
        (λ*z .+ 1).^(1/λ)
    end
end
