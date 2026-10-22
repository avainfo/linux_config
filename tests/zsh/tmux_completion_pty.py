#!/usr/bin/env python3
"""Exercise real interactive Zsh <Tab> completion for the tmux helpers.

Run from the repository root: python3 tests/zsh/tmux_completion_pty.py
Requires zsh and a pseudo-terminal (Linux/macOS).
"""
import os
import pty
import select
import subprocess
import tempfile
import time
from pathlib import Path


SOURCE = Path("dotfiles/zsh/.zshrc").read_text()
start = SOURCE.index("# General-purpose tmux splits;")
end = SOURCE.index("# Browse remote files via Oil", start)
LAYOUT_FUNCTIONS = SOURCE[start:end]


def receive_until(fd: int, marker: bytes, seconds: float = 12.0) -> bytes:
    deadline = time.monotonic() + seconds
    output = bytearray()
    while marker not in output and time.monotonic() < deadline:
        ready, _, _ = select.select([fd], [], [], 0.2)
        if ready:
            try:
                chunk = os.read(fd, 65536)
            except OSError as exc:
                raise AssertionError(f"pty read failed; output: {output!r}") from exc
            if not chunk:
                break
            output.extend(chunk)
    assert marker in output, f"missing {marker!r} in pty output: {output!r}"
    assert b"no matches found" not in output, f"Zsh completion threw NOMATCH: {output!r}"
    assert b"globbed-files" not in output, f"Zsh completion threw glob error: {output!r}"
    return bytes(output)


def type_keys(fd: int, keys: bytes) -> None:
    os.write(fd, keys)


with tempfile.TemporaryDirectory(prefix="ava-tmux-tab-") as temp:
    base = Path(temp)
    (base / "layout-functions.zsh").write_text(LAYOUT_FUNCTIONS)
    (base / "sample_completion.c").touch()
    (base / ".ssh").mkdir()
    (base / ".ssh" / "config").write_text("Host causaltrace\n    HostName localhost\n")

    master, slave = pty.openpty()
    env = {**os.environ, "HOME": str(base), "TERM": "xterm-256color", "ZDOTDIR": str(base)}
    proc = subprocess.Popen(
        ["zsh", "-f", "-i"],
        stdin=slave,
        stdout=slave,
        stderr=slave,
        cwd=base,
        env=env,
        start_new_session=True,
    )
    os.close(slave)

    try:
        receive_until(master, b"%")
        setup = (
            "autoload -Uz compinit && compinit -i -D; "
            "source ./layout-functions.zsh; "
            "compdef _files vim; "
            "unsetopt extendedglob; "
            "PROMPT='TEST> '; "
            "function _ava_capture() { print -r -- \"CAPTURE:$BUFFER\"; BUFFER=''; zle .accept-line; }; "
            "zle -N accept-line _ava_capture; "
            "print -r -- READY\r"
        )
        type_keys(master, setup.encode())
        receive_until(master, b"\x1b[JTEST> ")

        # Reproduces the user case with _normal -> _files -> '*:globbed-files'.
        type_keys(master, b"ts vim sample_comple\t\r")
        receive_until(master, b"CAPTURE:ts vim sample_completion.c")

        # An argument after a separator must complete in the right-pane context.
        type_keys(master, b"ts vim . -- ssh causalt\t\r")
        receive_until(master, b"CAPTURE:ts vim . -- ssh causaltrace")

        print("interactive tmux completion (real Tab) passed")
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=3)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait(timeout=3)
        os.close(master)
