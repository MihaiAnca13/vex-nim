# Contributing to VEX

Thank you for your interest in contributing to VEX! This document provides guidelines and instructions for contributing.

## Getting Started

### Prerequisites

- Nim 2.2 or later
- Git

### Development Setup

```bash
git clone https://github.com/MihaiAnca13/vex-nim.git
cd vex-nim
nimble install
```

### Running Tests

```bash
# Run all unit tests
nim c -r tests/

# Run with verbose output
nim c -r --verbosity:2 tests/
```

## Coding Standards

VEX follows the coding standards defined in [AGENTS.md](AGENTS.md). Key points:

- **Naming**: `camelCase` for procedures, `PascalCase` for types
- **Imports**: Stdlib first, then external libraries (boxy, pixie, vmath)
- **Formatting**: 2-space indentation, max 45 lines per function
- **Documentation**: Docstrings for all public APIs

## Branch Naming

- `main` - Main development branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `docs/*` - Documentation improvements

## Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch from `main`
3. **Make** your changes following coding standards
4. **Test** your changes with `nim c -r tests/`
5. **Commit** with a clear commit message
6. **Push** to your fork
7. **Open** a Pull Request against `main`

## Issue Tracker

Use GitHub Issues for:
- Bug reports
- Feature requests
- Questions about usage

When reporting bugs, please include:
- Expected behavior
- Actual behavior
- Steps to reproduce
- Nim version (`nim -v`)
- OS/Platform

## Code Review

All submissions require review before merging. Please:

- Keep PRs small and focused
- Include tests for new functionality
- Update documentation as needed
- Respond to review feedback constructively
