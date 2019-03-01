using Hydro
using Hydro.Verification

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
