import NucleantSIMD
import Testing

@Suite("Conversions")
struct ConversionTests {

    @Test func integerToFloat() {
        #expect(simd_float(SIMD4<Int32>(1, -2, 3, -4)) == SIMD4<Float>(1, -2, 3, -4))
        #expect(simd_double(SIMD4<Int32>(1, -2, 3, -4)) == SIMD4<Double>(1, -2, 3, -4))
        #expect(simd_double(SIMD3<Float>(0.5, -1, 2)) == SIMD3<Double>(0.5, -1, 2))
    }

    @Test func floatToInteger() {
        // Toward zero, like a C cast.
        #expect(simd_int(SIMD4<Float>(1.9, -1.9, 2.5, -2.5)) == SIMD4<Int32>(1, -1, 2, -2))
        // To nearest, ties to even.
        #expect(simd_int_rte(SIMD4<Float>(1.9, -1.9, 2.5, -2.5)) == SIMD4<Int32>(2, -2, 2, -2))
        #expect(simd_int_sat(SIMD2<Float>(1e10, -1e10)) == SIMD2<Int32>(.max, .min))
        #expect(simd_uchar_sat(SIMD4<Float>(-5, 0, 100, 300)) == SIMD4<UInt8>(0, 0, 100, 255))
        #expect(simd_short_sat(SIMD2<Int32>(40_000, -40_000)) == SIMD2<Int16>(.max, .min))
    }

    @Test func narrowing() {
        #expect(simd_uchar(SIMD4<Int32>(1, 2, 255, 256)) == SIMD4<UInt8>(1, 2, 255, 0))
        #expect(simd_char(SIMD2<Int32>(127, 128)) == SIMD2<Int8>(127, -128))
        #expect(simd_float(SIMD2<Double>(0.25, -8)) == SIMD2<Float>(0.25, -8))
    }
}
