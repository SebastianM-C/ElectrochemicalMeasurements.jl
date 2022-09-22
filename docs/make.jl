using ElectrochemicalMeasurements
using Documenter

DocMeta.setdocmeta!(ElectrochemicalMeasurements, :DocTestSetup, :(using ElectrochemicalMeasurements); recursive=true)

makedocs(;
    modules=[ElectrochemicalMeasurements],
    authors="Sebastian Micluța-Câmpeanu <m.c.sebastian95@gmail.com> and contributors",
    repo="https://github.com/SebastianM-C/ElectrochemicalMeasurements.jl/blob/{commit}{path}#{line}",
    sitename="ElectrochemicalMeasurements.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SebastianM-C.github.io/ElectrochemicalMeasurements.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SebastianM-C/ElectrochemicalMeasurements.jl",
    devbranch="master",
)
