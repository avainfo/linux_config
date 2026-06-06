# ============================================================
# 1. INSTANT PROMPT (doit rester tout en haut)
# ============================================================
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && \
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# ============================================================
# 2. PATH
# ============================================================
typeset -U path
path=(
    $HOME/.local/bin
    $HOME/.local/kitty.app/bin
    $HOME/bin
    $HOME/bin/jetbrains
    $HOME/srcs/flutter/bin
    $HOME/srcs/cmdline-tools/bin
    $HOME/.pub-cache/bin
    $path
)

# QT6
if [[ -d "$HOME/Qt/6.9.2/gcc_64" ]]; then
    export QT_BASE="$HOME/Qt/6.9.2/gcc_64"
    export CMAKE_PREFIX_PATH="$QT_BASE/lib/cmake${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
    export PATH="$QT_BASE/bin:$PATH"
    export LD_LIBRARY_PATH="$QT_BASE/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export QT_PLUGIN_PATH="$QT_BASE/plugins${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"
    export QML2_IMPORT_PATH="$QT_BASE/qml${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
fi

# ============================================================
# 3. OH MY ZSH
# ============================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_AUTO_TITLE="true"

plugins=(
    git
    zsh-completions
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
)

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh" || echo "Warning: Oh My Zsh not found"

# ============================================================
# 4. COULEURS / LS
# ============================================================
command -v dircolors >/dev/null 2>&1 && \
    eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
alias ls='ls --color=auto'

# ============================================================
# 5. ALIASES
# ============================================================
alias rm="rm -i"
alias vim="nvim"
alias gs="git status"
alias py="python3"
alias rpy="rm -rf __pycache__"

if [[ -z "$TMUX" ]]; then
    alias t="tmux"
else
    alias t="echo 'Déjà dans une session tmux'"
fi

if [[ -z "$KITTY_WINDOW_ID" ]]; then
    alias k="kitty --detach && exit"
else
    alias k="echo 'Kitty is already running'"
fi

alias avainfo='~/Documents/Development/AvaInfo/'
alias pgads='~/Documents/Development/PGADS/'
alias aura='~/Documents/Development/PersonalProjects/Aura-mk2/'

[[ -f "$HOME/francinette/tester.sh" ]] && \
    alias francinette="$HOME/francinette/tester.sh" && \
    alias paco="$HOME/francinette/tester.sh"

# ============================================================
# 6. FONCTIONS
# ============================================================
c() { cc -Wall -Wextra -Werror "$@" && ./a.out && rm -f a.out }
val() { cc -Wall -Wextra -Werror "$@" && valgrind ./a.out && rm -f a.out }
check() { norminette "$@" }

checkp() {
    echo "[1/4] py_compile..."  && python3 -m py_compile "$@"
    echo "[2/4] flake8..."      && python3 -m flake8 "$@"
    echo "[3/4] mypy --strict..." && python3 -m mypy --strict "$@"
    echo "[4/4] cleaning..."    && rm -rf **/__pycache__
}

cpi() { g++ -o main "$1" && ./main < input && rm -f main }

mf() {
    varname=$1; shift
    echo -n "$varname = " >> Makefile
    ls "$@" | sed ':a;N;$!ba;s/\n/ \\\n\t/g' >> Makefile
    echo >> Makefile
}

studio() {
    local target="${1:-.}"
    command -v realpath >/dev/null 2>&1 && target="$(realpath -m -- "$target")"
    local bin="$HOME/.local/share/JetBrains/Toolbox/apps/android-studio/bin/studio"
    [[ -f "$bin" ]] && "$bin" "$target" >/dev/null 2>&1 & disown || echo "Android Studio not found."
}

cpnew() {
    local dest="$PWD/$1"
    mkdir -p "$dest" || return 1
    [[ ! -f "$dest/main.cpp" ]] && cp ~/.config/nvim/templates/cp.cpp "$dest/main.cpp"
    [[ ! -f "$dest/input.txt" ]] && touch "$dest/input.txt"
    cd "$dest" && nvim main.cpp
}
alias cpr='g++ -std=c++20 -O2 -Wall -fsanitize=address,undefined -o /tmp/cp_out "$1" && time /tmp/cp_out'
alias cpri='g++ -std=c++20 -O2 -Wall -fsanitize=address,undefined -o /tmp/cp_out "$1" && time /tmp/cp_out < input.txt'

cfl() {
    local dir="${1:-.}" makefile output flags
    makefile="$dir/Makefile"; output="$dir/compile_flags.txt"
    [[ ! -f "$makefile" ]] && echo "cfl: no Makefile found in $dir" && return 1
    flags="$(make -C "$dir" -pn 2>/dev/null | awk '/^CFLAGS[[:space:]]*[:+?]?=/ { sub(/^CFLAGS[[:space:]]*[:+?]?=[[:space:]]*/, ""); print; exit }')"
    [[ -z "$flags" ]] && echo "cfl: CFLAGS not found in $makefile" && return 1
    printf "%s\n" $=flags > "$output" && echo "cfl: generated $output"
}

clg() {
    local target="${1:-.clang-format}"
    cat > "$target" <<'EOF'
BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: ForIndentation
ColumnLimit: 120
PointerAlignment: Left
EOF
    echo "clang-format config written to: $PWD/$target"
}

rlkeyboard() {
    local repo="$HOME/Downloads/gmk87-node"
    [[ ! -d "$repo" ]] && echo "GMK87 repo not found: $repo" && return 1
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    command -v node >/dev/null 2>&1 || { echo "Node.js not found."; return 1; }
    echo "Node: $(node -v)" && echo "Syncing GMK87 keyboard time..."
    cd "$repo" && sudo env "PATH=$PATH" "NVM_DIR=$NVM_DIR" npm run timesync
}

gpub() {
    local url="" remote="origin" branch="main"
    local -a positional=()

    gpub_help() { cat <<'EOF'
Usage: gpub <url> [branch]
       gpub <url> <remote> <branch>
  -u/--url, -r/--remote, -b/--branch, -h/--help
EOF
    }

    [[ $# -eq 0 ]] && gpub_help && return 1

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)  gpub_help; return 0 ;;
            -u|--url)   url="$2";    shift 2 ;;
            -r|--remote) remote="$2"; shift 2 ;;
            -b|--branch) branch="$2"; shift 2 ;;
            -*)  echo "Error: unknown option: $1"; gpub_help; return 1 ;;
            *)   positional+=("$1"); shift ;;
        esac
    done

    case "${#positional[@]}" in
        1) url="${url:-${positional[1]}}" ;;
        2) url="${url:-${positional[1]}}"; branch="${positional[2]}" ;;
        3) url="${url:-${positional[1]}}"; remote="${positional[2]}"; branch="${positional[3]}" ;;
        0) ;;
        *) echo "Error: too many arguments"; gpub_help; return 1 ;;
    esac

    [[ -z "$url" ]] && echo "Error: URL required" && gpub_help && return 1
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Error: not in a git repo"; return 1; }

    if git remote get-url "$remote" >/dev/null 2>&1; then
        local cur; cur="$(git remote get-url "$remote")"
        [[ "$cur" != "$url" ]] && echo "Error: remote '$remote' exists with different URL: $cur" && return 1
        echo "Remote '$remote' already correct."
    else
        git remote add "$remote" "$url"
    fi

    git branch -M "$branch" && git push -u "$remote" "$branch"
}

# ============================================================
# 7. OUTILS TIERS (nvm, cargo, atuin...)
# ============================================================
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]]          && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

[[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

# ============================================================
# 8. CONFIG LOCALE (.config/ava/*.zsh)
# ============================================================
if [[ -d "$HOME/.config/ava" ]]; then
    for conf in "$HOME"/.config/ava/*.zsh(N); do
        source "$conf"
    done
fi

# ============================================================
# 9. PROMPT / P10K
# ============================================================
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ============================================================
# 10. WELCOME
# ============================================================
command -v figlet >/dev/null 2>&1 && figlet -f standard "Welcome" && figlet -f standard "MR. DO SOUTO"
