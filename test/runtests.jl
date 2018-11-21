using Test

include("../src/HydroJulia.jl")
using .HydroJulia

@testset "Verification" begin
    include("verification.jl")
end
