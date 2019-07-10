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

module Verification

using Hurst.Utils

using Statistics

export coeff_det, nse, mae, mse, rmse, kge, persistence
export confusion, confusion_scaled, cost_loss_rev

"""
    nse(obs, sim)

Returns the Nash Sutcliffe Efficiency of `obs` and `sim` timeseries.

See also: [`coeff_det(y, f)`](@ref)
"""
function nse(obs, sim)
    coeff_det(obs, sim)
end

"""
    coeff_det(y, f)

Returns the Coefficient of Determination between `y` and `f`.
Skips missing values from either series.
"""
function coeff_det(y, f)
    1 - sum(skipmissing(y - f).^2) / sum(skipmissing(y .- mean(skipmissing(y))).^2)
end

"""
    mse(o, s)

Returns the Mean Square Error between `o` and `s`.
Skips missing values from either series.

See also: [`rmse(o, s)`](@ref)
"""
function mse(o, s)
    sum(skipmissing(o - s).^2) / (length_no_missing(o) - 1)
end

"""
    mae(o, s)

Returns the Mean Absolute Error between `o` and `s`.
Skips missing values from either series.
"""
function mae(o, s)
    sum(abs.(skipmissing(o - s))) / (length_no_missing(o) - 1)
end

"""
    rmse(o, s)

Returns the Root Mean Square Error between `o` and `s`.

See also: [`mse(o, s)`](@ref)
"""
function rmse(o, s)
    sqrt(mse(o, s))
end

"""
    persistence(o, s)

Returns the Persistence Index between `o` and `s`.
Skips missing values from either series.
"""
function persistence(o, s)
    shifted_o = lshift(o)
    return 1 - sum(skipmissing(s - o).^2) / sum(skipmissing(shifted_o - o).^2)
end

"""
    kge(o, s, components)

Returns the Kling-Gupta Efficiency between `o` and `s`.
Skips missing values from either series.

If `components` is `true` then a Dictionary is returned containing the
final KGE value (:kge) along with the individual components used to
construct the KGE (:covariance, :relative_variability, :mean_bias)

See also: [`kge(o, s)`](@ref)
"""
function kge(o, s, components)
    o, s = dropna(o, s)
    r = cov(o, s, corrected=true) / (std(s, corrected=true) * std(o, corrected=true))  # covariance
    a = std(s) / std(o, corrected=true)  # relative variability
    b = mean(s) / mean(o)  # mean bias
    k = 1 - sqrt((r - 1)^2 + (a - 1)^2 + (b - 1)^2)

    if components
        return Dict(
            :covariance => r,
            :relative_variability => a,
            :mean_bias => b,
            :kge => k
        )
    else
        return k
    end
end

"""
    kge(o, s)

Returns the Kling-Gupta Efficiency between `o` and `s`.
Skips missing values from either series.

See also: [`kge(o, s, components)`](@ref)
"""
kge(o, s) = kge(o, s, false)

"""
    confusion(hits, misses, false_alarms, quiets)

Returns a Dict containing fields of a confusion matrix with the various common
names used for each combination of the 2x2 grid.

https://en.wikipedia.org/wiki/Confusion_matrix

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

Returns a Dict containing fields of a confusion matrix with the various common
names used for each combination of the 2x2 grid scaled to be relative to the
number of events and non-events (hits + misses + false_alarms + quiets).

https://en.wikipedia.org/wiki/Confusion_matrix

See also: [`confusion(hits, misses, false_alarms, quiets)`](@ref)
"""
function confusion_scaled(hits, misses, false_alarms, quiets)
    total = hits + misses + false_alarms + quiets
    return confusion(hits/total, misses/total, false_alarms/total, quiets/total)
end

"""
    cost_loss_rev(costs, losses, scaled_conf)

Returns the relative economic value of a forecast system using a
the cost-loss model using the cost-loss ratio (`costs`, `losses`) and confusion
matrix scaled by the total events and non-events `scaled_conf`.

Verkade, J. S., and M. G. F. Werner. “Estimating the Benefits of Single Value
and Probability Forecasting for Flood Warning.” Hydrology and Earth System
Sciences 15, no. 12 (December 20, 2011): 3751–65.
https://doi.org/10.5194/hess-15-3751-2011.

See also: [`confusion_scaled(hits, misses, false_alarms, quiets)`](@ref)
"""
function cost_loss_rev(costs, losses, scaled_conf)
    h = scaled_conf[:hits]
    m = scaled_conf[:misses]
    f = scaled_conf[:false_alarms]

    r = costs / losses  # cost-loss ratio
    o = h + m           # observed relative frequency

    rev = (o - (h + f) * r - m) / (o * (1 - r))

    return rev
end

end
