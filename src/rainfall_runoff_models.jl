function gr4j_init_state(params)
    x4 = params["x4"]
    n = Int(ceil(x4))

    Dict(
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
        elseif x < scale
            return 0.5 * (x / scale)^2.5
        elseif x < 2scale
            return 1 - 0.5 * (2 - x / scale)^2.5
        else
            return 1
        end
    end
end

function create_uh_ordinates(variant, size, x4)
    uh = zeros(size)
    for t in 1:size
        uh[t] = s_curve(variant, x4, t) - s_curve(variant, x4, t - 1)
    end
    return uh
end

function update_uh(uh, volume, ordinates)
    uh = circshift(uh, 1)
    uh[1] = 0
    if volume == 0
        return uh
    else
        return (volume * ordinates) + uh
    end
end

function gr4j_random_parameters()
    Dict(
        "x1" => rand(1:6000),
        "x2" => rand(-3:0.1:3),
        "x3" => rand(1:1000),
        "x4" => rand(0.1:0.1:14)
    )
end

function gr4j_reasonable_parameters()
    Dict(
        "x1" => 800,
        "x2" => 2,
        "x3" => 400,
        "x4" => 3
    )
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

    # effective rainfall
    if rain > pet
        net_evap = 0
        scaled_net_precip = (rain - pet) / x1
        scaled_net_precip = scaled_net_precip > 13 ? 13 : scaled_net_precip
        tanh_scaled_net_precip = tanh(scaled_net_precip)
        reservoir_production = (x1 * (1 - (production_store / x1)^2) * tanh_scaled_net_precip) / (1 + production_store / x1 * tanh_scaled_net_precip)
        routing_pattern = rain - pet - reservoir_production
    else
        scaled_net_evap = (pet - rain) / x1
        scaled_net_evap = scaled_net_evap > 13 ? 13 : scaled_net_evap
        tanh_scaled_net_evap = tanh(scaled_net_evap)
        ps_div_x1 = (2 - production_store / x1) * tanh_scaled_net_evap
        net_evap = production_store * (ps_div_x1) / (1 + (1 - production_store / x1) * tanh_scaled_net_evap)
        reservoir_production = 0
        routing_pattern = 0
    end

    # production and routing
    production_store = production_store - net_evap + reservoir_production
    percolation = production_store / (1 + (production_store / 2.25 / x1)^4)^0.25
    routing_pattern = routing_pattern + (production_store - percolation)
    production_store = percolation

    # update unit hydrographs
    uh1 = update_uh(uh1, routing_pattern, uh1_ordinates)
    uh2 = update_uh(uh2, routing_pattern, uh2_ordinates)

    # groundwater exchange
    groundwater_exchange = x2 * (routing_store / x3)^3.5
    routing_store = max(0, routing_store + uh1[1] * 0.9 + groundwater_exchange)

    # runoff
    r2 = routing_store / (1 + (routing_store / x3)^4)^0.25
    qr = routing_store - r2
    routing_store = r2

    qd = max(0, uh2[1] * 0.1 + groundwater_exchange)
    q = qr + qd

    updated_state = Dict(
        "uh1" => uh1,
        "uh2" => uh2,
        "uh1_ordinates" => uh1_ordinates,
        "uh2_ordinates" => uh2_ordinates,
        "production_store" => production_store,
        "routing_store" => routing_store
    )

    return q, updated_state
end

# a simple one storage, two parameter rainfall-runoff model
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
