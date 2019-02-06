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
