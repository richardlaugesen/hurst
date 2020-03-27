# Copyright 2018-2020 Tiny Rock Pty Ltd
#
# This file is part of Hurst
#
# Hurst is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Hurst is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Hurst.  If not, see <https://www.gnu.org/licenses/>.

module Calibration

using Hurst.Simulation

using BlackBoxOptim

export calibrate

"""
    calibrate(rain, pet, runoff, functions, opt_options)

Attempts to minimise an objective function between the `runoff` and a simulation
from a rainfall-runoff model forced by `rain` and `pet`.

Returns an optimal set of parameters and the associated objective function value.

Will error if the `rain`, `pet` and `runoff` arrays are different lengths.

Functions to define the model and parameters are defined in the `functions`
Dictionary. Refer to example to understand meaning.

    functions[:run_model_time_step]
    functions[:init_state]
    functions[:params_from_array]
    functions[:objective_function]
    functions[:params_inverse_transform]
    functions[:params_range_transform]
    functions[:params_range_to_tuples]
    functions[:params_range]

If the `:params_inverse_transform` key is defined in the `functions` Dictionary
then it will assume the optimisation is in transformed space and will attempt to
transform and detransform paramter sets and ranges. Will error if ALL the
required transformation-related Dictionary keys are not defined.

Currently uses the
[BlackBoxOptim.jl](https://github.com/robertfeldt/BlackBoxOptim.jl)
package for numerical optimisation and the following options may be specified
in the `opt_options` Dictionary, detailed information can be
found at [BlackBoxOptim.jl options](https://github.com/robertfeldt/BlackBoxOptim.jl#configurable-options):

    opt_options[:method]
    opt_options[:max_iterations]
    opt_options[:max_time]
    opt_options[:trace_interval]
    opt_options[:trace_mode])

A typical set of `function` and `opt_options` to run a 5 minute calibration
using the GR4J model in transformed paramter space with the Nash
Sutcliffe Efficiency objective function could be:

    # build up dictionary of model functions needed for calibration
    functions = Dict()
    functions[:run_model_time_step] = gr4j_run_step
    functions[:init_state] = gr4j_init_state
    functions[:params_from_array] = gr4j_params_from_array
    functions[:objective_function] = (obs, sim) -> -1 * nse(obs, sim)
    functions[:params_inverse_transform] = gr4j_params_trans_inv
    functions[:params_range_transform] = gr4j_params_range_trans
    functions[:params_range_to_tuples] = gr4j_params_range_to_tuples
    functions[:params_range] = gr4j_params_range

    # build up dictionary of optimiser options needed for calibration
    opt_options = Dict()
    opt_options[:max_iterations] = false
    opt_options[:max_time] = 5 * 60
    opt_options[:trace_interval] = 15
    opt_options[:trace_mode] = :verbose
    opt_options[:method] = :adaptive_de_rand_1_bin_radiuslimited

    # calibrate the model
    opt_pars, opt_neg_nse = calibrate(data[:rain], data[:pet], data[:runoff_obs], functions, opt_options)
    opt_nse = -1 * opt_neg_nse

See also: [`simulate`](@ref)
"""
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

end
