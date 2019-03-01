# Copyright 2018-2019 Richard Laugesen
#
# This file is part of Hydro.jl
#
# Hydro.jl is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Hydro.jl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Hydro.jl.  If not, see <https://www.gnu.org/licenses/>.

module TestTransforms

using Hydro, Hydro.Transformations
using Test

@testset "Transformations" begin
    @testset "Box-cox transform" begin
        y = rand(100)

        @testset "λ = 0" begin
            λ = 0
            @test_throws DomainError boxcox(-1, λ)
            @test boxcox(0, λ) == -Inf
            @test boxcox(2, λ) == log(2)
            @test boxcox([1, 1, 1, 1], λ) == [0, 0, 0, 0]
            @test boxcox([1, 1, 1, 1], 1e-9) == boxcox([1, 1, 1, 1], 0)
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

        @testset "λ=$λ (range testset)" for λ in -3:0.5:3
            @test boxcox_inverse(boxcox(y, λ), λ) ≈ y
        end

        @testset "Two-param" begin
            λ = 0.2
            ν = 0.3
            y = rand(10)
            @test boxcox(y, λ, 0) == boxcox(y, λ)
            @test boxcox_inverse(boxcox(y, λ, ν), λ, ν) ≈ y
        end
    end

    @testset "Log-sinh transform" begin
        y = rand(100)

        @testset "a = 0, b = 1" begin
            a = 0
            b = 1
            @test_throws DomainError log_sinh(-1, a, b)
            @test log_sinh(2, a, b) == log(sinh(2))
            @test log_sinh_inverse(log_sinh(y, a, b), a, b) ≈ y
        end

        @testset "a = 0.00003, b = 0.01" begin
            a = 0.00003
            b = 0.01
            @test_throws DomainError log_sinh(-1, a, b)
            @test log_sinh(0, a, b) == log(sinh(a)) / b
            @test log_sinh(2, a, b) == log(sinh(a + 2b)) / b
            @test log_sinh_inverse(log_sinh(y, a, b), a, b) ≈ y
        end
    end

    @testset "Log transform" begin
        y = rand(100)
        @test log_trans(y) == log.(y)
        @test log_trans_inverse(log_trans(y)) ≈ y
        @test log_trans(y) == log_trans(y, 0)
        @test log_trans(y, 0.17) == log.(y .+ 0.17)
        @test log_trans_inverse(log_trans(y, 56), 56) ≈ y
        @test log_trans_inverse(y) == exp.(y)
        @test log_trans_inverse(y, 17) == exp.(y) .- 17
    end
end
end
