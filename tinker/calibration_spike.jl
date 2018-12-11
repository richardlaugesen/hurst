include("../src/Hydro.jl")
using .Hydro

using CSV
using DataFrames

function calibration_test(max_time)
    df = CSV.read("test/data/test_data.csv", header=1)
    names!(df, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))

    data = Dict()
    data["rain"] = df[:obs_rain]
    data["pet"] = df[:obs_pet]
    data["runoff_obs"] = df[:obs_runoff]
    data["runoff_sim_test"] = df[:test_sim_runoff]

    functions = Dict()
    functions["run_model_time_step"] = gr4j_run_step
    functions["init_state"] = gr4j_init_state
    functions["params_from_array"] = gr4j_params_from_array
    functions["objective_function"] = (obs, sim) -> -1 * nse(obs, sim)
    functions["params_inverse_transform"] = gr4j_params_trans_inv
    functions["params_range_transform"] = gr4j_params_range_trans
    functions["params_range_to_tuples"] = gr4j_params_range_to_tuples

    calibrate(functions, data, gr4j_params_range(), max_time)
end

opt_pars, opt_nse = calibration_test(10)
opt_nse *= -1

println("NSE: $opt_nse")
println("Parameters: $opt_pars")
