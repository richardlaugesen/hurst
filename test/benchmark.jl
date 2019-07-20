# Copyright 2018-2019 Tiny Rock Pty Ltd
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

module BenchmarkGR4J

using Hurst
using Hurst.Models.GR4J
using Hurst.Simulation

using Test
using CSV
using DataFrames
using BenchmarkTools

@testset "GR4J Benchmarks" begin

    # load some test data
    df = CSV.read("data/test_1_data.csv", header=1, missingstrings=["-9999"])
    names!(df, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))
    rain = df[:obs_rain]
    pet = df[:obs_pet]

    # typical timestep in less than 50 microseconds
    pars = gr4j_params_default()
    init_state = gr4j_init_state(pars)
    init_state[:production_store] = pars[:x1] * 0.6
    init_state[:routing_store] = pars[:x3] * 0.7

    typical = @belapsed gr4j_run_step(10, 5, $init_state, $pars)
    @test typical < (50 * 1e-6)

    # huge X4 doesn't cost more than an extra 10 millisecond
    pars[:x4] = 40
    init_state = gr4j_init_state(pars)
    init_state[:production_store] = pars[:x1] * 0.6
    init_state[:routing_store] = pars[:x3] * 0.7

    huge_x4 = @belapsed gr4j_run_step(10, 5, $init_state, $pars)
    @test (huge_x4 - typical) < (10 * 1e-6)

    # two paths through production store cost the same
    pars = gr4j_params_from_array([320.1073, 2.4208, 69.6276, 1.3891])
    init_state = gr4j_init_state(pars)
    init_state[:production_store] = pars[:x1] * 0.6
    init_state[:routing_store] = pars[:x3] * 0.7

    evap_path = @belapsed gr4j_run_step(5, 100, $init_state, $pars)
    precip_path = @belapsed gr4j_run_step(100, 5, $init_state, $pars)
    @test isapprox(evap_path, precip_path, atol=1e-5)

    # simulation of 2 years data should take less than 50 milliseconds
    @test (@belapsed simulate(gr4j_run_step, $rain, $pet, $pars, $init_state)) < (50 * 1e-3)
end

end
