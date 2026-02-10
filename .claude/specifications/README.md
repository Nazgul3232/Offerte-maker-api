# API Specifications

Gedetailleerde API-specificaties gegenereerd door de Analyst Agent.

Elk bestand hier is een complete specification klaar voor Developer Agent om te implementeren.

## Bestandsnaamconventie

```
{resource}-api-specification.md

Examples:
- quotes-api-specification.md
- invoices-api-specification.md
- projects-api-specification.md
- customers-api-specification.md
```

## Inhoud van een Spec

Elke spec bevat:

```markdown
# API Specification - [Resource] API

## Resource Overview
- Resource name
- Primary key type
- Related resources

## Endpoints Summary
- List of all endpoints

## Authorization Matrix
- Who can do what

## Detailed Endpoint Specifications
- Path
- HTTP Method
- Purpose
- Parameters
- Authorization
- Request body (DTO)
- Response format
- Status codes
- Caching

## DTOs
- Read DTO
- Create DTO
- Update DTO
- Field descriptions
- Validation rules

## Filtering & Query Options
- Pagination
- Sorting
- Filtering
- Search

## Caching Strategy
- Duration per endpoint
- ETag support

## Special Operations
- Custom actions
- Non-standard endpoints

## Integration Notes
- Architecture alignment
- Database considerations
```

## Status Workflow

1. **Draft** - Analyst is gathering requirements
2. **Complete** - Analyst has finished, spec is ready
3. **In Development** - Developer Agent is building
4. **Implemented** - Feature is complete and merged
5. **Live** - Feature is in production

Mark status in document with badge:

```markdown
# API Specification - Quotes API

**Status:** Complete ✅ | Ready for Development

[Rest of spec...]
```

## Using a Specification

### For Developer Agent
```
1. Find spec in .claude/specifications/
2. Read complete specification
3. Follow ARCHITECT_CHECKLIST.md
4. Build the feature
```

### For Architect Agent
```
1. Review PR from Developer
2. Cross-reference with spec
3. Verify alignment
4. Approve or request changes
```

## Examples

See existing specifications:
- (none yet - first spec will be created with /analyst)

## Creating a New Specification

### Method 1: Using /analyst Skill
```
User: "/analyst quotes"
Analyst: [Asks 8 phases of questions]
Analyst: [Creates quotes-api-specification.md]
```

### Method 2: Manual
```
1. Copy template below
2. Fill in all sections
3. Save to .claude/specifications/
4. Link in this README
```

## Specification Template

```markdown
# API Specification - [Resource] API

**Status:** Draft 📝 | In Progress 🔄 | Complete ✅

---

## Resource Overview

- **Resource Name:** [Name]
- **Primary Key:** [GUID/String/Numeric]
- **Description:** [What is this resource]
- **Related Resources:**
  - [Resource] → Company (relationship type)
  - [Resource] → Employee (relationship type)

---

## Endpoints Summary

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | /api/[resources] | List all | Manager |
| GET | /api/[resources]/{id} | Get single | Manager |
| POST | /api/[resources] | Create | Manager |
| PUT | /api/[resources]/{id} | Full update | Manager |
| PATCH | /api/[resources]/{id} | Partial update | Manager |
| DELETE | /api/[resources]/{id} | Delete | Manager |

---

## Authorization Matrix

| Operation | Public | Authenticated | Manager | Owner |
|-----------|--------|---------------|---------|-------|
| GET all | ☐ | ☐ | ☑ | ☐ |
| GET one | ☐ | ☐ | ☑ | ☐ |
| CREATE | ☐ | ☐ | ☑ | ☐ |
| UPDATE | ☐ | ☐ | ☑ | ☐ |
| DELETE | ☐ | ☐ | ☑ | ☐ |

---

## Detailed Endpoint Specifications

### GET /api/[resources]

**Purpose:** Retrieve list of all [resources]

**Authorization:** Manager role required

**Query Parameters:**
- `pageNumber` (optional, default: 1)
- `pageSize` (optional, default: 10)
- `sortBy` (optional: field names)
- `status` (optional: filter by status)

**Request:**
```
GET /api/[resources]?pageNumber=1&pageSize=10&sortBy=date
```

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "name": "string",
    "status": "enum",
    "createdDate": "datetime"
  }
]
```

**Headers:**
- `X-Pagination`: Pagination metadata

**Caching:**
- Duration: 60 seconds
- ETag: Supported

**Status Codes:**
- 200: Success
- 401: Unauthorized
- 403: Forbidden

---

### GET /api/[resources]/{id}

**Purpose:** Retrieve single [resource]

**Authorization:** Manager role required

**Path Parameters:**
- `id` (GUID): Resource ID

**Request:**
```
GET /api/[resources]/550e8400-e29b-41d4-a716-446655440000
```

**Response (200 OK):**
```json
{
  "id": "uuid",
  "name": "string",
  "status": "enum",
  "createdDate": "datetime"
}
```

**Caching:**
- Duration: 120 seconds
- ETag: Yes

**Status Codes:**
- 200: Success
- 401: Unauthorized
- 404: Not Found

---

### POST /api/[resources]

**Purpose:** Create new [resource]

**Authorization:** Manager role required

**Request Body:**
```json
{
  "name": "string (required)",
  "status": "enum (optional)"
}
```

**DTO:** `[Resource]ForCreationDto`

**Response (201 Created):**
```json
{
  "id": "uuid",
  "name": "string",
  "status": "enum",
  "createdDate": "datetime"
}
```

**Headers:**
- `Location`: /api/[resources]/{id}

**Validation:**
- Name: Required, min 3 chars, max 255
- Status: Optional, must be valid enum

**Status Codes:**
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 422: Unprocessable Entity

---

### PUT /api/[resources]/{id}

**Purpose:** Full update (replace entire resource)

**Authorization:** Manager role required

**Path Parameters:**
- `id` (GUID): Resource ID

**Request Body:**
```json
{
  "name": "string (required)",
  "status": "enum (optional)"
}
```

**DTO:** `[Resource]ForUpdateDto`

**Response (204 No Content):**
No body

**Validation:** Same as POST

**Status Codes:**
- 204: No Content
- 400: Bad Request
- 401: Unauthorized
- 404: Not Found
- 422: Unprocessable Entity

---

### PATCH /api/[resources]/{id}

**Purpose:** Partial update (JSON Patch)

**Authorization:** Manager role required

**Path Parameters:**
- `id` (GUID): Resource ID

**Request Body (JSON Patch):**
```json
[
  {
    "op": "replace",
    "path": "/status",
    "value": "Approved"
  }
]
```

**DTO:** `JsonPatchDocument<[Resource]ForUpdateDto>`

**Response (204 No Content):**
No body

**Status Codes:**
- 204: No Content
- 400: Bad Request
- 401: Unauthorized
- 404: Not Found
- 422: Unprocessable Entity

---

### DELETE /api/[resources]/{id}

**Purpose:** Delete [resource]

**Authorization:** Manager role required

**Path Parameters:**
- `id` (GUID): Resource ID

**Request:**
```
DELETE /api/[resources]/550e8400-e29b-41d4-a716-446655440000
```

**Response (204 No Content):**
No body

**Status Codes:**
- 204: No Content
- 401: Unauthorized
- 404: Not Found

---

## DTOs

### [Resource]Dto (Read)

Used for GET responses.

```csharp
public class [Resource]Dto
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Status { get; set; }
    public DateTime CreatedDate { get; set; }
}
```

**Fields:**
- `id`: Resource GUID
- `name`: Resource name
- `status`: Current status
- `createdDate`: When created

### [Resource]ForCreationDto (Create)

Used for POST requests.

```csharp
public class [Resource]ForCreationDto
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(255, MinimumLength = 3)]
    public string Name { get; set; }

    public string Status { get; set; } = "Draft";
}
```

**Validation Rules:**
- Name: Required, 3-255 characters
- Status: Optional, defaults to "Draft"

### [Resource]ForUpdateDto (Update)

Used for PUT/PATCH requests.

```csharp
public class [Resource]ForUpdateDto
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(255, MinimumLength = 3)]
    public string Name { get; set; }

    public string Status { get; set; }
}
```

**Differences from Create:**
- Same validation
- All fields required on PUT, optional on PATCH

---

## Filtering & Query Options

### Pagination
- **Supported:** Yes
- **Default Page Size:** 10
- **Max Page Size:** 100
- **Parameters:** pageNumber, pageSize

**Example:**
```
GET /api/[resources]?pageNumber=2&pageSize=20
```

### Sorting
- **Supported:** Yes
- **Default:** By created date descending
- **Fields:** name, status, createdDate

**Example:**
```
GET /api/[resources]?sortBy=name&sortOrder=asc
```

### Filtering
- **By Status:** ?status=Draft,Approved
- **By Date Range:** ?fromDate=2024-01-01&toDate=2024-12-31

**Example:**
```
GET /api/[resources]?status=Approved&fromDate=2024-01-01
```

---

## Caching Strategy

| Endpoint | Method | Duration | ETag |
|----------|--------|----------|------|
| GET all | GET | 60s | No |
| GET by ID | GET | 120s | Yes |
| Create | POST | N/A | N/A |
| Update | PUT/PATCH | N/A | N/A |
| Delete | DELETE | N/A | N/A |

**Cache Invalidation:**
- POST creates: Invalidate GET all
- PUT/PATCH updates: Invalidate GET by ID + GET all
- DELETE removes: Invalidate GET all

---

## Special Operations

### POST /api/[resources]/{id}/approve

**Purpose:** Approve a [resource]

**Authorization:** Manager role required

**Request:**
```json
{}
```

**Response (200 OK):**
```json
{
  "id": "uuid",
  "status": "Approved",
  "approvedDate": "datetime"
}
```

**Status Codes:**
- 200: Success
- 404: Not Found
- 409: Conflict (already approved)

---

## Integration Notes

✅ **Architecture Compliance:**
- Follows ARCHITECT_CHECKLIST.md
- 6-layer implementation required
  - Entity: [Resource].cs
  - Repository: I[Resource]Repository.cs + [Resource]Repository.cs
  - Service: I[Resource]Service.cs + [Resource]Service.cs
  - DTO: [Resource]Dto.cs + ForCreationDto + ForUpdateDto
  - Controller: [Resource]sController.cs
  - AutoMapper: CreateMap<[Resource], [Resource]Dto>()

✅ **Authentication:**
- JWT Bearer tokens required for most operations
- Roles: Manager, Employee, Administrator

✅ **Error Handling:**
- StandardErrorDetails format
- GlobalExceptionHandler catches exceptions
- Validation errors return 422 Unprocessable Entity

✅ **Database:**
- GUID primary keys
- Timestamps: CreatedDate, ModifiedDate
- Soft deletes: IsDeleted flag (if needed)
- Relationships: Foreign keys with proper navigation

---

## Approval & Status

**Specification Version:** 1.0
**Generated by:** Analyst Agent
**Date:** [Date]
**Status:** Complete ✅

**Ready for Development?**
→ Developer Agent will use this spec + ARCHITECT_CHECKLIST.md
→ Architect Agent will verify alignment with this spec
```

---

## Checklist for Specifications

Before marking Complete:

- [ ] All 8 analyst phases covered
- [ ] All endpoints documented
- [ ] DTOs fully specified
- [ ] Authorization matrix complete
- [ ] Validation rules defined
- [ ] Caching strategy clear
- [ ] Special operations documented
- [ ] Examples provided
- [ ] Status codes listed
- [ ] Error scenarios covered
- [ ] Aligned with architecture checklist
- [ ] Ready for Developer Agent

---

## Related Documentation

- **ARCHITECT_CHECKLIST.md** - What all implementations must have
- **DEVELOPMENT_GUIDELINES.md** - How to implement from spec
- **API_DESIGN_FRAMEWORK.md** - Reference of all API options
- **.claude/analyst-agent.md** - How analyst generates specs
- **.claude/skills/analyst.md** - The analyst skill

---

**Last Updated:** February 10, 2026
