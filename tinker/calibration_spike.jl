include("../src/HydroJulia.jl")
using .HydroJulia

using CSV
using DataFrames

function calibration_test()
    data = CSV.read("test/data/test_data.csv", header=1)
    names!(data, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))

    nse_negative = (obs, sim) -> -1 * nse(obs, sim)

    pars_range = [(1.0, 10000.0), (-100.0, 100.0), (1.0, 5000.0), (0.5, 40.0)]
    transformed_pars_range = gr4j_params_range_transform(pars_range)

    calibrate(
        gr4j_run_step,
        gr4j_init_state,
        gr4j_parameters,
        nse_negative,
        gr4j_params_transform_inverse,
        data,
        transformed_pars_range)
end

opt_nse, opt_pars = calibration_test()

println("Nse: $opt_nse")
println("Parameters: $pars")
