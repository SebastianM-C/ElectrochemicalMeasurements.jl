struct EISMeasurement <: AbstractMeasurement
    dataset::DataSet
    global_procedure::Dict{String,Any}
end

function EISMeasurement(project::MeasurementsProject, name)
    d = dataset(project, name)
    proc = select_procedure(d, project.procedures)
    EISMeasurement(d, proc)
end

@userplot struct Nyquist{T<:Tuple{<:EISMeasurement}}
    args::T
end

@recipe function f(n::Nyquist)
    eis = n.args[1]
    df = open(eis)
    re_Z = eis."Re_Z"
    im_Z = eis."Im_Z"
    Z_max = max(maximum(df[!, re_Z]), maximum(df[!, im_Z]))
    @series begin
        seriestype --> :scatter
        xlabel --> re_Z
        ylabel --> im_Z
        aspect_ratio := 1
        xlims --> (0, Z_max * 1.05)
        ylims --> (0, Z_max * 1.05)
        df[!, re_Z], df[!, im_Z]
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
