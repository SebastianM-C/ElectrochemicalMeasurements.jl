module ElectrochemicalMeasurements

export EISMeasurement, Nyquist, Bode

using DataSets
using CSV, DataFrames
using RecipesBase

abstract type AbstractMeasurement end

procedure(dataset::DataSet) = dataset.conf["procedure"]
procedure(m::AbstractMeasurement) = procedure(m.dataset)

function Base.open(m::AbstractMeasurement, select=default_select(m))
    CSV.read(open(IO, m.dataset), DataFrame; select)
end

# Base.getproperty(m::AbstractMeasurement, name::Symbol) = getproperty(m, string(name))
Base.getproperty(m::AbstractMeasurement, name::String) = procedure(m)[name]

include("eis.jl")
include("gcd.jl")

end
