
# TODO
# - Parameterise the types so they can have any number of named parameters
# - Should the parameter validation function be inside the Parameters struct?

struct ParameterBounds
    x1::Tuple{Float64, Float64}
    x2::Tuple{Float64, Float64}
    x3::Tuple{Float64, Float64}
    x4::Tuple{Float64, Float64}
end

# Pretty print for Parameters
Base.show(io::IO, bounds::ParameterBounds) =
    for field in fieldnames(ParameterBounds)
        println(io, field, " valid from ", getfield(bounds, field)[1], " to ", getfield(bounds, field)[2])
    end

# ------------------------------------------------------------------------------

struct Parameters
    x1::Float64
    x2::Float64
    x3::Float64
    x4::Float64
    bounds::ParameterBounds

    function Parameters(x1, x2, x3, x4, bounds)
        pars = Dict(:x1 => x1, :x2 => x2, :x3 => x3, :x4 => x4)
        errors = validate_parameters(pars, bounds)
        length(errors) > 0 ? error(errors) : new(x1, x2, x3, x4, bounds)
    end
end

# Cannot pass in the Parameters type directly because this is used by the inner constructor
function validate_parameters(parameters::Dict{Symbol, Float64}, bounds::ParameterBounds)::Vector{String}
    @assert fieldnames(ParameterBounds) != sort(collect(keys(parameters)))  "Parameters and bounds may be for different models"

    errors = []
    for field in fieldnames(ParameterBounds)
        parameters[field] >= getfield(bounds, field)[1] || push!(errors, "$field too low")
        parameters[field] <= getfield(bounds, field)[2] || push!(errors, "$field too high")
    end

    return errors
end

# Pretty print for Parameters
Base.show(io::IO, p::Parameters) =
    for field in fieldnames(typeof(pars.bounds))
        println(io, field, " = ", getfield(pars, field),
            " [Valid from ", getfield(pars.bounds, field)[1],
            " and ", getfield(pars.bounds, field)[2], "]")
    end

# ------------------------------------------------------------------------------

bounds = ParameterBounds((1.0, 10000.0), (-100.0, 100.0), (1.0, 5000.0), (0.5, 50.0))
pars = Parameters(350.0, 0.0, 50.0, 0.5, bounds)
