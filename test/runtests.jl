module TestHydro
@time include("transforms.jl")
@time include("verification.jl")
@time include("gr4j.jl")
@time include("gr4j_benchmark.jl")
end
