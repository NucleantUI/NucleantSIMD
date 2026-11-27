import NucleantSIMD
import Testing

/// What the simd API does at its edges: NaN, out-of-range conversions,
/// quaternions that aren't of unit length. Same results on every platform.
@Suite("Edge behavior")
struct BehaviorTests {

    @Test func floatToIntegerKeepsLowBits() {
        #expect(simd_char(SIMD2<Float>(300, -300)) == SIMD2<Int8>(44, -44))
        #expect(simd_uchar(SIMD2<Float>(300, -5)) == SIMD2<UInt8>(44, 251))
        #expect(simd_ushort(SIMD2<Float>(-1, 70_000)) == SIMD2<UInt16>(65_535, 4_464))
        #expect(simd_uint(SIMD2<Float>(-1.5, 7)) == SIMD2<UInt32>(.max, 7))
        #expect(simd_ulong(SIMD2<Double>(1.8e19, -1)) == SIMD2<simd_ulong1>(18_000_000_000_000_000_000, .max))
        #expect(simd_long(SIMD2<Double>(-2.5, 2.5)) == SIMD2<simd_long1>(-2, 2))
    }

    @Test func saturatingConversions() {
        #expect(simd_int_sat(SIMD4<Float>(.nan, 3e9, -3e9, 2.7)) == SIMD4<Int32>(.min, .max, .min, 2))
        #expect(simd_char_sat(SIMD2<Float>(.nan, 1)) == SIMD2<Int8>(-128, 1))
        #expect(simd_uchar_sat(SIMD2<Float>(.nan, 1)) == SIMD2<UInt8>(0, 1))
        #expect(simd_short_sat(SIMD2<Float>(40_000, .nan)) == SIMD2<Int16>(.max, .min))
        #expect(simd_uint_sat(SIMD2<Float>(-1.5, 5e9)) == SIMD2<UInt32>(0, .max))
        #expect(simd_long_sat(SIMD2<Double>(.nan, 1e30)) == SIMD2<simd_long1>(.min, .max))
        #expect(simd_ulong_sat(SIMD2<Double>(.nan, -1)) == SIMD2<simd_ulong1>(0, 0))
        #expect(simd_long_rte(SIMD2<Double>(0.5, 1.5)) == SIMD2<simd_long1>(0, 2))
        #expect(simd_uint_rte(SIMD2<Float>(-0.5, 4e9)) == SIMD2<UInt32>(0, 4_000_000_000))
        #expect(simd_float(SIMD2<UInt32>(.max, 16_777_217)) == SIMD2<Float>(4_294_967_296, 16_777_216))
    }

    @Test func notANumber() {
        let nan = Float.nan
        #expect(simd_fract(SIMD4<Float>(nan, .infinity, -0.25, 1)) == SIMD4<Float>(0.99999994, 0.99999994, 0.75, 0))
        #expect(simd_sign(SIMD4<Float>(nan, -0.0, 0, -3)) == SIMD4<Float>(0, 0, 0, -1))
        #expect(simd_clamp(SIMD2<Float>(nan, 5), SIMD2<Float>(0, 0), SIMD2<Float>(1, 1)) == SIMD2<Float>(0, 1))
        #expect(simd_min(SIMD2<Float>(nan, 1), SIMD2<Float>(0, nan)) == SIMD2<Float>(0, 1))
        #expect(simd_step(SIMD2<Float>(0.5, 0.5), SIMD2<Float>(nan, 0.5)) == SIMD2<Float>(1, 1))
        #expect(simd_reduce_min(SIMD4<Float>(nan, 1, 2, 3)) == 1)
        #expect(simd_reduce_max(SIMD8<Float>(1, 2, 3, nan, 0, 0, 0, 0)) == 3)
        #expect(simd_normalize(SIMD3<Float>(0, 0, 0)).x.isNaN)
        #expect(isnan(SIMD4<Float>(nan, 1, .infinity, 0)) == SIMD4<Int32>(-1, 0, 0, 0))
        #expect(isinf(SIMD2<Double>(.infinity, 1)) == SIMD2<simd_long1>(-1, 0))
        #expect(isfinite(SIMD2<Float>(.infinity, 1)) == SIMD2<Int32>(0, -1))
    }

    @Test func integerAbsWraps() {
        #expect(simd_abs(SIMD2<Int32>(.min, -1)) == SIMD2<Int32>(.min, 1))
        #expect(simd_abs(SIMD4<Int8>(-128, -1, 0, 127)) == SIMD4<Int8>(-128, 1, 0, 127))
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @Test func timesPiExactly() {
        let s = sinpi(SIMD4<Float>(1e10, -0.0, -2, 0.5))
        #expect(s == SIMD4<Float>(0, 0, 0, 1))
        #expect(s.y.sign == .plus && s.z.sign == .plus)
        #expect(cospi(SIMD4<Float>(0.5, -0.5, 1e10, 1)) == SIMD4<Float>(0, 0, 1, -1))
        #expect(tanpi(SIMD4<Float>(0.5, -0.5, 0.25, 1)) == SIMD4<Float>(.infinity, -.infinity, 1, 0))
    }

    @Test func refraction() {
        let x = SIMD3<Float>(0.7071068, -0.7071068, 0), n = SIMD3<Float>(0, 1, 0)
        #expect(isClose(simd_refract(x, n, 0.5), SIMD3<Float>(0.3535534, -0.9354144, 0)))
        #expect(refract(x, n: n, eta: 2) == .zero)
        #expect(simd_length(SIMD2<Float>(3e30, 4e30)) == .infinity)
    }

    @Test func orientation() {
        #expect(simd_orient(SIMD2<Float>(1, 0), SIMD2<Float>(0, 1)) == 1)
        #expect(simd_orient(SIMD2<Float>(0, 0), SIMD2<Float>(1, 0), SIMD2<Float>(0, 1)) == 1)
        #expect(simd_orient(SIMD3<Float>(1, 0, 0), SIMD3<Float>(0, 1, 0), SIMD3<Float>(0, 0, 1)) == 1)
        #expect(simd_orient(SIMD3<Float>(0, 0, 0), SIMD3<Float>(1, 0, 0), SIMD3<Float>(0, 1, 0), SIMD3<Float>(0, 0, 1)) == -1)
        #expect(simd_orient(SIMD3<Double>(1, 1, 1), SIMD3<Double>(3, 1, 1), SIMD3<Double>(1, 4, 1), SIMD3<Double>(1, 1, 6)) == -30)
    }

    @Test func circlesAndSpheres() {
        let a = SIMD2<Float>(0, 0), b = SIMD2<Float>(1, 0), c = SIMD2<Float>(0, 1)
        #expect(simd_incircle(SIMD2<Float>(0.25, 0.25), a, b, c) == 0.375)
        #expect(simd_incircle(SIMD2<Float>(5, 5), a, b, c) == -40)
        let p = SIMD3<Float>(0, 0, 0), q = SIMD3<Float>(1, 0, 0), r = SIMD3<Float>(0, 1, 0), s = SIMD3<Float>(0, 0, 1)
        #expect(simd_insphere(SIMD3<Float>(0.25, 0.25, 0.25), p, q, r, s) == -0.5625)
        #expect(simd_insphere(SIMD3<Float>(5, 5, 5), p, q, r, s) == 60)
    }

    @Test func makeWidening() {
        #expect(simd_make_float4_undef(SIMD2<Float>(1, 2)) == SIMD4<Float>(1, 2, 0, 0))
        #expect(simd_make_float4(SIMD2<Float>(1, 2)) == SIMD4<Float>(1, 2, 0, 0))
        #expect(simd_make_float2(SIMD8<Float>(1, 2, 3, 4, 5, 6, 7, 8)) == SIMD2<Float>(1, 2))
        #expect(simd_make_uchar8(SIMD4<UInt8>(1, 2, 3, 4), SIMD4<UInt8>(5, 6, 7, 8)) == SIMD8<UInt8>(1, 2, 3, 4, 5, 6, 7, 8))
        #expect(simd_make_char64(Int8(7))[0] == 7)
        #expect(simd_make_char64(Int8(7))[63] == 0)
    }

    @Test func descriptions() {
        #expect(simd_float2x3(1).debugDescription == "simd_float2x3([[1.0, 0.0, 0.0], [0.0, 1.0, 0.0]])")
        #expect(simd_quatf(ix: 1, iy: 2, iz: 3, r: 4).debugDescription == "simd_quatf(real: 4.0, imag: SIMD3<Float>(1.0, 2.0, 3.0))")
        #expect(simd_quatd(ix: 1, iy: 2, iz: 3, r: 4).debugDescription == "simd_quatd(real: 4.0, imag: SIMD3<Double>(1.0, 2.0, 3.0))")
    }
}

@Suite("Quaternions at their edges")
struct QuaternionBehaviorTests {

    let z = SIMD3<Float>(0, 0, 1)

    func turn(_ angle: Float) -> simd_quatf { simd_quatf(angle: angle, axis: z) }

    @Test func notOfUnitLength() {
        let q = simd_quatf(ix: 0, iy: 0, iz: 2, r: 2)
        #expect(q.act(SIMD3<Float>(1, 0, 0)) == SIMD3<Float>(-7, 8, 0))
        #expect(simd_float3x3(q) == simd_float3x3(rows: [SIMD3<Float>(0, -8, 0), SIMD3<Float>(8, 0, 0), SIMD3<Float>(0, 0, 8)]))
        #expect(isClose(simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 0, 2)).vector, SIMD4<Float>(0, 0, 1.4142135, 0.7071068)))
        #expect(isClose(simd_quatf(from: SIMD3<Float>(2, 0, 0), to: SIMD3<Float>(0, 3, 0)).vector, SIMD4<Float>(0, 0, 1.6641004, 1.1094003)))
    }

    @Test func oppositeDirections() {
        let q = simd_quatf(from: SIMD3<Float>(1, 0, 0), to: SIMD3<Float>(-1, 0, 0))
        #expect(isClose(q.vector, SIMD4<Float>(0, 0, 1, 0)))
        #expect(isClose(q.act(SIMD3<Float>(1, 0, 0)), SIMD3<Float>(-1, 0, 0)))
    }

    @Test func angles() {
        #expect(isClose(simd_quatf(ix: 0, iy: 0, iz: 0, r: -1).angle, 2 * .pi))
        #expect(simd_quatf(ix: 0, iy: 0, iz: 0, r: 1).axis.x.isNaN)
    }

    @Test func halfTurnMatrices() {
        let rows: [[SIMD3<Float>]] = [
            [SIMD3(1, 0, 0), SIMD3(0, -1, 0), SIMD3(0, 0, -1)],
            [SIMD3(-1, 0, 0), SIMD3(0, 1, 0), SIMD3(0, 0, -1)],
            [SIMD3(-1, 0, 0), SIMD3(0, -1, 0), SIMD3(0, 0, 1)],
        ]
        let expected = [SIMD4<Float>(1, 0, 0, 0), SIMD4<Float>(0, 1, 0, 0), SIMD4<Float>(0, 0, 1, 0)]
        for (m, q) in zip(rows, expected) {
            #expect(isClose(simd_quatf(simd_float3x3(rows: m)).vector, q))
        }
        #expect(isClose(simd_quatf(simd_float3x3(diagonal: SIMD3<Float>(2, 2, 2))).real, 1.3228756))
    }

    @Test func expAndLog() {
        #expect(isClose(exp(simd_quatf(ix: 0, iy: 0, iz: .pi / 4, r: 0)).vector, SIMD4<Float>(0, 0, 0.70710677, 0.7071068)))
        #expect(isClose(log(simd_quatf(ix: 0, iy: 0, iz: 1, r: 1)).vector, SIMD4<Float>(0, 0, 0.7853981, 0.3465736)))
        let q = simd_quatf(ix: 0.1, iy: -0.2, iz: 0.3, r: 0.9)
        #expect(isClose(exp(log(q)).vector, q.vector))
    }

    @Test func curves() {
        let q0 = turn(0), q1 = turn(.pi / 2), q2 = turn(.pi), q3 = turn(3 * .pi / 2)
        #expect(isClose(simd_slerp_longest(q0, q1, 0.5).vector, SIMD4<Float>(0, 0, -0.9238795, 0.38268337)))
        #expect(isClose(simd_spline(q0, q1, q2, q3, 0.5).vector, SIMD4<Float>(0, 0, 0.9238795, 0.38268352)))
        #expect(isClose(simd_bezier(q0, q1, q2, q3, 0.5).vector, SIMD4<Float>(0, 0, 0.92387944, 0.38268343)))
        #expect(isSameRotation(simd_spline(q0, q1, q2, q3, 0), q1))
        #expect(isSameRotation(simd_spline(q0, q1, q2, q3, 1), q2))
        #expect(isSameRotation(simd_bezier(q0, q1, q2, q3, 0), q0))
        #expect(isSameRotation(simd_bezier(q0, q1, q2, q3, 1), q3))
    }

    @Test func arithmetic() {
        let q = turn(.pi / 3), r = turn(.pi / 6)
        #expect(isSameRotation(q / r, r))
        #expect(isClose((q * 2).vector, 2 * q.vector))
        #expect(isClose((q / 2).vector, q.vector / 2))
        #expect(isClose(((q + r) - r).vector, q.vector))
        #expect(isClose(simd_dot(q, q), 1))
        #expect(isClose(simd_matrix4x4(q) * SIMD4<Float>(1, 0, 0, 1), SIMD4<Float>(0.5, 0.8660254, 0, 1)))
        var m = q
        m *= r
        #expect(isSameRotation(m, turn(.pi / 2)))
        #expect(Set([q, q, r]).count == 2)
    }
}

@Suite("Matrices at their edges")
struct MatrixBehaviorTests {

    @Test func generalInverse() {
        let m = simd_float4x4(rows: [
            SIMD4<Float>(2, -1, 0, 3),
            SIMD4<Float>(1, 4, -2, 0),
            SIMD4<Float>(0, 3, 5, -1),
            SIMD4<Float>(-2, 0, 1, 6),
        ])
        #expect(simd_almost_equal_elements(m * m.inverse, matrix_identity_float4x4, 1e-5))
        #expect(simd_almost_equal_elements(m.inverse * m, matrix_identity_float4x4, 1e-5))
        #expect(isClose(m.determinant, 494, 1e-3))
        #expect(isClose(simd_determinant(m.transpose), 494, 1e-3))

        let d = simd_double4x4(rows: [
            SIMD4<Double>(2, -1, 0, 3),
            SIMD4<Double>(1, 4, -2, 0),
            SIMD4<Double>(0, 3, 5, -1),
            SIMD4<Double>(-2, 0, 1, 6),
        ])
        #expect(simd_almost_equal_elements(d * d.inverse, matrix_identity_double4x4, 1e-12))
        #expect(isClose(d.determinant, 494, 1e-9))
    }

    @Test func shapesMultiply() {
        // 4 columns of 3 rows times 2 columns of 4 rows: 2 columns of 3 rows.
        let a = simd_float4x3(rows: [SIMD4<Float>(1, 2, 3, 4), SIMD4<Float>(0, 1, 0, 1), SIMD4<Float>(2, 0, 2, 0)])
        let b = simd_float2x4(rows: [SIMD2<Float>(1, 0), SIMD2<Float>(0, 1), SIMD2<Float>(1, 1), SIMD2<Float>(2, 0)])
        let ab: simd_float2x3 = a * b
        #expect(ab == simd_float2x3(rows: [SIMD2<Float>(12, 5), SIMD2<Float>(2, 1), SIMD2<Float>(4, 2)]))
        #expect(simd_mul(a, b) == ab)
        #expect(a.transpose.transpose == a)
        #expect(SIMD3<Float>(1, 1, 1) * a == SIMD4<Float>(3, 3, 5, 5))
    }

    @Test func elements() {
        var m = simd_float3x3(1)
        m[2, 0] = 7
        m[1] = SIMD3<Float>(4, 5, 6)
        #expect(m.columns.2 == SIMD3<Float>(7, 0, 1))
        #expect(m[1] == SIMD3<Float>(4, 5, 6))
        #expect(simd_trace(m) == 7)
        #expect(simd_linear_combination(2, m, -1, m) == m)
        #expect(simd_almost_equal_elements_relative(m, m * 1.000001, 1e-5))
        #expect(!simd_almost_equal_elements_relative(m, m * 1.1, 1e-5))
        #expect(simd_diagonal_matrix(SIMD3<Float>(1, 2, 3)) == simd_float3x3(diagonal: SIMD3<Float>(1, 2, 3)))
        #expect(simd_matrix(SIMD2<Float>(1, 2), SIMD2<Float>(3, 4)) == simd_matrix_from_rows(SIMD2<Float>(1, 3), SIMD2<Float>(2, 4)))
        #expect(simd_float4x3(diagonal: SIMD3<Float>(1, 2, 3)).columns.3 == .zero)
    }

    @Test func singular() {
        let m = simd_float2x2(rows: [SIMD2<Float>(1, 2), SIMD2<Float>(2, 4)])
        #expect(m.determinant == 0)
        #expect(!m.inverse.columns.0.x.isFinite)
    }
}
