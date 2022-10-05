function capacitance(cv::CVMeasurement, quadrant)
    scan_rate = unitful_metadata(cv, "scan_rate")
    Δt, ΔV, ∫IdV = discharge_area(cv, quadrant)

    C = ∫IdV / (ΔV * scan_rate)
    return (C=C, Δt = Δt, ΔV=ΔV)
end

function energy(C, ΔV)
    return (C*ΔV^2)/2
end

power(E, Δt) = E / Δt
