module ElectrochemicalMeasurements

export MeasurementsProject, EISMeasurement, Nyquist, Bode, GCDMeasurement, CVMeasurement,
    load_project, metadata, procedure, analysis, unitful_metadata, unitful_analysis,
    select_measurement,
    capacitance, power, energy

using DataSets
using CSV, DataFrames
using NumericalIntegration
using RecipesBase
using Unitful
using OffsetArrays
using TOML

abstract type AbstractMeasurement end

function Base.open(m::AbstractMeasurement, select=default_select(m), subset=take_subset)
    df = CSV.read(open(IO, m.dataset), DataFrame; select)
    subset(m, df)
end

function default_select(m::AbstractMeasurement)
    cols = procedure(m)["columns"]
    map(identity, values(cols))
end

take_subset(::AbstractMeasurement, df) = df

Base.getproperty(m::AbstractMeasurement, name::String) = procedure(m)["columns"][name]

include("project.jl")
include("eis.jl")
include("gcd.jl")
include("cv.jl")
include("filter.jl")
include("utils.jl")
include("analysis/cv_area.jl")
include("analysis/capacitance.jl")

end
