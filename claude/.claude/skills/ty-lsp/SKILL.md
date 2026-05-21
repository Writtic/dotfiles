---
name: ty-lsp
description: Use when working with Python and the user wants semantic navigation (go-to-definition, find references, hover types), real-time type-check diagnostics, a Pyright/Pylance alternative, or works in an Astral-toolchain project (uv, ruff, ty).
---

# ty-lsp

## Overview

Astral's `ty` is a fast, Rust-based Python type checker and language server. This skill explains how to install it, run the language server, and use it for symbol-aware Python operations instead of grep-based heuristics.

## When to use

- "Where is `Foo` defined?" / "Who calls `bar()`?" — prefer LSP over grep for symbol queries
- "What type does this return?" — use `hover` instead of reading code manually
- User wants type-check diagnostics on save
- Astral-toolchain project (uv, ruff, ty)
- Looking for a Pyright/Pylance alternative

## When NOT to use

- CI-grade type checking — ty is still beta and trails Pyright on edge cases; keep Pyright/mypy in CI
- Linting or formatting — use ruff (separate language server) instead
- Non-Python projects

## Installation

If `ty --version` fails, ask which install method the user prefers:

| Method | Command |
|--------|---------|
| Astral toolchain (recommended) | `uv tool install ty` |
| pip | `pip install ty` |
| pipx | `pipx install ty` |

## Running the language server

Start with `ty server` — communicates over stdio with JSON-RPC.

Prefer LSP operations (`textDocument/definition`, `textDocument/references`, `textDocument/hover`) over grep when the user asks symbol-level Python questions.

## Caveats

- **Beta**: ty is 0.0.x. Breaking changes possible between releases. Check the installed version first if diagnostics look wrong.
- **Stdlib unresolved**: verify `requires-python` in `pyproject.toml`. A wrong lower bound (e.g. `>= 2.7`) makes ty resolve against an old stdlib.
- **Members unresolved** (e.g. `from requests import x` works but `x.method` is missing): venv likely not detected. Run `uv sync` and restart, or point ty at the venv explicitly.
- **CI**: prefer Pyright/mypy for CI; use ty for local IDE/agent workflows.

## References

- Documentation: https://docs.astral.sh/ty/
- Editor integration: https://docs.astral.sh/ty/editors/
- GitHub: https://github.com/astral-sh/ty
