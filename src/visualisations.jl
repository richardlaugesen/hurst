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

module Visualisations

using Plots

export hydrograph

"""
    hydrograph(rain, runoffs, runoff_labels)

Generates a simple combined hydrograph and hyetograph figure.

Multiple traces of runoff may be plotted by passing an array of arrays for
`runoff` and associated `runoff_labels`.

Datetime tick marks are not plotted, only timesteps.
"""
function hydrograph(rain, runoffs, runoff_labels)
    p1 = plot(
            rain,
            seriestype=:bar,
            ylabel="Rain (mm)",
            legend=false,
            grid=true,
            yflip=true,
            xaxis=false)

    p2 = plot(
            runoffs,
            xlabel="Timestep", ylabel="Runoff (mm)",
            label=runoff_labels,
            grid=true,
            lw=1.5)

    plot(
        p1, p2,
        layout=grid(2, 1, heights=[0.3, 0.7]),
        size=(900, 700))
end

end
