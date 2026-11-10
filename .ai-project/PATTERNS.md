# Project-Specific Patterns

> **Purpose**: Document coding patterns specific to this project that AI should follow.
> **Update**: When you establish new patterns or change existing ones.

## 🎯 How to Use This File

When working with AI agents:
- AI reads this automatically when you say "Resume from last session"
- Update this when you establish a new pattern
- Keep it concise - details go in code comments

---

## 🔐 Authentication & Authorization

**Pattern**: [How authentication is handled]

Example:
```python
# Always use the auth decorator
from core.auth import require_auth

@require_auth(role="admin")
def admin_endpoint():
    pass
```

**Why**: [Rationale for this pattern]

---

## 🗄️ Database Access

**Pattern**: [How to access database]

Example:
```python
# Always use context manager
from db import get_session

with get_session() as session:
    user = session.query(User).filter_by(id=user_id).first()
```

**Why**: [Ensures proper connection cleanup]

---

## ❌ Error Handling

**Pattern**: [Error handling approach]

Example:
```python
# Use custom exceptions
from exceptions import ProjectError, NotFoundError

if not user:
    raise NotFoundError(f"User {user_id} not found")
```

**Why**: [Consistent error types, easier to handle]

---

## 📝 Logging

**Pattern**: [Logging approach]

Example:
```python
# Use module-level logger
import logging
logger = logging.getLogger(__name__)

logger.info("Processing request", extra={"user_id": user_id})
```

**Why**: [Consistent logging, easy to filter]

---

## 🧪 Testing

**Pattern**: [Testing approach]

Example:
```python
# Tests mirror source structure
# src/auth/login.py → tests/auth/test_login.py

# Use fixtures from conftest.py
def test_login(client, test_user):
    response = client.post("/login", json=test_user)
    assert response.status_code == 200
```

**Why**: [Easy to find tests, shared fixtures]

---

## 📦 Imports

**Pattern**: [Import organization]

Example:
```python
# Order: stdlib, third-party, local
import os
from typing import List

import requests
from flask import Flask

from core.auth import authenticate
from models.user import User
```

**Why**: [PEP 8 compliance, consistent]

---

## 🏗️ Code Organization

**Pattern**: [File/module organization]

Example:
```
src/
  feature/
    __init__.py      # Public API
    models.py        # Data models
    service.py       # Business logic
    api.py           # API endpoints

tests/
  feature/
    test_models.py
    test_service.py
    test_api.py
```

**Why**: [Clear separation of concerns]

---

## 🔧 Configuration

**Pattern**: [Config management]

Example:
```python
# Use config object, never hardcode
from config import settings

DATABASE_URL = settings.database_url
API_KEY = settings.api_key  # From environment
```

**Why**: [Environment-specific config, security]

---

## 📊 API Response Format

**Pattern**: [API response structure]

Example:
```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "metadata": {
    "timestamp": "...",
    "version": "1.0"
  }
}
```

**Why**: [Consistent client handling]

---

## 🔄 Async Operations

**Pattern**: [How to handle async/background tasks]

Example:
```python
# Use task queue for long operations
from tasks import celery_app

@celery_app.task
def send_email(user_id, subject, body):
    ...
```

**Why**: [Non-blocking, scalable]

---

## 📝 Documentation

**Pattern**: [Docstring style]

Example:
```python
def process_user(user_id: int, options: dict) -> User:
    """Process user data with given options.

    Args:
        user_id: User identifier
        options: Processing options

    Returns:
        Processed user object

    Raises:
        NotFoundError: If user doesn't exist
    """
```

**Why**: [Consistent, works with doc generators]

---

## 🎨 Naming Conventions

**Variables**: `snake_case`
**Functions**: `snake_case`
**Classes**: `PascalCase`
**Constants**: `UPPER_CASE`
**Private**: `_leading_underscore`

---

## 🚫 Anti-Patterns (Don't Do This)

1. **Don't use global variables** - Use dependency injection
2. **Don't catch generic exceptions** - Be specific
3. **Don't use mutable defaults** - `def func(items=[])` ❌
4. **Don't import `*`** - Explicit imports only

---

## 📚 Framework-Specific Patterns

[Add framework-specific patterns here]

---

**Last Updated**: [DATE]
**Review**: Update when patterns change or new patterns emerge
