class Mira < Formula
  desc "macOS CLI tool for Onyx Boox Mira e-ink display"
  homepage "https://github.com/erdalgunes/onyx-boox-mira-macos"
  url "https://github.com/erdalgunes/onyx-boox-mira-macos/archive/refs/tags/v1.1.0.tar.gz"
  sha256 ""  # Will be calculated after release
  license "MIT"
  
  depends_on :macos
  depends_on xcode: ["14.0", :build]
  
  def install
    system "swift", "build", "--configuration", "release", "--disable-sandbox"
    bin.install ".build/release/mira"
  end
  
  test do
    assert_match "mira - macOS CLI tool for Onyx Boox Mira e-ink display", shell_output("#{bin}/mira help")
  end
end