struct GCDMeasurement{D} <: AbstractMeasurement
    dataset::D
end

default_select(gcd::GCDMeasurement) = [gcd."potential", gcd."time"]

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
