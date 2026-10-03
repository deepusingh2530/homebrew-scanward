# homebrew-scanward

Homebrew tap for [scanward](https://github.com/deepusingh2530/scanward) — a
fast, fully-offline multi-language SAST scanner.

```sh
brew tap deepusingh2530/scanward
brew install scanward
scanward-corpus scan .
```

## Why a tap and not homebrew/core

`homebrew/core` requires a licence compatible with the Debian Free Software
Guidelines (an OSI-approved licence). scanward is licensed under
**PolyForm Noncommercial 1.0.0**, which is not OSI-approved, so core will not
accept it. A tap imposes no licence requirement. See
[docs/licensing.md](https://github.com/deepusingh2530/scanward/blob/main/docs/licensing.md).

## What you get

The release tarball carries the binary, the rule corpus, and a
`scanward-corpus` wrapper that points the scanner at that corpus:

```sh
scanward-corpus scan .          # scan with the installed corpus
scanward scan . --rules <path>  # or point at your own
scanward-corpus rule test       # 1251 rules, 2288 fixtures
```

Platforms: Apple Silicon and Linux x86-64/aarch64 use the published binaries.
Intel macOS has no published binary, so Homebrew builds from the source tarball
there (Rust 1.90+ required, and the corpus is not installed by that build —
clone the repository if you need the rules).

## Updating the formula

Bump `version` and the four `sha256` values when a new release is tagged:

```sh
gh release download v0.13.2 -R deepusingh2530/scanward -p 'scanward-v0.13.2-*.tar.gz'
shasum -a 256 scanward-v0.13.2-*.tar.gz
```
