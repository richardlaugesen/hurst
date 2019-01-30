# Copyright 2019 Richard Laugesen
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
function sampler(functions, data, pars_trans_array)

    # unpack dictionary of model functions
    timestep = functions[:run_model_time_step]
    init_state = functions[:init_state]
    pars_from_array = functions[:params_from_array]
    obj_fnc = functions[:objective_function]
    pars_trans_inv = functions[:params_inverse_transform]

    # detransform parameter set, simulate, and calculate obj func value
    pars = pars_trans_inv(pars_from_array(pars_trans_array))
    init_state = init_state(pars)
    sim = simulate(timestep, data, pars, init_state)

    return obj_fnc(data[:runoff_obs], sim)
end

# find an optimal set of parameters closed over the transformed range
# using a bunch of options for the numerical optimiser
# see methods here: https://github.com/robertfeldt/BlackBoxOptim.jl#existing-optimizers
function calibrate(functions, opt_options, data, prange)

    # unpack dictionary of model functions
    pars_from_array = functions[:params_from_array]
    pars_trans_inv = functions[:params_inverse_transform]
    prange_trans = functions[:params_range_transform]
    prange_to_tuples = functions[:params_range_to_tuples]

    # optimise over transformed parameter space using a partial function call
    opt = bboptimize(
        pars_trans -> sampler(functions, data, pars_trans);
        SearchRange = prange_to_tuples(prange_trans(prange)),
        Method = opt_options[:method],
        MaxFuncEvals = opt_options[:max_iterations],
        MaxTime = opt_options[:max_time],
        TraceInterval = opt_options[:trace_interval])

    # detransform the optimial parameter set and return with obj func value
    best_params = pars_trans_inv(pars_from_array(best_candidate(opt)))
    best_obj = best_fitness(opt)

    return best_params, best_obj
end
