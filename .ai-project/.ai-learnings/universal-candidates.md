# Universal Pattern Candidates

This file tracks patterns that might be universal (belong in .ai-harness/) rather than project-specific.

**Criteria for universal patterns:**
- Used across multiple projects (3+)
- Language/framework agnostic approach
- General best practice
- Not project-specific business logic

**Human action needed:** Review periodically and manually add worthy patterns to .ai-harness/

---

## Active Universal Candidates

### [Pattern Name]

**Usage Count**: 0 across X projects
**Projects**: project1, project2, project3
**First Seen**: [Date]

**Pattern Description**:
[What the pattern is]

**Example**:
```language
[code example]
```

**Why Universal?**:
[Reasoning for why this should be in harness]

**Recommended Target**:
- File: .ai-harness/skills/[language]_coding.md
- Section: [section name]

**Status**: Under consideration / Ready for harness / Added to harness / Rejected

**Manual Action Required**:
1. Review this pattern
2. If approved, manually add to .ai-harness/skills/[file]
3. Commit and push to harness repository
4. Run `git submodule update --remote` in all projects

---

## Added to Harness

(Patterns successfully promoted to harness are archived here)

### [Pattern Name]

**Added**: [Date]
**Harness File**: .ai-harness/skills/[file]
**Commit**: [commit hash]

---

## Rejected

(Patterns that were deemed project-specific or invalid are archived here)

---

**Note**: This file is populated by AI. Promotion to harness is manual (by human).
