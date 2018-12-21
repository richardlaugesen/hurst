module BenchmarkGr4j
using Test, Hydro, CSV, DataFrames, BenchmarkTools

@testset "GR4J Benchmarks" begin

    # load some test data
    df = CSV.read("data/test_1_data.csv", header=1, missingstrings=["-9999"])
    names!(df, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))

    data = Dict()
    data["rain"] = df[:obs_rain]
    data["pet"] = df[:obs_pet]
    data["runoff_obs"] = df[:obs_runoff]
    data["runoff_sim_test"] = df[:test_sim_runoff]

    # typical timestep in less than 50 microseconds
    pars = gr4j_params_default()
    init_state = gr4j_init_state(pars)
    init_state["production_store"] = pars["x1"] * 0.6
    init_state["routing_store"] = pars["x3"] * 0.7

    typical = @belapsed gr4j_run_step(10, 5, $init_state, $pars)
    @test typical < (50 * 1e-6)

    # huge X4 doesn't cost more than an extra 10 millisecond
    pars["x4"] = 40
    init_state = gr4j_init_state(pars)
    init_state["production_store"] = pars["x1"] * 0.6
    init_state["routing_store"] = pars["x3"] * 0.7

    huge_x4 = @belapsed gr4j_run_step(10, 5, $init_state, $pars)
    @test (huge_x4 - typical) < (10 * 1e-6)

    # two paths through production store cost the same
    pars = gr4j_params_from_array([320.1073, 2.4208, 69.6276, 1.3891])
    init_state = gr4j_init_state(pars)
    init_state["production_store"] = pars["x1"] * 0.6
    init_state["routing_store"] = pars["x3"] * 0.7

    evap_path = @belapsed gr4j_run_step(5, 100, $init_state, $pars)
    precip_path = @belapsed gr4j_run_step(100, 5, $init_state, $pars)
    @test isapprox(evap_path, precip_path, atol=1e-6)

    # simulation of 2 years data should take less than 50 milliseconds
    @test (@belapsed simulate(gr4j_run_step, $data, $pars, $init_state)) < (50 * 1e-3)
end

end
