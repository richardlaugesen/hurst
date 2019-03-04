push!(LOAD_PATH,"../src/")

using Documenter
using Hydro

makedocs(sitename="Hydro.jl")

deploydocs(
    repo = "github.com/tinyrock/hydro.jl.git",
)
