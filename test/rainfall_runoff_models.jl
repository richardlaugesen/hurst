using CSV
using DataFrames

@testset "GR4J" begin

    @testset "Run step" begin
        params = gr4j_reasonable_parameters()
        init_state = gr4j_init_state(params)

        @test gr4j_run_step(0, 0, init_state, params)[1] == 0
        @test gr4j_run_step(100, 5, init_state, params)[1] == 0.0014242748609873776
    end

    @testset "Run CSV" begin
        data = CSV.read("test/data/hydromet.csv", missingstrings="-9999", header=1) #, limit=100)
        params = gr4j_parameters(455.042087, -5.089095, 248.706793, 1.026477)
        init_state = gr4j_init_state(params)

        result = gr4j_simulate(data, params, init_state)
        last = nrow(result)

        @test :runoff_sim in names(result)
        @test result[1, :obs_runoff_sim_0] ≈ result[1, :runoff_sim]
        @test result[last, :obs_runoff_sim_0] ≈ result[last, :runoff_sim]
    end

    @testset "Run Andrews test" begin
        # https://github.com/amacd31/gr4j/blob/master/tests/test_gr4j.py

        sims = CSV.read("test/data/sims.csv", header=0, skipto=2)[1]
        data = CSV.read("test/data/USGS_02430680_combined.csv", header=2, skipto=2, limit=729)
        names!(data, Symbol.(["date", "obs_rain", "obs_pet", "obs_runoff"]))

        params = gr4j_parameters(303.627616, 0.32238919, 6.49759466, 0.294803885)

        init_state = gr4j_init_state(params)
        init_state["production_store"] = params["x1"] * 0.6
        init_state["routing_store"] = params["x3"] * 0.7

        result = gr4j_simulate(data, params, init_state)
        last = nrow(result)

        @test sims[1] ≈ result[1, :runoff_sim]
        @test sims[last] ≈ result[last, :runoff_sim]
    end
end
