# calibrate GR4J parameters for a 33 year daily record of an Australian catchment

include("../src/Hydro.jl")
using .Hydro

using CSV
using DataFrames

# load a test dataset from a CSV file into a dataframe
df = CSV.read("test/data/test_2_data.csv", header=1, missingstrings=["-9999"])
names!(df, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))

# Create a dictionary of data from the dataframe
data = Dict()
data["rain"] = df[:obs_rain]
data["pet"] = df[:obs_pet]
data["runoff_obs"] = df[:obs_runoff]
data["runoff_sim_test"] = df[:test_sim_runoff]

# build up dictionary of model functions needed for calibration
functions = Dict()
functions["run_model_time_step"] = gr4j_run_step
functions["init_state"] = gr4j_init_state
functions["params_from_array"] = gr4j_params_from_array
functions["objective_function"] = (obs, sim) -> -1 * nse(obs, sim)
functions["params_inverse_transform"] = gr4j_params_trans_inv
functions["params_range_transform"] = gr4j_params_range_trans
functions["params_range_to_tuples"] = gr4j_params_range_to_tuples

# find an optimial parameter set using NSE as the objective function
# with adaptive differential evolution method for 1000 iterations
opt_pars, opt_nse = calibrate(functions, data, gr4j_params_range(), 1000, :adaptive_de_rand_1_bin)
opt_nse *= -1

# print out some results
test_pars = gr4j_params_from_array(CSV.read("test/data/test_2_params.csv", delim=":", header=0)[2])
println("Test Parameters: $test_pars")
println("Optimised Parameters: $opt_pars")
println("NSE: $opt_nse")
