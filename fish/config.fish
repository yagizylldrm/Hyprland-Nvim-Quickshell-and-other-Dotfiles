if status is-interactive
    # 1. LinuxBrew Setup
    # This must run first so 'lsd', 'bat', and 'fzf' are found in your PATH
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

    # 2. Aliases
    # Note: No '=' sign in Fish aliases
    alias ls "lsd"
    alias cat "bat"

    # 3. Tool Initializations
    # zoxide (Replaces 'cd')
    zoxide init fish | source
    # thefuck (Auto-correction)
    thefuck --alias | source

    # 4. Yazi Function (Ported from your Zsh function)
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    # 5. Startup Splash
    # Clears screen and runs fastfetch every time you open a terminal
    clear
    fastfetch
end
alias pip "python -m pip"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# pnpm
set -gx PNPM_HOME "/home/yagizylldrm/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
