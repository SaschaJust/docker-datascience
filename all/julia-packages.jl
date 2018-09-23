using Pkg

printstyled("Updating metadata:\n", color=:cyan)
Pkg.update()

# Pkg.add(PackageSpec(url="https://github.com/SaschaJust/LibCURL.jl.git", version="0.2.3"))

printstyled("Running build scripts:\n", color=:cyan)
Pkg.build()

# "PlotlyJS" is currently broken for all julia versions
packages = (
    "IJulia",
    "PyPlot",
    "GR",
    "Plots",
    "StatPlots",
    "IterTools",
    "DataFrames",
    "HDF5",
    "PyCall",
    "RDatasets",
    "DataFrames",
    "ScikitLearn",
    "Gadfly",
    "LibPQ",
    "Makie"
)

for p = packages
    printstyled("Installing $p:\n", color=:cyan)
    Pkg.add(p)
end

function recompile_packages()
    for pkg in keys(Pkg.installed())
        try
            @info("Compiling: $pkg")
            eval(Expr(:toplevel, Expr(:using, Symbol(pkg))))
        catch err
            @warn("Unable to precompile: $pkg")
            @warn(err)
        end
    end
end

printstyled("Precompiling:\n", color=:cyan)
recompile_packages()
printstyled("Done.\n", color=:green)
