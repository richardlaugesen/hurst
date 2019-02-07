# Copyright 2018-2019 Richard Laugesen
#
# This file is part of Hydro.jl
#
# Hydro.jl is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Hydro.jl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Hydro.jl.  If not, see <https://www.gnu.org/licenses/>.

using BlackBoxOptim

# sample one point from objective function in parameter space
function sampler(rain, pet, runoff_obs, pars_array, functions)

    # unpack dictionary of model functions
    timestep = functions[:run_model_time_step]
    init_state = functions[:init_state]
    pars_from_array = functions[:params_from_array]
    obj_fnc = functions[:objective_function]

    # get the parameter set
    pars = pars_from_array(pars_array)

    # detransform parameter set if transform function provided
    if :params_inverse_transform in keys(functions)
        pars_trans_inv = functions[:params_inverse_transform]
        pars = pars_trans_inv(pars)
    end

    # simulate, and calculate obj func value
    init_state = init_state(pars)
    runoff_sim = simulate(timestep, rain, pet, pars, init_state)

    return obj_fnc(runoff_obs, runoff_sim)
end

# find an optimal set of parameters closed over the range
# using a bunch of options for the numerical optimiser
# can be in transformed space
# see methods here: https://github.com/robertfeldt/BlackBoxOptim.jl#existing-optimizers
function calibrate(rain, pet, runoff, functions, opt_options)

    # assumed to be in transformed space if ONE function provided
    in_transformed_space = :params_inverse_transform in keys(functions)

    # unpack dictionary of model functions and get params range
    pars_from_array = functions[:params_from_array]
    prange_to_tuples = functions[:params_range_to_tuples]
    prange = functions[:params_range]()

    # transform the parameter range if in transformed space
    if in_transformed_space
        prange_trans = functions[:params_range_transform]
        prange = prange_trans(prange)
    end

    # optimise over parameter space using a partial function call
    opt = bboptimize(
        pars -> sampler(rain, pet, runoff, pars, functions);
        SearchRange = prange_to_tuples(prange),
        Method = opt_options[:method],
        MaxFuncEvals = opt_options[:max_iterations],
        MaxTime = opt_options[:max_time],
        TraceInterval = opt_options[:trace_interval],
        TraceMode = opt_options[:trace_mode])

    # get the best parameter set and objective value
    best_params = pars_from_array(best_candidate(opt))
    best_obj = best_fitness(opt)

    # detransform parameter set if in transformed space
    if in_transformed_space
        pars_trans_inv = functions[:params_inverse_transform]
        best_params = pars_trans_inv(best_params)
    end

    return best_params, best_obj
end
