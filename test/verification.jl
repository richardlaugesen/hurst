# Copyright 2018-2019 Richard Laugesen
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

module TestVerification

using Hurst.Verification

using Test
using CSV

data = CSV.read("data/test_2_data.csv", header=1, missingstrings=["-9999"])
obs, sim = data[:obs_runoff], data[:obs_runoff_sim_0]

x = rand(100)
y = rand(100)

@testset "Verification" begin
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

    @testset "Cost-Loss" begin
        @testset "Basic behaviour" begin
            @test isequal(cost_loss_rev(0.5, 1.0, confusion_scaled(0, 0, 0, 0)), NaN)
            @test cost_loss_rev(0.5, 1.0, confusion_scaled(1, 0, 0, 0)) == 1
            @test cost_loss_rev(0.5, 1.0, confusion_scaled(1, 0, 1, 0)) == 0
            @test cost_loss_rev(0.5, 1.0, confusion_scaled(0, 0, 1, 0)) == -Inf
            @test cost_loss_rev(0.5, 1.0, confusion_scaled(1, 0, 2, 0)) ≈ -1

            conf_scaled = confusion_scaled(10, 2, 2, 15860)
            @test cost_loss_rev(0.3, 1.0, conf_scaled) > cost_loss_rev(0.8, 1.0, conf_scaled)
        end

        @testset "quiets irrelevant q=$q (scaled range testset)" for q in 0:10
            @test cost_loss_rev(0.5, 1.0, confusion_scaled(2, 0, 1, q)) ≈ 0.5
        end

        @testset "Scaled confusion matrix equivilant to non-scaled" begin
            conf_scaled = confusion_scaled(10, 2, 2, 15860)
            conf = confusion(10, 2, 2, 15860)
            @testset "CL ratio r=$r (scaled range test)" for r in 0:0.2:1
                @test cost_loss_rev(r, 1.0, conf) ≈ cost_loss_rev(r, 1.0, conf_scaled)
            end
        end

        @testset "Real example" begin
            conf_scaled = confusion_scaled(10, 2, 2, 15860)
            @test isapprox(cost_loss_rev(0.2, 1.0, conf_scaled), 0.7917, atol=10e-4)
            @test isapprox(cost_loss_rev(0.7, 1.0, conf_scaled), 0.4444, atol=10e-4)
        end

        @testset "False alarms" begin
            no_false_alarms = confusion_scaled(10, 2, 0, 15860)
            @test cost_loss_rev(0.1, 1.0, no_false_alarms) ≈ cost_loss_rev(0.9, 1.0, no_false_alarms)

            with_false_alarms = confusion_scaled(10, 2, 5, 15860)
            @test cost_loss_rev(0.1, 1.0, with_false_alarms) != cost_loss_rev(0.9, 1.0, with_false_alarms)
        end

        @testset "Random confusions and CL ratios is -Inf ≤ V ≤ 1" begin
            correct_range = true
            for i in 1:1000
                if cost_loss_rev(rand(), 1.0, confusion_scaled(rand(), rand(), rand(), rand())) > 1
                    correct_range = false
                end
            end
            @test correct_range == true
        end
    end
end
end
