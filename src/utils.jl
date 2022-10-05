function find_unique_metadata(ms::Vector{<:AbstractMeasurement})
    metadata_vals = values.(metadata.(ms))
    m1, rest = Iterators.peel(metadata_vals)
    keep_filter = falses(length(m1))
    for (i, v) in enumerate(m1)
        for metadata_row in rest
            if v ∉ metadata_row
                keep_filter[i] = true
            end
        end
    end
    collect(keys(metadata(ms[1])))[keep_filter]
end

function unique_metadata_legend(m::AbstractMeasurement, uq)
    join(get.((metadata(m),), uq, ""), " ")
end

procedure(dataset::DataSet) = dataset.conf["procedure"]
procedure(p::Pair{String,DataSet}) = procedure(last(p))

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
metadata(p::Pair{String,DataSet}) = metadata(last(p))
