import NucleantSIMD
import Testing

/// Elementwise math: the Float overloads of these come from the C math
/// library, which on Android isn't reachable through Foundation alone.
@Suite("Elementwise math")
struct MathTests {

    let quarterTurns = SIMD4<Float>(0, .pi / 2, .pi, 3 * .pi / 2)

    @Test func trigonometry() {
        #expect(isClose(sin(quarterTurns), SIMD4<Float>(0, 1, 0, -1)))
        #expect(isClose(cos(quarterTurns), SIMD4<Float>(1, 0, -1, 0)))
        #expect(isClose(tan(SIMD2<Float>(0, .pi / 4)), SIMD2<Float>(0, 1)))
        #expect(isClose(asin(SIMD2<Float>(0, 1)), SIMD2<Float>(0, .pi / 2)))
        #expect(isClose(acos(SIMD2<Float>(1, 0)), SIMD2<Float>(0, .pi / 2)))
        #expect(isClose(atan(SIMD2<Float>(0, 1)), SIMD2<Float>(0, .pi / 4)))
        // atan2(y, x)
        #expect(isClose(atan2(SIMD2<Float>(1, 1), SIMD2<Float>(1, -1)), SIMD2<Float>(.pi / 4, 3 * .pi / 4)))
        #expect(isClose(sin(SIMD4<Double>(0, .pi / 2, .pi, 3 * .pi / 2)), SIMD4<Double>(0, 1, 0, -1)))
    }

    @Test func hyperbolic() {
        let x = SIMD4<Float>(0, 1, -1, 20)
        #expect(isClose(sinh(SIMD3<Float>(0, 1, -1)), SIMD3<Float>(0, 1.1752012, -1.1752012)))
        #expect(isClose(cosh(SIMD3<Float>(0, 1, -1)), SIMD3<Float>(1, 1.5430806, 1.5430806)))
        #expect(isClose(tanh(x), SIMD4<Float>(0, 0.7615942, -0.7615942, 1)))
        #expect(isClose(tanh(SIMD2<Double>(0, 1)), SIMD2<Double>(0, 0.7615941559557649)))
    }

    @Test func exponentsAndLogarithms() {
        #expect(isClose(exp(SIMD2<Float>(0, 1)), SIMD2<Float>(1, 2.7182817)))
        #expect(isClose(exp2(SIMD4<Float>(0, 1, 3, -1)), SIMD4<Float>(1, 2, 8, 0.5)))
        #expect(isClose(exp10(SIMD3<Float>(0, 1, 2)), SIMD3<Float>(1, 10, 100), 1e-4))
        #expect(isClose(log(SIMD2<Float>(1, 2.7182817)), SIMD2<Float>(0, 1)))
        #expect(isClose(log2(SIMD4<Float>(1, 2, 8, 0.5)), SIMD4<Float>(0, 1, 3, -1)))
        #expect(isClose(log10(SIMD3<Float>(1, 10, 100)), SIMD3<Float>(0, 1, 2)))
        #expect(isClose(pow(SIMD3<Float>(2, 3, 4), SIMD3<Float>(3, 2, 0.5)), SIMD3<Float>(8, 9, 2)))
        #expect(isClose(cbrt(SIMD3<Float>(0, 8, -27)), SIMD3<Float>(0, 2, -3)))
        #expect(isClose(exp2(SIMD2<Double>(10, -2)), SIMD2<Double>(1024, 0.25)))
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @Test func timesPi() {
        let x = SIMD4<Float>(0, 0.5, 1, 1.5)
        #expect(isClose(sinpi(x), SIMD4<Float>(0, 1, 0, -1)))
        #expect(isClose(cospi(x), SIMD4<Float>(1, 0, -1, 0)))
        #expect(isClose(tanpi(SIMD2<Float>(0, 0.25)), SIMD2<Float>(0, 1)))
    }

    @Test func wideVectors() {
        let x = SIMD8<Float>(repeating: .pi / 2)
        #expect(isClose(sin(x), SIMD8<Float>(repeating: 1)))
        let y = SIMD16<Float>(repeating: 3)
        #expect(isClose(log2(exp2(y)), y))
    }
}
