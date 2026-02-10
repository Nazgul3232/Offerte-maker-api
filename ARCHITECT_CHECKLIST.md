# Architecture Compliance Checklist

**🚨 STRICT ENFORCEMENT - Geen uitzonderingen!**

Dit checklist moet 100% voltooid zijn voordat een feature goedgekeurd wordt.

Architect Agent zal dit controleren op elke feature PR.

---

## Domain Layer (Entities)

- [ ] Entity class aangemaakt in `Entities/Models/YourEntity.cs`
- [ ] Namespace correct: `Entities.Models` (niet OfferteMakerApi.*)
- [ ] Guid Id als primary key (`public Guid Id { get; set; }`)
- [ ] Nullable reference properties correct (`public Company? Company { get; set; }`)
- [ ] Foreign keys met Guid (`public Guid CompanyId { get; set; }`)
- [ ] Timestamps (CreatedDate, UpdatedDate) indien relevant
- [ ] Geen business logic in entity (alleen properties)

**Reference:** [ARCHITECTURE.md → Domain Layer](./ARCHITECTURE.md#4-domain-layer-entities)

---

## Data Access Layer - Configuration

- [ ] Entity Framework configuration aangemaakt: `Repository/Configuration/YourEntityConfiguration.cs`
- [ ] Implements `IEntityTypeConfiguration<YourEntity>`
- [ ] HasKey(), Property(), HasOne(), HasMany() correct geconfigureerd
- [ ] Foreign key constraints en DeleteBehavior ingesteld
- [ ] ToTable() naam correct

**Reference:** [ARCHITECTURE.md → Data Access Layer](./ARCHITECTURE.md#3-data-access-layer-repository--contracts)

---

## Data Access Layer - Repository

- [ ] Interface aangemaakt: `Contracts/IYourRepository.cs`
  - [ ] Methods voor GetAll, GetById, Create, Update, Delete
  - [ ] Async methods (`Task<>`)
  - [ ] trackChanges parameter waar relevant

- [ ] Repository implementatie: `Repository/YourRepository.cs`
  - [ ] Extends `RepositoryBase<YourEntity>`
  - [ ] Implements `IYourRepository`
  - [ ] Constructor met RepositoryContext
  - [ ] Implementeert alle interface methods
  - [ ] Gebruikt FindAll(), FindByCondition(), Create(), Update(), Delete()

- [ ] Geregistreerd in `RepositoryManager.cs`
  - [ ] Private readonly Lazy<IYourRepository> property
  - [ ] Lazy initialization in constructor
  - [ ] Public property: `public IYourRepository YourEntity => _yourRepository.Value;`

- [ ] EF Migration aangemaakt
  - [ ] `dotnet ef migrations add AddYourEntity`
  - [ ] Reviewed en goedgekeurd

**Reference:** [ARCHITECTURE.md → Repository Pattern](./ARCHITECTURE.md#2-repository-pattern)

---

## Business Logic Layer - Service

- [ ] Service interface aangemaakt: `Service.Contracts/IYourService.cs`
  - [ ] Methods voor GetAll, GetById, Create, Update, Delete
  - [ ] Async methods (`Task<>`)
  - [ ] Parameter types: DTOs (niet entities!)
  - [ ] Return types: DTOs (niet entities!)

- [ ] Service implementatie: `Service/YourService.cs`
  - [ ] Constructor: IRepositoryManager, IMapper
  - [ ] Implements `IYourService`
  - [ ] Business logic (validatie, transformatie, orchestration)
  - [ ] Alle methods async
  - [ ] Error handling (custom exceptions voor business errors)
  - [ ] Mapper.Map() gebruikt voor entity ↔ DTO conversie

- [ ] Geregistreerd in `ServiceManager.cs`
  - [ ] Private readonly Lazy<IYourService> property
  - [ ] Lazy initialization in constructor
  - [ ] Public property: `public IYourService YourEntity => _yourService.Value;`

- [ ] AutoMapper profile updated: `OfferteMakerApi/MappingProfile.cs`
  - [ ] CreateMap<YourEntity, YourDto>()
  - [ ] CreateMap<CreateYourDto, YourEntity>()
  - [ ] CreateMap<UpdateYourDto, YourEntity>()

**Reference:** [ARCHITECTURE.md → Service Pattern](./ARCHITECTURE.md#3-service-pattern)

---

## Shared Layer - DTOs

- [ ] DTOs aangemaakt in `Shared/DataTransferObjects/`
  - [ ] YourDto.cs (read)
  - [ ] CreateYourDto.cs (create)
  - [ ] UpdateYourDto.cs (update)

- [ ] DTO Properties
  - [ ] PascalCase properties
  - [ ] Geen Entity references
  - [ ] Primitieve types of andere DTOs only
  - [ ] Validation attributes waar relevant (Required, StringLength, etc.)

**Reference:** [ARCHITECTURE.md → DTO Pattern](./ARCHITECTURE.md#4-dto-pattern)

---

## Presentation Layer - Controller

- [ ] Controller aangemaakt: `OfferteMakerApi.Presentation/Controllers/YourEntitiesController.cs`
  - [ ] Extends ControllerBase
  - [ ] [ApiController] attribute
  - [ ] [Route("api/[controller]")] of [Route("api/v1/[controller]")]

- [ ] HTTP Methods
  - [ ] GET GetAll() - returns IEnumerable<YourDto>
  - [ ] GET GetById(id) - returns YourDto
  - [ ] POST Create(CreateYourDto) - returns CreatedAtAction
  - [ ] PUT Update(id, UpdateYourDto) - returns NoContent
  - [ ] DELETE Delete(id) - returns NoContent

- [ ] Dependency Injection
  - [ ] Constructor injects IServiceManager
  - [ ] Niet: statische fields, service locator pattern

- [ ] Validation & Error Handling
  - [ ] [ServiceFilter(typeof(ValidationFilterAttribute))] op POST/PUT
  - [ ] Try-catch waar relevant
  - [ ] Correct HTTP status codes (201, 204, 404, 400)

- [ ] XML Documentation Comments
  - [ ] /// <summary> op elke public method
  - [ ] /// <param> op parameters
  - [ ] /// <returns> op return type
  - [ ] /// <remarks> waar relevant

- [ ] Namespace correct: `OfferteMakerApi.Presentation.Controllers`

**Reference:** [ARCHITECTURE.md → Presentation Layer](./ARCHITECTURE.md#1-presentation-layer)

---

## Code Quality & Patterns

- [ ] **DTO Pattern enforced**
  - [ ] NO entities in API responses
  - [ ] ALL DTOs used for input/output

- [ ] **Async/Await**
  - [ ] Alle I/O operations zijn async
  - [ ] Geen .Result, .Wait()
  - [ ] Task<> return types

- [ ] **Dependency Injection**
  - [ ] Constructor injection only
  - [ ] Geregistreerd in Program.cs of Manager classes
  - [ ] Geen static fields voor dependencies

- [ ] **Namespaces**
  - [ ] Alle classes: `OfferteMakerApi.*` (NOT CompanyEmployees)
  - [ ] Geen gemengde namespaces

- [ ] **No Circular Dependencies**
  - [ ] Controller → Service → Repository (één richting)
  - [ ] Service mag NIET rechtstreeks Service aanroepen
  - [ ] Service gebruikt RepositoryManager, niet andere services

- [ ] **Error Handling**
  - [ ] Custom exceptions in `Entities/Exceptions/`
  - [ ] GlobalExceptionHandler vangt exceptions
  - [ ] ErrorDetails in responses

---

## Testing (if applicable)

- [ ] Unit tests voor Service
- [ ] Integration tests voor Controller
- [ ] Edge cases covered

---

## Git & Documentation

- [ ] Commit message duidelijk: `feat: Add quotes feature`
- [ ] Branch naam: `feature/add-quotes`
- [ ] Geen merge conflicts
- [ ] README.md updated (if needed)

---

## Checklist Summary

**Voor goedkeuring MOETEN ALLE items gechecked zijn.**

Een enkele afwijking = REJECTED → Developer fix → Resubmit

---

**Vragen?** Zie [ARCHITECTURE.md](./ARCHITECTURE.md) en [DEVELOPMENT_GUIDELINES.md](./DEVELOPMENT_GUIDELINES.md)
