// Comparisons with a tolerance, written only with API both sides of
// NucleantSIMD have: they run against Apple's simd on Apple platforms and
// against NucleantSIMDPortable everywhere else.

import NucleantSIMD

func isClose(_ a: Float, _ b: Float, _ tolerance: Float = 1e-5) -> Bool {
    Swift.abs(a - b) <= tolerance
}

func isClose(_ a: Double, _ b: Double, _ tolerance: Double = 1e-12) -> Bool {
    Swift.abs(a - b) <= tolerance
}

func isClose<V: SIMD>(_ a: V, _ b: V, _ tolerance: Float = 1e-5) -> Bool where V.Scalar == Float {
    let difference = a - b
    return difference.replacing(with: -difference, where: difference .< 0).max() <= tolerance
}

func isClose<V: SIMD>(_ a: V, _ b: V, _ tolerance: Double = 1e-12) -> Bool where V.Scalar == Double {
    let difference = a - b
    return difference.replacing(with: -difference, where: difference .< 0).max() <= tolerance
}

/// The same rotation: `q` and `-q` turn every vector the same way.
func isSameRotation(_ a: simd_quatf, _ b: simd_quatf, _ tolerance: Float = 1e-5) -> Bool {
    isClose(a.vector, b.vector, tolerance) || isClose(a.vector, -b.vector, tolerance)
}
