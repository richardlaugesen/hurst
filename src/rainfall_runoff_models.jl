using DataFrames

# -----------------------------------------
# One storage / two parameter model
# -----------------------------------------

function one_store_model(rain, pet, storage, params)
    capacity = params["capacity"]
    loss = params["loss"]

    # effective rainfall
    storage += rain - pet

    # general losses
    storage -= loss
    storage = (storage > 0) ? storage : 0

    # runoff generation
    if storage > capacity
        runoff = storage - capacity
        storage = capacity
    else
        runoff = 0
    end

    return storage, runoff
end

# -----------------------------------------
# GR4J
# -----------------------------------------

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
    production_store = state["production_store"]
    routing_store = state["routing_store"]
    uh1_ordinates = state["uh1_ordinates"]
    uh2_ordinates = state["uh2_ordinates"]

    # mapping to original fortran variable names
    P = rain
    E = pet
    V1 = production_store
    V2 = routing_store

    # interception and production store
    if P >= E
        ES = 0
        WS = (P - E) / x1
        WS = WS > 13 ? 13 : WS
        TWS = tanh(WS)
        Sr = V1 / x1

        PS = x1 * (1 - Sr * Sr) * TWS / (1 + Sr * TWS)
        PR = P - E - PS
    else
        WS = (E - P) / x1
        WS = WS > 13 ? 13 : WS
        TWS = tanh(WS)
        Sr = V1 / x1

        ES = V1 * (2 - Sr) * TWS / (1 + (1 - Sr) * TWS)
        PS = 0
        PR = 0
    end
    V1 = V1 - ES + PS

    # Percolation from production store
    Sr = V1 / x1
    Sr = Sr * Sr
    Sr = Sr * Sr
    S2 = V1 / sqrt(sqrt(1 + Sr / 25.62890625))
    PERC = V1 - S2
    V1 = S2
    PR += PERC

    # Convolution of unit hydrographs
    uh1 = update_uh(uh1, PR, uh1_ordinates)
    uh2 = update_uh(uh2, PR, uh2_ordinates)

    # Potential intercatchment semi-exchange
    Rr = V2 / x3
    ECH = x2 * Rr * Rr * Rr * sqrt(Rr)

    # routing store
    V2 = max(0, V2 + 0.9 * uh1[1] + ECH)
    Rr = V2 / x3
    Rr = Rr * Rr
    Rr = Rr * Rr
    R2 = V2 / sqrt(sqrt(1 + Rr))
    QR = V2 - R2
    V2 = R2

    # Runoff from direct branch QD
    QD = max(0, 0.1 * uh2[1] + ECH)

    # total runoff
    Q = QR + QD

    state = Dict(
        "uh1" => uh1,
        "uh2" => uh2,
        "uh1_ordinates" => uh1_ordinates,
        "uh2_ordinates" => uh2_ordinates,
        "production_store" => V1,
        "routing_store" => V2
    )

    return Q, state
end

# data expected to contain [obs_rain, obs_pet, obs_runoff, obs_runoff_sim_0]
function gr4j_simulate(data, params, curr_state)

    len = nrow(data)
    model_output = DataFrame(runoff_sim = fill(0.0, len))
    model_data = hcat(data, model_output)

    for i in 1:len
        rain = model_data[i, :obs_rain]
        pet = model_data[i, :obs_pet]

        runoff, new_state = gr4j_run_step(rain, pet, curr_state, params)
        curr_state = new_state

        #println(runoff, " ", curr_state["production_store"], " ", curr_state["routing_store"])

        model_data[i, :runoff_sim] = runoff
    end

    return model_data
end
