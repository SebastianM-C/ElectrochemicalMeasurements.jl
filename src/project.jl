struct MeasurementsProject{D} <: DataSets.AbstractDataProject
    data_project::D
    procedures::Vector{Any}
end

function load_project(path::AbstractString)
    sys_path = abspath(path)
    content = read(sys_path, String)
    sys_data_dir = dirname(sys_path)

    toml_str = DataSets._fill_template(sys_data_dir, content)
    config = TOML.parse(toml_str)

    data_project = DataSets.load_project(config)
    procedures = config["procedures"]

    MeasurementsProject(data_project, procedures)
end

function DataSets.dataset(project::MeasurementsProject, name::AbstractString)
    dataset(project.data_project, name)
end

DataSets.project_name(p::MeasurementsProject) = DataSets.project_name(p.data_project)

Base.iterate(p::MeasurementsProject, st=nothing) = iterate(p.data_project, st)
Base.keys(p::MeasurementsProject) = keys(p.data_project)

function Base.get(p::MeasurementsProject, name::AbstractString, default)
    get(p.data_project, name, default)
end

function merge_global_metadata!(dataset, procedure)
    if haskey(procedure, "metadata")
        global_metadata = procedure["metadata"]
        local_metadata = metadata(dataset)
        for (k, v) in global_metadata
            if !haskey(local_metadata, k)
                push!(local_metadata, k => v)
            end
        end
    end
end
