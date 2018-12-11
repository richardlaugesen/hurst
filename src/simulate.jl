function simulate(timestep, data, pars, init_state)
    rain = data["rain"]
    pet = data["pet"]
    len = length(rain)
    sim = zeros(len)

    curr_state = init_state
    for i in 1:len
        sim[i], new_state = timestep(rain[i], pet[i], curr_state, pars)
        curr_state = new_state
        #println(runoff, " ", curr_state["production_store"], " ", curr_state["routing_store"])
    end

    data["runoff_sim"] = sim
    return data
end
