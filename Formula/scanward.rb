# Homebrew formula for scanward.
#
# Kept in a personal tap rather than homebrew/core: core requires a
# DFSG-compatible (OSI-approved) licence, and scanward is PolyForm
# Noncommercial 1.0.0. Taps impose no licence requirement.
#
#   brew install deepusingh2530/scanward/scanward
#
# Each release tarball carries the binary, the rule corpus, and a
# `scanward-corpus` wrapper that points the scanner at that corpus.
class Scanward < Formula
  desc "Fast, fully-offline multi-language SAST scanner"
  homepage "https://github.com/deepusingh2530/scanward"
  license "PolyForm-Noncommercial-1.0.0"
  version "0.13.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/deepusingh2530/scanward/releases/download/v#{version}/scanward-v#{version}-macos-arm64.tar.gz"
      sha256 "03b4384c93846ecaefe84ed0e9edf2dbd16cabeb843dabeb33a0223ccb2d9f4d"
    else
      # No Intel macOS binary is published, so build from the source tarball.
      url "https://github.com/deepusingh2530/scanward/archive/refs/tags/v#{version}.tar.gz"
      sha256 "f647c0ea8915ccc7768d41a441cbdf831c0a7603e6fb0dfe71e823d20ca096e5"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && !Formula["glibc"].installed?
      url "https://github.com/deepusingh2530/scanward/releases/download/v#{version}/scanward-v#{version}-linux-musl.tar.gz"
      sha256 "ac01b3516a6c44623fdae8f1ebca8201ed221b4f48afe4d6278a94dd7c1a43fc"
    else
      url "https://github.com/deepusingh2530/scanward/releases/download/v#{version}/scanward-v#{version}-linux-gnu.tar.gz"
      sha256 "6ade8e9c096b401ee4bf77f6a056c827388218f8f7c81e7c1fc494adb2c4ba54"
    end
  end

  def install
    bin.install "scanward"
    pkgshare.install "LICENSE" if File.exist?("LICENSE")

    # Only prebuilt archives carry the corpus; a source build does not, so there
    # is nothing to install and no wrapper to write.
    return unless File.exist?("rules")

    (pkgshare/"rules").install Dir["rules"]

    # Generate our own wrapper rather than shipping the tarball's: the bundled
    # one resolves the corpus relative to its own directory, and Homebrew puts
    # the corpus in pkgshare, not next to the binary.
    (bin/"scanward-corpus").write <<~SH
      #!/bin/sh
      # Run scanward against the Homebrew-installed rule corpus.
      here="$(cd "$(dirname "$0")" && pwd)"
      rules="#{pkgshare}/rules"
      case "$1" in
        ""|-*) exec "$here/scanward" "$@" ;;
        scan|autofix)
          sub="$1"; shift
          for arg in "$@"; do
            case "$arg" in
              --rules|--rules=*) exec "$here/scanward" "$sub" "$@" ;;
            esac
          done
          exec "$here/scanward" "$sub" --rules "$rules" "$@"
          ;;
        rule) exec "$here/scanward" rule test "$rules" ;;
        *) exec "$here/scanward" "$@" ;;
      esac
    SH
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scanward --version")
    # `rule test` takes the rules path positionally.
    assert_match "rule(s) valid", shell_output("#{bin}/scanward rule test #{pkgshare}/rules")
  end

  def caveats
    <<~EOS
      Noncommercial licence: free for personal, research, educational,
      charitable and government use. Commercial use requires a licence from the
      maintainer — see
        https://github.com/deepusingh2530/scanward/blob/main/docs/licensing.md

      No Intel macOS binary is published; Homebrew builds from source there.
      The rule corpus is installed at:
        #{pkgshare}/rules

      Scan with the bundled corpus via the wrapper:
        scanward-corpus scan .
      or pass the corpus explicitly:
        scanward scan . --rules #{pkgshare}/rules
    EOS
  end
end
