using Statistics: mean

# nash sutcliffe efficiency
function nse(obs, sim)
    coeff_det(obs, sim)
end

# coefficient of determination
function coeff_det(y, f)
    return 1 - sum((y - f).^2) / sum((y .- mean(y)).^2)
end
