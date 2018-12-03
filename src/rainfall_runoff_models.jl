using DataFrames

function gr4j_init_state(params)
    x1 = params["x1"]
    x3 = params["x3"]
    x4 = params["x4"]
    n = Int(ceil(x4))

    return Dict(
        "uh1" => zeros(n),
        "uh2" => zeros(2n),
        "uh1_ordinates" => create_uh_ordinates(1, n, x4),
        "uh2_ordinates" => create_uh_ordinates(2, 2n, x4),
        "production_store" => 0, # 0.6 * x1,
        "routing_store" => 0 # 0.7 * x3
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

function rshift(v)
    v = circshift(v, 1)
    v[1] = 0
    return v
end

function update_uh(uh, volume, ordinates)
    (volume * ordinates) + rshift(uh)
end

function gr4j_parameters(x1, x2, x3, x4)
    Dict(
        "x1" => x1,
        "x2" => x2,
        "x3" => x3,
        "x4" => x4
    )
end

function gr4j_random_parameters()
    gr4j_parameters(rand(1:6000), rand(-3:0.1:3), rand(1:1000), rand(0.1:0.1:14))
end

function gr4j_reasonable_parameters()
    gr4j_parameters(800, 2, 400, 3)
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

    # Variables storage
    #       MISC( 1)=E             ! PE     ! observed potential evapotranspiration [mm/day]
    #       MISC( 2)=P1            ! Precip ! observed total precipitation [mm/day]
    #       MISC( 3)=St(1)  [V1]   ! Prod   ! production store level (St(1)) [mm]
    #       MISC( 4)=PN            ! Pn     ! net rainfall [mm/day]
    #       MISC( 5)=PS            ! Ps     ! part of Ps filling the production store [mm/day]
    #       MISC( 6)=AE            ! AE     ! actual evapotranspiration [mm/day]
    #       MISC( 7)=PERC          ! Perc   ! percolation (PERC) [mm/day]
    #       MISC( 8)=PR            ! PR     ! PR=PN-PS+PERC [mm/day]
    #       MISC( 9)=StUH1(1)      ! Q9     ! outflow from UH1 (Q9) [mm/day]
    #       MISC(10)=StUH2(1)      ! Q1     ! outflow from UH2 (Q1) [mm/day]
    #       MISC(11)=St(2)  [V2]   ! Rout   ! routing store level (St(2)) [mm]
    #       MISC(12)=EXCH          ! Exch   ! potential semi-exchange between catchments (EXCH) [mm/day]
    #       MISC(13)=AEXCH1 	  	 ! AExch1 ! actual exchange between catchments from branch 1 (AEXCH1) [mm/day]
    #       MISC(14)=AEXCH2        ! AExch2 ! actual exchange between catchments from branch 2 (AEXCH2) [mm/day]
    #       MISC(15)=AEXCH1+AEXCH2 ! AExch  ! actual total exchange between catchments (AEXCH1+AEXCH2) [mm/day]
    #       MISC(16)=QR            ! QR     ! outflow from routing store (QR) [mm/day]
    #       MISC(17)=QD            ! QD     ! outflow from UH2 branch after exchange (QD) [mm/day]
    #       MISC(18)=Q ! Qsim   ! simulated outflow at catchment outlet [mm/day]

    # mapping to original fortran variable names
    P1 = rain
    E = pet
    B = 0.9
    V1 = production_store
    V2 = routing_store

    # interception and production store
    if P1 < E
        EN = E - P1
        PN = 0
        WS = EN / x1
        WS = WS > 13 ? 13 : WS
        TWS = tanh(WS)
        Sr = V1 / x1
        ER = V1 * (2 - Sr) * TWS / (1 + (1 - Sr) * TWS)
        AE = ER + P1
        V1 -= ER
        PS = 0
        PR = 0
    else
        EN = 0
        AE = E
        PN = P1 - E
        WS = PN / x1
        WS = WS > 13 ? 13 : WS
        TWS = tanh(WS)
        Sr = V1 / x1
        PS = x1 * (1 - Sr * Sr) * TWS / (1 + Sr * TWS)
        PR = PN - PS
        V1 += PS
    end

    # Percolation from production store
    V1 = V1 < 0 ? 0 : V1
    Sr = V1 / x1
    Sr = Sr * Sr
    Sr = Sr * Sr
    PERC = V1 * (1 - 1 / sqrt(sqrt( 1 + Sr / 25.62891)))  # (9/4)^4 = 25.62891
    V1 -= PERC

    # Split of effective rainfall into the two routing components
    PRHU1 = PR * B
    PRHU2 = PR * (1 - B)

    # Convolution of unit hydrographs
    uh1 = update_uh(uh1, PRHU1, uh1_ordinates)
    uh2 = update_uh(uh2, PRHU2, uh2_ordinates)

    # Potential intercatchment semi-exchange
    Rr = V2 / x3
    EXCH = x2 * Rr * Rr * Rr * sqrt(Rr)  # x2 * (V2 / x3)^3.5

    # routing store
    AEXCH1 = V2 * uh1[1] + EXCH < 0 ? -V2 - uh1[1] : EXCH
    V2 += uh1[1] + EXCH
    V2 = V2 < 0 ? 0 : V2
    Rr = V2 / x3
    Rr = Rr * Rr
    Rr = Rr * Rr
    QR = V2 * (1 - 1 / sqrt(sqrt(1 + Rr))) # c2 * (1 - (1 + (V2/x3)^4)^-0.25)
    V2 -= QR

    # Runoff from direct branch QD
    AEXCH2 = uh2[1] + EXCH < 0 ? -uh2[1] : EXCH
    QD = max(0, uh2[1] + EXCH)

    # total runoff
    Q = QR + QD
    Q = Q < 0 ? 0 : Q

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
