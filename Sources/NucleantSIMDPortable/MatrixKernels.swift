// Determinants and inverses of square matrices, on their columns. The
// matrix types (Generated/Matrices.swift) call these.

// MARK: - 2x2

@inlinable
func determinant<S: RealScalar>(_ c0: SIMD2<S>, _ c1: SIMD2<S>) -> S {
    c0.x * c1.y - c0.y * c1.x
}

@inlinable
func inverse<S: RealScalar>(_ c0: SIMD2<S>, _ c1: SIMD2<S>) -> (SIMD2<S>, SIMD2<S>) {
    let r = 1 / determinant(c0, c1)
    return (SIMD2(c1.y, -c0.y) * r, SIMD2(-c1.x, c0.x) * r)
}

// MARK: - 3x3

@inlinable
func determinant<S: RealScalar>(_ c0: SIMD3<S>, _ c1: SIMD3<S>, _ c2: SIMD3<S>) -> S {
    dotFloat(c0, crossFloat(c1, c2))
}

@inlinable
func inverse<S: RealScalar>(_ c0: SIMD3<S>, _ c1: SIMD3<S>, _ c2: SIMD3<S>) -> (SIMD3<S>, SIMD3<S>, SIMD3<S>) {
    // The rows of the inverse are c1×c2, c2×c0 and c0×c1 over the determinant.
    let r0 = crossFloat(c1, c2), r1 = crossFloat(c2, c0), r2 = crossFloat(c0, c1)
    let r = 1 / dotFloat(c0, r0)
    return (SIMD3(r0.x, r1.x, r2.x) * r, SIMD3(r0.y, r1.y, r2.y) * r, SIMD3(r0.z, r1.z, r2.z) * r)
}

// MARK: - 4x4

// Laplace expansion along the top two rows: six 2x2 determinants from rows
// 0-1 (s) and six from rows 2-3 (c) give the determinant and every cofactor.

@usableFromInline
struct Minors4<S: RealScalar> {
    @usableFromInline var s0, s1, s2, s3, s4, s5: S
    @usableFromInline var c0, c1, c2, c3, c4, c5: S

    @inlinable
    init(_ m0: SIMD4<S>, _ m1: SIMD4<S>, _ m2: SIMD4<S>, _ m3: SIMD4<S>) {
        // m<column>[row]
        s0 = m0[0] * m1[1] - m0[1] * m1[0]
        s1 = m0[0] * m2[1] - m0[1] * m2[0]
        s2 = m0[0] * m3[1] - m0[1] * m3[0]
        s3 = m1[0] * m2[1] - m1[1] * m2[0]
        s4 = m1[0] * m3[1] - m1[1] * m3[0]
        s5 = m2[0] * m3[1] - m2[1] * m3[0]
        c5 = m2[2] * m3[3] - m2[3] * m3[2]
        c4 = m1[2] * m3[3] - m1[3] * m3[2]
        c3 = m1[2] * m2[3] - m1[3] * m2[2]
        c2 = m0[2] * m3[3] - m0[3] * m3[2]
        c1 = m0[2] * m2[3] - m0[3] * m2[2]
        c0 = m0[2] * m1[3] - m0[3] * m1[2]
    }

    @inlinable
    var determinant: S { s0 * c5 - s1 * c4 + s2 * c3 + s3 * c2 - s4 * c1 + s5 * c0 }
}

@inlinable
func determinant<S: RealScalar>(_ m0: SIMD4<S>, _ m1: SIMD4<S>, _ m2: SIMD4<S>, _ m3: SIMD4<S>) -> S {
    Minors4(m0, m1, m2, m3).determinant
}

@inlinable
func inverse<S: RealScalar>(
    _ m0: SIMD4<S>, _ m1: SIMD4<S>, _ m2: SIMD4<S>, _ m3: SIMD4<S>
) -> (SIMD4<S>, SIMD4<S>, SIMD4<S>, SIMD4<S>) {
    let k = Minors4(m0, m1, m2, m3)
    let r = 1 / k.determinant
    // Row j of the inverse: the cofactors of column j.
    let i0 = SIMD4(
        m1[1] * k.c5 - m2[1] * k.c4 + m3[1] * k.c3,
        -m1[0] * k.c5 + m2[0] * k.c4 - m3[0] * k.c3,
        m1[3] * k.s5 - m2[3] * k.s4 + m3[3] * k.s3,
        -m1[2] * k.s5 + m2[2] * k.s4 - m3[2] * k.s3
    )
    let i1 = SIMD4(
        -m0[1] * k.c5 + m2[1] * k.c2 - m3[1] * k.c1,
        m0[0] * k.c5 - m2[0] * k.c2 + m3[0] * k.c1,
        -m0[3] * k.s5 + m2[3] * k.s2 - m3[3] * k.s1,
        m0[2] * k.s5 - m2[2] * k.s2 + m3[2] * k.s1
    )
    let i2 = SIMD4(
        m0[1] * k.c4 - m1[1] * k.c2 + m3[1] * k.c0,
        -m0[0] * k.c4 + m1[0] * k.c2 - m3[0] * k.c0,
        m0[3] * k.s4 - m1[3] * k.s2 + m3[3] * k.s0,
        -m0[2] * k.s4 + m1[2] * k.s2 - m3[2] * k.s0
    )
    let i3 = SIMD4(
        -m0[1] * k.c3 + m1[1] * k.c1 - m2[1] * k.c0,
        m0[0] * k.c3 - m1[0] * k.c1 + m2[0] * k.c0,
        -m0[3] * k.s3 + m1[3] * k.s1 - m2[3] * k.s0,
        m0[2] * k.s3 - m1[2] * k.s1 + m2[2] * k.s0
    )
    return (
        SIMD4(i0[0], i1[0], i2[0], i3[0]) * r,
        SIMD4(i0[1], i1[1], i2[1], i3[1]) * r,
        SIMD4(i0[2], i1[2], i2[2], i3[2]) * r,
        SIMD4(i0[3], i1[3], i2[3], i3[3]) * r
    )
}
