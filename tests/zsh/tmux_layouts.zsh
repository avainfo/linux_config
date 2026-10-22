#!/usr/bin/env zsh
# Run from the repository root with: zsh -f tests/zsh/tmux_layouts.zsh
emulate -R zsh
set -eu

local_tmp="$(mktemp -d)"
trap 'rm -rf "$local_tmp"' EXIT
mkdir -p "$local_tmp/bin"
export TMUX_TEST_LOG="$local_tmp/tmux.log"
export TMUX_TEST_NUM="$local_tmp/count"
export PATH="$local_tmp/bin:$PATH"

cat > "$local_tmp/bin/tmux" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$TMUX_TEST_LOG"
case "$1" in
    new-window|new-session|split-window)
        n="$(cat "$TMUX_TEST_NUM" 2>/dev/null || echo 0)"
        n=$((n + 1))
        printf '%s\n' "$n" > "$TMUX_TEST_NUM"
        printf '%%pane%s\n' "$n"
        ;;
esac
MOCK
chmod +x "$local_tmp/bin/tmux"

# Source only the workspace functions, not the interactive zsh login setup.
sed -n '/^# General-purpose tmux splits;/,/^# Browse remote files via Oil/{
    /^# Browse remote files via Oil/d
    p
}' dotfiles/zsh/.zshrc > "$local_tmp/layouts.zsh"
source "$local_tmp/layouts.zsh"

contains() {
    grep -F -- "$1" "$TMUX_TEST_LOG" >/dev/null ||
        { print -u2 "Missing tmux call: $1"; cat "$TMUX_TEST_LOG"; return 1; }
}

export TMUX="/tmp/mock-server,123,0"

: > "$TMUX_TEST_LOG"
dv vim .
contains "new-window -P -F #{pane_id} -n dv"
contains "split-window -v -l 50%"
[[ "$(grep -Fc -- '-- vim .' "$TMUX_TEST_LOG")" == 2 ]] ||
    { print -u2 "dv must send 'vim .' to both panes"; exit 1; }
contains "select-pane -t %pane1"
! grep -F "attach-session" "$TMUX_TEST_LOG" >/dev/null

: > "$TMUX_TEST_LOG"
dh 'ssh causaltrace'
contains "new-window -P -F #{pane_id} -n dh"
contains "split-window -h -l 50%"
[[ "$(grep -Fc -- '-- ssh causaltrace' "$TMUX_TEST_LOG")" == 2 ]]

: > "$TMUX_TEST_LOG"
ts 'vim .' 'ssh causaltrace'
contains "new-window -P -F #{pane_id} -n ts"
contains "split-window -h -l 45%"
contains "split-window -v -l 50%"
[[ "$(grep -Fc -- '-- vim .' "$TMUX_TEST_LOG")" == 1 ]]
[[ "$(grep -Fc -- '-- ssh causaltrace' "$TMUX_TEST_LOG")" == 2 ]]

: > "$TMUX_TEST_LOG"
ts 'vim .' 'ssh causaltrace' 'ssh secondary'
[[ "$(grep -Fc -- '-- ssh causaltrace' "$TMUX_TEST_LOG")" == 1 ]]
[[ "$(grep -Fc -- '-- ssh secondary' "$TMUX_TEST_LOG")" == 1 ]]

: > "$TMUX_TEST_LOG"
dv vim 'file with spaces.c'
contains "file\\ with\\ spaces.c"

: > "$TMUX_TEST_LOG"
if ts 'vim .'; then
    print -u2 "ts should reject fewer than two commands"
    exit 1
fi
if dv; then
    print -u2 "dv should reject an empty command"
    exit 1
fi
[[ ! -s "$TMUX_TEST_LOG" ]]

# Outside tmux, it must create and attach to a new isolated session.
unset TMUX
: > "$TMUX_TEST_LOG"
ts 'vim .' 'ssh causaltrace'
contains "new-session -d -P -F #{pane_id} -s ts-"
contains "attach-session -t ts-"

print "tmux workspace checks passed"
