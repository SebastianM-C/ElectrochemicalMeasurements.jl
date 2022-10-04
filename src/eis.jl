struct EISMeasurement{D} <: AbstractMeasurement
    dataset::D
end

function default_select(eis::EISMeasurement)
    [eis."Z1_name", eis."Z2_name", eis."phase", eis."freq"]
end

@userplot struct Nyquist{T<:Tuple{<:EISMeasurement}}
    args::T
end

@recipe function f(n::Nyquist)
    eis = n.args[1]
    df = open(eis)
    z1 = eis."Z1_name"
    z2 = eis."Z2_name"
    Z_max = max(maximum(df[!, z1]), maximum(df[!, z2]))
    @series begin
        seriestype --> :scatter
        xlabel --> z1
        ylabel --> z2
        aspect_ratio := 1
        xlims --> (0, Z_max*1.05)
        ylims --> (0, Z_max*1.05)
        df[!, z1], df[!, z2]
    end
end

@userplot struct Bode{T<:Tuple{<:EISMeasurement}}
    args::T
end

@recipe function f(n::Bode)
    eis = n.args[1]
    df = open(eis)
    ϕ = eis."phase"
    f = eis."freq"
    @series begin
        seriestype --> :scatter
        xlabel --> f
        ylabel --> ϕ
        xscale --> :log10
        df[!, f], df[!, ϕ]
    end
end
