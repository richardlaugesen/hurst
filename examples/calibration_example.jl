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

using Hurst
using Hurst.Calibration
using Hurst.Simulation
using Hurst.GR4J
using Hurst.OSTP
using Hurst.Verification
using Hurst.Visualisations

using CSV
using DataFrames
using Printf: @sprintf

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

# -----------------------------------------------------------------------------
println("Calibrating GR4J...")

# build up dictionary of model functions needed for calibration
functions = Dict()
functions[:run_model_time_step] = gr4j_run_step
functions[:init_state] = gr4j_init_state
functions[:params_from_array] = gr4j_params_from_array
functions[:objective_function] = (obs, sim) -> -1 * nse(obs, sim)
functions[:params_inverse_transform] = gr4j_params_trans_inv
functions[:params_range_transform] = gr4j_params_range_trans
functions[:params_range_to_tuples] = gr4j_params_range_to_tuples
functions[:params_range] = gr4j_params_range

# build up dictionary of optimiser options needed for calibration
opt_options = Dict()
opt_options[:max_iterations] = false
opt_options[:max_time] = 5 * 60
opt_options[:trace_interval] = 15
opt_options[:trace_mode] = :verbose
opt_options[:method] = :adaptive_de_rand_1_bin_radiuslimited

opt_pars, opt_nse = calibrate(data[:rain], data[:pet], data[:runoff_obs], functions, opt_options)
opt_nse *= -1

println(opt_pars)

# -----------------------------------------------------------------------------
println("Simulating GR4J...")

# test parameters were
gr4j_params_from_array(CSV.read("test/data/test_2_params.csv", delim=":", header=0)[2])

init_state = gr4j_init_state(opt_pars)

sim = simulate(gr4j_run_step, data[:rain], data[:pet], opt_pars, init_state);
data[:runoff_sim_gr4j] = sim;

# -----------------------------------------------------------------------------
println("Calibrating OSTP...")

# build up dictionary of model functions needed for calibration
functions = Dict()
functions[:run_model_time_step] = ostp_run_step
functions[:init_state] = ostp_init_state
functions[:params_from_array] = ostp_params_from_array
functions[:objective_function] = (obs, sim) -> -1 * nse(obs, sim)
functions[:params_range_to_tuples] = ostp_params_range_to_tuples
functions[:params_range] = ostp_params_range

# build up dictionary of optimiser options needed for calibration
opt_options = Dict()
opt_options[:max_iterations] = false
opt_options[:max_time] = 1 * 60
opt_options[:trace_interval] = 15
opt_options[:trace_mode] = :verbose
opt_options[:method] = :adaptive_de_rand_1_bin_radiuslimited

opt_pars, opt_nse = calibrate(data[:rain], data[:pet], data[:runoff_obs], functions, opt_options)
opt_nse *= -1

println(opt_pars)

# -----------------------------------------------------------------------------
println("Simulating OSTP...")

init_state = ostp_init_state(opt_pars)

sim = simulate(ostp_run_step, data[:rain], data[:pet], opt_pars, init_state);
data[:runoff_sim] = sim;

# -----------------------------------------------------------------------------
println("Plotting hydrograph...")

function plotter(data, s, e, filename)
    obs = data[:runoff_obs][s:e]
    test = data[:runoff_sim_test][s:e]
    gr4j = data[:runoff_sim_gr4j][s:e]
    ostp = data[:runoff_sim][s:e]
    rain = data[:rain][s:e]

    nse_test = @sprintf("%.2f", nse(data[:runoff_obs], data[:runoff_sim_test]))
    nse_gr4j = @sprintf("%.2f", nse(data[:runoff_obs], data[:runoff_sim_gr4j]))
    nse_ostp = @sprintf("%.2f", nse(data[:runoff_obs], data[:runoff_sim]))

    hydrograph(rain, [obs, test, gr4j, ostp],
        ["Observations",
        "Test Simulation ($nse_test)",
        "GR4J Simulation ($nse_gr4j)",
        "OSTP Simulation ($nse_ostp)"])

    savefig(filename)
end

plotter(data, 12000, 12200, "hydrograph-calibration-1.png")
plotter(data, 1, 12417, "hydrograph-calibration-2.png")


# Loading data...
# Period of record is 34.0 years
# Calibrating GR4J...
# Starting optimization with optimizer BlackBoxOptim.DiffEvoOpt{BlackBoxOptim.FitPopulation{Float64},BlackBoxOptim.RadiusLimitedSelector,BlackBoxOptim.AdaptiveDiffEvoRandBin{3},BlackBoxOptim.RandomBound{BlackBoxOptim.RangePerDimSearchSpace}}
# 0.00 secs, 0 evals, 0 steps
# DE modify state:
# 15.45 secs, 50 evals, 27 steps, improv/step: 0.444 (last = 0.4444), fitness=-0.715894622
# DE modify state:
# 30.68 secs, 92 evals, 49 steps, improv/step: 0.367 (last = 0.2727), fitness=-0.715894622
# DE modify state:
# 46.12 secs, 139 evals, 78 steps, improv/step: 0.372 (last = 0.3793), fitness=-0.715894622
# DE modify state:
# 61.41 secs, 185 evals, 106 steps, improv/step: 0.349 (last = 0.2857), fitness=-0.715894622
# DE modify state:
# 76.74 secs, 230 evals, 139 steps, improv/step: 0.338 (last = 0.3030), fitness=-0.715894622
# DE modify state:
# 91.89 secs, 276 evals, 176 steps, improv/step: 0.369 (last = 0.4865), fitness=-0.715894622
# DE modify state:
# 106.91 secs, 319 evals, 215 steps, improv/step: 0.340 (last = 0.2051), fitness=-0.715894622
# DE modify state:
# 122.11 secs, 366 evals, 260 steps, improv/step: 0.331 (last = 0.2889), fitness=-0.715894622
# DE modify state:
# 137.37 secs, 413 evals, 305 steps, improv/step: 0.341 (last = 0.4000), fitness=-0.725902085
# DE modify state:
# 152.73 secs, 460 evals, 349 steps, improv/step: 0.347 (last = 0.3864), fitness=-0.725902085
# DE modify state:
# 167.89 secs, 507 evals, 393 steps, improv/step: 0.333 (last = 0.2273), fitness=-0.725902085
# DE modify state:
# 183.09 secs, 559 evals, 442 steps, improv/step: 0.333 (last = 0.3265), fitness=-0.725902085
# DE modify state:
# 198.37 secs, 612 evals, 494 steps, improv/step: 0.318 (last = 0.1923), fitness=-0.725902085
# DE modify state:
# 213.52 secs, 665 evals, 547 steps, improv/step: 0.313 (last = 0.2642), fitness=-0.725902085
# DE modify state:
# 228.67 secs, 718 evals, 600 steps, improv/step: 0.308 (last = 0.2642), fitness=-0.731613837
# DE modify state:
# 243.82 secs, 771 evals, 652 steps, improv/step: 0.308 (last = 0.3077), fitness=-0.731613837
# DE modify state:
# 258.87 secs, 824 evals, 705 steps, improv/step: 0.304 (last = 0.2453), fitness=-0.748949988
# DE modify state:
# 274.14 secs, 876 evals, 757 steps, improv/step: 0.293 (last = 0.1538), fitness=-0.795511079
# DE modify state:
# 289.39 secs, 930 evals, 811 steps, improv/step: 0.289 (last = 0.2222), fitness=-0.823401384
# DE modify state:
#
# Optimization stopped after 849 steps and 300.249559879303 seconds
# Termination reason: Max time (300.0 s) reached
# Steps per second = 2.827647775208359
# Function evals per second = 3.223984742522605
# Improvements/step = Inf
# Total function evaluations = 968
# 
#
# Best candidate found: [3.84484, 2.89193, 5.73781, 0.0367135]
#
# Fitness: -0.823401384
#
# Dict(:x2=>2.89193,:x3=>310.384,:x4=>1.5374,:x1=>46.7512)
# Simulating GR4J...
# Calibrating OSTP...
# Starting optimization with optimizer BlackBoxOptim.DiffEvoOpt{BlackBoxOptim.FitPopulation{Float64},BlackBoxOptim.RadiusLimitedSelector,BlackBoxOptim.AdaptiveDiffEvoRandBin{3},BlackBoxOptim.RandomBound{BlackBoxOptim.RangePerDimSearchSpace}}
# 0.00 secs, 0 evals, 0 steps
# DE modify state:
# 15.00 secs, 1451 evals, 1381 steps, improv/step: 0.668 (last = 0.6676), fitness=-0.179531280
# DE modify state:
# 30.00 secs, 2903 evals, 2834 steps, improv/step: 0.480 (last = 0.3021), fitness=-0.202277432
# DE modify state:
# 45.01 secs, 4367 evals, 4299 steps, improv/step: 0.404 (last = 0.2553), fitness=-0.202306468
# DE modify state:
#
# Optimization stopped after 5764 steps and 60.009498834609985 seconds
# Termination reason: Max time (60.0 s) reached
# Steps per second = 96.05146038439602
# Function evals per second = 97.1846143236984
# Improvements/step = Inf
# Total function evaluations = 5832
#
#
# Best candidate found: [208.396, 5.6504]
#
# Fitness: -0.202306469
#
# Dict(:loss=>5.6504,:capacity=>208.396)
# Simulating OSTP...
# Plotting hydrograph...
