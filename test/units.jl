# Copyright 2018-2020 Richard Laugesen
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

module TestUnits

using Hurst.Units

using Test

@testset "Units" begin
    @testset "Streamflow and volume" begin
        @test cumecs_to_megalitres_day(2000) == 172800
        @test isapprox(megalitres_day_to_cumecs(8000), 92.593, atol=1e-3)
        @test isapprox(cumecs_to_megalitres_day(megalitres_day_to_cumecs(100)), 100, atol=1e-10)
    end

    @testset "Streamflow and runoff" begin
        @test mm_runoff_to_megalitres(10, 800) == 8000
        @test isapprox(megalitres_to_mm_runoff(1000, 1000), 1, atol=1e-7)
        @test mm_runoff_to_megalitres(megalitres_to_mm_runoff(1000, 8), 8) == 1000
    end

    @testset "Area" begin
        @test km2_to_m2(10) == 10e6
        @test m2_to_km2(1e8) == 100
        @test km2_to_m2(m2_to_km2(1)) == 1

        @test km2_to_acres(12) == 2965.2
        @test isapprox(acres_to_km2(6200), 25.091056, atol=1e-6)
        @test isapprox(km2_to_acres(acres_to_km2(1)), 1, atol=1e-7)
    end
end
end
