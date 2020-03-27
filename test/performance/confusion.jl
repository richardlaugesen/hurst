# Copyright 2018-2020 Tiny Rock Pty Ltd
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

module TestConfusion

using Hurst.Performance.Confusion

using Test

@testset "Confusion" begin
    @testset "Confusion matrix" begin
        conf_scaled_1 = confusion_scaled(10, 2, 2, 15860)
        conf_scaled_2 = confusion_scaled(8, 6, 2, 15858)
        conf_1 = confusion(10, 2, 2, 15860)
        conf_2 = confusion(8, 6, 2, 15858)
        get_elements = conf -> map(k -> conf[k], [:hits, :misses, :false_alarms, :quiets])

        @testset "Keys" begin
            @test conf_1[:hits] == conf_1[:true_positives]
            @test conf_1[:false_alarms] == conf_1[:type_i_error]
            @test conf_1[:hits] != conf_2[:hits]
            @test conf_1[:false_alarms] == conf_2[:false_alarms]
        end

        @testset "Scaling" begin
            @test conf_scaled_1[:hits] == conf_1[:hits] / sum(get_elements(conf_1))
            @test conf_scaled_2[:quiets] == conf_2[:quiets] / sum(get_elements(conf_2))
        end

        @testset "Totals" begin
            @test sum(get_elements(conf_scaled_1)) == 1
            @test sum(get_elements(conf_1)) > 1
            @test sum(get_elements(conf_scaled_1)) == sum(get_elements(conf_scaled_2))
            @test sum(get_elements(conf_1)) == sum(get_elements(conf_2))
        end

        @testset "Observed frequencies" begin
            @test conf_scaled_1[:false_alarms] + conf_scaled_1[:quiets] == 1 - (conf_scaled_1[:hits] + conf_scaled_1[:misses])
            @test conf_scaled_1[:hits] + conf_scaled_1[:misses] != conf_scaled_2[:hits] + conf_scaled_2[:misses]
            @test conf_1[:false_alarms] + conf_1[:quiets] != 1 - (conf_1[:hits] + conf_1[:misses])
        end
    end
end
end
