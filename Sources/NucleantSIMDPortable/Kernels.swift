// What the public overloads (Generated/) run, written once for every vector
// type. All of it is inlined and specialized into the caller, so a lane loop
// here costs what a hand-written loop over that one type would.

// MARK: - Lanes

@inlinable @inline(__always)
func lanewise<V: SIMD>(_ x: V, _ f: (V.Scalar) -> V.Scalar) -> V {
    var result = x
    for i in result.indices { result[i] = f(x[i]) }
    return result
}

@inlinable @inline(__always)
func lanewise<V: SIMD>(_ x: V, _ y: V, _ f: (V.Scalar, V.Scalar) -> V.Scalar) -> V {
    var result = x
    for i in result.indices { result[i] = f(x[i], y[i]) }
    return result
}

/// Into a vector of another scalar with as many lanes.
@inlinable @inline(__always)
func lanewise<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self, _ f: (V.Scalar) -> R.Scalar) -> R {
    var result = R()
    for i in result.indices { result[i] = f(x[i]) }
    return result
}

/// All bits set where `condition` holds, none elsewhere: the integer masks
/// the comparison functions return.
@inlinable @inline(__always)
func mask<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self, _ condition: (V.Scalar) -> Bool) -> R
where R.Scalar: FixedWidthInteger {
    lanewise(x, into: R.self) { condition($0) ? ~R.Scalar.zero : .zero }
}

/// The first lanes of `x`, the rest zero: widening and narrowing copies.
@inlinable @inline(__always)
func resized<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self) -> R where V.Scalar == R.Scalar {
    var result = R()
    for i in 0 ..< Swift.min(x.scalarCount, result.scalarCount) { result[i] = x[i] }
    return result
}

@inlinable @inline(__always)
func resized<S: SIMDScalar, R: SIMD>(_ x: S, into _: R.Type = R.self) -> R where R.Scalar == S {
    var result = R()
    result[0] = x
    return result
}

// MARK: - Elementwise math

@inlinable
func sinPi<S: RealScalar>(_ x: S) -> S {
    // r = x - 2k in [-1, 1], exactly; then |s| <= 1/2 with sin(πs) = sin(πr).
    let r = S.libmRemainder(x, 2)
    let s = r > 0.5 ? 1 - r : (r < -0.5 ? -1 - r : r)
    // + 0: zero results are +0, as for sinpi(-0) and sinpi(-2).
    return S.libmSin(S.pi * s) + 0
}

@inlinable
func cosPi<S: RealScalar>(_ x: S) -> S {
    // cos(πr) = sin(π(1/2 - |r|)), exactly 0 at the half turns.
    let r = S.libmRemainder(x, 2).magnitude
    return S.libmSin(S.pi * (0.5 - r))
}

@inlinable
func tanPi<S: RealScalar>(_ x: S) -> S {
    let r = S.libmRemainder(x, 1)
    return sinPi(r) / cosPi(r)
}

@inlinable
func exp10Scalar<S: RealScalar>(_ x: S) -> S { S.libmPow(10, x) }

// MARK: - Common

@inlinable @inline(__always)
func absInteger<V: SIMD>(_ x: V) -> V where V.Scalar: FixedWidthInteger & SignedInteger {
    // Wraps like C: the most negative value stays itself.
    x.replacing(with: V.zero &- x, where: x .< V.zero)
}

@inlinable @inline(__always)
func absFloat<V: SIMD>(_ x: V) -> V where V.Scalar: FloatingPoint {
    lanewise(x) { $0.magnitude }
}

/// `fmin`/`fmax`: a NaN lane takes the other operand.
@inlinable @inline(__always)
func minFloat<V: SIMD>(_ x: V, _ y: V) -> V where V.Scalar: FloatingPoint { lanewise(x, y, V.Scalar.minimum) }

@inlinable @inline(__always)
func maxFloat<V: SIMD>(_ x: V, _ y: V) -> V where V.Scalar: FloatingPoint { lanewise(x, y, V.Scalar.maximum) }

@inlinable @inline(__always)
func minInteger<V: SIMD>(_ x: V, _ y: V) -> V where V.Scalar: FixedWidthInteger { x.replacing(with: y, where: y .< x) }

@inlinable @inline(__always)
func maxInteger<V: SIMD>(_ x: V, _ y: V) -> V where V.Scalar: FixedWidthInteger { x.replacing(with: y, where: y .> x) }

@inlinable @inline(__always)
func clampFloat<V: SIMD>(_ x: V, _ low: V, _ high: V) -> V where V.Scalar: FloatingPoint {
    minFloat(maxFloat(x, low), high)
}

@inlinable @inline(__always)
func clampInteger<V: SIMD>(_ x: V, _ low: V, _ high: V) -> V where V.Scalar: FixedWidthInteger {
    minInteger(maxInteger(x, low), high)
}

@inlinable @inline(__always)
func clampFloat<S: FloatingPoint>(_ x: S, _ low: S, _ high: S) -> S {
    S.minimum(S.maximum(x, low), high)
}

/// -1, 0 or 1; 0 for zeros and NaN.
@inlinable @inline(__always)
func signFloat<V: SIMD>(_ x: V) -> V where V.Scalar: FloatingPoint {
    V.zero.replacing(with: 1, where: x .> V.zero).replacing(with: -1, where: x .< V.zero)
}

@inlinable @inline(__always)
func signFloat<S: FloatingPoint>(_ x: S) -> S { x > 0 ? 1 : (x < 0 ? -1 : 0) }

@inlinable @inline(__always)
func mixFloat<V: SIMD>(_ x: V, _ y: V, _ t: V) -> V where V.Scalar: FloatingPoint { x + t * (y - x) }

@inlinable @inline(__always)
func mixFloat<S: FloatingPoint>(_ x: S, _ y: S, _ t: S) -> S { x + t * (y - x) }

@inlinable @inline(__always)
func recipFloat<V: SIMD>(_ x: V) -> V where V.Scalar: FloatingPoint { V.one / x }

@inlinable @inline(__always)
func rsqrtFloat<V: SIMD>(_ x: V) -> V where V.Scalar: FloatingPoint { V.one / x.squareRoot() }

@inlinable @inline(__always)
func rsqrtFloat<S: FloatingPoint>(_ x: S) -> S { 1 / x.squareRoot() }

/// `x - floor(x)`, kept below 1.
@inlinable @inline(__always)
func fractFloat<V: SIMD>(_ x: V) -> V where V.Scalar: FloatingPoint {
    minFloat(x - x.rounded(.down), V(repeating: V.Scalar(1).nextDown))
}

@inlinable @inline(__always)
func fractFloat<S: FloatingPoint>(_ x: S) -> S { S.minimum(x - x.rounded(.down), S(1).nextDown) }

/// 0 where `x < edge`, 1 elsewhere.
@inlinable @inline(__always)
func stepFloat<V: SIMD>(_ edge: V, _ x: V) -> V where V.Scalar: FloatingPoint {
    V.one.replacing(with: V.zero, where: x .< edge)
}

@inlinable @inline(__always)
func stepFloat<S: FloatingPoint>(_ edge: S, _ x: S) -> S { x < edge ? 0 : 1 }

@inlinable @inline(__always)
func smoothstepFloat<V: SIMD>(_ edge0: V, _ edge1: V, _ x: V) -> V where V.Scalar: FloatingPoint {
    let t = clampFloat((x - edge0) / (edge1 - edge0), V.zero, V.one)
    return t * t * (3 - 2 * t)
}

@inlinable @inline(__always)
func smoothstepFloat<S: FloatingPoint>(_ edge0: S, _ edge1: S, _ x: S) -> S {
    let t = clampFloat((x - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
}

/// `x * y + z`, fused.
@inlinable @inline(__always)
func muladdFloat<V: SIMD>(_ x: V, _ y: V, _ z: V) -> V where V.Scalar: FloatingPoint { z.addingProduct(x, y) }

// MARK: - Geometry

@inlinable @inline(__always)
func dotFloat<V: SIMD>(_ x: V, _ y: V) -> V.Scalar where V.Scalar: FloatingPoint { (x * y).sum() }

@inlinable @inline(__always)
func lengthFloat<V: SIMD>(_ x: V) -> V.Scalar where V.Scalar: FloatingPoint { dotFloat(x, x).squareRoot() }

@inlinable @inline(__always)
func normalizeFloat<V: SIMD>(_ x: V) -> V where V.Scalar: FloatingPoint { x * rsqrtFloat(dotFloat(x, x)) }

@inlinable @inline(__always)
func normOneFloat<V: SIMD>(_ x: V) -> V.Scalar where V.Scalar: FloatingPoint { absFloat(x).sum() }

@inlinable @inline(__always)
func normInfFloat<V: SIMD>(_ x: V) -> V.Scalar where V.Scalar: FloatingPoint { absFloat(x).max() }

/// The part of `x` along `y`.
@inlinable @inline(__always)
func projectFloat<V: SIMD>(_ x: V, _ y: V) -> V where V.Scalar: FloatingPoint {
    dotFloat(x, y) / dotFloat(y, y) * y
}

/// `x` mirrored in the plane with unit normal `n`.
@inlinable @inline(__always)
func reflectFloat<V: SIMD>(_ x: V, _ n: V) -> V where V.Scalar: FloatingPoint {
    x - 2 * dotFloat(x, n) * n
}

/// `x` bent through a surface with unit normal `n`; zero past the critical angle.
@inlinable @inline(__always)
func refractFloat<V: SIMD>(_ x: V, _ n: V, _ eta: V.Scalar) -> V where V.Scalar: FloatingPoint {
    let d = dotFloat(n, x)
    let k = 1 - eta * eta * (1 - d * d)
    return k < 0 ? V.zero : eta * x - (eta * d + k.squareRoot()) * n
}

@inlinable @inline(__always)
func crossFloat<S: RealScalar>(_ x: SIMD3<S>, _ y: SIMD3<S>) -> SIMD3<S> {
    SIMD3(x.y * y.z - x.z * y.y, x.z * y.x - x.x * y.z, x.x * y.y - x.y * y.x)
}

@inlinable @inline(__always)
func crossFloat<S: RealScalar>(_ x: SIMD2<S>, _ y: SIMD2<S>) -> SIMD3<S> {
    SIMD3(0, 0, x.x * y.y - x.y * y.x)
}

// The orientation predicates. Float inputs are evaluated in Double, which
// gets the sign right for far closer calls than Float arithmetic would.

/// det [x y]: positive when y is counterclockwise from x.
@inlinable
func orient<S: RealScalar>(_ x: SIMD2<S>, _ y: SIMD2<S>) -> S {
    let x = SIMD2<Double>(x), y = SIMD2<Double>(y)
    return S(x.x * y.y - x.y * y.x)
}

/// Positive when a, b, c turn counterclockwise.
@inlinable
func orient<S: RealScalar>(_ a: SIMD2<S>, _ b: SIMD2<S>, _ c: SIMD2<S>) -> S {
    let a = SIMD2<Double>(a), b = SIMD2<Double>(b) - a, c = SIMD2<Double>(c) - a
    return S(b.x * c.y - b.y * c.x)
}

/// det [x y z]: positive for a right-handed basis.
@inlinable
func orient<S: RealScalar>(_ x: SIMD3<S>, _ y: SIMD3<S>, _ z: SIMD3<S>) -> S {
    S(dotFloat(SIMD3<Double>(x), crossFloat(SIMD3<Double>(y), SIMD3<Double>(z))))
}

/// det [a-d b-d c-d]: positive when b - a, c - a, d - a are left-handed.
@inlinable
func orient<S: RealScalar>(_ a: SIMD3<S>, _ b: SIMD3<S>, _ c: SIMD3<S>, _ d: SIMD3<S>) -> S {
    let d = SIMD3<Double>(d)
    return S(dotFloat(SIMD3<Double>(a) - d, crossFloat(SIMD3<Double>(b) - d, SIMD3<Double>(c) - d)))
}

/// Positive when x is inside the circle through a, b, c (counterclockwise),
/// negative outside, zero on it.
@inlinable
func incircle<S: RealScalar>(_ x: SIMD2<S>, _ a: SIMD2<S>, _ b: SIMD2<S>, _ c: SIMD2<S>) -> S {
    let p = SIMD2<Double>(x)
    let a = SIMD2<Double>(a) - p, b = SIMD2<Double>(b) - p, c = SIMD2<Double>(c) - p
    let la = dotFloat(a, a), lb = dotFloat(b, b), lc = dotFloat(c, c)
    let det = a.x * (b.y * lc - lb * c.y) - a.y * (b.x * lc - lb * c.x) + la * (b.x * c.y - b.y * c.x)
    return S(det)
}

/// Positive when x is inside the sphere through a, b, c, d and
/// `orient(a, b, c, d)` is positive; the sign flips with either.
@inlinable
func insphere<S: RealScalar>(
    _ x: SIMD3<S>, _ a: SIMD3<S>, _ b: SIMD3<S>, _ c: SIMD3<S>, _ d: SIMD3<S>
) -> S {
    let p = SIMD3<Double>(x)
    let a = SIMD3<Double>(a) - p, b = SIMD3<Double>(b) - p, c = SIMD3<Double>(c) - p, d = SIMD3<Double>(d) - p
    func det3(_ u: SIMD3<Double>, _ v: SIMD3<Double>, _ w: SIMD3<Double>) -> Double { dotFloat(u, crossFloat(v, w)) }
    // det [row | squared length], expanded along the last column.
    let det = -dotFloat(a, a) * det3(b, c, d) + dotFloat(b, b) * det3(a, c, d)
        - dotFloat(c, c) * det3(a, b, d) + dotFloat(d, d) * det3(a, b, c)
    return S(det)
}

// MARK: - Logic

/// The top bit of every lane, as a Bool per lane.
@inlinable @inline(__always)
func topBits<V: SIMD>(_ x: V) -> SIMDMask<V.MaskStorage> where V.Scalar: FixedWidthInteger {
    (x &>> V.Scalar(V.Scalar.bitWidth - 1)) .!= V.zero
}

/// `y` where the mask's top bit is set, `x` elsewhere.
@inlinable @inline(__always)
func select<V: SIMD, M: SIMD>(_ x: V, _ y: V, _ mask: M) -> V where M.Scalar: FixedWidthInteger & SignedInteger {
    var result = x
    for i in result.indices where mask[i] < 0 { result[i] = y[i] }
    return result
}

/// The bits of `y` where `mask` has them set, of `x` elsewhere.
@inlinable @inline(__always)
func bitselectInteger<V: SIMD, M: SIMD>(_ x: V, _ y: V, _ mask: M) -> V
where V.Scalar: FixedWidthInteger, M.Scalar: FixedWidthInteger {
    var result = x
    for i in result.indices {
        let m = V.Scalar(truncatingIfNeeded: mask[i])
        result[i] = (x[i] & ~m) | (y[i] & m)
    }
    return result
}

@inlinable @inline(__always)
func bitselectFloat<V: SIMD, M: SIMD>(_ x: V, _ y: V, _ mask: M) -> V where V.Scalar == Float, M.Scalar == Int32 {
    var result = x
    for i in result.indices {
        let m = UInt32(bitPattern: mask[i])
        result[i] = Float(bitPattern: (x[i].bitPattern & ~m) | (y[i].bitPattern & m))
    }
    return result
}

@inlinable @inline(__always)
func bitselectFloat<V: SIMD, M: SIMD>(_ x: V, _ y: V, _ mask: M) -> V where V.Scalar == Double, M.Scalar: FixedWidthInteger {
    var result = x
    for i in result.indices {
        let m = UInt64(truncatingIfNeeded: mask[i])
        result[i] = Double(bitPattern: (x[i].bitPattern & ~m) | (y[i].bitPattern & m))
    }
    return result
}

// MARK: - Conversions

/// Integers to integers, keeping the low bits.
@inlinable @inline(__always)
func convertTruncating<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self) -> R
where V.Scalar: FixedWidthInteger, R.Scalar: FixedWidthInteger {
    lanewise(x) { R.Scalar(truncatingIfNeeded: $0) }
}

/// Integers to integers, clamped to the result's range.
@inlinable @inline(__always)
func convertSaturating<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self) -> R
where V.Scalar: FixedWidthInteger, R.Scalar: FixedWidthInteger {
    lanewise(x) { R.Scalar(clamping: $0) }
}

/// A floating-point value as an integer, toward zero, clamped to the
/// integer's range; NaN is the lowest value.
@inlinable @inline(__always)
func saturatingInteger<F: BinaryFloatingPoint, I: FixedWidthInteger>(_ x: F, as _: I.Type = I.self) -> I {
    if x.isNaN || x <= F(I.min) { return I.min }
    if x >= F(I.max) { return I.max }
    return I(x)
}

/// Toward zero into 64 bits, then the low bits: 300.0 as an 8-bit integer
/// is 44, -1.0 as an unsigned one all ones. Past 64 bits it saturates.
@inlinable @inline(__always)
func wrappingInteger<F: BinaryFloatingPoint, I: FixedWidthInteger>(_ x: F, as _: I.Type = I.self) -> I {
    x < 0
        ? I(truncatingIfNeeded: saturatingInteger(x, as: Int64.self))
        : I(truncatingIfNeeded: saturatingInteger(x, as: UInt64.self))
}

/// Floating point to integers, toward zero, keeping the low bits.
@inlinable @inline(__always)
func convertFloatToInteger<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self) -> R
where V.Scalar: BinaryFloatingPoint, R.Scalar: FixedWidthInteger {
    lanewise(x) { wrappingInteger($0) }
}

/// Floating point to integers, toward zero, clamped to the result's range.
@inlinable @inline(__always)
func convertFloatToIntegerSaturating<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self) -> R
where V.Scalar: BinaryFloatingPoint, R.Scalar: FixedWidthInteger {
    lanewise(x) { saturatingInteger($0) }
}

/// Floating point to integers, to nearest with ties to even, saturating.
@inlinable @inline(__always)
func convertFloatToIntegerRTE<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self) -> R
where V.Scalar: BinaryFloatingPoint, R.Scalar: FixedWidthInteger {
    lanewise(x) { saturatingInteger($0.rounded(.toNearestOrEven)) }
}

@inlinable @inline(__always)
func convertIntegerToFloat<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self) -> R
where V.Scalar: FixedWidthInteger, R.Scalar: BinaryFloatingPoint {
    lanewise(x) { R.Scalar($0) }
}

@inlinable @inline(__always)
func convertFloatToFloat<V: SIMD, R: SIMD>(_ x: V, into _: R.Type = R.self) -> R
where V.Scalar: BinaryFloatingPoint, R.Scalar: BinaryFloatingPoint {
    lanewise(x) { R.Scalar($0) }
}

// MARK: - Description

/// "[1.0, 2.0, 3.0]", the form matrices print their columns in.
@inlinable
func arrayDescription<V: SIMD>(_ x: V) -> String {
    "[" + x.indices.map { "\(x[$0])" }.joined(separator: ", ") + "]"
}
