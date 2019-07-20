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

# Reproduce relative economic figure from Verkade 2011
#
# Verkade, J. S., and M. G. F. Werner. “Estimating the Benefits of Single Value
# and Probability Forecasting for Flood Warning.” Hydrology and Earth System
# Sciences 15, no. 12 (December 20, 2011): 3751–65.
# https://doi.org/10.5194/hess-15-3751-2011.

using Hurst.Value
using DataFrames
using StatsPlots

# confusion matricies from table 3, Verkade 2011
perf = Dict()
perf[:lead_1] = confusion_scaled(10, 2, 0, 15860)
perf[:lead_2] = confusion_scaled(10, 4, 2, 15856)
perf[:lead_3] = confusion_scaled(6, 9, 2, 15855)
perf[:lead_4] = confusion_scaled(7, 7, 2, 15856)
perf[:lead_5] = confusion_scaled(8, 6, 2, 15856)
perf[:lead_6] = confusion_scaled(6, 9, 3, 15854)

# calculate the relative economic value over cost-loss ratios for each lead time
rev = DataFrame()
rev[:cl_ratio] = 0:0.01:1.0
for (lead_time, confusion_mtx) in perf
    rev[lead_time] = map(r -> cost_loss(r, 1, confusion_mtx), rev[:cl_ratio])
end

# sorted list of columns without the cost-loss ratios
col_names = sort(filter(n -> n != :cl_ratio, names(rev)))

# plot the rev curve for each forecast lead time
@df rev plot(:cl_ratio,
             cols(col_names),
             ylim = [-1,1],
             title = "Verkade 2011 - Figure 6",
             xlabel = "Cost-loss ratio",
             ylabel = "Relative economic value",
             legend = :bottomleft,
             size = (800, 600))

# Roulin and Verkade methods behave differently
quiets_range = 0:20

roulin = map(q -> cost_loss_roulin(0.5, 1.0, confusion_scaled(20, 0, 10, q)), quiets_range)
verkade = map(q -> cost_loss_verkade(0.5, 1.0, confusion_scaled(20, 0, 10, q)), quiets_range)

plot(quiets_range,
     [roulin, verkade],
     label = ["Roulin", "Verkade"],
     title = "Verkade and Roulin methods treat quiets differently",
     xlabel = "Number of quiets",
     ylabel = "Relative economic value",
     legend = :bottomright,
     size = (800, 600))
