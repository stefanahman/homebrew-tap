class Mindoro < Formula
  desc "Pomodoro timer whose breaks take over every terminal window"
  homepage "https://github.com/stefanahman/mindoro"
  url "https://github.com/stefanahman/mindoro/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "c071e4de5ad418b89e156de682e294a5123c860d6ae35bff3a4246f5d46ccd62"
  license "MIT"

  depends_on "bash"

  def install
    # The launcher resolves its own symlink to find lib/ and share/, so
    # the tree lives whole under libexec and bin/ carries one link.
    libexec.install "bin", "lib", "libexec", "adapters", "share", "mindoro.tmux", "VERSION"
    # macOS ships bash 3.2; `env bash` would find it on a PATH without
    # Homebrew first. Point the scripts at the bash they depend on.
    bash = formula_opt_bin("bash")/"bash"
    %w[bin/mindoro libexec/mindoro-break adapters/tmux mindoro.tmux].each do |script|
      inreplace libexec/script, "#!/usr/bin/env bash", "#!#{bash}"
    end
    bin.install_symlink libexec/"bin/mindoro"
  end

  def caveats
    <<~EOS
      For tmux, two lines in tmux.conf:
        set -g status-right '\#{mindoro} %H:%M'
        run-shell 'mindoro tmux-init'
      Then prefix+P starts and stops a session. `mindoro start` works anywhere.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mindoro --version")
    assert_equal "", shell_output("#{bin}/mindoro status")
  end
end
