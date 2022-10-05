function Base.filter(f, project::MeasurementsProject)
    filter(f, project.data_project.datasets)
end

function select_measurement(type_map::Pair{String,DataType}, project::MeasurementsProject, meta_filter=m->true)
    datasets = filter(d->procedure(d)["name"]==type_map[1] && meta_filter(metadata(d)), project)
    map(d->type_map[2](project, d), collect(keys(datasets)))
end
