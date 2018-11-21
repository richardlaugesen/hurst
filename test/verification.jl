
@testset "Box-cox transformation" begin
    y = rand(1000)

    @testset "λ = 0" begin
        λ = 0
        @test_throws DomainError boxcox(-1, λ)
        @test boxcox(0, λ) == -Inf
        @test boxcox(2, λ) == log(2)
        @test boxcox([1, 1, 1, 1], λ) == [0, 0, 0, 0]
        @test boxcox_inverse(boxcox(y, λ), λ) ≈ y
    end

    @testset "λ = 0.2" begin
        λ = 0.2
        @test_throws DomainError boxcox(-1, λ)
        @test boxcox(0, λ) == -1 / λ
        @test boxcox(2, λ) == (2^λ - 1) / λ
        @test boxcox([1, 1, 1, 1], λ) == [0, 0, 0, 0]
        @test boxcox_inverse(boxcox(y, λ), λ) ≈ y
    end

    @testset "λ=$λ (range testset)" for λ in -3:0.1:3
        @test boxcox_inverse(boxcox(y, λ), λ) ≈ y
    end
end
