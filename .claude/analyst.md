# Analyst Agent Skill

## Usage

```
/analyst [resource-name]

Examples:
/analyst quotes
/analyst invoices
/analyst reports
/analyst
```

If no resource name provided, will ask for one.

## What This Does

Systematically gathers API requirements through 8 phases of questions:
1. Basic resource definition
2. Required operations
3. Query/filtering features
4. Caching strategy
5. Authorization & security
6. Response data structure
7. Special operations
8. API versioning

Produces detailed API specification ready for Developer Agent to implement.

---

## Analyst Agent Questionnaire

I will ask structured questions and build a complete API specification.

You answer the questions, I'll generate a detailed spec that includes:
- All endpoints with methods
- Authorization matrix
- DTO structures
- Validation rules
- Caching strategy
- Special operations
- Integration with your architecture

Let's start!

