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

cumecs_to_megalitres_day(q) = q * 86.4
megalitres_day_to_cumecs(v) = v / 86.4

mm_runoff_to_megalitres(d, area_km) = d * area_km
megalitres_to_mm_runoff(v, area_km) = v / area_km

km2_to_m2(a) = a * 1e6
m2_to_km2(a) = a / 1e6
