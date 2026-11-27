// Linux, Android, Windows, WebAssembly and the rest: no simd module, so
// NucleantSIMD is the same API written in Swift.
#if !canImport(simd)

@_exported import NucleantSIMDPortable

#endif
