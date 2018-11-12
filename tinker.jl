# playing with this in Juno

using Pkg
Pkg.add("Plots")
Pkg.add("DataFrames")
Pkg.add("CSV")

using Plots
using DataFrames
using CSV
using Statistics

# load a file of example data with missing data
data = CSV.read("test-data/hydromet.csv", missingstrings="-9999")

# some summary information of the DF
size(data)
names(data)
describe(data)
typeof(data.obs_runoff)

# lets see how the first 10 values look
data[1:10, :]

# select a subset of the data
s = 10000
e = s + 50
d = data[s:e, :]

# set a single value missing
d.obs_runoff[3] = missing

# set a few values missing
d[6:9, :obs_runoff] = missing

# plot the obs and sim runoff
plot([d.obs_runoff, d.obs_runoff_sim_0])

# define nash sutcliffe efficiency
function nse(obs, sim)
    obs_mean = mean(obs)
    1 - sum((obs - sim).^2) / sum((obs .- obs_mean).^2)
end

# drop any missing values and calculate NSE
dropmissing!(data)
nse(data.obs_runoff, data.obs_runoff_sim_0)

# define the box-cox transform
function boxcox(y, λ)
    if λ == 0
        log.(y)
    else
        (y.^λ .- 1) ./ λ
    end
end

# histogram of log transformed and 1/5 transformed runoff
log_q = boxcox(data.obs_runoff, 0)
trans_q = boxcox(data.obs_runoff, 0.2)
histogram([log_q, trans_q])
