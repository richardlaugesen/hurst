
function gr4j_parameters(x1, x2, x3, x4)
    Dict("x1" => x1, "x2" => x2, "x3" => x3, "x4" => x4)
end

function gr4j_random_parameters()
    gr4j_parameters(rand(1:6000), rand(-3:0.1:3), rand(1:1000), rand(0.1:0.1:14))
end

function gr4j_reasonable_parameters()
    gr4j_parameters(800, 2, 400, 3)
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

function gr4j_run_step_optimised(rain, pet, state, params)

    # parameters
    x1 = params["x1"]
    x2 = params["x2"]
    x3 = params["x3"]
    x4 = params["x4"]

    # state
    uh1 = state["uh1"]
    uh2 = state["uh2"]
    production_store = state["production_store"]
    routing_store = state["routing_store"]
    uh1_ordinates = state["uh1_ordinates"]
    uh2_ordinates = state["uh2_ordinates"]

    # mapping to original fortran variable names
    P = rain
    E = pet
    v1 = production_store
    v2 = routing_store

    # interception and production store
    if P >= E
        es = 0
        ws = (P - E) / x1
        ws = ws > 13 ? 13 : ws
        TWS = tanh(ws)
        Sr = v1 / x1

        ps = x1 * (1 - Sr * Sr) * TWS / (1 + Sr * TWS)
        pr = P - E - ps
    else
        ws = (E - P) / x1
        ws = ws > 13 ? 13 : ws
        TWS = tanh(ws)
        Sr = v1 / x1

        es = v1 * (2 - Sr) * TWS / (1 + (1 - Sr) * TWS)
        ps = 0
        pr = 0
    end
    v1 = v1 - es + ps

    # Percolation from production store
    Sr = v1 / x1
    Sr = Sr * Sr
    Sr = Sr * Sr
    S2 = v1 / sqrt(sqrt(1 + Sr / 25.62890625))
    perc = v1 - S2
    v1 = S2
    pr += perc

    # Convolution of unit hydrographs
    uh1 = update_uh(uh1, pr, uh1_ordinates)
    uh2 = update_uh(uh2, pr, uh2_ordinates)

    # Potential intercatchment semi-exchange
    Rr = v2 / x3
    ech = x2 * Rr * Rr * Rr * sqrt(Rr)

    # routing store
    v2 = max(0, v2 + 0.9 * uh1[1] + ech)
    Rr = v2 / x3
    Rr = Rr * Rr
    Rr = Rr * Rr
    R2 = v2 / sqrt(sqrt(1 + Rr))
    qr = v2 - R2
    v2 = R2

    # Runoff from direct branch qd
    qd = max(0, 0.1 * uh2[1] + ech)

    # total runoff
    q = qr + qd

    state = Dict(
        "uh1" => uh1,
        "uh2" => uh2,
        "uh1_ordinates" => uh1_ordinates,
        "uh2_ordinates" => uh2_ordinates,
        "production_store" => v1,
        "routing_store" => v2
    )

    return q, state
end
