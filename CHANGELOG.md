# Changelog

## 0.2.0 - 2026-11-15

- Move `@json` structure serialization and deserialization from compiler-owned
  generation to library-defined `JsonWritable` and `JsonReadable` behaviors.
- Add recursive owned-sequence support and deterministic stress, grammar-corpus,
  and adversarial coverage.
- Require Flecha `>=0.4.0, <0.5.0` and validate against the pinned 0.4 toolchain.

## 0.1.2 - 2026-11-07

- Add `Writer::writeRaw()` for embedding one pre-serialized JSON value after
  strict syntax and trailing-data validation.

## 0.1.1 - 2026-11-05

- Correct the generated-structure README example to use Flecha's built-in
  `stdoutln` function.
- Compile and execute the actual README Flecha code block in CI so published
  examples cannot silently drift from the supported API.
- Preserve the 0.1 public API and Flecha compatibility range; this patch has no
  runtime or serialization behavior changes.

## 0.1.0 - 2026-11-05

- Publish the initial compiler-integrated `@json` protocol, streaming reader,
  streaming writer, strict validation, and Unicode handling for Flecha 0.3.
