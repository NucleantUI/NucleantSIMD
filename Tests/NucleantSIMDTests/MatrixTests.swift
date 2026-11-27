import NucleantSIMD
import Testing

@Suite("Matrices")
struct MatrixTests {

    /// Rows (1 2) and (3 4).
    let m = simd_float2x2(rows: [SIMD2<Float>(1, 2), SIMD2<Float>(3, 4)])

    @Test func identity() {
        let v = SIMD4<Float>(1, 2, 3, 4)
        #expect(matrix_identity_float4x4 * v == v)
        #expect(matrix_identity_float4x4 == simd_float4x4(diagonal: SIMD4<Float>(repeating: 1)))
        #expect(matrix_identity_float3x3 == simd_float3x3(1))
        #expect(matrix_identity_double2x2 == simd_double2x2(1))
    }

    @Test func rowsAndColumns() {
        #expect(m.columns.0 == SIMD2<Float>(1, 3))
        #expect(m.columns.1 == SIMD2<Float>(2, 4))
        #expect(m[1][0] == 2)
        #expect(m == simd_float2x2(columns: (SIMD2<Float>(1, 3), SIMD2<Float>(2, 4))))
        #expect(m == simd_float2x2([SIMD2<Float>(1, 3), SIMD2<Float>(2, 4)]))
        #expect(m.transpose == simd_float2x2(rows: [SIMD2<Float>(1, 3), SIMD2<Float>(2, 4)]))
        #expect(simd_transpose(m) == m.transpose)
    }

    @Test func multiplication() {
        let other = simd_float2x2(rows: [SIMD2<Float>(5, 6), SIMD2<Float>(7, 8)])
        #expect(m * other == simd_float2x2(rows: [SIMD2<Float>(19, 22), SIMD2<Float>(43, 50)]))
        #expect(simd_mul(m, other) == m * other)
        #expect(matrix_multiply(m, other) == m * other)
        #expect(m * SIMD2<Float>(1, 1) == SIMD2<Float>(3, 7))
        #expect(SIMD2<Float>(1, 1) * m == SIMD2<Float>(4, 6))
        #expect(2 * m == simd_float2x2(rows: [SIMD2<Float>(2, 4), SIMD2<Float>(6, 8)]))
        #expect(m + m == 2 * m)
        #expect(m - m == simd_float2x2())
    }

    @Test func nonSquare() {
        // Three columns of two rows: maps SIMD3 to SIMD2.
        let a = simd_float3x2(columns: (SIMD2<Float>(1, 0), SIMD2<Float>(0, 1), SIMD2<Float>(1, 1)))
        #expect(a * SIMD3<Float>(1, 2, 3) == SIMD2<Float>(4, 5))
        // Its transpose has two columns of three rows.
        #expect(a.transpose == simd_float2x3(rows: [SIMD2<Float>(1, 0), SIMD2<Float>(0, 1), SIMD2<Float>(1, 1)]))
        #expect(a * a.transpose == simd_float2x2(rows: [SIMD2<Float>(2, 1), SIMD2<Float>(1, 2)]))
    }

    @Test func determinantAndInverse() {
        #expect(m.determinant == -2)
        #expect(simd_determinant(m) == -2)
        let n = simd_float3x3(rows: [SIMD3<Float>(2, 0, 1), SIMD3<Float>(1, 3, 2), SIMD3<Float>(1, 1, 2)])
        #expect(isClose(n.determinant, 6))
        #expect(simd_almost_equal_elements(n * n.inverse, matrix_identity_float3x3, 1e-5))
        #expect(simd_almost_equal_elements(simd_inverse(m), simd_float2x2(rows: [SIMD2<Float>(-2, 1), SIMD2<Float>(1.5, -0.5)]), 1e-6))

        let d = simd_double3x3(rows: [SIMD3<Double>(2, 0, 1), SIMD3<Double>(1, 3, 2), SIMD3<Double>(1, 1, 2)])
        #expect(isClose(d.determinant, 6))
        #expect(simd_almost_equal_elements(d.inverse * d, matrix_identity_double3x3, 1e-12))
    }

    @Test func transforms() {
        var translation = matrix_identity_float4x4
        translation.columns.3 = SIMD4<Float>(1, 2, 3, 1)
        #expect(translation * SIMD4<Float>(0, 0, 0, 1) == SIMD4<Float>(1, 2, 3, 1))
        #expect(translation * SIMD4<Float>(1, 0, 0, 0) == SIMD4<Float>(1, 0, 0, 0))

        var back = matrix_identity_float4x4
        back.columns.3 = SIMD4<Float>(-1, -2, -3, 1)
        #expect(simd_almost_equal_elements(translation.inverse, back, 1e-6))

        let scale = simd_float4x4(diagonal: SIMD4<Float>(2, 3, 4, 1))
        #expect((translation * scale) * SIMD4<Float>(1, 1, 1, 1) == SIMD4<Float>(3, 5, 7, 1))
        #expect(simd_almost_equal_elements((translation * scale).inverse * (translation * scale), matrix_identity_float4x4, 1e-6))
    }

    /// The layout a GPU reads: columns of 16 bytes for 3- and 4-wide floats.
    @Test func memoryLayout() {
        #expect(MemoryLayout<simd_float4x4>.size == 64)
        #expect(MemoryLayout<simd_float3x3>.size == 48)
        #expect(MemoryLayout<simd_float2x2>.size == 16)
        #expect(MemoryLayout<simd_double4x4>.size == 128)
        #expect(MemoryLayout<SIMD3<Float>>.stride == 16)
        #expect(MemoryLayout<simd_quatf>.size == 16)
        #expect(MemoryLayout<simd_quatd>.size == 32)
    }
}
