# Analyst Agent - API Specification Skill

## Purpose
Systematically gather API requirements and produce detailed specifications before development starts.

## Usage
```
/analyst
/analyst quotes
/analyst invoices
```

---

## Workflow

### STEP 1: Greeting & Resource Name

```
🤖 ANALYST AGENT - API Specification Assistant
═══════════════════════════════════════════════════════════

I'll help you design your API by asking structured questions
across 8 phases. This ensures we cover all aspects before
development starts.

What resource do you want to create an API for?
(Example: Quotes, Invoices, Reports, Customers, etc.)
```

---

### PHASE 1: Basic Resource Definition

```
📋 PHASE 1: BASIC REQUIREMENTS
─────────────────────────────────────────────────────────────

Great! Let's design the [RESOURCE] API.

1️⃣ Is "[RESOURCE]" the exact name you want?

2️⃣ What's the unique identifier?
   ☐ GUID (UUID) - Recommended ✅
   ☐ String code (e.g., "QUOTE-001")
   ☐ Numeric ID
   ☐ Multiple (GUID + string code)

3️⃣ What other resources does it relate to?
   Format: "[RESOURCE] → Company (1:many)"
```

---

### PHASE 2: Core CRUD Operations

```
🔧 PHASE 2: OPERATIONS
─────────────────────────────────────────────────────────────

Standard REST operations - which do you need?

[ ] GET /api/[resources]          - List all
[ ] GET /api/[resources]/{id}     - Get single
[ ] POST /api/[resources]         - Create
[ ] PUT /api/[resources]/{id}     - Full update
[ ] PATCH /api/[resources]/{id}   - Partial update
[ ] DELETE /api/[resources]/{id}  - Delete

Collection operations:
[ ] GET /api/[resources]/collection/({ids})  - Multiple by IDs
[ ] POST /api/[resources]/collection         - Bulk create

Check which operations you need.
```

---

### PHASE 3: Listing, Filtering & Search

```
🔍 PHASE 3: LISTING & FILTERING
─────────────────────────────────────────────────────────────

When users GET all items, what features do they need?

1️⃣ Pagination?
   ☐ Yes → How many per page? (10, 20, 50?)
   ☐ No

2️⃣ Sorting?
   ☐ Yes → By what fields?
   ☐ No

3️⃣ Filtering?
   ☐ Yes → By what fields?
   ☐ No

4️⃣ Field selection?
   ☐ Yes - Only specific fields: ?fields=id,name
   ☐ No
```

---

### PHASE 4: Caching & Performance

```
⚡ PHASE 4: CACHING & PERFORMANCE
─────────────────────────────────────────────────────────────

1️⃣ Cache GET all?
   ☐ Yes → Duration? (60s, 120s, 5min?)
   ☐ No

2️⃣ Cache GET by ID?
   ☐ Yes → Duration?
   ☐ No

3️⃣ ETag support?
   ☐ Yes - For conditional requests
   ☐ No
```

---

### PHASE 5: Authorization & Security

```
🔐 PHASE 5: AUTHORIZATION & SECURITY
─────────────────────────────────────────────────────────────

Who can do what?

GET all:    [ ] Public [ ] Auth [ ] Manager [ ] Owner
GET one:    [ ] Public [ ] Auth [ ] Manager [ ] Owner
CREATE:     [ ] Public [ ] Auth [ ] Manager [ ] Owner
UPDATE:     [ ] Public [ ] Auth [ ] Manager [ ] Owner
DELETE:     [ ] Public [ ] Auth [ ] Manager [ ] Owner

Additional:
[ ] Rate limiting needed?
[ ] Audit logging needed?
```

---

### PHASE 6: Response Data

```
📤 PHASE 6: RESPONSE DATA STRUCTURE
─────────────────────────────────────────────────────────────

What should responses include?

Example structure (customize):
{
  "id": "uuid",
  "name": "string",
  "status": "enum",
  "amount": "decimal",
  "createdDate": "datetime",
  "companyId": "uuid",
  "companyName": "string",  // Include full data or just ID?
  "items": []               // Include details?
}

1️⃣ List all fields needed
2️⃣ Include related data or just IDs?
3️⃣ Include nested arrays?
4️⃣ HATEOAS links?
```

---

### PHASE 7: Special Operations

```
⚙️ PHASE 7: SPECIAL OPERATIONS
─────────────────────────────────────────────────────────────

Any custom actions needed?

[ ] Approve/Reject: POST /api/[resources]/{id}/approve
[ ] Send/Publish: POST /api/[resources]/{id}/send
[ ] Export: GET /api/[resources]/{id}/export?format=pdf
[ ] Duplicate: POST /api/[resources]/{id}/duplicate
[ ] Lock/Unlock: Status changes
[ ] Other: ...

List custom operations needed.
```

---

### PHASE 8: Versioning

```
📌 PHASE 8: VERSIONING
─────────────────────────────────────────────────────────────

Will this API evolve over time?

[ ] Yes → Will need v2 support
[ ] No → v1 only

Current pattern: /api/v1/[resources]
```

---

## Specification Output

After all 8 phases, compile:

```
✅ SPECIFICATION COMPLETE
═══════════════════════════════════════════════════════════

# API Specification - [RESOURCE] API

## Resource Overview
- Resource: [NAME]
- Primary Key: [Type]
- Relations: [List]

## Endpoints
- GET /api/[resources]
- GET /api/[resources]/{id}
- POST /api/[resources]
- PUT /api/[resources]/{id}
- PATCH /api/[resources]/{id}
- DELETE /api/[resources]/{id}
[+ custom operations]

## Authorization Matrix
[Table with role permissions]

## DTOs
[Detailed DTO structures]

## Caching Strategy
[Duration for each endpoint]

## Filtering Options
[Pagination, sorting, filtering fields]

---

Ready for Developer Agent to implement!
```

---

## Key Principles

✅ Ask all 8 phases thoroughly
✅ Wait for detailed answers (not just yes/no)
✅ Reference Companies/Employees patterns
✅ Produce concrete specification
✅ Align with ARCHITECT_CHECKLIST.md

❌ Don't skip phases
❌ Don't assume requirements
❌ Don't produce vague specs
