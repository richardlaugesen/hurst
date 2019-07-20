# Copyright 2018-2019 Tiny Rock Pty Ltd
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

using Hurst
using Hurst.Performance.Metrics

using CSV
using DataFrames
using Printf: @sprintf

df = CSV.read("test/data/test_2_data.csv", header=1, missingstrings=["-9999"]);
obs, sim = df[:obs_runoff], df[:obs_runoff_sim_0];

metrics = Dict()

metrics[:nse] = nse(obs, sim)
metrics[:mse] = mse(obs, sim)
metrics[:rmse] = rmse(obs, sim)
metrics[:persistence] = persistence(obs, sim)
metrics[:kge] = kge(obs, sim)
metrics[:kge_components] = kge(obs, sim, true)

println(metrics)

# Dict{Any,Any} with 6 entries:
#   :rmse           => 1.39263
#   :kge_components => Dict(:mean_bias=>1.07001,:kge=>0.844643,:relative_variability=>0.888073,:covariance=>0.918107)
#   :kge            => 0.844643
#   :mse            => 1.93941
#   :nse            => 0.841729
#   :persistence    => 0.468714
