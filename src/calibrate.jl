using BlackBoxOptim

# sample one point from objective function in parameter space
function sampler(functions, data, pars_trans_array)

    # unpack dictionary of model functions
    timestep = functions["run_model_time_step"]
    init_state = functions["init_state"]
    pars_from_array = functions["params_from_array"]
    obj_fnc = functions["objective_function"]
    pars_trans_inv = functions["params_inverse_transform"]

    # detransform parameter set, simulate, and calculate obj func value
    pars = pars_trans_inv(pars_from_array(pars_trans_array))
    init_state = init_state(pars)
    result = simulate(timestep, data, pars, init_state)

    return obj_fnc(result["runoff_obs"], result["runoff_sim"])
end

# find an optimal set of parameters closed over the transformed range
# using a numerical optimisation method for max_iter number of iterations
# see methods here: https://github.com/robertfeldt/BlackBoxOptim.jl#existing-optimizers
function calibrate(functions, data, prange, max_iter, method)

    # unpack dictionary of model functions
    pars_from_array = functions["params_from_array"]
    pars_trans_inv = functions["params_inverse_transform"]
    prange_trans = functions["params_range_transform"]
    prange_to_tuples = functions["params_range_to_tuples"]

    # optimise over transformed parameter space using a partial function call
    opt = bboptimize(
        pars_trans -> sampler(functions, data, pars_trans);
        SearchRange = prange_to_tuples(prange_trans(prange)),
        Method = method,
        MaxFuncEvals = max_iter)

    # detransform the optimial parameter set and return with obj func value
    best_params = pars_trans_inv(pars_from_array(best_candidate(opt)))
    best_obj = best_fitness(opt)

    return best_params, best_obj
end
