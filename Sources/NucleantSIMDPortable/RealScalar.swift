// The C math library, for what the standard library doesn't have (sin, exp,
// ...). Only this file imports it: `Foundation` alone has no `Float`
// overloads on every platform (Android has just the `Double` ones there).
#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(Android)
import Android
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(CRT)
import CRT
#elseif canImport(Darwin)
import Darwin
#endif

/// `Float` and `Double`: the scalars the floating-point simd API is written
/// for, with the C math functions it needs.
@usableFromInline
protocol RealScalar: BinaryFloatingPoint, SIMDScalar, Codable, Sendable {
    static func libmAcos(_ x: Self) -> Self
    static func libmAcosh(_ x: Self) -> Self
    static func libmAsin(_ x: Self) -> Self
    static func libmAsinh(_ x: Self) -> Self
    static func libmAtan(_ x: Self) -> Self
    static func libmAtan2(_ y: Self, _ x: Self) -> Self
    static func libmAtanh(_ x: Self) -> Self
    static func libmCbrt(_ x: Self) -> Self
    static func libmCos(_ x: Self) -> Self
    static func libmCosh(_ x: Self) -> Self
    static func libmErf(_ x: Self) -> Self
    static func libmErfc(_ x: Self) -> Self
    static func libmExp(_ x: Self) -> Self
    static func libmExp2(_ x: Self) -> Self
    static func libmExpm1(_ x: Self) -> Self
    static func libmFmod(_ x: Self, _ y: Self) -> Self
    static func libmHypot(_ x: Self, _ y: Self) -> Self
    static func libmLgamma(_ x: Self) -> Self
    static func libmLog(_ x: Self) -> Self
    static func libmLog10(_ x: Self) -> Self
    static func libmLog1p(_ x: Self) -> Self
    static func libmLog2(_ x: Self) -> Self
    static func libmNextafter(_ x: Self, _ y: Self) -> Self
    static func libmPow(_ x: Self, _ y: Self) -> Self
    static func libmRemainder(_ x: Self, _ y: Self) -> Self
    static func libmSin(_ x: Self) -> Self
    static func libmSinh(_ x: Self) -> Self
    static func libmTan(_ x: Self) -> Self
    static func libmTanh(_ x: Self) -> Self
    static func libmTgamma(_ x: Self) -> Self
}

extension Float: RealScalar {
    @inlinable static func libmAcos(_ x: Float) -> Float { acosf(x) }
    @inlinable static func libmAcosh(_ x: Float) -> Float { acoshf(x) }
    @inlinable static func libmAsin(_ x: Float) -> Float { asinf(x) }
    @inlinable static func libmAsinh(_ x: Float) -> Float { asinhf(x) }
    @inlinable static func libmAtan(_ x: Float) -> Float { atanf(x) }
    @inlinable static func libmAtan2(_ y: Float, _ x: Float) -> Float { atan2f(y, x) }
    @inlinable static func libmAtanh(_ x: Float) -> Float { atanhf(x) }
    @inlinable static func libmCbrt(_ x: Float) -> Float { cbrtf(x) }
    @inlinable static func libmCos(_ x: Float) -> Float { cosf(x) }
    @inlinable static func libmCosh(_ x: Float) -> Float { coshf(x) }
    @inlinable static func libmErf(_ x: Float) -> Float { erff(x) }
    @inlinable static func libmErfc(_ x: Float) -> Float { erfcf(x) }
    @inlinable static func libmExp(_ x: Float) -> Float { expf(x) }
    @inlinable static func libmExp2(_ x: Float) -> Float { exp2f(x) }
    @inlinable static func libmExpm1(_ x: Float) -> Float { expm1f(x) }
    @inlinable static func libmFmod(_ x: Float, _ y: Float) -> Float { x.truncatingRemainder(dividingBy: y) }
    @inlinable static func libmHypot(_ x: Float, _ y: Float) -> Float { hypotf(x, y) }
    @inlinable static func libmLgamma(_ x: Float) -> Float { lgammaf(x) }
    @inlinable static func libmLog(_ x: Float) -> Float { logf(x) }
    @inlinable static func libmLog10(_ x: Float) -> Float { log10f(x) }
    @inlinable static func libmLog1p(_ x: Float) -> Float { log1pf(x) }
    @inlinable static func libmLog2(_ x: Float) -> Float { log2f(x) }
    @inlinable static func libmNextafter(_ x: Float, _ y: Float) -> Float { nextafterf(x, y) }
    @inlinable static func libmPow(_ x: Float, _ y: Float) -> Float { powf(x, y) }
    @inlinable static func libmRemainder(_ x: Float, _ y: Float) -> Float { x.remainder(dividingBy: y) }
    @inlinable static func libmSin(_ x: Float) -> Float { sinf(x) }
    @inlinable static func libmSinh(_ x: Float) -> Float { sinhf(x) }
    @inlinable static func libmTan(_ x: Float) -> Float { tanf(x) }
    @inlinable static func libmTanh(_ x: Float) -> Float { tanhf(x) }
    @inlinable static func libmTgamma(_ x: Float) -> Float { tgammaf(x) }
}

extension Double: RealScalar {
    @inlinable static func libmAcos(_ x: Double) -> Double { acos(x) }
    @inlinable static func libmAcosh(_ x: Double) -> Double { acosh(x) }
    @inlinable static func libmAsin(_ x: Double) -> Double { asin(x) }
    @inlinable static func libmAsinh(_ x: Double) -> Double { asinh(x) }
    @inlinable static func libmAtan(_ x: Double) -> Double { atan(x) }
    @inlinable static func libmAtan2(_ y: Double, _ x: Double) -> Double { atan2(y, x) }
    @inlinable static func libmAtanh(_ x: Double) -> Double { atanh(x) }
    @inlinable static func libmCbrt(_ x: Double) -> Double { cbrt(x) }
    @inlinable static func libmCos(_ x: Double) -> Double { cos(x) }
    @inlinable static func libmCosh(_ x: Double) -> Double { cosh(x) }
    @inlinable static func libmErf(_ x: Double) -> Double { erf(x) }
    @inlinable static func libmErfc(_ x: Double) -> Double { erfc(x) }
    @inlinable static func libmExp(_ x: Double) -> Double { exp(x) }
    @inlinable static func libmExp2(_ x: Double) -> Double { exp2(x) }
    @inlinable static func libmExpm1(_ x: Double) -> Double { expm1(x) }
    @inlinable static func libmFmod(_ x: Double, _ y: Double) -> Double { x.truncatingRemainder(dividingBy: y) }
    @inlinable static func libmHypot(_ x: Double, _ y: Double) -> Double { hypot(x, y) }
    @inlinable static func libmLgamma(_ x: Double) -> Double { lgamma(x) }
    @inlinable static func libmLog(_ x: Double) -> Double { log(x) }
    @inlinable static func libmLog10(_ x: Double) -> Double { log10(x) }
    @inlinable static func libmLog1p(_ x: Double) -> Double { log1p(x) }
    @inlinable static func libmLog2(_ x: Double) -> Double { log2(x) }
    @inlinable static func libmNextafter(_ x: Double, _ y: Double) -> Double { nextafter(x, y) }
    @inlinable static func libmPow(_ x: Double, _ y: Double) -> Double { pow(x, y) }
    @inlinable static func libmRemainder(_ x: Double, _ y: Double) -> Double { x.remainder(dividingBy: y) }
    @inlinable static func libmSin(_ x: Double) -> Double { sin(x) }
    @inlinable static func libmSinh(_ x: Double) -> Double { sinh(x) }
    @inlinable static func libmTan(_ x: Double) -> Double { tan(x) }
    @inlinable static func libmTanh(_ x: Double) -> Double { tanh(x) }
    @inlinable static func libmTgamma(_ x: Double) -> Double { tgamma(x) }
}
