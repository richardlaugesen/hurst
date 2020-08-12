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

module GR4J

using Hurst.Utils
using Hurst.Transformations

export gr4j_run_step, gr4j_init_state
export gr4j_params_from_array, gr4j_params_to_array
export gr4j_params_default, gr4j_params_random
export gr4j_params_range, gr4j_params_range_trans, gr4j_params_range_to_tuples
export gr4j_params_trans, gr4j_params_trans_inv

"""
    gr4j_params_from_array(arr)

Returns a Dictionary containing a parameter set ready to be used by the
`gr4j_run_step` function.

Sets the value of the `:x1`, `:x2`, `:x3` and `:x4` keys to the 1st, 2nd, 3rd
and 4th index values of the `arr` array.

Intentionally does not check if these parameter values are within any
acceptable range.

See also:
[`gr4j_params_to_array`](@ref),
[`gr4j_params_range`](@ref),
[`gr4j_run_step`](@ref)
"""
function gr4j_params_from_array(arr)::GR4JParameters
    GR4JParameters(arr[1], arr[2], arr[3], arr[4], gr4j_params_range())
end

"""
    gr4j_params_to_array(pars)

Returns an array containing GR4J parameter vaues from a parameter Dictionary
with keys defined by the `gr4j_params_from_array` function.

Sets the 1st, 2nd, 3rd and 4th index values of the returned array to the value
of the `:x1`, `:x2`, `:x3` and `:x4` keys in the `pars` Dictionary.

Intentionally does not check if these parameter values are within any
acceptable range.

See also:
[`gr4j_params_from_array`](@ref),
[`gr4j_params_range`](@ref)
"""
function gr4j_params_to_array(pars::GR4JParameters)
    [pars.x1, pars.x2, pars.x3, pars.x4]
end

"""
    gr4j_params_default()

Returns a Dictionary containing a reasonable set of GR4J parameter vaues with
keys defined by the `gr4j_params_from_array` function and ready to be used
by the `gr4j_run_step` function.

See also:
[`gr4j_params_from_array`](@ref),
[`gr4j_run_step`](@ref)
"""
function gr4j_params_default()::GR4JParameters
    gr4j_params_from_array([350, 0, 50, 0.5])
end

"""
    gr4j_params_random(prange)

Returns a Dictionary containing a random set of GR4J parameter vaues selected
with a uniform sampler within the parameter ranges specified by `prange`.

The `prange` argument should be a Dictionary with keys defined by the
`gr4j_params_range` function.

This set of random parameters has keys defined by the `gr4j_params_from_array`
function and is ready to be used by the `gr4j_run_step` function.

See also:
[`gr4j_params_from_array`](@ref),
[`gr4j_run_step`](@ref),
[`gr4j_params_range`](@ref)
"""
function gr4j_params_random(prange)::GR4JParameters
    quanta = 0.1
    params = gr4j_params_default()
    for p in [:x1, :x2, :x3, :x4]
        setfield!(params, p) = rand(getfield(prange, p)[0]:quanta:getfield(prange, p)[1])       # probably cant do this because not mutable
    end
    return params
end

"""
    gr4j_params_range()

Returns a Dictionary with reasonable ranges for GR4J parameter vaues.

These are used in the model calibration and random parameter sampling functions.

See also:
[`gr4j_params_from_array`](@ref),
[`gr4j_run_step`](@ref),
[`gr4j_params_random`](@ref)
"""
function gr4j_params_range()::GR4JParameterBounds
    GR4JParameterBounds((1, 10000), (-100, 100), (1, 5000), (0.5, 50))
end

"""
    gr4j_params_range_to_tuples(prange)

Returns an array of tuples containing the GR4J parameter ranges provided in the
`prange` Dictionary argument. This Dictionary should contain the keys defined by
the `gr4j_params_range` function.

See also: [`gr4j_params_range`](@ref)
"""
function gr4j_params_range_to_tuples(prange)
    [
        (prange[:x1][:low], prange[:x1][:high]),
        (prange[:x2][:low], prange[:x2][:high]),
        (prange[:x3][:low], prange[:x3][:high]),
        (prange[:x4][:low], prange[:x4][:high])
    ]
end

X4_TRANS_OFFSET = -(0.5 - 1e-9)

"""
    gr4j_param_trans(param, value)

Returns the `value` of a single GR4J parameter which has been transformed using
standard practice for a more uniform parameter search space to calibrate within.

The `param` Symbol should correspond to a key in the Dictionary returned by
the `gr4j_params_from_array` function.

See also:
[`gr4j_param_trans_inv`](@ref),
[`gr4j_params_from_array`](@ref),
[`gr4j_params_trans`](@ref)
"""
function gr4j_param_trans(param, value)
    if param == :x1
        return log_trans(value)
    elseif param == :x2
        return value
    elseif param == :x3
        return log_trans(value)
    elseif param == :x4
        return log_trans(value, X4_TRANS_OFFSET)
    end
end

"""
    gr4j_param_trans_inv(param, value)

Returns a single transformed GR4J parameter `value` which has been
back-transformed. The back-transformation performed is the inverse of the
transformations defined in the function `gr4j_param_trans`.

The `param` Symbol should correspond to a key in the Dictionary returned by
the `gr4j_params_from_array` function.

See also:
[`gr4j_param_trans(param, value),
[`gr4j_params_from_array`](@ref),
[`gr4j_param_trans`](@ref)
"""
function gr4j_param_trans_inv(param, value)
    if param == :x1
        return log_trans_inverse(value)
    elseif param == :x2
        return value
    elseif param == :x3
        return log_trans_inverse(value)
    elseif param == :x4
        return log_trans_inverse(value, X4_TRANS_OFFSET)
    end
end

"""
    gr4j_params_trans(pars)

Returns a set of GR4J parameters which has been transformed using
standard practice for a more uniform parameter search space to calibrate within.

The `pars` Dictionary should correspond to the that generated by the
`gr4j_params_from_array` function.

See also:
[`gr4j_params_trans_inv`](@ref),
[`gr4j_params_from_array`](@ref)
"""
function gr4j_params_trans(pars)
    for p in [:x1, :x2, :x3, :x4]
        pars[p] = gr4j_param_trans(p, pars[p])
    end
    return pars
end

"""
    gr4j_params_trans_inv(pars)

Returns a set of transformed GR4J parameters `pars` which have been
back-transformed. The back-transformation performed is the inverse of the
transformations used in the function `gr4j_params_trans`.

The `pars` Dictionary should correspond to the that generated by the
`gr4j_params_from_array` function.

See also:
[`gr4j_params_trans`](@ref),
[`gr4j_params_from_array`](@ref)
"""
function gr4j_params_trans_inv(pars)
    for p in [:x1, :x2, :x3, :x4]
        pars[p] = gr4j_param_trans_inv(p, pars[p])
    end
    return pars
end

"""
    gr4j_params_range_trans(prange)

Returns a Dictionary with reasonable ranges for GR4J parameter vaues which have
been transformed using the method defined in the `gr4j_param_trans` function.

See also:
[`gr4j_params_range`](@ref),
[`gr4j_run_step`](@ref),
[`gr4j_params_random`](@ref)
"""
function gr4j_params_range_trans(prange)
    for p in [:x1, :x2, :x3, :x4]
        prange[p][:low] = gr4j_param_trans(p, prange[p][:low])
        prange[p][:high] = gr4j_param_trans(p, prange[p][:high])
    end
    return prange
end

"""
    s_curve(variant, scale, x)

Returns the value at location `x` of a `variant` of an s-curve function
parameterised with a `scale`.

Is used to define the values of the GR4J unit hydrograph ordinates in the
function `create_uh_ordinates`.

See also:
[`create_uh_ordinates`](@ref),
[`gr4j_run_step`](@ref)
"""
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
        elseif x <= scale
            return 0.5 * (x / scale)^2.5
        elseif x < 2scale
            return 1 - 0.5 * (2 - x / scale)^2.5
        else
            return 1
        end
    end
end

"""
    create_uh_ordinates(variant, size, x4)

Returns an Array of `size` elements containing the GR4J unit hydrograph ordinates
for either of the two `variant` parameterised by the `x4` parameter.

Uses the `s_curve` function to determine the ordinate values and is used by the
`gr4j_init_state` function to create an initial state for GR4J, specifically
defining the unit hydrograph ordinate values used when updating the unit
hydrographs each time-step in the `gr4j_run_step` function.

See also:
[`s_curve`](@ref),
[`gr4j_init_state`](@ref),
[`gr4j_run_step`](@ref)
"""
function create_uh_ordinates(variant, size, x4)
    ordinates = zeros(size)
    for t in 1:size
        ordinates[t] = s_curve(variant, x4, t) - s_curve(variant, x4, t - 1)
    end
    return ordinates
end

"""
    update_uh(uh, volume, ordinates)

Returns an updated unit hydrograph Array after incrementing the `uh` and
convoluting with the `ordinates` and `volume`.

The ordinates are defined by the `create_uh_ordinates` function.

Used by the `gr4j_run_step` function when updating the model state, specifically
the two GR4J unit hydrographs.

See also:
[`create_uh_ordinates`](@ref),
[`gr4j_run_step`](@ref)
"""
function update_uh(uh, volume, ordinates)
    (volume * ordinates) + lshift(uh)
end

"""
    gr4j_init_state(pars)

Return a Dictionary containing an initial state for GR4J model. Uses a
standard method derived from a set of model parmaters, `pars`.

The `pars` argument should have keys defined by the `gr4j_params_from_array`
function.

Essential input for the first call to `gr4j_run_step` function to ensure the
unit hydrograph arrays are initialised to the correct size and ordinates are
specified correctly.

See also:
[`gr4j_params_from_array`](@ref),
[`gr4j_run_step`](@ref)
"""
function gr4j_init_state(pars)
    x4 = pars[:x4]
    n = Int(ceil(x4))

    return Dict(
        :uh1 => zeros(n),
        :uh2 => zeros(2n),
        :uh1_ordinates => create_uh_ordinates(1, n, x4),
        :uh2_ordinates => create_uh_ordinates(2, 2n, x4),
        :production_store => 0,
        :routing_store => 0
    )
end

"""
    gr4j_run_step(rain, pet, state, pars)

Run a single time-step of the GR4J model. Model is forced by the `rain` and `pet`
(floats) supplied and uses the `state` for initial conditions. Model parameters
used are provided in the `pars` argument.

The `pars` argument should have keys defined by the `gr4j_params_from_array`
function and the `state` with keys defined by `gr4j_init_state`.

The function then returns the runoff and an updated state. This updated state is
typically used as the input state for the next time-step in a time-series simulation.

See also:
[`gr4j_init_state`](@ref),
[`gr4j_params_from_array`](@ref)
"""
function gr4j_run_step(rain, pet, state, pars)

    # parameters
    x1 = pars[:x1]
    x2 = pars[:x2]
    x3 = pars[:x3]
    x4 = pars[:x4]

    # state
    uh1 = state[:uh1]
    uh2 = state[:uh2]
    v1 = state[:production_store]
    v2 = state[:routing_store]
    ord1 = state[:uh1_ordinates]
    ord2 = state[:uh2_ordinates]

    # forcing
    p = rain
    e = pet

    # interception and production store
    if p >= e
        ws = min(13, (p - e) / x1)
        es = 0
        ps = x1 * (1 - (v1 / x1)^2) * tanh(ws) / (1 + (v1 / x1) * tanh(ws))
        pr = rain - e - ps
    else
        ws = min(13, (e - p) / x1)
        es = v1 * (2 - v1 / x1) * tanh(ws) / (1 + (1 - v1 / x1) * tanh(ws))
        ps = 0
        pr = 0
    end
    v1 -= es - ps

    # Percolation from production store
    perc = v1 * (1 - (1 + (v1 / x1)^4 / 25.62890625)^-0.25)
    v1 -= perc
    pr += perc

    # Convolution of unit Hydrographs
    uh1 = update_uh(uh1, pr, ord1)
    uh2 = update_uh(uh2, pr, ord2)

    # Potential intercatchment semi-exchange
    ech = x2 * (v2 / x3)^3.5

    # routing store
    v2 = max(0, v2 + 0.9 * uh1[1] + ech)
    qr = v2 * (1 - (1 + (v2 / x3)^4)^-0.25)
    v2 -= qr

    # Runoff from direct branch qd
    qd = max(0, 0.1 * uh2[1] + ech)

    # total runoff
    q = qr + qd

    state = Dict(
        :uh1 => uh1,
        :uh2 => uh2,
        :uh1_ordinates => ord1,
        :uh2_ordinates => ord2,
        :production_store => v1,
        :routing_store => v2
    )

    return q, state
end

end
