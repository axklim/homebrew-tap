class Mynah < Formula
  desc "Rate how clearly a message reads, and translate via Claude"
  homepage "https://github.com/axklim/mynah"
  # Placeholders until the first release cut by the new workflow. v0.2.1 and earlier
  # shipped the CLI as a source build and the app as a separate zip, so there is no
  # v0.2.1 asset this formula could point at.
  url "https://github.com/axklim/mynah/releases/download/v0.3.0/mynah-0.3.0-arm64.zip"
  # The URL points at a release asset, not a tag tarball, so Homebrew cannot derive
  # the version. The release workflow in axklim/mynah rewrites all three lines together.
  version "0.3.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  # Both artifacts are prebuilt by CI on an Apple silicon runner: the app half needs
  # full Xcode to compile at all (a dependency uses #Preview, whose macro plugin ships
  # only inside Xcode), and building the CLI here would buy nothing but a wait.
  depends_on arch: :arm64
  depends_on macos: :ventura

  def install
    bin.install "mynah"
    prefix.install "Mynah.app"
  end

  service do
    run opt_prefix/"Mynah.app/Contents/MacOS/Mynah"
    keep_alive true
    run_type :immediate
    log_path var/"log/mynah.log"
    error_log_path var/"log/mynah.log"
  end

  def caveats
    <<~EOS
      mynah shells out to an authenticated `claude` CLI — there is no API key to set.
      Install Claude Code and sign in first, or every check fails.

        mynah check "i has finished the task and it works good"
        pbpaste | mynah translate

      Start the menu bar app with

        brew services start mynah

      then press Hyper+C (^~⌘C) to rate the clipboard, or Hyper+⇧C to translate
      it. The app has no Dock icon; it lives in the menu bar.

      The bundle is signed ad-hoc, so its code hash changes on every upgrade while
      macOS privacy grants stay bound to the old hash. The `claude` subprocess can
      probe user folders, so a file-access prompt may reappear after an upgrade —
      click Allow, or reset it with

        tccutil reset SystemPolicyDownloadsFolder io.klimov.mynah
    EOS
  end

  test do
    assert_match "mynah check", shell_output("#{bin}/mynah --help")

    # Catches the release mistake nothing else can see: a tag cut without bumping
    # MynahVersion.swift, leaving the binary reporting the previous version.
    assert_equal version.to_s, shell_output("#{bin}/mynah --version").strip

    assert_path_exists prefix/"Mynah.app/Contents/MacOS/Mynah"
  end
end
