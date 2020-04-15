# Copyright 2018-2020 Tiny Rock Pty Ltd
#
# This file is part of Hurst
#
# Hurst is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Hurst is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Hurst.  If not, see <https://www.gnu.org/licenses/>.


module GR4J

export GR4JParameterBounds, GR4JParameters, GR4JState, GR4JModel

# ------------------------------------------------------------------------------
# Parameter set bounds
# TODO: Call these :high and :low
# ------------------------------------------------------------------------------

struct GR4JParameterBounds
    x1::Tuple{Float64, Float64}
    x2::Tuple{Float64, Float64}
    x3::Tuple{Float64, Float64}
    x4::Tuple{Float64, Float64}
end

Base.show(io::IO, bounds::GR4JParameterBounds) =
    for field in fieldnames(GR4JParameterBounds)
        println(io, field, " valid from ", getfield(bounds, field)[1], " to ", getfield(bounds, field)[2])
    end

# ------------------------------------------------------------------------------
# Parameter set
# ------------------------------------------------------------------------------

struct GR4JParameters
    x1::Float64
    x2::Float64
    x3::Float64
    x4::Float64
    bounds::GR4JParameterBounds

    # throw descriptive error if values are outside bounds
    function GR4JParameters(x1::Number, x2::Number, x3::Number, x4::Number, bounds::GR4JParameterBounds)
        errors = ""
        pars = Dict(:x1 => x1, :x2 => x2, :x3 => x3, :x4 => x4)
        for field in fieldnames(GR4JParameterBounds)
            if pars[field] < getfield(bounds, field)[1]
                err = string(field, " is too low \t(", pars[field], " < ", getfield(bounds, field)[1], ")\n")
                errors = string(errors, err)

            elseif pars[field] > getfield(bounds, field)[2]
                err = string(field, " is too high \t(", pars[field], " > ", getfield(bounds, field)[2], ")\n")
                errors = string(errors, err)
            end
        end

        length(errors) > 0 ? error(errors) : new(x1, x2, x3, x4, bounds)
    end
end

Base.show(io::IO, pars::GR4JParameters) =
    for field in fieldnames(typeof(pars.bounds))
        println(io, field, " = ", getfield(pars, field),
            " \t(Valid from ", getfield(pars.bounds, field)[1],
            " and ", getfield(pars.bounds, field)[2], ")")
    end

# ------------------------------------------------------------------------------
# Model state
# ------------------------------------------------------------------------------

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
        uh1_ordinates = create_uh_ordinates(1, n, pars.x4)  # this is in the main GR4J code
        uh2_ordinates = create_uh_ordinates(2, 2n, pars.x4)
        production_store = 0
        routing_store = 0

        return new(uh1, uh2, uh1_ordinates, uh2_ordinates, production_store, routing_store)
    end
end

Base.show(io::IO, state::GR4JState) =
    print(io, "Production Store = ", state.production_store,
              "\nRouting Store = ", state.routing_store,
              "\nFirst unit hydrograph = ", state.uh1,
              "\nSecond unit hydrograph = ", state.uh2)

# ------------------------------------------------------------------------------
# Model itself
# ------------------------------------------------------------------------------

struct GR4JModel
    parameters::GR4JParameters
    state::GR4JState
end

Base.show(io::IO, model::GR4JModel) =
    print(io, "State\n",
              "----------------------------\n",
              model.state,
              "\n\nParameters\n",
              "----------------------------\n",
              model.parameters)

# ------------------------------------------------------------------------------
# Check if it all worked
# TODO: put this in a test
# ------------------------------------------------------------------------------

bounds = GR4JParameterBounds((1, 10000), (-100, 100), (1, 5000), (0.5, 50))
pars = GR4JParameters(350, 0, 50, 3, bounds)
state = GR4JState(pars)
model = GR4JModel(pars, state)

end
