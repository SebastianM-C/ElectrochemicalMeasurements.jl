module ElectrochemicalMeasurements

export EISMeasurement, Nyquist, Bode

using DataSets
using CSV, DataFrames
using RecipesBase

abstract type AbstractMeasurement end

metadata(dataset::DataSet) = dataset.conf["metadata"]
metadata(m::AbstractMeasurement) = metadata(m.dataset)

function Base.open(m::AbstractMeasurement, select=default_select(m))
    CSV.read(open(IO, m.dataset), DataFrame; select)
end

Base.getproperty(m::AbstractMeasurement, name) = metadata(m)[string(name)]

include("eis.jl")
include("gcd.jl")

end
