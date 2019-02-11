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

module Hydro

# Example model for study
export ostp_run_step, ostp_init_state
export ostp_params_from_array, ostp_params_to_array
export ostp_params_default, ostp_params_random
export ostp_params_range, ostp_params_range_trans, ostp_params_range_to_tuples
export ostp_params_trans, ostp_params_trans_inv

# GR4J rainfall runoff model
export gr4j_run_step, gr4j_init_state
export gr4j_params_from_array, gr4j_params_to_array
export gr4j_params_default, gr4j_params_random
export gr4j_params_range, gr4j_params_range_trans, gr4j_params_range_to_tuples
export gr4j_params_trans, gr4j_params_trans_inv

# model running
export simulate
export calibrate

# verification and figures
export coeff_det, nse, mae, mse, rmse, kge, persistence
export hydrograph

# Data transformations
export boxcox, boxcox_inverse
export log_sinh, log_sinh_inverse
export log_trans, log_trans_inverse

# Unit conversions
export cumecs_to_megalitres_day, megalitres_day_to_cumecs
export mm_runoff_to_megalitres, megalitres_to_mm_runoff
export km2_to_m2, m2_to_km2
export km2_to_acres, acres_to_km2

include("util.jl")
include("units.jl")
include("verification.jl")
include("transforms.jl")
include("ostp.jl")
include("gr4j.jl")
include("simulate.jl")
include("calibrate.jl")
include("visualisation.jl")

end
