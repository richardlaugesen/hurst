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

module Visualisations

using Plots

export hydrograph, hyscatter

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

"""
    hyscatter(obs, sim, labels)

Generates a simple scatter plot of a simulation series
against an observation series.

Include a plot `title`, series `label`, and measurement `units` for the axis.
"""
function hyscatter(obs, sim, title, label, units)

    limit = max(maximum(obs), maximum(sim)) * 1.1

    scatter(obs, sim,
        alpha=0.6,
        markersize=1,
        xlim=(0, limit),
        ylim=(0, limit),
        title=title,
        label=label,
        xlabel="Observations ($units)", ylabel="Simulation ($units)",
        grid=true,
        size=(900, 700))
end

end
