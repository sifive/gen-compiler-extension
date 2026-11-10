# Project Conventions

> **Purpose**: Document tools, workflows, and conventions for this project.
> **Update**: During setup or when changing tools/workflows.

---

## 📋 Project Metadata

**Project Name**: [Project Name]
**Language**: [Primary Language]
**Framework**: [Framework/Library]
**Version**: [Current Version]
**Started**: [Date]

---

## 🛠️ Development Tools

### Language & Runtime
- **Primary**: Python 3.11+
- **Secondary**: Bash (for scripts), SQL

### Package Management
- **Tool**: pip / poetry / pipenv
- **Lock File**: requirements.txt / poetry.lock
- **Virtual Env**: venv / poetry env

### Code Quality
- **Formatter**: ruff format / black
- **Linter**: ruff check / pylint / flake8
- **Type Checker**: mypy / pyright
- **Import Sorter**: ruff / isort

### Testing
- **Framework**: pytest
- **Coverage**: pytest-cov
- **Mocking**: pytest-mock / unittest.mock
- **Fixtures**: tests/conftest.py

### Build & Deployment
- **Build Tool**: [make / docker / setuptools]
- **CI/CD**: [GitHub Actions / Jenkins / GitLab CI]
- **Container**: [Docker / Podman]

---

## 📝 Code Style

### Python (PEP 8 + Project Specifics)
- **Line Length**: 100 characters (not 79)
- **Indentation**: 4 spaces (never tabs)
- **Quotes**: Double quotes for strings (unless avoiding escapes)
- **Imports**: Grouped (stdlib, third-party, local) with blank lines

### Type Hints
- **Required**: All public functions and methods
- **Style**: Use `typing` module types
- **Optional**: Internal/private functions (encouraged)

Example:
```python
from typing import List, Optional

def process_items(items: List[str], limit: Optional[int] = None) -> dict:
    ...
```

### Docstrings
- **Style**: Google style / NumPy style / reStructuredText
- **Required**: All public modules, classes, functions
- **Optional**: Private/internal code (but encouraged)

---

## 🌿 Git Workflow

### Branch Naming
- `main` - Production-ready code
- `develop` - Integration branch (if using git-flow)
- `feature/feature-name` - New features
- `bugfix/issue-description` - Bug fixes
- `hotfix/critical-fix` - Urgent production fixes
- `refactor/what-is-refactored` - Code refactoring
- `docs/what-is-documented` - Documentation only

### Commit Messages
**Format**: Conventional Commits

```
type(scope): subject

body (optional)

footer (optional)
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes nor adds feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependencies

**Examples**:
```
feat(auth): add JWT token validation
fix(api): handle null user in response
docs(readme): update installation instructions
```

### Pull Requests
- **Title**: Use conventional commit format
- **Description**: Explain what and why (not how)
- **Requirements**:
  - [ ] Tests pass
  - [ ] Code reviewed
  - [ ] No merge conflicts
  - [ ] Documentation updated (if needed)

---

## 🧪 Testing Standards

### Test Organization
```
tests/
  unit/          # Fast, isolated tests
  integration/   # Tests with external dependencies
  e2e/          # End-to-end tests
  conftest.py   # Shared fixtures
```

### Test Naming
```python
def test_function_name_scenario_expected_result():
    ...

# Examples:
def test_authenticate_valid_credentials_returns_token():
def test_process_invalid_input_raises_error():
```

### Coverage Requirements
- **Minimum**: 80% overall
- **Target**: 90% for business logic
- **Exceptions**: Main/CLI entry points, trivial getters/setters

### Running Tests
```bash
# All tests
pytest

# With coverage
pytest --cov=src --cov-report=html

# Specific test
pytest tests/test_auth.py::test_login

# Mark-based
pytest -m "not slow"
```

---

## 🔧 Build & Run Commands

### Setup
```bash
# Install dependencies
pip install -r requirements.txt
# OR
poetry install

# Setup dev environment
make setup
```

### Development
```bash
# Run locally
python src/main.py
# OR
make run

# Watch mode (if applicable)
make watch
```

### Testing
```bash
make test          # Run all tests
make test-unit     # Unit tests only
make test-cov      # With coverage report
```

### Code Quality
```bash
make format        # Format code
make lint          # Run linters
make typecheck     # Type checking
make check         # All checks (format + lint + typecheck)
```

### Build
```bash
make build         # Build project
make docker        # Build Docker image
```

---

## 📁 Project Structure

```
project-root/
├── src/               # Source code
│   ├── __init__.py
│   ├── main.py        # Entry point
│   └── ...
├── tests/             # Tests
├── docs/              # Documentation
├── scripts/           # Utility scripts
├── config/            # Configuration files
├── .ai-context/       # Session context (gitignored)
├── .ai-project/       # Project context
└── .ai-harness/       # AI Agent Harness (submodule)
```

---

## 🔐 Secrets Management

- **Never commit**: API keys, passwords, tokens
- **Use**: Environment variables or secret management service
- **Local**: `.env` file (gitignored)
- **Production**: Secret manager (AWS Secrets Manager, etc.)

---

## 📚 Documentation

- **README.md**: Project overview, setup, usage
- **docs/**: Detailed documentation
- **Inline**: Complex logic should have comments
- **API**: Auto-generated from docstrings

---

## 🚀 Release Process

1. Update version in `__version__.py` / `pyproject.toml`
2. Update `CHANGELOG.md`
3. Create release branch: `release/vX.Y.Z`
4. Run full test suite
5. Merge to `main`
6. Tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
7. Deploy to production
8. Merge back to `develop`

---

## 📞 Communication

- **Issues**: GitHub Issues / Jira
- **Discussions**: GitHub Discussions / Slack
- **Code Review**: GitHub Pull Requests
- **Documentation**: Project Wiki / Confluence

---

**Last Updated**: [DATE]
**Review**: Update when adopting new tools or changing workflows
