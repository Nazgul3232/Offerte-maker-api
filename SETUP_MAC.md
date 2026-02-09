# Setup Guide - macOS (Mac Mini)

Complete setup instructions for running the Offerte Maker API on macOS.

## 📋 Prerequisites

- macOS 12.0 or later
- Homebrew (optional but recommended)
- Internet connection

## 🚀 Step 1: Install .NET 8 SDK

### Option A: Using Homebrew (Recommended)

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install .NET 8 SDK
brew install dotnet@8

# Verify installation
dotnet --version
# Should output: 8.x.x
```

### Option B: Direct Download

1. Visit: https://dotnet.microsoft.com/download/dotnet/8.0
2. Download **macOS arm64** (for Apple Silicon M1/M2/M3)
3. Or **macOS x64** (for Intel Mac)
4. Run the installer
5. Verify:
   ```bash
   dotnet --version
   ```

## 🐳 Step 2: Install Docker Desktop for Mac

1. Download: https://www.docker.com/products/docker-desktop
2. Choose **Apple Silicon** (M1/M2/M3) or **Intel** version
3. Open the .dmg file and drag Docker to Applications
4. Launch Docker from Applications
5. Wait for Docker to start (icon in menu bar)
6. Verify installation:
   ```bash
   docker --version
   docker run hello-world
   ```

## 📦 Step 3: Create docker-compose.yml

Create this file in the root of your project:

```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: offerte-maker-db
    environment:
      ACCEPT_EULA: "Y"
      SA_PASSWORD: "YourSecurePassword123!"
      MSSQL_PID: "Developer"
    ports:
      - "1433:1433"
    volumes:
      - sqlserver-data:/var/opt/mssql
    healthcheck:
      test: ["CMD-SHELL", "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourSecurePassword123!' -Q 'SELECT 1' || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  sqlserver-data:
    driver: local
EOF
```

Or copy from the repo if provided.

## 🔧 Step 4: Update Connection String

Edit `CompanyEmployees/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "sqlConnection": "Server=localhost,1433;Database=OffereMakerDb;User Id=sa;Password=YourSecurePassword123!;Encrypt=false;TrustServerCertificate=true;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information"
    }
  },
  "Jwt": {
    "Secret": "your-256-bit-secret-key-here-minimum-256-bits",
    "Issuer": "OffermakerAPI",
    "Audience": "OffermakerAPIClients",
    "ExpiresIn": 3600
  }
}
```

## 🚀 Step 5: Start the Application

### Terminal 1: Start SQL Server

```bash
# Navigate to project root
cd /Users/frodo/Offerte-maker-api

# Start Docker container
docker-compose up

# You should see:
# ✓ offerte-maker-db  (health: starting → healthy)
```

Wait for "healthy" status (takes ~30 seconds).

### Terminal 2: Apply Migrations & Start API

```bash
# Navigate to API project
cd CompanyEmployees

# Restore NuGet packages
dotnet restore

# Apply database migrations
dotnet ef database update

# Run the API
dotnet run

# You should see:
# info: Microsoft.Hosting.Lifetime[14]
#       Now listening on: https://localhost:5001
#       Now listening on: http://localhost:5000
```

## ✅ Verify Everything Works

1. **Open Swagger UI**
   - URL: https://localhost:5001/swagger/index.html
   - Or: http://localhost:5000/swagger/index.html

2. **Test Database Connection**
   - Try any GET endpoint: `/api/v1/companies`
   - Should return: `[]` (empty array)

3. **Check Logs**
   - Look for "Application started" message
   - No errors in terminal

## 🔐 Security Note

The password `YourSecurePassword123!` is for development only!

For production, use strong passwords and environment variables:

```bash
export SA_PASSWORD="YourActualSecurePassword123!"
docker-compose up
```

## 📱 Useful Commands

### Docker

```bash
# View running containers
docker ps

# View logs
docker logs offerte-maker-db

# Stop containers
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Restart containers
docker-compose restart

# Shell into container
docker exec -it offerte-maker-db /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourSecurePassword123!'
```

### .NET

```bash
# Run with hot reload
dotnet watch run

# Run tests
dotnet test

# Build release
dotnet build -c Release

# Publish
dotnet publish -c Release -o ./publish

# Clean
dotnet clean
```

## 🐛 Troubleshooting

### Docker not starting
```bash
# Start Docker manually
open /Applications/Docker.app

# Or restart Docker
docker restart
```

### Connection timeout
```bash
# Check if SQL Server is healthy
docker-compose ps

# Wait a bit longer and retry (takes ~30 seconds)
# Check logs: docker-compose logs sqlserver
```

### Port 1433 already in use
```bash
# Kill existing process on port 1433
lsof -ti:1433 | xargs kill -9

# Or use different port in docker-compose.yml
# Change: "1433:1433" to "1434:1433"
# Update connection string accordingly
```

### Migration errors
```bash
# Reset database
docker-compose down -v
docker-compose up

# Then reapply migrations
dotnet ef database update
```

### .NET not found
```bash
# Add to ~/.zshrc or ~/.bash_profile
export PATH="$PATH:/usr/local/share/dotnet"

# Reload shell
source ~/.zshrc

# Verify
dotnet --version
```

## 💡 Development Workflow

1. **Terminal 1: SQL Server**
   ```bash
   docker-compose up
   ```

2. **Terminal 2: API (with auto-reload)**
   ```bash
   cd CompanyEmployees
   dotnet watch run
   ```

3. **Terminal 3: Code editing**
   ```bash
   code .
   ```

When you save code, the API automatically reloads. Perfect for development!

## 🎯 What's Next?

- Read [README.md](./README.md) for API overview
- Check [ARCHITECTURE.md](./ARCHITECTURE.md) for system design
- See [DEVELOPMENT_GUIDELINES.md](./DEVELOPMENT_GUIDELINES.md) for adding features
- Review [CODE_REVIEW_STANDARDS.md](./CODE_REVIEW_STANDARDS.md) before creating PRs

## 📞 Help

If you have issues:

1. Check Docker Desktop is running (icon in menu bar)
2. Check .NET version: `dotnet --version` (should be 8.x)
3. Check SQL Server logs: `docker-compose logs sqlserver`
4. Check API logs in terminal output
5. Verify connection string in appsettings.json

---

**Last Updated:** 2026-02-09
**Platform:** macOS (Apple Silicon & Intel)
**Framework:** .NET 8.0
**Database:** SQL Server 2022
