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

module OSTP

# Simple rainfall-runoff model for education purposes, dont actually use it!

export ostp_run_step, ostp_init_state
export ostp_params_from_array, ostp_params_to_array
export ostp_params_default, ostp_params_random
export ostp_params_range, ostp_params_range_trans, ostp_params_range_to_tuples
export ostp_params_trans, ostp_params_trans_inv

function ostp_params_from_array(arr)
    Dict(:capacity => arr[1], :loss => arr[2])
end

function ostp_params_to_array(pars)
    [pars[:capacity], pars[:loss]]
end

function ostp_params_default()
    ostp_params_from_array([350, 3])
end

function ostp_params_random(prange)
    quanta = 0.1
    params = gr4j_params_default()
    for p in [:capacity, :loss]
        params[p] = rand(prange[p][:low]:quanta:prange[p][:high])
    end
    return params
end

function ostp_params_range()
    Dict(
        :capacity => Dict(:low => 1.0, :high => 10000.0),
        :loss => Dict(:low => -100.0, :high => 100.0))
end

function ostp_params_range_to_tuples(prange)
    [
        (prange[:capacity][:low], prange[:capacity][:high]),
        (prange[:loss][:low], prange[:loss][:high])
    ]
end

# just a single storage
function ostp_init_state(pars)
    pars[:capacity] / 2
end

# One storage / two parameter model
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
