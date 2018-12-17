@testset "Nash Sutcliffe Efficiency (and coefficient of determination)" begin
    x = rand(100)
    y = rand(100)

    @testset "Basic series" begin
        @test nse(y, y) == 1
        @test nse(y, x) < 0
        @test nse([1,2,3,4,5], [2,3,4,5,6]) == 0.5
        @test nse([1,2,3,4,5], [6,7,8,9,10]) == -11.5
    end

    @testset "Corrupted obsverations" begin
        @test nse(y, y .+ 0.1) < 1
        @test nse(y, y .+ 0.1) < 1
        @test nse(y, y .* 0.1) < 1
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
end
