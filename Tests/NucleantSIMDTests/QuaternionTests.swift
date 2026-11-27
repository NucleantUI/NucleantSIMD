import NucleantSIMD
import Testing

@Suite("Quaternions")
struct QuaternionTests {

    let x = SIMD3<Float>(1, 0, 0), y = SIMD3<Float>(0, 1, 0), z = SIMD3<Float>(0, 0, 1)

    /// A quarter turn around z.
    var quarter: simd_quatf { simd_quatf(angle: .pi / 2, axis: z) }

    @Test func rotation() {
        #expect(isClose(quarter.act(x), y))
        #expect(isClose(simd_act(quarter, y), -x))
        #expect(isClose(quarter.angle, .pi / 2))
        #expect(isClose(quarter.axis, z))
        #expect(isClose((quarter * quarter).act(x), -x))
        #expect(isClose(quarter.inverse.act(quarter.act(SIMD3<Float>(1, 2, 3))), SIMD3<Float>(1, 2, 3)))
        #expect(isSameRotation(quarter.conjugate, quarter.inverse))
    }

    @Test func parts() {
        let q = simd_quatf(ix: 1, iy: 2, iz: 3, r: 4)
        #expect(q.real == 4)
        #expect(q.imag == SIMD3<Float>(1, 2, 3))
        #expect(q.vector == SIMD4<Float>(1, 2, 3, 4))
        #expect(q == simd_quatf(real: 4, imag: SIMD3<Float>(1, 2, 3)))
        #expect(q == simd_quatf(vector: SIMD4<Float>(1, 2, 3, 4)))
        #expect(isClose(simd_quatf(ix: 0, iy: 0, iz: 0, r: 2).normalized.vector, SIMD4<Float>(0, 0, 0, 1)))
        #expect(isClose(simd_quatf(ix: 0, iy: 3, iz: 0, r: 4).length, 5))
    }

    @Test func fromTo() {
        #expect(isClose(simd_quatf(from: x, to: y).act(x), y))
        #expect(isSameRotation(simd_quatf(from: x, to: y), quarter))
        #expect(isClose(simd_quatf(from: y, to: z).act(y), z))
    }

    @Test func matrices() {
        let r3 = simd_float3x3(quarter)
        #expect(isClose(r3 * x, y))
        #expect(isSameRotation(simd_quatf(r3), quarter))

        let r4 = simd_float4x4(quarter)
        #expect(isClose(r4 * SIMD4<Float>(1, 0, 0, 0), SIMD4<Float>(0, 1, 0, 0)))
        #expect(isClose(r4 * SIMD4<Float>(0, 0, 0, 1), SIMD4<Float>(0, 0, 0, 1)))
        #expect(isSameRotation(simd_quatf(r4), quarter))
    }

    @Test func interpolation() {
        let identity = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        let half = simd_slerp(identity, quarter, 0.5)
        #expect(isClose(half.angle, .pi / 4))
        #expect(isClose(half.axis, z))
        #expect(isSameRotation(simd_slerp(identity, quarter, 1), quarter))
    }

    @Test func doublePrecision() {
        let q = simd_quatd(angle: .pi / 2, axis: SIMD3<Double>(0, 0, 1))
        #expect(isClose(q.act(SIMD3<Double>(1, 0, 0)), SIMD3<Double>(0, 1, 0)))
        #expect(isClose(simd_double3x3(q) * SIMD3<Double>(0, 1, 0), SIMD3<Double>(-1, 0, 0)))
        #expect(isClose(q.angle, .pi / 2))
    }
}
