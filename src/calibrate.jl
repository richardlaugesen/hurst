using BlackBoxOptim

# sample one point from objective function in parameter space
function sampler(timestep_f, init_state_f, param_f, obj_f, pars_inv_trans_f, data, transformed_pars_a)
    transformed_pars = param_f(transformed_pars_a)
    pars = pars_inv_trans_f(transformed_pars)

    init_state = init_state_f(pars)
    result = simulate(timestep_f, data, pars, init_state)

    obj = obj_f(data[:obs_runoff], result[:runoff_sim])
    return obj
end

# find optimal set of parameters closed of the range
function calibrate(timestep_f, init_state_f, param_f, obj_f, pars_inv_trans_f, data, transformed_pars_range)

    # partial function pass in array of transformed parameters
    sampler_par = transformed_pars_a -> sampler(
        timestep_f,
        init_state_f,
        param_f,
        obj_f,
        pars_inv_trans_f,
        data,
        transformed_pars_a)

    optim = bboptimize(sampler_par; SearchRange=transformed_pars_range)

    return best_candidate(optim), best_fitness(optim)
end
