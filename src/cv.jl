struct CVMeasurement{D} <: AbstractMeasurement
    dataset::D
end

default_select(cv::CVMeasurement) = [cv."current", cv."potential"]

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
