---
name: ruff-lsp
description: Use when the user wants real-time Python lint/format diagnostics, asks about ruff setup, requests style fixes or import sorting, encounters PEP 8 violations to auto-fix, or is migrating from the deprecated `ruff-lsp` package to the built-in `ruff server`.
---

# ruff-lsp

## Overview

Astral's `ruff` is a fast, Rust-based Python linter and formatter, replacing flake8/black/isort. Its built-in language server (`ruff server`) delivers real-time diagnostics, code actions, and formatting via LSP.

## When to use

- Real-time lint diagnostics (pycodestyle, pyflakes, pyupgrade, flake8-* plugins)
- Format-on-save / organize imports (`source.fixAll`, `source.organizeImports`)
- Quick-fix code actions, including `noqa` suppression
- Migrating from the deprecated `ruff-lsp` Python package

## When NOT to use

- Type checking, go-to-definition, find references — ruff does **not** include a type checker; use a dedicated type-checker LSP (Pyright, ty, Pylance) instead
- Non-Python projects

## Installation

If `ruff --version` fails, ask which install method the user prefers:

| Method | Command |
|--------|---------|
| Astral toolchain (recommended) | `uv tool install ruff` |
| pip | `pip install ruff` |
| pipx | `pipx install ruff` |

## Running the language server

Start with `ruff server` — communicates over stdio with JSON-RPC.

## Configuration

ruff reads config from `[tool.ruff]` in `pyproject.toml` or from `ruff.toml`. If neither exists, defaults apply — suggest explicit config for reproducibility.

## Caveats

- **Deprecated package**: the standalone `ruff-lsp` Python package is deprecated. Always use `ruff server` from the main ruff binary. If both are installed, disable the deprecated `ruff-lsp` to avoid conflicts.
- **Scope**: ruff does linting/formatting only. Type-related questions belong to a separate type-checker LSP; the two are complementary, not redundant.
- **Pair with a type checker**: Astral's docs recommend running ruff alongside a separate type-checker LSP (Pyright or ty), with capabilities allocated to each.

## References

- Editor setup: https://docs.astral.sh/ruff/editors/setup/
- LSP settings reference: https://docs.astral.sh/ruff/editors/settings/
- GitHub: https://github.com/astral-sh/ruff
