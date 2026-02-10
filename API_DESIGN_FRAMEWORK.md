# API Design Framework & Analyst Questions

## Existing API Analysis: Companies & Employees

### Companies API Features

```
GET    /api/companies
       - Gets list of all companies
       - Authorization: Manager role
       - Rate limiting: Enabled (SpecificPolicy)
       - Output caching: 120 seconds
       - Returns: CompanyDto[]

GET    /api/companies/{id}
       - Gets single company by ID
       - Authorization: Public
       - Output caching: 60 seconds
       - ETag support: Yes (for conditional requests)
       - Returns: CompanyDto

GET    /api/companies/collection/({ids})
       - Gets multiple companies by ID collection
       - Uses custom ArrayModelBinder
       - Authorization: Public
       - Returns: CompanyDto[]

POST   /api/companies
       - Create single company
       - Validation: Required (ValidationFilterAttribute)
       - DTOs: CompanyForCreationDto
       - HTTP Status: 201 Created
       - Returns: CompanyDto with Location header

POST   /api/companies/collection
       - Create multiple companies
       - Bulk operation
       - DTOs: IEnumerable<CompanyForCreationDto>
       - HTTP Status: 201 Created
       - Returns: Newly created companies

PUT    /api/companies/{id}
       - Full update (replace entire resource)
       - Validation: Required
       - DTOs: CompanyForUpdateDto
       - HTTP Status: 204 No Content
       - Returns: Nothing (standard REST)

DELETE /api/companies/{id}
       - Delete company
       - Authorization: Public
       - HTTP Status: 204 No Content
       - Cascade: Yes (deletes related employees)

OPTIONS /api/companies
       - CORS/HTTP method negotiation
       - Returns: Allow header with supported methods
```

### Employees API Features

```
GET    /api/companies/{companyId}/employees
       - Gets all employees for a company
       - Pagination support: Yes (EmployeeParameters)
       - Sorting support: Yes (through parameters)
       - Filtering support: Yes (through parameters)
       - Media type validation: Yes
       - HATEOAS links: Optional (based on Accept header)
       - Meta-data: X-Pagination header
       - Returns: EmployeeDto[] or LinkedRepresentation

HEAD   /api/companies/{companyId}/employees
       - Same as GET but no response body
       - Used for checking availability

GET    /api/companies/{companyId}/employees/{id}
       - Gets single employee
       - Authorization: Public
       - Returns: EmployeeDto

POST   /api/companies/{companyId}/employees
       - Create employee for company
       - Validation: Required
       - DTOs: EmployeeForCreationDto
       - HTTP Status: 201 Created
       - Returns: EmployeeDto with Location header

PUT    /api/companies/{companyId}/employees/{id}
       - Full update (replace)
       - Validation: Required
       - DTOs: EmployeeForUpdateDto
       - HTTP Status: 204 No Content
       - Returns: Nothing

PATCH  /api/companies/{companyId}/employees/{id}
       - Partial update (JSON Patch)
       - DTOs: JsonPatchDocument<EmployeeForUpdateDto>
       - Format: RFC 6902
       - HTTP Status: 204 No Content
       - Returns: Nothing

DELETE /api/companies/{companyId}/employees/{id}
       - Delete employee
       - HTTP Status: 204 No Content
       - Returns: Nothing
```

---

## API Design Options Reference

### 1. **Basic Operations (CRUD)**
- ✅ GET all (list)
- ✅ GET by ID (single)
- ✅ POST (create)
- ✅ PUT (full update)
- ✅ DELETE (delete)
- ✅ PATCH (partial update)

### 2. **Collection Operations**
- ✅ GET multiple by IDs: `/api/resource/collection/({ids})`
- ✅ POST multiple: `POST /api/resource/collection`
- ❓ PATCH multiple: `PATCH /api/resource/collection`
- ❓ DELETE multiple: `DELETE /api/resource/collection`

### 3. **Query Parameters & Filtering**
- ✅ Pagination: `?pageNumber=1&pageSize=10`
- ✅ Sorting: `?orderBy=name&sortOrder=asc`
- ✅ Filtering: `?searchTerm=value&minSalary=50000`
- ❓ Full-text search: `?q=search+term`
- ❓ Field selection: `?fields=id,name,email`

### 4. **Caching Strategies**
- ✅ Output caching: `[OutputCache(Duration = 60)]`
- ✅ ETag support: For conditional requests
- ✅ Cache-Control headers: Standard HTTP caching
- ❓ Cache invalidation: When to clear caches
- ❓ Distributed cache: Redis integration

### 5. **HTTP Features**
- ✅ Status codes: 200, 201, 204, 400, 404, 422, 500
- ✅ Location header: For created resources
- ✅ ETag header: For concurrency control
- ✅ X-Pagination header: For pagination metadata
- ✅ Allow header: For OPTIONS request
- ✅ HATEOAS links: Navigation links (Employees has this)
- ❓ Content negotiation: JSON, XML, CSV

### 6. **Authorization & Security**
- ✅ Role-based: `[Authorize(Roles = "Manager")]`
- ✅ Rate limiting: `[EnableRateLimiting("SpecificPolicy")]`
- ✅ Rate limit disable: `[DisableRateLimiting]`
- ❓ Permission-based: Fine-grained access control
- ❓ Resource-level security: User owns resource
- ❓ Audit logging: Track changes

### 7. **Validation**
- ✅ DTO validation: `[ServiceFilter(typeof(ValidationFilterAttribute))]`
- ✅ Model state: Automatic validation on POST/PUT/PATCH
- ✅ Validation attributes: Data Annotations on DTOs
- ❓ Custom validation: Domain rules
- ❓ Async validation: Server-side async checks

### 8. **Response Handling**
- ✅ Standard DTOs: Separated from domain entities
- ✅ Error responses: StandardErrorDetails format
- ✅ Success responses: JSON/XML
- ✅ Null coalescing: Proper null handling
- ❓ Envelope pattern: Wrap responses
- ❓ Problem details: RFC 7807 format

### 9. **API Versioning**
- ✅ Multiple versions: v1, v2
- ✅ Route-based: `/api/v1/` vs `/api/v2/`
- ✅ Group by version: `[ApiExplorerSettings(GroupName = "v1")]`
- ❓ Header-based: `Accept: application/vnd.api+json;version=2`
- ❓ Query parameter: `?api-version=2`

### 10. **Advanced Features**
- ✅ Nested resources: `/api/companies/{id}/employees`
- ✅ Bulk operations: Create/update multiple
- ✅ Partial updates: PATCH with JSON Patch
- ✅ Pagination metadata: X-Pagination header
- ✅ Hypermedia: HATEOAS links
- ❓ Filtering by related fields: Complex queries
- ❓ Aggregate operations: COUNT, SUM, AVG
- ❓ Async operations: Long-running processes

### 11. **Documentation**
- ✅ Swagger/OpenAPI: Auto-generated from attributes
- ✅ XML comments: Summary, param, returns
- ✅ Response types: `[ProducesResponseType(201)]`
- ✅ Swagger grouping: `[ApiExplorerSettings(GroupName = "v1")]`
- ❓ Usage examples: Real-world examples
- ❓ Rate limit documentation: Limits per endpoint

### 12. **Performance**
- ✅ Async/await: All operations are async
- ✅ Output caching: By endpoint
- ✅ ETag support: Conditional requests
- ✅ Pagination: Limit data transfer
- ❓ Lazy loading: Load related entities on demand
- ❓ Eager loading: Load related entities up front
- ❓ Compression: Gzip responses

---

## Analyst Agent: Questions to Ask

When someone requests a new API feature, the **Analyst Agent** should ask these questions:

### Phase 1: Basic Requirements

```
📋 BASIC REQUIREMENTS
─────────────────────────────────────────────────────────────

1. What is the resource you want to create an API for?
   Example: Quotes, Invoices, Projects, Customers

2. What is the PRIMARY unique identifier?
   - GUID? (recommended: ✅)
   - String/Code? (SKU, OrderNumber)
   - Numeric ID? (legacy)

3. Does this resource have RELATIONSHIPS to other resources?
   Examples:
   - Quote has Company (many quotes per company)
   - Quote has Employee (who created it)
   - Quote has Items (line items)

   Format: "Quote --(1:many)--> Company"
                "Quote --(1:many)--> QuoteItems"
```

### Phase 2: Core CRUD Operations

```
🔧 CORE OPERATIONS
─────────────────────────────────────────────────────────────

1. Which operations do you need?

   [ ] GET all / List
       → Do you need pagination? Sorting? Filtering?

   [ ] GET by ID / Single
       → Do you need ETag support for caching?

   [ ] POST / Create
       → Single or bulk creation too?

   [ ] PUT / Full Update
       → Do you support full replacement?

   [ ] PATCH / Partial Update
       → Do you want JSON Patch support?

   [ ] DELETE / Remove
       → Soft delete (mark as deleted) or hard delete?
       → Cascade to related records?

2. Special collection operations?
   [ ] Get multiple by IDs: GET /api/quotes/collection/({ids})
   [ ] Create bulk: POST /api/quotes/collection
```

### Phase 3: Query & Filtering

```
🔍 FILTERING & SEARCH
─────────────────────────────────────────────────────────────

1. Do you need pagination?
   [ ] Yes → Page size? (default: 10, 20, 50?)
   [ ] No

2. Do you need sorting?
   [ ] Yes → What fields? (name, date, status, price?)
   [ ] No

3. Do you need filtering?
   [ ] Yes → What filters?
       - By status? (Draft, Approved, Sent)
       - By date range? (created between X and Y)
       - By amount? (min/max)
       - By owner? (user, employee, company)
   [ ] No

4. Do you need search?
   [ ] Full-text search: ?q=search+term
   [ ] No

5. Do you need field selection (only return specific fields)?
   [ ] Yes: ?fields=id,name,amount (saves bandwidth)
   [ ] No
```

### Phase 4: Caching & Performance

```
⚡ CACHING & PERFORMANCE
─────────────────────────────────────────────────────────────

1. Should GET responses be cached?
   [ ] Yes → For how long?
       - GET all: 60s, 120s, 5min?
       - GET by ID: 60s, 5min, 10min?
   [ ] No (changes frequently)

2. Do you need ETag support?
   [ ] Yes (for conditional requests, save bandwidth)
   [ ] No

3. Do you need HEAD requests?
   [ ] Yes (check if resource exists without downloading)
   [ ] No

4. Large datasets expected?
   [ ] Yes → Pagination + streaming?
   [ ] No
```

### Phase 5: Authorization & Security

```
🔐 AUTHORIZATION & SECURITY
─────────────────────────────────────────────────────────────

1. Who can access this API?
   [ ] Public (no auth required)
   [ ] Authenticated users only
   [ ] Specific roles: Manager, Employee, Administrator?
   [ ] Resource owner only (user owns the resource)

2. Different permissions per operation?
   GET all:    [ ] Public [ ] Manager [ ] Owner
   GET by ID:  [ ] Public [ ] Manager [ ] Owner
   CREATE:     [ ] Public [ ] Manager [ ] Owner
   UPDATE:     [ ] Public [ ] Manager [ ] Owner
   DELETE:     [ ] Public [ ] Manager [ ] Owner

3. Do you need rate limiting?
   [ ] Yes → Per endpoint or per user?
   [ ] No

4. Do you need audit logging?
   [ ] Yes (track who did what and when)
   [ ] No
```

### Phase 6: Response Handling

```
📤 RESPONSE HANDLING
─────────────────────────────────────────────────────────────

1. What status codes do you want to return?
   ✅ Always: 200 (OK), 201 (Created), 204 (No Content)
   ✅ Always: 400 (Bad Request), 404 (Not Found)
   ✅ Always: 422 (Unprocessable Entity), 500 (Server Error)

   Additional:
   [ ] 304 (Not Modified - with ETag)
   [ ] 409 (Conflict - concurrent update)
   [ ] 429 (Too Many Requests - rate limited)

2. What fields should the response include?

   For Quote, example structure:
   {
     "id": "guid",
     "quoteNumber": "string",
     "amount": "decimal",
     "status": "enum",
     "createdAt": "datetime",
     "companyId": "guid",
     "items": [...]  // Include nested items?
   }

3. Do you need related data in responses?
   Examples:
   [ ] Include Company info in Quote response?
   [ ] Include Employee info (creator)?
   [ ] Include all QuoteItems?
   [ ] Or just IDs/links?

4. Do you want HATEOAS links?
   [ ] Yes (include navigation links like _links.self, _links.all)
   [ ] No
```

### Phase 7: Special Operations

```
⚙️ SPECIAL OPERATIONS
─────────────────────────────────────────────────────────────

1. Custom actions needed?
   [ ] Approve/Reject: POST /api/quotes/{id}/approve
   [ ] Send/Archive: POST /api/quotes/{id}/send
   [ ] Export: GET /api/quotes/{id}/export?format=pdf
   [ ] Duplicate: POST /api/quotes/{id}/duplicate
   [ ] Lock/Unlock: Status change operations

2. Nested resources?
   [ ] Yes: /api/quotes/{quoteId}/items
   [ ] No

3. Bulk operations on collection?
   [ ] PATCH /api/quotes/collection (update multiple)
   [ ] DELETE /api/quotes/collection (delete multiple)
   [ ] No bulk operations

4. Async operations (long-running)?
   [ ] Yes (return 202 Accepted, check status later)
   [ ] No
```

### Phase 8: Versioning

```
📌 API VERSIONING
─────────────────────────────────────────────────────────────

1. Will this API evolve over time?
   [ ] Yes → Need v2 support?
   [ ] No

2. How to handle versions?
   [ ] Route-based: /api/v1/quotes (current approach)
   [ ] Header-based: Accept: application/vnd.api+json;version=2
   [ ] Query parameter: ?api-version=2
```

---

## Analyst Agent Output Example

```
🤖 ANALYST AGENT SUMMARY - Quotes API
═══════════════════════════════════════════════════════════

Based on your requirements, here's what I understand:

RESOURCE: Quote
- Primary Key: GUID
- Related to: Company (many:1), Employee (many:1), QuoteItems (1:many)

OPERATIONS REQUIRED:
✓ GET /api/companies/{companyId}/quotes
  - Pagination: Yes (page size: 10)
  - Sorting: By date, amount
  - Filtering: By status, date range
  - Caching: 60 seconds

✓ GET /api/companies/{companyId}/quotes/{id}
  - ETag support: Yes
  - Caching: 120 seconds

✓ POST /api/companies/{companyId}/quotes
  - Create with validation
  - Returns: 201 Created

✓ PUT /api/companies/{companyId}/quotes/{id}
  - Full update

✓ PATCH /api/companies/{companyId}/quotes/{id}
  - Partial update with JSON Patch

✓ DELETE /api/companies/{companyId}/quotes/{id}
  - Hard delete (no cascade needed)

SPECIAL ACTIONS:
✓ POST /api/companies/{companyId}/quotes/{id}/approve
✓ POST /api/companies/{companyId}/quotes/{id}/send
✓ GET /api/companies/{companyId}/quotes/{id}/pdf
  - Export as PDF

AUTHORIZATION:
✓ Manager role required for all operations
✓ Rate limiting: Standard policy

RESPONSE STRUCTURE:
- Include related Company info (name, address)
- Include all QuoteItems with details
- HATEOAS links for navigation

───────────────────────────────────────────────────────────

This aligns with ARCHITECT_CHECKLIST.md and your clean architecture.

Ready to proceed? Any clarifications needed?
```

---

## How to Use This Framework

### For Developers:

1. **When someone asks for a new API:**
   ```
   User: "We need a Quotes API"

   → Trigger Analyst Agent
   → Agent asks Phase 1-8 questions
   → Developer answers
   → Agent generates summary
   → Developer can now build the feature
   ```

2. **Analyst Agent should be automated:**
   - Can be a `.claude/analyst-agent.md` file
   - Or a Claude skill: `/analyst`
   - Takes feature request as input
   - Outputs detailed specification

---

## Integration with Your System

```
Feature Request
      ↓
   Analyst Agent ← (asks detailed questions)
      ↓
   Feature Specification
      ↓
   Developer Agent ← (reads checklist & spec)
      ↓
   Builds feature following architecture
      ↓
   Architect Agent ← (reviews compliance)
      ↓
   APPROVED / REJECTED
```

---

## DTOs Per Resource

Based on the analysis, every resource needs:

```csharp
// Read
public class QuoteDto
{
    public Guid Id { get; set; }
    public string QuoteNumber { get; set; }
    public decimal Amount { get; set; }
    // ... etc
}

// Create
public class QuoteForCreationDto
{
    [Required]
    public string QuoteNumber { get; set; }

    [Required]
    [Range(0.01, double.MaxValue)]
    public decimal Amount { get; set; }
    // ... no Id, dates auto-generated
}

// Update
public class QuoteForUpdateDto
{
    [Required]
    public string QuoteNumber { get; set; }

    [Required]
    [Range(0.01, double.MaxValue)]
    public decimal Amount { get; set; }
    // ... differs from Create? Include what's updatable
}

// Patch
public class QuoteForPatchDto : QuoteForUpdateDto
{
    // Same as update, allows partial changes
}
```

---

**Last Updated:** February 10, 2026
