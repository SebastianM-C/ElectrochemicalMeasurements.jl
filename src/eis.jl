struct EISMeasurement{D} <: AbstractMeasurement
    dataset::D
end

function default_select(eis::EISMeasurement)
    [eis.Z1_name, eis.Z2_name, eis.phase, eis.freq]
end

@userplot struct Nyquist{T<:Tuple{<:EISMeasurement}}
    args::T
end

@recipe function f(n::Nyquist)
    eis = n.args[1]
    df = open(eis)
    z1 = eis.Z1_name
    z2 = eis.Z2_name
    @series begin
        xlabel --> z1
        ylabel --> z2
        df[!, z1], df[!, z2]
    end
end

@userplot struct Bode{T<:Tuple{<:EISMeasurement}}
    args::T
end

@recipe function f(n::Bode)
    eis = n.args[1]
    df = open(eis)
    ϕ = eis.phase
    f = eis.freq
    @series begin
        xlabel --> ϕ
        ylabel --> f
        df[!, ϕ], df[!, f]
    end
end
