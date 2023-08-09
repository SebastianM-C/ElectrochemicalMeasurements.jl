const AVAILABLE_PROCEDURES = ["CV", "EIS", "GCD"]
const AVAILABLE_MEASUREMENT_TYPES = [CVMeasurement, EISMeasurement, GCDMeasurement]

function build_dataset(path::AbstractString=pwd())
    files = readdir(path, join=true)
    selected = quickmulti(files, message="Select files of folders to use:")
    if isempty(selected)
        @warn "Nothing selected, nothing to do."
        return nothing
    end

    selected_files = filter(isfile, selected)
    selected_folders = filter(isdir, selected)
    @debug "Selected files: $(join(selected_files, ' '))"
    @debug "Selected folders: $(join(selected_folders, ' '))"
    available_metadata = Dict()
    datasets = []
    for folder in selected_folders
        explore_folder!(datasets, folder, available_metadata)
    end
    process_files!(datasets, selected_files, ".", available_metadata)
    toml = Dict(
        "data_config_version" => 1,
        "procedures" => [dataset_procedure(m) for m in AVAILABLE_MEASUREMENT_TYPES],
        "datasets" => datasets
    )
    open(joinpath(path, "Data.toml"), "w") do io
        TOML.print(io, toml)
    end
end

function explore_folder!(datasets, path, available_metadata)
    val_map = Dict()
    procedure_map = Dict()
    file_keys = []
    file_idxs = []
    for (root, dir, files) in walkdir(path)
        @debug "Exploring $root"
        if isempty([startswith(root, p) for p in keys(procedure_map)])
            path_meta = quickmenu(["yes", "no"], message="Is there common procedure for all files in $root?")
            if path_meta == "yes"
                procedure = quickmenu(AVAILABLE_PROCEDURES, message="Choose the common procedure for the files in $root?")
                push!(procedure_map, root => procedure)
            else
                procedure = nothing
            end
        else
            for p in keys(procedure_map)
                if startswith(root, p)
                    procedure = procedure_map[p]
                    break
                else
                    @warn "procedure not found for $root"
                    procedure = nothing
                end
            end
        end
        process_files!(datasets, files, root, available_metadata, procedure, val_map, file_keys, file_idxs)
    end
end

function process_files!(datasets, files, root, available_metadata, procedure, val_map=Dict(), file_keys = [], idxs = [])
    if isempty(files)
        return
    else
        file_metadata = Dict()

        add_common_metadata!(file_metadata, available_metadata, root)
        # try to use filenames
        split_fns = split.(files, ('_',))
        # Main.split_fns = split_fns
        if allequal(length.(split_fns)) && !isnothing(procedure)
            @info "We can add metadata based on filenames"
            if !isempty(file_keys)
                reuse_file_keys = quickmenu(["yes", "no"], message="Reuse $file_keys?")
                if reuse_file_keys == "no"
                    empty!(file_keys)
                    empty!(idxs)
                end
            end

            if isempty(file_keys)
                metadata_elements = quickmulti(split_fns[1], message="Choose relevant elements")
                append!(idxs, map(m->findfirst(==(m), split_fns[1]), metadata_elements))
                @debug "relevant idxs: $idxs"
                # file_keys = []
                for i in idxs
                    k = Base.prompt("metadata key name at index $i (i.e. what corresponds to $(split_fns[1][i]) in the first file)")
                    push!(file_keys, k)
                end
            end

            add_valmap = quickmenu(["yes", "no"], message="Map values?")
            if add_valmap == "yes"
                if !isempty(val_map)
                    pretty_table(val_map)
                    reuse_valmap = quickmenu(["yes", "no"], message="Reuse the above?")
                    if reuse_valmap == "no"
                        empty!(val_map)
                    end
                end
                add_vals = quickmenu(["yes", "no"], message="Add values to maping?")
                if add_vals == "yes"
                    vals = quickmulti(unique(vcat(split_fns...)), message="Pick vals to map")
                    for v in vals
                        push!(val_map, v => Base.prompt("Value for $v"))
                    end
                end
            end
            ok = "no"
            for (i, fn) in enumerate(split_fns)
                if ok != "yes to all"
                    ok = "no"
                end
                metadata = copy(file_metadata)
                # @debug metadata
                for (i, k) in enumerate(file_keys)
                    fnval = fn[idxs[i]]
                    if haskey(val_map, fnval)
                        v = val_map[fnval]
                    else
                        v = fnval
                    end
                    # @debug "Adding $k=>$v"
                    push!(metadata, k=>v)
                end
                file = files[i]
                file_description = dataset_for_file(file, root, procedure, metadata)
                toml_description = Dict("datasets" => [file_description])
                TOML.print(toml_description)

                if ok == "yes to all"
                    push!(datasets, file_description)
                else
                    ok = quickmenu(["yes", "no", "yes to all"], message="Is the above corect?")
                    if ok == "yes" || ok == "yes to all"
                        push!(datasets, file_description)
                    else
                        d = dataset_from_file(file, root, available_metadata, procedure, copy(file_metadata))
                        push!(datasets, d)
                    end
                end
            end
        else
            for file in files
                f = quickmenu(["yes", "no"], message="Continue with $(joinpath(root, file))?")
                if f == "no"
                    continue
                else
                    d = dataset_from_file(file, root, available_metadata, procedure, copy(file_metadata))
                    push!(datasets, d)
                end
            end
        end
    end
end

function add_common_metadata!(file_metadata, available_metadata, root)
    path_metadata = splitpath(root)
    add_metadata = "yes"
    while add_metadata != "no"
        metadata_msg = "Add metadata for all files in $(basename(root))?"
        add_metadata = quickmenu(["yes", "no"], message=metadata_msg)
        if add_metadata == "no"
            break
        end
        metadata_key = quickmenu([collect(keys(available_metadata)); "[add new]"], message="Choose metadata key")
        if metadata_key == "[add new]"
            metadata_key = Base.prompt("New metadata key")
        end
        metadata_val = quickmenu([path_metadata; "[add new]"], message="Choose metadata value")
        if metadata_val == "[add new]"
            metadata_val = Base.prompt("New metadata value")
        end
        metadata_entry = metadata_key => metadata_val
        push!(file_metadata, metadata_entry)
        push!(available_metadata, metadata_entry)
    end
end

function add_filename_metadata!(file_metadata, available_metadata, root, files)
    split_fns = split.(files)
    add_metadata = "yes"
    while add_metadata != "no"
        metadata_msg = "Add file name based metadata for all files in $(basename(root))?"
        add_metadata = quickmenu(["yes", "no"], message=metadata_msg)
        if add_metadata == "no"
            break
        end
        metadata_key = quickmenu([collect(values(available_metadata)); "[add new]"], message="Choose metadata key")
        if metadata_key == "[add new]"
            metadata_key = Base.prompt("New metadata key")
        end
        metadata_val = quickmenu([path_metadata; "[add new]"], message="Choose metadata value")
        if metadata_val == "[add new]"
            metadata_val = Base.prompt("New metadata value")
        end
        metadata_entry = metadata_key => metadata_val
        push!(file_metadata, metadata_entry)
        push!(available_metadata, metadata_entry)
    end
end

function dataset_from_file(file, root, available_metadata, procedure = nothing, file_metadata = Dict())
    header = "Create description for $(joinpath(root, file))"
    select_procedure = "Select procedure for $file"
    if isnothing(procedure)
        procedure = quickmenu(AVAILABLE_PROCEDURES, message=header * '\n' * select_procedure)
    end
    if !isempty(file_metadata)
        pretty_table(file_metadata, title="Metadata for $(joinpath(root, file))")
    end
    add_metadata = "yes"
    while add_metadata != "no"
        metadata_msg = "Add metadata for $file?"
        add_metadata = quickmenu(["yes", "no"], message=metadata_msg)
        if add_metadata == "no"
            break
        end

        metadata_key = quickmenu([collect(keys(available_metadata)); "[add new]"], message="Choose metadata key")
        if metadata_key == "[add new]"
            metadata_key = Base.prompt("New metadata key")
        end
        path_metadata = split(file, '_')
        suggestion = unique([path_metadata; collect(values(available_metadata))])
        metadata_val = quickmenu([suggestion; "[add new]"], message="Choose metadata value")
        if metadata_val == "[add new]"
            metadata_val = Base.prompt("New metadata value")
        end
        metadata_entry = metadata_key => metadata_val

        push!(file_metadata, metadata_entry)
        push!(available_metadata, metadata_entry)
        pretty_table(file_metadata, title="Metadata for $(joinpath(root, file))")
    end
    file_description = dataset_for_file(file, root, procedure, file_metadata)
    toml_description = Dict("datasets" => [file_description])
    TOML.print(toml_description)

    return file_description
end

function normalized_dataset_name(root, file)
    proposal = join(splitpath(joinpath(root, file)), '_')
    if isletter(first(proposal))
        name = proposal
    else
        name = "d"*proposal
    end

    idxs = findall(x->!(isletter(x) || isnumeric(x) || x ∈ ['-', '_', '/']), name)
    if !isnothing(idxs)
        to_replace = Dict(unique(name[idxs]) .=> "")
        for r in to_replace
            name = replace(name, r)
        end
    end

    return name
end

function dataset_for_file(file, root, procedure, file_metadata)
    Dict(
        "name" => normalized_dataset_name(root, file),
        "description" => "$procedure data",
        "uuid" => string(uuid4()),
        "storage" => Dict(
            "driver" => "FileSystem",
            "type" => "Blob",
            "path" => join(["@__DIR__"; splitpath(joinpath(root, file))], '/')
        ),
        "metadata" => file_metadata,
        "procedure" => Dict(
            "name" => procedure
        )
    )
end
