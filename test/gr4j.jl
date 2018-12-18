using CSV
using DataFrames
using BenchmarkTools

@testset "GR4J" begin

    df = CSV.read("test/data/test_1_data.csv", header=1, missingstrings=["-9999"])
    names!(df, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))

    data = Dict()
    data["rain"] = df[:obs_rain]
    data["pet"] = df[:obs_pet]
    data["runoff_obs"] = df[:obs_runoff]
    data["runoff_sim_test"] = df[:test_sim_runoff]

    @testset "Single timestep" begin
        pars = gr4j_params_default()
        init_state = gr4j_init_state(pars)

        @test gr4j_run_step(0, 0, init_state, pars)[1] == 0
        @test gr4j_run_step(100, 5, init_state, pars)[1] ≈ 0.2270703669963994
        @test gr4j_run_step(1000, 0, init_state, pars)[1] ≈ 605.529053798641
    end

    @testset "2 year simulation" begin
        pars = gr4j_params_from_array(CSV.read("test/data/test_1_params.csv", delim=":", header=0)[2])
        init_state = gr4j_init_state(pars)
        init_state["production_store"] = pars["x1"] * 0.6
        init_state["routing_store"] = pars["x3"] * 0.7

        result = simulate(gr4j_run_step, data, pars, init_state)

        @test isapprox(result["runoff_sim_test"][1], result["runoff_sim"][1], atol=0.0001)
        @test isapprox(result["runoff_sim_test"][400], result["runoff_sim"][400], atol=0.0001)
        @test isapprox(result["runoff_sim_test"][end], result["runoff_sim"][end], atol=0.0001)
    end

    @testset "Benchmarks" begin
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

        @test typeof(default) == Dict{String, Float64}
        @test length(default) == 4
        @test sort(collect(keys(default))) == ["x1", "x2", "x3", "x4"]

        @test typeof(random) == Dict{String, Float64}
        @test length(random) == 4
        @test sort(collect(keys(random))) == ["x1", "x2", "x3", "x4"]

        @test isapprox(default_trans_arr, [5.8579, 0.0, 3.9120, -20.7232], atol=1e-4)
        @test gr4j_params_trans_inv(default_trans) == default

        @test typeof(prange) == Dict{String,Dict{String,Float64}}
        @test length(prange) == 4
        @test typeof(prange["x1"]) == Dict{String,Float64}
        @test length(prange["x1"]) == 2

        @test typeof(prange_tuples) == Array{Tuple{Float64,Float64},1}
        @test size(prange_tuples) == (4,)
        @test length(prange_tuples[1]) == 2
        @test prange_tuples[1][2] == prange["x1"]["high"]
        @test prange_tuples[4][1] == prange["x4"]["low"]
    end
end
