# swift-migemo

Swift wrapper for [C/Migemo](https://github.com/koron/cmigemo).

This package provides:
- Romanized query expansion to Migemo regular-expression patterns.
- Optional compilation to Swift `Regex`.
- Bundled UTF-8 dictionary files, so users can start without external setup.

## Installation

```swift
// Package.swift
.dependencies: [
    .package(url: "https://github.com/ainame/swift-migemo", from: "0.1.0")
],
.targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Migemo", package: "swift-migemo")
        ]
    )
]
```

## Usage

```swift
import Migemo

let migemo = try Migemo() // Uses bundled dictionary by default
let pattern = try migemo.regexPattern(for: "kensaku")
let regex = try migemo.regex(for: "kensaku")
```

Use your own dictionary directory:

```swift
import Foundation
import Migemo

let directory = URL(fileURLWithPath: "/path/to/migemo-dict-directory")
let migemo = try Migemo(options: .init(dictionary: .directory(directory)))
```

The directory must contain these files:
- `migemo-dict`
- `roma2hira.dat`
- `hira2kata.dat`
- `han2zen.dat`
- `zen2han.dat`

## API

- `Migemo.init(options:)`
- `Migemo.init(dictionaryPath:)`
- `Migemo.regexPattern(for:) -> String`
- `Migemo.regex(for:) -> Regex<AnyRegexOutput>`

Errors are exposed via `MigemoError`.

## Dictionary and Licensing

- Repository license summary is in `LICENSE`.
- Project MIT license is in `LICENSE-MIT`.
- Third-party attribution is in `THIRD_PARTY_NOTICES.md`.
- C/Migemo upstream source is vendored under `Sources/CMigemoC` (MIT): `Vendor/cmigemo/LICENSE_MIT.txt`.
- Bundled dictionary files are derived from SKK `SKK-JISYO.L` and are documented with GPL notices:
  - `Vendor/cmigemo/DICTIONARY_SOURCE.md`
  - `Vendor/skk/SKK-JISYO.L.HEADER.txt`
  - `Vendor/skk/COPYING`

## Development

```sh
swift build
swift test
```

## Notes

- Repository/package identity is `swift-migemo`.
- Swift module/import name is `Migemo`.
