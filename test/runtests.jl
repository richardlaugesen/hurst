using Test

include("../src/HydroJulia.jl")
using .HydroJulia

@testset "Transformations" begin
    include("transformations.jl")
end

@testset "Rainfall funoff models" begin
    include("rainfall_runoff_models.jl")
end
