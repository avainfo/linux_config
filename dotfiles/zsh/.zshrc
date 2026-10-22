# ============================================================
# 0. WELCOME
# ============================================================
command -v figlet >/dev/null 2>&1 && figlet -f standard "Welcome" && figlet -f standard "MR. DO SOUTO"

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
    $HOME/tools/sdk/flutter/bin
    $HOME/Android/Sdk/cmdline-tools/latest/bin
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

# Completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
zstyle ':completion:*' menu select

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
alias dev='cd ~/code'

alias ccode='cd ~/code'
alias c42='cd ~/code/42'
alias cpgads='cd ~/code/pgads'
alias cpersonal='cd ~/code/personal'
alias coss='cd ~/code/open-source'
alias clabs='cd ~/code/labs'
alias cava='cd ~/code/avainfo'
alias cclients='cd ~/code/clients'
alias ctutoring='cd ~/code/tutoring'
alias chackathons='cd ~/code/hackathons'
alias cconf='cd ~/Documents/config'

# Docker
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dca='docker attach'

# Docker Compose
alias dco='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcbuild='docker compose build'
alias dcps='docker compose ps'
alias dcl='docker compose logs -f'
alias dcr='docker compose restart'

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

alias avainfo='cd ~/code/avainfo'
alias pgads='cd ~/code/pgads'
alias aura='cd ~/code/personal/Aura-mk2'

[[ -f "$HOME/tools/francinette/tester.sh" ]] && \
    alias francinette="$HOME/tools/francinette/tester.sh" && \
    alias paco="$HOME/tools/francinette/tester.sh"

# ============================================================
# 6. FONCTIONS
# ============================================================
c() { cc -Wall -Wextra -Werror "$@" && ./a.out && rm -f a.out }
val() { cc -Wall -Wextra -Werror "$@" && valgrind ./a.out && rm -f a.out }
check() { norminette "$@" }

checkp() (
    (( $# )) || { print -u2 'Usage: checkp <files.py...>'; return 2; }
    local cache_dir
    cache_dir="$(mktemp -d "${TMPDIR:-/tmp}/checkp.XXXXXXXX")" || return 1
    trap 'command rm -rf -- "$cache_dir"' EXIT
    echo "[1/3] py_compile..."
    PYTHONPYCACHEPREFIX="$cache_dir" python3 -m py_compile "$@" || return $?
    echo "[2/3] flake8..."
    python3 -m flake8 "$@" || return $?
    echo "[3/3] mypy --strict..."
    python3 -m mypy --strict "$@"
)

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
# Remove the former aliases when reloading this configuration.
unalias cpr cpri 2>/dev/null
cpr() (
    (( $# )) || { print -u2 'Usage: cpr <source.cpp> [compiler flags...]'; return 2; }
    local build_dir
    build_dir="$(mktemp -d "${TMPDIR:-/tmp}/cpr.XXXXXXXX")" || return 1
    trap 'command rm -rf -- "$build_dir"' EXIT
    g++ -std=c++20 -O2 -Wall -fsanitize=address,undefined "$@" -o "$build_dir/main" || return $?
    time "$build_dir/main"
)
cpri() { cpr "$@" < input.txt }

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
    local repo="$HOME/tools/sources/gmk87-node"
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
# 6.1 TMUX + NEOVIM WORKSPACE LAYOUTS
# ============================================================
# dvim [files...]: Neovim split left/right above one shell
# tvim [files...]: Neovim split left/right above a second Neovim pane
# Always create a new tmux window when already inside tmux.
# Otherwise create and attach to a dedicated tmux session.
_tmux_nvim_layout() {
    local layout="$1"
    shift

    if ! command -v tmux >/dev/null 2>&1 || ! command -v nvim >/dev/null 2>&1; then
        print -u2 "dvim/tvim: tmux and nvim must be installed"
        return 1
    fi

    local top bottom session="" command_line="nvim -c vsplit" arg
    for arg in "$@"; do
        command_line+=" ${(q)arg}"
    done

    if [[ -n "${TMUX:-}" ]]; then
        top="$(tmux new-window -P -F '#{pane_id}' -n "$layout" -c "$PWD")" || return 1
    else
        session="${layout}-$$-${RANDOM}"
        top="$(tmux new-session -d -P -F '#{pane_id}' -s "$session" -n "$layout" -c "$PWD")" || return 1
    fi

    # 65% for the top editor, 35% for the bottom editor or terminal.
    bottom="$(tmux split-window -v -l '35%' -P -F '#{pane_id}' -t "$top" -c "$PWD")" || return 1

    # Send the editor command after arranging the panes, retaining the shell on exit.
    tmux send-keys -l -t "$top" "$command_line" || return 1
    tmux send-keys -t "$top" Enter || return 1

    # tvim runs a separate Neovim instance across the entire lower tmux pane.
    # dvim keeps that same pane as a normal shell.
    if [[ "$layout" == "tvim" ]]; then
        tmux send-keys -l -t "$bottom" "nvim" || return 1
        tmux send-keys -t "$bottom" Enter || return 1
    else
        # Start dvim with a clean lower shell.
        tmux send-keys -t "$bottom" C-l || return 1
    fi

    tmux select-pane -t "$top" || return 1

    [[ -z "$session" ]] || tmux attach-session -t "$session"
}

dvim() { _tmux_nvim_layout dvim "$@" }
tvim() { _tmux_nvim_layout tvim "$@" }

# General-purpose tmux splits; start commands in shells so panes stay open.
_tmux_workspace_send() {
    local pane="$1" command_line="$2"
    tmux send-keys -l -t "$pane" -- "$command_line" &&
        tmux send-keys -t "$pane" Enter
}

_tmux_workspace_cleanup() {
    local first="$1" session="$2"
    if [[ -n "$session" ]]; then
        tmux kill-session -t "$session" >/dev/null 2>&1
    else
        tmux kill-window -t "$first" >/dev/null 2>&1
    fi
}

_tmux_workspace() {
    emulate -L zsh
    local layout="$1" command_left="$2" command_right="${3-}" command_bottom="${4-}"
    local first second third="" session="" orientation=""
    local -a panes commands
    local i

    if ! command -v tmux >/dev/null 2>&1; then
        print -u2 "dv/dh/ts: tmux must be installed"
        return 1
    fi

    if [[ -n "${TMUX:-}" ]]; then
        first="$(tmux new-window -P -F '#{pane_id}' -n "$layout" -c "$PWD")" || return 1
    else
        session="${layout}-$-${RANDOM}"
        first="$(tmux new-session -d -P -F '#{pane_id}' -s "$session" -n "$layout" -c "$PWD")" || return 1
    fi

    # tmux -v = top/bottom; tmux -h = left/right.
    case "$layout" in
        dv) orientation="-v" ;;
        dh|ts) orientation="-h" ;;
    esac

    if [[ "$layout" == "ts" ]]; then
        second="$(tmux split-window -h -l '45%' -P -F '#{pane_id}' -t "$first" -c "$PWD")" || {
            _tmux_workspace_cleanup "$first" "$session"
            return 1
        }
        third="$(tmux split-window -v -l '50%' -P -F '#{pane_id}' -t "$second" -c "$PWD")" || {
            _tmux_workspace_cleanup "$first" "$session"
            return 1
        }
    else
        second="$(tmux split-window "$orientation" -l '50%' -P -F '#{pane_id}' -t "$first" -c "$PWD")" || {
            _tmux_workspace_cleanup "$first" "$session"
            return 1
        }
    fi

    panes=("$first" "$second")
    commands=("$command_left" "$command_right")
    if [[ "$layout" == "ts" ]]; then
        panes+=("$third")
        commands+=("$command_bottom")
    fi

    for (( i=1; i<=${#panes}; i++ )); do
        if ! _tmux_workspace_send "${panes[i]}" "${commands[i]}"; then
            print -u2 "$layout: could not start a command"
            _tmux_workspace_cleanup "$first" "$session"
            return 1
        fi
    done

    tmux select-pane -t "$first" || return 1
    [[ -z "$session" ]] || tmux attach-session -t "$session"
}

# One string is a shell command; multiple args are safely quoted individually.
_tmux_duplicate() {
    emulate -L zsh
    local layout="$1" command_line="" arg
    shift

    if (( $# == 0 )); then
        print -u2 "Usage: $layout <command> [args...] | $layout '<shell command>'"
        return 2
    fi

    if (( $# == 1 )); then
        command_line="$1"
    else
        for arg in "$@"; do
            [[ -z "$command_line" ]] || command_line+=" "
            command_line+="${(q)arg}"
        done
    fi

    [[ -n "$command_line" ]] || return 2
    _tmux_workspace "$layout" "$command_line" "$command_line"
}

dv() { _tmux_duplicate dv "$@" }
dh() { _tmux_duplicate dh "$@" }

# Modern syntax (Tab friendly): ts vim . -- ssh causaltrace
# Third pane optional: ts vim . -- ssh causaltrace -- htop
# Legacy syntax ('vim .' 'ssh causaltrace') still works.
_tmux_workspace_quote() {
    emulate -L zsh
    local arg command_line=""
    for arg in "$@"; do
        [[ -z "$command_line" ]] || command_line+=" "
        command_line+="${(q)arg}"
    done
    print -r -- "$command_line"
}

ts() {
    emulate -L zsh
    local -a pane_commands=() command_args=()
    local arg contains_separator=0

    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            contains_separator=1
            break
        fi
    done

    if (( ! contains_separator )); then
        # Compatibility with the original quoted, two/three-command syntax.
        if (( $# < 2 || $# > 3 )) || [[ -z "$1" || -z "$2" ]] ||
            { (( $# == 3 )) && [[ -z "$3" ]]; }; then
            print -u2 "Usage: ts <left command> -- <right command> [-- <bottom-right command>]"
            print -u2 "Legacy: ts 'vim .' 'ssh causaltrace' ['ssh other-host']"
            return 2
        fi
        _tmux_workspace ts "$1" "$2" "${3:-$2}"
        return
    fi

    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            if (( ${#command_args} == 0 )); then
                print -u2 "ts: empty command before '--'"
                return 2
            fi
            pane_commands+=("$(_tmux_workspace_quote "${command_args[@]}")")
            command_args=()
        else
            command_args+=("$arg")
        fi
    done

    if (( ${#command_args} == 0 )); then
        print -u2 "ts: missing command after '--'"
        return 2
    fi
    pane_commands+=("$(_tmux_workspace_quote "${command_args[@]}")")

    if (( ${#pane_commands} < 2 || ${#pane_commands} > 3 )); then
        print -u2 "Usage: ts <left command> -- <right command> [-- <bottom-right command>]"
        return 2
    fi

    _tmux_workspace ts "${pane_commands[1]}" "${pane_commands[2]}" "${pane_commands[3]:-${pane_commands[2]}}"
}

# Reparse the current sub-command so Zsh's normal command/argument completion
# works for nvim paths, ssh host aliases, etc. after each '--' separator.
_tmux_workspace_complete() {
    emulate -L zsh
    local start=2 i
    local -a segment

    if [[ "${words[1]}" == "ts" ]]; then
        for (( i=2; i<CURRENT; i++ )); do
            [[ "${words[i]}" == "--" ]] && start=$(( i + 1 ))
        done
    fi

    segment=("${(@)words[start,-1]}")
    words=("${(@)segment}")
    (( CURRENT = CURRENT - start + 1 ))
    _normal
}

# Oh My Zsh initializes compdef before this section is sourced.
if (( ${+functions[compdef]} )); then
    compdef _tmux_workspace_complete dv dh ts
fi

# Browse remote files via Oil's SSH adapter using an SSH host alias.
svim() {
    if (( $# != 1 )) || [[ -z "$1" ]]; then
        print -u2 "Usage: svim <ssh-alias>[/remote/path]"
        return 2
    fi

    local target="${1#oil-ssh://}"
    [[ "$target" == */* ]] || target+="/"
    command nvim "oil-ssh://$target"
}

# Complete SSH hosts and remote paths, reusing three levels for 45 seconds.
typeset -gA _svim_cache _svim_expiry

_svim() {
    emulate -L zsh
    local target="${words[CURRENT]}"
    local host remote parent prefix root rest key output line kind name suffix now i limit
    local -a hosts=() parts=() dirs=() files=()

    if [[ "$target" != */* ]]; then
        [[ -r "$HOME/.ssh/config" ]] || return
        hosts=("${(@f)$(awk '
            tolower($1) == "host" {
                for (i=2; i<=NF; i++) {
                    if ($i ~ /^#/) break
                    if ($i !~ /[*!?]/) print $i
                }
            }' "$HOME/.ssh/config")}")
        (( ${#hosts} )) && compadd -S / -- "${hosts[@]}"
        return
    fi

    host="${target%%/*}"
    remote="${target#*/}"
    [[ -n "$host" && "$host" != -* ]] || return 1
    if [[ "$remote" == */* ]]; then
        parent="${remote%/*}"
        [[ -n "$parent" ]] && prefix="$parent/" || { parent="/"; prefix="/"; }
    else
        parent="."
        prefix=""
    fi

    rest="$parent"
    if [[ "$parent" == /* ]]; then
        rest="${parent#/}"
        root="/"
    else
        root="."
        [[ "$rest" == "." ]] && rest=""
    fi
    [[ -n "$rest" ]] && parts=("${(@s:/:)rest}")
    limit=$(( (${#parts} / 3) * 3 ))
    if (( limit )); then
        root=""
        for (( i=1; i<=limit; i++ )); do
            [[ -n "$root" ]] && root+="/"
            root+="${parts[i]}"
        done
        [[ "$parent" == /* ]] && root="/$root"
    fi

    key="$host|$root"
    zmodload zsh/datetime 2>/dev/null
    now="${EPOCHSECONDS:-0}"
    if [[ -z "${_svim_expiry[$key]-}" ]] || (( now >= _svim_expiry[$key] )); then
        output="$(timeout 5s ssh -T -o BatchMode=yes -o ConnectTimeout=3 \
            -o ConnectionAttempts=1 -- "$host" \
            "find -L ${(q)root} -mindepth 1 -maxdepth 3 -printf '%y:%P\n'" \
            2>/dev/null)" || return 1
        if (( ${#_svim_cache} > 60 )); then
            _svim_cache=()
            _svim_expiry=()
        fi
        _svim_cache[$key]="$output"
        _svim_expiry[$key]=$(( now + 45 ))
    fi

    if [[ "$root" == "." || "$root" == "/" ]]; then
        rest="$rest"
    elif [[ "$parent" == "$root" ]]; then
        rest=""
    else
        rest="${parent#"$root"/}"
    fi
    [[ -n "$rest" ]] && rest+="/"

    for line in "${(@f)_svim_cache[$key]}"; do
        [[ "$line" == ?:* ]] || continue
        kind="${line%%:*}"
        name="${line#*:}"
        [[ "$name" == "$rest"* ]] || continue
        suffix="${name#"$rest"}"
        [[ -n "$suffix" && "$suffix" != */* ]] || continue
        if [[ "$kind" == d ]]; then
            dirs+=("$host/$prefix$suffix")
        else
            files+=("$host/$prefix$suffix")
        fi
    done
    (( ${#dirs} )) && compadd -S / -- "${dirs[@]}"
    (( ${#files} )) && compadd -- "${files[@]}"
}
compdef _svim svim

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
