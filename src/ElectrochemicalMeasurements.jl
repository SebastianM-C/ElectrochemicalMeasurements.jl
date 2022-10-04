module ElectrochemicalMeasurements

export EISMeasurement, Nyquist, Bode, GCDMeasurement, CVMeasurement

using DataSets
using CSV, DataFrames
using RecipesBase

abstract type AbstractMeasurement end

procedure(dataset::DataSet) = dataset.conf["procedure"]
procedure(m::AbstractMeasurement) = procedure(m.dataset)

function Base.open(m::AbstractMeasurement, select=default_select(m), subset=take_subset)
    df = CSV.read(open(IO, m.dataset), DataFrame; select)
    subset(m, df)
end

take_subset(::AbstractMeasurement, df) = df
# Base.getproperty(m::AbstractMeasurement, name::Symbol) = getproperty(m, string(name))
Base.getproperty(m::AbstractMeasurement, name::String) = procedure(m)[name]

include("eis.jl")
include("gcd.jl")
include("cv.jl")

end
