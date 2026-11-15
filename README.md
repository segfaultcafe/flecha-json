# Flecha JSON

`flecha/json` is the JSON library for Flecha. It provides:

- library-defined `@json` behaviors for structure serialization and deserialization;
- a streaming writer for objects, arrays, strings, numbers, booleans, and null;
- a streaming reader with nested traversal, unknown-value skipping, and strict
  JSON validation; and
- UTF-8 validation, JSON string escaping, Unicode escape decoding, and checked
  numeric conversion.

Version `0.2.0` requires Flecha `>=0.4.0, <0.5.0`, including support for
reflection inside runtime loops, managed interface returns, and owned-slice
type patterns.

## Install

Add the immutable public package with Longbow 0.4:

```sh
longbow add flecha/json@^0.2 --as json
```

Or declare it directly:

```toml
[dependencies]
json = { package = "flecha/json", version = "^0.2" }
```

The dependency alias (`json` above) controls the import path:

```flecha
@imports
    :: lib::json::json;
```

## Decorated structures

`@json(structure)` derives `JsonWritable` and `JsonReadable`. Serialize with
`value.json()` and deserialize with `json::from<T>(bytes)`. Public
fields are included by default; private fields are omitted. A field decoration
overrides its JSON name.

<!-- checked-example:start -->
```flecha
module example;

@imports
    :: lib::json::json;

@json(structure)
structure User {
    @json("display_name") string displayName;
    bool active;
    private string accessToken;
};

void main() {
    user := User::init();
    user.displayName = "Ada";
    user.active = true;

    encoded, writeError := user.json();
    if writeError == none {
        stdoutln(encoded[:].cast<stringv>);
    }

    decoded, readError := json::from<User>(encoded[:]);
    if readError == none {
        stdoutln(decoded.displayName);
    }
}
```
<!-- checked-example:end -->

The encoded document is:

```json
{"display_name":"Ada","active":true}
```

## Streaming writer

`Writer` emits compact JSON and returns the first error encountered. A complete
document must contain exactly one root value and every opened container must be
closed before `finish()`.

```flecha
writer := json::Writer::init();
err := writer.beginObject();
if err == none { err = writer.key("answer"); }
if err == none { err = writer.write(42); }
if err == none { err = writer.endObject(); }

document, finishError := writer.finish();
```

Supported scalar overloads cover `bool`, all Flecha integer types, `f32`,
`f64`, `stringv`, and `string`; `writeNull()` writes JSON null. Non-finite
floating-point values are rejected because JSON cannot represent them.
`writeRaw()` embeds one already serialized JSON value after validating the
complete input, including nested syntax and trailing data.

## Streaming reader

`Reader` borrows the source bytes. Object keys can be matched without allocating,
and unknown values can be skipped recursively.

```flecha
reader := json::Reader::init(
    "{\"answer\":42,\"ignored\":[true,null]}".cast<[]const u8>
);

err := reader.beginObject();
bool more = false;
i32 answer = none;
if err == none { more, err = reader.nextObjectField(); }
while err == none and more {
    if reader.keyIs("answer") {
        err = reader.read(&answer);
    } else {
        err = reader.skipValue();
    }
    if err == none { more, err = reader.nextObjectField(); }
}
if err == none { err = reader.finish(); }
```

Use `beginArray()` / `nextArrayElement()` for arrays, `readNull()` for null,
`read()` for booleans and numeric types, and `readString()` for an owned decoded
string. `finish()` rejects trailing data and incomplete documents.

## Errors

Library-specific failures use `JsonError`:

- `InvalidState` and `IncompleteDocument` for invalid API transitions;
- `InvalidSyntax`, `UnexpectedEnd`, and `TrailingData` for malformed documents;
- `TypeMismatch` and `NumberOutOfRange` for incompatible target types; and
- `NonFiniteNumber` for unsupported floating-point output.

Allocation and UTF-8 errors from the standard library may also be returned.

## Development

Use the Flecha 0.4 toolchain to validate the package:

```sh
longbow check
longbow test --verbose
longbow publish --dry-run
git diff --check
```

The source archive produced by `publish --dry-run` is deterministic. Published
`owner/package/version` tuples are immutable, so release `0.2.0` is published
only after the dry-run checksum and a clean consumer build have been verified.

## License

MIT. See [LICENSE](LICENSE).

## 0.2 status

The behavior supports scalar fields and nested structures, public-field selection,
explicit field names, private-field omission, and compile-time rejection of
private annotations and duplicate selected names. `JsonReadable` requires only
`readJson`; handwritten implementations need no reflection helper. The generated
reader skips unknown properties and propagates parsing errors.

Owned sequence fields (`own []T`) compose recursively with scalars, strings,
and derived structures. Failed sequence decoding preserves the previous owner.
The streaming array API continues to work independently of owned sequence
derivation.

## Stress testing

Run `longbow test . --verbose` for the complete suite, including deterministic
growth/shrink, recursive, Unicode, grammar-corpus, and malformed-input tests.
See [test coverage and bounds](docs/testing.md) for details.
