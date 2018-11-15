# define the box-cox transform
function boxcox(y, λ)
    if λ == 0
        log.(y)
    else
        (y.^λ .- 1) ./ λ
    end
end
