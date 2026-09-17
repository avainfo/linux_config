# 42 workstation-local storage policy.
#
# Keep the regular dotfiles portable. Only Neovim's disposable cache,
# plugin/data directory and state are redirected to local goinfre when the
# 42 mount is actually present. Project-specific tools such as uv should
# configure their own storage and must not be exported globally here.

_ava_is_42_workstation() {
    [[ -d /goinfre && -d "$HOME/goinfre" && -w "$HOME/goinfre" ]] || return 1
    command -v mountpoint >/dev/null 2>&1 || return 1
    mountpoint -q /goinfre 2>/dev/null
}

if _ava_is_42_workstation; then
    export AVA_42_GOINFRE="$HOME/goinfre"

    nvim() {
        local base="$AVA_42_GOINFRE/nvim"
        mkdir -p "$base/cache" "$base/state" "$base/data"
        XDG_CACHE_HOME="$base/cache" \
        XDG_STATE_HOME="$base/state" \
        XDG_DATA_HOME="$base/data" \
        command nvim "$@"
    }
fi

unset -f _ava_is_42_workstation
