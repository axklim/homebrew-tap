class Aerotab < Formula
  desc "Cmd-Tab switcher that never causes an AeroSpace workspace jump"
  homepage "https://github.com/axklim/aerotab"
  url "https://github.com/axklim/aerotab/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "402d76f6d31079b80658d7bd5e29935e62d5939389954d0c19d7820e802be841"
  head "https://github.com/axklim/aerotab.git", branch: "main"

  depends_on :macos

  def install
    # Stamp the bundle with the formula's version rather than build.sh's default.
    ENV["AEROTAB_VERSION"] = version.to_s
    system "./build.sh", buildpath/"dist"
    prefix.install buildpath/"dist/AeroTab.app"
  end

  service do
    run opt_prefix/"AeroTab.app/Contents/MacOS/AeroTab"
    keep_alive true
    run_type :immediate
    log_path var/"log/aerotab.log"
    error_log_path var/"log/aerotab.log"
  end

  def caveats
    <<~EOS
      AeroTab needs AeroSpace 0.21.0 or newer:
        brew install --cask nikitabobko/tap/aerospace

      Start it with:
        brew services start aerotab

      Then grant Accessibility permission to
        #{opt_prefix}/AeroTab.app
      in System Settings > Privacy & Security > Accessibility. Without it no
      event tap is installed and Cmd-Tab keeps its native behaviour.

      The bundle is signed ad-hoc, so its code hash changes on every upgrade and
      macOS forgets the grant. Re-approve AeroTab after upgrading.
    EOS
  end

  test do
    assert_predicate prefix/"AeroTab.app/Contents/MacOS/AeroTab", :exist?
  end
end
