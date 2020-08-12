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

using Hurst
using Hurst.Visualisations

using CSV
using DataFrames
using Printf: @sprintf
using Plots

# -----------------------------------------------------------------------------
println("Loading data...")

# load a test dataset from a CSV file into a dataframe
df = CSV.read("test/data/test_2_data.csv", header=1, missingstrings=["-9999"]);

len = @sprintf("%.1f", size(df)[1] / 365)
println("Period of record is $len years")

# rename the columns
names!(df, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]));

# Create a dictionary of data from the dataframe - standard data structure through Hurst
data = Dict()
data[:rain] = df[:obs_rain]
data[:pet] = df[:obs_pet]
data[:runoff_obs] = df[:obs_runoff]
data[:runoff_sim_test] = df[:test_sim_runoff];

s = 12000
e = 12200

obs = data[:runoff_obs][s:e]
test = data[:runoff_sim_test][s:e]
rain = data[:rain][s:e]

# -----------------------------------------------------------------------------
println("Plots...")

hydrograph(rain, [obs, test, log.(test)], ["Observations", "GR4J", "log(GR4J)"])
savefig("examples/figures/hydrograph.png")

hyscatter(obs, test, "GR4J", "mm", "Runoff simulation compared to observations")
savefig("examples/figures/scatter-1.png")

hyscatter(obs, [test, log.(test)], ["GR4J", "log(GR4J)"], "mm", "Runoff simulation compared to observations")
savefig("examples/figures/scatter-2.png")
