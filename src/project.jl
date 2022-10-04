struct MeasurementsProject{D,P} <: DataSets.AbstractDataProject
    data_project::D
    procedures::P
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

Base.pairs(p::MeasurementsProject) = pairs(p.data_project)

procedure(dataset::DataSet) = dataset.conf["procedure"]

function procedure(m::AbstractMeasurement)
    global_procedure = m.global_procedure
    dataset_procedure = procedure(m.dataset)

    default = copy(global_procedure)
    if !all(keys(dataset_procedure) .== "name")
        for key in keys(dataset_procedure)
            default[key] = dataset_procedure[key]
        end
    end

    return default
end

function select_procedure(dataset, procedures)
    dataset_proc = procedure(dataset)
    proc_name = dataset_proc["name"]
    only(filter(p -> p["name"] == proc_name, procedures))
end

metadata(m::AbstractMeasurement) = metadata(m.dataset)
metadata(dataset::DataSet) = dataset.conf["metadata"]