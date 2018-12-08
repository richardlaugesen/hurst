using CSV
using DataFrames
using Plots

@testset "GR4J" begin

    @testset "Run step" begin
        params = gr4j_reasonable_parameters()
        init_state = gr4j_init_state(params)

        @test gr4j_run_step(0, 0, init_state, params)[1] == 0
        @test gr4j_run_step(100, 5, init_state, params)[1] == 0.0014248522376373149
        @test gr4j_run_step(1000, 0, init_state, params)[1] == 1.0416849478510568
    end

    @testset "Simulation" begin
        data = CSV.read("test/data/test_data.csv", header=1)
        names!(data, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff", "test_sim_runoff"]))

        params = gr4j_parameters(320.1073, 2.4208, 69.6276, 1.3891)

        init_state = gr4j_init_state(params)
        init_state["production_store"] = params["x1"] * 0.6
        init_state["routing_store"] = params["x3"] * 0.7

        result = gr4j_simulate(data, params, init_state)

        @test isapprox(result[1, :test_sim_runoff], result[1, :runoff_sim], atol=0.0001)
        @test isapprox(result[400, :test_sim_runoff], result[400, :runoff_sim], atol=0.0001)
        @test isapprox(result[728, :test_sim_runoff], result[728, :runoff_sim], atol=0.0001)
    end
end
