# Crash Analysis Workflow

When developing C/C++ applications or embedded reliability tools, tracking down crashes is critical. This configuration optimizes `systemd-coredump` and `gdb` for a smooth debugging experience.

## Workflow

1. **Reproduce the crash:** Run your application until it segfaults.
2. **List core dumps:**
   ```bash
   coredumpctl list
   ```
3. **Inspect the latest crash info:**
   ```bash
   analyze-core <executable-name>
   ```
   Or manually:
   ```bash
   coredumpctl info <executable-name>
   ```
4. **Open the core dump in GDB:**
   ```bash
   analyze-core <executable-name> # (this also drops you into gdb)
   ```
   Or manually:
   ```bash
   coredumpctl gdb <executable-name>
   ```
5. **Analyze inside GDB:**
   Use the custom aliases provided by `.gdbinit`:
   - `bt full` or `btfull` to see the full backtrace with local variables.
   - `threads` to inspect all running threads at the time of the crash.
   - `regs` to check register states.
   - `maps` to inspect memory mappings.

6. **Collect diagnostics:**
   If the crash is part of a systemd service, you can easily gather logs:
   ```bash
   collect-diagnostics <service-name>
   ```
   This will output the service status, recent logs, memory info, and more into `./diagnostics/`.
