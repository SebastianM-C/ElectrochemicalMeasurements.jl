struct CVMeasurement <: AbstractMeasurement
    dataset::DataSet
    global_procedure::Dict{String,Any}
end

CVMeasurement(project::MeasurementsProject, name) = CVMeasurement(project, dataset(project, name))

function CVMeasurement(project::MeasurementsProject, dataset::DataSet)
    proc = select_procedure(dataset, project.procedures)
    merge_global_metadata!(dataset, proc)
    CVMeasurement(dataset, proc)
end

dataset_procedure(::Type{CVMeasurement}) = Dict(
    Dict(
        "name" => "CV",
        "columns" => Dict(
            "current" => "WE(1).Current (A)",
            "potential" => "WE(1).Potential (V)",
            "time" => "Time (s)",
            "scan" => "Scan"
        ),
        "preprocessing" => Dict(
            "select_scan" => 2
        ),
        "analysis" => Dict(
            "quadrant" => [2, 4],
            "fixed_ΔV" => "0.9 V"
        )
    )
)

function take_subset(cv::CVMeasurement, df)
    select_scan = procedure(cv)["preprocessing"]["select_scan"]
    fd = df[df[!, cv."scan"].==select_scan, :]
    push!(fd, fd[1, :])
end

@recipe function f(cv::CVMeasurement)
    df = open(cv)
    V = cv."potential"
    I = cv."current"
    @series begin
        xlabel --> V
        ylabel --> I
        df[!, V], df[!, I]
    end
end

@recipe function f(cvs::Vector{<:CVMeasurement})
    uq_meta = find_unique_metadata(cvs)
    for cv in cvs
        @series begin
            label --> unique_metadata_legend(cv, uq_meta)
            cv
        end
    end
end
