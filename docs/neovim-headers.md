# Automatic MIT headers in Neovim

New, empty source files automatically receive the same Ava Info Conseils MIT copyright header as `F1 + m`.

The implementation is part of `lua/ava/header.lua`. It reuses the supported filename patterns in `M.types`, so the automatic behavior and the manual MIT template use the same comment syntax.

## Supported file types

The header follows the extensions already handled by `F1 + m`:

- C/C++: `.c`, `.h`, `.cc`, `.hh`, `.cpp`, `.hpp`, `.cxx`, `.tpp`, `.ipp`
- Go, Rust, PHP, Java, Kotlin: `.go`, `.rs`, `.php`, `.java`, `.kt`, `.kts`
- Web: `.js`, `.ts`, `.html`, `.htm`, `.xml`
- Other supported templates: `.py`, `.lua`, `.tex`, `.ml`, `.mli`, `.mll`, `.mly`, `.vim`, `vimrc`, `.el`, `emacs`, `.asm`, `.f`, `.for`, `.f90`, `.f95`, `.f03`

Other extensions, such as `.md`, `.jsx`, `.tsx` and `.hxx`, remain untouched because they are not covered by the current `F1 + m` rules.

PHP files start with `<?php`, XML files with an XML declaration, and HTML files with `<!DOCTYPE html>` before the MIT header. This avoids producing PHP output before its opening tag, or placing an XML declaration after comments.

## Ways to create a file

- `nvim new.c`, `:edit new.c`, `:split new.h`, `:vsplit new.cpp`: Neovim fires `BufNewFile` when the named file does not exist.
- Oil.nvim: create a new file in Oil, save the directory view, then open the new file. Oil's successful `OilActionsPost` event records which files it created. On opening that empty file, the MIT header is inserted into its buffer.
- Oil SSH (`svim`): the same Oil action tracking works for newly created remote files. The header appears after the remote file has finished loading.
- `:enew` followed by `:file path/new.cpp`: a newly named, empty buffer also gets the header.

**Important:** Oil first creates an empty file on disk. After you open it, the header appears in the buffer; **save the file with `:write`** to persist the header. The automation does not secretly rewrite files in the background.

For safety, existing files (including empty ones), copied or moved files, nonempty buffers, and failed Oil operations are not given new headers. Files created externally while Neovim was closed are also not treated as new. The automation does not invent timestamps to guess whether an empty file was recently created.

The `F1 + m` mapping remains available for manually inserting an MIT header. `F1 + g` inserts `GPL-2.0-only`, replacing the existing SPDX identifier when a matching Ava Info Conseils MIT/Apache/GPL header is already present at the top of the file. This avoids stacking contradictory headers after automatic MIT insertion. `F1 + f`, `F1 + a`, and `F1 + p` remain unchanged.

## Test

Run from the repository root with Neovim 0.11.7:

```sh
nvim --headless -u NONE -l tests/nvim/header_creation.lua
```

The tests check supported extensions, empty and existing files, Oil local/remote creation events, failed operations, and avoiding duplicated automatic headers.

## Licensing reminder

An MIT template is the default, not a license determination. Check each repository's licensing rules before committing, especially 42 coursework, proprietary customer code and eBPF programs covered by another declared license.
