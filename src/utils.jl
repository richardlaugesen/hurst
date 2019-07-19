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

module Utils

using DataFrames

export length_no_missing, lshift, dataframify, dropna

function length_no_missing(ar)
    length(collect(skipmissing(ar)))
end

function lshift(v)
    v = circshift(v, -1)
    v[length(v)] = 0
    return v
end

function dataframify(x...)
    DataFrame([x...])
end

function dropna(ar...)
    df = dataframify(ar...)
    cases = completecases(df)
    return df[cases, 1], df[cases, 2]  # TODO: expand this over the ...
end

end
