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

module Value

export confusion, confusion_scaled
export cost_loss_verkade, cost_loss_roulin, cost_loss

"""
    confusion(hits, misses, false_alarms, quiets)

Returns a Dict containing fields of a
[confusion matrix](https://en.wikipedia.org/wiki/Confusion_matrix) with the
various common names used for each combination of the 2x2 grid.

See also: [`confusion_scaled(hits, misses, false_alarms, quiets)`](@ref)
"""
function confusion(hits, misses, false_alarms, quiets)
    Dict(
        :hits => hits,
        :true_positives => hits,

        :misses => misses,
        :false_negatives => misses,
        :type_ii_error => misses,
        :missed_events => misses,

        :false_alarms => false_alarms,
        :false_positive => false_alarms,
        :type_i_error => false_alarms,

        :correct_misses => quiets,
        :true_negatives => quiets,
        :quiets => quiets,
        :correct_negatives => quiets
    )
end

"""
    confusion_scaled(hits, misses, false_alarms, quiets)

Returns a Dict containing fields of a
[confusion matrix](https://en.wikipedia.org/wiki/Confusion_matrix) with the
various common names used for each combination of the 2x2 grid scaled to be
relative to the number of events and non-events
(hits + misses + false_alarms + quiets).

See also: [`confusion(hits, misses, false_alarms, quiets)`](@ref)
"""
function confusion_scaled(hits, misses, false_alarms, quiets)
    total = hits + misses + false_alarms + quiets
    return confusion(hits/total, misses/total, false_alarms/total, quiets/total)
end

"""
    cost_loss_verkade(costs, losses, scaled_conf)

Returns the relative economic value of a forecast system using a
the cost-loss model using the cost-loss ratio (`costs`, `losses`) and confusion
matrix scaled by the total events and non-events `scaled_conf`.

Verkade, J. S., and M. G. F. Werner. “Estimating the Benefits of Single Value
and Probability Forecasting for Flood Warning.” Hydrology and Earth System
Sciences 15, no. 12 (December 20, 2011): 3751–65.
[https://doi.org/10.5194/hess-15-3751-2011](https://doi.org/10.5194/hess-15-3751-2011).

See also:
[`confusion_scaled(hits, misses, false_alarms, quiets)`](@ref),
[`cost_loss(costs, losses, scaled_conf, method)`](@ref),
[`cost_loss_roulin(costs, losses, scaled_conf)`](@ref)
"""
function cost_loss_verkade(costs, losses, scaled_conf)
    h = scaled_conf[:hits]
    m = scaled_conf[:misses]
    f = scaled_conf[:false_alarms]

    r = costs / losses  # cost-loss ratio
    o = h + m           # observed relative frequency

    rev = (o - (h + f) * r - m) / (o * (1 - r))

    return rev
end

"""
    cost_loss_roulin(costs, losses, scaled_conf)

Returns the relative economic value of a forecast system using a
the cost-loss model using the cost-loss ratio (`costs`, `losses`) and confusion
matrix scaled by the total events and non-events `scaled_conf`.

Roulin, E. “Skill and Relative Economic Value of Medium-Range Hydrological
Ensemble Predictions.” Hydrology and Earth System Sciences 11, no. 2 (2007):
725–37. [https://doi.org/10.5194/hess-11-725-2007](https://doi.org/10.5194/hess-11-725-2007).

See also: [`confusion_scaled(hits, misses, false_alarms, quiets)`](@ref),
[`cost_loss(costs, losses, scaled_conf, method)`](@ref),
[`cost_loss_verkade(costs, losses, scaled_conf)`](@ref)
"""
function cost_loss_roulin(costs, losses, scaled_conf)
    f_1 = scaled_conf[:quiets]
    f_2 = scaled_conf[:misses]
    f_3 = scaled_conf[:false_alarms]
    f_4 = scaled_conf[:hits]

    α = costs / losses      # cost-loss ratio
    μ = f_2 + f_4           # observed relative frequency

    H = f_4 / μ             # NaN if μ=0
    F = f_3 / (1 - μ)       # NaN if μ=1

    V = (min(α, μ) - F * α * (1 - μ) + H * μ * (1 - α) - μ) / (min(α, μ) - μ * α)

    return V
end

"""
    cost_loss(costs, losses, scaled_conf, method="verkade")

Returns the relative economic value of a forecast system using a
the cost-loss model using the cost-loss ratio (`costs`, `losses`) and confusion
matrix scaled by the total events and non-events `scaled_conf`.

Two methods are implemented (Verkade 2011 and Roulin 2007) which may be selected
with the `method` argument (default is Verkade).

Verkade, J. S., and M. G. F. Werner. “Estimating the Benefits of Single Value
and Probability Forecasting for Flood Warning.” Hydrology and Earth System
Sciences 15, no. 12 (December 20, 2011): 3751–65.
[https://doi.org/10.5194/hess-15-3751-2011](https://doi.org/10.5194/hess-15-3751-2011).

Roulin, E. “Skill and Relative Economic Value of Medium-Range Hydrological
Ensemble Predictions.” Hydrology and Earth System Sciences 11, no. 2 (2007):
725–37. [https://doi.org/10.5194/hess-11-725-2007](https://doi.org/10.5194/hess-11-725-2007).

See also: [`confusion_scaled(hits, misses, false_alarms, quiets)`](@ref),
[`cost_loss_roulin(costs, losses, scaled_conf)`](@ref),
[`cost_loss_verkade(costs, losses, scaled_conf)`](@ref)
"""
function cost_loss(costs, losses, scaled_conf; method="verkade")
    if method == "roulin"
        cost_loss_roulin(costs, losses, scaled_conf)
    else
        cost_loss_verkade(costs, losses, scaled_conf)
    end
end

end
