using Test

include("../src/Hydro.jl")
using .Hydro

@testset "Rainfall funoff models" begin
    include("gr4j.jl")
end

@testset "Transformations" begin
    include("transformations.jl")
end
