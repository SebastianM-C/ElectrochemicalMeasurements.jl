struct EISMeasurement <: AbstractMeasurement
    dataset::DataSet
    global_procedure::Dict{String,Any}
end

EISMeasurement(project::MeasurementsProject, name) = EISMeasurement(project, dataset(project, name))

function EISMeasurement(project::MeasurementsProject, dataset::DataSet)
    proc = select_procedure(dataset, project.procedures)
    EISMeasurement(dataset, proc)
end

function take_subset(eis::EISMeasurement, df)
    freq = eis."freq"
    if haskey(procedure(eis)["preprocessing"], "max_freq")
        max_freq = procedure(eis)["preprocessing"]["max_freq"]
        idxs = findall(≤(max_freq), df[!, freq])
        df[idxs, :]
    else
        df
    end
end

@userplot struct Nyquist{T}
    args::T
end

@recipe function f(n::Nyquist{<:Tuple{<:EISMeasurement}})
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

@recipe function f(n::Nyquist{<:Tuple{Vector{<:EISMeasurement}}})
    uq_meta = find_unique_metadata(n.args[1])
    for eis in n.args[1]
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
            label --> unique_metadata_legend(eis, uq_meta)
            df[!, re_Z], df[!, im_Z]
        end
    end
end

@userplot struct Bode{T}
    args::T
end

@recipe function f(n::Bode{<:Tuple{<:EISMeasurement}})
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

@recipe function f(n::Bode{<:Tuple{Vector{<:EISMeasurement}}})
    uq_meta = find_unique_metadata(n.args[1])
    for eis in n.args[1]
        df = open(eis)
        ϕ = eis."phase"
        f = eis."freq"
        @series begin
            seriestype --> :scatter
            xlabel --> f
            ylabel --> ϕ
            xscale --> :log10
            label --> unique_metadata_legend(eis, uq_meta)
            df[!, f], df[!, ϕ]
        end
    end
end
