import NucleantSIMD
import Testing

@Suite("Vectors")
struct VectorTests {

    @Test func dotAndCross() {
        let a = SIMD3<Float>(1, 2, 3), b = SIMD3<Float>(4, 5, 6)
        #expect(dot(a, b) == 32)
        #expect(simd_dot(a, b) == 32)
        #expect(cross(a, b) == SIMD3<Float>(-3, 6, -3))
        #expect(simd_cross(SIMD3<Float>(1, 0, 0), SIMD3<Float>(0, 1, 0)) == SIMD3<Float>(0, 0, 1))
        #expect(dot(SIMD4<Double>(1, 2, 3, 4), SIMD4<Double>(1, 1, 1, 1)) == 10)
    }

    @Test func lengthAndDistance() {
        #expect(length(SIMD2<Float>(3, 4)) == 5)
        #expect(simd_length(SIMD2<Double>(3, 4)) == 5)
        #expect(length_squared(SIMD2<Float>(3, 4)) == 25)
        #expect(distance(SIMD2<Float>(1, 1), SIMD2<Float>(4, 5)) == 5)
        #expect(distance_squared(SIMD2<Float>(1, 1), SIMD2<Float>(4, 5)) == 25)
        #expect(isClose(normalize(SIMD3<Float>(0, 3, 4)), SIMD3<Float>(0, 0.6, 0.8)))
        #expect(isClose(simd_normalize(SIMD3<Double>(0, 3, 4)), SIMD3<Double>(0, 0.6, 0.8)))
    }

    @Test func interpolation() {
        let from = SIMD4<Float>(0, 0, 0, 0), to = SIMD4<Float>(10, 20, 30, 40)
        #expect(mix(from, to, t: 0.25) == SIMD4<Float>(2.5, 5, 7.5, 10))
        #expect(simd_mix(from, to, SIMD4<Float>(0, 0.5, 1, 0.5)) == SIMD4<Float>(0, 10, 30, 20))

        let x = SIMD4<Float>(0.1, 0.5, 0.9, 0.25)
        #expect(step(x, edge: SIMD4<Float>(repeating: 0.5)) == SIMD4<Float>(0, 1, 1, 0))
        #expect(isClose(
            smoothstep(x, edge0: SIMD4<Float>(repeating: 0), edge1: SIMD4<Float>(repeating: 1)),
            SIMD4<Float>(0.028, 0.5, 0.972, 0.15625)
        ))
    }

    @Test func clampMinMax() {
        let x = SIMD4<Float>(-1, 0.5, 2, 1)
        #expect(clamp(x, min: 0, max: 1) == SIMD4<Float>(0, 0.5, 1, 1))
        #expect(simd_clamp(SIMD4<Int32>(-5, 0, 5, 10), SIMD4<Int32>(repeating: 0), SIMD4<Int32>(repeating: 6)) == SIMD4<Int32>(0, 0, 5, 6))
        #expect(min(SIMD3<Float>(1, 5, 3), SIMD3<Float>(4, 2, 6)) == SIMD3<Float>(1, 2, 3))
        #expect(max(SIMD3<Float>(1, 5, 3), SIMD3<Float>(4, 2, 6)) == SIMD3<Float>(4, 5, 6))
        #expect(simd_min(SIMD4<Int32>(1, -5, 3, 0), SIMD4<Int32>(0, 2, 6, 0)) == SIMD4<Int32>(0, -5, 3, 0))
    }

    @Test func absSignFract() {
        #expect(abs(SIMD4<Float>(-1, 2, -3, 0)) == SIMD4<Float>(1, 2, 3, 0))
        #expect(simd_abs(SIMD4<Int32>(-1, 2, -3, 0)) == SIMD4<Int32>(1, 2, 3, 0))
        #expect(sign(SIMD4<Float>(-2, 0, 3, -0.5)) == SIMD4<Float>(-1, 0, 1, -1))
        #expect(fract(SIMD2<Float>(1.25, -0.75)) == SIMD2<Float>(0.25, 0.25))
        #expect(floor(SIMD4<Float>(1.5, -1.5, 2, -0.25)) == SIMD4<Float>(1, -2, 2, -1))
        #expect(ceil(SIMD4<Float>(1.5, -1.5, 2, -0.25)) == SIMD4<Float>(2, -1, 2, 0))
        #expect(trunc(SIMD4<Float>(1.5, -1.5, 2, -0.25)) == SIMD4<Float>(1, -1, 2, 0))
    }

    @Test func reductions() {
        let x = SIMD4<Float>(3, 1, 4, 2)
        #expect(reduce_add(x) == 10)
        #expect(simd_reduce_add(x) == 10)
        #expect(reduce_min(x) == 1)
        #expect(reduce_max(x) == 4)
        #expect(simd_reduce_add(SIMD4<Int32>(1, 2, 3, 4)) == 10)
    }

    @Test func masks() {
        #expect(simd_any(SIMD4<Int32>(0, 0, -1, 0)))
        #expect(!simd_any(SIMD4<Int32>(0, 1, 2, 3)))
        #expect(simd_all(SIMD4<Int32>(-1, -1, -1, -1)))
        #expect(!simd_all(SIMD4<Int32>(-1, -1, 0, -1)))
        #expect(simd_select(SIMD4<Float>(repeating: 1), SIMD4<Float>(repeating: 2), SIMD4<Int32>(0, -1, 0, -1)) == SIMD4<Float>(1, 2, 1, 2))
        #expect(simd_bitselect(SIMD4<Int32>(repeating: 0), SIMD4<Int32>(repeating: 0xFF), SIMD4<Int32>(0x0F, 0, 0xF0, -1)) == SIMD4<Int32>(0x0F, 0, 0xF0, 0xFF))
    }

    @Test func geometry() {
        #expect(simd_reflect(SIMD3<Float>(1, -1, 0), SIMD3<Float>(0, 1, 0)) == SIMD3<Float>(1, 1, 0))
        #expect(isClose(simd_project(SIMD3<Float>(2, 3, 0), SIMD3<Float>(1, 0, 0)), SIMD3<Float>(2, 0, 0)))
        #expect(isClose(rsqrt(SIMD4<Float>(1, 4, 16, 0.25)), SIMD4<Float>(1, 0.5, 0.25, 2), 1e-3))
        #expect(isClose(simd_precise_rsqrt(SIMD4<Float>(1, 4, 16, 0.25)), SIMD4<Float>(1, 0.5, 0.25, 2)))
        #expect(isClose(recip(SIMD4<Float>(1, 2, 4, 0.5)), SIMD4<Float>(1, 0.5, 0.25, 2), 1e-3))
    }

    @Test func makeFromParts() {
        #expect(simd_make_float4(SIMD3<Float>(1, 2, 3), 4) == SIMD4<Float>(1, 2, 3, 4))
        #expect(simd_make_float4(SIMD2<Float>(1, 2), SIMD2<Float>(3, 4)) == SIMD4<Float>(1, 2, 3, 4))
        #expect(simd_make_float3(SIMD4<Float>(1, 2, 3, 4)) == SIMD3<Float>(1, 2, 3))
        #expect(simd_make_int2(7, 8) == SIMD2<Int32>(7, 8))
        #expect(simd_make_double3(1, SIMD2<Double>(2, 3)) == SIMD3<Double>(1, 2, 3))
    }

    @Test func typeNames() {
        #expect(simd_float4.self == SIMD4<Float>.self)
        #expect(vector_float3.self == SIMD3<Float>.self)
        #expect(simd_double2.self == SIMD2<Double>.self)
        #expect(simd_int4.self == SIMD4<Int32>.self)
        #expect(simd_uchar16.self == SIMD16<UInt8>.self)
        #expect(simd_packed_float4.self == SIMD4<Float>.self)
    }
}
