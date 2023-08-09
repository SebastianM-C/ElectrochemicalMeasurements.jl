struct GCDMeasurement <: AbstractMeasurement
    dataset::DataSet
    global_procedure::Dict{String,Any}
end

GCDMeasurement(project::MeasurementsProject, name) = GCDMeasurement(project, dataset(project, name))

function GCDMeasurement(project::MeasurementsProject, dataset::DataSet)
    proc = select_procedure(dataset, project.procedures)
    GCDMeasurement(dataset, proc)
end

dataset_procedure(::Type{GCDMeasurement}) = Dict(
    Dict(
        "name" => "GCD",
        "columns" => Dict(
            "potential" => "WE(1).Potential (V)",
            "time" => "Corrected time (s)"
        )
    )
)

default_select(gcd::GCDMeasurement) = [gcd."potential", gcd."time"]

function take_subset(gcd::GCDMeasurement, df)
    V = gcd."potential"
    # make this opt-in
    cycle_type = metadata(gcd)["cycle_type"]
    if cycle_type == "positive"
        idx = findfirst(<(0), df[!, V]) - 1
    else
        idx = findfirst(>(0), df[!, V]) - 1
    end
    df[1:idx, :]
end

@recipe function f(gcd::GCDMeasurement)
    df = open(gcd)
    V = gcd."potential"
    t = gcd."time"

    @series begin
        xlabel --> t
        ylabel --> V
        df[!, t], df[!, V]
    end
end

@recipe function f(gcds::Vector{<:GCDMeasurement})
    uq_meta = find_unique_metadata(gcds)
    for gcd in gcds
        @series begin
            label --> unique_metadata_legend(gcd, uq_meta)
            gcd
        end
    end
end
