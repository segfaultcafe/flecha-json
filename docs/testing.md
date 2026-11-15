# JSON stress and adversarial tests

Run the complete library suite from the package root:

```sh
longbow test . --verbose
```

Use the Flecha 0.4 development compiler with owned-slice type patterns,
reflection-loop `break`/`proceed`, and recursive owning-type analysis support.
When testing a compiler build explicitly:

```sh
FLECHA_COMPILER=/path/to/flecha longbow test . --verbose
```

The tests are ordinary Flecha unit tests under `src/`, with no network,
external corpus, timing threshold, or nondeterministic seed. They complement
`reader_test.fl`, `writer_test.fl`, and the behavior/owned-array tests.

## Coverage

- `json_stress_test.fl`: 21 array sizes from 0 through 4,097, including both
  sides of growth boundaries; repeated growth/shrink/empty replacements;
  recursive owning trees through depth 64; deeply nested unknown mixed
  containers; 2,048 unknown properties and an 8,192-byte key; long Unicode
  and escaped strings; all supported numeric/boolean owned-array element
  types; 64 seeded mixed-document trials; and ragged three-dimensional arrays.
- `json_corpus_test.fl`: 30 independently written valid documents and 73
  malformed documents, checked through both reader traversal and raw writer
  validation. Includes grammar boundaries, duplicate keys, whitespace,
  numeric syntax, escapes, surrogate pairs, and invalid container states.
- `json_adversarial_test.fl`: every truncated prefix of a nested document;
  raw NUL and invalid UTF-8 insertion at every byte offset; numeric overflow
  and type mismatches; null rejection; escaped duplicate-key replacement;
  failed replacement at eight array growth boundaries and recursive depths through 64; decoded strings
  outliving the source buffer; malformed unknown values; and missing fields.

The seeded generator starts at 1729 and uses
`state = (state * 25173 + 13849) % 65521`. It produces 0–16 documents per
trial and 0–66 numeric elements per document. Expected element values are
computed independently of JSON encoding/decoding. Explicit input fixtures
and exact output checks complement roundtrip assertions so matching reader
and writer mistakes do not become the only oracle.

## Scope

“Elastic” here means correctness across changing container sizes, including
replacing an existing owner with larger, smaller, or empty input. These are
bounded regression tests, not throughput benchmarks or an unbounded fuzzer.
They exercise owned arrays as structure fields; they do not assume that a
root `json::from<own []E>` API exists.

A failed array-field decode must preserve its previous owner. This does not
promise transactionality for an entire object: fields processed earlier may
already have changed. The tests verify value/lifetime behavior; a passing
unit suite alone is not proof of leak freedom under allocation failure.
