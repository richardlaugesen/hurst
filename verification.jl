using Statistics

# define nash sutcliffe efficiency
function nse(obs, sim)
    obs_mean = mean(obs)
    1 - sum((obs - sim).^2) / sum((obs .- obs_mean).^2)
end
