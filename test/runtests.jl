using Test

include("../src/HydroJulia.jl")
using .HydroJulia

@testset "Transformations" begin
    include("transformations.jl")
end
