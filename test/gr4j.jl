# Copyright 2019 Richard Laugesen
#
# This file is part of Hydro.jl
#
# Hydro.jl is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Hydro.jl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Hydro.jl.  If not, see <https://www.gnu.org/licenses/>.

module TestGr4j
using Test, Hydro, CSV, DataFrames

@testset "GR4J" begin

    df = CSV.read("data/test_1_data.csv", header=1, missingstrings=["-9999"])
    names!(df, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))

    data = Dict()
    data[:rain] = df[:obs_rain]
    data[:pet] = df[:obs_pet]
    data[:runoff_obs] = df[:obs_runoff]
    data[:runoff_sim_test] = df[:test_sim_runoff]

    @testset "Single timestep" begin
        pars = gr4j_params_default()
        init_state = gr4j_init_state(pars)

        @test gr4j_run_step(0, 0, init_state, pars)[1] == 0
        @test gr4j_run_step(100, 5, init_state, pars)[1] ≈ 0.2270703669963994
        @test gr4j_run_step(1000, 0, init_state, pars)[1] ≈ 605.529053798641
        @test_throws TypeError gr4j_run_step(missing, 0, init_state, pars)
        @test_throws TypeError gr4j_run_step(100, missing, init_state, pars)
    end

    @testset "2 year simulation" begin
        pars = gr4j_params_from_array(CSV.read("data/test_1_params.csv", delim=":", header=0)[2])
        init_state = gr4j_init_state(pars)
        init_state[:production_store] = pars[:x1] * 0.6
        init_state[:routing_store] = pars[:x3] * 0.7

        sim = simulate(gr4j_run_step, data, pars, init_state)

        @test isapprox(data[:runoff_sim_test][1], sim[1], atol=0.0001)
        @test isapprox(data[:runoff_sim_test][400], sim[400], atol=0.0001)
        @test isapprox(data[:runoff_sim_test][end], sim[end], atol=0.0001)
    end

    @testset "Parameters" begin
        default = gr4j_params_default()
        default_arr = gr4j_params_to_array(gr4j_params_default())
        random = gr4j_params_random(gr4j_params_range())
        default_trans = gr4j_params_trans(default)
        default_trans_arr = gr4j_params_to_array(default_trans)
        prange = gr4j_params_range()
        prange_tuples = gr4j_params_range_to_tuples(prange)

        @test typeof(default_arr) == Array{Float64, 1}
        @test size(default_arr) == (4,)
        @test default_arr == [350, 0, 50, 0.5]

        @test typeof(default) == Dict{Symbol, Float64}
        @test length(default) == 4
        @test sort(collect(keys(default))) == [:x1, :x2, :x3, :x4]

        @test typeof(random) == Dict{Symbol, Float64}
        @test length(random) == 4
        @test sort(collect(keys(random))) == [:x1, :x2, :x3, :x4]

        @test isapprox(default_trans_arr, [5.8579, 0.0, 3.9120, -20.7232], atol=1e-4)
        @test gr4j_params_trans_inv(default_trans) == default

        @test typeof(prange) == Dict{Symbol,Dict{Symbol,Float64}}
        @test length(prange) == 4
        @test typeof(prange[:x1]) == Dict{Symbol,Float64}
        @test length(prange[:x1]) == 2

        @test typeof(prange_tuples) == Array{Tuple{Float64,Float64},1}
        @test size(prange_tuples) == (4,)
        @test length(prange_tuples[1]) == 2
        @test prange_tuples[1][2] == prange[:x1][:high]
        @test prange_tuples[4][1] == prange[:x4][:low]
    end
end
end
