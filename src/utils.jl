function find_unique_metadata(ms::Vector{<:AbstractMeasurement})
    metadata_vals = values.(metadata.(ms))
    m1, rest = Iterators.peel(metadata_vals)
    keep_filter = falses(length(m1))
    for (i,v) in enumerate(m1)
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
