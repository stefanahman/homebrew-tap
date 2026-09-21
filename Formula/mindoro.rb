class Mindoro < Formula
  desc "Pomodoro timer whose breaks take over every terminal window"
  homepage "https://github.com/stefanahman/mindoro"
  url "https://github.com/stefanahman/mindoro/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "bd0b5e7547a649e87c960c3ce8c548f1a38564f268181ba771b0569a4172dd1e"
  license "MIT"

  depends_on "bash"

  def install
    # The launcher resolves its own symlink to find lib/ and share/, so
    # the tree lives whole under libexec and bin/ carries one link.
    libexec.install "bin", "lib", "libexec", "adapters", "share", "tmux", "VERSION"
    # macOS ships bash 3.2; `env bash` would find it on a PATH without
    # Homebrew first. Point the scripts at the bash they depend on.
    bash = formula_opt_bin("bash")/"bash"
    %w[bin/mindoro libexec/mindoro-break adapters/tmux tmux/mindoro.tmux].each do |script|
      inreplace libexec/script, "#!/usr/bin/env bash", "#!#{bash}"
    end
    bin.install_symlink libexec/"bin/mindoro"
  end

  def caveats
    <<~EOS
      For tmux, load the plugin and put \#{mindoro} in your status line:
        run-shell #{opt_libexec}/tmux/mindoro.tmux
        set -g status-right '\#{mindoro} %H:%M'
      Then prefix+P starts and stops a session. `mindoro start` works anywhere.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mindoro --version")
    assert_equal "", shell_output("#{bin}/mindoro status")
  end
end
