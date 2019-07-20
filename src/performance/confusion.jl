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

module Confusion

export confusion, confusion_scaled

"""
    confusion(hits, misses, false_alarms, quiets)

Returns a Dict containing fields of a
[confusion matrix](https://en.wikipedia.org/wiki/Confusion_matrix) with the
various common names used for each combination of the 2x2 grid.

See also: [`confusion_scaled(hits, misses, false_alarms, quiets)`](@ref)
"""
function confusion(hits, misses, false_alarms, quiets)
    Dict(
        :hits => hits,
        :true_positives => hits,

        :misses => misses,
        :false_negatives => misses,
        :type_ii_error => misses,
        :missed_events => misses,

        :false_alarms => false_alarms,
        :false_positive => false_alarms,
        :type_i_error => false_alarms,

        :correct_misses => quiets,
        :true_negatives => quiets,
        :quiets => quiets,
        :correct_negatives => quiets
    )
end

"""
    confusion_scaled(hits, misses, false_alarms, quiets)

Returns a Dict containing fields of a
[confusion matrix](https://en.wikipedia.org/wiki/Confusion_matrix) with the
various common names used for each combination of the 2x2 grid scaled to be
relative to the number of events and non-events
(hits + misses + false_alarms + quiets).

See also: [`confusion(hits, misses, false_alarms, quiets)`](@ref)
"""
function confusion_scaled(hits, misses, false_alarms, quiets)
    total = hits + misses + false_alarms + quiets
    return confusion(hits/total, misses/total, false_alarms/total, quiets/total)
end

end
