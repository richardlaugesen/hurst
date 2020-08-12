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

module TestEconomic

using Hurst.Performance.Economic
using Hurst.Performance.Confusion

using Test

@testset "Economic" begin
    @testset "Cost-Loss" begin

        @testset "Cost-loss base method" begin
            conf_scaled = confusion_scaled(10, 2, 2, 15860)
            @test cost_loss(0.2, 1.0, conf_scaled) == cost_loss_verkade(0.2, 1.0, conf_scaled)
            @test cost_loss(0.2, 1.0, conf_scaled, method="roulin") == cost_loss_roulin(0.2, 1.0, conf_scaled)
            @test cost_loss(0.2, 1.0, conf_scaled, method="verkade") == cost_loss_verkade(0.2, 1.0, conf_scaled)
            @test cost_loss(0.2, 1.0, conf_scaled, method="anything") == cost_loss_verkade(0.2, 1.0, conf_scaled)
        end

        @testset "Richardson method" begin
            conf_scaled = confusion_scaled(10, 2, 2, 15860)

            f_1 = conf_scaled[:quiets]
            f_2 = conf_scaled[:misses]
            f_3 = conf_scaled[:false_alarms]
            f_4 = conf_scaled[:hits]

            α = 0.2
            μ = f_2 + f_4
            H = f_4 / μ
            F = f_3 / (1 - μ)

            @test cost_loss_richardson(α, μ, H, F) == cost_loss_roulin(α, 1.0, conf_scaled)
        end

        @testset "Method = $cost_loss_method" for cost_loss_method in [cost_loss_verkade, cost_loss_roulin]
            @testset "Basic behaviour" begin
                @test isequal(cost_loss_method(0.5, 1.0, confusion_scaled(0, 0, 0, 0)), NaN)
                @test cost_loss_method(0.5, 1.0, confusion_scaled(1, 0, 1, 0)) == 0
                @test cost_loss_method(0.5, 1.0, confusion_scaled(1, 0, 2, 0)) ≈ -1
                @test cost_loss_method(0.5, 1.0, confusion_scaled(1, 0, 1E9, 0)) ≈ -1E9

                conf_scaled = confusion_scaled(10, 2, 2, 15860)
                @test cost_loss_method(0.3, 1.0, conf_scaled) > cost_loss_method(0.8, 1.0, conf_scaled)

                if cost_loss_method == cost_loss_verkade
                    @test cost_loss_method(0.5, 1.0, confusion_scaled(1, 0, 0, 0)) == 1
                    @test cost_loss_method(0, 1, confusion_scaled(1, 0, 2, 0)) == 1

                # Roulin method not defined for some values
                elseif cost_loss_method == cost_loss_roulin
                    @test cost_loss_method(0.5, 1.0, confusion_scaled(1, 0, 0, 1)) == 1
                    @test isequal(cost_loss_method(0, 1, confusion_scaled(1, 0, 2, 0)), NaN)
                end
            end

            if cost_loss_method == cost_loss_verkade
                @testset "Scaled confusion matrix equivilant to non-scaled (Verkade method only)" begin
                    conf_scaled = confusion_scaled(10, 2, 2, 15860)
                    conf = confusion(10, 2, 2, 15860)
                    @testset "CL ratio r=$r (scaled range test)" for r in 0:0.2:1
                        @test cost_loss_verkade(r, 1.0, conf) ≈ cost_loss_verkade(r, 1.0, conf_scaled)
                    end
                end
            end

            # Note: Verkade and Roulin treat quiets differently close to zero (see example)
            @testset "quiets irrelevant q=$q (scaled range testset)" for q in 1000:1010
                @test cost_loss_method(0.5, 1.0, confusion_scaled(200, 0, 100, q)) ≈ 0.5
            end

            @testset "Real example" begin
                conf_scaled = confusion_scaled(10, 2, 2, 15860)
                @test isapprox(cost_loss_method(0.2, 1.0, conf_scaled), 0.7917, atol=10e-4)
                @test isapprox(cost_loss_method(0.7, 1.0, conf_scaled), 0.4444, atol=10e-4)
            end

            @testset "False alarms" begin
                no_false_alarms = confusion_scaled(10, 2, 0, 15860)
                @test cost_loss_method(0.1, 1.0, no_false_alarms) ≈ cost_loss_method(0.9, 1.0, no_false_alarms)

                with_false_alarms = confusion_scaled(10, 2, 5, 15860)
                @test cost_loss_method(0.1, 1.0, with_false_alarms) != cost_loss_method(0.9, 1.0, with_false_alarms)
            end

            @testset "Random confusions and CL ratios is -Inf ≤ V ≤ 1" begin
                correct_range = true
                for i in 1:1000
                    if cost_loss_method(rand(), 1.0, confusion_scaled(rand(), rand(), rand(), rand())) > 1
                        correct_range = false
                    end
                end
                @test correct_range == true
            end
        end
    end
end
end
