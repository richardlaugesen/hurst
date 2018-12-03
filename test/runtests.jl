using Test

include("../src/HydroJulia.jl")
using .HydroJulia

@testset "Rainfall funoff models" begin
    include("rainfall_runoff_models.jl")
end

@testset "Transformations" begin
    include("transformations.jl")
end
