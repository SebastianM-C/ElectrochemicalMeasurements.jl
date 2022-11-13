function capacitance(cv::CVMeasurement, quadrant)
    scan_rate = unitful_metadata(cv, "scan_rate")
    Δt, ΔV, ∫IdV = discharge_area(cv, quadrant)

    C = ∫IdV / (ΔV * scan_rate)
    return (C=C, Δt = Δt, ΔV=ΔV)
end

function capacitance(gcd::GCDMeasurement)
    df = open(gcd)
    fixed_ΔV = unitful_analysis(gcd, "fixed_ΔV")
    I = unitful_metadata(gcd, "charging_current")
    df = open(gcd)
    t, V = df[!, gcd."time"], df[!, gcd."potential"]
    idxs = findall(v -> v > 0, V)
    t, V = t[idxs], V[idxs]

    ∫Vdt = integrate(t, V) * u"V*s"
    Δt = (t[end] - t[begin]) * u"s"
    ΔV = !isnothing(fixed_ΔV) ? fixed_ΔV : -(reverse(extrema(V))...) * u"V"

    return (C = 2 * I * ∫Vdt / ΔV^2, Δt = Δt, ΔV = ΔV)
end

function energy(C, ΔV)
    return (C*ΔV^2)/2
end

power(E, Δt) = E / Δt
