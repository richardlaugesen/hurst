using Hurst
using Hurst.Transformations

y = rand(100)

for λ in -10:0.5:10
        sum_trans = sum(boxcox_inverse(boxcox(y, λ), λ))
        sum_y = sum(y)
        diff = sum_trans - sum_y
        println("$λ $sum_trans $sum_y $diff")
end
