# -------------------------------------------------
# two param box-cox transform
# -------------------------------------------------

function boxcox(y, λ, ν)
    if abs(λ) < 1e-8
        log.(y .+ ν)
    else
        ((y .+ ν).^λ .- 1) / λ
    end
end

function boxcox_inverse(z, λ, ν)
    if abs(λ) < 1e-8
        exp.(z) .- ν
    else
        (λ*z .+ 1).^(1/λ) .- ν
    end
end

# -------------------------------------------------
# one param box-cox transform
# -------------------------------------------------

boxcox(y, λ) = boxcox(y, λ, 0)
boxcox_inverse(z, λ) = boxcox_inverse(z, λ, 0)

# -------------------------------------------------
# log-sinh transform
# -------------------------------------------------

function log_sinh(y, a, b)
    log.(sinh.(a .+ b * y)) / b
end

function log_sinh_inverse(z, a, b)
    (asinh.(exp.(b * z)) .- a) / b
end

# -------------------------------------------------
# log transform
# -------------------------------------------------

function log_trans(y, offset)
    log.(y .+ offset)
end

function log_trans_inverse(z, offset)
    exp.(z) .- offset
end

log_trans(y) = log_trans(y, 0)
log_trans_inverse(z) = log_trans_inverse(z, 0)
