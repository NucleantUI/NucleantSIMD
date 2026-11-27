// Quaternion math on (ix, iy, iz, r) vectors. `simd_quatf` and `simd_quatd`
// (Generated/Quaternions.swift) call these.

@inlinable @inline(__always)
func imaginary<S: RealScalar>(_ q: SIMD4<S>) -> SIMD3<S> { SIMD3(q.x, q.y, q.z) }

@inlinable @inline(__always)
func quaternion<S: RealScalar>(_ imag: SIMD3<S>, _ real: S) -> SIMD4<S> { SIMD4(imag, real) }

@inlinable
func quaternionProduct<S: RealScalar>(_ p: SIMD4<S>, _ q: SIMD4<S>) -> SIMD4<S> {
    let pv = imaginary(p), qv = imaginary(q)
    return quaternion(p.w * qv + q.w * pv + crossFloat(pv, qv), p.w * q.w - dotFloat(pv, qv))
}

@inlinable @inline(__always)
func quaternionConjugate<S: RealScalar>(_ q: SIMD4<S>) -> SIMD4<S> { SIMD4(-q.x, -q.y, -q.z, q.w) }

@inlinable @inline(__always)
func quaternionInverse<S: RealScalar>(_ q: SIMD4<S>) -> SIMD4<S> { quaternionConjugate(q) / dotFloat(q, q) }

/// `v` turned by the unit quaternion `q`: q·v·q⁻¹, worked out without the
/// products.
@inlinable
func quaternionAct<S: RealScalar>(_ q: SIMD4<S>, _ v: SIMD3<S>) -> SIMD3<S> {
    let u = imaginary(q), t = 2 * crossFloat(u, v)
    return v + q.w * t + crossFloat(u, t)
}

@inlinable
func quaternionAngle<S: RealScalar>(_ q: SIMD4<S>) -> S {
    2 * S.libmAtan2(lengthFloat(imaginary(q)), q.w)
}

@inlinable
func quaternionAxis<S: RealScalar>(_ q: SIMD4<S>) -> SIMD3<S> { normalizeFloat(imaginary(q)) }

/// A turn of `angle` radians around `axis` (of unit length).
@inlinable
func quaternion<S: RealScalar>(angle: S, axis: SIMD3<S>) -> SIMD4<S> {
    let half = angle / 2
    return quaternion(S.libmSin(half) * axis, S.libmCos(half))
}

/// The shortest turn from `from` to `to`, both of unit length.
@inlinable
func quaternion<S: RealScalar>(from: SIMD3<S>, to: SIMD3<S>) -> SIMD4<S> {
    // Half way between them, h: the turn is (from × h, from · h).
    let sum = from + to, length2 = dotFloat(sum, sum)
    if length2 > S.ulpOfOne * dotFloat(from, from) {
        let h = sum * rsqrtFloat(length2)
        return quaternion(crossFloat(from, h), dotFloat(from, h))
    }
    // Opposite directions: half a turn around any axis perpendicular to `from`.
    let a = absFloat(from)
    let other: SIMD3<S> = a.x <= a.y && a.x <= a.z ? SIMD3(1, 0, 0) : (a.y <= a.z ? SIMD3(0, 1, 0) : SIMD3(0, 0, 1))
    return quaternion(normalizeFloat(crossFloat(from, other)), 0)
}

/// The turn a rotation matrix makes, from its columns.
@inlinable
func quaternion<S: RealScalar>(_ c0: SIMD3<S>, _ c1: SIMD3<S>, _ c2: SIMD3<S>) -> SIMD4<S> {
    // Shepperd: start from the largest of 4r², 4x², 4y², 4z² for accuracy.
    let trace = c0.x + c1.y + c2.z
    if trace >= c0.x && trace >= c1.y && trace >= c2.z {
        let r = (1 + trace).squareRoot() / 2, f = 1 / (4 * r)
        return SIMD4((c1.z - c2.y) * f, (c2.x - c0.z) * f, (c0.y - c1.x) * f, r)
    } else if c0.x >= c1.y && c0.x >= c2.z {
        let x = (1 + c0.x - c1.y - c2.z).squareRoot() / 2, f = 1 / (4 * x)
        return SIMD4(x, (c1.x + c0.y) * f, (c2.x + c0.z) * f, (c1.z - c2.y) * f)
    } else if c1.y >= c2.z {
        let y = (1 - c0.x + c1.y - c2.z).squareRoot() / 2, f = 1 / (4 * y)
        return SIMD4((c1.x + c0.y) * f, y, (c2.y + c1.z) * f, (c2.x - c0.z) * f)
    } else {
        let z = (1 - c0.x - c1.y + c2.z).squareRoot() / 2, f = 1 / (4 * z)
        return SIMD4((c2.x + c0.z) * f, (c2.y + c1.z) * f, z, (c0.y - c1.x) * f)
    }
}

/// The columns of the rotation matrix of a unit quaternion. Written with r²
/// on the diagonal rather than 1, so any other length scales the matrix by
/// its square.
@inlinable
func rotationColumns<S: RealScalar>(_ q: SIMD4<S>) -> (SIMD3<S>, SIMD3<S>, SIMD3<S>) {
    let x = q.x, y = q.y, z = q.z, r = q.w
    let xx = x * x, yy = y * y, zz = z * z, rr = r * r
    return (
        SIMD3(rr + xx - yy - zz, 2 * (x * y + z * r), 2 * (x * z - y * r)),
        SIMD3(2 * (x * y - z * r), rr - xx + yy - zz, 2 * (y * z + x * r)),
        SIMD3(2 * (x * z + y * r), 2 * (y * z - x * r), rr - xx - yy + zz)
    )
}

@inlinable
func quaternionExp<S: RealScalar>(_ q: SIMD4<S>) -> SIMD4<S> {
    let v = imaginary(q), angle = lengthFloat(v), scale = S.libmExp(q.w)
    if angle == 0 { return quaternion(v, scale) }
    return scale * quaternion(S.libmSin(angle) / angle * v, S.libmCos(angle))
}

@inlinable
func quaternionLog<S: RealScalar>(_ q: SIMD4<S>) -> SIMD4<S> {
    let v = imaginary(q), sine = lengthFloat(v), length = lengthFloat(q)
    if sine == 0 { return quaternion(v, S.libmLog(length)) }
    return quaternion(S.libmAtan2(sine, q.w) / sine * v, S.libmLog(length))
}

/// Along the arc from `q0` to `q1` (unit quaternions) at a constant rate.
@inlinable
func slerpArc<S: RealScalar>(_ q0: SIMD4<S>, _ q1: SIMD4<S>, _ t: S) -> SIMD4<S> {
    let d = clampFloat(dotFloat(q0, q1), -1, 1)
    let angle = S.libmAcos(d)
    let s = S.libmSin(angle)
    // Nearly the same: the chord and the arc agree.
    if s.magnitude < S.ulpOfOne.squareRoot() {
        return normalizeFloat(mixFloat(q0, q1, SIMD4(repeating: t)))
    }
    return (S.libmSin((1 - t) * angle) * q0 + S.libmSin(t * angle) * q1) / s
}

/// The shorter way round: q and -q are the same turn.
@inlinable
func slerp<S: RealScalar>(_ q0: SIMD4<S>, _ q1: SIMD4<S>, _ t: S) -> SIMD4<S> {
    slerpArc(q0, dotFloat(q0, q1) < 0 ? -q1 : q1, t)
}

@inlinable
func slerpLongest<S: RealScalar>(_ q0: SIMD4<S>, _ q1: SIMD4<S>, _ t: S) -> SIMD4<S> {
    slerpArc(q0, dotFloat(q0, q1) >= 0 ? -q1 : q1, t)
}

/// The control point at `q1` for a smooth spline through q0, q1, q2.
@inlinable
func splineControl<S: RealScalar>(_ q0: SIMD4<S>, _ q1: SIMD4<S>, _ q2: SIMD4<S>) -> SIMD4<S> {
    let inverse1 = quaternionInverse(q1)
    let a = quaternionLog(quaternionProduct(inverse1, dotFloat(q1, q2) < 0 ? -q2 : q2))
    let b = quaternionLog(quaternionProduct(inverse1, dotFloat(q1, q0) < 0 ? -q0 : q0))
    return quaternionProduct(q1, quaternionExp(-(a + b) / 4))
}

/// From q1 at t = 0 to q2 at t = 1, smooth through q0 before and q3 after.
@inlinable
func spline<S: RealScalar>(_ q0: SIMD4<S>, _ q1: SIMD4<S>, _ q2: SIMD4<S>, _ q3: SIMD4<S>, _ t: S) -> SIMD4<S> {
    let s1 = splineControl(q0, q1, q2), s2 = splineControl(q1, q2, q3)
    return slerp(slerp(q1, q2, t), slerp(s1, s2, t), 2 * t * (1 - t))
}

/// The cubic Bézier curve from q0 to q3 with control points q1 and q2.
@inlinable
func bezier<S: RealScalar>(_ q0: SIMD4<S>, _ q1: SIMD4<S>, _ q2: SIMD4<S>, _ q3: SIMD4<S>, _ t: S) -> SIMD4<S> {
    let q01 = slerp(q0, q1, t), q12 = slerp(q1, q2, t), q23 = slerp(q2, q3, t)
    return slerp(slerp(q01, q12, t), slerp(q12, q23, t), t)
}
