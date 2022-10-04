struct GCDMeasurement <: AbstractMeasurement
    dataset::DataSet
    global_procedure::Dict{String,Any}
end

function GCDMeasurement(project::MeasurementsProject, name)
    d = dataset(project, name)
    proc = select_procedure(d, project.procedures)
    GCDMeasurement(d, proc)
end

default_select(gcd::GCDMeasurement) = [gcd."potential", gcd."time"]

function take_subset(gcd::GCDMeasurement, df)
    V = gcd."potential"
    # make this opt-in
    idx = findfirst(<(0), df[!, V]) - 1
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
