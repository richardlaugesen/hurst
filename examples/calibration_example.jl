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

function plotter(s, e)
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
end

plotter(12000, 12200)
plotter(1, 12417)
