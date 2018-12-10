using DataFrames

# data expected to contain [obs_rain, obs_pet, obs_runoff, obs_runoff_sim_0]
function simulate(timestep_fnc, data, params, init_state)

    len = nrow(data)
    model_output = DataFrame(runoff_sim = fill(0.0, len))
    model_data = hcat(data, model_output)

    curr_state = init_state
    for i in 1:len
        rain = model_data[i, :obs_rain]
        pet = model_data[i, :obs_pet]

        runoff, new_state = timestep_fnc(rain, pet, curr_state, params)
        curr_state = new_state

        #println(runoff, " ", curr_state["production_store"], " ", curr_state["routing_store"])

        model_data[i, :runoff_sim] = runoff
    end

    return model_data
end
