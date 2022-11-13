struct CVMeasurement <: AbstractMeasurement
    dataset::DataSet
    global_procedure::Dict{String,Any}
end

function CVMeasurement(project::MeasurementsProject, name)
    d = dataset(project, name)
    proc = select_procedure(d, project.procedures)
    CVMeasurement(d, proc)
end

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
