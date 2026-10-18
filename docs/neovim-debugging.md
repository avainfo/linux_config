# Neovim: GDB debugging

The Neovim configuration includes `nvim-dap`, `nvim-dap-ui`, and `nvim-nio` for native GDB debugging of C, C++, and Rust programs.

## Requirements

- Neovim 0.11.7 (the workstation's tested version)
- GDB 14+ built with Python support (required for its DAP interpreter)
- A local executable compiled with debug symbols

Check the installed debugger:

```sh
gdb --version | head -n 1
```

On supported Debian-based systems, GDB can usually be installed with `sudo apt install gdb`. Verify the version; older GDB packages do not provide the DAP interpreter.

Install the Neovim plugins after updating the configuration:

```vim
:Lazy sync
```

Restart Neovim after installation.

## Run a session

Build a C program without optimizations and with debug symbols:

```sh
cc -g -O0 -Wall -Wextra -o demo demo.c
nvim demo.c
```

1. Place the cursor on an executable line and press `Space db` to toggle a breakpoint.
2. Press `Space dc`, select **Launch executable (GDB)**, and enter the executable's path (for example, `/path/to/project/demo`).
3. When the breakpoint is hit, step through the code and inspect the scopes and call stack in the debug UI.
4. Press `Space dq` to terminate.

For C++, build with `c++ -g -O0`; for Rust, use a debug build and select the executable in `target/debug/`.

## Keys

| Keys | Action |
| --- | --- |
| `Space db` | Toggle breakpoint |
| `Space dc` | Start or continue a session |
| `Space dn` | Step over |
| `Space di` | Step into |
| `Space do` | Step out |
| `Space dp` | Pause |
| `Space dq` | Terminate |
| `Space dr` | Toggle DAP REPL |
| `Space du` | Toggle debugger UI |
| `Space de` | Evaluate expression under cursor or visual selection |

The debug UI opens automatically when the session starts and closes when the target exits or the debugger terminates it. All mappings load the debugging plugins only when first used.

A second configuration, **Attach to process (GDB)**, prompts for an executable and then lets you select a running PID. Linux may restrict attaching to unrelated processes.

## Scope and limitations

These configurations start **local GDB**. Opening a remote file through `svim` / Oil SSH does not turn the debugger into a remote debugger. Use a debugger installed on the target machine or configure `gdbserver` separately when remote debugging is needed.

GDB here debugs **userspace** processes (for example, a libbpf loader). It does not step through the eBPF program running inside the Linux kernel. Kernel-side investigation requires separate tools such as `bpftool`, tracefs, and BPF verifier logs.

If a session fails, check `:DapShowLog`, `gdb --version`, your working directory (`:pwd`), and whether the chosen binary contains debug symbols.
