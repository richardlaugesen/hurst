using CSV

@testset "GR4J" begin

    @testset "Run step" begin
        params = gr4j_reasonable_parameters()
        init_state = gr4j_init_state(params)

        @test gr4j_run_step(100, 5, init_state, params)[1] == 68.235244298729
    end

    @testset "Run CSV" begin
        data = CSV.read("test/data/hydromet.csv", missingstrings="-9999")
        params = gr4j_parameters(455.042087, -5.089095, 248.706793, 1.026477)
        init_state = gr4j_init_state(params)

        result = gr4j_simulate(data, params, init_state)
        last_row = result[nrow(result), :]

        @test :runoff_sim in names(result)
        @test last_row[:obs_runoff_sim_0] ≈ last_row[:runoff_sim]
    end
end
