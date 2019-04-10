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

module Simulation

export simulate

"""
    simulate(timestep_fnc, rain, pet, pars, init_state)

Returns a runoff simulation by forcing a rainfall-runoff model with the `rain`
and `pet` timeseries.

The rainfall-runoff model is defined by the `timestep_fnc` function and `pars`
model parameters Dictionary. This function is expected to return runoff for a
single timestep of rain and pet. The model will be initalised with the
`init_state` initial state Dictionary.

Will error if the `rain` and `pet` arrays are different lengths.
"""
function simulate(timestep_fnc, rain, pet, pars, init_state)
    len = length(rain)
    sim = zeros(len)

    curr_state = init_state
    for i in 1:len
        sim[i], new_state = timestep_fnc(rain[i], pet[i], curr_state, pars)
        curr_state = new_state
    end

    return sim
end

end
