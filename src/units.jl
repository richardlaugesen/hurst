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

module Units

export cumecs_to_megalitres_day, megalitres_day_to_cumecs
export mm_runoff_to_megalitres, megalitres_to_mm_runoff
export km2_to_m2, m2_to_km2
export km2_to_acres, acres_to_km2

"""
    cumecs_to_megalitres_day(q)

Convert cubic metres per second of streamflow `q` into
megalitres per day of volume.

See also: [`megalitres_day_to_cumecs(v)`](@ref)
"""
cumecs_to_megalitres_day(q) = q * 86.4

"""
    megalitres_day_to_cumecs(v)

Convert megalitres per day of volume `v` into
cubic metres per second of streamflow.

See also: [`cumecs_to_megalitres_day(q)`](@ref)
"""
megalitres_day_to_cumecs(v) = v / 86.4

"""
    mm_runoff_to_megalitres(d, area)

Use the catchment `area` (kilometres) to convert a depth `d` of
catchment average runoff (millimetres) into volume (megalitres).

See also: [`megalitres_to_mm_runoff(v, area)`](@ref)
"""
mm_runoff_to_megalitres(d, area) = d * area

"""
    megalitres_to_mm_runoff(v, area)

Use the catchment `area` (kilometres) to convert a volume `v` (megalitres)
into catchment average runoff (millimetres).

See also: [`mm_runoff_to_megalitres(d, area)`](@ref)
"""
megalitres_to_mm_runoff(v, area) = v / area

"""
    km2_to_m2(a)

Convert an area in square kilometres to an area in square metres.

See also: [`m2_to_km2(a)`](@ref)
"""
km2_to_m2(a) = a * 1e6

"""
    m2_to_km2(a)

Convert an area in square metres to an area in square kilometres.

See also: [`km2_to_m2(a)`](@ref)
"""
m2_to_km2(a) = a / 1e6

"""
    km2_to_acres(a)

Convert an area in square kilometres to an area in acres.

See also: [`acres_to_km2(a)`](@ref)
"""
km2_to_acres(a) = a * 247.1

"""
    acres_to_km2(a)

Convert an area in acres to an area in square kilometres.

See also: [`km2_to_acres(a)`](@ref)
"""
acres_to_km2(a) = a * 0.004046944556859571

end
