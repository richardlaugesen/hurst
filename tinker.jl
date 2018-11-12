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

# a simple one storage, two parameter rainfall-runoff model
function one_store_model(rain, pet, storage, params)
    capacity = params["capacity"]
    loss = params["loss"]

    # effective rainfall
    storage += rain - pet

    # general losses
    storage -= loss
    storage = (storage > 0) ? storage : 0

    # runoff generation
    if storage > capacity
        runoff = storage - capacity
        storage = capacity
    else
        runoff = 0
    end

    return storage, runoff
end

# try the model out
params = Dict("capacity" => 30, "loss" => 2)
one_store_model(50, 5, 4, params)

# create new dataframe for model input and output and initalise storage to 0
# TODO: fill with missing instead of 0.0 but need to define type to be Float32 somehow
len = nrow(data)
model_output = DataFrame(storage = fill(0.0, len), runoff_sim = fill(0.0, len))
model_data = hcat(data, model_output)

# run model over series
for i in 1:len
    rain = model_data[i, :obs_rain]
    pet = model_data[i, :obs_pet]
    curr_storage = model_data[i, :storage]

    new_storage, runoff = one_store_model(rain, pet, curr_storage, params)

    model_data[i, :runoff_sim] = runoff

    if i < len
        model_data[i + 1, :storage] = new_storage
    end
end

# see how the results look
d = model_data[s:e, [:obs_runoff, :runoff_sim, :obs_runoff_sim_0, :storage]]
println(d)
plot([d.obs_runoff, d.runoff_sim, d.obs_runoff_sim_0])
plot(d.storage)
