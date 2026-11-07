#!/usr/bin/env zsh
# Run from repository root: zsh -f tests/zsh/vim_launcher.zsh
emulate -R zsh
set -eu

test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
export VIM_TEST_LOG="$test_dir/args"
export PATH="$test_dir/bin:$PATH"

cat > "$test_dir/bin/nvim" <<'MOCK'
#!/bin/sh
printf '%s\n' "$@" > "$VIM_TEST_LOG"
MOCK
chmod +x "$test_dir/bin/nvim"

# Test the actual vim function from .zshrc without loading interactive setup.
sed -n '/^vim() {/,/^}/p' dotfiles/zsh/.zshrc > "$test_dir/vim.zsh"
[[ -s "$test_dir/vim.zsh" ]]
source "$test_dir/vim.zsh"

vim
diff -u <(printf '%s\n' '.') "$VIM_TEST_LOG"

vim test.txt
diff -u <(printf '%s\n' 'test.txt') "$VIM_TEST_LOG"

vim 'file with spaces.c'
diff -u <(printf '%s\n' 'file with spaces.c') "$VIM_TEST_LOG"

vim -u NONE 'file with spaces.c'
diff -u <(printf '%s\n' '-u' 'NONE' 'file with spaces.c') "$VIM_TEST_LOG"

vim .
diff -u <(printf '%s\n' '.') "$VIM_TEST_LOG"

print "vim launcher checks passed"
