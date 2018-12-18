using CSV

data = CSV.read("test/data/test_2_data.csv", header=1, missingstrings=["-9999"])
obs, sim = data[:obs_runoff], data[:obs_runoff_sim_0]

x = rand(100)
y = rand(100)

@testset "Nash Sutcliffe Efficiency (and coefficient of determination)" begin
    @testset "Basic series" begin
        @test nse(y, y) == 1
        @test nse(y, x) < 0
        @test nse([1,2,3,4,5], [2,3,4,5,6]) == 0.5
        @test nse([1,2,3,4,5], [6,7,8,9,10]) == -11.5
    end

    @testset "Corrupted obsverations" begin
        @test nse(y, y .+ 0.1) < 1
        @test nse(y, y .* 0.1) < 1
        @test nse(y, y .+ 0.1) > nse(y, y .+ 0.5)
    end

    @testset "No observation variance" begin
        @test nse(1, 2) == -Inf
        @test nse([1, 1, 1], [2, 2, 2]) == -Inf
        @test isequal(nse([2, 2, 2], [2, 2, 2]), NaN)
    end

    @testset "Missing data" begin
        @test nse([1, missing, 3, 4], [1, 2, 3, 4]) == 1
        @test isapprox(nse([1, 2, missing, 4], [6, missing, 8, 9]), -9.7142857, atol=1e-7)
        @test_throws MethodError nse([missing, missing, missing], [1, 2, 3])
        @test_throws MethodError nse([1, 2, 3], [missing, missing, missing])
    end

    @testset "Real data" begin
        @test isapprox(nse(obs, sim), 0.841729, atol=1e-6)
    end
end

@testset "Kling-Gupta Efficiency" begin
    @testset "Basic series" begin
        @test isapprox(kge(y, y), 1, atol=1e-9)
        @test kge(y, x) < 0.5
        @test isapprox(kge([1,2,3,4,5], [2,3,4,5,6]), 0.66666, atol=1e-4)
        @test isapprox(kge([1,2,3,4,5], [6,7,8,9,10]), -0.66666, atol=1e-4)
    end

    @testset "Corrupted obsverations" begin
        @test kge(y, y .+ 0.1) < 1
        @test kge(y, y .* 0.1) < 1
        @test kge(y, y .+ 0.1) > kge(y, y .+ 0.5)
    end

    @testset "No observation variance" begin
        @test_throws ArgumentError kge(1, 2)
        @test isequal(kge([1, 1, 1], [2, 2, 2]), NaN)
        @test isequal(kge([2, 2, 2], [2, 2, 2]), NaN)
    end

    @testset "Missing data" begin
        @test kge([1, missing, 3, 4], [1, 2, 3, 4]) == 1
        @test kge([1, 2, missing, 4], [6, missing, 8, 9]) == -1
        @test_throws UndefVarError kge([missing, missing, missing], [1, 2, 3])  # TODO: throw a better exception
        @test_throws UndefVarError kge([1, 2, 3], [missing, missing, missing])
    end

    @testset "Real data" begin
        @test isapprox(kge(obs, sim), 0.8446, atol=1e-4)
    end
end

@testset "Mean Absolute Error" begin
    @testset "Basic series" begin
        @test mae(y, y) == 0
        @test mae(y, x) > 0
        @test mae(1, 2) == Inf
        @test isequal(mae(1, 1), NaN)
    end

    @testset "Corrupted obsverations" begin
        @test mae(y, y .+ 0.1) > 0
        @test mae(y, y .* 0.1) > 0
        @test mae(y, y .+ 0.1) < mae(y, y .+ 0.5)
    end

    @testset "Missing data" begin
        @test mae([1, missing, 3, 4], [1, 2, 3, 4]) == 0
        @test mae([1, 2, missing, 4], [6, missing, 8, 9]) == 5
        @test_throws MethodError mae([missing, missing, missing], [1, 2, 3])
        @test_throws MethodError mae([1, 2, 3], [missing, missing, missing])
    end

    @testset "Real data" begin
        @test isapprox(mae(obs, sim), 0.388019, atol=1e-6)
    end
end

@testset "Mean Square Error" begin
    @testset "Basic series" begin
        @test mse(y, y) == 0
        @test mse(y, x) > 0
        @test mse(1, 2) == Inf
        @test isequal(mse(1, 1), NaN)
    end

    @testset "Corrupted obsverations" begin
        @test mse(y, y .+ 0.1) > 0
        @test mse(y, y .* 0.1) > 0
        @test mse(y, y .+ 0.1) < mse(y, y .+ 0.5)
    end

    @testset "Missing data" begin
        @test mse([1, missing, 3, 4], [1, 2, 3, 4]) == 0
        @test mse([1, 2, missing, 4], [6, missing, 8, 9]) == 25
        @test_throws MethodError mse([missing, missing, missing], [1, 2, 3])
        @test_throws MethodError mse([1, 2, 3], [missing, missing, missing])
    end

    @testset "Real data" begin
        @test isapprox(mse(obs, sim), 1.9393, atol=1e-3)
    end
end

@testset "Root Mean Square Error" begin
    @test rmse(obs, sim) == sqrt(mse(obs, sim))
end
