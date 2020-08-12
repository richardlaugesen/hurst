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

module Metrics

using Hurst.Utils
using Hurst.Performance.Confusion

using Statistics

export coeff_det, nse, mae, mse, rmse, kge, persistence, kuipers_score

"""
    nse(obs, sim)

Returns the Nash Sutcliffe Efficiency of `obs` and `sim` timeseries.

See also: [`coeff_det`](@ref)
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

See also: [`rmse`](@ref)
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

See also: [`mse`](@ref)
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
    kge(o, s, return_components)

Returns the Kling-Gupta Efficiency between `o` and `s`.
Skips missing values from either series.

If `return_components` is `true` then a Dictionary is returned containing the
final KGE value (:kge) along with the individual return_components used to
construct the KGE (:covariance, :relative_variability, :mean_bias)
"""
function kge(o, s; return_components=false)
    o, s = dropna(o, s)
    r = cov(o, s, corrected=true) / (std(s, corrected=true) * std(o, corrected=true))  # covariance
    a = std(s) / std(o, corrected=true)  # relative variability
    b = mean(s) / mean(o)  # mean bias
    k = 1 - sqrt((r - 1)^2 + (a - 1)^2 + (b - 1)^2)

    if return_components
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
    kuipers_score(scaled_conf)

Returns the Kuipers Score using the elements of the `scaled_conf` contingency
table.

Richardson, D. S. “Skill and Relative Economic Value of the ECMWF Ensemble
Prediction System.” Quarterly Journal of the Royal Meteorological Society
126, no. 563 (January 2000): 649–67.
[https://doi.org/10.1256/smsqj.56312](https://doi.org/10.1256/smsqj.56312).

See also: [`confusion_scaled`](@ref)
"""
function kuipers_score(scaled_conf)
    a = scaled_conf[:quiets]
    b = scaled_conf[:misses]
    c = scaled_conf[:false_alarms]
    d = scaled_conf[:hits]

    return (a * d - b * c) / ((a + c) * (b + d))
end

end
