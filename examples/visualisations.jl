using Hurst
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

s = 12000
e = 12200

obs = data[:runoff_obs][s:e]
test = data[:runoff_sim_test][s:e]
rain = data[:rain][s:e]

# -----------------------------------------------------------------------------
println("Plots...")

hydrograph(rain, [obs, test, log.(test)], ["Observations", "GR4J", "log(GR4J)"])
#savefig("hydrograph.png")

hyscatter(obs, test, "GR4J", "mm", "Runoff simulation compared to observations")
#savefig("scatter-1.png")

hyscatter(obs, [test, log.(test)], ["GR4J", "log(GR4J)"], "mm", "Runoff simulation compared to observations")
#savefig("scatter-2.png")
