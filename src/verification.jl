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

using Statistics

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
