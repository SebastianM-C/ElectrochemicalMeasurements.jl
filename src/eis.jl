struct EISMeasurement{D}
    dataset::D
end

metadata(dataset::DataSet) = dataset.conf["metadata"]
metadata(eis::EISMeasurement) = metadata(eis.dataset)

function default_select(eis::EISMeasurement)
    m = metadata(eis)

    return [m["Z1_name"], m["Z2_name"], m["phase"], m["freq"]]
end

function Base.open(eis::EISMeasurement, select=default_select(eis))
    CSV.read(open(IO, eis.dataset), DataFrame; select)
end

@userplot struct Nyquist{T<:Tuple{<:EISMeasurement}}
    args::T
end

@recipe function f(n::Nyquist)
    eis = n.args[1]
    df = open(eis)
    z1 = metadata(eis)["Z1_name"]
    z2 = metadata(eis)["Z2_name"]
    @series begin
        df[!, z1], df[!, z2]
    end
end

@userplot struct Bode{T<:Tuple{<:EISMeasurement}}
    args::T
end

@recipe function f(n::Bode)
    eis = n.args[1]
    df = open(eis)
    z1 = metadata(eis)["phase"]
    z2 = metadata(eis)["freq"]
    @series begin
        df[!, z1], df[!, z2]
    end
end
