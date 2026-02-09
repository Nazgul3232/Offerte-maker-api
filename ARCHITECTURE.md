# Architectuur Document - Offerte Maker API

## Overzicht

Dit document beschrijft de architectuur van de Offerte Maker API. Deze architectuur dient als basis voor alle toekomstige API-uitbreidingen en modules.

**Framework:** .NET 8.0
**Architectuur Pattern:** Clean Layered Architecture
**Database:** SQL Server met Entity Framework Core

---

## Architectuur Lagen

De applicatie is ingedeeld in duidelijk gescheiden lagen, elk met een specifieke verantwoordelijkheid:

### 1. **Presentation Layer** (`CompanyEmployees.Presentation`)
- **Verantwoordelijkheid:** HTTP-requests verwerken, validatie, response-formatting
- **Inhoud:**
  - Controllers: API endpoints definiëren
  - ActionFilters: Custom validation en processing logic
  - ModelBinders: Request data binding
- **Key Classes:**
  - `CompaniesController`, `EmployeesController`, `AuthenticationController`
  - `ValidationFilterAttribute`, `ValidateMediaTypeAttribute`
- **Afhankelijkheden:** Service.Contracts, Shared DTOs

### 2. **Business Logic Layer** (`Service` + `Service.Contracts`)
- **Verantwoordelijkheid:** Bedrijfslogica, data transformatie, orchestratie
- **Inhoud:**
  - Service implementaties: `CompanyService`, `EmployeeService`, `AuthenticationService`
  - Data shaping: CSV, JSON formatting
  - Contracts: `ICompanyService`, `IEmployeeService` interfaces
  - Manager: `ServiceManager` als entry point
- **Afhankelijkheden:** Repository, Entities, Shared

### 3. **Data Access Layer** (`Repository` + `Contracts`)
- **Verantwoordelijkheid:** Database communicatie, CRUD operaties
- **Inhoud:**
  - Repositories: `CompanyRepository`, `EmployeeRepository`
  - Base: `RepositoryBase<T>` voor generische operaties
  - Context: `RepositoryContext` (DbContext)
  - Manager: `RepositoryManager` als entry point
  - Configurations: Entity Framework mapping configuraties
- **Afhankelijkheden:** Entities, Microsoft.EntityFrameworkCore

### 4. **Domain Layer** (`Entities`)
- **Verantwoordelijkheid:** Domain models, business regels
- **Inhoud:**
  - Models: `Company`, `Employee`, `User`
  - ErrorModel: `ErrorDetails` voor error responses
  - ConfigurationModels: Externe config DTOs
  - Exceptions: Custom exception classes
  - LinkModels: HATEOAS link models
- **Geen afhankelijkheden op andere lagen**

### 5. **Shared Layer** (`Shared`)
- **Verantwoordelijkheid:** Gedeelde code, DTOs, helper classes
- **Inhoud:**
  - DataTransferObjects: `CompanyDto`, `EmployeeDto`, `CreateCompanyDto` etc.
  - RequestFeatures: `RequestParameters` voor paging, sorting, filtering
- **Gebruikt door:** Alle lagen

### 6. **Cross-cutting Concerns**

#### Logger Service (`LoggerService`)
- Centralized logging met NLog
- Interface: `ILoggerManager`
- Implementatie: Configuratie via `nlog.config`

#### Exception Handling (`CompanyEmployees/Extensions`)
- `GlobalExceptionHandler`: Centralized exception handling
- Alle unhandled exceptions worden afgevangen en geformatteerd

#### Authentication & Authorization
- JWT Bearer tokens
- Identity configuratie
- Role-based access control (Manager, Administrator)

---

## Dependency Injection & Configuration

### Registratie in Program.cs
Alle dependencies worden in `Program.cs` ingeschreven via extension methods:

```csharp
builder.Services.ConfigureLoggerService();
builder.Services.ConfigureRepositoryManager();
builder.Services.ConfigureServiceManager();
builder.Services.ConfigureSqlContext();
builder.Services.ConfigureIdentity();
builder.Services.ConfigureJWT();
```

**Patroon:** Extension methods in `Extensions` folder voor duidelijkheid en modulairheid.

---

## Data Flow

### Standaard Request Flow

```
HTTP Request
    ↓
Controller (Presentation)
    ↓ (IServiceManager)
ServiceManager → Specifieke Service
    ↓ (IRepositoryManager)
RepositoryManager → Specifieke Repository
    ↓
Entity Framework Core
    ↓
SQL Server Database
```

### Response Flow

```
Database
    ↓
Entity Models
    ↓
DTOs (in Service)
    ↓
JSON/XML/CSV (via Controller + MediaType)
    ↓
HTTP Response
```

---

## Key Design Patterns

### 1. **Manager Pattern**
- `ServiceManager` en `RepositoryManager` als centrales entry points
- Lazy loading voor repositories (performantie)
- Eén place to configure alle dependencies

### 2. **Repository Pattern**
- Abstract base class: `RepositoryBase<T>`
- Specifieke repositories: `CompanyRepository`, `EmployeeRepository`
- Abstrahering van database details

### 3. **Service Pattern**
- Bedrijfslogica gescheiden van data access
- Services gebruiken repositories voor data
- Transformatie van entities naar DTOs

### 4. **DTO Pattern**
- Entities worden niet direct naar client gestuurd
- DTOs beschermen internal structure
- Eenvoudigere versioning

### 5. **Configuration Pattern**
- Entity Framework Fluent API configuraties
- `IEntityTypeConfiguration<T>` implementaties
- Centraal in `Repository/Configuration`

---

## Folder Structuur

```
Offerte-maker-api/
└── CompanyEmployees/
    ├── CompanyEmployees/                      # Main API Project
    │   ├── Program.cs
    │   ├── Extensions/                        # DI & Configuration
    │   ├── Utility/                           # Utility Classes
    │   ├── Migrations/                        # EF Migrations
    │   ├── ContextFactory/                    # DbContext Factory
    │   └── Properties/
    │
    ├── CompanyEmployees.Presentation/         # Presentation Layer
    │   ├── Controllers/
    │   ├── ActionFilters/
    │   └── ModelBinders/
    │
    ├── Service/                               # Business Logic Layer
    │   ├── ServiceManager.cs
    │   ├── *Service.cs
    │   └── DataShaping/
    │
    ├── Service.Contracts/                     # Service Interfaces
    │   └── I*Service.cs
    │
    ├── Repository/                            # Data Access Layer
    │   ├── RepositoryManager.cs
    │   ├── *Repository.cs
    │   ├── RepositoryBase.cs
    │   ├── RepositoryContext.cs
    │   ├── Configuration/                     # EF Configurations
    │   └── Extensions/
    │
    ├── Contracts/                             # Repository Interfaces
    │   └── I*Repository.cs
    │
    ├── Entities/                              # Domain Models
    │   ├── Models/
    │   ├── Exceptions/
    │   ├── ErrorModel/
    │   ├── LinkModels/
    │   └── ConfigurationModels/
    │
    ├── Shared/                                # Shared Code
    │   ├── DataTransferObjects/
    │   └── RequestFeatures/
    │
    └── LoggerService/                         # Cross-cutting Logger
        └── ILoggerManager.cs
```

---

## Versioning & API Contracts

### API Versioning
- Versies via URL: `/api/v1/companies`, `/api/v2/companies`
- Implementatie: Separate controllers voor elke versie
- Konfiguratie: `Services.ConfigureVersioning()`

### Content Negotiation
- Ondersteunde formats: JSON, XML, CSV
- MediaType handling: `ValidateMediaTypeAttribute`
- Extension methods: `AddCustomCSVFormatter()`

### HATEOAS (Hypermedia)
- Link generation voor resources
- `EmployeeLinks` voor dynamic link generation
- HAL-style responses (optional)

---

## Security Measures

### Authentication
- JWT Bearer tokens
- `Microsoft.AspNetCore.Authentication.JwtBearer`
- Token refresh endpoint

### Authorization
- Role-based (Manager, Administrator)
- Attributes op controllers/actions
- `IAuthorizationService` voor granulaire controle

### Rate Limiting
- Configuratie: `Services.ConfigureRateLimitingOptions()`
- Bescherming tegen abuse

### CORS
- Configuratie: `Services.ConfigureCors()`
- Origin validation

---

## Database Design

### Entities
- **Company:** Bedrijfsgegevens
- **Employee:** Werknemergegevens + CompanyId
- **User/Identity:** Authenticatie & autorisatie (ASP.NET Identity)

### Migraties
- Location: `CompanyEmployees/Migrations`
- Gereedschap: EF Core Migrations
- Database: SQL Server

### Conventions
- PascalCase voor column names
- Foreign keys: `CompanyId`, `EmployeeId`
- Timestamps: `CreatedDate`, `UpdatedDate` (if applicable)

---

## Error Handling

### Exception Strategy
- Custom exceptions in `Entities/Exceptions`
- `GlobalExceptionHandler` vangt alle unhandled exceptions
- Gestructureerde error responses: `ErrorDetails`

### Error Response Format
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "statusCode": 404,
  "message": "Resource not found",
  "details": "The requested company does not exist"
}
```

---

## Logging

### Implementatie
- NLog voor logging
- Configuratie: `nlog.config`
- Log levels: Debug, Info, Warn, Error, Fatal

### Log Locations
- Console output (development)
- File logging (production)
- Location configureerbaar in `nlog.config`

---

## Testing Strategy

### Unit Tests
- Per laag (Service, Repository tests)
- Mocking van dependencies
- Focus op bedrijfslogica

### Integration Tests
- Controller tests met echte dependencies
- In-memory database
- API endpoint validatie

### Location
- Separate `*.Tests` projects
- Naming: `ServiceTests`, `RepositoryTests`

---

## Development Guidelines

### Toevoegen van Nieuwe API's / Features

#### Stap 1: Domain Layer
1. Creëer/update `Entities/Models/YourEntity.cs`
2. Voeg validatie/business regels toe

#### Stap 2: Data Access Layer
1. Creëer `Repository/YourRepository.cs` (extends `RepositoryBase<T>`)
2. Creëer `Contracts/IYourRepository.cs`
3. Voeg entity configuration toe in `Repository/Configuration/`
4. Registreer in `RepositoryManager`
5. Voeg migration toe: `dotnet ef migrations add YourFeature`

#### Stap 3: Business Logic Layer
1. Creëer `Service/YourService.cs`
2. Creëer `Service.Contracts/IYourService.cs`
3. Registreer in `ServiceManager`
4. Implement bedrijfslogica

#### Stap 4: Presentation Layer
1. Creëer `YourController.cs` in `CompanyEmployees.Presentation/Controllers`
2. Voeg DTOs toe in `Shared/DataTransferObjects`
3. Implement HTTP endpoints
4. Voeg validation toe via `ValidationFilterAttribute`

#### Stap 5: Documentation
- Swagger comments op endpoints: `/// <summary>`, `/// <param>`, `/// <returns>`
- Update architectuur doc indien nodig

### Code Style & Standards

#### Naming Conventions
- **Classes:** PascalCase (`CompanyService`, `CompanyRepository`)
- **Methods:** PascalCase (`GetAllCompanies`)
- **Properties:** PascalCase (`Id`, `Name`)
- **Private fields:** camelCase met `_` prefix (`_repository`, `_logger`)
- **Parameters:** camelCase (`companyId`, `requestParameters`)

#### File Organization
- Eén public class per file
- File name = class name
- Logical grouping in folders

#### Dependency Injection
- Constructor injection voor dependencies
- Explicit registration in `Program.cs` via extension methods
- Geen service locator anti-pattern

### Documentation Requirements
- XML comments op public methods
- README.md voor nieuwe modules
- Update ARCHITECTURE.md bij major changes

---

## Performance Considerations

### Database
- Lazy loading in `RepositoryManager` (Lazy<T>)
- Efficient queries (select columns, filtering at DB level)
- Connection pooling (default in EF Core)

### Caching
- Output caching beschikbaar: `Services.ConfigureOutputCaching()`
- Response caching headers kunnen worden toegevoegd

### API Optimization
- Paging via `RequestParameters`
- Minimal JSON responses (via DTOs)
- Compression headers

---

## Deployment

### Build Configuration
- Framework: .NET 8.0
- Publish Profile: `Properties/PublishProfiles`
- IIS Integration: `Services.ConfigureIISIntegration()`

### Environment Configuration
- appsettings.json (default)
- appsettings.Development.json
- appsettings.Production.json (not in repo)
- Environment variables for sensitive data

---

## Checklist voor Code Review

Wanneer een nieuwe feature/API wordt toegevoegd:

- [ ] Volgt de code de layered architecture?
- [ ] Zijn alle lagen aanwezig? (Entity, Repository, Service, Controller, DTO)
- [ ] Is dependency injection correct geconfigureerd?
- [ ] Zijn er unit tests?
- [ ] Is error handling aanwezig?
- [ ] Heeft de controller XML comments?
- [ ] Is versioning correct geimplementeerd (indien nodig)?
- [ ] Zijn DTOs gebruikt (geen entity exposure)?
- [ ] Is de code testable (geen tight coupling)?
- [ ] Volgt de code de naming conventions?

---

## Troubleshooting

### Geen repositories in ServiceManager
**Probleem:** `ServiceManager` ziet de `RepositoryManager` niet
**Oplossing:** Zorg dat `RepositoryManager` in `Program.cs` is geregistreerd

### Migratie errors
**Probleem:** Fout bij `dotnet ef database update`
**Oplossing:**
1. Check `DbContext` constructor in `RepositoryContext`
2. Check connection string in `appsettings.json`
3. Check `ContextFactory` voor EF tooling

### DTO <-> Entity mapping errors
**Probleem:** AutoMapper kan mapping niet vinden
**Oplossing:** Check AutoMapper profile registratie in `Program.cs`

---

## Toekomstige Uitbreidingen

Mogelijke verbeteringen zonder deze architectuur te wijzigen:

- [ ] CQRS pattern (separate read/write services)
- [ ] Event sourcing
- [ ] Background jobs (Hangfire)
- [ ] Caching layer (Redis)
- [ ] API documentation (Swagger/OpenAPI enhancements)
- [ ] Distributed tracing (OpenTelemetry)
- [ ] Message queue integration (RabbitMQ, Azure Service Bus)
- [ ] Async validation
- [ ] GraphQL endpoint

---

**Laatst bijgewerkt:** 2026-02-09
**Versie:** 1.0
**Owner:** Development Team
