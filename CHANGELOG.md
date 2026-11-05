# Changelog

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
