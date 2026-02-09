# Code Review Standards - Architecture Enforcement

Richtlijnen voor peer reviews om de architectuur consistent te houden en kwaliteit te garanderen.

---

## Reviewers Verantwoordelijkheden

### 1. Architecture Review

**Controleer:**

- [ ] Volgt het de Clean Layered Architecture?
  - Presentation Layer → Service Layer → Repository Layer → Database
  - Geen skip van lagen
  - Geen backwards dependencies

- [ ] Zijn alle lagen aanwezig voor nieuwe features?
  - Entity/Model
  - Repository + Interface
  - Service + Interface
  - Controller
  - DTO

**Red Flags:**

```csharp
// ❌ RED FLAG: Repository in Controller
[HttpGet]
public async Task<IActionResult> GetProjects()
{
    var projects = await _repositoryContext.Projects.ToListAsync();
    return Ok(projects);
}

// ❌ RED FLAG: Direct database access from Service
public class ProjectService
{
    public async Task<Project> GetAsync(Guid id)
    {
        using (var context = new RepositoryContext())
        {
            return await context.Projects.FindAsync(id);
        }
    }
}

// ❌ RED FLAG: Service-to-Service dependency (circular risk)
public class CompanyService
{
    private readonly IProjectService _projectService; // Uses another service

    public async Task DeleteCompanyAsync(Guid id)
    {
        var projects = await _projectService.GetCompanyProjectsAsync(id);
        // ... logic ...
    }
}
```

---

### 2. Dependency Injection Review

**Controleer:**

- [ ] Constructor injection gebruikt?
- [ ] Dependencies zijn interfaces, niet implementations?
- [ ] Service geregistreerd in `Program.cs` via extension method?
- [ ] Geen `new` keyword voor service instanties?

**Goed Voorbeeld:**

```csharp
// ✓ Correct
public class ProjectService : IProjectService
{
    private readonly IRepositoryManager _repository;

    public ProjectService(IRepositoryManager repository)
    {
        _repository = repository;
    }
}

// In ServiceManager.cs:
public IProjectService Project => _projectService.Value;

// In Program.cs:
builder.Services.AddScoped<IProjectService, ProjectService>();
```

**Slechte Voorbeelden:**

```csharp
// ❌ Service Locator Anti-Pattern
var service = ServiceProvider.GetRequiredService<IProjectService>();

// ❌ Direct Instantiation
var repository = new ProjectRepository(context);

// ❌ Static Classes
public static class ProjectHelper
{
    public static void DeleteProject(Guid id) { }
}
```

---

### 3. Data Transfer Object (DTO) Review

**Controleer:**

- [ ] DTOs gebruikt, geen Entities in responses?
- [ ] DTOs hebben aparte Create/Update/Read variants?
- [ ] Geen entity navigation properties in DTOs?
- [ ] DTOs bevatten enkel response-relevante properties?

**Goed Voorbeeld:**

```csharp
// ✓ Correct
public record ProjectDto
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public Guid CompanyId { get; set; }
}

public record CreateProjectDto
{
    public string Name { get; set; }
    public Guid CompanyId { get; set; }
}

// Controller
[HttpPost]
public async Task<ActionResult<ProjectDto>> Create(CreateProjectDto dto)
{
    var project = await _service.CreateAsync(dto);
    return Ok(project); // Returns ProjectDto
}
```

**Slechte Voorbeelden:**

```csharp
// ❌ Entities direct exposed
[HttpGet]
public async Task<ActionResult<Project>> GetProject(Guid id)
{
    var project = await _service.GetAsync(id);
    return Ok(project); // Exposes all Entity properties and relations
}

// ❌ Navigation properties in DTO
public record ProjectDto
{
    public string Name { get; set; }
    public CompanyDto Company { get; set; } // Could cause circular refs
    public IEnumerable<EmployeeDto> Employees { get; set; }
}

// ❌ Database ID in request DTO
public record CreateProjectDto
{
    public Guid Id { get; set; } // Shouldn't be settable by client
    public string Name { get; set; }
}
```

---

### 4. Error Handling Review

**Controleer:**

- [ ] Custom exceptions defined voor business logic errors?
- [ ] Try-catch of fluent error handling pattern?
- [ ] Appropriate HTTP status codes?
- [ ] Geen stack traces in production responses?

**Goed Voorbeeld:**

```csharp
// Custom Exception in Entities/Exceptions
public class EntityNotFoundException : Exception
{
    public EntityNotFoundException(string message) : base(message) { }
}

// Service usage
public async Task<ProjectDto> GetProjectAsync(Guid id)
{
    var project = await _repository.Project.GetByIdAsync(id, trackChanges: false);
    if (project is null)
        throw new EntityNotFoundException($"Project with id {id} was not found");

    return _mapper.Map<ProjectDto>(project);
}

// Controller handling
[HttpGet("{id}")]
public async Task<IActionResult> GetProject(Guid id)
{
    var project = await _serviceManager.Project.GetProjectAsync(id);
    return Ok(project);
}
// GlobalExceptionHandler catches and returns 404
```

**Slechte Voorbeelden:**

```csharp
// ❌ Returning null instead of throwing
public async Task<ProjectDto> GetProjectAsync(Guid id)
{
    var project = await _repository.Project.GetByIdAsync(id, false);
    return _mapper.Map<ProjectDto?>(project); // Returns null, unclear to caller
}

// ❌ No error handling in controller
[HttpDelete("{id}")]
public async Task<IActionResult> Delete(Guid id)
{
    await _service.DeleteAsync(id); // What if fails?
    return NoContent();
}

// ❌ Exposing stack trace
catch (Exception ex)
{
    return BadRequest(new { error = ex.ToString() }); // Don't expose details!
}
```

---

### 5. Entity & Database Review

**Controleer:**

- [ ] Entity configuratie met Fluent API?
- [ ] Foreign keys correct gedefinieerd?
- [ ] Cascade delete behavior appropriate?
- [ ] Entity Framework migration present?
- [ ] No raw SQL queries in production code?

**Goed Voorbeeld:**

```csharp
// Configuration
public class ProjectConfiguration : IEntityTypeConfiguration<Project>
{
    public void Configure(EntityTypeBuilder<Project> builder)
    {
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name)
            .IsRequired()
            .HasMaxLength(100);

        builder.HasOne(x => x.Company)
            .WithMany()
            .HasForeignKey(x => x.CompanyId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.ToTable("Projects");
    }
}

// DbContext
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.ApplyConfiguration(new ProjectConfiguration());
}
```

**Slechte Voorbeelden:**

```csharp
// ❌ No Fluent API configuration
public class Project
{
    [Key]
    public Guid Id { get; set; }

    [MaxLength(100)]
    public string Name { get; set; }
}

// ❌ No migration
// Changes to database schema without migration file

// ❌ Raw SQL (unless absolutely necessary)
var projects = await _context.Projects
    .FromSqlRaw("SELECT * FROM Projects WHERE Name LIKE '%{0}%'", searchTerm)
    .ToListAsync(); // SQL Injection risk!
```

---

### 6. Async/Await Review

**Controleer:**

- [ ] Async methods overal waar I/O plaatsvindt?
- [ ] Geen `.Result` of `.Wait()` blocking calls?
- [ ] Geen async void (except event handlers)?
- [ ] ConfigureAwait(false) voor library code?

**Goed Voorbeeld:**

```csharp
// ✓ Correct async chain
public async Task<ProjectDto> GetProjectAsync(Guid id)
{
    var project = await _repository.Project.GetByIdAsync(id, trackChanges: false);
    return _mapper.Map<ProjectDto>(project);
}

// ✓ Async all the way
[HttpGet("{id}")]
public async Task<IActionResult> GetProject(Guid id)
{
    var project = await _serviceManager.Project.GetProjectAsync(id);
    return Ok(project);
}
```

**Slechte Voorbeelden:**

```csharp
// ❌ Blocking call (.Result)
public ProjectDto GetProject(Guid id)
{
    var project = await _repository.Project.GetByIdAsync(id, false).Result;
    return _mapper.Map<ProjectDto>(project);
}

// ❌ async void (never!)
private async void OnProjectCreated(ProjectDto project)
{
    await _service.ProcessAsync(project); // Can't handle exceptions
}

// ❌ Mix of sync and async
public Task<ProjectDto> GetProjectAsync(Guid id)
{
    var project = _repository.Project.GetByIdAsync(id, false).Result;
    return Task.FromResult(_mapper.Map<ProjectDto>(project));
}
```

---

### 7. Repository Pattern Review

**Controleer:**

- [ ] Repository interface gedefinieerd?
- [ ] CRUD operations in repository?
- [ ] Complex queries in repository?
- [ ] `trackChanges` parameter gebruikt waar van toepassing?
- [ ] Repository.SaveAsync() via RepositoryManager?

**Goed Voorbeeld:**

```csharp
// Interface
public interface IProjectRepository
{
    Task<Project?> GetByIdAsync(Guid id, bool trackChanges);
    Task<IEnumerable<Project>> GetAllAsync(bool trackChanges);
    void Create(Project project);
    void Update(Project project);
    void Delete(Project project);
}

// Implementation
public class ProjectRepository : RepositoryBase<Project>, IProjectRepository
{
    public async Task<Project?> GetByIdAsync(Guid id, bool trackChanges) =>
        await FindByCondition(x => x.Id == id, trackChanges).FirstOrDefaultAsync();

    public async Task<IEnumerable<Project>> GetAllAsync(bool trackChanges) =>
        await FindAll(trackChanges).ToListAsync();

    public void Create(Project project) => Create(project);
    public void Update(Project project) => Update(project);
    public void Delete(Project project) => Delete(project);
}

// Usage in Service
var project = await _repository.Project.GetByIdAsync(id, trackChanges: true);
project.Name = "Updated";
_repository.Project.Update(project);
await _repository.SaveAsync();
```

**Slechte Voorbeelden:**

```csharp
// ❌ No repository interface
public class ProjectRepository { }

// ❌ Business logic in repository
public class ProjectRepository
{
    public async Task<ProjectDto> GetProjectWithValidationsAsync(Guid id)
    {
        // Validation logic belongs in Service, not Repository!
    }
}

// ❌ SaveAsync() called directly from repository
public class ProjectRepository
{
    public async Task CreateProjectAsync(Project project)
    {
        Create(project);
        await _context.SaveChangesAsync(); // Should be via Manager
    }
}
```

---

### 8. AutoMapper Review

**Controleer:**

- [ ] Mappings gedefinieerd in een Profile?
- [ ] Reverse mappings waar nodig?
- [ ] Custom mapping logic voor complexe cases?
- [ ] Profile geregistreerd in Program.cs?

**Goed Voorbeeld:**

```csharp
public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // Read mapping
        CreateMap<Project, ProjectDto>();

        // Create mapping
        CreateMap<CreateProjectDto, Project>();

        // Update mapping (reverse)
        CreateMap<UpdateProjectDto, Project>();

        // Complex mapping
        CreateMap<Company, CompanyWithProjectsDto>()
            .ForMember(dest => dest.ProjectCount,
                opt => opt.MapFrom(src => src.Projects.Count));
    }
}

// Program.cs
builder.Services.AddAutoMapper(typeof(MappingProfile));
```

**Slechte Voorbeelden:**

```csharp
// ❌ Manual mapping in Service
var dto = new ProjectDto
{
    Id = project.Id,
    Name = project.Name,
    // ... 20 more lines of manual mapping
};

// ❌ Mapping in Controller
[HttpGet("{id}")]
public async Task<IActionResult> GetProject(Guid id)
{
    var project = await _service.GetAsync(id);
    var dto = new ProjectDto { Id = project.Id, Name = project.Name };
    return Ok(dto);
}

// ❌ Profile niet geregistreerd
// AutoMapper crashes at runtime
```

---

### 9. Validation Review

**Controleer:**

- [ ] Data Annotations op DTOs?
- [ ] ValidationFilterAttribute op POST/PUT?
- [ ] Custom validation logic in Service?
- [ ] Meaningful error messages?

**Goed Voorbeeld:**

```csharp
public record CreateProjectDto
{
    [Required(ErrorMessage = "Project name is required")]
    [StringLength(100, MinimumLength = 3)]
    public string Name { get; set; }

    [StringLength(500)]
    public string? Description { get; set; }

    [Required]
    public Guid CompanyId { get; set; }
}

// Controller
[HttpPost]
[ServiceFilter(typeof(ValidationFilterAttribute))]
public async Task<IActionResult> CreateProject(CreateProjectDto dto)
{
    // If we reach here, validation passed
    var project = await _serviceManager.Project.CreateAsync(dto);
    return CreatedAtAction(nameof(GetProject), new { id = project.Id }, project);
}
```

**Slechte Voorbeelden:**

```csharp
// ❌ No validation
public record CreateProjectDto
{
    public string Name { get; set; }
    public Guid CompanyId { get; set; }
}

// ❌ Validation in Controller
[HttpPost]
public async Task<IActionResult> CreateProject(CreateProjectDto dto)
{
    if (string.IsNullOrEmpty(dto.Name))
        return BadRequest("Name required");
    if (dto.Name.Length < 3)
        return BadRequest("Name too short");
    // ... more validation logic
}

// ❌ Validation niet geactiveerd
// ValidationFilterAttribute not applied
```

---

### 10. API Documentation Review

**Controleer:**

- [ ] XML comments op public methods?
- [ ] Summary, param, returns beschrijvingen?
- [ ] HTTP verb en status codes correct?
- [ ] Swagger comments consistent?

**Goed Voorbeeld:**

```csharp
/// <summary>
/// Retrieves a specific project by its ID
/// </summary>
/// <param name="projectId">The unique identifier of the project</param>
/// <returns>The project details if found</returns>
/// <response code="200">Project found and returned</response>
/// <response code="404">Project not found</response>
[HttpGet("{projectId:guid}")]
public async Task<IActionResult> GetProject(Guid projectId)
{
    var project = await _serviceManager.Project.GetProjectAsync(projectId);
    if (project is null)
        return NotFound();

    return Ok(project);
}
```

**Slechte Voorbeelden:**

```csharp
// ❌ No documentation
[HttpGet("{id}")]
public async Task<IActionResult> GetProject(Guid id)
{
    return Ok(await _service.GetAsync(id));
}

// ❌ Vague documentation
/// <summary>
/// Get project
/// </summary>
```

---

## Red Flags Checklist

### 🚩 Critical Issues (Must Fix)

- [ ] Entity exposed directly in API response
- [ ] Database access outside Repository layer
- [ ] Circular dependencies
- [ ] Blocking async calls (.Result, .Wait())
- [ ] No error handling in critical paths
- [ ] Security vulnerabilities (SQL injection, XSS)
- [ ] No migration for database changes

### ⚠️ Warnings (Should Fix)

- [ ] Async void methods (except event handlers)
- [ ] Missing DTOs for API responses
- [ ] Service-to-Service dependencies
- [ ] No validation on input DTOs
- [ ] Missing XML documentation on public APIs
- [ ] Complex logic in Controllers
- [ ] No unit tests

### 💡 Nice to Have (Good Practice)

- [ ] Consistent error messages
- [ ] Consistent naming conventions
- [ ] Comprehensive logging
- [ ] Performance optimizations
- [ ] Integration tests
- [ ] Swagger/OpenAPI completeness

---

## Review Process

### Stap 1: Overview
- [ ] Begrijp wat PR probeert op te lossen
- [ ] Check PR description en linked issues

### Stap 2: Architecture Check
- [ ] Verwerk layer-by-layer
- [ ] Controleer afhankelijkheden
- [ ] Zoek naar pattern deviations

### Stap 3: Code Quality
- [ ] Controleer naming conventions
- [ ] Verwijder duplicatie
- [ ] Controleer error handling

### Stap 4: Testing
- [ ] Zijn tests aanwezig en comprehensive?
- [ ] Worden edge cases getest?

### Stap 5: Documentation
- [ ] Is code documentatie compleet?
- [ ] Moeten ARCHITECTURE.md updates?

### Stap 6: Provide Feedback
- Positive: "I like how you structured..."
- Constructive: "This might be better as..."
- Questions: "Why did you choose...?"

---

## Comment Templates

### Architecture Issue
```markdown
**Architecture Concern:** This seems to violate our layering principle.

The controller is accessing the repository directly instead of using the service layer.
Please refactor to go through `ServiceManager`.

Related: ARCHITECTURE.md - Data Flow section
```

### Missing Abstraction
```markdown
**Missing Abstraction:** According to our architecture, this should have an interface.

Please create `I[FeatureName]Repository` interface in the Contracts project and implement it.

See: DEVELOPMENT_GUIDELINES.md - Quick Start
```

### DTO Exposure
```markdown
**Security/API Contract:** Entities shouldn't be exposed directly.

Create a DTO instead:
- `[Feature]Dto` for read operations
- `Create[Feature]Dto` for POST
- `Update[Feature]Dto` for PUT

See: CODE_REVIEW_STANDARDS.md - Data Transfer Object Review
```

---

**Last Updated:** 2026-02-09
**Owner:** Development Team
