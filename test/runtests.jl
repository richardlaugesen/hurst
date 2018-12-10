using Test

include("../src/HydroJulia.jl")
using .HydroJulia

@testset "Rainfall funoff models" begin
    include("gr4j.jl")
end

@testset "Transformations" begin
    include("transformations.jl")
end
