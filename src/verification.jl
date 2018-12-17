using Statistics

# nash sutcliffe efficiency
function nse(obs, sim)
    coeff_det(obs, sim)
end

# coefficient of determination
function coeff_det(y, f)
    return 1 - sum(skipmissing(y - f).^2) / sum(skipmissing(y .- mean(skipmissing(y))).^2)
end

function mse(o, s)
    sum(skipmissing(o - s).^2) / (length_no_missing(o) - 1)
end

function mae(o, s)
    sum(abs.(skipmissing(o - s))) / (length_no_missing(o) - 1)
end

function rmse(o, s)
    sqrt(mse(o, s))
end

function persistence(o, s)
    shifted_o = lshift(o)
    return 1 - sum(skipmissing(s - o).^2) / sum(skipmissing(shifted_o - o).^2)
end

function kge(o, s, components)  
    o, s = dropna(o, s)
    r = cov(o, s, corrected=true) / (std(s, corrected=true) * std(o, corrected=true))  # covariance
    a = std(s) / std(o, corrected=true)  # relative variability
    b = mean(s) / mean(o)  # mean bias
    k = 1 - sqrt((r - 1)^2 + (a - 1)^2 + (b - 1)^2)
    
    if components
        return Dict(
            "covariance" => r,
            "relative_variability" => a,
            "mean_bias" => b,
            "kge" => k
        )
    else
        return k
    end
end

kge(o, s) = kge(o, s, false)

