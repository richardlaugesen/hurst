# Copyright 2018-2019 Tiny Rock Pty Ltd
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

module TestOSTP

using Hurst
using Hurst.OSTP

using Test
using CSV
using DataFrames

@testset "OSTP" begin
    @testset "Single timestep" begin
        pars = ostp_params_from_array([100, 0])
        init_state = 0
        @test ostp_run_step(1, 0, init_state, pars)[1] == 0

        pars = ostp_params_from_array([100, 50])
        init_state = ostp_init_state(pars)
        @test ostp_run_step(20, 7, init_state, pars)[1] == 0
        @test ostp_run_step(200, 7, init_state, pars)[1] == 93
    end
end

end
