# Development Guidelines - Offerte Maker API

Praktische richtlijnen voor het toevoegen van nieuwe features en het handhaven van architecturale integriteit.

---

## Quick Start: Toevoegen van een Nieuwe Feature

### Scenario: Een Nieuwe Entity (bijv. "Project")

#### 1. Domain Layer (Entities)

**File:** `Entities/Models/Project.cs`

```csharp
namespace Entities.Models;

public class Project
{
    public Guid Id { get; set; }

    public string Name { get; set; }

    public string Description { get; set; }

    public Guid CompanyId { get; set; }

    public Company? Company { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? UpdatedDate { get; set; }
}
```

**Conventies:**
- `Guid Id` als primary key
- Guid voor foreign keys (`CompanyId`)
- Nullable reference properties (C# nullable reference types)
- Timestamps voor audit trail
- Relationship properties naar related entities

#### 2. Data Access Layer

**File:** `Repository/Configuration/ProjectConfiguration.cs`

```csharp
using Entities.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Repository.Configuration;

public class ProjectConfiguration : IEntityTypeConfiguration<Project>
{
    public void Configure(EntityTypeBuilder<Project> builder)
    {
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(x => x.Description)
            .HasMaxLength(500);

        builder.Property(x => x.CreatedDate)
            .HasDefaultValueSql("GETUTCDATE()");

        builder.HasOne(x => x.Company)
            .WithMany()
            .HasForeignKey(x => x.CompanyId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.ToTable("Projects");
    }
}
```

**Update:** `RepositoryContext.cs`

```csharp
public DbSet<Project> Projects { get; set; }

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // ... existing configurations ...
    modelBuilder.ApplyConfiguration(new ProjectConfiguration());
}
```

**File:** `Contracts/IProjectRepository.cs`

```csharp
using Entities.Models;

namespace Contracts;

public interface IProjectRepository
{
    Task<IEnumerable<Project>> GetAllProjectsAsync(bool trackChanges);
    Task<Project?> GetProjectByIdAsync(Guid projectId, bool trackChanges);
    void CreateProject(Project project);
    void UpdateProject(Project project);
    void DeleteProject(Project project);
}
```

**File:** `Repository/ProjectRepository.cs`

```csharp
using Contracts;
using Entities.Models;
using Microsoft.EntityFrameworkCore;

namespace Repository;

public class ProjectRepository : RepositoryBase<Project>, IProjectRepository
{
    public ProjectRepository(RepositoryContext repositoryContext)
        : base(repositoryContext)
    {
    }

    public async Task<IEnumerable<Project>> GetAllProjectsAsync(bool trackChanges) =>
        await FindAll(trackChanges).OrderBy(x => x.Name).ToListAsync();

    public async Task<Project?> GetProjectByIdAsync(Guid projectId, bool trackChanges) =>
        await FindByCondition(x => x.Id.Equals(projectId), trackChanges).FirstOrDefaultAsync();

    public void CreateProject(Project project) => Create(project);

    public void UpdateProject(Project project) => Update(project);

    public void DeleteProject(Project project) => Delete(project);
}
```

**Update:** `RepositoryManager.cs`

```csharp
private readonly Lazy<IProjectRepository> _projectRepository;

public RepositoryManager(RepositoryContext repositoryContext)
{
    _repositoryContext = repositoryContext;
    _projectRepository = new Lazy<IProjectRepository>(() => new ProjectRepository(repositoryContext));
    // ... existing repositories ...
}

public IProjectRepository Project => _projectRepository.Value;
```

**EF Migration:**

```bash
cd CompanyEmployees
dotnet ef migrations add AddProjectEntity
dotnet ef database update
```

#### 3. Business Logic Layer

**File:** `Service.Contracts/IProjectService.cs`

```csharp
using Shared.DataTransferObjects;

namespace Service.Contracts;

public interface IProjectService
{
    Task<IEnumerable<ProjectDto>> GetAllProjectsAsync();
    Task<ProjectDto?> GetProjectAsync(Guid projectId);
    Task<ProjectDto> CreateProjectAsync(CreateProjectDto projectDto);
    Task UpdateProjectAsync(Guid projectId, UpdateProjectDto projectDto);
    Task DeleteProjectAsync(Guid projectId);
}
```

**File:** `Service/ProjectService.cs`

```csharp
using AutoMapper;
using Contracts;
using Entities.Models;
using Service.Contracts;
using Shared.DataTransferObjects;

namespace Service;

public class ProjectService : IProjectService
{
    private readonly IRepositoryManager _repository;
    private readonly IMapper _mapper;

    public ProjectService(IRepositoryManager repository, IMapper mapper)
    {
        _repository = repository;
        _mapper = mapper;
    }

    public async Task<IEnumerable<ProjectDto>> GetAllProjectsAsync()
    {
        var projects = await _repository.Project.GetAllProjectsAsync(trackChanges: false);
        return _mapper.Map<IEnumerable<ProjectDto>>(projects);
    }

    public async Task<ProjectDto?> GetProjectAsync(Guid projectId)
    {
        var project = await _repository.Project.GetProjectByIdAsync(projectId, trackChanges: false);
        if (project is null)
            return null;

        return _mapper.Map<ProjectDto>(project);
    }

    public async Task<ProjectDto> CreateProjectAsync(CreateProjectDto projectDto)
    {
        var project = _mapper.Map<Project>(projectDto);
        _repository.Project.CreateProject(project);
        await _repository.SaveAsync();

        return _mapper.Map<ProjectDto>(project);
    }

    public async Task UpdateProjectAsync(Guid projectId, UpdateProjectDto projectDto)
    {
        var project = await _repository.Project.GetProjectByIdAsync(projectId, trackChanges: true);
        if (project is null)
            throw new EntityNotFoundException($"Project {projectId} not found");

        _mapper.Map(projectDto, project);
        _repository.Project.UpdateProject(project);
        await _repository.SaveAsync();
    }

    public async Task DeleteProjectAsync(Guid projectId)
    {
        var project = await _repository.Project.GetProjectByIdAsync(projectId, trackChanges: false);
        if (project is null)
            throw new EntityNotFoundException($"Project {projectId} not found");

        _repository.Project.DeleteProject(project);
        await _repository.SaveAsync();
    }
}
```

**Update:** `ServiceManager.cs`

```csharp
private readonly Lazy<IProjectService> _projectService;

public ServiceManager(IRepositoryManager repositoryManager, IMapper mapper)
{
    _projectService = new Lazy<IProjectService>(() => new ProjectService(repositoryManager, mapper));
    // ... existing services ...
}

public IProjectService Project => _projectService.Value;
```

#### 4. Shared Layer - DTOs

**File:** `Shared/DataTransferObjects/ProjectDto.cs`

```csharp
namespace Shared.DataTransferObjects;

public record ProjectDto
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public Guid CompanyId { get; set; }
    public DateTime CreatedDate { get; set; }
}

public record CreateProjectDto
{
    public string Name { get; set; }
    public string Description { get; set; }
    public Guid CompanyId { get; set; }
}

public record UpdateProjectDto
{
    public string Name { get; set; }
    public string Description { get; set; }
}
```

#### 5. Presentation Layer - Controller

**File:** `CompanyEmployees.Presentation/Controllers/ProjectsController.cs`

```csharp
using CompanyEmployees.Presentation.ActionFilters;
using Microsoft.AspNetCore.Mvc;
using Service.Contracts;
using Shared.DataTransferObjects;

namespace CompanyEmployees.Presentation.Controllers;

[ApiController]
[Route("api/projects")]
public class ProjectsController : ControllerBase
{
    private readonly IServiceManager _serviceManager;

    public ProjectsController(IServiceManager serviceManager)
    {
        _serviceManager = serviceManager;
    }

    /// <summary>
    /// Get all projects
    /// </summary>
    /// <returns>List of projects</returns>
    [HttpGet]
    public async Task<IActionResult> GetAllProjects()
    {
        var projects = await _serviceManager.Project.GetAllProjectsAsync();
        return Ok(projects);
    }

    /// <summary>
    /// Get a specific project by ID
    /// </summary>
    /// <param name="projectId">The project ID</param>
    /// <returns>The project details</returns>
    [HttpGet("{projectId:guid}")]
    public async Task<IActionResult> GetProject(Guid projectId)
    {
        var project = await _serviceManager.Project.GetProjectAsync(projectId);
        if (project is null)
            return NotFound(new { message = "Project not found" });

        return Ok(project);
    }

    /// <summary>
    /// Create a new project
    /// </summary>
    /// <param name="createProjectDto">Project data</param>
    /// <returns>The created project</returns>
    [HttpPost]
    [ServiceFilter(typeof(ValidationFilterAttribute))]
    public async Task<IActionResult> CreateProject([FromBody] CreateProjectDto createProjectDto)
    {
        var project = await _serviceManager.Project.CreateProjectAsync(createProjectDto);
        return CreatedAtAction(nameof(GetProject), new { projectId = project.Id }, project);
    }

    /// <summary>
    /// Update a project
    /// </summary>
    /// <param name="projectId">The project ID</param>
    /// <param name="updateProjectDto">Updated project data</param>
    /// <returns>No content</returns>
    [HttpPut("{projectId:guid}")]
    [ServiceFilter(typeof(ValidationFilterAttribute))]
    public async Task<IActionResult> UpdateProject(Guid projectId, [FromBody] UpdateProjectDto updateProjectDto)
    {
        await _serviceManager.Project.UpdateProjectAsync(projectId, updateProjectDto);
        return NoContent();
    }

    /// <summary>
    /// Delete a project
    /// </summary>
    /// <param name="projectId">The project ID</param>
    /// <returns>No content</returns>
    [HttpDelete("{projectId:guid}")]
    public async Task<IActionResult> DeleteProject(Guid projectId)
    {
        await _serviceManager.Project.DeleteProjectAsync(projectId);
        return NoContent();
    }
}
```

#### 6. AutoMapper Configuration

**File:** `CompanyEmployees/MappingProfile.cs` (if doesn't exist, create it)

```csharp
using AutoMapper;
using Entities.Models;
using Shared.DataTransferObjects;

namespace CompanyEmployees;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // ... existing mappings ...

        // Project mappings
        CreateMap<Project, ProjectDto>();
        CreateMap<CreateProjectDto, Project>();
        CreateMap<UpdateProjectDto, Project>();
    }
}
```

**Update:** `Program.cs`

```csharp
builder.Services.AddAutoMapper(typeof(MappingProfile));
```

#### 7. Validation (Optional)

**File:** `Shared/DataTransferObjects/ProjectDto.cs` (update)

```csharp
using System.ComponentModel.DataAnnotations;

namespace Shared.DataTransferObjects;

public record CreateProjectDto
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(100, MinimumLength = 3,
        ErrorMessage = "Name must be between 3 and 100 characters")]
    public string Name { get; set; }

    [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
    public string Description { get; set; }

    [Required(ErrorMessage = "CompanyId is required")]
    public Guid CompanyId { get; set; }
}
```

---

## Common Patterns

### Foutafhandeling

**Pattern:** Exceptions in Domain, handling in Controller

```csharp
// Service layer - throw custom exception
throw new EntityNotFoundException("Project not found");

// Controller - handle exception
try
{
    await _serviceManager.Project.DeleteProjectAsync(projectId);
}
catch (EntityNotFoundException ex)
{
    return NotFound(new { message = ex.Message });
}
```

### Paging & Filtering

**Update in RequestParameters:**

```csharp
namespace Shared.RequestFeatures;

public class RequestParameters
{
    private const int MaxPageSize = 50;

    public int PageNumber { get; set; } = 1;

    private int _pageSize = 10;
    public int PageSize
    {
        get => _pageSize;
        set => _pageSize = (value > MaxPageSize) ? MaxPageSize : value;
    }

    public string? OrderBy { get; set; }

    public string? SearchTerm { get; set; }
}
```

**Controller usage:**

```csharp
[HttpGet]
public async Task<IActionResult> GetAllProjects([FromQuery] RequestParameters parameters)
{
    var projects = await _serviceManager.Project
        .GetAllProjectsAsync(parameters);

    return Ok(projects);
}
```

### Async/Await Pattern

**Always use async methods:**

```csharp
// ✓ Correct
public async Task<ProjectDto> GetProjectAsync(Guid id)
{
    return await _repository.Project.GetProjectByIdAsync(id, false);
}

// ✗ Incorrect - blocking
public ProjectDto GetProject(Guid id)
{
    return _repository.Project.GetProjectByIdAsync(id, false).Result;
}
```

---

## Code Review Checklist

### Voor elke Pull Request

- [ ] **Architecture**
  - [ ] Alle lagen aanwezig (Entity, Repository, Service, Controller)?
  - [ ] Afhankelijkheden in juiste richting (geen circular)?
  - [ ] Manager pattern correct gebruikt?

- [ ] **Data Access**
  - [ ] Repository interface gedefinieerd?
  - [ ] `IRepositoryManager` en `ServiceManager` updated?
  - [ ] EF Configuration aanwezig?
  - [ ] Migration gemaakt?

- [ ] **Business Logic**
  - [ ] Service interface gedefinieerd?
  - [ ] Service in `ServiceManager` geregistreerd?
  - [ ] AutoMapper profiel updated?

- [ ] **API**
  - [ ] DTOs gebruikt (geen Entity exposure)?
  - [ ] Validation filters aanwezig?
  - [ ] HTTP status codes correct?
  - [ ] XML comments op public methods?

- [ ] **Error Handling**
  - [ ] Custom exceptions gedefinieerd?
  - [ ] `GlobalExceptionHandler` covers het scenario?

- [ ] **Testing**
  - [ ] Unit tests aanwezig?
  - [ ] Edge cases covered?
  - [ ] Mocking correct?

---

## Common Mistakes

### ❌ Mistake 1: Entity rechtstreeks in Response

```csharp
// WRONG
[HttpGet("{id}")]
public async Task<ActionResult<Employee>> GetEmployee(Guid id)
{
    var employee = await _repository.Employee.GetAsync(id);
    return Ok(employee); // Exposes all entity properties!
}

// CORRECT
[HttpGet("{id}")]
public async Task<ActionResult<EmployeeDto>> GetEmployee(Guid id)
{
    var employee = await _serviceManager.Employee.GetAsync(id);
    return Ok(employee);
}
```

### ❌ Mistake 2: Circular Dependencies

```csharp
// WRONG - Service depends on Service
public class CompanyService
{
    private readonly EmployeeService _employeeService; // Circular dependency risk
}

// CORRECT - Use RepositoryManager
public class CompanyService
{
    private readonly IRepositoryManager _repository;

    // Access employees via repository
    var employees = await _repository.Employee.GetByCompanyAsync(companyId);
}
```

### ❌ Mistake 3: Blocking Calls

```csharp
// WRONG
public async Task<ProjectDto> GetProjectAsync(Guid id)
{
    return await _repository.Project.GetByIdAsync(id).Result; // Deadlock risk!
}

// CORRECT
public async Task<ProjectDto> GetProjectAsync(Guid id)
{
    return await _repository.Project.GetByIdAsync(id);
}
```

### ❌ Mistake 4: No Error Handling

```csharp
// WRONG
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteProject(Guid id)
{
    await _serviceManager.Project.DeleteAsync(id); // What if not found?
    return NoContent();
}

// CORRECT
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteProject(Guid id)
{
    try
    {
        await _serviceManager.Project.DeleteAsync(id);
        return NoContent();
    }
    catch (EntityNotFoundException)
    {
        return NotFound();
    }
}
```

---

## Performance Tips

1. **Lazy Loading in Manager**
   ```csharp
   private readonly Lazy<IProjectRepository> _projectRepository;
   ```
   Only instantiate when needed

2. **Include/ThenInclude for Relationships**
   ```csharp
   public async Task<Company?> GetCompanyWithEmployeesAsync(Guid id)
   {
       return await FindByCondition(x => x.Id == id)
           .Include(x => x.Employees)
           .FirstOrDefaultAsync();
   }
   ```

3. **Paging Large Datasets**
   ```csharp
   var companies = await _repository.Company
       .FindAll(false)
       .Skip((parameters.PageNumber - 1) * parameters.PageSize)
       .Take(parameters.PageSize)
       .ToListAsync();
   ```

4. **Select Only Required Fields**
   ```csharp
   public async Task<IEnumerable<CompanyNameDto>> GetCompanyNamesAsync()
   {
       return await FindAll(false)
           .Select(x => new CompanyNameDto { Id = x.Id, Name = x.Name })
           .ToListAsync();
   }
   ```

---

## Debugging Tips

### Issue: Entity Not Updating
**Solution:** Ensure `trackChanges: true` in repository call

```csharp
// Wrong - detached entity
var project = await _repository.Project.GetProjectByIdAsync(id, trackChanges: false);
project.Name = "Updated";
await _repository.SaveAsync(); // No changes saved

// Correct - tracked entity
var project = await _repository.Project.GetProjectByIdAsync(id, trackChanges: true);
project.Name = "Updated";
await _repository.SaveAsync(); // Changes saved
```

### Issue: Foreign Key Constraint Error
**Solution:** Ensure parent entity exists and ID is correct

```csharp
var project = new Project
{
    CompanyId = Guid.NewGuid(), // This ID must exist in Companies table
    Name = "New Project"
};
```

### Issue: No Results from Repository
**Solution:** Check query conditions and database data

```csharp
// Add debugging
var projects = await FindByCondition(x => x.Id == projectId, false)
    .ToListAsync();

// Log the generated SQL
// Enable EF Core logging in Program.cs:
services.AddDbContext<RepositoryContext>(options =>
    options.LogTo(Console.WriteLine));
```

---

## Tooling & Commands

### Entity Framework Migrations

```bash
# Create new migration
cd CompanyEmployees
dotnet ef migrations add MigrationName

# Apply migrations
dotnet ef database update

# Revert last migration
dotnet ef migrations remove

# See migration status
dotnet ef migrations list
```

### Building & Testing

```bash
# Build solution
dotnet build

# Run tests
dotnet test

# Build for production
dotnet publish -c Release
```

---

## Version Control

### Commit Message Format

```
[FEATURE|FIX|REFACTOR|CHORE] Brief description

Longer explanation if needed.

Related issue: #123
```

### Branch Naming

```
feature/add-projects-api
fix/bug-in-employee-service
chore/update-dependencies
```

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New Feature
- [ ] Bug Fix
- [ ] Refactoring
- [ ] Documentation

## Architecture Compliance
- [ ] All layers present (Entity, Repository, Service, Controller)
- [ ] No circular dependencies
- [ ] Dependency Injection proper
- [ ] DTOs used
- [ ] Error handling implemented

## Testing
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] Manual testing completed

## Screenshots/Evidence (if applicable)
```

---

**Last Updated:** 2026-02-09
**Owner:** Development Team
