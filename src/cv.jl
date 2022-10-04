struct CVMeasurement{D} <: AbstractMeasurement
    dataset::D
end

default_select(cv::CVMeasurement) = [cv."current", cv."potential", cv."scan"]

function take_subset(cv::CVMeasurement, df)
    fd = df[df[!, cv."scan"] .== cv."select_scan", :]
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
