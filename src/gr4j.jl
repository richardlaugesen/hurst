
function gr4j_parameters(arr)
    Dict("x1" => arr[1], "x2" => arr[2], "x3" => arr[3], "x4" => arr[4])
end

function gr4j_random_parameters()
    gr4j_parameters([rand(1:10000), rand(-100:0.5:100), rand(1:5000), rand(0.5:0.1:40)])
end

function gr4j_reasonable_parameters()
    gr4j_parameters([350, 0, 50, 0.5])
end

X4_TRANS_OFFSET = 0.5 - 1e-9

function gr4j_params_transform(pars)
    pars["x1"] = log(pars["x1"])
    pars["x3"] = log(pars["x3"])
    pars["x4"] = log(pars["x4"] - X4_TRANS_OFFSET)

    return pars
end

function gr4j_params_range_transform(pars_range)
    pars_range[1] = (log(pars_range[1][1]), log(pars_range[1][2]))
    pars_range[3] = (log(pars_range[3][1]), log(pars_range[3][2]))
    pars_range[4] = (log(pars_range[4][1] - X4_TRANS_OFFSET), log(pars_range[4][2] - X4_TRANS_OFFSET))

    return pars_range
end

function gr4j_params_transform_inverse(pars)
    pars["x1"] = exp(pars["x1"])
    pars["x3"] = exp(pars["x3"])
    pars["x4"] = exp(pars["x4"]) + X4_TRANS_OFFSET

    return pars
end

function gr4j_init_state(params)
    x4 = params["x4"]
    n = Int(ceil(x4))

    return Dict(
        "uh1" => zeros(n),
        "uh2" => zeros(2n),
        "uh1_ordinates" => create_uh_ordinates(1, n, x4),
        "uh2_ordinates" => create_uh_ordinates(2, 2n, x4),
        "production_store" => 0,
        "routing_store" => 0
    )
end

function s_curve(variant, scale, x)
    if variant == 1
        if x <= 0
            return 0
        elseif x < scale
            return (x / scale)^2.5
        else
            return 1
        end

    elseif variant == 2
        if x <= 0
            return 0
        elseif x <= scale
            return 0.5 * (x / scale)^2.5
        elseif x < 2scale
            return 1 - 0.5 * (2 - x / scale)^2.5
        else
            return 1
        end
    end
end

function create_uh_ordinates(variant, size, x4)
    ordinates = zeros(size)
    for t in 1:size
        ordinates[t] = s_curve(variant, x4, t) - s_curve(variant, x4, t - 1)
    end
    return ordinates
end

function lshift(v)
    v = circshift(v, -1)
    v[length(v)] = 0
    return v
end

function update_uh(uh, volume, ordinates)
    (volume * ordinates) + lshift(uh)
end

function gr4j_run_step(rain, pet, state, params)

    # parameters
    x1 = params["x1"]
    x2 = params["x2"]
    x3 = params["x3"]
    x4 = params["x4"]

    # state
    uh1 = state["uh1"]
    uh2 = state["uh2"]
    v1 = state["production_store"]
    v2 = state["routing_store"]
    ord1 = state["uh1_ordinates"]
    ord2 = state["uh2_ordinates"]

    # forcing
    p = rain
    e = pet

    # interception and production store
    if p >= e
        ws = min(13, (p - e) / x1)
        es = 0
        ps = x1 * (1 - (v1 / x1)^2) * tanh(ws) / (1 + (v1 / x1) * tanh(ws))
        pr = rain - e - ps
    else
        ws = min(13, (e - p) / x1)
        es = v1 * (2 - v1 / x1) * tanh(ws) / (1 + (1 - v1 / x1) * tanh(ws))
        ps = 0
        pr = 0
    end
    v1 -= es - ps

    # Percolation from production store
    perc = v1 * (1 - (1 + (v1 / x1)^4 / 25.62890625)^-0.25)
    v1 -= perc
    pr += perc

    # Convolution of unit hydrographs
    uh1 = update_uh(uh1, pr, ord1)
    uh2 = update_uh(uh2, pr, ord2)

    # Potential intercatchment semi-exchange
    ech = x2 * (v2 / x3)^3.5

    # routing store
    v2 = max(0, v2 + 0.9 * uh1[1] + ech)
    qr = v2 * (1 - (1 + (v2 / x3)^4)^-0.25)
    v2 -= qr

    # Runoff from direct branch qd
    qd = max(0, 0.1 * uh2[1] + ech)

    # total runoff
    q = qr + qd

    state = Dict(
        "uh1" => uh1,
        "uh2" => uh2,
        "uh1_ordinates" => ord1,
        "uh2_ordinates" => ord2,
        "production_store" => v1,
        "routing_store" => v2
    )

    return q, state
end
