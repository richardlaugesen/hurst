# Copyright 2018-2019 Richard Laugesen
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

using Hurst
using Hurst.GR4J
using Hurst.Simulation

using CSV
using DataFrames
using BenchmarkTools

function benchmark_timestep()
    pars = gr4j_params_from_array([320.1073, 2.4208, 69.6276, 1.3891])
    init_state = gr4j_init_state(pars)
    init_state[:production_store] = pars[:x1] * 0.6
    init_state[:routing_store] = pars[:x3] * 0.7

    @benchmark gr4j_run_step(100, 5, $init_state, $pars)
end

function benchmark_simulation()
    pars = gr4j_params_from_array(CSV.read("test/data/test_1_params.csv", delim=":", header=0)[2])
    init_state = gr4j_init_state(pars)
    init_state[:production_store] = pars[:x1] * 0.6
    init_state[:routing_store] = pars[:x3] * 0.7

    df = CSV.read("test/data/test_1_data.csv", header=1)
    names!(df, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))
    rain = df[:obs_rain]
    pet = df[:obs_pet]

    @benchmark simulate(gr4j_run_step, $rain, $pet, $pars, $init_state)
end

benchmark_timestep()

    # ----------------------------------------------------
    # Transcription of Fortran version
    # ----------------------------------------------------
    # BenchmarkTools.Trial:
    #   memory estimate:  4.97 KiB
    #   allocs estimate:  103
    #   --------------
    #   minimum time:     13.042 μs (0.00% GC)
    #   median time:      14.204 μs (0.00% GC)
    #   mean time:        23.081 μs (34.39% GC)
    #   maximum time:     63.937 ms (99.87% GC)
    #   --------------
    #   samples:          10000
    #   evals/sample:     1

    # ----------------------------------------------------
    # Unoptimised for clarity [7% slower]
    # Expanding exponents is key optimisation
    # ----------------------------------------------------
    #
    # BenchmarkTools.Trial:
    #   memory estimate:  4.94 KiB
    #   allocs estimate:  101
    #   --------------
    #   minimum time:     14.060 μs (0.00% GC)
    #   median time:      15.276 μs (0.00% GC)
    #   mean time:        25.716 μs (38.08% GC)
    #   maximum time:     79.157 ms (99.92% GC)
    #   --------------
    #   samples:          10000
    #   evals/sample:     1

benchmark_simulation()

    # ----------------------------------------------------
    # Transcription of Fortran version
    # ----------------------------------------------------
    #
    # BenchmarkTools.Trial:
    #   memory estimate:  3.62 MiB
    #   allocs estimate:  79415
    #   --------------
    #   minimum time:     9.496 ms (0.00% GC)
    #   median time:      10.112 ms (0.00% GC)
    #   mean time:        10.570 ms (5.89% GC)
    #   maximum time:     78.309 ms (86.69% GC)
    #   --------------
    #   samples:          473
    #   evals/sample:     1

    # ----------------------------------------------------
    # Unoptimised for clarity [8% slower]
    # Expanding exponents is key optimisation
    # ----------------------------------------------------
    #
    # BenchmarkTools.Trial:
    #   memory estimate:  3.59 MiB
    #   allocs estimate:  77955
    #   --------------
    #   minimum time:     10.622 ms (0.00% GC)
    #   median time:      10.892 ms (0.00% GC)
    #   mean time:        11.700 ms (5.37% GC)
    #   maximum time:     21.715 ms (17.32% GC)
    #   --------------
    #   samples:          428
    #   evals/sample:     1
