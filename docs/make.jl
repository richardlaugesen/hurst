push!(LOAD_PATH,"../src/")

using Documenter
using Hurst

makedocs(sitename="Hurst")

deploydocs(
    repo = "github.com/tinyrock/hurst.git",
)
