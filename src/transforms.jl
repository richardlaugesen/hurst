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

module Transformations

export boxcox, boxcox_inverse
export log_sinh, log_sinh_inverse
export log_trans, log_trans_inverse

"""
    boxcox(y, λ, ν)

Two param box-cox transform. ([Wikipedia](https://en.wikipedia.org/wiki/Power_transform))

Box, G. E. P., and D. R. Cox (1964), An analysis of transformations,
J. R. Stat. Soc., Ser. B, 26, 296–311.

See also: [`boxcox_inverse(z, λ, ν)`](@ref)
"""
function boxcox(y, λ, ν)
    if abs(λ) < 1e-8
        log.(y .+ ν)
    else
        ((y .+ ν).^λ .- 1) / λ
    end
end

"""
    boxcox_inverse(z, λ, ν)

Inverse of the two param box-cox transform. ([Wikipedia](https://en.wikipedia.org/wiki/Power_transform))

Box, G. E. P., and D. R. Cox (1964), An analysis of transformations,
J. R. Stat. Soc., Ser. B, 26, 296–311.

See also: [`boxcox(y, λ, ν)`](@ref)
"""
function boxcox_inverse(z, λ, ν)
    if abs(λ) < 1e-8
        exp.(z) .- ν
    else
        (λ*z .+ 1).^(1/λ) .- ν
    end
end

"""
    boxcox(y, λ)

One param box-cox transform. ([Wikipedia](https://en.wikipedia.org/wiki/Power_transform))

Box, G. E. P., and D. R. Cox (1964), An analysis of transformations,
J. R. Stat. Soc., Ser. B, 26, 296–311.

See also: [`boxcox_inverse(z, λ)`](@ref)
"""
boxcox(y, λ) = boxcox(y, λ, 0)

"""
    boxcox_inverse(z, λ)

Inverse of the one param box-cox transform. ([Wikipedia](https://en.wikipedia.org/wiki/Power_transform))

Box, G. E. P., and D. R. Cox (1964), An analysis of transformations,
J. R. Stat. Soc., Ser. B, 26, 296–311.

See also: [`boxcox(y, λ)`](@ref)
"""
boxcox_inverse(z, λ) = boxcox_inverse(z, λ, 0)

"""
    log_sinh(y, a, b)

Log-sinh transform.

Wang, Q. J., D. L. Shrestha, D. E. Robertson, and P. Pokhrel (2012b), A
log-sinh transformation for data normalization and variance stabiliza- tion,
Water Resour. Res., 48, W05514, doi:10.1029/2011WR010973.

See also: [`log_sinh_inverse(z, a, b)`](@ref)
"""
function log_sinh(y, a, b)
    log.(sinh.(a .+ b * y)) / b
end

"""
    log_sinh_inverse(z, a, b)

Inverse of the log-sinh transform.

Wang, Q. J., D. L. Shrestha, D. E. Robertson, and P. Pokhrel (2012b), A
log-sinh transformation for data normalization and variance stabiliza- tion,
Water Resour. Res., 48, W05514, doi:10.1029/2011WR010973.

See also: [`log_sinh(y, a, b)`](@ref)
"""
function log_sinh_inverse(z, a, b)
    (asinh.(exp.(b * z)) .- a) / b
end

"""
    log_trans(y, offset)

Log transform with offset. ([Wikipedia](https://en.wikipedia.org/wiki/Data_transformation_%28statistics%29))

See also: [`log_trans_inverse(z, offset)`](@ref)
"""
function log_trans(y, offset)
    log.(y .+ offset)
end

"""
    log_trans_inverse(z, offset)

Inverse log transform with offset. ([Wikipedia](https://en.wikipedia.org/wiki/Data_transformation_%28statistics%29))

See also: [`log_trans(y, offset)`](@ref)
"""
function log_trans_inverse(z, offset)
    exp.(z) .- offset
end

"""
    log_trans(y)

Log transform with no offset. ([Wikipedia](https://en.wikipedia.org/wiki/Data_transformation_%28statistics%29))

See also: [`log_trans_inverse(z)`](@ref)
"""
log_trans(y) = log_trans(y, 0)

"""
    log_trans_inverse(z)

Inverse log transform with no offset. ([Wikipedia](https://en.wikipedia.org/wiki/Data_transformation_%28statistics%29))

See also: [`log_trans(y)`](@ref)
"""
log_trans_inverse(z) = log_trans_inverse(z, 0)

end
