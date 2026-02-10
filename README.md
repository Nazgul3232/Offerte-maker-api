# Offerte Maker API

A professional, scalable REST API for quote/offer generation built with clean layered architecture using .NET 8.0 and SQL Server.

## 🏗️ Architecture

This project follows a **Clean Layered Architecture** pattern, separating concerns into distinct layers:

```
┌─────────────────────────────┐
│   Presentation Layer        │  Controllers, DTOs, Validation
├─────────────────────────────┤
│   Business Logic Layer      │  Services, AutoMapper, DataShaping
├─────────────────────────────┤
│   Data Access Layer         │  Repositories, UnitOfWork Pattern
├─────────────────────────────┤
│   Domain Layer              │  Entities, Exceptions, Configurations
└─────────────────────────────┘
```

For detailed architecture documentation, see [ARCHITECTURE.md](./ARCHITECTURE.md)

## 🚀 Quick Start

### Prerequisites

- **.NET 8.0** SDK or later
- **SQL Server** (local or Azure)
- **Visual Studio 2022** or **VS Code**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Nazgul3232/Offerte-maker-api.git
   cd Offerte-maker-api
   ```

2. **Update connection string**

   Edit `OfferteMakerApi/OfferteMakerApi/appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "sqlConnection": "Server=YOUR_SERVER;Database=OfferterMaker;Trusted_Connection=true;Encrypt=false;"
     }
   }
   ```

3. **Apply database migrations**
   ```bash
   cd OfferteMakerApi/OfferteMakerApi
   dotnet ef database update
   ```

4. **Run the API**
   ```bash
   dotnet run
   ```

5. **Access the API**
   - **Swagger UI:** https://localhost:5001/swagger/index.html
   - **API Base URL:** https://localhost:5001/api

## 📁 Project Structure

```
Offerte-maker-api/
├── OfferteMakerApi/                     # Main API Project
│   ├── OfferteMakerApi/                # API Host & Configuration
│   ├── OfferteMakerApi.Presentation/   # Controllers, Filters, ModelBinders
│   ├── Service/                        # Business Logic Services
│   ├── Service.Contracts/              # Service Interfaces
│   ├── Repository/                     # Data Access Layer
│   ├── Contracts/                      # Repository Interfaces
│   ├── Entities/                       # Domain Models & Exceptions
│   ├── Shared/                         # DTOs & Request Features
│   └── LoggerService/                  # Logging
├── ARCHITECTURE.md                      # Architecture documentation
├── DEVELOPMENT_GUIDELINES.md           # Developer guide
└── CODE_REVIEW_STANDARDS.md            # Code review checklist
```

## 🔌 API Endpoints

### Companies
- `GET /api/v1/companies` - Get all companies
- `GET /api/v1/companies/{id}` - Get specific company
- `POST /api/v1/companies` - Create company
- `PUT /api/v1/companies/{id}` - Update company
- `DELETE /api/v1/companies/{id}` - Delete company

### Employees
- `GET /api/v1/employees` - Get all employees
- `GET /api/v1/employees/{id}` - Get specific employee
- `POST /api/v1/companies/{companyId}/employees` - Create employee
- `PUT /api/v1/employees/{id}` - Update employee
- `DELETE /api/v1/employees/{id}` - Delete employee

### Authentication
- `POST /api/authentication/register` - Register new user
- `POST /api/authentication/login` - Login & get JWT token
- `POST /api/token/refresh` - Refresh JWT token

See [Swagger documentation](https://localhost:5001/swagger) for complete API specification.

## 🔐 Authentication

The API uses **JWT (JSON Web Tokens)** for authentication:

1. **Register** a user account
2. **Login** to get an access token and refresh token
3. **Include token** in Authorization header:
   ```
   Authorization: Bearer <your-jwt-token>
   ```

### Roles
- **Manager** - Can manage employees and view reports
- **Administrator** - Full system access

## 🛠️ Development

### Adding a New Feature

Follow the step-by-step guide in [DEVELOPMENT_GUIDELINES.md](./DEVELOPMENT_GUIDELINES.md)

Quick overview:
1. Create Entity in `Entities/Models/`
2. Create Repository in `Repository/`
3. Create Service in `Service/`
4. Create DTOs in `Shared/DataTransferObjects/`
5. Create Controller in `OfferteMakerApi.Presentation/Controllers/`
6. Add AutoMapper configuration
7. Register in `Program.cs`

### Code Style

- **Naming:** PascalCase for public members, camelCase for private fields
- **DI:** Constructor injection only, no service locator
- **Async:** Always use async/await for I/O operations
- **DTOs:** Never expose entities directly to clients
- **Validation:** Use Data Annotations on DTOs

### Running Tests

```bash
dotnet test
```

## 📋 Code Review Process

All pull requests must follow [CODE_REVIEW_STANDARDS.md](./CODE_REVIEW_STANDARDS.md)

**Requirements before merge:**
- [ ] Architecture compliance verified
- [ ] All layers present (if adding feature)
- [ ] Unit tests included
- [ ] No circular dependencies
- [ ] DTOs used (no entity exposure)
- [ ] Documentation updated
- [ ] Code follows naming conventions

## 📚 Documentation

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture, patterns, design decisions
- **[DEVELOPMENT_GUIDELINES.md](./DEVELOPMENT_GUIDELINES.md)** - How to add features, code patterns, troubleshooting
- **[CODE_REVIEW_STANDARDS.md](./CODE_REVIEW_STANDARDS.md)** - Code review checklist and standards

## 🔧 Technologies

- **Framework:** .NET 8.0
- **Database:** SQL Server with Entity Framework Core 8.0
- **Authentication:** JWT Bearer Tokens with ASP.NET Identity
- **Mapping:** AutoMapper for DTO transformation
- **Logging:** NLog
- **API Documentation:** Swagger/OpenAPI
- **Validation:** Data Annotations + Custom Filters
- **Content Negotiation:** JSON, XML, CSV support

## 🐛 Troubleshooting

### Database Connection Error
```
A network-related or instance-specific error occurred while establishing a connection to SQL Server...
```

**Solution:** Check your connection string in `appsettings.json`

### Migration Failed
```
The 'RepositoryContext' type has not been added to the service provider...
```

**Solution:** Ensure `ConfigureSqlContext()` is called in `Program.cs`

### AutoMapper Configuration Error
```
Unmapped members found...
```

**Solution:** Check `MappingProfile` in `Program.cs` and add missing mappings

See [DEVELOPMENT_GUIDELINES.md](./DEVELOPMENT_GUIDELINES.md#troubleshooting) for more solutions.

## 🤝 Contributing

For detailed workflow instructions, see **[BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md)**

Quick summary:
1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Follow [DEVELOPMENT_GUIDELINES.md](./DEVELOPMENT_GUIDELINES.md)
3. Follow [CODE_REVIEW_STANDARDS.md](./CODE_REVIEW_STANDARDS.md)
4. Commit with clear messages following [Conventional Commits](https://www.conventionalcommits.org)
5. Run automated checks: `./scripts/architect-review.sh featurename`
6. Push to branch and create Pull Request
7. Architect Agent reviews for architecture compliance
8. Merge after approval

### Commit Message Format

```
feat: Brief description of feature

Longer explanation if needed.

Closes #123
```

**Standard prefix types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code refactoring
- `docs:` - Documentation
- `chore:` - Dependencies/build
- `test:` - Test additions

See [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md#commit-message-format) for detailed examples.

## 📈 Performance & Optimization

- Database queries are optimized with lazy loading and efficient filtering
- Output caching is configured for GET endpoints
- Rate limiting protects against abuse
- CORS policy is configured for security
- Paging support for large datasets

## 🔒 Security

- **Authentication:** JWT tokens with configurable expiration
- **Authorization:** Role-based access control
- **Validation:** Input validation on all endpoints
- **Error Handling:** Sensitive information not exposed in responses
- **SQL Injection:** Protected via Entity Framework Core
- **CORS:** Configurable origin validation

## 📦 Deployment

### Build for Production

```bash
dotnet build -c Release
```

### Publish

```bash
dotnet publish -c Release -o ./publish
```

### Environment Configuration

Create `appsettings.Production.json`:
```json
{
  "ConnectionStrings": {
    "sqlConnection": "Your production connection string"
  },
  "Jwt": {
    "Secret": "Your production secret key (min 128 bits)",
    "Issuer": "OffermakerAPI",
    "Audience": "OffermakerAPIClients",
    "ExpiresIn": 3600
  }
}
```

## 📊 API Versioning

The API supports multiple versions:

- **v1:** `GET /api/v1/companies`
- **v2:** `GET /api/v2/companies`

Each version can have different response formats and business logic.

## 🎯 Roadmap

- [ ] CQRS pattern for complex queries
- [ ] Event sourcing for audit trails
- [ ] Background jobs (Hangfire)
- [ ] Redis caching layer
- [ ] GraphQL endpoint
- [ ] OpenTelemetry tracing
- [ ] Message queue integration
- [ ] API rate limiting by user
- [ ] Advanced filtering & search
- [ ] Bulk operations API

## 📝 License

This project is proprietary. All rights reserved.

## 👥 Contact

**Development Team**
Email: dev@offerte-maker.local

---

## Quick Links

- 📖 [Architecture Guide](./ARCHITECTURE.md)
- 💻 [Development Guide](./DEVELOPMENT_GUIDELINES.md)
- 🌳 [Branching Strategy](./BRANCHING_STRATEGY.md)
- ✅ [Code Review Standards](./CODE_REVIEW_STANDARDS.md)
- ✓ [Architecture Checklist](./ARCHITECT_CHECKLIST.md)
- 🔗 [GitHub Repository](https://github.com/Nazgul3232/Offerte-maker-api)

---

**Last Updated:** 2026-02-10 (Refactored: CompanyEmployees → OfferteMakerApi)
**Framework Version:** .NET 8.0
**Database:** SQL Server
