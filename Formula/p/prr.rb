class Prr < Formula
  desc "Mailing list style code reviews for github"
  homepage "https://github.com/danobi/prr"
  url "https://github.com/danobi/prr/archive/refs/tags/v0.20.0.tar.gz"
  sha256 "fa25e4690a6976af37738b417b01f1fa0df7448efd631239aadea0399a9e862a"
  license "GPL-2.0-only"
  head "https://github.com/danobi/prr.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "1935f2644eed1aea55ec06e5169cf4768f4add80d324be5bb986ba6e6b4cf416"
    sha256 cellar: :any,                 arm64_sonoma:  "5eb5d8287cde7049ce2ffc0dac1e5bb46a8d8d112f69cefac3fd2b0af95ba0cc"
    sha256 cellar: :any,                 arm64_ventura: "a6ca2fcec336fe4248924d153b101e878575a5f64156be4ef656d9ee25e79c0d"
    sha256 cellar: :any,                 sonoma:        "ae3767c62caefd53b2eac176b08cf87e3ea21396eb75861b710e4d328d7a19da"
    sha256 cellar: :any,                 ventura:       "9312b31f0f636a53a15ac44e63495421d6c94836bd13e346914cce9da3a6845f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e4e577e866ec76b2a49589a6d10cbdaad14cbce93fefa69eb899fae6fb9e6424"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "libgit2"
  depends_on "openssl@3"

  uses_from_macos "zlib"

  def install
    ENV["LIBGIT2_NO_VENDOR"] = "1"
    # Ensure the declared `openssl@3` dependency will be picked up.
    # https://docs.rs/openssl/latest/openssl/#manual
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix
    ENV["OPENSSL_NO_VENDOR"] = "1"

    # Specify GEN_DIR for shell completions and manpage generation
    ENV["GEN_DIR"] = buildpath

    system "cargo", "install", *std_cargo_args

    bash_completion.install "completions/prr.bash" => "prr"
    fish_completion.install "completions/prr.fish"
    zsh_completion.install "completions/_prr"
    man1.install Dir["man/*.1"]
  end

  def check_binary_linkage(binary, library)
    binary.dynamically_linked_libraries.any? do |dll|
      next false unless dll.start_with?(HOMEBREW_PREFIX.to_s)

      File.realpath(dll) == File.realpath(library)
    end
  end

  test do
    assert_match "Failed to read config", shell_output("#{bin}/prr get Homebrew/homebrew-core/6 2>&1", 1)

    [
      Formula["libgit2"].opt_lib/shared_library("libgit2"),
      Formula["openssl@3"].opt_lib/shared_library("libssl"),
      Formula["openssl@3"].opt_lib/shared_library("libcrypto"),
    ].each do |library|
      assert check_binary_linkage(bin/"prr", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
