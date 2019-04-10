# Copyright 2018-2019 Richard Laugesen
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

# -------------------------------------------------
# parameters and ranges
# -------------------------------------------------

module GR4J

using Hurst.Utils
using Hurst.Transformations

export gr4j_run_step, gr4j_init_state
export gr4j_params_from_array, gr4j_params_to_array
export gr4j_params_default, gr4j_params_random
export gr4j_params_range, gr4j_params_range_trans, gr4j_params_range_to_tuples
export gr4j_params_trans, gr4j_params_trans_inv

function gr4j_params_from_array(arr)
    Dict(:x1 => arr[1], :x2 => arr[2], :x3 => arr[3], :x4 => arr[4])
end

function gr4j_params_to_array(pars)
    [pars[:x1], pars[:x2], pars[:x3], pars[:x4]]
end

function gr4j_params_default()
    gr4j_params_from_array([350, 0, 50, 0.5])
end

function gr4j_params_random(prange)
    quanta = 0.1
    params = gr4j_params_default()
    for p in [:x1, :x2, :x3, :x4]
        params[p] = rand(prange[p][:low]:quanta:prange[p][:high])
    end
    return params
end

function gr4j_params_range()
    Dict(
        :x1 => Dict(:low => 1.0, :high => 10000.0),
        :x2 => Dict(:low => -100.0, :high => 100.0),
        :x3 => Dict(:low => 1.0, :high => 5000.0),
        :x4 => Dict(:low => 0.5, :high => 50.0))
end

function gr4j_params_range_to_tuples(prange)
    [
        (prange[:x1][:low], prange[:x1][:high]),
        (prange[:x2][:low], prange[:x2][:high]),
        (prange[:x3][:low], prange[:x3][:high]),
        (prange[:x4][:low], prange[:x4][:high])
    ]
end

# -------------------------------------------------
# parameter transformations
# -------------------------------------------------

X4_TRANS_OFFSET = -(0.5 - 1e-9)

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

function gr4j_params_trans(pars)
    for p in [:x1, :x2, :x3, :x4]
        pars[p] = gr4j_param_trans(p, pars[p])
    end
    return pars
end

function gr4j_params_trans_inv(pars)
    for p in [:x1, :x2, :x3, :x4]
        pars[p] = gr4j_param_trans_inv(p, pars[p])
    end
    return pars
end

function gr4j_params_range_trans(prange)
    for p in [:x1, :x2, :x3, :x4]
        prange[p][:low] = gr4j_param_trans(p, prange[p][:low])
        prange[p][:high] = gr4j_param_trans(p, prange[p][:high])
    end
    return prange
end

# -------------------------------------------------
# initial state
# -------------------------------------------------

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

# -------------------------------------------------
# unit Hurstgraphs
# -------------------------------------------------

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

function create_uh_ordinates(variant, size, x4)
    ordinates = zeros(size)
    for t in 1:size
        ordinates[t] = s_curve(variant, x4, t) - s_curve(variant, x4, t - 1)
    end
    return ordinates
end

function update_uh(uh, volume, ordinates)
    (volume * ordinates) + lshift(uh)
end

# -------------------------------------------------
# model run for single timestep
# -------------------------------------------------

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

    # Convolution of unit Hurstgraphs
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
