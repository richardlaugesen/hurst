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

module TestCalibrate

using Hurst
using Hurst.Performance
using Hurst.Simulation
using Hurst.Calibration
using Hurst.GR4J
using Hurst.OSTP

using Test
using CSV
using DataFrames

@testset "Calibration" begin

    # load some test data
    df = CSV.read("data/test_1_data.csv", header=1, missingstrings=["-9999"])
    names!(df, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))
    rain = df[:obs_rain]
    pet = df[:obs_pet]
    runoff = df[:obs_runoff]

    # build up dictionary of optimiser options needed for calibration
    opt_options = Dict()
    opt_options[:max_iterations] = false
    opt_options[:max_time] = 0.25 * 60  # 15 seconds
    opt_options[:trace_interval] = 15
    opt_options[:method] = :adaptive_de_rand_1_bin_radiuslimited
    opt_options[:trace_mode] = :silent

    @testset "GR4J (with parameter transformations)" begin
        # build up dictionary of model functions needed for calibration
        functions = Dict()
        functions[:run_model_time_step] = gr4j_run_step
        functions[:init_state] = gr4j_init_state
        functions[:params_from_array] = gr4j_params_from_array
        functions[:objective_function] = (obs, sim) -> -1 * nse(obs, sim)
        functions[:params_inverse_transform] = gr4j_params_trans_inv
        functions[:params_range_transform] = gr4j_params_range_trans
        functions[:params_range_to_tuples] = gr4j_params_range_to_tuples
        functions[:params_range] = gr4j_params_range

        opt_pars, opt_nse = calibrate(rain, pet, runoff, functions, opt_options)
        opt_nse *= -1

        @test typeof(opt_pars) == Dict{Symbol, Float64}
        @test typeof(opt_nse) == Float64
        @test 0 < opt_nse < 1
        @test opt_nse > 0.3
    end

    @testset "OSTP (no parameter transformations)" begin
        # build up dictionary of model functions needed for calibration
        functions = Dict()
        functions[:run_model_time_step] = ostp_run_step
        functions[:init_state] = ostp_init_state
        functions[:params_from_array] = ostp_params_from_array
        functions[:objective_function] = (obs, sim) -> -1 * nse(obs, sim)
        functions[:params_range_to_tuples] = ostp_params_range_to_tuples
        functions[:params_range] = ostp_params_range

        opt_pars, opt_nse = calibrate(rain, pet, runoff, functions, opt_options)
        opt_nse *= -1

        @test typeof(opt_pars) == Dict{Symbol, Float64}
        @test typeof(opt_nse) == Float64
        @test -Inf < opt_nse < 1
    end
end
end
