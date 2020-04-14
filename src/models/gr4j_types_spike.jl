
# TODO
# - Parameterise the types so they can have any number of named parameters
# - Should the parameter validation function be inside the Parameters struct?

struct GR4JParameterBounds
    x1::Tuple{Float64, Float64}
    x2::Tuple{Float64, Float64}
    x3::Tuple{Float64, Float64}
    x4::Tuple{Float64, Float64}
end

# Pretty print for Parameters
Base.show(io::IO, bounds::GR4JParameterBounds) =
    for field in fieldnames(GR4JParameterBounds)
        println(io, field, " valid from ", getfield(bounds, field)[1], " to ", getfield(bounds, field)[2])
    end

# ------------------------------------------------------------------------------

struct GR4JParameters
    x1::Float64
    x2::Float64
    x3::Float64
    x4::Float64
    bounds::GR4JParameterBounds

    function GR4JParameters(x1::Number, x2::Number, x3::Number, x4::Number, bounds::GR4JParameterBounds)
        pars = Dict(:x1 => x1, :x2 => x2, :x3 => x3, :x4 => x4)
        errors = validate_parameters(pars, bounds)
        length(errors) > 0 ? error(errors) : new(x1, x2, x3, x4, bounds)
    end
end

# Cannot pass in the Parameters type directly because this is used by the inner constructor
function validate_parameters(parameters, bounds::GR4JParameterBounds)::Vector{String}
    @assert fieldnames(GR4JParameterBounds) != sort(collect(keys(parameters)))  "Parameters and bounds may be for different models"

    errors = []
    for field in fieldnames(GR4JParameterBounds)
        parameters[field] >= getfield(bounds, field)[1] || push!(errors, "$field too low")
        parameters[field] <= getfield(bounds, field)[2] || push!(errors, "$field too high")
    end

    return errors
end

# Pretty print for Parameters
Base.show(io::IO, pars::GR4JParameters) =
    for field in fieldnames(typeof(pars.bounds))
        println(io, field, " = ", getfield(pars, field),
            " \t(Valid from ", getfield(pars.bounds, field)[1],
            " and ", getfield(pars.bounds, field)[2], ")")
    end

# ------------------------------------------------------------------------------

# Parameterise by n = Int(ceil(x4))
struct GR4JState
    uh1::Array{Float64}
    uh2::Array{Float64}
    uh1_ordinates::Array{Float64}
    uh2_ordinates::Array{Float64}
    production_store::Float64
    routing_store::Float64

    function GR4JState(pars::GR4JParameters)
        n = Int(ceil(pars.x4))

        uh1 = zeros(n)
        uh2 = zeros(2n)
        uh1_ordinates = create_uh_ordinates(1, n, pars.x4)
        uh2_ordinates = create_uh_ordinates(2, 2n, pars.x4)
        production_store = 0
        routing_store = 0

        return new(uh1, uh2, uh1_ordinates, uh2_ordinates, production_store, routing_store)
    end
end

# Pretty print for State
Base.show(io::IO, state::GR4JState) =
    print(io, "Production Store = ", state.production_store,
              "\nRouting Store = ", state.routing_store,
              "\nUH1 = ", state.uh1,
              "\nUH2 = ", state.uh2)

function create_uh_ordinates(variant, size, x4)
    ordinates = zeros(size)
    for t in 1:size
        ordinates[t] = s_curve(variant, x4, t) - s_curve(variant, x4, t - 1)
    end
    return ordinates
end

function s_curve(variant, scale, x)
    if variant == 1
        if x <= 0
            return 0
        elseif x < scale
            return (x / scale)^2.5
        else
            return 1
        end

    elseif variant == 2
        if x <= 0
            return 0
        elseif x <= scale
            return 0.5 * (x / scale)^2.5
        elseif x < 2scale
            return 1 - 0.5 * (2 - x / scale)^2.5
        else
            return 1
        end
    end
end

# ------------------------------------------------------------------------------

struct GR4JModel
    parameters::GR4JParameters
    state::GR4JState
end

# Pretty print for State
Base.show(io::IO, model::GR4JModel) =
    print(io, "State\n",
              "----------------------------\n",
              model.state,
              "\n\nParameters\n",
              "----------------------------\n",
              model.parameters)

# ------------------------------------------------------------------------------

bounds = GR4JParameterBounds((1, 10000), (-100, 100), (1, 5000), (0.5, 50))
pars = GR4JParameters(350, 0, 50, 15, bounds)
state = GR4JState(pars)
model = GR4JModel(pars, state)
