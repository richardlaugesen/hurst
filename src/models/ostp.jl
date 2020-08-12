# Copyright 2018-2020 Richard Laugesen
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

module OSTP

export ostp_run_step, ostp_init_state
export ostp_params_from_array, ostp_params_to_array
export ostp_params_default, ostp_params_random
export ostp_params_range, ostp_params_range_trans, ostp_params_range_to_tuples
export ostp_params_trans, ostp_params_trans_inv

"""
    ostp_params_from_array(arr)

Returns a Dictionary containing a parameter set ready to be used by the
`ostp_run_step` function.

Sets the value of the `:capacity`, `:loss` keys to the 1st and 2nd index values
of the `arr` array.

Intentionally does not check if these parameter values are within any
acceptable range.

See also:
[`ostp_params_to_array`](@ref),
[`ostp_params_range`](@ref),
[`ostp_run_step`](@ref)
"""
function ostp_params_from_array(arr)
    Dict(:capacity => arr[1], :loss => arr[2])
end

"""
    ostp_params_to_array(pars)

Returns an array containing ostp parameter vaues from a parameter Dictionary
with keys defined by the `ostp_params_from_array` function.

Sets the 1st and 2nd index values of the returned array to the value
of the `:capacity` and `:loss` keys in the `pars` Dictionary.

Intentionally does not check if these parameter values are within any
acceptable range.

See also:
[`ostp_params_from_array`](@ref),
[`ostp_params_range`](@ref)
"""
function ostp_params_to_array(pars)
    [pars[:capacity], pars[:loss]]
end

"""
    ostp_params_default()

Returns a Dictionary containing a reasonable set of ostp parameter vaues with
keys defined by the `ostp_params_from_array` function and ready to be used
by the `ostp_run_step` function.

See also:
[`ostp_params_from_array`](@ref),
[`ostp_run_step`](@ref)
"""
function ostp_params_default()
    ostp_params_from_array([350, 3])
end

"""
    ostp_params_random(prange)

Returns a Dictionary containing a random set of ostp parameter vaues selected
with a uniform sampler within the parameter ranges specified by `prange`.

The `prange` argument should be a Dictionary with keys defined by the
`ostp_params_range` function.

This set of random parameters has keys defined by the `ostp_params_from_array`
function and is ready to be used by the `ostp_run_step` function.

See also:
[`ostp_params_from_array`](@ref),
[`ostp_run_step`](@ref),
[`ostp_params_range`](@ref)
"""
function ostp_params_random(prange)
    quanta = 0.1
    params = ostp_params_default()
    for p in [:capacity, :loss]
        params[p] = rand(prange[p][:low]:quanta:prange[p][:high])
    end
    return params
end

"""
    ostp_params_range()

Returns a Dictionary with reasonable ranges for ostp parameter vaues.

These are used in the model calibration and random parameter sampling functions.

See also:
[`ostp_params_from_array`](@ref),
[`ostp_run_step`](@ref),
[`ostp_params_random`](@ref)
"""
function ostp_params_range()
    Dict(
        :capacity => Dict(:low => 1.0, :high => 10000.0),
        :loss => Dict(:low => -100.0, :high => 100.0))
end

"""
    ostp_params_range_to_tuples(prange)

Returns an array of tuples containing the ostp parameter ranges provided in the
`prange` Dictionary argument. This Dictionary should contain the keys defined by
the `ostp_params_range` function.

See also: [`ostp_params_range`](@ref)
"""
function ostp_params_range_to_tuples(prange)
    [
        (prange[:capacity][:low], prange[:capacity][:high]),
        (prange[:loss][:low], prange[:loss][:high])
    ]
end

"""
    ostp_init_state(pars)

Return a Dictionary containing an initial state for ostp model. Uses a
standard method derived from a set of model parmaters, `pars`.

The `pars` argument should have keys defined by the `ostp_params_from_array`
function.

See also:
[`ostp_params_from_array`](@ref),
[`ostp_run_step`](@ref)
"""
function ostp_init_state(pars)
    pars[:capacity] / 2
end


"""
    ostp_run_step(rain, pet, state, pars)

Run a single time-step of the ostp model. ostp a simple one storage, two parameter
model used for educational purposes. To outline basic concepts in conceptual
rainfall-runoff models and how to implement a rainfall-runoff model within Hurst.
Please do not use it for actual water resource modelling!

The model is forced by the `rain` and `pet` (floats) supplied and uses the
`state` for initial conditions. Model parameters used are provided in the `pars` argument.

The `pars` argument should have keys defined by the `ostp_params_from_array`
function and the `state` with keys defined by `ostp_init_state`.

The function then returns the runoff and an updated state. This updated state is
typically used as the input state for the next time-step in a time-series simulation.

See also:
[`ostp_init_state`](@ref),
[`ostp_params_from_array`](@ref)
"""
function ostp_run_step(rain, pet, storage, params)
    capacity = params[:capacity]
    loss = params[:loss]

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

    return runoff, storage
end

end
