using Statistics: mean

# nash sutcliffe efficiency
function nse(obs, sim)
    coeff_det(obs, sim)
end

# coefficient of determination
function coeff_det(y, f)
    return 1 - sum(skipmissing(y - f).^2) / sum(skipmissing(y .- mean(skipmissing(y))).^2)
end
