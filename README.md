# NucleantSIMD

Apple's `simd` API on every platform Swift runs on. On Apple platforms,
`import NucleantSIMD` is Apple's simd module. On Linux, Android, Windows,
WebAssembly and OpenBSD, where there is no simd module, it is the same API
written in Swift: `simd_float4x4`, `simd_quatf`, `matrix_identity_float4x4`,
`simd_dot`, `normalize`, `simd_slerp`, `sin` on vectors, and the rest.

```swift
.package(url: "https://github.com/NucleantUI/NucleantSIMD.git", .upToNextMinor(from: "0.0.0"))
```

```swift
.product(name: "NucleantSIMD", package: "NucleantSIMD")
```

## Use

```swift
import NucleantSIMD

let turn = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 0, 1))
var model = simd_float4x4(turn)
model.columns.3 = SIMD4<Float>(1, 2, 3, 1)

let point = model * SIMD4<Float>(1, 0, 0, 1)   // (1, 3, 3, 1)
let facing = normalize(cross(SIMD3<Float>(1, 0, 0), turn.act(SIMD3<Float>(1, 0, 0))))
```

The same code builds everywhere, with no `#if canImport(simd)`.

## What's in it

Apple's simd API for Swift, with the same names and signatures:

- Vector functions: elementwise math (`sin`, `exp2`, `sinpi`, ...),
  `simd_clamp`, `mix`, `smoothstep`, the reductions, geometry (`dot`,
  `cross`, `length`, `reflect`, `refract`, `simd_orient`, `simd_incircle`,
  ...), masks and selects, every `simd_int`/`simd_float`/... conversion with
  its `_sat` and `_rte` forms, and every `simd_make_*`.
- The 18 matrix types, `simd_float2x2` to `simd_double4x4`, with their
  initializers, operators, `transpose`, `inverse` and `determinant`, and the
  `simd_mul`/`matrix_*` functions.
- `simd_quatf` and `simd_quatd`, with `slerp`, `spline` and `bezier`.
- The type names: `simd_float4`, `vector_float4`, `simd_packed_float4`,
  `float4x4`, `matrix_float4x4`, ...

The tests hold the results to Apple's, NaN and saturating conversions
included. The types have Apple's memory layout (a `simd_float3x3` is three
16-byte columns), so they go to the GPU as they are.

Not included: the half-precision types (`simd_half4`, `simd_quath`).

## How it is built

| Target | What it is |
|---|---|
| `NucleantSIMD` | What you import. Re-exports `simd` on Apple platforms and `NucleantSIMDPortable` on the others. |
| `NucleantSIMDPortable` | The simd API in Swift. Only built for platforms without simd: an Apple app never compiles or links it. |

`NucleantSIMDPortable` is written once, generically, in its kernel files.
The thousands of per-type overloads in `Generated/` that call them come from
`Scripts/generate.py`. Its math (`sin`, `acos`, ...) comes from the
platform's C library, so the `Float` versions are there on Android too.

The tests check every result through `import NucleantSIMD`: against Apple's
simd on macOS, and against NucleantSIMDPortable on Linux and WebAssembly,
with the same expected values.

## License

MIT, see [LICENSE](LICENSE).
