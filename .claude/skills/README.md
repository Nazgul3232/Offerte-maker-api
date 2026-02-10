# Claude Skills for Offerte-Maker-Api

Custom skills to enhance your development workflow.

## Available Skills

### `/analyst` - API Specification Assistant

**Purpose:** Systematically gather requirements and produce detailed API specifications.

**Usage:**
```
/analyst
/analyst quotes
/analyst invoices
```

**What It Does:**
- Asks 8 phases of structured questions
- Gathers all API requirements
- Produces detailed specification
- Ready for Developer Agent to implement

**Example:**
```
You: /analyst quotes

Analyst Agent: 🤖 Let me gather your requirements...

Phase 1: Basic Requirements
─────────────────────────────────────────────────────
1. Is "Quotes" the exact resource name?
2. Should it use GUID as primary key?
3. What resources does Quote relate to?
```

**Output:**
Complete API specification with:
- All endpoints with HTTP methods
- Authorization matrix
- DTO structures
- Caching strategy
- Validation rules
- Special operations
- Integration notes

**Next Step After:**
→ Developer Agent uses spec + ARCHITECT_CHECKLIST.md to build
→ Architect Agent reviews for compliance

---

## How Skills Work

Skills are automated workflows that follow `.md` files in this directory.

### Creating a New Skill

1. Create `skillname.md` in `.claude/skills/`
2. Define the workflow/instructions
3. Use: `/skillname` to invoke

### Current Structure
```
.claude/
├── skills/
│   ├── analyst.md          (API specification assistant)
│   └── README.md           (this file)
├── analyst-agent.md        (agent role instructions)
├── architect-agent.md      (agent role instructions)
└── developer-agent.md      (agent role instructions)
```

---

## Integration with Your System

```
Feature Request
      ↓
/analyst skill ← Gathers detailed requirements
      ↓
API Specification
      ↓
Developer Agent ← Follows spec + checklist
      ↓
Feature Implementation
      ↓
Architect Agent ← Reviews compliance
      ↓
APPROVED ✅
```

---

## Tips

- **Use `/analyst` when:** Someone asks for a new API feature
- **Ask clearly:** Describe what you want (e.g., "Quotes for customers")
- **Answer thoroughly:** Give detailed answers to questions, not yes/no
- **Reference examples:** Analyst will show Companies/Employees patterns

---

**Last Updated:** February 10, 2026
